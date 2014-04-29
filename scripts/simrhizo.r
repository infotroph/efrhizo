require(rhizoFuncs)
require(lme4)

gm3tomm3mm3 = function(x){
# convert grams root per m^3 into mm^3 root per mm^3
# (0.2 g/cm^3 is my wild-ass guess at root density...
# I think it came from one of Joseph Craine's papers?)
	return(x
		/ 1e9 # = g root / mm^3 soil
		/ 0.2 # = cm^3 root / mm^3 soil
		* 1000 # = mm^3 root/mm^3 soil
	)
}

logmean = function(expmean, expvar){
	# given observed mean and variance of an untransformed lognormally distributed variable,
	# compute the mean of its log-transformed normal distribution.
	# calculations cribbed from http://en.wikipedia.org/wiki/Log-normal_distribution
	log(expmean^2 / sqrt(expvar + expmean^2))
}
logvar = function(expmean, expvar){
	# given observed mean and variance of an untransformed lognormally distributed variable,
	# compute the variance of its log-transformed normal distribution.
	# calculations cribbed from http://en.wikipedia.org/wiki/Log-normal_distribution
	log(1 + expvar / expmean^2)
}

mkranefbeta = function(fac, sd){
	# Generate simulated betas for a random effect:
	# Given a vector of effect levels (need not actually be a factor)
	# and an assigned stdev for the random effect,
	# generates betas for each level such that mean(betas) == 0
	# and returns them as a vector of length(fac).
	# N.B. In a real experiment, there is of course no guarantee that your
	# random draw on these effects will actually have the same mean as
	# your population;
	# I force it here only to simplify model evaluation.
	# N.B. 2: Sample sd is not likely to be close to requested population sd.
	n=length(unique(fac))
	betas = rnorm(n=n, mean=0, sd=sd)
	# betas = (betas - mean(betas))/n
	betas = betas - mean(betas)
	return(betas[fac])
}

mklognorm = function(m, v){
	# Generate lognormally distributed random deviates,
	# with requested mean and variance of the _untransformed_ values.
	rlnorm(
		n=max(length(m), length(v)),
		meanlog=logmean(m, v),
		sdlog=sqrt(logvar(m, v)))
}

getfixmeans = function(mod){
	# Given an lmer model, compute fixed-effect group means
	# from beta estimates.
	# These _should_ equal tapply(data$y, data$fixed, mean)...
	fixm = unique(getME(mod, "X")) %*% fixef(mod)
	fixvars = attr(terms(formula(nobars(getCall(mod)))), "term.labels")
	fixlevs = model.frame(mod)[rownames(fixm), fixvars]
	if(is.list(fixlevs)){fixlevs=do.call(paste, fixlevs)}
	rownames(fixm) = fixlevs
	return(fixm)
}

# Basic design grid

fake.design = expand.grid(
	Location = seq(5,100,5),
	Tube = factor(1:96),
	Date = c("2014-01-01", "2014-01-02", "2014-01-03", "2014-01-04")
)
fake.design$Species = assign.species(fake.design$Tube)
fake.design$Block = assign.block(fake.design$Tube)
fake.design$Depth = loc.to.depth(fake.design$Location)
fake.design$Depth.c = c(scale(fake.design$Depth, center=TRUE, scale=FALSE))
fake.design$Depth.sc = c(scale(fake.design$Depth, center=TRUE, scale=TRUE))
fake.design$Date = as.Date(fake.design$Date)
fake.design$Date.c = c(scale(fake.design$Date, center=TRUE, scale=FALSE))
fake.design$Date.sc = c(scale(fake.design$Date, center=TRUE, scale=TRUE))





# Assign fixed-effects betas
speciesbetas = data.frame(
	Species=c("Cornsoy", "Miscanthus", "Switchgrass", "Prairie"),
	# spmean = (
	# 	gm3tomm3mm3(c(49, 323, 362, 206))), # Krista's 2012 deep-core masses in g/m^3
	# 		# NOTE: 49 g/m^3 is the value for maize, don't compare too seriously to soy!
	# spsd = gm3tomm3mm3(c(15,57,33,22)))z
	spmean = c(1.5e-6, 2e-6, -1e-6, -2e-6),
	# spsd = c(.5, .5, .5, .5))
	spsd = c(0,0,0,0))

depthlin = -0.001
depthquad = 0

datelin = 0 #0.1
datequad = 0 #0.2

# assigned random-effects thetas
blockvar = 0.01
tubevar = 0.1
residvar = 0.1




# no effects
simnull = fake.design
simnull$ybar = mean(speciesbetas$spmean)
simnull$yvar = mean(speciesbetas$spsd)^2 + residvar
simnull$rootvol = with(simnull, mklognorm(ybar, yvar))


