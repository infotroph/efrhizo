/*
Observations are either 0 ("none detected") or lognormal:
y_i ~ lognormal(mu_obs_i, sigma_i) with probability pi_i,
y_i = 0 with probability 1-phi_i

Detection probability increases with mu_obs_i:
phi_i ~ logistic(a_detect + b_detect*mu_obs_i)

mu_obs is biased low near surface, but converges to true mu at depth:
mu_obs_i ~ mu_i * logistic(a_surface_i + b_surface_i*depth)

And mu is a function of crop, depth and tube identity
(and eventually other factors I haven't added yet, including time):
mu_i ~ b_crop + b_tube_i + b_depth * log(depth)

Data is arranged in long format ("database style"),
and MUST be presorted with y decreasing,
so that all observations where y==0 are in a contiguous block at the end of the data.
Only the positive values are passed to the lognormal sampler,
but zeroes still inform estimated mu through the detection probability.
*/

data{
	int<lower=0> N; 				// number of observations
	int<lower=0> T; 				// number of tubes
	int<lower=0> C;					// number of crops
	int<lower=0, upper=T> tube[N]; 	// tube ID
	int<lower=1, upper=C> crop[N]; // Be sure to check number<>crop mapping.
	vector<lower=0>[N] depth;			// cm below surface within tube
	vector<lower=0>[N] y; 			// DV: mm^3 root / mm^2 image area

	//Pseudodata for predictive check
	int<lower=0> N_pred;
	int<lower=0> T_pred;
	int<lower=0> C_pred;
	int<lower=0, upper=C_pred> crop_pred[N_pred];
	int<lower=0, upper=T_pred> tube_pred[N_pred];
	real<lower=0> depth_pred[N_pred];

	//Priors
	real sig_tube_prior_m;
	real<lower=0> sig_tube_prior_s;
	real sigma_prior_m;
	real<lower=0> sigma_prior_s;
	real intercept_prior_m;
	real<lower=0> intercept_prior_s;
	real b_depth_prior_m;
	real<lower=0> b_depth_prior_s;
	real loc_surface_prior_m;
	real<lower=0> loc_surface_prior_s;
	real scale_surface_prior_m;
	real<lower=0> scale_surface_prior_s;
	real loc_detect_prior_m;
	real<lower=0> loc_detect_prior_s;
	real scale_detect_prior_m;
	real<lower=0> scale_detect_prior_s;
}

transformed data{
	real depth_logmean;
	real depth_pred_max;
	int<lower=1,upper=C_pred> tube_crop_pred[T_pred];
	vector[N] log_depth_centered;
	vector[N_pred] log_depth_pred_centered;
	int<lower=0, upper=1> y_logi[N]; // logical: is y > 0?
	int<lower=0, upper=N> n_pos;	// how many y are > 0?

	depth_logmean = log(mean(depth));
	depth_pred_max = max(depth_pred);
	for(n in 1:N){
		log_depth_centered[n] = log(depth[n]) - depth_logmean;
		y_logi[n] = int_step(y[n]);
	}
	n_pos = sum(y_logi);

	if(sum(y_logi[(n_pos+1):N]) != 0 || sum(y_logi[1:n_pos]) != n_pos){
		reject("all observations with y==0 must appear at the end of the dataset")
	}

	for(n in 1:N_pred){
		tube_crop_pred[tube_pred[n]] = crop_pred[n];
		log_depth_pred_centered[n] = log(depth_pred[n]) - depth_logmean;
	}

}

parameters{
	// for logit
	real loc_detect;
	real<lower=0> scale_detect;

	// Extra underdetection factor for near-surface roots
	vector[C] loc_surface;
	vector<lower=0>[C] scale_surface;

	// for depth regression;
	// Each crop is fit separately
	vector[C] intercept;
	vector[C] b_depth;

	// subject effects
	vector[T] b_tube;
	real<lower=0> sig_tube;

	// residual -- allowed to vary by crop
	vector<lower=0>[C] sigma;
}

