
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

ALL = data/frametots2010.txt\
	data/frametots2012.txt\
	data/calibs2010.csv\
	data/calibs2012.csv\
	data/stripped2010.csv\
	data/stripped2012.csv

all: $(ALL)
	#not written yet

data/frametots2010.txt: $(RAW2010)
	cp scripts/frametot-headers.txt data/frametots2010.txt
	scripts/frametot-collect.sh $(RAW2010) >> data/frametots2010.txt 

data/frametots2012.txt: $(RAW2012)
	cp scripts/frametot-headers.txt data/frametots2012.txt
	scripts/frametot-collect.sh $(RAW2012) >> data/frametots2012.txt 

data/calibs2010.csv:
	echo "file, h, v, unit" > data/calibs2010.csv
	scripts/slurpcals.sh rawdata/calibs2010/*.CAL >> data/calibs2010.csv

data/calibs2012.csv:
	echo "file, h, v, unit" > data/calibs2012.csv
	scripts/slurpcals.sh rawdata/calibs2012/*.CAL >> data/calibs2012.csv

data/stripped2010.csv: data/frametots2010.txt rawdata/censorframes2010.csv rawdata/censorimg2010.csv
	Rscript scripts/cleanup.r data/frametots2010.txt rawdata/censorframes2010.csv rawdata/censorimg2010.csv data/stripped2010.csv

data/stripped2012.csv: data/frametots2012.txt rawdata/censorframes2012.csv
	Rscript scripts/cleanup.r data/frametots2012.txt rawdata/censorframes2012.csv "NULL" data/stripped2012.csv

clean:
	rm $(ALL)
	# Is this actually what I want?

