
RAWOPER = rawdata/agreement*.txt

agreement-all.csv: $(RAWOPER) ../scripts/frametot-headers.txt ./oa_frametot_collect.sh
	cat  ../scripts/frametot-headers.txt \
		| tr '\t' ',' \
		| sed -e 's/^/Operator,/' \
		> agreement-all.csv
	./oa_frametot_collect.sh $(RAWOPER) >> agreement-all.csv
