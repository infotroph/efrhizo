
RAW2010 = rawdata/ef2010.05.24.txt \
	rawdata/ef2010-07-22.txt \
	rawdata/ef2010-08-12.txt \
	rawdata/ef2010-10-07.txt

RAW2012 = rawdata/EF2012_S1test.TXT \
	rawdata/EF2012_S2.TXT \
	rawdata/EF2012_S3.TXT \
	rawdata/EF2012_S4.TXT \
	rawdata/EF2012_S5.TXT \
	rawdata/EF2012_S6.TXT \
	rawdata/EF2012_S6_found_in_SoC_notes.txt

RAW2014 = rawdata/EF2014_peak.txt

ALL = data/frametots2010.txt \
	data/frametots2012.txt \
	data/frametots2014.txt \
	data/calibs2010.csv \
	data/calibs2012.csv \
	data/calibs2014.csv \
	data/stripped2010.csv \
	data/stripped2012.csv \
	data/stripped2014.csv \
	figures/logvol-cornpoints-2012.png \
	figures/logvol-cornpointsline-2012.png \
	figures/logvol-polyfit-2010.png \
	figures/logvol-polyfit-2012.png \
	figures/logvol-polyfit-2014.png

all: $(ALL)
	#not written yet

data/frametots2010.txt: \
		$(RAW2010) \
		scripts/frametot-headers.txt \
		scripts/frametot-collect.sh
	cp scripts/frametot-headers.txt data/frametots2010.txt
	scripts/frametot-collect.sh $(RAW2010) >> data/frametots2010.txt 

data/frametots2012.txt: \
		$(RAW2012) \
		scripts/frametot-headers.txt \
		scripts/frametot-collect.sh
	cp scripts/frametot-headers.txt data/frametots2012.txt
	scripts/frametot-collect.sh $(RAW2012) >> data/frametots2012.txt 

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

data/calibs2012.csv: \
		scripts/slurpcals.sh \
		rawdata/calibs2012/*.CAL
	echo "file, h, v, unit" > data/calibs2012.csv
	scripts/slurpcals.sh rawdata/calibs2012/*.CAL >> data/calibs2012.csv

data/calibs2014.csv: \
		scripts/slurpcals.sh \
		rawdata/calibs2014/*.CAL
	echo "file, h, v, unit" > data/calibs2014.csv
	scripts/slurpcals.sh rawdata/calibs2014/*.CAL >> data/calibs2014.csv

data/stripped2010.csv: \
		data/frametots2010.txt \
		rawdata/censorframes2010.csv \
		rawdata/censorimg2010.csv \
		scripts/cleanup.r
	Rscript scripts/cleanup.r \
		data/frametots2010.txt \
		rawdata/censorframes2010.csv \
		rawdata/censorimg2010.csv \
		data/stripped2010.csv >> tmp/2010-cleanup-log.txt

data/stripped2012.csv: \
		data/frametots2012.txt \
		rawdata/censorframes2012.csv \
		scripts/cleanup.r
	Rscript scripts/cleanup.r \
		data/frametots2012.txt \
		rawdata/censorframes2012.csv \
		"NULL" \
		data/stripped2012.csv >> tmp/2012-cleanup-log.txt

data/stripped2014.csv: \
		data/frametots2014.txt \
		rawdata/censorframes2014.csv \
		scripts/cleanup.r
	Rscript scripts/cleanup.r \
		data/frametots2014.txt \
		rawdata/censorframes2014.csv \
		"NULL" \
		data/stripped2014.csv >> tmp/2014-cleanup-log.txt


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

figures/logvol-polyfit-2012.png: \
		data/stripped2012.csv \
		scripts/plot-ebireportspring2014.r
	Rscript scripts/plot-ebireportspring2014.r

figures/logvol-polyfit-2014.png: \
		data/stripped2014.csv \
		scripts/plot-2014.r
	Rscript scripts/plot-2014.r

clean:
	rm $(ALL)
	# Is this actually what I want?