# crop effect
simdatc = merge(fake.design, speciesbetas)
simdatc$ybar = simdatc$spmean
simdatc$yvar = simdatc$spsd^2 + residvar
simdatc$rootvol = mklognorm(simdatc$ybar, simdatc$yvar)

#crop and block effects
simdatcb = simdatc
simdatcb$bkmean = mkranefbeta(simdatcb$Block, sqrt(blockvar))
simdatcb$ybar = with(simdatcb, spmean + bkmean)
simdatcb$yvar = simdatcb$spsd^2 + residvar
simdatcb$rootvol = mklognorm(simdatcb$ybar, simdatcb$yvar)

#crop, block, tube
simdatcbt = simdatcb
simdatcbt$tubemean = mkranefbeta(simdatcbt$Tube, sqrt(tubevar))
simdatcbt$ybar = with(simdatcbt, spmean + bkmean + tubemean)
simdatcbt$yvar = simdatcbt$spsd^2 + residvar
simdatcbt$rootvol = mklognorm(simdatcbt$ybar, simdatcbt$yvar)


# crop, block, tube, depth
simdatcbtd = simdatcbt
simdatcbtd$ybar = with(simdatcbtd,
	spmean + bkmean + tubemean
	+ depthlin*Depth.c + depthquad*Depth.c^2)
simdatcbt$yvar = simdatcbt$spsd^2 + residvar
simdatcbt$rootvol = mklognorm(simdatcbt$ybar, simdatcbt$yvar)


#crop, block, tube, depth, date
simdatcbtdd = simdatcbtd
simdatcbtdd$ybar = with(simdatcbtdd,
	spmean + bkmean + tubemean
	+ depthlin*Depth.c + depthquad*Depth.c^2
	+ datelin*Date.sc + datequad*Date.sc^2
)
#with(simdatcbtdd, print(spmean + bkmean + tubemean
#		+ depthlin*Depth.sc + depthquad*Depth.sc^2
#		+ datelin*Date.sc + datequad*Date.sc^2))
simdatcbtdd$yvar = simdatcbtdd$spsd^2 + residvar
simdatcbtdd$rootvol = mklognorm(simdatcbtdd$ybar, simdatcbtdd$yvar)



# simnull.norm = fake.design
# simnull.norm = within(simnull.norm,{
# 	rootvol = rnorm(
# 		n=nrow(simnull.norm),
# 		mean=mean(speciesbetas$spmean),
# 		sd=mean(speciesbetas$spsd) + residvar)
# })

# simdatc.norm = merge(fake.design, speciesbetas)
# simdatc.norm = within(simdatc.norm, {
# 	rootvol = rnorm(
# 		n=nrow(simdatc.norm),
# 		mean=spmean,
# 		sd=spsd + residvar)
# })

# simdatcb.norm = simdatc.norm
# simdatcb.norm = within(simdatcb.norm, {
# 	bkmean = mkranefbeta(Block, sqrt(blockvar))
# 	rootvol = rnorm(
# 		n=nrow(simdatcb.norm),
# 		mean=spmean + bkmean,
# 		sd=spsd + residvar)
# })

# simdatcbt.norm = simdatcb.norm
# simdatcbt.norm = within(simdatcbt.norm, {
# 	tubemean = mkranefbeta(Tube, sqrt(tubevar))
# 	rootvol = rnorm(
# 		n=nrow(simdatcbt.norm),
# 		mean=spmean + bkmean + tubemean,
# 		sd=spsd + residvar)
# })

# simdatcbtd.norm = simdatcbt.norm
# simdatcbtd.norm = within(simdatcbtd.norm, {
# 	rootvol = rnorm(
# 		n=nrow(simdatcbtd.norm),
# 		mean=spmean + bkmean + tubemean + depthlin*Depth + depthquad*Depth^2,
# 		sd=spsd + residvar)
# })



# "simple" contrast matrix -- intercept is grand mean instead of reference cell mean
# not orthogonal!
sc = contr.treatment(4)-matrix(rep(1/4, 12), ncol=3)


# reverse-Helmert coding:
# 1. corn vs avg of all others ("perennial vs annual")
# 2. Mxg vs average of switch and prairie ("Miscanthus vs other annuals")
# 3. Switch vs. prairie (CAUTION: Be sure you know which is which when interpreting!)
hc = matrix(c(
	3/4, -1/4, -1/4, -1/4,
	0, 2/3, -1/3, -1/3,
	0, 0, 1/2, -1/2),
	ncol=3)



#cbtnull.norm = lmer(rootvol ~ Species + (1|Block/Tube), simnull.norm)
#cbt.norm = lmer(rootvol ~ Species + (1|Block/Tube), simdatcbt.norm)

fitcbt=function(df){
	lmer(rootvol ~ Species + (1|Block/Tube),
		data=df,
		contrasts=list(Species=hc))
}






