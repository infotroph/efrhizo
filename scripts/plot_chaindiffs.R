library("dplyr")
library("tidyr")
library("DeLuciatoR")
# used without loading: rstan::extract -- conflicts with tidyr::extract.

# Extract the saved HMC draws of one parameter
# out of a saved stanfit object hidden inside an Rdata file.
# Assumes the stanfit object is named `rz_mtd`.
# By default, renames columns to match cropnames,
# which is only useful for parameters that have exactly one value per crop.
# For others, set crop_specific=FALSE and rename as appropriate after extracting.
get_par = function(rdata_file, param, crop_specific=TRUE){
    rzenv = new.env()
    load(rdata_file, envir=rzenv)
    rz_fit = get("rz_mtd", envir=rzenv)
    chains = rstan::extract(rz_fit, pars=param)[[1]]
    if(crop_specific){
    	cropkey = get("cropkey", envir=rzenv)
    	stopifnot(ncol(chains) == nrow(cropkey))
	    colnames(chains) = cropkey$name[match(seq_len(ncol(chains)), cropkey$num)]
    }
    as.data.frame(chains)
}

# Extract and assemble chains from one param for ALL fitted models
get_chains = function(param){
	(list.files("data/stan/", pattern="*.Rdata", full.names=TRUE)
	%>% data.frame(src=., stringsAsFactors=FALSE)
	%>% group_by(src)
	%>% do(fit=get_par(rdata_file=.$src, param=param))
	%>% unnest()
	%>% extract(src, c("year", "session"), regex="_(\\d{4})_s(\\d)"))
		# NB leaves year and session as character, which is what I want today.
		# If you need them as numeric, add convert=TRUE.
}

filter_peaks = function(df){
	# Peak-biomass observations were session 4 in years 2010-2012,
	# sessions 5 & 2 in 2013 & 2014 but for these year we only fit the peak session anyway.
	filter(df, (session==4)| year %in% c("2013", "2014"))
}


croptot_chains = get_chains("crop_tot")
intercept_chains = get_chains("intercept")
# slope_chains = get_chains("b_depth")
# sigma_chains = get_chains("sigma")

croptot_plot = (ggplot(
	(croptot_chains
		%>% filter_peaks()
		%>% gather(crop, total, -year,-session)
		%>% mutate(annual = if_else(crop=="Maize-Soybean" & year %in% c("2010", "2013"), "Soybean", "Maize"))),
	aes(year, log(total), fill=annual))
	+ geom_violin()
	+ facet_wrap(~crop)
	+ theme_ggEHD(16)
	+ scale_fill_grey()
	+ theme(legend.title=element_blank(), legend.position=c(0.15, 0.9))
	+ ylab(expression(Total~0-130~cm~root~volume*","~ln~mm^3~mm^-1)))
ggsave_fitmax(
	filename="figures/stanfit-croptots-peak.png",
	plot=croptot_plot,
	maxheight=9,
	maxwidth=6.5,
	units="in",
	dpi=300)

# Differences between midsummer 2010 and 2014 intercept terms:
# The math is valid for all four crops, but not useful for maize-soybean
# because it compares 2010 soy against 2014 maize.
# Instead, let's compare 2010 soybean vs 2013 soybean, 
# and 2011 maize vs 2014 maize.
# N.B. assumes all comparisons contain the same number of samples!
intercept_diff = (
	intercept_chains
	%>% filter_peaks()
	%>% gather(crop, icpt, -year, -session)
	%>% group_by(crop)
	%>% do(
		"2010 vs 2014" = filter(.,year=="2014")$icpt - filter(.,year=="2010")$icpt,
		"2010 vs 2013" = filter(.,year=="2013")$icpt - filter(.,year=="2010")$icpt,
		"2011 vs 2014" = filter(.,year=="2014")$icpt - filter(.,year=="2011")$icpt)
	%>% unnest()
	%>% gather(years, diff_icpt, -crop)
)
croptot_diff = (
	croptot_chains
	%>% filter_peaks()
	%>% gather(crop, total, -year, -session)
	%>% group_by(crop)
	%>% do(
		"2010 vs 2014" = filter(.,year=="2014")$total - filter(.,year=="2010")$total,
		"2010 vs 2013" = filter(.,year=="2013")$total - filter(.,year=="2010")$total,
		"2011 vs 2014" = filter(.,year=="2014")$total - filter(.,year=="2011")$total)
	%>% unnest()
	%>% gather(years, diff_tot, -crop)
)

