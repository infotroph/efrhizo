
RAWOPER = rawdata/agreement*.txt

all: agreement-all.csv \
	agreement_log.txt \
	agreement_plots.pdf

.PHONY: all

agreement-all.csv: $(RAWOPER) ../scripts/frametot-headers.txt ./oa_frametot_collect.sh
	cat  ../scripts/frametot-headers.txt \
		| tr '\t' ',' \
		| sed -e 's/^/Operator,/' \
		> agreement-all.csv
	./oa_frametot_collect.sh $(RAWOPER) >> agreement-all.csv

agreement_log.txt agreement_plots.pdf: agreement-all.csv img_id.csv oa.stan operator_agreement.R
	Rscript operator_agreement.R 2>&1 | tee -a agreement_log.txt
