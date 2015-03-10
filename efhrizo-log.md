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

* Makefile was missing prerequisites -- cleaned data files for `frametotals*.txt` and `stripped*.txt`  failed to list their processing scripts in prerequisite lists. Fixed that, remade all outputs.

* Gah, cleanup.r produces a lot of error messages. Need to clean these up eventually, but meanwhile let's save them somewhere instead of flooding the console. Piped these outputs to a new `tmp/` directory, added it to `.gitignore`, documented it in `ReadMe.txt` as the place for temporary output you're not wuite done with.

...Why are so many of these "multiple calibrations" messages listing numbers that look identical? A typical example:
	`[1] "EF2012_T096_L100_2012.10.25_103258_006_MDM.jpg : multiple cals. PxSizeH:  0.022663, 0.022663, 0.022663, 0.022663 , PxSizeV:  0.022026, 0.022026, 0.022026, 0.022026"`
Those pixel sizes look identical to me and they should to `strip.tracing.dups()` as well. Investigating... And here's the place where I compare PxSizeV against PxSizeH[1] instead of PxSizeV[1]. Fixed that, rebuilt RhizoFuncs package, reran cleanup scripts, calibration messages dropped dramatically from 1041 to 327 lines in 2010 and from 6430 to 2338 lines in 2012. That's still a lot of errors, but much better!

A sidetrack: Spent a while documenting what I can see of the file format for WinRhizo patterns files. Not yet reverse-engineered well enough to reconstruct the trace images confidently outside of WinRhino, but it's a start. See `notes/patfile-notes.txt` for details.

Updating 2012 data files. Have brought over the most recent versions of at least S1, S5, S6 (possibly not the "found in notes" S6 file, though). Am too tired to trust my evaluation of the changes before committing -- in particular, make sure line endings and sort order aren't inflating the changeset. 

Manually added updated censoring for session 1; this too needs checking when I'm better rested. Menu for tomorrow before committing these changes:
	-- confirm that all raw data files are updated.
	-- check for line ending issues in raw data files.
	-- check S1 frame censoring records, add them for other sessions.
	-- copy in updated analysis logs.

2015-02-26:

censorframes2010.csv and censorframes2010.csv both had CR-only line endings (Grr, Excel). Changed these to LF and added a final newline for easier diffing later; will make other changes in a separate commit.

Rechecked 2012 raw data:
	
* S1,5,6 add previously missing tubes, need to commit updated versions.
* S2,3,4 remain identical. `EF2012_S6_found_in_SoC_notes.txt` is identical except header lines, which are missing in the imager version and I manually added them when I committed it, so no change needed.

Updating censorframes2012:

* T19 apparent typos lead to seeing some probable tracing errors. 
	* On 2015-06-08, T19 L45 and T19 L105 listed in censor table but none from T20, while trace log says to censor T19 L50,100 as blurry AND T20 L45 blur, L105 water. 
	* On inspecting images to resolve this, it looks to me as if T19 L45,50,100 are all clear enough to confidently call root-free, but T19 L45 has some traced roots; I bet they're from a mud track at bottom middle.
	* Inspecting T20 S2 images, L45 is indeed blurry and L105 is indeed obscured by water.
==> Removed censor entry for T19 L105 S2, kept entry for T19 L45 S2 but changed reason from "blur" to "mistraced", added a note to check more carefully in WinRhizo. 

* Added missing T20 L45,105 lines.

* Last line of `censorframes2012.csv` is:
	,,,,"""Multiple duplicates of images"""
I be this is referring to T21 S2, which is bad data that will take work to remove -- trace log says "Review tube: has multiple duplicates of images." Will need to make a `censorimg2012.csv` eventually to resolve this. Removed line from censorframes and will hope it doesn't screw up my numbers too badly until I finish removing it.

* Added censored frames from trace log for the following tube. Did not check images, just trusted log: 25, 28, 30, 32, 41, 42, 43, 48, 49, 52, 54, 55, 59, 63, 64, 66, 70, 71, 72, 74...

* Can't interpret 75 note: "L010115 obscurred".  Ignoring for the moment. Come back to this!

* ... more censored frames from 77, 82, 83, 84, 85, 86, 88, 96.

Out of time and ambition for today. Still need to add censor entries for sessions 3,4,5,6 and check all against what's visible in WinRhizo.