# save 95% CIs for hypothesis testing
(intercept_diff
	%>% filter(xor(years=="2010 vs 2014", crop=="Maize-Soybean"))
	%>% group_by(crop, years)
	%>% summarize(
		"2.5%"=signif(quantile(diff_icpt, 0.025), 3),
		"97.5"=signif(quantile(diff_icpt, 0.975), 3))
	%>% write.csv(
		file="data/stan/intercept_diff_years.csv",
		quote=FALSE,
		row.names=FALSE))
(croptot_diff
	%>% filter(xor(years=="2010 vs 2014", crop=="Maize-Soybean"))
	%>% group_by(crop, years)
	%>% summarize(
		"2.5%"=signif(quantile(diff_tot, 0.025), 3),
		"97.5%"=signif(quantile(diff_tot, 0.975), 3))
	%>% write.csv(
		file="data/stan/croptot_diff_years.csv",
		quote=FALSE,
		row.names=FALSE))

croptot_diffplot = (
	ggplot(
		data=(croptot_diff
			%>% filter(xor(years == "2010 vs 2014", crop == "Maize-Soybean"))
			%>% mutate(
				crop=if_else(crop=="Maize-Soybean" & years=="2010 vs 2013", "Soybean", crop),
				crop=if_else(crop=="Maize-Soybean", "Maize", crop),
				crop=factor(crop, # to put maize and soy next to each other
					levels=c("Maize", "Soybean", "Miscanthus", "Prairie", "Switchgrass")))),
	aes(crop, diff_tot, fill=years))
	+ geom_hline(aes(yintercept=0))
	+ geom_violin()
	+ xlab("")
	+ ylab(expression(Delta~root~volume*","~mm^3~mm^-1))
	+ scale_fill_grey(start=0.3, end=1)
	+ theme_ggEHD()
	+ theme(
		legend.title=element_blank(),
		legend.position=c(0.2,0.8))
	+ scale_y_continuous(
		sec.axis=sec_axis(~., labels=NULL),
		limits=c(-5,55)) # cuts off switchgrass upper tail -- goes to 135
	+ geom_line(
		# manually constructed cut indicator on switchgrass upper tail
		# If not cut off by ylim, would extend to 135 and make it hard to see other violins
		data=data.frame(
			x=5+c(-0.1,-.05,0.05,0.1),
			y=54+c(0,1,0,1)),
		aes(x=x,y=y),
		inherit.aes=FALSE)
)
ggsave_fitmax(
	filename="figures/stanfit-croptot-yeardiffs.png",
	plot=croptot_diffplot,
	maxheight=9,
	maxwidth=6.5,
	units="in",
	dpi=300)

intercept_diffplot = (
	ggplot(
		data=(intercept_diff
			%>% filter(xor(years == "2010 vs 2014", crop == "Maize-Soybean"))
			%>% mutate(
				crop=if_else(crop=="Maize-Soybean" & years=="2010 vs 2013", "Soybean", crop),
				crop=if_else(crop=="Maize-Soybean", "Maize", crop),
				crop=factor(crop, # to put maize and soy next to each other
					levels=c("Maize", "Soybean", "Miscanthus", "Prairie", "Switchgrass")))),
		aes(crop, diff_icpt, fill=years))
	+ geom_hline(aes(yintercept=0))
	+ geom_violin()
	+ xlab("")
	+ ylab(expression(Delta~alpha*","~ln~mm^3~mm^-2))
	+ scale_fill_grey(start=0.3, end=1)
	+ scale_y_continuous(sec.axis=sec_axis(~., labels=NULL))
	+ theme_ggEHD()
	+ theme(
		legend.title=element_blank(),
		legend.position=c(0.2,0.8))
)
ggsave_fitmax(
	filename="figures/stanfit-intercept-yeardiffs.png",
	plot=intercept_diffplot,
	maxheight=9,
	maxwidth=6.5,
	units="in",
	dpi=300)
