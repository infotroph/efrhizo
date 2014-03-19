
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

ALL = data/ef2010-allframetots.txt\
	data/ef2012-allframetots.txt\
	data/2010-allcals.csv\
	data/2012-allcals.csv

all: $(ALL)
	#not written yet

data/ef2010-allframetots.txt: $(RAW2010)
	cp frametot-headers.txt data/ef2010-allframetots.txt
	ls $(RAW2010) | xargs -n1 sed -e '1,4d' -e '/ROOT/d' >> data/ef2010-allframetots.txt 

data/ef2012-allframetots.txt: $(RAW2012)
	cp frametot-headers.txt data/ef2012-allframetots.txt
	ls $(RAW2012) | xargs -n1 sed -e '1,4d' -e '/ROOT/d' >> data/ef2012-allframetots.txt 

data/2010-allcals.csv:
	echo "file, h, v, unit" > data/2010-allcals.csv
	scripts/slurpcals.sh rawdata/calibs2010/*.CAL >> data/2010-allcals.csv

data/2012-allcals.csv:
	echo "file, h, v, unit" > data/2012-allcals.csv
	scripts/slurpcals.sh rawdata/calibs2012/*.CAL >> data/2012-allcals.csv

clean:
	# not written yet