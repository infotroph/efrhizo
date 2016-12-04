
RAW2010 = rawdata/ef2010.05.24.txt \
	rawdata/ef2010-07-22.txt \
	rawdata/ef2010-08-12.txt \
	rawdata/ef2010-10-07.txt

RAW2011 = rawdata/EF2011_Session4.TXT

RAW2012 = rawdata/EF2012_S1test.TXT \
	rawdata/EF2012_S2.TXT \
	rawdata/EF2012_S3.TXT \
	rawdata/EF2012_S4.TXT \
	rawdata/EF2012_S5.TXT \
	rawdata/EF2012_S6.TXT \
	rawdata/EF2012_S6_found_in_SoC_notes.txt

RAW2013 = rawdata/EF2013-TAW-s5.TXT
	# rawdata/EF2013-S1.TXT also exists,
	# but do not add it until well checked
	# and added to censorframes2013.csv


RAW2014 = rawdata/EF2014_peak.txt \
	rawdata/EFDESTRUCTIVE.TXT
	# rawdata/EFTO_S1.TXT also exists,
	# but do not add it until well checked
	# and added to censorframes2014.csv

RAWCORES = rawdata/Tractor-Core-Biomass-2011.csv \
	rawdata/Tractor-Core-Biomass-2014.csv \
	rawdata/Tractor-Core-CN-2011.csv \
	rawdata/Tractor-Core-CN-2014.csv

ALL = data/frametots2010.txt \
	data/frametots2011.txt \
	data/frametots2012.txt \
	data/frametots2013.txt \
	data/frametots2014.txt \
	data/calibs2010.csv \
	data/calibs2011.csv \
	data/calibs2012.csv \
	data/calibs2013.csv \
	data/calibs2014.csv \
	data/stripped2010.csv \
	data/stripped2011.csv \
	data/stripped2012.csv \
	data/stripped2013.csv \
	data/stripped2014.csv \
	data/stripped2014-destructive.csv \
	data/offset2009.csv \
	data/offset2010.csv \
	data/offset2011.csv \
	data/offset2012.csv \
	data/offset2013.csv \
	data/offset2014.csv \
	data/tractorcore.csv \
	data/destructive-mass-nearvsfar.txt \
	data/stan \
	figures/logvol-cornpoints-2012.png \
	figures/logvol-cornpointsline-2012.png \
	figures/logvol-polyfit-2010.png \
	figures/logvol-polyfit-2011.png \
	figures/logvol-polyfit-2012.png \
	figures/logvol-polyfit-2013.png \
	figures/logvol-polyfit-2014.png \
	figures/destructive-mass.png \
	figures/destructive-massvsvol.png \
	figures/destructive-vol.png \
	figures/destructive-vol-fulldepth.png \
	figures/tractorcore-bars.png \
	figures/tractorcore-bars-mass.png \
	figures/tractorcore-exp.png \
	figures/stan-vs-cores.png \
	figures/stanfit-2010.png \
	figures/stanfit-2012.png \
	figures/stanfit-cropdiffs.png \
	figures/stanfit-croptots.png \
	figures/stanfit-fvu.png \
	figures/stanfit-obsvspred.png \
	figures/stanfit-params.png \
	figures/stanfit-peak.png \
	figures/stanfit-intercept-yeardiffs.png \
	figures/stanfit-croptots-peak.png \
	figures/stanfit-croptot-yeardiffs.png \
	data/stan/croptot_diff_years.csv \
	data/stan/intercept_diff_years.csv

all: $(ALL)
	#not written yet

data/frametots2010.txt: \
		$(RAW2010) \
		scripts/frametot-headers.txt \
		scripts/frametot-collect.sh
	cp scripts/frametot-headers.txt data/frametots2010.txt
	scripts/frametot-collect.sh $(RAW2010) >> data/frametots2010.txt 

data/frametots2011.txt: \
		$(RAW2011) \
		scripts/frametot-headers.txt \
		scripts/frametot-collect.sh
	cp scripts/frametot-headers.txt data/frametots2011.txt
	scripts/frametot-collect.sh $(RAW2011) >> data/frametots2011.txt 

data/frametots2012.txt: \
		$(RAW2012) \
		scripts/frametot-headers.txt \
		scripts/frametot-collect.sh
	cp scripts/frametot-headers.txt data/frametots2012.txt
	scripts/frametot-collect.sh $(RAW2012) >> data/frametots2012.txt 

data/frametots2013.txt: \
		$(RAW2013) \
		scripts/frametot-headers.txt \
		scripts/frametot-collect.sh
	cp scripts/frametot-headers.txt data/frametots2013.txt
	scripts/frametot-collect.sh $(RAW2013) >> data/frametots2013.txt 

data/frametots2014.txt: \
		$(RAW2014) \
		scripts/frametot-headers.txt \
		scripts/frametot-collect.sh
	cp scripts/frametot-headers.txt data/frametots2014.txt
	scripts/frametot-collect.sh $(RAW2014) >> data/frametots2014.txt 

