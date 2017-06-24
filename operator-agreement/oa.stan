/*
Observations are either 0 ("none detected") or lognormal:
y_i ~ lognormal(mu_obs_i, sigma_i) with probability pi_i,
y_i = 0 with probability 1-phi_i

Detection probability increases with mu_obs_i:
phi_i ~ logistic(a_detect + b_detect*mu_obs_i)

Mu is a function of rater and image identity
mu_i ~ b_rater_i + b_image_i

Data is arranged in long format ("database style"),
and presorted with y decreasing, or at least with all the zeros after all the nonzeros.
Only the positive values are passed to the lognormal sampler,
but zeroes still inform estimated mu through the detection probability.
*/

data{
	int<lower=0> N; 				// number of observations
	int<lower=0> I; 				// number of images
	int<lower=0> R;					// number of raters
	int<lower=0, upper=I> image[N]; 
	int<lower=1, upper=R> rater[N]; 
	vector<lower=0>[N] y; 			// DV: mm^3 root / mm^2 image area
}
transformed data{
	int<lower=0, upper=1> y_logi[N]; // logical: is y > 0?
	int<lower=0, upper=N> n_pos;	// how many y are > 0?
	n_pos = 0;
	for(n in 1:N){
		if (y[n] > 0){
			y_logi[n] = 1;
			n_pos = n;
		} else {
			y_logi[n] = 0;
		}
	}
	if(sum(y_logi[(n_pos+1):N]) != 0 || sum(y_logi[1:n_pos]) != n_pos){
		reject("all observations with y==0 must appear at the end of the dataset")
	}
}

parameters{
	// for logit
	vector[R] loc_detect;
	vector<lower=0>[R] scale_detect;

	// Expected value for each image
	vector[I] mu_img;

	// Mean and variance may vary for each rater
	simplex[R] b_rater_raw;
	real<lower=0> b_rater_scale;

	real<lower=0> sigma[R];
}

transformed parameters{
	vector[N] mu;
	vector[N] detect_odds;
	vector[R] b_rater;
	
	b_rater = b_rater_scale*(b_rater_raw - 1.0/R);
	mu = mu_img[image] + b_rater[rater];
	detect_odds = (mu - loc_detect[rater]) ./ scale_detect[rater];
}

model{
	// Priors
	mu_img ~ normal(-5, 6);
	b_rater_raw ~ normal(0,1);
	b_rater_scale ~ normal(3,3);
	sigma ~ normal(0, 3);
	loc_detect ~ normal(-8, 5);
	scale_detect ~ normal(0, 6);

	y_logi ~ bernoulli_logit(detect_odds);
	head(y, n_pos) ~ lognormal(head(mu, n_pos), sigma[head(rater, n_pos)]);
}

generated quantities {
	real<lower=0> sig_rater;
	real sig_intrarater;
	sig_rater = sd(b_rater);
	sig_intrarater = mean(sigma);
}
