library("dplyr")
library("tidyr")

## Constants
CORE_DIAM_CM = 1.50 * 2.54 #  Coring tube had 1.5" tip diameter
CORE_AREA_CM2 = pi * (CORE_DIAM_CM/2)^2
CORE_AREA_M2 = CORE_AREA_CM2 / 10000

## string->number mapping for fertilization levels
# In 2011, fertilization only varied by crop ==> map to Treatment
# In 2014, Miscanthus plots were split ==> varies by location, take from data
fert_11_bycrop = c( 
	"Maize"=180,
	"Miscanthus"=0,
	"Switchgrass"=56,
	"Prairie"=0)
fert_14_fromstring = c( 
		"None"=0, 
		"56 kg/ha"=56, 
		"180 kg/ha"=180)


## Read raw data
tc11 = read.csv(
	"rawdata/Tractor-Core-Biomass-2011.csv",
	colClasses=c(
		Block="integer",
		Treatment="factor",
		Sample="integer",
		Upper="integer",
		Lower="character", # will coerce to numeric after cleanup: 100+ is coded as "x"
		X...Dead="character", # will coerce to numeric after cleanup
		Root.Weight="character", # will coerce to numeric after cleanup
		Rhizome.Weight="numeric",
		Total.Length..3.Cores.="numeric",
		Notes="character"))
tc14 = read.csv(
	"rawdata/Tractor-Core-Biomass-2014.csv",
	colClasses=c(
		Block="integer",
		Treatment="factor",
		Sample="character",
		Upper="integer",
		Lower="character", # will coerce to numeric after cleanup: 100+ is coded as "+"
		Root.Mass="character", # will coerce to numeric after cleanup
		Rhizome.Mass="character",
		Total.Mass="numeric",
		X..Dead="character", # will coerce to numeric after cleanup
		Soil.Length="numeric",
		Notes="character",
		Plot.Fertilzer="character",
		Belowground.Biomass..g.m2.="numeric",
		Core.Area.3.Cores="NULL",
		Core.Area.2.Cores="NULL"))
tc11_cn = read.csv(
	"rawdata/Tractor-Core-CN-2011.csv",
	colClasses=c(
		Block="integer",
		Treatment="factor",
		Sample="character",
		Upper="integer",
		Lower="character", # will coerce to numeric after cleanup: 100+ is coded as "+"
		X..N="numeric",
		X..C="numeric",
		Notes="character"))
tc14_cn = read.csv(
	"rawdata/Tractor-Core-CN-2014.csv",
	colClasses=c(
		Block="integer",
		Treatment="factor",
		Direction="character",
		Sample..="character",
		Upper="integer",
		Lower="character", # will coerce to numeric after cleanup: 100+ is coded as "+"
		Root...N="character", # will coerce to numeric after removing inline notes
		Root...C="numeric",
		Rhizome...N="numeric",
		Rhizome...C="numeric",
		Fertilizer="character"))



## Normalize column names
# Could probably do this inside read.csv by setting col.names, but this works
names(tc11) = c(
	"Block", "Treatment", "Sample", "Upper", "Lower",
	"Pct_dead", "Mass_root", "Mass_rhizome",
	"Soil_length", "Notes")
names(tc14) = c(
	"Block", "Treatment", "Sample", "Upper", "Lower",
	"Mass_root", "Mass_rhizome", "Mass_total", "Pct_dead",
	"Soil_length", "Notes", "Fertilizer", "Biomass_g_m2")
names(tc11_cn) = c(
	"Block", "Treatment", "Sample", "Upper", "Lower",
	"Pct_N", "Pct_C", "Notes")
names(tc14_cn) = c(
	"Block", "Treatment", "Direction", "Sample", "Upper", "Lower",
	"Pct_N_root", "Pct_C_root", "Pct_N_rhizome", "Pct_C_rhizome",
	"Fertilizer")



## Normalize treatment names
# N.B. factor renaming-by-list syntax is weird: newname="oldname"
trts = list(
	Maize="Corn",
	Miscanthus="Miscanthus",
	Switchgrass="Switchgrass",
	Prairie="Prairie",
	Maize="C",
	Miscanthus="M",
	Switchgrass="S",
	Prairie="P")
levels(tc11$Treatment) = trts
levels(tc14$Treatment) = trts
levels(tc11_cn$Treatment) = trts
levels(tc14_cn$Treatment) = trts	



## Clean up file-specific formatting quirks

# 2011  biomass

tc11$Mass_root[tc11$Mass_root %in% c("", "Sample DNE")] = NA
tc11$Mass_root=as.numeric(tc11$Mass_root)

tc11$Mass_rhizome[tc11$Mass_root=="Sample DNE"] = NA

tc11$Num_cores = 3

tc11$Fert_kg_ha = fert_11_bycrop[tc11$Treatment]

