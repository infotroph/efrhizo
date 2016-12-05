library("dplyr")
library("tidyr")
library("forcats")
library("cowplot")
library("DeLuciatoR")
# used without loading: rstan::extract -- conflicts with tidyr::extract.

set.seed(2679348)

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

# Peak-biomass observations were session 4 in years 2010-2012,
# sessions 5 & 2 in 2013 & 2014 but for these years we only fit the peak session anyway.
filter_peaks = function(df){
	filter(df, (session==4)| year %in% c("2013", "2014"))
}


croptot_chains = get_chains("crop_tot")
intercept_chains = get_chains("intercept")
slope_chains = get_chains("b_depth")
# sigma_chains = get_chains("sigma")

croptot_peak_plot = (ggplot(
	(croptot_chains
		%>% filter_peaks()
		%>% gather(crop, total, -year,-session)
		%>% mutate(annual = if_else(crop=="Maize-Soybean" & year %in% c("2010", "2013"), "Soybean", "Maize"))),
	aes(year, log(total), fill=annual))
	+ geom_violin()
	+ facet_wrap(~crop)
	+ theme_ggEHD(14)
	+ scale_fill_grey()
	+ theme(legend.title=element_blank(), legend.position=c(0.15, 0.9))
	+ ylab(expression(Total~0-130~cm~root~volume*","~ln~mm^3~mm^-1))
	+ xlab(NULL)
	+ scale_y_continuous(sec.axis=sec_axis(~., labels=NULL)))

slope_peak_plot = (ggplot(
	(slope_chains
		%>% filter_peaks()
		%>% gather(crop, b_depth, -year,-session)
		%>% mutate(annual = if_else(crop=="Maize-Soybean" & year %in% c("2010", "2013"), "Soybean", "Maize"))),
	aes(year, b_depth, fill=annual))
	+ geom_violin()
	+ facet_wrap(~crop)
	+ theme_ggEHD(16)
	+ scale_fill_grey()
	+ theme(legend.title=element_blank(), legend.position=c(0.2, 0.65 ))
	+ ylab(expression(beta^depth*","~ln~mm^3~mm^-2~ln~cm^-1))
	+ xlab(NULL)
	+ scale_y_continuous(sec.axis=sec_axis(~., labels=NULL)))

intercept_peak_plot = (ggplot(
	(intercept_chains
		%>% filter_peaks()
		%>% gather(crop, intercept, -year,-session)
		%>% mutate(annual = if_else(crop=="Maize-Soybean" & year %in% c("2010", "2013"), "Soybean", "Maize"))),
	aes(year, intercept, fill=annual))
	+ geom_violin()
	+ facet_wrap(~crop)
	+ theme_ggEHD(14)
	+ scale_fill_grey()
	+ theme(legend.title=element_blank(), legend.position=c(0.2, 0.65 ))
	+ ylab(expression(alpha*","~ln~mm^3~mm^-2))
	+ xlab(NULL)
	+ scale_y_continuous(sec.axis=sec_axis(~., labels=NULL)))


