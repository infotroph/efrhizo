/*
Observations are either 0 ("none detected") or lognormal:
y_i ~ lognormal(mu_obs_i, sigma_i) with probability pi_i,
y_i = 0 with probability 1-phi_i

Detection probability increases with mu_obs_i:
phi_i ~ logistic(a_detect + b_detect*mu_obs_i)

mu_obs is biased low near surface, but converges to true mu at depth:
mu_obs_i ~ mu_i * logistic(a_surface + b_surface*depth)

And mu is a function of crop, depth and tube identity
(and eventually other factors I haven't added yet, including time):
mu_i ~ b_crop + b_tube_i + b_depth * log(depth)

Data is arranged in long format ("database style"),
and presorted by y so that all the zeros are in a contiguous block.
Only the positive values are passed to the lognormal sampler,
but zeroes still inform estimated mu through the detection probability.
*/

data{
	int<lower=0> N; 				// number of observations
	int<lower=0> T; 				// number of tubes
	int<lower=0> C;					// number of crops
	int<lower=0, upper=T> tube[N]; 	// tube ID
	int<lower=1, upper=C> crop[N]; // Be sure to check number<>crop mapping.
	real<lower=0> depth[N];			// cm below surface within tube
	vector<lower=0>[N] y; 			// DV: mm^3 root / mm^2 image area
	int<lower=0, upper=1> y_logi[N]; // logical: is y > 0?
	int<lower=0, upper=N> first_pos; // index of the first nonzero y value
	int<lower=0, upper=N> n_pos;	// how many y are > 0?

	//Pseudodata for predictive check
	int<lower=0> N_pred;
	int<lower=0> T_pred;
	int<lower=0> C_pred;
	int<lower=0, upper=C_pred> crop_pred[N_pred];
	int<lower=0, upper=T_pred> tube_pred[N_pred];
	real<lower=0> depth_pred[N_pred];
}

transformed data{
	real depth_logmean;
	real depth_pred_max;
	int<lower=1,upper=C> tube_crop[T];
	int<lower=1,upper=C_pred> tube_crop_pred[T_pred];
	real log_depth_centered[N];
	real log_depth_pred_centered[N_pred];

	depth_logmean <- log(mean(depth));
	depth_pred_max <- max(depth_pred);
	for(n in 1:N){
		tube_crop[tube[n]] <- crop[n];
		log_depth_centered[n] <- log(depth[n]) - depth_logmean;
	}
	for(n in 1:N_pred){
		tube_crop_pred[tube_pred[n]] <- crop_pred[n];
		log_depth_pred_centered[n] <- log(depth_pred[n]) - depth_logmean;
	}

}

parameters{
	// for logit
	real loc_detect;
	real<lower=0> scale_detect;

	// Extra underdetection factor for near-surface roots
	real loc_surface;
	real<lower=0> scale_surface;

	// for depth regression;
	// Each crop is fit separately
	vector[C] intercept;
	vector[C] b_depth;

	// subject effects
	vector[T] b_tube;
	real<lower=0> sig_tube[C];

	// residual -- allowed to vary by crop
	real<lower=0> sigma[C];
}

transformed parameters{
	vector[N] mu; // E[latent mean root volume]
	vector[N] mu_obs; // E[OBSERVED root volume], including surface effect
	vector[N] detect_odds;
	vector<lower=0>[N] sig;
	vector<lower=0>[T] sigt;

	for(n in 1:N){
		// Note centered regression --
		// intercept here is E[y] at mean depth, not surface!
		mu[n] <- intercept[crop[n]]
			+ b_tube[tube[n]]
			+ b_depth[crop[n]] * log_depth_centered[n];
		mu_obs[n] <- mu[n]
			+ log(inv_logit((depth[n]-loc_surface)/scale_surface));
		sig[n] <- sigma[crop[n]];
	}
	for(t in 1:T){
		sigt[t] <- sig_tube[tube_crop[t]];
	}

	// logistic regression for probability of detecting roots in a given image
	detect_odds <- (mu_obs - loc_detect)/scale_detect;
}

model{
	// Priors, mostly derived from assuming the range of log(y) is roughly -12 to 0.
	for(c in 1:C){
		sig_tube[c] ~ normal(0, 3);
		sigma[c] ~ normal(0, 3);
		intercept[c] ~ normal(-6, 6);
		b_depth[c] ~ normal(-1, 5);
	}
	loc_detect ~ normal(-8, 10);
	scale_detect ~ normal(0, 6);
	loc_surface ~ normal(13, 10);
	scale_surface ~ normal(6, 5);

	b_tube ~ normal(0, sigt);
	y_logi ~ bernoulli_logit(detect_odds);
	segment(y, first_pos, n_pos) ~ lognormal(
		segment(mu_obs, first_pos, n_pos), 
		segment(sig, first_pos, n_pos));
}

generated quantities{
	real b_tube_pred[T_pred];
	real<lower=0> pred_tot[T_pred];
	real mu_pred[N_pred];
	real mu_obs_pred[N_pred];
	real detect_odds_pred[N_pred];
	real<lower=0> y_pred[N_pred];
	real<lower=0> crop_tot[C];
	real crop_tot_diff[C-1];
	real crop_int_diff[C-1];
	real crop_bdepth_diff[C-1];

	// integral of expected root volume 
	// from surface to deepest predicted layer.
	// Starting from depth=0.1 cm instead of 0 to stabilize estimates,
	// otherwise they run to +/- infinity when b is near -1.
	for(c in 1:C){
		crop_tot[c] <- 
			(exp(intercept[c] - b_depth[c]*depth_logmean)
				* (depth_pred_max^(b_depth[c] + 1) - 0.1 * 0.1^b_depth[c]))
			/ (b_depth[c] + 1);
	}
	
	// Tests for differences between crops:
	// First expected total root volume, 
	// then the parameters that contribute to it.
	for(c in 2:C){
		crop_tot_diff[c-1] <- crop_tot[c] - crop_tot[1];
		crop_int_diff[c-1] <- intercept[c] - intercept[1];
		crop_bdepth_diff[c-1] <- b_depth[c] - b_depth[1];
	}

	for(t in 1:T_pred){
		int tc;
		tc <- tube_crop_pred[t];

		// prediction offset for a random NEWLY OBSERVED tube.
		b_tube_pred[t] <- normal_rng(0, sig_tube[tc]);

		// total root volume in soil profile
		pred_tot[t] <-
			exp(intercept[tc]
				- b_depth[tc]*depth_logmean
				+ b_tube_pred[t])
			* (depth_pred_max^(b_depth[tc]+1) - 0.1 * 0.1^b_depth[tc]) 
			/ (b_depth[tube_crop_pred[t]]+1);
	}

	for(n in 1:N_pred){
		mu_pred[n] <-
			intercept[crop_pred[n]]
			+ b_tube_pred[tube_pred[n]]
			+ b_depth[crop_pred[n]] * log_depth_pred_centered[n];
		mu_obs_pred[n] <-
			mu_pred[n]
			+ log(inv_logit((depth_pred[n]-loc_surface)/scale_surface));

		detect_odds_pred[n] <- inv_logit((mu_obs_pred[n] - loc_detect)/scale_detect);

		y_pred[n] <- lognormal_rng(mu_obs_pred[n], sigma[crop_pred[n]]) * bernoulli_rng(detect_odds_pred[n]);
	}
}