# Treat mean achieved depth as bottom of 100+ layer
mean_depth_tc11 = (tc11
	%>% filter(Upper==100)
	%>% summarize(Lower=round(mean(100 + Soil_length/Num_cores, na.rm=TRUE)))
)$Lower
tc11$Lower[tc11$Upper == 100] = as.character(mean_depth_tc11)
tc11$Lower = as.numeric(tc11$Lower)

# If I were being complete here I'd convert Pct_dead to numeric,
# but I don't have an immediate use for it and it's very messy:
# > print(unique(tc11$Pct_dead[is.na(as.numeric(tc11$Pct_dead))]))
#   [1] ""      "<10"   "<5"    "30-40" "<15"   "<30"  
# Fix this if/when you need it.


# 2014 biomass

tc14$Mass_root[tc14$Mass_root == "<0.01"] = "0"
tc14$Mass_root = as.numeric(tc14$Mass_root)

# These missing values are in fact zero...
tc14$Mass_rhizome[tc14$Mass_rhizome == ""] = "0"
tc14$Mass_rhizome = as.numeric(tc14$Mass_rhizome)

# ...and these zeroes are in fact missing values!
nocore_rows = which(tc14$Notes == "No core below 1 meter")
nocore_cols = c("Mass_root", "Mass_rhizome", "Mass_total", "Pct_dead", "Soil_length", "Biomass_g_m2")
tc14[nocore_rows, nocore_cols] = NA

tc14$Pct_dead[tc14$Pct_dead == "<1"] = "0"
tc14$Pct_dead[tc14$Pct_dead == ""] = NA
tc14$Pct_dead = as.numeric(tc14$Pct_dead)

# Sampling locations are inconsistently named:
# Blocks 1-4 OK, always named as a direction
# Block 0 sampled 2x per side, second loc is aways "<direction> 2"
# 	but first loc is sometimes "<direction>" and sometimes "<direction> 1"
tc14$Sample[tc14$Block==0] = sub(
	pattern="([[:alpha:]]+)$",
	replacement="\\1 1", 
	x=tc14$Sample[tc14$Block==0])
tc14$Sample = factor(tc14$Sample)

tc14$Fert_kg_ha = fert_14_fromstring[tc14$Fertilizer]

tc14$Num_cores = ifelse(tc14$Notes == "Only 2 Cores Taken", 2, 3)

# Treat mean achieved depth as bottom of 100+ layer
mean_depth_tc14 = (tc14
	%>% filter(Upper==100)
	%>% summarize(Lower=round(mean(100 + Soil_length/Num_cores, na.rm=TRUE)))
)$Lower
tc14$Lower[tc14$Upper == 100] = as.character(mean_depth_tc14)
tc14$Lower = as.numeric(tc14$Lower)

# Sanity check for 2014 biomass:
# Total mass and Biomass_g_m2 come precalculated.
# If we can't reconstruct them from raw values, something's wrong.
# ...But they're precalculated with core diameter rounded to 38 mm, so be generous :)
with(tc14, stopifnot(
	all.equal(
		Mass_root + Mass_rhizome,
		Mass_total,
		tolerance=0.01),
	all.equal(
		Mass_total/(Num_cores * CORE_AREA_M2),
		Biomass_g_m2,
		tolerance=0.01)))


# 2011 CN

tc11_cn$Lower[tc11_cn$Upper==100] = as.character(mean_depth_tc11)
tc11_cn$Lower = as.numeric(tc11_cn$Lower)

tc11_cn$Pool = "Root"
tc11_cn$Pool[tc11_cn$Notes =="Rhizome"] = "Rhizome"
tc11_cn_root = subset(tc11_cn, Pool == "Root") %>% select(-Pool)
tc11_cn_rhizome = subset(tc11_cn, Pool == "Rhizome") %>% select(-Pool)
tc11_cn = merge(
	x=tc11_cn_root,
	y=tc11_cn_rhizome,
	by=c("Block", "Treatment", "Sample", "Upper", "Lower"),
	suffixes=c(x="_root", y="_rhizome"),
	all=TRUE)
rm(list=c("tc11_cn_root", "tc11_cn_rhizome"))


# 2014 CN

tc14_cn$Lower[tc14_cn$Upper==100] = as.character(mean_depth_tc14)
tc14_cn$Lower = as.numeric(tc14_cn$Lower)

noterows_cn14 = tc14_cn$Pct_N_root %in% c(
	"Not enough ground material for CN analysis",
	"No core below 1 meter")
tc14_cn$Pct_N_root[noterows_cn14] = NA
tc14_cn$Pct_N_root = as.numeric(tc14_cn$Pct_N_root)

tc14_cn$Fert_kg_ha = fert_14_fromstring[tc14_cn$Fertilizer]
tc14_cn$Sample = factor(trimws(paste(tc14_cn$Direction, tc14_cn$Sample)))



