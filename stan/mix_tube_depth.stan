/*
Observations are either 0 or lognormal:
y_i ~ lognormal(mu_i, sigma) with probability pi_i,
y = 0 with probability 1-phi_i

Detection probability is a function of mu_obs:
phi_i ~ logistic(alpha+beta*mu_i)

mu_obs is a function of mu and depth (near-surface roots are harder to detect for handwavy reasons that probably include poor soil contact)
mu_obs_i ~ mu_i * inv_logit((depth-loc_surface)/scale_surface)

And mu is a function of depth and tube identity
(and eventually some other factors I haven't added yet):
mu_i ~ intercept + b_tube_i + b_depth * log(depth)

 Data is arranged in long format (Stan manual seems to call this "database style"),
 and presorted so that all the nonzeros are in a contiguous block.
*/

data{
	int<lower=0> N; 				// number of observations
	int<lower=0> T; 				// number of tubes
	int<lower=0, upper=T> tube[N]; 	// tube ID
	real<lower=0> depth[N];			// cm below surface within tube
	vector<lower=0>[N] y; 			// DV: mm^3 root / mm^2 image area
	int<lower=0, upper=1> y_logi[N]; // logical: is y > 0?
	int<lower=0, upper=N> first_pos; // index of the first nonzero y value
	int<lower=0, upper=N> n_pos;	// how many y are > 0?

	//Pseudodata for predictive check
	int<lower=0> N_pred;
	int<lower=0> T_pred;
	int<lower=0, upper=T> tube_pred[N_pred];
	real<lower=0> depth_pred[N_pred];

}

transformed data{
	real depth_logmean;
	real depth_pred_max;
	depth_logmean <- log(mean(depth));
	depth_pred_max <- max(depth_pred);
}

parameters{
	// for logit
	real a_detect;
	real b_detect;

	// Extra underdetection factor for near-surface roots
	real loc_surface;
	real<lower=0> scale_surface;

	// for depth regression
	real intercept;
	real b_depth;

	// subject effects
	vector[T] b_tube;
	real<lower=0> sig_tube;

	// residual
	real<lower=0> sigma;
}

transformed parameters{
	vector[N] mu; // E[latent mean root volume]
	vector[N] mu_obs; // E[OBSERVED root volume], including surface effect
	vector[N] detect_odds;
	real mu_obs_mean;

	for(n in 1:N){
		// Note centered regression --
		// intercept here is E[y] at mean depth, not surface!
		mu[n] <- intercept
			+ b_tube[tube[n]]
			+ b_depth*(log(depth[n]) - depth_logmean);
		mu_obs[n] <- mu[n]
			+ log(inv_logit((depth[n]-loc_surface)/scale_surface));
	}
	// center means for logistic regression, too
	mu_obs_mean <- mean(mu_obs);
	detect_odds <- a_detect + b_detect*(mu_obs - mu_obs_mean);
}

model{
	// Priors, mostly derived from assuming the range of log(y) is roughly -12 to 0.
	sig_tube ~ normal(0, 3);
	sigma ~ normal(0, 3);
	intercept ~ normal(-6, 6);
	b_depth ~ normal(-1, 5);
	a_detect ~ normal(0, 5);
	b_detect ~ normal(5, 10);
	loc_surface ~ normal(13, 10);
	scale_surface ~ normal(6, 5);

	b_tube ~ normal(0, sig_tube);
	y_logi ~ bernoulli_logit(detect_odds);
	segment(y, first_pos, n_pos) ~ lognormal(segment(mu_obs, first_pos, n_pos), sigma);
}

generated quantities{
	real b_tube_pred[T_pred];
	real<lower=0> pred_tot[T_pred];
	real mu_pred[N_pred];
	real mu_obs_pred[N_pred];
	real detect_odds_pred[N_pred];
	real<lower=0> y_pred[N_pred];

	for(t in 1:T_pred){
		// prediction offset for a random NEWLY OBSERVED tube.
		b_tube_pred[t] <- normal_rng(0, sig_tube);

		// total root volume in soil profile
		pred_tot[t] <-
			exp(intercept
				- b_depth*depth_logmean
				+ b_tube_pred[t])
			* (depth_pred_max^(b_depth+1) - 0.1*0.1^b_depth)
			/ (b_depth+1);
	}

	for(n in 1:N_pred){
		mu_pred[n] <-
			intercept
			+ b_tube_pred[tube_pred[n]]
			+ b_depth * (log(depth_pred[n]) - depth_logmean);
		mu_obs_pred[n] <-
			mu_pred[n]
			+ log(inv_logit((depth_pred[n]-loc_surface)/scale_surface));

		detect_odds_pred[n] <- inv_logit(
			a_detect + b_detect * (mu_obs_pred[n] - mu_obs_mean));

		y_pred[n] <- lognormal_rng(mu_obs_pred[n], sigma) * bernoulli_rng(detect_odds_pred[n]);
	}
}
