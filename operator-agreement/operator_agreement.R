library(dplyr)
library(rhizoFuncs)
library(rstan)
tidyMCMC = broom::tidyMCMC

set.seed(63493)
sessionInfo()

pdf("agreement_plots.pdf", width=8.5, height=11)

rstan_options(auto_write = TRUE)
options(mc.cores=7)

oa_raw = read.csv("agreement-all.csv")
img_ids = read.csv("img_id.csv")

# Drop duplicate records from mid-tracing reloads.
# Overall effect is to keep only the most recent record for each image/operator combination.
# Throws a bazillion warnings in the process, though.
oa_strip = (oa_raw
	%>% make.datetimes()
	%>% arrange(MeasDateTime)
	%>% group_by(Operator, Tube, Location)
	%>% do(strip.tracing.dups(.)))


oa = (merge(
		oa_strip,
		img_ids,
		by.x=c("Tube", "Location"),
		by.y=c("assigned_tube", "assigned_loc"))
	%>% mutate(src_imgnum = group_indices(., paste(src_tube, src_location, src_session))))

# Drop columns that don't vary
oa = oa[,sapply(oa, function(x)length(unique(x))>1)]

# To only analyze tracings from techs who worked on the final dataset,
# use something like this.
# But recall that *everyone* was tested at the end of initial training,
# so the techs who didn't trace for the final set have the same experience level
# as those who did ==> Using all 11 should give a better estimate to answer the underlying question
# "how much do we need to worry about tracer identity effects?"
# oa = (oa 
# 	%>% filter(Operator %in% c("CKB", "AP", "CRS", "EA", "JNR", "MPD", "TAW")) 
# 	%>% droplevels())


# sort for Stan model: zeroes at end
oa=oa[order(oa$TotVolume.mm3, decreasing=TRUE),]

oastan = stan(
	file="oa.stan",
	data=list(
		N=nrow(oa),
		I=length(unique(oa$src_imgnum)),
		R=length(unique(oa$Operator)),
		image=oa$src_imgnum,
		rater=as.numeric(oa$Operator),
		y=oa$TotVolume.mm3/(510*oa$PxSizeH*754*oa$PxSizeV)),
	open_progress=FALSE)



print(oastan, pars=c("sigma", "scale_detect", "loc_detect", "b_rater", "sig_rater", "sig_intrarater", "lp__"))
print(traceplot(oastan, pars=c("b_rater_scale", "sigma", "scale_detect", "loc_detect", "b_rater", "sig_rater", "sig_intrarater", "lp__")))
print(plot(oastan, pars=c("sigma", "scale_detect", "loc_detect", "b_rater", "sig_rater", "sig_intrarater")))
print(pairs(oastan, pars=c("sigma[1]", "scale_detect[1]", "loc_detect[1]", "b_rater[1]", "b_rater_scale")))

# image means vs predicted
oas_mi = (tidyMCMC(
		oastan,
		pars=c("mu_img"),
		conf.int=TRUE,
		conf.level=0.5)
	%>% tidyr::extract(
		col=term,
		into="src_imgnum",
		regex="\\[(\\d+)\\]$",
		convert=TRUE))
oa_img_obspred = (oa 
	%>% group_by(src_imgnum) 
	%>% summarize_at(vars(starts_with("Tot")), funs(mean, sd))
	%>% left_join(oas_mi))

#observed img means vs predicted, first on linear scale then on log scale
(ggplot(oa_img_obspred, 
	aes(TotVolume.mm3_mean, exp(estimate)))
	+ geom_point()
	+ geom_abline()
	+ geom_errorbar(aes(ymin=exp(conf.low), ymax=exp(conf.high)))
	+ geom_errorbarh(aes(xmin=TotVolume.mm3_mean-TotVolume.mm3_sd, xmax=TotVolume.mm3_mean+TotVolume.mm3_sd))
	+ ylab("estimated total volume"))
(ggplot(oa_img_obspred, aes(log(TotVolume.mm3_mean), estimate))
	+ geom_point()
	+ geom_abline()
	+ geom_errorbar(aes(ymin=conf.low, ymax=conf.high))
	+ geom_errorbarh(aes(xmin=log(TotVolume.mm3_mean-TotVolume.mm3_sd), xmax=log(TotVolume.mm3_mean+TotVolume.mm3_sd)))
	+ ylab("log(estimated total volume)"))

oas_pd = (tidyMCMC(
		oastan,
		pars=c("detect_odds"),
		conf.int=TRUE,
		conf.level=0.5)
	%>% tidyr::extract(
		col=term,
		into="rownum",
		regex="\\[(\\d+)\\]$",
		convert=TRUE))
oa_pd_obspred = (oa  
	%>% mutate(rownum=row_number())
	%>% left_join(oas_pd))
(ggplot(oa_pd_obspred, 
	aes(log(TotVolume.mm3), estimate))
	+ geom_point()
	+ geom_abline()
	+ geom_errorbar(aes(ymin=conf.low, ymax=conf.high))
	+ ylab("estimated detect_odds"))

dev.off()
