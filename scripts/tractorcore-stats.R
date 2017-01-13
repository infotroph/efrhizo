
sink(file="data/tractorcore_stats.txt")

library("lme4")
library("lsmeans")
library("dplyr")
lme = nlme::lme
corAR1 = nlme::corAR1
se = plotrix::std.error

sessionInfo()

coredata=read.csv("data/tractorcore.csv")

# use Kenward-Roger degrees of freedom for lsmeans,
# for compatibility with lsmeans <= 2.23
# (default changed to Satterthwaite in lsmeans 2.24)
lsm.options(lmer.df = "ken")

core_blocks = (coredata
	%>% mutate(Year=factor(Year))
	%>% group_by(Year, Treatment, Upper, Block)
	%>% summarize_each(
		funs(mean(., na.rm=TRUE), se(., na.rm=TRUE)),
		Biomass_g_cm3,
		Biomass_g_m2,
		Biomass_root_g_cm3,
		Biomass_root_g_m2,
		Midpoint)
	%>% rename(
		Crop=Treatment,
		Depth=Midpoint_mean,
		Depth_se=Midpoint_se))

core_block_tots = (core_blocks 
	%>% group_by(Year, Crop, Block) 
	%>% summarize_each(funs(sum)) 
	%>% select(Year, Crop, Block, ends_with("m2_mean")))

# Total root or root+rhizome mass per area
# Yes, I'm fitting the model twice: 
# Once in lme for convenient p-values,
# Again in lme4 so lsmeans can back-convert the log transformation for me.
# F values and estimated block effects ought to be ~identical.
m_tot_lme = lme(
	fixed = log(Biomass_g_m2_mean) ~ Year * Crop,
	random = ~ 1 | Block,
	data=core_block_tots)
m_tot_justroot_lme = lme(
	fixed = log(Biomass_root_g_m2_mean) ~ Year * Crop,
	random = ~ 1 | Block,
	data=core_block_tots)
m_tot = lmer(
	formula = log(Biomass_g_m2_mean) ~ Year * Crop + (1|Block),
	data=core_block_tots)
m_tot_justroot = lmer(
	formula = log(Biomass_root_g_m2_mean) ~ Year * Crop + (1|Block),
	data=core_block_tots)

lsm_tot = lsmeans(m_tot, revpairwise~Crop|Year)
lsm_tot_justroot = lsmeans(m_tot_justroot, revpairwise~Crop|Year)
lsm_tot_yr = lsmeans(m_tot, revpairwise~Year*Crop)
lsm_tot_justroot_yr = lsmeans(m_tot_justroot, revpairwise~Year*Crop)


# Root density with depth
# Need to account for autocorrelations, so only using nlme
m_depth = lme(
	fixed = log(Biomass_g_cm3_mean) ~ Year * Crop * log(Depth),
	random = ~ 1 | Block,
	correlation = corAR1(form=~log(Depth)|Block/Crop/Year),
	data = core_blocks)
m_depth_justroot = lme(
	fixed = log(Biomass_root_g_cm3_mean) ~ Year * Crop * log(Depth),
	random = ~ 1 | Block,
	correlation = corAR1(form=~log(Depth)|Block/Crop/Year),
	data = core_blocks)

lsm_depth = lsmeans(
	m_depth,
	revpairwise~Crop|Year*Depth,
	at=list(Depth=c(5, 20, 40, 75, 100, 115, 128)))
lsm_depth_justroot = lsmeans(
	m_depth_justroot,
	revpairwise~Crop|Year*Depth,
	at=list(Depth=c(5, 20, 40, 75, 100, 115, 128)))
lsm_slope = lstrends(
	m_depth,
	revpairwise~Crop|Year,
	var="log(Depth)")
lsm_slope_justroot = lstrends(
	m_depth_justroot,
	revpairwise~Crop|Year,
	var="log(Depth)")


cat("\n------------------------------------------------\n",
	"Total tractor core biomass (ln g root+rhizome m^-2):\n")
print(anova(m_tot_lme))
print(VarCorr(m_tot))
print(summary(lsm_tot, type="response"))
print(summary(lsm_tot_yr, type="response")$contrasts)

cat("\n------------------------------------------------\n",
	"Tractor core biomass of roots only (ln g root m^-2):\n")
print(anova(m_tot_justroot_lme))
print(VarCorr(m_tot_justroot))
print(summary(lsm_tot_justroot, type="response"))
print(summary(lsm_tot_justroot_yr, type="response")$contrasts)

cat("\n------------------------------------------------\n",
	"Tractor core biomass by depth (ln g root+rhizome cm^-3):\n")
print(anova(m_depth))
print(VarCorr(m_depth))
print(m_depth$modelStruct$corStruct)
print(
	summary(lsm_depth)$lsmeans 
	%>% as.data.frame 
	%>% mutate(exp(lsmean), exp(lower.CL), exp(upper.CL)))
print(
	summary(lsm_depth)$contrasts 
	%>% as.data.frame 
	%>% mutate(response.ratio=exp(estimate), p.value=round(p.value, 3)))
print(cld(lsm_depth, Letters=letters))
print(cld(lsm_slope, Letters=letters, details=TRUE))

cat("\n------------------------------------------------\n",
	"Tractor core root-only biomass by depth (ln g root cm^-3):\n")
print(anova(m_depth_justroot))
print(VarCorr(m_depth_justroot))
print(m_depth_justroot$modelStruct$corStruct)
print(
	summary(lsm_depth_justroot)$lsmeans 
	%>% as.data.frame 
	%>% mutate(exp(lsmean), exp(lower.CL), exp(upper.CL)))
print(
	summary(lsm_depth_justroot)$contrasts 
	%>% as.data.frame 
	%>% mutate(response.ratio=exp(estimate), p.value=round(p.value, 3)))
print(cld(lsm_depth_justroot, Letters=letters))
print(cld(lsm_slope_justroot, Letters=letters, details=TRUE))

sink()