transformed parameters{
	vector[N] mu; // E[latent mean root volume]
	vector[N] mu_obs; // E[OBSERVED root volume], including surface effect
	vector[N] detect_odds;

	// Note centered regression --
	// intercept here is E[y] at mean depth, not surface!
	mu = intercept[crop]
		+ b_tube[tube]
		+ b_depth[crop] .* log_depth_centered;
	mu_obs = mu + log_inv_logit((depth - loc_surface[crop]) ./ scale_surface[crop]);

	// logistic regression for probability of detecting roots in a given image
	detect_odds = (mu_obs - loc_detect)/scale_detect;
}

model{
	// Priors, mostly derived from assuming the range of log(y) is roughly -12 to 0.
	sig_tube ~ normal(sig_tube_prior_m, sig_tube_prior_s);
	b_tube ~ normal(0, sig_tube);
	sigma ~ normal(sigma_prior_m, sigma_prior_s);
	intercept ~ normal(intercept_prior_m, intercept_prior_s);
	b_depth ~ normal(b_depth_prior_m, b_depth_prior_s);
	loc_surface ~ normal(loc_surface_prior_m, loc_surface_prior_s);
	scale_surface ~ normal(scale_surface_prior_m, scale_surface_prior_s);
	loc_detect ~ normal(loc_detect_prior_m, loc_detect_prior_s);
	scale_detect ~ normal(scale_detect_prior_m, scale_detect_prior_s);
	
	// Likelihood.
	y_logi ~ bernoulli_logit(detect_odds);
	head(y, n_pos) ~ lognormal(head(mu_obs, n_pos), sigma[head(crop, n_pos)]);
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
	// Starting from depth=1 cm instead of 0 to stabilize estimates,
	// otherwise they run to +/- infinity when b is near -1.
	for(c in 1:C){
		if(b_depth[c] == -1.0){
			// integral below gives NaN when b+1==0, but is equal to:
			crop_tot[c] = exp(intercept[c] - b_depth[c]*depth_logmean)
			* log(depth_pred_max);
		}else{
			crop_tot[c] =
				exp(intercept[c] - b_depth[c]*depth_logmean)
				* (pow(depth_pred_max, b_depth[c] + 1.0) - 1.0)
				/ (b_depth[c] + 1.0);
		}
	}
	
	// Tests for differences between crops:
	// First expected total root volume, 
	// then the parameters that contribute to it.
	for(c in 2:C){
		crop_tot_diff[c-1] = crop_tot[c] - crop_tot[1];
		crop_int_diff[c-1] = intercept[c] - intercept[1];
		crop_bdepth_diff[c-1] = b_depth[c] - b_depth[1];
	}

	for(t in 1:T_pred){
		int tc;
		tc = tube_crop_pred[t];

		// prediction offset for a random NEWLY OBSERVED tube.
		b_tube_pred[t] = normal_rng(0, sig_tube);

		// total root volume in soil profile (from 1 cm to deepest pred depth)
		if(b_depth[tc] == -1.0){
			// integral below gives NaN when b+1==0, but is equal to:
			pred_tot[t] =
				exp(intercept[tc] - b_depth[tc]*depth_logmean + b_tube_pred[t])
				* log(depth_pred_max);
		}else{
			pred_tot[t] =
				exp(intercept[tc] - b_depth[tc]*depth_logmean + b_tube_pred[t])
				* (pow(depth_pred_max, b_depth[tc]+1) - 1)
				/ (b_depth[tc]+1);
		}
	}

	for(n in 1:N_pred){
		mu_pred[n] =
			intercept[crop_pred[n]]
			+ b_tube_pred[tube_pred[n]]
			+ b_depth[crop_pred[n]] * log_depth_pred_centered[n];
		mu_obs_pred[n] =
			mu_pred[n]
			+ log_inv_logit((depth_pred[n]-loc_surface[crop_pred[n]])/scale_surface[crop_pred[n]]);

		detect_odds_pred[n] = inv_logit((mu_obs_pred[n] - loc_detect)/scale_detect);

		y_pred[n] = lognormal_rng(mu_obs_pred[n], sigma[crop_pred[n]]) * bernoulli_rng(detect_odds_pred[n]);
	}
}
