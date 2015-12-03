#set.seed(234587)
library(rstan)

runname=commandArgs(trailingOnly=TRUE)[[1]]

n_subsample = 1000 # how many rows to pick from the full dataset?

rstan_options(auto_write = TRUE)
options(mc.cores=7)
n_chains = 7
n_iters = 3000
n_warm = 1000
stanpars=c("a_detect", "b_detect", "intercept", "b_depth", "sig_tube", "sigma", "mu_mean")

source("../scripts/stat-prep.R") # creates data frame "strpall"
strpall = strpall[strpall$Depth > 0,]

rows_used = sample(1:nrow(strpall), n_subsample)
rzdat = strpall[rows_used,]
rm(strpall)
print(paste("Subsampling these", n_subsample, "rows from strpall:"))
print(dput(rows_used))

# Stan expects tube numbers to be in 1:T. If subsetting, must remap.
tube_map = data.frame(Tube=sort(unique(rzdat$Tube)))
tube_map$Tube_alias = seq_along(tube_map$Tube)
rzdat=merge(rzdat, tube_map)
print(dput(tube_map))

rzdat = rzdat[order(rzdat$rootvol.mm3.mm2),]


rz_mtd = stan(
	data=list(
		N=nrow(rzdat), 
		T=length(unique(rzdat$Tube_alias)),
		tube=rzdat$Tube_alias,
		depth=rzdat$Depth,
		y=rzdat$rootvol.mm3.mm2,
		y_logi=as.numeric(rzdat$rootvol.mm3.mm2 > 0),
		first_pos=which(rzdat$rootvol.mm3.mm2 > 0)[1],
		n_pos=length(which(rzdat$rootvol.mm3.mm2 > 0))), 
	file="mix_tube_depth.stan",
	iter=n_iters,
	warmup=n_warm,
	chains=n_chains,
	pars=stanpars,
	sample_file=paste0(runname, "_samples.txt"),
	diagnostic_file=paste0(runname, "_info.txt"),
	verbose=TRUE,
	open_progress=FALSE)

save(rz_mtd, file=paste0(runname, ".Rdata"))
warnings()
stopifnot(rz_mtd@mode == 0) # 1 or 2 = error

print(rz_mtd)
print(paste("mean of depth:", mean(rzdat$Depth)))

png(
	paste0(runname, "_%03d.png"),
	height=1200,
	width=1800,
	units="px")
print(plot(rz_mtd))
print(traceplot(rz_mtd))
print(traceplot(rz_mtd, inc_warmup=TRUE))
print(pairs(rz_mtd))
print(stan_hist(rz_mtd))
print(stan_dens(rz_mtd))
print(stan_ac(rz_mtd))
print(stan_diag(rz_mtd))
dev.off()

sessionInfo()