## Combine biomass and CN
tc11 = merge(
	tc11, 
	tc11_cn,
	by=c("Block", "Treatment", "Sample", "Upper", "Lower")) # but not by Note!
tc11 = (tc11 
	%>% rename(
		Biomass_notes = Notes,
		CN_notes_root = Notes_root,
		CN_notes_rhizome = Notes_rhizome))

tc14 = merge(
	tc14 %>% select(-Fertilizer, -Mass_total, -Biomass_g_m2), 
	tc14_cn %>% select(-Fertilizer, -Direction),
	by=c("Block", "Treatment", "Sample", "Upper", "Lower", "Fert_kg_ha"),
	all=TRUE)
tc14 = (tc14 
	%>% rename(Biomass_notes = Notes)
	%>% mutate(
		CN_notes_rhizome=NA,
		CN_notes_root=NA))



## OK, now let's put 2011 and 2014 together

stopifnot(setequal(names(tc11), names(tc14)))
coredata = rbind(
	tc11 %>% mutate(Year=2011),
	tc14 %>% mutate(Year=2014))
# Sort, move sort columns to beginning of row
coredata = (coredata
	%>% arrange(Year, Treatment, Block, Sample, Upper, Lower)
	%>% select(Year, Treatment, Block, Sample, Upper, Lower, everything()))


## Compute biomass and C by volume & area

# Don't propagate NAs from missing CN data if there was no biomass to measure
pct_or_zero = function(mass, percent){
	stopifnot(length(mass) == length(percent))
	res = mass * percent/100
	res[mass==0 & is.na(percent)] = 0
	res
}

# Things to note about this chain of conversions:
#
# * Soil_length is TOTAL length, in this horizon, of all 2 or 3 cores 
#	pooled in this sample, e.g. 10 cm * 3 cores = 30 cm in 0-10 layer.
# 	Thus no need to include Num_cores in biomass calculation -- 
# 	Soil_length accounts for it already.
#
# * Midpoint is the best point estimate of the actual depth of this sample:
#	Top 3 layer midpoints should all be very close to 5, 20, 50, 
#	50-100 should mostly = 75 with some shorter. 100+ will be more variable.
# 
# * Layer_fraction is the ratio between the depth we achieved and the depth we
#	were aiming for. Should be 1 everywhere the midpoint is one of
#	(5, 20, 50, 75, 113), and never >1 except in the 100+ layer.
#
# * Biomass_g_m2 is inferred mass per m^2 in the "whole layer", inferred using
#	Layer_fraction as a multiplier to correct for the fact that some cores 
#	didn't reach the full depth. This correction assumes mass-per-volume is
#	constant within a layer, which isn't true but is close enough in the deep
#	layers where the correction applies.
#
# * NAs from missing CN data propagate through anything with nonzero biomass.
#	For best estimates in layers with many missing readings, probably better to
#	recalculate total C/N from block averages -- by layer for roots, all layers
#	together (really just 0-10 and 10-30) for rhizomes
#
coredata = mutate(coredata, 
	Midpoint = Upper + 0.5*Soil_length/Num_cores,
	Layer_fraction =  (Soil_length/Num_cores) / (Lower-Upper),
	Mass_total = Mass_root + Mass_rhizome,
	Biomass_g_cm3 = Mass_total / (CORE_AREA_CM2 * Soil_length),
	Biomass_g_m2 = Mass_total / (CORE_AREA_M2 * Num_cores) / Layer_fraction,
	Biomass_root_g_cm3 = Mass_root / (CORE_AREA_CM2 * Soil_length),
	Biomass_root_g_m2 = Mass_root / (CORE_AREA_M2 * Num_cores) / Layer_fraction,
	Mass_root_C = pct_or_zero(Mass_root, Pct_C_root),
	Mass_root_N = pct_or_zero(Mass_root, Pct_N_root),
	Mass_rhizome_C = pct_or_zero(Mass_rhizome, Pct_C_rhizome),
	Mass_rhizome_N = pct_or_zero(Mass_rhizome, Pct_N_rhizome),
	Mass_total_C = Mass_root_C + Mass_rhizome_C,
	Mass_total_N = Mass_root_N + Mass_rhizome_N,
	C_g_cm3 = Mass_total_C / (CORE_AREA_CM2 * Soil_length),
	N_g_cm3 = Mass_total_N / (CORE_AREA_CM2 * Soil_length), 
	C_g_m2 = Mass_total_C / (CORE_AREA_M2 * Num_cores) / Layer_fraction,
	N_g_m2 = Mass_total_N / (CORE_AREA_M2 * Num_cores) / Layer_fraction)


write.csv(coredata, file="data/tractorcore.csv", row.names=FALSE)
