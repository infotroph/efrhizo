# Running log of edits to the Energy Farm minirhizotron repository

## Started 2015-02-25, long after the start of the repository.

# 2015-02-25:

Cleaning up uncommitted changes left from last time I worked in this directory, which was while preparing a poster for department Fall Welcome in September 2014. 

* scripts/plot-ebireportspring2014.r updated for a nicer color scheme in 2010 & 2012 polynomial fit plots. 2012 all-points-scattered plots change slightly because of different margins, but no change in color scale. Committed updated versions of all output plots. Did NOT commit a few additional lines of code that produced both polynomial plots side-by-side in one file. Pasting here for the record:
	require(gridExtra)
	png(
		filename="figures/logvol-polyfit-2010and2012.png",
		width=16,
		height=8,
		units="in",
		res=300)
	grid.arrange(p10,p12, ncol=2)
	dev.off()

* protocols/rhizotron-imaging-prot-20140602.tex is a revision of the imaging protocol written for 2014 when I supposed to be collecting weekly measurements of only the block 0 tubes. The only images collected were June (CKB) and August (CKB, TLP, TAW) and this protocol was never deployed, but committing for future reference.

* scripts/sitedups.py is a Python script for finding duplicate images, i.e. those that share the same tube, location, and session number. I whipped it up while checking 2013 images two weeks ago and did not commit it at the time; fixing that now.

* Added this file. No more excuses for wondering why I did that thing.