data/calibs2010.csv: \
		scripts/slurpcals.sh \
		rawdata/calibs2010/*.CAL
	echo "file, h, v, unit" > data/calibs2010.csv
	scripts/slurpcals.sh rawdata/calibs2010/*.CAL >> data/calibs2010.csv

data/calibs2011.csv: \
		scripts/slurpcals.sh \
		rawdata/calibs2011/*.CAL
	echo "file, h, v, unit" > data/calibs2011.csv
	scripts/slurpcals.sh rawdata/calibs2011/*.CAL >> data/calibs2011.csv

data/calibs2012.csv: \
		scripts/slurpcals.sh \
		rawdata/calibs2012/*.CAL
	echo "file, h, v, unit" > data/calibs2012.csv
	scripts/slurpcals.sh rawdata/calibs2012/*.CAL >> data/calibs2012.csv

data/calibs2013.csv: \
		scripts/slurpcals.sh \
		rawdata/calibs2013/*.CAL
	echo "file, h, v, unit" > data/calibs2013.csv
	scripts/slurpcals.sh rawdata/calibs2013/*.CAL >> data/calibs2013.csv

data/calibs2014.csv: \
		scripts/slurpcals.sh \
		rawdata/calibs2014/*.CAL
	echo "file, h, v, unit" > data/calibs2014.csv
	scripts/slurpcals.sh rawdata/calibs2014/*.CAL >> data/calibs2014.csv

# offsets for years that have some measurements...
data/offset2010.csv: \
		scripts/estimate_offset.r \
		rawdata/tube_offsets/offsets-2010-meas-spring2011.csv \
		rawdata/tube_offsets/est-offset2010.csv
	Rscript $^ data/offset2010.csv
data/offset2011.csv: \
		scripts/estimate_offset.r \
		rawdata/tube_offsets/offsets-2011.csv \
		rawdata/tube_offsets/est-offset2011.csv
	Rscript $^ data/offset2011.csv
data/offset2014.csv: \
		scripts/estimate_offset.r \
		rawdata/tube_offsets/offsets-2014.csv \
		rawdata/tube_offsets/est-offset2014.csv
	Rscript $^ data/offset2014.csv

# ...and for years with no measurements that I can find.
data/offset2009.csv: \
		scripts/estimate_offset.r \
		rawdata/tube_offsets/est-offset2009.csv
	Rscript scripts/estimate_offset.r  NULL rawdata/tube_offsets/est-offset2009.csv data/offset2009.csv
data/offset2012.csv: \
		scripts/estimate_offset.r \
		rawdata/tube_offsets/est-offset2012.csv
	Rscript scripts/estimate_offset.r NULL rawdata/tube_offsets/est-offset2012.csv data/offset2012.csv
data/offset2013.csv: \
		scripts/estimate_offset.r \
		rawdata/tube_offsets/est-offset2013.csv
	Rscript scripts/estimate_offset.r NULL rawdata/tube_offsets/est-offset2013.csv data/offset2013.csv


data/stripped2010.csv: \
		scripts/cleanup.r \
		data/frametots2010.txt \
		rawdata/censorframes2010.csv \
		rawdata/censorimg2010.csv \
		data/offset2010.csv
	mkdir -p tmp && Rscript $^ data/stripped2010.csv >> tmp/2010-cleanup-log.txt

data/stripped2011.csv: \
		scripts/cleanup.r \
		data/frametots2011.txt \
		rawdata/censorframes2011.csv \
		\
		data/offset2011.csv
	mkdir -p tmp && Rscript scripts/cleanup.r \
		data/frametots2011.txt \
		rawdata/censorframes2011.csv \
		"NULL" \
		data/offset2011.csv \
		data/stripped2011.csv >> tmp/2011-cleanup-log.txt

data/stripped2012.csv: \
		scripts/cleanup.r \
		data/frametots2012.txt \
		rawdata/censorframes2012.csv \
		\
		data/offset2012.csv
	mkdir -p tmp && Rscript scripts/cleanup.r \
		data/frametots2012.txt \
		rawdata/censorframes2012.csv \
		"NULL" \
		data/offset2012.csv \
		data/stripped2012.csv >> tmp/2012-cleanup-log.txt

data/stripped2013.csv: \
		scripts/cleanup.r \
		data/frametots2013.txt \
		rawdata/censorframes2013.csv \
		\
		data/offset2013.csv
	mkdir -p tmp && Rscript scripts/cleanup.r \
		data/frametots2013.txt \
		rawdata/censorframes2013.csv \
		"NULL" \
		data/offset2013.csv \
		data/stripped2013.csv >> tmp/2013-cleanup-log.txt

data/stripped2014.csv: \
		scripts/cleanup.r \
		data/frametots2014.txt \
		rawdata/censorframes2014.csv \
		\
		data/offset2014.csv
	mkdir -p tmp && Rscript scripts/cleanup.r \
		data/frametots2014.txt \
		rawdata/censorframes2014.csv \
		"NULL" \
		data/offset2014.csv \
		data/stripped2014.csv >> tmp/2014-cleanup-log.txt

data/stripped2014-destructive.csv: \
		scripts/cleanup-destructive.r \
		data/frametots2014.txt \
		rawdata/censorframes2014.csv \
		\
		data/offset2014.csv
	mkdir -p tmp && Rscript scripts/cleanup-destructive.r \
		data/frametots2014.txt \
		rawdata/censorframes2014.csv \
		"NULL" \
		data/offset2014.csv \
		data/stripped2014-destructive.csv >> tmp/2014-destructive-cleanup-log.txt

data/tractorcore.csv: \
		$(RAWCORES) \
		scripts/tractorcore-cleanup.R
	Rscript scripts/tractorcore-cleanup.R


# Run Stan, extract fits, make some diagnostic plots.
# Beware: Starts every run by deleting everything in data/stan!
# TODO: Make this less monolithic so that it's possible to update incrementally.
data/stan: \
		stan/mctd_foursurf.sh \
		stan/mctd_foursurf.R \
		stan/mctd_foursurf.stan \
		stan/extractfits_mctd.R \
		scripts/stat-prep.R \
		scripts/rhizo_colClasses.csv \
		data/stripped2010.csv \
		data/stripped2011.csv \
		data/stripped2012.csv \
		data/stripped2013.csv \
		data/stripped2014.csv
	./stan/mctd_foursurf.sh "current" data/stan && touch data/stan

figures/logvol-cornpoints-2012.png: \
		data/stripped2012.csv \
		scripts/plot-ebireportspring2014.r
	Rscript scripts/plot-ebireportspring2014.r

figures/logvol-cornpointsline-2012.png: \
		data/stripped2012.csv \
		scripts/plot-ebireportspring2014.r
	Rscript scripts/plot-ebireportspring2014.r

figures/logvol-polyfit-2010.png: \
		data/stripped2010.csv \
		scripts/plot-ebireportspring2014.r
	Rscript scripts/plot-ebireportspring2014.r

figures/logvol-polyfit-2011.png: \
		data/stripped2011.csv \
		scripts/plot-ebireportspring2014.r
	Rscript scripts/plot-ebireportspring2014.r

figures/logvol-polyfit-2012.png: \
		data/stripped2012.csv \
		scripts/plot-ebireportspring2014.r
	Rscript scripts/plot-ebireportspring2014.r

figures/logvol-polyfit-2013.png: \
		data/stripped2013.csv \
		scripts/plot-2013.r
	Rscript scripts/plot-2013.r

figures/logvol-polyfit-2014.png: \
		data/stripped2014.csv \
		scripts/plot-2014.r
	Rscript scripts/plot-2014.r

figures/destructive-mass.png figures/destructive-massvsvol.png figures/destructive-vol.png figures/destructive-vol-fulldepth.png data/destructive-mass-nearvsfar.txt: \
		scripts/destructive-tissue.r \
		rawdata/destructive-harvest/rhizo-destructive-belowground.csv \
		data/stripped2014-destructive.csv
	Rscript scripts/destructive-tissue.r

figures/tractorcore-bars.png figures/tractorcore-bars-mass.png figures/tractorcore-exp.png: \
		scripts/plot-tractorcores.R \
		data/tractorcore.csv
	Rscript scripts/plot-tractorcores.R

figures/stan-vs-cores.png: \
		scripts/plot-stan-vs-core.R \
		data/stan/predmu_current.csv \
		data/tractorcore.csv
	Rscript scripts/plot-stan-vs-core.R \
	data/stan/obs_vs_pred_current.csv \
	data/tractorcore.csv \
	figures/stan-vs-cores.png

figures/stanfit-2010.png figures/stanfit-2012.png figures/stanfit-cropdiffs.png figures/stanfit-croptots.png figures/stanfit-fvu.png figures/stanfit-obsvspred.png figures/stanfit-params.png figures/stanfit-peak.png: \
		stan/plotfits_mctd.R \
		data/stan/cropbdepths_current.csv \
		data/stan/cropdiffs_current.csv \
		data/stan/cropintercepts_current.csv \
		data/stan/cropsigmas_current.csv \
		data/stan/croptotals_current.csv \
		data/stan/fit_current.csv \
		data/stan/obs_vs_pred_current.csv \
		data/stan/params_current.csv \
		data/stan/predmu_current.csv
	Rscript stan/plotfits_mctd.R data/stan/ figures/

figures/stanfit-intercept-yeardiffs.png figures/stanfit-croptots-peak.png figures/stanfit-croptot-yeardiffs.png data/stan/croptot_diff_years.csv data/stan/intercept_diff_years.csv: scripts/plot_chaindiffs.R data/stan/*.Rdata
	Rscript scripts/plot_chaindiffs.R

clean:
	rm $(ALL)
	# Is this actually what I want?

