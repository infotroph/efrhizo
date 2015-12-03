/*
Observations are either 0 or lognormal:
y_i ~ lognormal(mu_i, sigma) with probability pi_i,
y = 0 with probability 1-phi_i

Detection probability is a function of mu:
phi_i ~ logistic(alpha+beta*mu_i)

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
	vector<lower=0>[N] y; 			// DV
	int<lower=0, upper=1> y_logi[N]; // logical: is y > 0?
	int<lower=0, upper=N> first_pos; // index of the first nonzero y value
	int<lower=0, upper=N> n_pos;	// how many y are > 0?
}

parameters{
	// for logit
	real a_detect;
	real b_detect;

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
	vector[N] mu;
	vector[N] detect_odds;

	for(n in 1:N){
		// Note centered regression --
		// intercept here is E[y] at mean depth, not surface!
		mu[n] <- intercept
			+ b_tube[tube[n]]
			+ b_depth*(log(depth[n]) - log(mean(depth)));
	}
	// center means for logistic regression, too
	detect_odds <- a_detect + b_detect*(mu - mean(mu));
}

model{
	// Priors, mostly derived from assuming the range of log(y) is roughly -12 to 0.
	sig_tube ~ normal(0, 3);
	sigma ~ normal(0, 3);
	intercept ~ normal(-6, 6);
	b_depth ~ normal(-1, 5);
	a_detect ~ normal(0, 5);
	b_detect ~ normal(5, 10);

	b_tube ~ normal(0, sig_tube);
	y_logi ~ bernoulli_logit(detect_odds);
	segment(y, first_pos, n_pos) ~ lognormal(segment(mu, first_pos, n_pos), sigma);
}