# Differences between midsummer 2010 and 2014 terms:
# The math is valid for all four crops, but not useful for maize-soybean
# because it compares 2010 soy against 2014 maize.
# Instead, let's compare 2010 soybean vs 2013 soybean, 
# and 2011 maize vs 2014 maize.
# N.B. assumes all comparisons contain the same number of samples!
intercept_endyear_diff = (
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
croptot_endyear_diff = (
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
slope_diff = (
	slope_chains
	%>% filter_peaks()
	%>% gather(crop, b_depth, -year, -session)
	%>% group_by(crop)
	%>% do(
		"2010, 2011" = filter(.,year=="2011")$b_depth - filter(.,year=="2010")$b_depth,
		"2010, 2012" = filter(.,year=="2012")$b_depth - filter(.,year=="2010")$b_depth,
		"2010, 2013" = filter(.,year=="2013")$b_depth - filter(.,year=="2010")$b_depth,
		"2010, 2014" = filter(.,year=="2014")$b_depth - filter(.,year=="2010")$b_depth,
		"2011, 2012" = filter(.,year=="2012")$b_depth - filter(.,year=="2011")$b_depth,
		"2011, 2013" = filter(.,year=="2013")$b_depth - filter(.,year=="2011")$b_depth,
		"2011, 2014" = filter(.,year=="2014")$b_depth - filter(.,year=="2011")$b_depth,
		"2012, 2013" = filter(.,year=="2013")$b_depth - filter(.,year=="2012")$b_depth,
		"2012, 2014" = filter(.,year=="2014")$b_depth - filter(.,year=="2012")$b_depth,
		"2013, 2014" = filter(.,year=="2014")$b_depth - filter(.,year=="2013")$b_depth)
	%>% unnest()
	%>% gather(years, diff_slope, -crop)
)

# Between-session differences for 2010 and 2012.
# Since a few sessions have differing numbers of samples, we compare a subset.
# (Should still be plenty for valid tests)
intercept_diff_2010 = (
	intercept_chains
	%>% filter(year=="2010")
	%>% gather(crop, icpt, -year, -session)
	%>% group_by(year, crop)
	%>% do(
		"5/27, 7/23"  = sample(filter(.,session=="3")$icpt, 10000) - sample(filter(.,session=="1")$icpt, 10000),
		"5/27, 8/16"  = sample(filter(.,session=="4")$icpt, 10000) - sample(filter(.,session=="1")$icpt, 10000),
		"5/27, 10/10" = sample(filter(.,session=="5")$icpt, 10000) - sample(filter(.,session=="1")$icpt, 10000),
		"7/23, 8/16"  = sample(filter(.,session=="4")$icpt, 10000) - sample(filter(.,session=="3")$icpt, 10000),
		"7/23, 10/10" = sample(filter(.,session=="5")$icpt, 10000) - sample(filter(.,session=="3")$icpt, 10000),
		"8/16, 10/10" = sample(filter(.,session=="5")$icpt, 10000) - sample(filter(.,session=="4")$icpt, 10000))
	%>% unnest()
	%>% gather(sessions, diff_icpt, -crop, -year)
)
slope_diff_2010 = (
	slope_chains
	%>% filter(year=="2010")
	%>% gather(crop, b_depth, -year, -session)
	%>% group_by(year, crop)
	%>% do(
		"5/27, 7/23"  = sample(filter(.,session=="3")$b_depth, 10000) - sample(filter(.,session=="1")$b_depth, 10000),
		"5/27, 8/16"  = sample(filter(.,session=="4")$b_depth, 10000) - sample(filter(.,session=="1")$b_depth, 10000),
		"5/27, 10/10" = sample(filter(.,session=="5")$b_depth, 10000) - sample(filter(.,session=="1")$b_depth, 10000),
		"7/23, 8/16"  = sample(filter(.,session=="4")$b_depth, 10000) - sample(filter(.,session=="3")$b_depth, 10000),
		"7/23, 10/10" = sample(filter(.,session=="5")$b_depth, 10000) - sample(filter(.,session=="3")$b_depth, 10000),
		"8/16, 10/10" = sample(filter(.,session=="5")$b_depth, 10000) - sample(filter(.,session=="4")$b_depth, 10000))
	%>% unnest()
	%>% gather(sessions, diff_slope, -crop, -year)
)


# Maize not present for s6 in 2012, making the comparisons unbalanced.
# Ugly and should probably be cleaned up a lot -- this was the first thing that worked.
intercept_diff_2012 = (
	intercept_chains
	%>% filter(year=="2012")
	%>% gather(crop, icpt, -year, -session)
	%>% filter(session != "6" | crop != "Maize-Soybean") 
	%>% group_by(year, crop)
	%>% do(
		"5/21, 6/06" = sample(filter(.,session=="2")$icpt, 10000) - sample(filter(.,session=="1")$icpt, 10000),
		"5/21, 6/20" = sample(filter(.,session=="3")$icpt, 10000) - sample(filter(.,session=="1")$icpt, 10000),
		"5/21, 8/5" = sample(filter(.,session=="4")$icpt, 10000) - sample(filter(.,session=="1")$icpt, 10000),
		"5/21, 8/30" = sample(filter(.,session=="5")$icpt, 10000) - sample(filter(.,session=="1")$icpt, 10000),
		"5/21, 10/24" = if(all(.$crop=="Maize-Soybean")){
				rep(NA, 10000)
			}else{
				sample(filter(.,session=="6")$icpt, 10000) - sample(filter(.,session=="1")$icpt, 10000)},
		"6/6, 6/20" = sample(filter(.,session=="3")$icpt, 10000) - sample(filter(.,session=="2")$icpt, 10000),
		"6/6, 8/5" = sample(filter(.,session=="4")$icpt, 10000) - sample(filter(.,session=="2")$icpt, 10000),
		"6/6, 8/30" = sample(filter(.,session=="5")$icpt, 10000) - sample(filter(.,session=="2")$icpt, 10000),
		"6/6, 10/24" = if(all(.$crop=="Maize-Soybean")){
				rep(NA, 10000)
			}else{
				sample(filter(.,session=="6")$icpt, 10000) - sample(filter(.,session=="2")$icpt, 10000)},
		"6/20, 8/5" = sample(filter(.,session=="4")$icpt, 10000) - sample(filter(.,session=="3")$icpt, 10000),
		"6/20, 8/30" = sample(filter(.,session=="5")$icpt, 10000) - sample(filter(.,session=="3")$icpt, 10000),
		"6/20, 10/24" = if(all(.$crop=="Maize-Soybean")){
				rep(NA, 10000)
			}else{
				sample(filter(.,session=="6")$icpt, 10000) - sample(filter(.,session=="3")$icpt, 10000)},
		"8/5, 8/30" = sample(filter(.,session=="5")$icpt, 10000) - sample(filter(.,session=="4")$icpt, 10000),
		"8/5, 10/24" = if(all(.$crop=="Maize-Soybean")){
				rep(NA, 10000)
			}else{
				sample(filter(.,session=="6")$icpt, 10000) - sample(filter(.,session=="4")$icpt, 10000)},
		"8/30, 10/24" = if(all(.$crop=="Maize-Soybean")){
				rep(NA, 10000)
			}else{
				sample(filter(.,session=="6")$icpt, 10000) - sample(filter(.,session=="5")$icpt, 10000)})
	%>% unnest()
	%>% gather(sessions, diff_icpt, -crop, -year)
	%>% remove_missing(vars="diff_icpt")
)
slope_diff_2012 = (
	slope_chains
	%>% filter(year=="2012")
	%>% gather(crop, b_depth, -year, -session)
	%>% filter(session != "6" | crop != "Maize-Soybean") 
	%>% group_by(year, crop)
	%>% do(
		"5/21, 6/06"  = sample(filter(.,session=="2")$b_depth, 10000) - sample(filter(.,session=="1")$b_depth, 10000),
		"5/21, 6/20"  = sample(filter(.,session=="3")$b_depth, 10000) - sample(filter(.,session=="1")$b_depth, 10000),
		"5/21, 8/5"   = sample(filter(.,session=="4")$b_depth, 10000) - sample(filter(.,session=="1")$b_depth, 10000),
		"5/21, 8/30"  = sample(filter(.,session=="5")$b_depth, 10000) - sample(filter(.,session=="1")$b_depth, 10000),
		"5/21, 10/24" = if(all(.$crop=="Maize-Soybean")){
				rep(NA, 10000)
			}else{
				sample(filter(.,session=="6")$b_depth, 10000) - sample(filter(.,session=="1")$b_depth, 10000)},
		"6/6, 6/20"  = sample(filter(.,session=="3")$b_depth, 10000) - sample(filter(.,session=="2")$b_depth, 10000),
		"6/6, 8/5"   = sample(filter(.,session=="4")$b_depth, 10000) - sample(filter(.,session=="2")$b_depth, 10000),
		"6/6, 8/30"  = sample(filter(.,session=="5")$b_depth, 10000) - sample(filter(.,session=="2")$b_depth, 10000),
		"6/6, 10/24" = if(all(.$crop=="Maize-Soybean")){
				rep(NA, 10000)
			}else{
				sample(filter(.,session=="6")$b_depth, 10000) - sample(filter(.,session=="2")$b_depth, 10000)},
		"6/20, 8/5"   = sample(filter(.,session=="4")$b_depth, 10000) - sample(filter(.,session=="3")$b_depth, 10000),
		"6/20, 8/30"  = sample(filter(.,session=="5")$b_depth, 10000) - sample(filter(.,session=="3")$b_depth, 10000),
		"6/20, 10/24" = if(all(.$crop=="Maize-Soybean")){
				rep(NA, 10000)
			}else{
				sample(filter(.,session=="6")$b_depth, 10000) - sample(filter(.,session=="3")$b_depth, 10000)},
		"8/5, 8/30" = sample(filter(.,session=="5")$b_depth, 10000) - sample(filter(.,session=="4")$b_depth, 10000),
		"8/5, 10/24" = if(all(.$crop=="Maize-Soybean")){
				rep(NA, 10000)
			}else{
				sample(filter(.,session=="6")$b_depth, 10000) - sample(filter(.,session=="4")$b_depth, 10000)},
		"8/30, 10/24" = if(all(.$crop=="Maize-Soybean")){
				rep(NA, 10000)
			}else{
				sample(filter(.,session=="6")$b_depth, 10000) - sample(filter(.,session=="5")$b_depth, 10000)})
	%>% unnest()
	%>% gather(sessions, diff_slope, -crop, -year)
	%>% remove_missing(vars="diff_slope")
)

intercept_diff_sessions = (
	bind_rows(intercept_diff_2010, intercept_diff_2012)
	%>% mutate(sessions=factor(sessions, levels=c(
		"5/27, 7/23",
		"5/27, 8/16",
		"5/27, 10/10",
		"7/23, 8/16",
		"7/23, 10/10",
		"8/16, 10/10",
		"5/21, 6/06",
		"5/21, 6/20",
		"5/21, 8/5",
		"5/21, 8/30", 
		"5/21, 10/24",
		"6/6, 6/20",
		"6/6, 8/5", 
		"6/6, 8/30",
		"6/6, 10/24", 
		"6/20, 8/5",
		"6/20, 8/30", 
		"6/20, 10/24",
		"8/5, 8/30",
		"8/5, 10/24", 
		"8/30, 10/24"))))
slope_diff_sessions = (
	bind_rows(slope_diff_2010, slope_diff_2012)
	%>% mutate(sessions=factor(sessions, levels=c(
		"5/27, 7/23",
		"5/27, 8/16",
		"5/27, 10/10",
		"7/23, 8/16",
		"7/23, 10/10",
		"8/16, 10/10",
		"5/21, 6/06",
		"5/21, 6/20",
		"5/21, 8/5",
		"5/21, 8/30", 
		"5/21, 10/24",
		"6/6, 6/20",
		"6/6, 8/5", 
		"6/6, 8/30",
		"6/6, 10/24", 
		"6/20, 8/5",
		"6/20, 8/30", 
		"6/20, 10/24",
		"8/5, 8/30",
		"8/5, 10/24", 
		"8/30, 10/24"))))


# save 95% CIs for hypothesis testing
(intercept_endyear_diff
	%>% filter(xor(years=="2010 vs 2014", crop=="Maize-Soybean"))
	%>% group_by(crop, years)
	%>% summarize(
		"2.5%"=signif(quantile(diff_icpt, 0.025), 3),
		"97.5"=signif(quantile(diff_icpt, 0.975), 3))
	%>% write.csv(
		file="data/stan/intercept_diff_years.csv",
		quote=FALSE,
		row.names=FALSE))
(croptot_endyear_diff
	%>% filter(xor(years=="2010 vs 2014", crop=="Maize-Soybean"))
	%>% group_by(crop, years)
	%>% summarize(
		"2.5%"=signif(quantile(diff_tot, 0.025), 3),
		"97.5%"=signif(quantile(diff_tot, 0.975), 3))
	%>% write.csv(
		file="data/stan/croptot_diff_years.csv",
		quote=FALSE,
		row.names=FALSE))
(slope_diff
	%>% group_by(crop, years)
	%>% summarize(
		"2.5%"=signif(quantile(diff_slope, 0.025), 3),
		"97.5%"=signif(quantile(diff_slope, 0.975), 3))
	%>% write.csv(
		file="data/stan/slope_diff_years.csv",
		quote=which(colnames(.)=="years"), # DO quote years column: has commas in it!
		row.names=FALSE))
(intercept_diff_sessions
	%>% group_by(year, crop, sessions)
	%>% summarize(
		"2.5%"=signif(quantile(diff_icpt, 0.025), 3),
		"97.5%"=signif(quantile(diff_icpt, 0.975), 3))
	%>% write.csv(
		file="data/stan/intercept_diff_sessions.csv",
		quote=which(colnames(.)=="sessions"),
		row.names=FALSE))
(slope_diff_sessions
	%>% group_by(year, crop, sessions)
	%>% summarize(
		"2.5%"=signif(quantile(diff_slope, 0.025), 3),
		"97.5%"=signif(quantile(diff_slope, 0.975), 3))
	%>% write.csv(
		file="data/stan/slope_diff_sessions.csv",
		quote=which(colnames(.)=="sessions"),
		row.names=FALSE))

croptot_diffplot = (
	ggplot(
		data=(croptot_endyear_diff
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
	+ theme_ggEHD(14)
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
	filename="figures/stanfit-croptot-endyears.png",
	plot=plot_grid(
		croptot_peak_plot,
		croptot_diffplot,
		labels="auto",
		ncol=1,
		rel_heights=c(1, 0.75)),
	maxheight=9,
	maxwidth=6.5,
	units="in",
	dpi=300)

intercept_endyear_diffplot = (
	ggplot(
		data=(intercept_endyear_diff
			%>% filter(xor(years == "2010 vs 2014", crop == "Maize-Soybean"))
			%>% mutate(
				crop=if_else(crop=="Maize-Soybean" & years=="2010 vs 2013", "Soybean", crop),
				crop=if_else(crop=="Maize-Soybean", "Maize", crop),
				crop=factor(crop, # to put maize and soy next to each other
					levels=c("Maize", "Soybean", "Miscanthus", "Prairie", "Switchgrass")))),
		aes(crop, diff_icpt, fill=years))
	+ geom_hline(aes(yintercept=0))
	+ geom_violin()
	+ xlab(NULL)
	+ ylab(expression(Delta~alpha*","~ln~mm^3~mm^-2))
	+ scale_fill_grey(start=0.3, end=1)
	+ scale_y_continuous(sec.axis=sec_axis(~., labels=NULL))
	+ theme_ggEHD(14)
	+ theme(
		legend.title=element_blank(),
		legend.position=c(0.2,0.85))
)
ggsave_fitmax(
	filename="figures/stanfit-intercept-endyears.png",
	plot=plot_grid(
		intercept_peak_plot,
		intercept_endyear_diffplot,
		ncol=1,
		labels="auto",
		rel_heights=c(1, 0.75)),
	maxheight=9,
	maxwidth=6.5,
	units="in",
	dpi=300)


slope_diffplot = (
	ggplot(
		data=slope_diff,
		aes(years, diff_slope), fill="grey")
	+ geom_hline(aes(yintercept=0))
	+ geom_violin(draw_quantiles=c(0.025, 0.975), fill="grey")
	+facet_wrap(~crop)
	+ xlab(NULL)
	+ ylab(expression(Delta~beta^depth*","~ln~mm^3~mm^-2~ln~cm^-1))
	+ scale_y_continuous(sec.axis=sec_axis(~., labels=NULL))
	+ theme_ggEHD(16)
	+ theme(
		axis.text.x=element_text(angle=45, hjust=1))
)
ggsave_fitmax(
	filename="figures/stanfit-slope.png",
	plot=plot_grid(
		slope_peak_plot,
		slope_diffplot,
		labels="auto",
		ncol=1),
	maxheight=12,
	maxwidth=6.5,
	units="in",
	dpi=300)

intercept_session_diffplot = (
	ggplot(
		data=intercept_diff_sessions,
		aes(sessions, diff_icpt), fill="grey")
	+ geom_hline(aes(yintercept=0))
	+ geom_violin(draw_quantiles=c(0.025, 0.975), fill="grey")
	+facet_grid(crop~year, scales="free_x")
	+ xlab(NULL)
	+ ylab(expression(Delta~alpha*","~ln~mm^3~mm^-2))
	+ scale_y_continuous(sec.axis=sec_axis(~., labels=NULL))
	+ theme_ggEHD(16)
	+ theme(
		strip.placement="outside",
		strip.switch.pad.grid=unit(0.5,"lines"),
		axis.text.x=element_text(angle=45, hjust=1))
)
slope_session_diffplot = (
	ggplot(
		data=slope_diff_sessions,
		aes(sessions, diff_slope), fill="grey")
	+ geom_hline(aes(yintercept=0))
	+ geom_violin(draw_quantiles=c(0.025, 0.975), fill="grey")
	+facet_grid(crop~year, scales="free_x")
	+ xlab(NULL)
	+ ylab(expression(Delta~beta^depth*","~ln~mm^3~mm^-2~ln~cm^-1))
	+ scale_y_continuous(sec.axis=sec_axis(~., labels=NULL))
	+ theme_ggEHD(16)
	+ theme(
		strip.placement="outside",
		strip.switch.pad.grid=unit(0.5,"lines"),
		axis.text.x=element_text(angle=45, hjust=1))
)
ggsave_fitmax(
	filename="figures/stanfit-seasondiffs.png",
	plot=plot_grid(intercept_session_diffplot, slope_session_diffplot, labels="auto"),
	maxheight=9,
	maxwidth=13,
	units="in",
	dpi=300)

