/*
* Estimate root density with one common log(depth) slope,
* one common intercept at depth=50 plus random offset for each tube.
* Offsets are NOT constrained to sum to zero,
* but they do have a zero-centered prior.
*/

data {
	int N; // rows data
	int T; // num tubes
	int tube_id[N];
	vector[N] depth;
	real y[N];

	// pseudodata for predictive check
	int Np;
	int Tp;
	int tube_id_pred[Np];
	vector[Np] depth_pred;
}

parameters {
	real b_depth;
	real intercept;
	real<lower=0> tube_sigma;
	real<lower=0> sigma;
	vector[T] tube_offset;
}

transformed parameters {
	vector[N] mu;
	vector[3] mu_mon; // monitor a few mu without storing all
	vector[T] tube_intercept;

	tube_intercept <- intercept + tube_offset;

	for(n in 1:N){
		mu[n] <- tube_intercept[tube_id[n]] + b_depth * (log(depth[n])-log(50));
	}
	mu_mon[1] <- mu[1];
	mu_mon[2] <- mu[N/2];
	mu_mon[3] <- mu[N];
}

model {
	intercept ~ normal(10, 10);
	b_depth ~ normal(-20, 10);
	sigma ~ normal(0, 10);
	tube_sigma ~ normal(0, 10);

	tube_offset ~ normal(0, tube_sigma);

	for(n in 1:N){
		y[n] ~ normal(mu[n], sigma);
	}
}

generated quantities {
	real y_pred[Np];
	real mu_pred[Np];
	vector[Tp] tube_predintercept;
	vector[Tp] tube_predoffset;

	for(t in 1:Tp){
		tube_predoffset[t] <- normal_rng(0, tube_sigma);
		tube_predintercept[t] <- intercept + tube_predoffset[t];
	}
	for(n in 1:Np){
		mu_pred[n] <- tube_predintercept[tube_id_pred[n]] + b_depth * (log(depth_pred[n])-log(50));
		y_pred[n] <- normal_rng(mu_pred[n], sigma);
	}
}