Compiled updated data,censoring info, and figures. Only slight changes -- early-season prairie moves up to match the rest of the season, most shallow depths increase very slightly (guess: Because we're censoring more tape-covered Locations 5). Committed all.

Now for a VERY quick and dirty look at 2014:

* Added data from peak sampling (`EF2014_peak.txt`).
* Made a token `censorframe2014.pdf`, essentially as a placeholder -- only censors T4 L5 for daylight.
* Copied calibration files to `calibs2014/`
* Quick half-assed copy of plotting script named `plot-2014.r`. Man, I really need to overhaul the plotting to make it work on all years.
* Trace log NOT imported yet!
* Added Make rules to build `data/frametots2014.txt`, `data/calibs2014.csv`, `data/stripped2014.csv`, `figures/logvol-polyfit-2014.png`. All rules have same structure as previous years, except plotting uses the new script I mentioned above instead of `plot-ebireportspring2014.r`.

Beginning the process of moving analysis logs from Excel binary format to CSV. Starting with `data/2012/analysis log 2012-s1.xls` in a process that will be painful to replicate:

* Opened in Excel on Mac, exported as CSV.
* Opened CSV in text editor. Changed line endings from CR to LF, saved.
* Changed date formatting to match ISO standard (this will make future updates easier):
	- date separator from  "." to "-" everywhere, e.g. 2013.10.15 -> 2013-10-15
	- fixed a few one-digit days, e.g. 2013-10-1 -> 2013-10-01
	- fixed some reversed months/days, e.g.  2013-14-11 -> 2013-11-14
	- changed "2013-23-13" to "2013-10-23" in B4 prairie. Had to look up the tracing dates in the data file to figure out what to correct it to; I guess he switched from YYYY-MM-DD to MM-DD-YY in the middle of typing?
	- changed image collection date of "2013-05-21" (impossible in 2012 data) to 2012-05-21.
* Deleted Excel file, committed changes.

* Now that the trace log is in a format we can actually see changes in, let's update it with the most recent version from the tracing computer! opened imager's version of `analysis-log-2012-s1.xls`, exported as CSV, opened in text editor, changed line endings from Cr to LF. Hooray, the only differences are the places CRS added his tracing remarks for previously untraced tubes!

2015-03-05:

Thinking more about how to get useful information out of pat files without manually loading them into Winrhizo. Theory: make a script to a Python script that will attempt to take *.pat and draw traced edges over *.jpg for human evaluation. First question will just be whether I understand the pat file format well enough to even extract pixel coordinates and segment diameters!

Started sketching this script out as `showpat.py`. Not very far along yet, but have beginnings of a Python class to represent patfiles (`Pat`; instance variables thus far are one filename, a few housekeeping variables, and a list of segments, methods `read_pat(path)` and `new_segment(list)` to populate a Pat from the given file). A separate class holds individual root segments (`Segment`; just a list of names for each set of numbers in the file, e.g. `seg.coords` is a list of the pixel coordinates for the segment, `seg.self.mystery_bool2` is less useful.) Have tested a few of the individual one-liners in Python REPL, but have not yet even tried to run the script. Image processing part is effectively not there; wasted a lot of time installing dependencies for scikit-image. This script not yet committed to the repository, but is saved in the scripts directory. Next steps for tomorrow: 

* Add minimal read-from-arguments capabilities, comment out all image handling for now.
* run script, confirm that patfiles are being read into Pat objects
* Consider more error handling: How else could things go wrong during read-in?
* Get image handling working, write out all pixel coordinates of each segment as a colorful dot on the image. Are they anywhere near the roots they're supposed to represent?
	1. No ==> Find ways to combine info from other lines to make them match up.
	2. Yes ==> Figure out which number corresponds to diameter.
* Color root areas, write out, evaluate by hand.
* Grab image data from root area, attempt discriminant analysis to find an RGB classifier that matches hand-tracing results.

Noticed a few places where the 2012 patfiles behave a bit differently from what I jotted down about the 2012 patfiles. In particular, each segment records is NOT always 46 lines long -- sometimes line 46 is 0 instead of 7 even when it's not the end of the file, and a variable number more lines of integers appear before the next segment starts. Updated patfile-notes.txt to reflect this.

Script expanded, first "working" version saved in a WIP branch. Where "working" means "writes 10-px green dots onto the one image I've tested, at what look like the right coordinates"; don't trust it much yet!

2015-03-09:

More work on showpat.py. A quick shell script to test on some 2012 images:

	#!/bin/bash

	# Just wrapping a loop over showpat.py
	# assumes images and patfiles are in same directory and have matching names

	IMGPATH="/Users/chrisb/rdp-tx/ef2012_t1-t53/"
	OUTPATH="/Users/chrisb/UI/efrhizo/tmp/"

	FILES=$(find $IMGPATH -name '*.pat' -print0 | xargs -0 basename -s .pat)

	for F in $FILES; do
		echo $F
		./scripts/showpat.py "$IMGPATH$F".jpg "$IMGPATH$F".pat "$OUTPATH$F".png
	done

This takes a very long time to run. Modified to run only the first few interesting ones (images 1-10 had no roots in them):

	# ...
	FILES=( $(find $IMGPATH -name '*.pat' -print0 | xargs -0 basename -s .pat) )
	# ...
	for F in ${FILES[@]:9:50}; do
	# ...

Still takes > 30 sec to process a few dozen images, but let's see what we have:

Many images have vertical lines at x=510; appears that I'm swapping coordinates somewhere so x coordinates get cut off by the filter that's supposed to affect y coordinates. Found it: I was passing drawpoints(x,y) but defining drawpoints(row, col). Rows should by y, not x! Points were inly drawn in the right location because I was swapping row/col again after applying my out-of-bounds filter. Fixed both.

Added filter for negative indices (circle extends off top/left) as well as out-of-bound positive (extends off bottom/right), and updated positive filter to use maximum index (num rows - 1) rather than pixel dimension. This appears to fix all out-of-bounds errors.

Looks like the first 8 integers of each segment (what I call `coords` in showpat.py) are the root midline at each end of the segment, repeated for unknown reasons. The next 8 decimal-that-always-takes-an-integer-value lines (`dec_coords` in showpat.py) look like they're the edges at each end of the segment. First stab at drawing an outline around the segment produces a diagonal line through it.

Looks like I was miscounting indexes when reading in the pat file --> coords only contain 7 elements -> draw_edge not called for second four coordinates. Now drawing Xs whose ends match up with corners of each segment.

