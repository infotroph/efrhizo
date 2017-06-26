# Running log of edits to the Energy Farm minirhizotron repository

## Started 2015-02-25, long after the start of the repository.

## 2015-02-25

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

## 2015-02-26

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

## 2015-03-05

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

## 2015-03-09

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

Added an alternate line that traces along edges instead of in X across them, but I think I actually like the X's -- good balance between seeing what the tracer did but still being able to pick out where the root edge is in the image. Leaving the edge-trace commented out, running with X's for now.

## 2015-03-15

Checking correctness of segment attributes in showpat.py -- suspect I may have some off-by-one errors hiding in the line indexes of the Segment init method. Added a Segment.ordered_values() method for debugging -- dumps segment attributes in the order they appear in the file. Appears to be working when I temporarily replace whole showpat loop with one "print_segs(pat)", but now bedtime before I've actually checked any indexes.

## 2015-03-16

Now for the index checking I was aiming for yesterday. Fixed a bunch of off-by-one errors in segment line indexes. All errors I *noticed* were underreads, i.e. making me miss the last item of a list, not read the wrong line into any attribute. Note to self: `list[n:n+1]` returns a list of 1 item, not 2. 

Also found one patfile where the "boolean" value on line 38 (always "1" in the files I'd checked before) is "3", so divided `mystery_bool4` (previously line 38 & 39) into `mystery_int2` (line 38) & `mystery_bool4` (line 39).

Possible insight into `remainder` lines (all beyond line 46 of the segment): They only appear after the last segment in a given root, number of lines in remainder seems to *roughly* scale with number of segments in root. Perhaps when `last` is 7 the next segment is also from this root, and when it's 0 this is the end of the root and `remainder` is some whole-root summary: topology analysis, maybe?

... but maybe not! EF2012_T001_L025_2012.08.30_100221_005_MDM.pat is a counterexample: Four segments named R1, then a remainder section, then two more segments also named R1, then another remainder section. Does this means it doesn't have to come at the end of a root (end of an axis, perhaps?), or that root names don't have to be unique?

Some notes from 2013-03-12 that I jotted down while asking Robert Paul to give me a code review, noting here for the record:

* Consider packaging main loop as a main function, then call it from within a `if __name__ == '__main__':` wrapper so file can be called as a module without running main.
* `draw_edge`: do I need to call `limit_range` if line is 1 px wide? start and end should be guaranteed within range, so everything between should be as well...
* `limit_range`:  BUGBUG: Can this bite me if I call it on e.g. a method that calculates areas?

Putting away patfiles for the moment to address tube offsets: Tubes are *theoretically* installed with 22 cm above ground so that Location 1 is at ground level. In *practice*, most are close to it, but some got stuck during installation and sit much higher, while only a very few are lower. Have a *very* few measurements of tube offsets (there may be more kicking around on paper somewhere?). Looking at histograms from `rawdata/tube-offsets-spring2011.csv`, all 4 crops mostly cluster near 24 cm but have one or two tubes >30 -- near-surface roots from these will be counted as MUCH deeper than they really are! Id I had been consistent about recording tube offsets every time we installed new tubes, we'd be set, but I didn't.

But we have another source: images from shallow-installed tubes have light showing in the aboveground frames. Precision is less good (+/- ~6 cm instead of ~1 cm), because we only save frame 1, 5, 10, 15...), and furthermore "frame 1" is inconsistent: Some operators take the image wherever the camera sits, others unlock the indexing pin and hunt for the best image of the tube number. Not sure how to deal with the precision and concistency issues yet, but for a start I will extract frames listed as "light" or "above ground" or the like from the `censorimage` tables, check them against raw images, and compile these into a spreadsheet of "deepest frame with light showing". 

## 2015-03-17

Set out to compile spreadsheet mentioned yesterday, realized I don't have all the correct raw images on my laptop. Assigned TAW to do it at the rhizotron tracing computer: open each tube in WinRhizo, then for the top few frames (until clearly underground) record the offset (as % of image height, counting from top, visually assesed to closest 10%) of: 
	
* Bottom of duct tape, 
* Bottom of light from outside tube
* Top of soil line
* sharpie line from measuring 22 cm, if visible

Also recording a yes/no on whether the tube number is visible in the image at all.

How I plan to use this: Assemble all tubes, check that differences through the season look more like camera placement/soil settling/tape peeling than like tube movement or mislabeled images, then take average. light that always appears before the first soil = tube aboveground, light below soil = cracked soil letting light penetrate belowground. When 22-cm mark is visible in same frame as soil line, compute offset directly. 

Question: worry about calibration when computing this offset? All images are 510 px high, so maximum change in image height is
	
	> cal10=read.csv("~/UI/efrhizo/data/calibs2010.csv")
	> cal12=read.csv("~/UI/efrhizo/data/calibs2012.csv")
	> cal14=read.csv("~/UI/efrhizo/data/calibs2014.csv")
	> cal10$year=2010
	> cal12$year=2012
	> cal14$year=2014
	> caln=rbind(cal10,cal12,cal14)
	> range(caln$v*510)
	[1] 11.13537 13.98734
	> mean(caln$v*510)
	[1] 12.22049

So the maximum change across a whole frame is about 3 mm, and most less-than-a-frame measurements will change far less than that. For estimating tube offset to the nearest cm, this is more than good enough. Will assume 12.2 mm/image and convert TAW's percentage-of-frame offsets to distances with `(percent/100)*12.2`. Then in the easy case where the 22 cm line is visible in the same frame as a clean bottom-of-light/top-of-soil front, the tube offset is 
	
	# test here that e.g. soil_top >= max(light_bottom, tape_bottom)
	offset_pct = soil_top - target_line
	offset_mm = offset_pct/100*12.2
	offset_cm = 22 + (offset_mm/10)

This doesn't yet account for the less-easy cases, which will probably be most of them... after all, if the soil line is visible in frame 1 beside the target depth line, we're within at most 1.2 cm of the target depth. Still considering how to handle, say, target depth line in frame 1 and light visible in frame 5.

## 2015-03-25

Checking 2011 tube offset records against paper datasheets. 

* Tube 56 (0s12) was measured as 23.5 cm, I recorded as 23 in electronic version. Changing that to round up to 24. 
* `rawdata/tube-offsets-spring2011.csv` is offsets of tubes that were in the ground all winter, i.e. it tells us the offsets for 2010 modulo frost heaving, NOT the offsets to use for 2011. Renamed to `offsets-2010-meas-spring2011.csv` to better reflect that, and moved it into a new `tube_offsets` directory while I'm at it.
* Changed `offsets-2010-meas-spring2011.csv` line endings from CR to LF. Grr, Excel.
* Tube offsets for 2011 are currently contained in the "after tube replacement" columns of `rawdata/rhizotube-offsets.xlsx`. Copied these into `rawdata/tube_offset/offsets-2011.csv`. These are just the offsets of tubes that were replaced -- still need to fil in offsets of tubes kept from 2010.
* This means `rawdata/rhizotube-offsets.xlsx` is no longer needed -- everything in it is better formatted in these the 2010 and 2011 offset files. Deleted.
* One piece of information that still exists only on paper: row alignment of corn tubes. Added a `rowposition` column. In 2011, this was systematic: odd numbered tubes were in the row, even-numbered tubes were between them.
* Created a new `rawdata/tube_replacements.csv` datasheet to track all tube replacements in one place: year replaced, offset before replacement, offset after replacement. My records on this are very poor, so will be incomplete, but will collect what I do know. Corn/soy replaced every year; won't include them here.
* OK, now added 2011 offsets for tubes not replaced in 2011. 2010 and 2011 offsets should now, to the extent I trust these measurements, be complete.
* Copied incomplete 2014 offsets from `rawdata/rhizo-destructive-tubenotes.csv`. These were all measured in fall 2014 and I should go measure the rest, like, tomorrow. Added a "date" column to track this, went back and added that to 2010 and 2011 files as well. Exact measurement dates not known for 2011-03 numbers, but calling it the 14th -- that's the day we started and that's close enough.

## 2015-03-28

The `loc.to.depth()` function in RhizoFuncs has an error in depth calculation: it is 22 cm from the top of the tube to the *center* of location 1, not to the top of it. That means `loc.to.depth(1, offset=22)` ought to equal zero, but it currently returns 2. I had been thinking of this as "depth at the bottom of the frame", but even that isn't right.

Changed `loc.to.depth()` by internally subtracting one from the location number; think of it as "how many frames have I moved from the beginning". 

_*NOTE that this will change all previously calculated depths when I rerun make!*_

## 2015-03-29

Recalculated depths in all existing datafiles using the new version of `loc.to.depth`. Since the Makefile doesn't list a dependency on the rhizoFuncs functions (TODO: Should it?), I remade everything from scratch with `make clean; make`.

Now recalculated them again using the image-based offset estimates from TAW (see 2015-03-17 above). When I don't have a current measurement of tube offset, we can estimate it by looking at the top few images and noting for each one how far down we see tape or light, and how far up we see the beginning of visible belowground soil. The basic procedure: 

* Convert location number and "percent from top of image" into distance down the tube (20.04 cm + 1.35*location + (percent/100 * 1.22)). Why these constants? because locations are 1.35 cm apart, images are about 12.2 mm tall (calibration doesn't change this much at all), and the camera is built such that it's 22 cm from the top of the tube to the center of location 1. See the comments in `estimate_offset.r` for a few more notes on this. 
* Within each tube on a given day, ignore all but the shallowest frame with a "top of soil" and all but the deepest with "bottom of tape" or "bottom of light".
* Take the maximum of these indicator distances as today's estimated offset for this tube. Many tubes will not have all three observations, but this is OK. If all three are missing, return an NA estimate. 
* (Note: Technically the soil gives us a point estimate ("we see where the tube enters the soil") and the other two give us lower bounds ("There is light/tape indicating the tube is aboveground to at least here, and we see that we are firmly underground by the top of the next image"), but I'm going to ignore that for now.)
* Take the mean of estimated offsets across the whole season. This is our offset estimated from image data for this tube this year.
* Merge these estimated offsets with the measured offsets if they are available, and write out a finished offset file containing columns "tube", "measured", "estimated", "offset" (taken from "measured except when measured is NA, then taken from "estimated"), and "source" (which column the value in "offset" came from).

Edited `Makefile` to to generate all years' offset files, whether with measred AND estimated offsets (2010, 2011, 2014) or just image estimates (2009, 2011, 2013). All generated with `scripts/estimate_offset.r`, passing "NULL" when the measurement file doesn't exist. Note that if I discover a cache of tube offset measurements for 2009, 2012, or 2013, I'll need to rewrite the make rules before it picks up on them.

Edited `cleanup.r` to take an offset file argument and calculate depth accordingly; updated all Make rules for stripped*.csv to use new arguments.

Also note that the offset estimates for 2011 are based on UNCORRECTED tube numbers -- any mislabeled images in the set are still mislabeled here! I suspect there are at least a few here, e.g. plotting out all estimated offsets for 2011 shows a couple that are very different on day 1 than they are the rest of the season. Since I took all the offset measurements at the beginning of the season, I doubt the differences are from tubes moving. REVISIT THIS after correcting 2011 tube images and update numbers as needed.

Added data from 2013: all extant 2013 calibrations, data files and analysis logs for S1 (currently in progress) and S5. Made a token start at a `censorframes2013.csv` by copying the first few clearly bad tubes of session 5; not really adequate effort yet, just enough to make the file exist.

Updated Makefile to process all these new 2013 data same as other years, forked plotting script yet again to make `plot-2013.r`. This one-script-per-plot thing is getting untenable; need to refactor this to be more flexible very soon.

Ran make, saved all updated data, went to bed.

OK, I lied, no bed yet. Added calibration and data files from session 1 2014, which was supposed to be the turnover experiment but only consisted of one round through B0. Took images every frame in these, but will for now use the standard cleanup script that throws out all except loc 5-10-15-etc. Updated Makefile, added previously missing analysis log for august (session 5), changed `plot-2014.r` to allow for two sessions.

...script crashes complaining it has three sessions not two. On inspection, there is a stray T43 from S6 2012, with all fields zero, appended to the end of the 2014-S1 datafile. Confirmed that the same images are listed in the 2012-S6 datafile, deleted them from the 2014 file. Scripts all reran without error.

...But all values in S1 are zero -- nobody has actually traced it, I just loaded it up for a quick count of how many frames contained roots. D'oh!

OK, actually going to sleep now. Leaving the empty 2014 datafile as a placeholder -- as soon as it's traced, drop it in for updated graphs.


## 2015-03-30

Found some errors in the descriptions, but not the actual calculation, of depth calculations in `notes/destructive-harvest-2014.txt`. Tubes are 30° from vertical not horizontal, and radians are degrees*2pi/360, not 2pi/260 as claimed in a few places. While I'm editing, added some line breaks and descriptions of the added/subtracted "wedges" for more clarity in the volume calculation section.

Working on analysis of the fall 2014 destructive harvest images. Might as well add it to the 2014 whole-season analysis as well -- it's only a few tubes, but why not.

* Modified `cleanup.r` as `cleanup-destructive.r` to keep all frames instead of censoring everything not in 5,10,15,..., Wound up only changing one line, rest of script is identical to my starting point.
* Imported analysis log as `rawdata/analysis-log-destructive-2014-09.csv`
* Added `scripts/destructive-tissue.r` for calculating volume-corrected root masses in harvest weights 
* Added 2014.9.16.CAL, 2014.9.17.CAL, 2014.9.19.CAL to `rawdata/calibs2014/`
* Added WinRhizo data file `EFDESTRUCTIVE.TXT` to `rawdata/` and to `RAW2014` list in Makefile.
* Added all censored frames from `analysis-log-destructive.csv` into `rawdata/censorframes2014.csv`.
* Note that there is a session numbering collision -- both EFTO (June) and EFDESTRUCTIVE (September) were saved as session 1. Cleanup script shouldn't care, so resetting session number in plotting script.
* OK, now cleanup-destructive.r is changing a bit more. I'll feed it the full frametots2014.csv, then remove all images whose name doesn't start with "EFDESTRUCTIVE". TODO: see if it's possible to refactor this so they both use the same script.

Not yet ready to add destructive cleanup script to Makefile. Ran it by hand:

	Rscript scripts/cleanup-destructive.r data/frametots2014.txt rawdata/censorframes2014.csv "NULL" data/offset2014.csv data/stripped2014-destructive.csv >> tmp/2014-destructive-cleanup-log.txt 

Results look strange... are there really THAT few shallow roots in the rhizotron images? Went back to tracing computer, rechecked all 6 tubes. Found many untraced roots -- looks like EA was *extremely* conservative about tracing roots that were at all unclear. Updated all 6 tubes myself, re-exported data. 

Added tissue comparison plotting to Makefile.

Comparing plots from old and new versions of data, my corrections make a substantial difference.  Went back and did a partial re-reinspection, found more changes, mostly adding roots but also removing some in the deeper switchgrass frames -- some clusters of roots were traced as one mega-root, waaaay inflating the volume estimate. Probably need to check the rest of these even more carefully than already done, but will leave that for later.

Updated 2013-S1 datafile with newest version from the imaging computer. DID NOT update trace log or check for new calibrations -- will do that when TAW finishes tracing the session.

Added a full-depth plot of the destructive harvest rhizotron images. Good illustration of how much extra noise I've settled for by only taking images every 5 locations.

...Why does the September prairie curve in `figures/logvol-polyfit-2014.png` not extend higher than ~10 cm depth? That should be the same set of numbers as the destructive harvest plots, which look fine and extend up to 0.
[a bunch of poking around happened here...]
...Because merge()returns a dataframe that is by default _sorted on the merged columns_, not in the same order as either input. I was doing 

	stripped$Offset = merge(stripped, offsets[,c("tube", "offset")], by.x=Tube, by.y="tube")$offset 

This meant I was adding a _sorted_ vector onto an _unsorted_ dataframe, with consequent wrong offsets all over the place. Why did I only see the effects in one dataset? Probably because the other sets were sorted already! Note that `stripped` is constructed from a call to `by(raw, raw$Img, ...)`, and that `by` sorts by indices as well. For years where the experiment name is the same in every image, the tube number is the first varying component of the image name, so this is eqivalent to a sort by tube then location then date. But in 2014, there was a June experiment named "EFTO", an August experiment named "EF2014", and a September experiment named "EFDESTRUCTIVE". Then sorting on image name would sort first by experiment name = month, _then_ by tube number.

The lesson: Don't just go pulling one vector out of a merge() result and assuming it will match one of the input dataframes.

Fixed by replacing the above line with 

	stripped = merge(stripped, offsets[,c("tube", "offset")], by.x="Tube", by.y="tube")
	names(stripped)[which(names(stripped)=="offset")] = "Offset" 

The second line is just to keep the column names consistently capitalized.

Reran make, prairie 2014 graph improved all all others stayed the same. Hooray!


Now comparing 2014 peak numbers against 2014 tractor core values.

* Exported Excel spreadsheet `Final Data, 2014 Tractor Core Belowground Biomass.xlsx` (from Mike Masters, 2014-12-02) as CSV. Did NOT commit XLSX version to Git, just the csv.
* Opened CSV in Sublime Text, removed extra header line before column names, replaced three instances of "N/A" with "NA".
* Read into R, will save session separately.


## 2014-03-31:

Presented current results to DeLucia lab this morning. Concensus from Evan and others is that existing data are sufficient and we don't need to collect any more images. 

Most interesting findings in current plots: Total root volume seems to be slowly increasing year-over year in all perennials, and perennials show very little seasonality in total root mass through 2012 season, but changes reappear in 2013..

Total root volume: This is cool... _assuming_ it's not just an operator effect; most students who have traced roots traced them in one year only! I have some cross comparison data I can use to check this, both in the opeator agreement training set and from a few tubes from earlier years that I had TAW retrace while he was waiting for me to clean up the 2013 images. 

Perennials show very little seasonality in total root mass through 2012 season, but changes reappear in 2013: Was 2012 a _pause_ in root expansion because of the drought, or was 2013 a _resumption_ of growth that had stopped a while before at "stand maturity" (possibly in delayed response to the drought)? To resolve this, trace several sessions from 2011 and all sessions from 2013.

Destructive harvest: replication is low, but not seeing any particular evidence for differences in root density near tubes. Likely conclusion is that underestimates of near-surface roots are a _detection_ issue, i.e. the roots are present in the soil near the tube, we're just failing to see them for some reason. Put another way, it looks like the tube itself doesn't create a hostile microenvironment. 

Comparing 2014 peak harvest tractor cores vs rhizotron images: surprisingly low correlation even at depth -- when plotting block means by depth horizon, 0-10 (!) is essentially the only horizon with a significant positive slope, and even that is driven by one or two points. None of us were really sure what to make of this, need to think on it more.

A possible angle for further investigation into near-surface underdetection: Is it an artifact of my every-five-locations sampling strategy? Take the few tubes where I did sample all locations (June & September 2014, a few in 2009, borrow images from a Leakey lab project if I need more replicates), simulate estimated root volumes when looking at all frames, every 2, every 5, (...10...etc). Check both systematic (1,5,10,15) and random ("give me 20 frames from this tube of 110") subsamples. N.B. Evan didn't seem very excited about this idea, says "focus on the biology." Point in his favor: Plenty of people see undersampling in shallow depths when they DO collect every frame.

## 2015-04-06

Found two typos in `Tractor-core-biomass-2014.csv`: one 30-50 lower depth "5" where it should be "50", one 100+ lower depth empty where others are "+".

While I'm at it: removed lines of empty fields from end of file, changed line endings to LF.

More typos: 

* lines 387-388: 0-10 cm and 10-30 cm layers appear to be transposed from their usual order (0-10 is below 10-30), except that the `Soil Length` column has 30 cm (typical for 0-10) above 60 cm (typical for 10-30). Swapped Soil Length, left the rest of the row as found. 
* line 287: 0-10 cm layer with `Soil Length` listed as 60. All other lines nearby look as expected; changed to 30.

## 2015-04-29

Did I seriously take no notes about fixing tractor core plots? Shame on me. Will try to reconstruct, but the basic insight is that for lab meeting I was NOT correctly converting tractor cores to per-cm^3 biomass -- what I showed was really (mass in this layer per unit surface area)/100, with no consideration for differing layer thicknesses. Have previously printed plot on my desk and som uncommitted changes in the script in static/, not sure if everything is there or not. I think all the calculations operated directly on columns from the tractor core file?

## 2015-04-30

Found the unsaved editor window where I developed the conversion, incorporated what I think are the important parts back into figures/static/tractorcore-vs-rhizo-2014-20150331.r. Not committing changes yet -- check diff and think more about whether to make them permanent.

## 2015-05-05

Added some very simple stats on whether destructive harvest soil had more roots near or far from the tube.

## 2015-05-06

Started methods section of manuscript in a fresh subrepository. Not sure yet if I want to keep it separate or replay commits into main repo.

## 2015-08-07

Added peak-season data from August 2011. Also have data from S1 (April), but only tubes 1-8 are traced; not adding these yet.

Tube 96 is weird: PxSizeH and PxSizeV are set to 0, which leads to strange volume-per-area calculations (some are NA, others Inf). Additionally, all roots are marked as alive, but TotVolume.mm3 does not match AliveVolume.mm3, e.g. loc 45 shows TotVolume.mm3 as 0.000 but AliveVolume.mm3 as 0.213! Assuming for the moment these are all rounding errors from the zero-sized pixels, will fix that before worrying about the volume mismatches. Added all locations from Tube 96 to censor list for now; making a note to go back and try re-exporting with Aug 4th calibration loaded correctly; hopefully this will resolve all the above weirdnesses.

## 2015-08-08

Updated EF2013-S1.TXT with newer version from tracing computer; contains traced data from 15 tubes not present in previous version.

## 2015-08-10

Calculation error in tractor core volumes: I was dividing total root mass by (number of cores * area per core * total core length), but total core length already contains the number of cores! Correct volume correction is (g root / cm^3) = (g root in sample)/(cm^2 per core * cm total core length).

Typo in unit-conversions.txt: corn root density of "0.8-1.4" should have been "0.08-1.4", but in the process of checking that I stopped eyeballing and did the math for real. New value: 0.06-1.4, with most values around 0.08-0.09. Highest densities are found in small-diameter roots very near apex (<2 mm from tip), decreases to 0.05-0.06 range (or 0.08 at 19C) beyond ~5-6 mm back.

Updated censor file for August 2014 readings. Will need to check a few against images later, as noted.

Updated censor file for August 2013 readings. Will need to check a few of these as well.

## 2015-11-16

In S4 2014 (2012-08-06), root length in T17 L85 was recorded as > 1500 mm -- on inspection of traced images, one node from the middle of a root seems to have somehow been moved outside the frame. Fixed that, updated tracing repo, saved updated data file in this repo, remade 2012 datasets.

## 2015-11-17

Several plotting scripts still use local-script versions of the DeLucia ggplot theme and of mirror.ticks. Edited these to use the R package versions (DeLuciatoR, ggplotTicks). (Noticed because updating 2014 dataset, for the edit I'll note next, triggered a replot of the destructive-tissue analysis. Saving this fix first so all updates from that change are recorded together.)

In peak 2014 (2014-08-15), T71 L60 had three large parallel roots that were traced as one gigantic one. Retraced, tweaked widths in a few nearby frames while I was at it, saved new values for whole tube, rebuilt project with updated 2014 numbers.

Fixed four outliers in 2012 data:

* S1 T3: L75 had a large "root" that looks to me like soil color variation. Removed it, but left some smaller roots.
* S5 T31: L40 & 45 had large "roots" that look to me like soil color variation. Deleted them, leaving both frames root-free. Adjusted tracing in L110 while I was at it -- traced area was larger than visible root.
* S6 T65: L105 had a large "root" that looks to me like soil color variation. Removed it, added a visible but untraced root in L110 while I was at it.

Candidate for deletion: Hand-compiled data file `data/2010/EF2010.05.24-corrected.csv`. Only differs from the script-compiled version in negative ways: It contains 74 frames that should be censored (most are loc 1), dates are stored in parser-unfriendly formats, and my root volume calculations are in per-cm instead of per-mm units. ==> This file has been fully replaced by the whole-season scripts. Deleted.

==> This means the hand-compiled means alongside it, `data/2010/efrhizo-cropmeans-20100524.csv` and `data/2010efrhizo-cropmeans-noblk-20100524.csv`, are also candidates for deletion: They probably use indiosyncratic units and include values from frames that ought to be censored, and recreating these from the current data would be trivial. Deleted the whole `data/2010/` directory.

## 2015-12-02

Working on modeling these data in a Bayesian framework using the Stan probabalistic programming language. Have been throwing thoughts into some scratch files that I will commit soon, but the basic idea is taken from Sonderegger et al. 2013, DOI:10.1111/nph.12128 -- The key idea is to model observed root volume as a mixture of zeros (assumed to be from detection failure, not actually zero roots) and lognormally distributed nonzeros, but with the change of detection increasing as root volume increases. The expectation `mu_i` in turn depends on depth, crop, season, random tube/block effects, and whatever else I add.

	y_i ~ mix of {
		lognormal(mu_i, sigma) [observed with probability p_i]
		0 [observed with probability 1-p_i] }
	p_i ~ logistic(alpha + beta * mu_i)
	mu_i ~ b_0 + b_tube_i + b_depth * log(depth_i) + b_crop_i [+ ...]
	b_tube ~ normal(0, sig_tube)

The model I have so far treats tube ID as a random effect and and assumes that root volume drops linearly with the log of depth, and appears to work on simulated one-crop data (more details on this TK below). I plan to try it on real data soon, then add a crop effect if the mixture, depth, and tube effects look like they're working right.

To implement the above model, we need priors on `alpha`, `beta`, `b_0`, `b_depth`, `sig_tube`, and `sigma`. Also, let's give those first three more descriptive names: `a_detect`, `b_detect`, `intercept`, respectively. OK, now let's review what we know and pick values:

* `a_detect`:
	* This is weirdly parameterized right now because I'm centering the logistic regression at mean(mu) (TODO: change this?). Interpret it as "log odds of detecting roots at whole-experiment mean root density".
	* I certainly hope our odds are better than even (otherwise we're missing most of the roots that exist!), but I don't have a principled way to constrain it, so let's allow a wide range. 
	* ==> Allow p(detect | mean(mu)) to vary at least from 1% to 99% 
	* ==> log(0.01/0.99) = -4.59, log(0.99/0.01) = 4.59
	* ==> Define prior as `a_detect ~ normal(0, 5)`.

* `b_detect`:
	* This is the change in log odds of detection for a unit change in mean root volume. Running again with the assumption that the lower detection limit is no less than log(6.28e-6) = -12 and that we'd dang well better hit 100% detection at the ceiling of log(1.28) ~= 0: 
	* p(detect|mu < -12) << 0.01 ==> log odds << -4.59
	* p(detect|mu=0) >> 0.99 ==> log odds >> 4.59
	* ==> Change in log odds is at least (4.59 - -4.59)/12 = 0.76.
	* But couldn't some zeroes may come from heterogeneity instead of detection failure?
		* OK, fine. Even if p(detect|mu=0) = 0.1, that's (log(0.1/0.9) - log(0.01/0.99))/12 ~= 0.20.
	* What if detection is a very sharp threshold function? If p(detect) goes from 0.01 to 0.99 in one log unit, that's (log(0.99/0.01) - log(0.01/0.99))/1 = 9.19. If half a unit, 18.38.
	* ==> Basically, I expect b_detect to be positive and probably < 10, but am not very confident beyond that.
	* ==> define prior as `b_detect ~ normal(5, 10)` for a start, and be sure to check whether the posterior is sensitive to my choice.

* `intercept`:
	* Max root volume observable is < 1 mm^3/mm2 (we can always see SOME soil in the image), or maaaaybe 1.28 (observe 1 mm x 1 mm, ignore cylindrical volume and assume 0.78 mm depth = (1*1)/0.78 = 1.28 mm^3).
	* Min: 1px x 1px root at typical magnification ~= 0.02 x 0.02 mm = (0.02 mm/2)^2 * pi * 0.02 mm = 6.28e-6 mm^3
	* ==> log(1.28), log(6.28e-6) ==> expect raw root volumes to round off to between -12 and 0 when working on log scale
	* ==> Define prior as `intercept ~ normal(-6, 6)`.

* `b_depth`:
	* plotting log(mass) ~ log(depth) of root core data gives a linear-looking relationship with a slope somewhere near -1 and certainly between -0.5 and -2.
	* This is slightly cheating: I'm estimating my prior from the same plots as the images I'm analyzing! But the *method* of obtaining the numbers is very different, so I think it's defensible. 
	* An intuitive argument for the same conclusion:
		We know root volume approaches zero but is still detectable at 140 cm, so if our intercept is 0.24 (=maximum root volume from intercept calculations) and our detection limit is -12 as above, then 0.24 + slope*log(140) > -12 ==> slope > (-12 + 0.24)/log(140) ==> slope > -2.38.
	* ==> I do want to allow slope term to be positive if the data support it, but don't expect absolute value to be more than single digits.
	* ==> Define prior as `b_depth ~ normal(-1,5)`, can probably get away with tightening to (-1,3) if desired.

* `sig_tube`
	* Range of a normal distribution is roughly four sigmas. Sticking with the same crude range estimate of "-12 up to 0", that implies an sd around 12/4 = 3.
	* There is a lot of variation between tubes, so let's keep the prior broad enough to include all the variance if necessary.
	* Variances have to be positive, but Stan can handle this automatically as long as I declare the parameter as `real<lower=0> sig_tube` and will truncate distributions as needed.
	* ...But on closer examination of the manual, I realize I'm not sure if this holds for *any* truncation (normal(1,3), say, where the peak is positive and then one tail is cut off), or just when it's zero-centered and the distribution can simply be folded in half.
	* ==> Define prior as `sig_tube ~ normal(0, 3)`, but try a wider distribution if posterior estimate is > 2.

* `sigma`
	* Same logic as for sig_tube. Let's keep both priors the same for now.
	* ==> Define prior as `sigma ~ normal(0,3)`.

## 2015-12-03

mixture model appears to be working with depth and tube effects. Synced repository to the IGB computing cluster and ran the following jobs:

* rz_mtd.1567789: Job crashed. Package 'dplyr' is not installed. Deleted output file.
	* Emailed admins to request installation of dplyr and lubridate, but then edited stat_prep.R to use base functions instead while I was waiting.
	* In the process, I added a colClasses definition to the read.csv steps -- now skips some columns I never use and requires less downstream format-tweaking in others.

* rz_mtd.1568006: Job crashed. I forgot to commit `scripts/rhizo_colClasses.csv`! Deleted output file.

* rz_mtd.1568007: 1000-row subsample of full rhizotron dataset, 7 chains run for 3000 iterations, 1000 as warmup.
	* Elapsed time: chains ranged from 17-26 seconds sampling,  2m16s wall time for whole script.
	* Used 1401732kb ~= 1.4 GB memory (I reserved 7 GB) and ~2.1 GB virtual memory (CHECK: Do I need to worry about this?).
	* Convergence: Close but not complete. Effective sample size lowest for `b_detect` (293), `sig_tube` (504), `lp__` (308) -- others are in the low hundreds.
	* `b_detect` and `sig_tube` both show a fair amount of autocorrelation, but may not be enough to need thinning.
	* Looks like I forgot a dollar sign in the qsub script, so the output files from this run are named `PBS_JOBNAME.1568007.biocluster.igb.illinois.edu*` instead of the intended `rz_mtd.1568007.biocluster.igb.illinois.edu*`. Fixed that. 
	* Added a second traceplot to the graphing output, with warmup samples included.
	* ==> This looks promising. Let's take a bigger bite!

* rz_mtd.1568016: 5000-row subset, 7 chains run for 10000 samples, still 1000 warmup.
	* sampling time 198 - 262 sec, wall time 5m34s.
	* Used about 1.1 GB memory, 1.8 GB VM.
	* Rhat=1 for all chains, traceplots look well converged. ESS is 9429 for `lp__`, over 10000 for all other parameters. 
	* Distributions are still a tad lumpy, especially `sigma`, which also has its posterior mode around 2.05. TODO: Try widening prior to check for sensitivity.
	* b_depth is estimated to be essentially zero. Will be interesting to see if that holds up in larger datasets.
	* I should make these filenames shorter. TODO: Truncate my email address off the job ID before passing it in to R, perhaps with something like MYJOBID=`echo $PBS_JOBID | sed 's/\..*//'`.

* rz_mtd.1568055: 10000-row subset (= around 40% of the ~23k rows in this version of the full dataset), 20k iterations. All other settings same as before, none of my TODOs from above done yet.
	*Another TODO: None the my outputs contain a full date-and-time stamp. Add that to the top or bottom of the script.
	* Wall time 21:21, sampling times 770-1081 seconds. Memory ~1.3 GB.~2 GB VM.
	* Traceplots and histograms look good, Rhat=1 for everything, lowest ESS is `lp__` at 32119.
	* Runtimes so far: 2.25/3000=0.00075, 5.5/5000=0.0011, 21.3/10000 = 0.00213. Looks like it's somewhere in O(n^2) territory.
	* ==> Expect whole dataset to take something like a couple of hours, maybe? Let's try it.

* rz_mtd.1568182: All rows, 20000 iterations.
	* Before running: Commented out all subsampling statements in mix_tube_depth.R, but kept the tube-map operation even though it should theoretically not be needed. Also edited qsub script from just 	

		```
		module load R/3.2.0
		time Rscript mix_tube_depth.R "$PBS_JOBNAME"."$PBS_JOBID"
		```

		to 

		```
		module load R/3.2.0
		SHORT_JOBID=`echo $PBS_JOBID | sed 's/\..*//'`
		echo "Starting $PBS_JOBNAME"."$SHORT_JOBID" on `date -u`
		time Rscript mix_tube_depth.R "$PBS_JOBNAME"."$SHORT_JOBID"
		```

	* Runtime: 49:46 walltime, sampling 2087-2638 sec. Memory ~1.3 GB, VM ~1.9 GB.
	* Traceplots all look great, Rhats all 1. intercept ESS is 9175, all others >> 30000.
	* ==> These estimates seem fairly good for this model, but let's check if sigma is sensitive to its prior.

* rz_mtd.1568239: Adjusted prior on sigma from normal(0, 3) to normal(0,10), all other conditions identical to job 1568182.
	* Runtime 58:28, sampling time 2964 - 3282 sec. Memory 1.6 GB, VM 2.3 GB.
	* Traces for all paramets are just a hair wider, but no visible shifts in location. Posterior mean table rounds a few scattered last-digits up by one, but no substantive change in posterior HPD invervals for any parameters.
	* ==> normal(0, 3) prior seems OK. Maybe do another round of sensitivity analysis once I've settled on the final model.

## 2015-12-06

Adding some predictions to the mixture model. I'm modeling visible root volume per unit image area, but the quantity I'm actually interested in is the mass of root C per unit field area. How to convert them?

To find total expected mass per m^2 ground, I'll need to integrate across the soil profile. I'm assuming that area->volume->mass->C conversions are all constant multipliers, so it should be OK to integrate volume and convert afterwards (right?).

Predicted root volume is mean-centered for easier computation, so modeled values are log(volume) ~ a + b*(log(depth) - log(mean(depth))). To make the integral easier, let's convert back to intercept=soil surface:

```
log(y) 	=  a + b*(log x - log c)
		= a + b*(log x) - b*(log c)
		= a - b*(log c) + b*(log x)
```

a-b*(log(c)) is constant, lump it together for the integral

```
log(y) 	=  a' + b*log(x)
y = exp(a' + b*log(x))
integral(y) = (exp(a') * x^(b+1)) / (b+1) + C
integral(y, 0,130) = exp(a') * 130^(b+1) / (b+1)
```

My calculus is terrible, so last two steps are on authority of Wolfram Alpha. But it does seem to match my crude integration-by-small-sums in R, i.e. `exp(a) * 130^(b+1) / (b+1)` comes close to matching `eps * sum(exp(a + b * log(seq(eps, 130, eps))))` for the values of a & b I have tried.

... OK, for the values of b > -1 I have tried. Below that they differ dramatically and Wolfram Alpha reports "integral did not converge." I will (naively?) assume this is a computational issue (float overflow?) and treat the above integral as correct.

==> Added a generated quantities block that simulates newly observed tubes and generates predicted quantities from the posterior for each one:

* tube offset `b_tube_pred`,
* Expectations for log mean `mu_pred` and log odds of detection `detect_odds_pred` at each depth,
* Simulated obervation data (including zeroes) `y_pred`,
* total root volume from the whole soil profile, from surface to the deepest requested prediction depth `pred_tot`.

This also requires adding new inputs: `N_pred`, `T_pred`, `tube_pred`, `depth_pred`.

## 2015-12-13

Returning to predictive checks above: Updated `mix_tube_depth.R` to include plotting of generated quantities.

Current predictive plots don't look great because Stan is fitting a positive b_depth, i.e. it thinks root volume is lower near the surface than deeper. Let's try to fix this by telling the model about our near-surface underdetection problem:

* We believe the rhizotron underdetects roots near the surface, probably because of poor soil contact. I can cite a ton of papers to back this up, but I don't know of any offhand that quantified the underdetection or how deep it extends.
* Our data seem to show that it's only be a problem very near the surface: When I plot mean tractor-core masses vs rhizotron observations at various depth, I get a ~linear relationship everywhere, but the slope is a lot lower for the 0-10 layer than for deeper ones.
* Using the wild-guess conversion factors I developed for my ESA 2015 talk (root volume/0.78 * density = root mass, density = (0.08 for maize, 0.19 for switch, 0.20 for miscanthus, 0.15 for prairie)), the core-vs-rhizotron plots have a slope whose uncertainty more-or-less-includes 1 for all layers below 0-10, while slope is more like 0.1-0.2 in 0-10 layer.
* ==> This implies that near the surface we're missing at least 80-90% of roots, then it rises quickly to ~complete detection by say 15 or 20 cm.

So (I think) what I need to do is add a "surface effect" fudge factor to capture this depth-dependent underestimation. To do this, I want a function that

* rises from ~0 at depth=~0 to ~1 at ~30
* Is well-behaved and doesn't fly off to infinity in either direction
* Can be estimated without too much trouble

How about a logistic function, i.e. `inv_logit(x) = 1/(1+exp(-(x-location)/scale))`? (Notation seems to be inconsistent; Stan calls this "inverse logit", R calls it plain logistic ('logis').)

* Takes real, returns real in [0,1], with inv_logit(location) = 0.5, `inv_logit(location - 3*scale)` about 0.05 and `inv_logit(location + 3*scale)` is about 0.95. So 90% of the distance from 0 to 1 covers about 6 scale units.
* What priors to use for location and scale?
	* If we detect ~10% of roots near surface, then surface is -log(1/0.1 - 1) = -2.19 scale units from location.
	* If we reach "full detection" by 30 cm, let's call 95% "full" and say we're at least -log(1/0.95 - 1) = 2.94 scale units from location
	* ==> So we've spanned 2.19+2.94 ~= 5 scale units in < 30 cm, so scale is <= 30/5 = 6.
	* ==> location is around 2.19*6 ~= 13 cm.
	* Does that work? test the other direction:

		```
		> plogis(0, 13, 6)
		[1] 0.102784
		> plogis(30, 13, 6)
		[1] 0.9444507
		```

		Yep, close enough.
	* Let's keep the prior relatively weak: location ~ normal(13, 10), scale ~ normal(6, 5). This allows for enough flexibility to let the surface-effect curve pass through more or less any point in the (0<=x<=30 cm, 0<=y<=1) space while staying within 2 sds of the priors, but should penalize surface effects that extend ridiculously far into the soil (right?)
	* NOTE: This is another "probably kinda cheating" prior: The idea that we underestimate near the surface comes from elsewhere, but all the numbers are from this dataset! Consider how to support these with evidence from elsewhere.

So, to implement this: leave calculation of `mu` as it is (expected true root volume), then compute `mu_obs`  (expected volume, observed, when we detect roots at all) as a depth-dependent fraction of `mu`. Since we're working on the log scale, that's

```
mu_obs[n] = mu[n] + log(inv_logit((depth[n]-loc_surface)/scale_surface))
```

which is equivalent to saying `y_observed ~ exp(mu) * surface_effect`.

N.B. Let's be extra-clear that I'm modeling two separate underdetection processes: First the surface effect that makes us underdetect everything, then the binary detection process AFTER this: If the surface effect makes our mean observed volume very small, then the chance of seeing zero roots is high! It might be reasonable to think of these as two spatial processes: the binary effect says roots are clumpy relative to the scale of sampling, the surface effect makes it hard to see roots regardless of volume.

While implementing this, I also split the parameters into two groups so I could graph latent parameter estimates separately from generated quantities. Should have committed this separately, but oh well.

## 2015-12-24

Converted jagged lines into smoothers when overlaying predictive intervals onto data-vs-prediction plots. Looks much nicer.

Moved sessionInfo() from bottom of `mix_tube_depth.R` to top -- it really should have been there all along, because it's intended as a debugging/reproducibility tool, and if it's at the bottom then any error in the script makes it exit without producing the information I might need for debugging!

## 2015-12-25

Synced current version to the cluster, ran job rz_mtd.1585115. 7 chains, 20k samples, 1000 samples warmup. Stan took 5134 to 5386 seconds, total wall time for whole script was 98m 3sec. Memory usages ~ 2.1 GB, vmem ~3.1 GB.

Most chain plots look good. Intercept maybe a tad slow-mixing by eye, and ESS for intercept is 4422  (all others >> 10k) ==> Probably should run a bit longer. Visual convergence in << 500 steps,  Rhats all 1.00 ==> Burnin seems long enough.

Merged git branch 'stan' back in to master -- It's time.

## 2015-12-26

Current model looks like it produces a reasonable fit to the whole dataset. Now to allow differences between crops. Which parameters should be allowed to vary?

* I believe the detection and surface-effect parameters arise from the minirhizotron method, and should not be expected to differ between crops. What would change my mind about that? 

	- Detection differences could arise from species-specific differences in root visibility OTHER THAN diameter, which we already account for. Say, systematic color differences that make some crops' roots contrast more with their background. My prior belief is that there's not enough difference in root color to worry about ==> use same `a_detect` and `b_detect` estimates for whole model. 

	- Surface-effect differences could come from differences in physical environment: If drying->cracking->poor tube contact->poor visibility, then maybe expect it to be worse in the crop that uses most water... but if tube motion->poor contact->poor visibility, then maybe worst in crops with most tube motion (Corn b/c working around stems for in-row tubes? Switch because trying to work through thick even stand?) Here too, my prior is that the effect is similar in all crops -- e.g. best I can tell, all crops plot on the same line in rhizo-vs-core plots (though this may be circular, because to get them on the same line I'm relying on root density assumptions that were picked partly on same basis). ==> use same `loc_surface` and `scale_surface` terms for whole model, at least at the outset.

* If root mass differs between crops, intercept term will differ nearly by definition ==> Estimate 5 separate terms for `intercept`

* Easy to imagine differences in root depth distribution: switchgrass is famously deep-rooted, corn supposedly pretty shallow ==> allow `b_depth` to differ between crops.

* Variance is likely to differ too -- maize is in rows with tubes both in and between, early miscanthus is clumpy, switchgrass has been thick and even since beginning ==> estimate 5 separate terms for `sigma`.

* Tube offsets (`b_tube`) are nested within crop ==> keep estimating one term per tube. I expect this is the parameter currently soaking up most of the variation between crops, so most `b_tube` magnitudes ought to shrink. 

* Should `sig_tube` vary by crop? Probably yes, by same logic as `sigma`: with vs. between rows is a between-tube variance, clumpy roots may be either within-tube or between-tube. Allowing both to vary gives most flexibility, and I /think/ the heirarchical model will keep both terms identifiable. ==> Estimate 5 separate `sig_tube`.

* `mu`, `mu_obs`, `detect_odds` are already calculated for each frame, will now use crop-specific parameters above ==> no change in number estimated.

## 2016-01-05

Copied `mix_tube_depth.stan` to `mix_crop_tube_depth.stan`, edited to let the above parameters vary by crop. 

On first run, estimates of total root volume are very long-tailed, with frequent spikes off toward +/- infinity. Looks like the problem occurs when estimated b_depth is very near -1. To stabilize, integrate from some small depth >0 instead of from exactly 0, so that when f(depth) tends toward infinity at 0 it's harder to take the whole integral along for the ride:

Wolfram Alpha says the integral from p to q of `exp(a + b*log(x))` is 
`exp(a) * (q^(b+1) - p * p^b) / (b+1)`. So let's integrate expected root volume under crop c from 0.1 to 140 as 

```
crop_tot[c] <- 
	(exp(intercept[c] - b_depth[c]*depth_logmean)
		* (depth_pred_max^(b_depth[c] + 1) - 0.1 * 0.1^b_depth[c]))
	/ (b_depth[c] + 1);
```

Also: added `lp__` to tracked parameters, both here and in `mix_tube_depth.R`

Uploaded to Biocluster, edited to use all rows instead of a subsample, submitted jobs for both with-crop and without-crop versions:

## 2016-01-06

* job 1661554 -- mix_tube_depth.sh. 

	7 chains, 20000 iterations on full dataset. 

	Ran successfully, walltime 01:44:35, 2 GB memory. Sampling time 5365-5658 seconds. n_eff for intercept is only about 5000, others look OK. TODO: Realized while looking at output that I need to change `pred_tot` here to use same intergration-from-0.1 as with-crop version.

* job 1661555 -- mix_crop_tube_depth.sh. 

	7 chains, 20000 iterations on full dataset. 

	All chains finished sampling in 7348-10462 seconds, then exits with error after 2:57:54 walltime:

	```
	Error in checkForRemoteErrors(val) :
	  one node produced an error: invalid class "stanfit" object: The following variables have undefined values:  y_pred[3],The following variables have undefined values:  y_pred[8],The following variables have undefined values:  y_pred[12],The following variables have undefined values:  y_pred[13],The following variables have undefined values:  y_pred[16]
	Calls: stan ... clusterApply -> staticClusterApply -> checkForRemoteErrors
	Execution halted
	```

This will be tricky to track down--no stanfit object returned, info file doesn't track state of generated quantities, so I need to dig into samples.txt... which is 16 GB for each chain! 

Examining headers, it looks like sample files contain ~30 lines of run-level diagnostics (Stan version, etc), then a CSV record of all 94158 (!) parameters for each iteration. Looks like the y_preds are near the end of each row, so let's extract those to look at without the rest of the file:

	```
	sed -e '/#/d' rz_mtd.1661555_samples.txt1| cut -d, -f94107- >> rz_mtd.1661555_samp1_ypred.csv
	# [repeat for ...txt2, txt3, etc]
	```

While I wait for those to finish running, let's think harder. Ran OK with a subsample on my laptop... let's see if a subsample runs on the cluster.

	```
	git stash # rolls us back to use a 1000-observation subset for all scripts.
	qsub mix_tube_depth.sh 
	```

(Oops, I meant to type `mix_crop_tube_depth.sh`! Didn't notice this at first until I wondered why the output had so few parameters in it.)

Runs as job 1668248:

* mix_tube_depth.sh, seven chains of 3000, subsampling with n=1000.
* This exits with error too! 11 of 35 y_pred are "The following variables have undefined values".

OK, but the full run of `mix_tube_depth.sh` was OK last night... what's going on?

First some administrative changes to make this easier to track down. I didn't notice the wrong-script error above at first, so let's be clearer about that in the output. added lines to `mix_tube_depth.sh` and `mix_crop_tube_depth.sh` to echo script name when they start. While I'm at it, made crop name-to-number mapping in `mix_crop_tube_depth.R` nicer-looking.

Edited `pred_tot` definition in `mix_tube_depth.stan` to integrate from 0.1 cm, so it matches the integration used in `mix_crop_tube_depth.stan`. Hopefully this will stabilize estimates here as well.

Local runs of current version of both `mix_tube_depth.R` and `mix_crop_tube_depth.R` (1000-obs subset, 3000 iterations, 7 chains) complete with no error and look OK.

Submitted runs of both scripts on cluster, should be identical conditions to local runs.

* 1668273 `mix_tube_depth.sh`

	runs with no warnings

* 1668274 `mix_crop_tube_depth.sh`

	```
	Warning messages:
	1: There were 274 divergent transitions after warmup. Increasing adapt_delta above 0.8 may help.
	2: Examine the pairs() plot to diagnose sampling problems
	```

Let's do that again.

* 1668337 `mix_tube_depth.sh`

	No warnings

* 1668338 `mix_crop_tube_depth.sh`

	```
	Warning messages:
	1: There were 86 divergent transitions after warmup. Increasing adapt_delta above 0.8 may help.
	2: Examine the pairs() plot to diagnose sampling problems
	```

* 1668340 `mix_crop_tube_depth.sh`

	5000 observations, 10000 iterations

	```
	Warning messages:
	1: There were 1141 divergent transitions after warmup. Increasing adapt_delta above 0.8 may help.
	2: Examine the pairs() plot to diagnose sampling problems
	```

* 1668344 `mix_tube_depth.sh`

	5000 observations, 10000 iterations

	No warnings


Returning to errored job 1661555. Let's look at *ypred.csv:

* Read all into R, stitched together into one dataframe, filtered for NAs and Infs.
* As expected, each of the y_pred parameters throwing errors (3, 8, 12, 13, 16) contains one sample where value is NaN. All occur at the very beginning of chain 3: 12 & 13 are NA on 3rd sample, 3 & 16 on 4th, 8 on 7th.
* Some infinite values in this neighborhood of chain 3 too -- `y_pred[2]` is Inf for samples 1-2-4-5, 13 on 4, 17 on 2, 18 on 2-3-5, 22 on 7, 23 on 2, 28 on 1-4-7, 32 on 6.
* No other chain contains any infinite or NaN values.
* ==> I'm going to try rerunning the full model again in the hopes that I just got unlucky with starting parameters in that one chain.

Since earlier test runs warned about divergent transitions after warmup, let's see if a longer warmup helps. Increased n_warm from 1000 to 3000.

Submitted job 1668345: all observations, 20k iterations on 7 chains, 3000 samples warmup.

	Error in checkForRemoteErrors(val) : 
	  one node produced an error: invalid class "stanfit" object: The following variables have undefined values:  y_pred[4],The following variables have undefined values:  y_pred[9],The following variables have undefined values:  y_pred[19]
	Calls: stan ... clusterApply -> staticClusterApply -> checkForRemoteErrors
	Execution halted

Looks like all the NaNs are, again, at the very beginning of chain 3.

## 2016-01-07

A shot in the dark: Stan script currently declares no lower bound on `y_pred`, `crop_tot`, or `pred_tot`. These ought to all be nonnegative -- would specifying that in the variable declaration help? Edited these in both `mix_tube_Depth.stan` and `mix_crop_tube_depth.stan`.

Let's see if there's any intermittency to the errors from these, without waiting forever for each run to finish. Pushed changes to cluster, started three copies each of `mix_tube_depth.sh` and `mix_crop_tube_depth.sh`. All use full dataset, but only 5000 iterations, warm=1000.

* 1668696, 1668697, 1668698: `mix_tube_depth.sh`
* 1668699, 1668700, 1668701: `mix_crop_tube_depth.sh`


A change of pace while I wait: Cleaning up some cruft in the data directory.

* `ef20200524-Robjects.Rdata` contains objects from an old preliminary analysis of one day of data from 2010-05-24. Have already deleted all other files from this analysis, and it looks like I may well have committed this one by accident anyway. Oops.

	==> Deleted.

* `rhizo laptop listings/` contains listings of what images existed on the field laptop at some unknown data in 2011, and has been here since I first started version-controlling the project. Many of the filenames were changed by the manual-cleanup step, so the only information that might be useful from this is "how many images once existed and did I actually copy them all onto the server?"

	==> Keeping a copy on my archive drive just in case, but deleting this from the repository.

* `Ref-images.xls` gives some mappings from tube number to calibration image from 2009, when I hadn't yet settled on a calibration system. These could be useful if I ever want to finish tracing the 2009 images, but not until then.

	==> Saved a CSV version of this in `notes/`, deleted XLS version.

* `analysis log2010-03-25.xlsx` is actually the analysis log for 2009-08-26; I bet 2010-03-25 is when AP started the tracing process. Ought to be in rawdata with the other tracing logs.

	==> Saved a CSV version as `rawdata/analysis-log-2009-08-26.csv`, deleted XLSX version. Logged in to tracing computer and renamed it there too: from `Desktop/Energy Farm Rhizotron/analysis log2010-03-25.xls` to `Desktop/Energy Farm Rhizotron/EF2009/2009-8-26/analysis-log-2009-08-26.xls`

* `20090827/EF20090827-frametots.txt` is another leftover from old analyses. It is identical to the result of running `frametot-collect.sh` on `rawdata/winRHIZO\ 2009.8.27.txt`.

	==> Deleted.

* `20090827/log.txt`, with some notes from tediously hand-sorting duplicate tracings and from comparing files to restore some from the backup of a crashed hard drive. This looks like information that should have been in this log all along.

	==> Deleted, but pasting whole file here for reference:

	```
	17 March 2011, 12:35 AM
		Analayzing 2009-08-26 EF rhizotron data (NOT NECESSARILY THE RIGHT VERSION -- I didn't check whether this is the same as the version in the restored files). Followed /Users/chrisb/UI/energy farm/rhizotron data/dataprocessing.txt through step 4, am trying to check for duplicates. Have removed "easy" dups, i.e. the ones that differ in MeasDate and MeasTime but nowhere else. Have list of tube/location combinations where dups remain. 
		Tube 28: location 70 updated, last entry OK
		Tube 29: Locations 5,10 updated, last entry OK
			Location 15: Looks identical-except-date-and-time. I'm looking at the raw data rather than the set with the dups removed, so this just means the image was opened and not updated in winRhizo, right?
			
	17 March, 5:00 PM:
		Comparing directory contents of restored and unrestored rhizotron data directories (user rhizotron, directory "Desktop\Energy Farm Rhizotron". For shorthand, "restored" means the version that just came out of the backup file, "orig" means the version that was on the computer before, even though in some cases the "orig" version may be newer. Woo, confusion.
		 Note that Ahbi reports there are also some 2009 analyses on the imager computer where 2010 analysis is being done; haven't checked those yet.
		
		calibration:
			2 files in restored that weren't in orig. Copied them over and now they match.
		data:
			"amdtest.TXT" was in restored but not orig; copied to match. All 4 now files in the directory appear to contain root length data from 2009-06-05:
			"amdtest.TXT"
				tubes 1 & 12
			"EF09.TXT"
				tubes 1 & 2
			"eftest.TXT"
				tube 26 loc 5, several locations form tube 97 
			"tmp.TXT"
				tube 1 loc 22
		EF2009-06-05:
			Restored version has many more .pat files, but no winrhizo file present in either version. Where is it? In data directory and extremely fragmentary, apparently.
				pat files are from tubes 1,2, and 12.
		EF2009-06-17:
			Restored version has winrhizo data file and many more .pat files. 
		EF2009-7-24:
			identical except thumbs.db, no pat files or winrhizo data in either.
		EF2009-8-26: only in orig
			contains images from 44 tubes (+calibration). winrhizo file has frames from all of them.
		EF2010-05-24: only in orig
		EF2010-7-22: only in orig	
		Ref-images:
			identical
		Session 1:
			4 pat files differ (T1L8, T1L10, T1L11, T1L12). 99 more pat files in restored version. No winrhizo data file in either.
		winrhizo files:
			restored version contains "ef-winrhizo.CFG", orig doesn't. "demotest.TXT" is common to both and contains measurements for WinRhizo sample images plus 2009-06-05 tube 1. 
		analysis log 2010-03-25: only in orig
		analysis log.xlt: only in orig
		calibration images.xls: only in orig
		README.txt: only in orig
		efrhizo-2009-06-05.xlsx: only in restored
		efrhizo-2009-06-17.xlsx: only in restored
		efrhizo-analysis-template.xltx: only in restored 
	```

* `20090827/quickprocess-history-20110328.history` is an R console log from doing a now-outdated analysis. Everything I do in it is hand-rolling things that are now handled by the functions in rhizoFuncs.

	==> Deleted.

* `2012/` contains XLS versions of analysis logs for sessions 2-6 2012, plus two XLS spreadsheets from the the ID-correction process before tracing. Most of these need further hand-transcription: Bad frames from sessions 3-6 are not yet added to censorframes2012.csv. Session 2 has been, though.

	==> Converted `analysis log 2012-S2.xls` to `rawdata/analysis-log-2012-s2.csv`, deleted original.

	==> Punting on other 4 analysis logs: Keeping them here is a decent reminder that need to be transcribed into censorframes2012.csv at time of moving.

	==> Punting on preseason cleanup spreadsheets `2012 Tube Corrections with renamer.xls` and `2012 Tube Corrections.xls`. These probably ought to live in `notes/` eventually, but not moving them yet.

==> `2012/` is now the only thing in `data/` that is NOT generated by the Makefile. Updated the Readme to specify this.

## 2016-01-09

Edited this log to correct some Markdown formatting errors: Mostly unifying all datestamps as H2, some list display issues, plus corrected a few 2015/2016 date errors (all from this week) that I found in the process.

Added censored frames from 2012-S3 to `rawdata/censorframes2012.csv`, exported analysis log from `data/2012/analysis log 2012-s3.xls` to `rawdata/analysis-log-2012-s3.csv`---No, hold up. 

Actually exported from `~/UI/ef-tracing/EF2012_T1-53/analysis-log-2012-s3.xls`, which is identical to the one in `data/2012/` except that I already converted dates from "yyy.mm.dd" to "yyyy-mm-dd" like I want in the CSV version.

Deleted `data/2012/analysis log 2012-s3.xls`.

Looks like I kept yyyy.mm.dd dates when I converted `analysis-log-2012-s2.csv` the other day. Fixed this.

## 2016-01-10

Have been running my Torque scripts with 7 processors, which is really one less than I need -- the dispatching process needs to keep one core while it runs 7 chains! Changed `mix_tube_depth.sh` and mix_crop_tube_depth.sh` from ppn=7 to ppn=8.

Neglected to remake datasets after updating censored 2012 images last night. Ran `make`, which generates updated version of: 

* `stripped2012.csv` (all rows change because centered values are recalculated -- TODO: maybe remove these? Was using them when trying to do stats in lme4, but not now.)
* `logvol-cornpoints-2012.png`
* `logvol-cornpointsline-2012.png`
* `logvol-polyfit-2010.png`, `logvol-polyfit-2011.png`, `logvol-polyfit-2012.png` -- 2012 & 2010 only update because they're plotted by the same script, changes not saved.

All updated images now have their numbers overlapping the axis lines and ggplot warns "axis.ticks.margin is deprecated. Please set margin property of axis.text instead." Hypothesis: Something in the DeLuciatoR or ggplotTicks packages is incompatible with ggplot 2.0, which I installed when I upgraded my laptop last month. TODO: fix this and replot these figures, but for now I'm committing the version plotted from the most recent data.

## 2016-01-11

Doing some input-cleaning on Stan scripts. Tired of dealing with Tube as a factor; let's go scorched-earth and change it way back at the source in `cleanup.r`. Things to note:
	
* The only place I might want tubes to be factors instead of numnbers is if passing them to the fixed-factors formula of a linear modeling function, where they should NOT be treated as a continuous covariate. I'm fairly sure all the formulae in this repository use Tube only as a random factor, where lmer converts it to factor anyway. Have not checked exhaustively, but if any stats break from this change this is almost certainly why.

* This change creates a giant diff because Make will remove a whole lot of quotation marks from the stripped datafiles, but the simplification should be worth it.

* Make also rebuilds all the figures with no visible change to data, but ruins their formatting (numbers overlapping axis ticks) for the same reason noted 2016-01-10. NOT committing the updated images -- fix plotting code and redo these correctly!

## 2016-01-16

Compared `data/2012/analysis log 2012-s4.xls` against version in ef-tracing repository, found this one to be out of date. Deleted it, saved ef-tracing version as `rawdata/analysis-log-2012-s4.csv`, converted four color-encoded notes to text (tubes 21-24 were traced with 8-0-7 calibration instead of 8-06 like they should have been, JNR flagged this with orange cells, so I converted to notes), added bad frames to censorframes2012.csv, reran cleanup scripts. As on 2016-01-11, did *not* commit replotted 2010 & 2011 logvol-polyfit figures, which changed formatting but not underlying data. Still TODO: Fix formatting!

## 2016-01-18

Set out to add bad images from S5 (end of August) 2012 to censored images file, realized I'd forgotten this session is only partly traced. All blocks of maize and Miscanthus are traced, but only blocks 1,2,4 of switch and prairie are done -- JNR finished all his assigned tubes, CRS stopped after tube 50. Finished recording bad frames for what is traced; will need to revisit when (if?) these are traced.

Deleted `data/2012/analysis log 2012-s5.xls`; it's out of date. Exported newer version from ef-tracing repository to `rawdata/analysis-log-2012-s5.csv`.

## 2016-01-19

Deleted `data/2012/analysis log 2012-s6.xls`; it's out of date. Exported newer version from ef-tracing repository to `rawdata/analysis-log-2012-s6.csv`, added bad frames to `censorframes2012.csv`. 

NOTE: Bad-frames listing for sessions 4-5-6 of 2012 is based on my visual review of all images while checking log entries, and I did overrule the tracing tech's decision in a fair number of cases -- at least one frame changed in 5-10% of tubes, maybe? For previously entered sessions, I had mostly trusted tech's decisions and simply transcribed the bad frames listed in the analysis log. Possible TODO: revisit all other years/sessions and check censoring decisions.

## 2016-01-21

Running separate Stan runs for August of each year, by altering the subset of data I pass in, e.g. `rows_used = which(strpall$Year==SUB_YEAR & strpall$Session==SUB_SESSION)`. For 2010, 2011, 2012 SUB_SESSION=4; for 2013 use Session 5, for 2014 use Session 2. Image count for these sessions ranges from 1223 (2013) to 1912 (2012). 

Also tweaked from previous runs: Bumped n_predtubes from 5 up to 8 for better estimation of tube variability in predicted values, turned off writing of sample files (they're huge and haven't been all that helpful for debugging thus far). For all year, 7 chains of 20000, n_warm=1000.

Submitted these jobs with subsets as listed, editing script in between once I see they've started running (I hope this is safe...?)

* 2010 S4: 1697993
* 2011 S4: 1697994
* 2012 S4: 1697995
* 2013 S5: 1697996
* 2014 S2: 1697997

## 2016-03-27

Working on final plots of 2011 and 2014 Giddings core biomass and C/N content. First: Adding data to the Git repo. Root/rhizome biomass from 2011, CN data from 2011 and 2014. 2014 root/rhizome biomass is already present. All are my conversions to CSV from Excel sheets that Mike Masters emailed me on:

* `rawdata/Tractor-Core-Biomass-2011.csv`: 2013-10-02
* `rawdata/Tractor-Core-CN-2011.csv`: 2014-10-13
* `rawdata/Tractor-Core-CN-2014.csv`: 2016-03-21

While working on plot scripts, found some errors in 2011 CN data. Corrected after a few emails with Mike, summarized here. Note date stamps -- this all happened over the course of the last several days while I ignored Git, so I'm committing it separately to keep track.


Subject: Re: 2014 tractor core CN   
From: Chris Black <black11@igb.illinois.edu>   
Date: Tue, 22 Mar 2016 14:43:50 -0500   
To: Michael Masters <mmasters@illinois.edu>   
 
> Thanks. These look pretty straightforward --- only two questions about 2014:
> 
> * The block 1 & 2 Miscanthus fertilization rates in the CN file disagree with the ones in (the 2014-12-02 version of) the root biomass file. Biomass file says block 1M was N&W 56, E&S 0; while  2M was E&S 56, N&W 0. The CN file reverses this: 1M with N&W 0, E&S 56; 2M with E&S 0, N&W 56. Which is correct?
> 
> * The CN file has no row for 0C2 100+, which the biomass file says had only 0.01 g root. Safe to record this as Not Enough Material?
> 
> 
> I’m less sure how to approach the 2011 CN file (version you sent to me on 2014-10-13):
> 
> * 1C4 has two lines labeled 50-100, none labeled 100+. Is one of these the 100+ sample?
> 
> * 0M5, 2M1, 2M2, 3M2, 4M1 have two 0-10 lines each. The biomass data shows rhizomes present in the 0-10 layer of all these samples. Is one of these CN values root and one rhizome? If so, which is which?
> 
> * 3M3 has three 0-10 lines. Rhizomes are present, but would only account for two of them. 
> 
> * 3S2 has two 0-10 lines, but the biomass data says no rhizomes.
> 
> * 2M2, 3M2, 4M3 are the only samples where the biomass data shows rhizomes in the 10-30 layer, but there is only one CN value from each. Fair to assume the CN values are from roots and that the rhizomes were intentionally skipped?
> 
> * Not a data quality issue, just interesting: In both years, 0C shows an exceptionally wide scatter in the %C of its 100+ samples, but %N seems normal. Any ideas why?

From: "Masters, Michael David" <mmasters@illinois.edu>   
To: Chris Black <black11@igb.illinois.edu>   
Subject: RE: 2014 tractor core CN   
Date: Fri, 25 Mar 2016 18:50:01 +0000   

> Hey Chris,
> I'll go in order.  Sorry it's taken me a few days to get back to you.  Been busy lately in the field.  We harvested miscanthus earlier in the week, and we've been using the Picarro every day for our jars.
> 
> 2014
> 
> * The initial email Tim sent me back in the spring of 2014 had blocks one and two switched.  It was funny because we spent the whole field season thinking that they were reversed because the biomass looked much bigger on the unfertilized side.  So, many of my early files on this had the wrong information.  The correct fertilizer halves were South for plots 1, 3, and 4, and north for block 2.  This is correct in the final data file I sent you the other day.
> 
> * I'm assuming you mean OCNorth1, because that is the only B0 sample in 2014 with no 100+ CN values.  You are correct, there was not enough material for that one.  I will add a NEM note.  Not sure how I missed that.
> 
> 2011
>
> * The 1C4 that has a %N of 0.58 and a % C of 31.59 is actually 1C4 100+.  Oops, good catch.
> 
> * Wow... I can't believe I didn't put those labels in there.  That's embarrassing.  Thank you for catching that.  I added those labels in the notes column.
> 
> * 3M3 there was a rhizome run twice, new value is averaged between the two duplicates there previously.
> 
> * For 3S2, I had to go back into the original weighing notebook.  Both samples are clearly labeled as 3S2, one with 50% dead, and one with 1% dead.  We couldn't actually have two of the same sample.  The biomass from that 0-10 fraction was 3.5 grams, a nice healthy sample size.  I'm going to assume that the 1% dead sample is correct, and that the 50% dead one was something else that was mislabeled and throw it out.
> 
> * Yes, I think that's what happened.  We grind the rhizomes in a different grinder, so we usually separate them from the rest of the roots.  I bet they just somehow slipped through the cracks, probably treated different because the were 10-30's. I've confirmed in data from the runs that those in the sheet are roots.  You want me to try to dig out the rhizome material and run them?  Probably won't be too hard.
> 
> * That's pretty strange... it's only with block 0?  I don't know.  I would think it would be the other way around.  Usually the C is really consistent, and the N data is all over the place.  I will think about it and try to come up with an answer.
> 
> Let me know if I can do anything else to help.
> 
> Mike

Mike attached an updated 2011 CN file: Most of the differences are that root and rhizome are now identified with an annotation in the 'notes' column. Updated `rawdata/Tractor-Core-CN-2011.csv` to incorporate all changes -- this breaks my (still uncommitted) plotting script, will commit all R code separately.

Hand-corrected fertilization rates in 2014 biomass file to match 2014 CN file: As per Mike's email, Blocks 1 & 2 were swapped. Correct rates for Block 1 are N0 E56 S56 W0, Block 2 N56 E0 S0 W56.

First ~working attempt at a tractor core data cleanup script. Writes all 480 locations/depths for each year to `data/tractorcore.csv`. Note that all C and N contents are for individual samples, so samples that had biomass but no CN data show as missing values here. In downstream plots/tables, I plan to recalculate these from block-averaged %C and %N in order to avoid losing the biomass information (especially important for 2011 10-30 layer, which contained a few rhizomes but they didn't get measured).

First ~working plot script saved, with ouputs and updated Makefile for the while pathway. Used whole-plot average %C and %N of rhizomes, but block/horizon averages for roots. This involved re-doing a bunch of the calculations from tractorcore-cleanup.R in plot-tractorcore.R and I'll probably kick myself for adding the duplicated code later, but this seems to work for now anyway.

## 2016-03-28

Correcting one note in censorframes2014.csv: T92 L065 is censored because of water droplets. This triggers a replot of several figures in new ggplot style:
	
	figures/destructive-mass.png
	figures/destructive-massvsvol.png
	figures/destructive-vol-fulldepth.png
	figures/destructive-vol.png
	figures/logvol-polyfit-2014.png

No changes to data, just linewidth/spacing changes. NOT committing the changed figures!

## 2016-03-29

Cleanup in the operator-agreement directory: renamed many raw data files, imported all remaining data from imager, converted logs from XLS to CSV, moved calibrations into one CSV. Started a readme and the VERY first attempt at a Makefile, but it's not ready to use yet. Beginning to think about analysis plans for the agreement data, but need to think more before writing it down.

More data cleanup! Found a note in an old TODO file reminding me to check 2012 T21 S2 for duplicated images. Inspected images, found that locations 1 and 45-75 all show location 40. Locations 5-40 and 80-110 all look OK: they show the same soil features visible at those locations in sessions 1 and 3. Updated 2012-censorframes.csv, reran Make.

TODO: While checking T21 locations, noticed that 2012 T21 L115 S3 is a black image, but does not appear in censorframes-2012.csv. Fixed that, but this lead me to notice that in both sessions, the raw data file contains no entries for frames deeper than 95, even though images do exist for locations 100-110! Long-term, I probably need to do some kind of automated cross-checking of image listings against trace listings. For now, I'm just going to hope this isn't a widespread problem and shrug it off as a couple of missing datapoints that would only contribute zeroes.

## 2016-03-30

Last night's "black image" for 2012 S3 T21 L115 is actually a blue screen like most other bad images, I just had my laptop screen set to a late-night color balance and couldn't tell. Fixed in censorframes2012.csv.

Now trying to update Biocluster scripts to run Stan  estimates all at once instead of manually editing and resubmitting:

* Modified `mix_crop_tube_depth.R` to accept year and session number as arguments.
* Run `mix_crop_tube_depth.R` from a Torque script that generates a job array by using the `PBS -t <range>` directive: According to http://help.igb.illinois.edu/Job_Array_Example, this generates as many copies of the script as there are indexes in `<range>`, then dispatches them with `$PBS_ARRAYID` set to each index.

	A wrinkle, though: In my experimental runs, this seems to mostly work, but the script run with the first index (no matter what number I start from) doesn't generate any output! Thought at first it was always exitting with an error, but later it seemed to return 0 and take a normal amount of time to run. Have emailed the Biocluster techs to ask about this, meanwhile I'm going to include a model I don't really care about as the first job in the array.
* `#PBS -t 0-5` should generate six runs. Let's map their indices to different midsummer rhizotron sessions.
* Midseasons as run 2016-01-21, plus July 2010 (S3) as the sacrifical first job: 2010-s3, 2010-s4, 2011-s4, 2012-s4, 2013-s5, 2014-s2:
	```
	years=(2010 2010 2011 2012 2013 2014)
	sessions=(3 4 4 4 5 2)
	y="${years[$PBS_ARRAYID]}"
	s="${sessions[$PBS_ARRAYID]}"
	```
* Now pass each one in to the R script: `time Rscript mix_crop_tube_depth.R "$PBS_JOBNAME"."$SHORT_JOBID" "$y" "$s"`

Assembled all these changes into one file, saved as `mix_crop_tube_depth_midsummers.sh`.

While I'm at it: Changed handling of n_subsample so that's also an *optional* argument to the script. If not provided, use all rows from the chosen year and session.

OK, let's try this. Pushed all changes to IGB cluster, ran all mix_crop_tube_depth for all midsummers as a simple $(qsub stan/mix_crop_tube_depth_midsummers.sh)

* Job ID: 1862884[].biocluster.igb.illinois.edu
* 7 chains, 20000 iterations each
* No subset (should run all rows of each year/session)
* array indexes (#PBS -t) 0-5
* years=(2010 2010 2011 2012 2013 2014)
* sessions=(3 4 4 4 5 2)

All jobs run 8-11 minutes, finish Stan sampling but exit with errors at beginning of plotting code:

```
Error in if (debug) { : argument is of length zero
Calls: print ... element_grob -> element_grob.element_text -> titleGrob
Execution halted
```

I vaguely remember messages like this when I first installed ggplot 2.0.0 and was still running a version of Rstan that had been built against an earlier version. Tried switching from R 3.2.0 to R 3.2.3 by updating the `module load` call in Torque script, but Stan is not installed for 3.2.3. Will email David Slater and ask to get all new versions set up in R 3.2.3 (need to check which versions of what I need).

Bigger problem: I coerced the runname to numeric, so all six runs overwrite each other as "NA.Rdata". Gah! Removed as.numeric around runname in mix_crop_tube_depth.R.

Removed project name (`#PBS -A rhizotron`) from Torque scripts -- Biocluster docs say it needs to match a project name you have on file, all mine were set to "rhizotron" but are changed in the records to "black11" because that's the default for me. I'll let it stay default for now.

Installed Rstan 2.9.0-3 myself to `~/R/x86_64-pc-linux-gnu-library/3.2/`, along with automatically installed dependencies (ggplot2 2.1.0, inline, RccpEigen, StanHeaders) rather than wait for installation by admins. Updated R module calls to 3.2.3.

Current post-stan save calls preserve the Stan samples, but not subsampled data (possible to reconstruct this from logs, but tedious) or simulated rz_pred dataframe (needed for plotting). Added both of these to the saved Rdata object.

Some R environment setup to tell R that it should preferentially use the locally installed rstan. And while I'm at it, let's set some compiler flags, most notably -O3 (Stan howtos report this ~always gives a noticeable speedup in model runtime for only a little increase in compile time).

```
echo '.libPaths("/home/a-m/black11/R/x86_64-pc-linux-gnu-library/3.2")' >> ~/.Rprofile
mkdir ~/.R
echo 'CXXFLAGS=-O3 -Wno-unused-variable -Wno-unused-function -Wno-unused-local-typedefs -march=native' >> ~/.R/Makevars
```

## 2016-03-31

...Lots of frustrated troubleshooting omitted here, and lots of jobs run and deleted. Key symptom is that all Stan scripts, even very simple ones, were succeeding when run with 1 chain but failing when run with multiple chains:

```
Error in .Object$initialize(...) : 
  could not find function "cpp_object_initializer"
In addition: Warning message:
version 2.1.0 of 'ggplot2' masked by 1.0.1 in /home/apps/R/R-3.2.3/lib64/R/library 
failed to create the sampler; sampling not done
```

Things I tried included: Adding `library(Rcpp)` to top of script, deleting compiled model (*.rda) and recompiling, adding a second trivial model to the middle of the main script... lots of cursing, of course...

Played with a trivial Stan regression on synthetic data. Key insight: this too breaks, but only when I ask for more than one chain --> local R environment is somehow masked by system default environment on worker thread dispatch!

Reduced chains to 1. full model runs now!

OK, so if one of the complaints is that the system ggplot2 1.0.1 is masking my local ggplot2 2.1.0, what if I use a different R module? `R/experimental` has ggplot 2.1.0 already.

IT WORKS!!!

* Job 1863305[].biocluster.igb.illinois.edu
* 7 chains, 20000 iterations each
* No subset (should run all rows of each year/session)
* array indexes (#PBS -t) 0-5
* years=(2010 2010 2011 2012 2013 2014)
* sessions=(3 4 4 4 5 2)
* walltime 9:15 - 21:21
* memory ~2.5 GB each

"sacrificial" 2010-S3 ran normally -- looks like whatever gremlins caused the first-index issue are resolved now. Mixing in 2010-S3 is poor though, not sure why.

Zipped up results in three separate tarballs for copying back to laptop: images as `rz_mctd.1863305-pngs.tar.gz` (~21MB), Rdata as `rz_mctd.1863305-rdata.tar.gz` (~1.5 GB), and log files as `rz_mctd.1863305-logs.tar.gz` (~17KB).

Created run scripts to fit each session of 2010 (`mix_crop_tube_depth_sessions10.sh`, fits sessions 1,3,4,5) & 2012 (`mix_crop_tube_depth_sessions12.sh`, fits sessions 1-6), pushed all changes to Biocluster. Note that none of the Stan output is committed to Git yet, I'm just copying it back and forth by hand thus far.

```
qsub mix_crop_tube_depth_sessions12.sh 
1863316[].biocluster.igb.illinois.edu

qsub mix_crop_tube_depth_sessions10.sh 
1863317[].biocluster.igb.illinois.edu
```

2010 script had wrong year in it! These fits show 2012 again. Deleted all files from job 1863317, fixed script, reran as job 1863349.

Hastily constructed scripts to assemble/plot results from all fits. Barely finished in time to show results to Evan at 2 PM before committing any changes. Now (11 PM 2016-04-01) committing these scripts after renaming/cleaning them up a bit.

This workflow is getting a bit ridiculous. Let's review:

* Raw data are cleaned up to annual files by a series of two scripts (frametot-collect.sh, then cleanup.R). This process is automated in the Makefile and all the intermediate steps are saved as version-cpntrolled files.
* The clean annual files are mashed together by stat-prep.R to produce a single master dataset. The master dataset is currently not saved anywhere; instead each model script is responsible for calling stat-prep.R itself.
* Stan models are run on the IGB computing cluster, by submitting the appropriate Torque script, which calls the appropriate R script, which runs the appropriate Stan model. None of this process is in the Makefile and all the scripts in the sequence are very tightly coupled, i.e. they each rely heavily on the exact format of each others' inputs and utputs, so I usually have to edit them all at once.
* The model I'm currently using is run by mix_crop_tube_depth.R, which: 
	* Takes arguments that specify which year and session to fit, and whether to fit all available lines of data from that year or to subsample them. Those arguments are specified in the Torque scripts. 
	* Assumes a run of one session from one year, and will exit with an error if called otherwise. This assumption was newly added on 2016-03-30 and the underlying Stan model will happily fit data that spans multiple days (but it won't estimate any time-related parameters, either!)
	* Set
	* Attempts some diagnostic plotting and prints some summaries, but also save an Rdata file that contains three objects: the fitted model, the subset of the clean rhizotron data that was used to fit it, and the set of crop/depth/tube combinations at which to simulate predicted data.
* Model results are summarized by calling extractfits_mctd.R to get root volume parameters from each model fit and store them as neatly formatted (or at least *more* neatly formatted) CSVs.
* Finally, plotfits_mctd.R gathers all the fits from the various models and plots them in ways that are, hopfeully, comprehensible to the world.

The model results I plotted for Evan come from job IDs `rz_mctd.1863305` (peak samples from all years), `rz_mctd_2010.1863349` (2010 all sessions), and `rz_mctd_2012.1863316` (2012 all sessions). Note that `extractfits_mctd.R` names files by year and session and overwrites any duplicates, and that I ran it on the peak outputs before the single-year outputs, so the peak 2010 and 2012 values I plotted are the ones from jobs 1863349 and 1863316 respectively, *not* from `1863305[1]` and `1863305[3]`. But they *are* supposedly identical runs or supposedly the same model, so the values ought to be very similar. My squints at the diagnostic plots say this is more or less the case.

## 2016-04-01

Emailed Biocluster staff to ask for rstan upgrade. David Slater upgraded rstan to 2.9.90 in R/3.2.0 module and also installed it in R/experimental, with warning that experimental is bleeding-edge with weekly automated package updates, so it may break at any time. I'll keep using R/experimental for now, but removed my local ~/R/ and .Rprofile so all packages use the system version of rstan.

My "first job in the array does't run" issue from 2016-03-30 seems to have resolved itself with no changes from me. Removed the `sacrificial` job from `mix_crop_tube_depth_midsummers.sh`.

Submitted updated midsummers script as job 1863731. Theoretically nothing has changed in the model, so I expect output very similar to job 1863305, though with no 2010-S3. 

## 2016-04-02

Conclusion on checking traceplots and output summaries from 1863731: Yes, output is very similar, but in both cases the model seems to have intermittent mixing trouble: One previously-well-mixing chain gets stuck partway through the run, stays fixed at ~same values of nearly all parameters for a while, eventually starts moving again. In run 1863305 this visibly affects the 2014-S2 data, while in run 1863731 the 2014-s2 traces look fine but 2012-s4 has a DRAMATIC freeze from samples ~13k to ~18k. Wonder how many other chains do this but aren't visible because they're overplotted by well-mixing later chains? Probably need to do some test runs with fewer chains and see if I can find where in parameter space it's getting stuck.

Also: Apparently I committed the wrong file yesterday: Deleted gatherfits_mctd.R, which is an unwanted copy of extractfits_mctd.R, and added plotfits_mctd.R, which I thought I was adding in 54a6d8.

Moved last two hand-edited files out of `data/` directory. It is now actually true, with no asterisks, that everything in `data/` is generated, by a scripted process that can be rerun at any time, from something in `rawdata`.

## 2016-04-05

Trying to diagnose occasional "divergent transitions after warmup" warnings -- I had been ignoring these, but I gather from reading the Stan-users mailing list that these often indicate the sampler is having trouble covering the full posterior distribution, and the part-line advice seems to be to treat any divergent transitions as too many. don't know yet whether these are related to the stuck chains noted on 2016-04-02.

In job 1863731 (most recent run of peak samples from all five years), 2010-s4 did not warn and all of 2011-2014 did warn: 82, 1128, 828, 592 divergent transitions after warmup, respectively.

Plan of attack:

* Are the warnings consistent? --> run same job several times, check divergent transition count
* Take the warning's advice: 2011-s4 output is typical.
	```
	Warning messages:
	1: There were 82 divergent transitions after warmup. Increasing adapt_delta above 0.8 may help.
	2: Examine the pairs() plot to diagnose sampling problems
	```
* ???

Well, one thing at a time. Made the following changes--No I didn't. Biocluster seems very sluggish right now (can't even get a git status without waiting minutes).

## 2016-04-06

OK, *now* making the following changes.

* Uncommented the two `pairs()` plots in `mix_crop_tube_depth.R`. These take forever to run, but if they're the correct diagnostic then they're the correct diagnostic.
* Submitted mix_drop_tube_depth_midsummers.sh five times. Job numbers:
	1865013, 1865014, 1865015, 1865016, 1865017
* Edited mix_crop_tube_depth.R to add `control=list(adapt_delta=0.85)` to the stan call.
* Edited mix_drop_tube_depth_midsummers.sh to set job name to "rz_mctd_ad85"
* Submitted mix_drop_tube_depth_midsummers.sh five more times, note job numbers:
	1865019, 1865020, 1865021, 1865022, 1865023
* Edited mix_crop_tube_depth.R to set adapt_delta=0.90.
* Edited mix_drop_tube_depth_midsummers.sh to set job name to "rz_mctd_ad90"
* Submitted mix_drop_tube_depth_midsummers.sh five more times. Job numbers.
	1865024, 1865025, 1865026. 1865027, 1865028

...All jobs with adapt_delta edited (1865019 onward) crash in two seconds because I didn't add a comma after the control parameter.

* Edited mix_crop_tube_depth.R to add a comma to the end of line 141: `control=list(adapt_delta=0.90),`
* Submitted ...midsummers.sh once, waited a minute, no crash. submitted for more. These are all with jobname `rz_mctd_ad90`. Job numbers:
	1865030, 1865031, 1865032, 1865033, 1865034


## 2016-04-10

Looking at output from 2016-04-06. Observations:

* Yes, models with divergent transitions produce them consistently every run. Easiest to see this by grepping for "divergent" in output logs, e.g. `$(grep 'divergent' rz_mctd.o186501*|sed -n '/ $/d; p'|sort)` (the sed call is just because the same warning appears twice in each log, once ending with a space and once without.) 
	2010: none
	2011: 146, 209, 11, 16, 30 => mean = 82.4
	2012: 6, 32, 86, 19, 5 => 29.6
	2013: 1803, 1120, 909, 689, 4951 => 1894.4
	2014: 697, 446, 172, 351, 421 => 417.4
* increasing adapt_delta to 0.9 doesn't seem to change number of divergences. Maaybe a bit fewer on average, but max is 11818!
	2010: none
	2011: 99, 24, 10, 18, 62 => 42.6
	2012: 30, 38, 8, 32, 181 => 57.8
	2013: 526, 473, 302, 11818, 546 => 2733
	2014: 328, 204, 1844, 388, 528 => 658.4
* edited adapt_delta to 0.99, submitted five jobs as rz_mctd_ad99.*:
	1866691, 1866692, 1866693, 1866694, 1866695
* `$(grep 'divergent' rz_mctd_ad99*.o186* | sed -E '/ $/d; s/^(.*?-(.)):/\2 \1/' | sort)`
	2010: none
	2011: ?, 15, 8, 60, 7 (no log from job 1866691) => 22.5
	2012: ?, 2, 7, 6, 2 (no log from job 1866691) => 4.25
	2013: 73, 411, 70, 204, 178 => 187.2
	2014: 62, 46, 122, 504, 80 => 162.8
* ==> OK, yes, setting adapt_delta to 0.99 does produce fewer divergent transitions than at 0.8 or 0.9, but models run very slowly (some over 2 hours) and still now completely solved. 
* Reverted all local Biocluster changes to run scripts. Next: Look at pairs plots, look for high correlation that could be causing sampler trouble.

## 2016-04-12

Edited mix_crop_tube_depth.stan to precompute centered log depth (log(depth) - log(mean(depth))) in the transformed data block rather than calculate it every iteration. If I did this right, should not change results but ought to produce a small speedup. Considered removing the derived depth_logmean value, but kept it because I use it to calculate predicted totals in teh generated quantities block as well.

Regarding empty log files seen yesterday and earlier: David Slater, cluster admin, says he's not sure what's going on and it "definitely shouldn't do that", but says it might help to explicitly write my output to a log file rather than rely on the `# PBS -j oe` directive, which saves output in the Torque spool and then (supposedly) copies it back to the working directory after the run finishes. Slater says he has occasionally seen this copy time out on very large files (i.e. approaching 1 GB), so it can't hurt to skip it.

Edited currently active Torque scripts (mix_crop_tube_depth_midsummers.sh, mix_crop_tube_depth_sessions10.sh, mix_crop_tube_depth_sessions_12.sh) to write their stdout/stderr output directly to a log file instead of relying on Torque to copy output back from its spool file. I used `2>&1 | tee -a "$PBS_JOBNAME"."$SHORT_JOBID".log`, which ought to copy both stdout and stderr but also still leave them echoed to the console -- so the Torque output file *ought* to exist and be identical to this log. Will see if that's true.

Testing these changes by running midsummers script as job 1867406[]. If I did everything right, the results should be nearly identical to jobs 1865013[] - 1865017[], except with a slightly faster runtime and log files named like 'rz_mctd-*.1867406[*].log' that are character-for-character identical to 'rz_mctd.o1867406-*'.

Results:

* Logs are not identical, because I didn't tee my various `echo` calls. Fixed that.
* Sampling time per chain doesn't seem much faster:
	Centering every iteration (1865013[] - 1865017[] combined)
		2010 275-400ish
		2011 320-600ish
		2012 350-620ish (plus one 1120)
		2013 200-450ish (plus one 750)
		2014 300-900ish
	Precentering (just one run, not five as above)
		2010 258-378
		2011 302-582
		2012 324-488
		2013 209-1359
		2014 271-507
* On token inspection, parameter estimates seem identical (but didn't check every one)

Edited Torque scripts to send their informational messages to the same log as the Rscript output, submitted midsummers script as job 1867574[]. Diff reports all five logs are identical between Torque and piped versions.

Now thinking about the other places I center data in the script. To calculate detection probability, I perform a logistic regression that conditions on mu_obs. This is conceptually sound and comes straight from Sonderegger et al. However, I tried to reduce autocorrelation by centering the regression as

```
mu_obs_mean <- mean(mu_obs);
detect_odds <- a_detect + b_detect*(mu_obs - mu_obs_mean);
```

Notice that this means the centering *changes* as my current estimate of mean(mu_obs) changes! This means I'm introducing a new autocorrelation. I'm not 100% sure I can write out the probabilities to prove it right now, but I *think* the inferred mean/median/mode should be unbiased but I'm inflating my estimate of the uncertainty, because `a_detect` moves as the sampling of `mu` updates.

To fix: precompute a centering point from OBSERVED log root volume, and center the regression on that. Which centering point to use? M How about mean(log(y)) -- that should be equal to mean(mu_obs), right? Well, no -- the zeroes in the data complicate this. Instead, let's take the mean of all observations with positive root volume: mean(log(segment(y, first_pos, n_pos))). This will necessarily be a larger number than the old a_detect because mean without zeroes > mean excluding zeroes, and it makes the interpretation of a_detect even weirder ("log odds of detecting roots at the mean volume of roots we detected"??), but I think it should improve sampling and it's still possible to combine a_detect, mean positive root volume, and b_detect to compute the detection probabilities at ANY root volume.

Tested with midsummers script as job 1867620[]. Seems to do about what I expected. Does not magically fix the divergent transitions.

What if I constrain sig and sigt to be positive? The numbers going into them are already constrained (they're copies of sigma and sig_tube respoectively), but maybe the sampler loses that information somewhere. Changed, tested as job 1867676[]. No visible effect.

Should not affect sampling, but: With my current setup, n_predtubes does nothing but eat memory: All predicted quantities that contain a tube effect use a random draw from N(0, sig_tube) -- in other words, each step of the chain creates an independed newly observed tube. Replicating with more than one tube per crop does nothing but inflate the model output with multiple tubes/locations within tubes that are guaranteed identical within MCMC error. Changed n_predtubes to 4 (i.e. 1 per crop) in mix_crop_tube_depth and I intend to leave it that way. This means rz_pred is only 28 lines long, so changed `*_pred[35]` to `*_pred[28]` in the plotpars_pred list.

Added some easier-to read plots of crop-specific parameters with density estimates, instead of trying to read everything as bars squished onto the same scale as lp__.

Here, finally, is a likely-looking suspect for the cause of the divergent transitions: They only seem to occur in models where sig_tube is pushed way down toward zero in at least one crop, and the parameter-vs-log-prob plots appear to show divergent transitions disproportionately happening when at least sig_tube is exactly on the low boundary of its support. May need to try a hierarchical prior in the hopes of sharing the information that "tube_sig isn't zero" between crops.

## 2016-04-19

Reparameterizing the detection parameters -- I'm tired of them being uninterpretable. Switching from log odds parameters `bernoulli_logit(a_detect + b_detect * (mu_obs - ylog_pos_mean))` to direct specification of the scale and location of the logit: `bernoulli_logit((mu_obs - loc_detect)/scale_detect)`. Interpretation is now simple: We expect to detect roots in half the images when `mu` equals `loc_detect`, dropping to ~5% at loc_detect - 3*scale_detect and rising to ~95% at loc_detect + 3*scale_detect.

Note that I removed the centering on `ylog_pos_mean`. The point of that was to reduce correlation between the intercept and scale terms, and this parameterization already centers itself. There is still some correlation, but seems acceptable to me.

New parameterization calls for updated priors! As before I don't have any solid information about this, so let's keep them very weak.

* For location: We think p(detect | mu < -12) is very low because that's the size of a single pixel in the traced images, and we sure hope that p(detect | mu > 0) is high because that implies the entire soil volume is roots. Let's center our prior somewhere in the bottom half of our detection range, then allow values that more than span it: `loc_detect ~ normal(-8, 10)`.
* For scale: if "detection is low at -12 and high at zero" means the whole range (> 6 scale units) of detection probabilities fits within 12 log units, then scale < 2, possibly << 2 if it's a sharp detection threshold. On the other hand, if meny of the zeroes we see are from heterogeneity within relatively high mean root volumes, then detection probability might be relatively constant across the rangeI don't know. Let's constrain it to be positive and probably less than 12 (we think there'd better be SOME change in detection probability within the visible range): `scale_detect ~ normal(0, 6)`.

(SPEAKING OF constraining scales to be positive, I didn't have a `<lower=0>` on `b_detect` before. Made sure to add it to `loc_detect`, but that probably should have been there all along!).

Pushed these changes to the cluster (commit 3595a32), submitted midsummers script as job 1873540[].

While that runs: Re-set random seed in mix_crop_tube_depth.R so I can compare model changes with the same data. Why do I keep unsetting this?

Results looks OK in terms of detection parameters and do not change other estimates -- including my previously existing issues with unstable sig_tube estimates and divergent transitions.

Next issue: I'm not convinced my parameterization of tube effects makes sense. Currently modeling `b_tube` as a population with zero mean across ALL crops, but variance around zero differing between crops. This means there's nothing to prevent the model deciding that all tube in Miscanthus are on the positive side of the distribution and all Maize tubes are low -- this would shrink the estimated intercept and slope differences between crops, and could also mess with my `sig_tube` estimates: `sig_tube` becomes the expected distance from zero for all tubes in the crop, not the variance around the crop mean.

Let's change `b_tube` to make it have mean zero within each crop. To do this, I added two new vectors to the data block: crop_first_tube is the index of of the lowest-numbered tube in that crop, and crop_num_tubes is the number of tubes we measured in that crop. Then in the model block, I assign all the `b_tube`s in each crop c to have mean 0 and sd `sig_tube[c]`: segment(b_tube, crop_first_tube, crop_num_tubes) ~ normal(0, sig_tube[c]);` This means I can eliminate the `sigt` intermediate vector entirely. Each `sig_tube[c]` still gets its own independent half-normal(0, 3) prior.

Test run on 2013 peak data looks like it makes only a little difference in estimates, but arguably fewer divergent transitions (double instead of triple digits per chain?) I'll keep it.

Okay, what if I add a hierarchical prior on sig_tube? Conceptually, rhizotron tubes have some unobserved population mean and variance, each crop is a sample from that. This sounds suspiciously like it may have the same issues as my previous b_tube parameterization, but let's try it: add parameters `real<lower=0> sig_alltubes` (expection of sigma from the whole population) and `real<lower=0> sig_tubesig` (variation around the expectation between crops), with hyperpriors `sig_alltubes ~ normal(0, 3)` and `sig_tubesig ~ gamma(2, 0.1)` (Recommended as a boundary-avoiding prior for hierarchical variances by Andrew Gelman -- source? I read it on the Stan wiki, but should find better source if this works). Then `sig_tube[c] ~ normal(sig_alltubes, sig_tubesig)`.

Test run does not look promising. Individual sig_tube estimates are essentially identical, hierarchical parameters have about twice the sd of each crop's tube_sigma and are very long-tailed. I don't think this approach is worth it.

OK, let's back up. What we've learned here is that we have consistent compuational issues fitting a model with separate between-tube variance for each crop: The estimates for individual crops go to zero in certain years, and I can't find any way to "trick" the model into changing its mind about that. I suspect that different crops probably DO have different variances -- in particular, row crops usually seem to very more, consistent with the in-row-vs-between-row differences that we know these crops have. HOWEVER: I conclude that we just do not have enough information to estimate these terms well. Let's simplify and fit a model with a single tube variance term that applies to all crops, but keep a varying *residual* variance. Any differences not explained by tube-to-tube differences should translate to a higher residual variance and possibly reduced confidence about the value of the other parameter estimates, but (I think?) no change in inferences about total root volume.

Saving the previously committed unpooled-sig-tube model as mix_crop_tube_depth_foursigt.stan, and my attempted hierarchical version as mix_crop_tube_depth_foursigt_hier.stan (I REALLY need a better naming scheme!). Now let's simplify the existing model:

* Parameter block: redefined sig_tube from an array (`real sig_tube[C]`) to a scalar (`real sig_tube`).
* Model block: Moved prior assigment out of the loop, removed indexing on crop.
* Generated quantities: removed indexing on crop.

Pushed this to cluster, started three runs:

* job 1873783: ..._midsummers.sh
* 1873785: ..._sessions10..sh
* 1873787: ..._sessions12.sh

All jobs exit within 10 minutes, reporting status 0 but many are missing output:

* 1873783-
	* 0 OK
	* 1 six chains OK, 1 with errors (appears to be generating NaNs somewhere?)
	* 2 OK
	* 3 OK
	* 4 "Error in socketConnection [...] port 11572 cannot be opened"
* 1873785-
	* 1 OK
	* 2 data frame error -- right, this is the one that's supposed to throw an error.
	* 3 "Error in socketConnection [...] port 11582 cannot be opened"
	* 4 "Error in socketConnection [...] port 11582 cannot be opened", but then all 7 chains appear to run successfully.
	* 5 OK
* 1873787-
	* 1 OK
	* 2 "Error in socketConnection [...] port 11618 cannot be opened"
	* 3 "Error in socketConnection [...] port 11618 cannot be opened", but all 7 chains seem to run  successfully
	* 4 "Error in socketConnection [...] port 11628 cannot be opened"
	* 5 "Error in socketConnection [...] port 11628 cannot be opened", but all 7 chains appear to run successfully.
	* 6 OK

This looks like a race condition of some kind to me -- multiple jobs competing for the same sockets? Let's try the simplest thing: Resubmit all scripts, waiting a minute in between submissions on the (superstitious) off chance it helps.

Resubmitted: midsummers 1873817, sessions10 1873819, sessions12 1873820.

* 1873817-0 OK
* 1873817-1 6 chains OK, 1 with errors
* 1873817-2 OK
* 1873817-3 OK
* 1873817-4 OK
* 873819-1 OK
* 1873819-2 (bogus session) exits with error as expected
* 1873819-3 exits with socket error
* 1873819-4 exits with socket error.
* 1873819-5 OK
* 1873820-1 OK
* 1873820-2 OK
* 1873820-3 OK
* 1873820-4 OK
* 1873820-5 OK
* 1873820-6 OK

Hmph. Chain errors in midsummer 2011 seem consistent, and socket errors are on same 2010 jobs as before. Let's try once more, submitting 2010 script first: sessions10 1873863, sessions12 1873864, midsummers 1873865.

* 1873863 (2010): -4 fails, -5 contains error messages but seems to run OK, others OK
* 1873864 (2012): All OK
* 1873865 (midsummers): -0,2,4 socket failure. -1 6 chains OK but 1 with NaN in y_pred. -3 OK.

Is the NaN in 2011 something RNG-dependent? Changed first line of mix_crop_tube_depth.R from `set.seed(234587)` to `set.seed(134587)`, submitted midsummers as job 1873997.

* 1873997-0 socket failure
* 1873997-1 socket failure message but all seven chains finish, no NaN errors.
* 1873997-2 OK
* 1873997-3 OK
* 1873997-4 OK

Changed seed back to 234587, ran again as job 1874021.

* 1874021-0 socket failure
* 1874021-1 one chain NaN, others OK ==> Yes, the seed value matters.
* 1874021-2 OK
* 1874021-3 socket failure message but all 7 chains OK
* 1874021-4 socket failure

## 2016-04-20

Still a bit puzzled about socket errors, but the Biocluster admins are on it and I *think* I have working model output from every date. Let's try to plot things more sensibly.

* Combine crop names so that "Maize" and "Soy" plot together in multipanel multi-year views. The best place to do this is actually before the model, in stat-prep.R! OK, fine then. I'm rerunning models again.


## 2016-04-23

To save some time while rerunning, let's dial back some of the massive overkill. I was running 20k iterations because there used to be some highly autocorrelated terms in the model and the sampler was mixing slowly, but a lot of that was from pathologies in the model that I have now removed. Informal tests suggest that my effective sample size is now around 10% of my actual sample size for even the slowest-mixing terms, and 2000 post-warmup samples * 4 chains is already more than enough. So I really do NOT need the giant files and long wait times from 20k*7 samples. Let's pare back in mix_crop_tube_depth.R: Reduced n_chains from 7 to 5 and n_iters from 20000 to 5000. This is probably still overkill, but I do want to make sure I have stable estimates of my confidence intervals.

How about n_warm? Ran 5 test runs with 200, 500, 1000, 1500, 2000 warmup samples. All used 2014 peak data, with 4 chains and 3000 post-warmup samples each.  Posterior parameter estimates only change in lowest digits, and no detectable change in sampler efficiency: I see maybe a *tiny* increase in ESS and reduction in MCSE with warmup >= 1000, but have to squint hard. Plotting sampler params against n_warm, looks like trend is for a very slight decrease in average speed (more leapfrog steps, smaller stepsize, greater tree depth) but lower between-chain variance (shortest warmup has both the fastest and slowest individual chains) as warmup time increases. ==> Let's keep 1000-sample warmup.

Fewer chains means I don't need to reserve as many cores on the cluster, and while I'm at it I've been reserving around 3 times as much memory as I actually use. Changed Torque directive from `#PBS -l nodes=1:ppn=8,mem=7000mb` to `#PBS -l nodes=1:ppn=6,mem=4000mb` in all three recently-used scripts.

Pushed this version to the cluster, ran midsummers as job 1875344, 2010 as job 1875345,2012 as job 1875346. All run in less than 5 minutes and use less than 1.5 GB memory -- including compilation. Hey, these would probably work fine on my laptop!

1875344-0: sampling time 52-80 sec, 3:59 total. ESS of lp__: 2079 (out of 20000)
1875344-1: One chain errors with NaN. Other 4 all within 1 sec of 111 sec sampling time! total runtime 4:39. ESS 4716 (out of 16000)
1875344-2: sampling 75-117 sec, 4:15 total. ESS 4933/20000
1875344-3: sampling 49-73 sec, 3:24 total. ESS 3864/20000
1875344-4: sampling 53-77 sec, 3:30 total. ESS 2497/20000

1875345-1: sampling 47-64 sec, total 3:22. ESS of lp__ 1382/20000 
1875345-3: socket error
1875345-4: sampling 52-78 sec, 3:32 total. ESS 2079/20000
1875345-5: socket error

1875346-1: sampling 56-63 sec, 3:04 total. ESS 3453/20000
1875346-2: socket error
1875346-3: socket error but chains run, sampling 104-107 sec, 4:11 total. ESS 1578/20000
1875346-4: socket error
1875346-5: socket error 
1875346-6: sampling 46-51 sec, 3:04 total. ESS 4867/20000

## 2016-04-25

I'm tired of waiting for cluster runs that are full of errors. Setting up to run everything on my laptop instead.

* New script 'mctd_looping.sh' run the model for each day separately, rather than as a Torque array job, and extracts result summaries using extractfits_mctd.R.
* Removed some of the redundant diagnostic graphs from mix_crop_tube_depth.R: Don't care about posterior mean of lp__, traceplots with inc_warmup=TRUE are mostly uninformative, pairs plots have been commented out for a while, and stan_hist contains pretty much the same information as stan_dens.
* Also changed (print(stan_diag(...))) to stan_diag(...) -- stan_diag automatically plots its result, so the print call was creating extra PNGs of each subpanel that were duplicates of the single three-panel view.
* This gets us down to "only" 16 diagnostic plots from each run.
* extractfits_mctd.R gains an identifier argument, so I can collect result sets without overwriting the summary files.

Deleted `mix_crop_tube_depth.sh`, which hasn't been useful in a long time.
New script `mctd_one_session.sh`, for testing runs of individual days, possibly with subsampling. I've been using an uncommitted version of this for misc. local testing for a while, might as well keep it handy. All input variables are hardcoded -- to use it, change them at will and run it with no arguments.

## 2016-04-30

It's misleading to include S1 2013 and S1 2014 in the 'clean' dataset -- I never really checked either one well and bad frames are not yet censored. Commented them out of the Makefile. This causes several side effects: 
	* Had to adjust labels to remove these sessions from plot-2013.R and plot-2014.R.
	* All rows of stripped2013.csv and stripped2014.csv change, because centering of date and depth change.
	* stripped2014-destructive.csv changes its ImgNotes field from "" everywhere to NA everywhere. This happens because it's generated from the whole-season frametots2014.txt, and ImgComments had some non-null values in the removed session 1 data. Now that it's an empty string everywhere, R reads it as NA instead of as "" and passes that change on to stripped2014-destructive.csv.

One 2012 calibration file is missing from the compiled calibrations, because the script only recognizes files with uppercase extensions. Renamed '08_07.cal' to '08_07.CAL'.

## 2016-05-01

Predicting root mass to 140 cm depth is a bit of an overreach--average deepest observations are more like 120-130 cm: `by(strpall$Depth, paste(strpall$Tube, strpall$Session, strpall$Year), max) %>% plot` shows a VERY strong horizontal stripe at 127 cm (location 110 with typical ~24-mm tube offset) and another at 115 (location 100). Only a handfull of tubes were ever sampled below 127 cam. Let's do all our prediction to 130 cm , not 140.

Question: Why is there so much more maize root in 2014?

* Operator difference? Probably no. EA traced all 2014 frames, and his training images are very near mean of all 11 tracers for length, width, volume. Only operator whose average is notably higher is CRS, he isn't logged as working on 2014 at all.

* Calibration difference? Possibly! PxSizeH seems unusually variable.
	* In most calibrations from 2010-2013, PxSizeH/PxSizeV is around 0.96 ±	0.02, i.e. the images are slightly squished on the Y-axis somewhere in  the optical/image-aquisition/saving/copying-between computers pathway (I don't really know or care where -- that's exactly why we has separate horizontal and vertical calibrations!). There are three outliers in 2012 (0.86, 1.02, 1.03 and one in 2013 (0.93)
	* In 2014, first session ("traced" by me, though mostly not traced at all) PxSizeH/PxSizeV is normal (0.97), then for the six days traced by EA it drops to ~0.93 ± 1 except for one outlier at 0.86 -- lowest ratio seen the whole experiment! -- because PxSizeH is exceptionally low with no corresponding drop in PxSizeV.
	* Opened the three calibration images from 2014 S2 in Preview and calculated my own calibrations using the same method I train all tracers to use: Start at furthest-left fully-visible line, count squares to right until furthest right fully-visible line, PxSizeH = (number 1-mm squares traveled)/(number pixels traveled). Ditto for vertical calibration, from top-fully-visible to bottom-fully-visible. Results:
	```
		    date       EA_H      CKB_H       EA_V      CBK_V
	1 2014-08-13 0.02411576 0.02236422 0.02582160 0.02369668
	2 2014-08-14 0.02161383 0.02011494 0.02341920 0.02093023
	3 2014-08-15 0.02014388 0.02024922 0.02345416 0.02107728
	```
	Hmm. OK, I calculated mine from 14x10 mm = 626x422 px, 14x9 mm = 696x430 px, and 13x9 mm = 642x427 px areas respectively. EA should have used the same -- does ((mm traced)/(mm/px) = px traced) give close to the same pixel dimensions as I traced?
	```
	> c(14, 14, 13) / c(0.02411576, 0.02161383, 0.02014388)
	[1] 580.5332 647.7334 645.3573
	> c(10, 9, 9) / c(0.02582160, 0.02341920, 0.02345416)
	[1] 387.2727 384.3001 383.7272
	```
	Only for the horizontal dimension of Aug 15. But (mm traced+1)/(mm/px) works for the other five!
	```
	> c(15, 15, 14) / c(0.02411576, 0.02161383, 0.02014388)
	[1] 621.9999 694.0001 645.3573
	> c(11, 10, 10) / c(0.02582160, 0.02341920, 0.02345416)
	[1] 425.9999 427.0001 426.3636
	```
	==> I suspect EA counted lines instead of squares (with a miscount on one horizontal dimension)!
	* Let's recheck every calibration image. Copied all 67 calibration images from the whole experiment to my laptopn, opened each in Preview, draw the largest possible rectangle on fully visible gridlines, recorded pixel and mm dimensions, compared my pixel sizes against those used in the current tracing calibrations. Saved this as `notes/cal_check_20160501.csv`. Result: For both horizontal and vertical dimensions, comparing my calibration against the versions as traced gives two distinct lines: Most on the 1:1 line, 8 (horizontal) or 7 (vertical) points above it on a parallel line. My interpretation: Off-by-one errors are the primary source off calibration error. QED.

OK, so bad calibrations do happen. Now to fix them. My approach: Working on the tracing computer, edit existing calibration files to match my measurement, double-checking as I go, load up each tube in WinRhizo with the correct edited calibration, re-save into a fresh data file. Once all looks good, replace old data file with the new one.

Let's start with 2014 session 2 and see if it makes any difference in model results before going any futher. Logged in remotely to imager and:

* edited 
	* `2014.08.13 calibration.CAL` from `2.411576E-002`,`2.582160E-002` to `2.2435891E-002`,`2.35849E-002`
	* `2014.08.14 calibration.CAL` from `2.161383E-002`,`2.341920E-002` to `2.017291E-002`,`2.093023E-002`
	* `2014.08.15 calibration.CAL` from `2.014388E-002`,`2.345416E-002` to `2.023121E-002`,`2.097902E-002`
* Opened WinRhizo, loaded config file
* Calibration > Load Calibration > `2014.08.13 calibration.CAL`
* Data > New File > EF2014_data_recal.TXT
* For each tube imaged on 2014-08-13: Loaded, scrolled through, closed.
	* 1-8, 25-28, 30-32
* Closed data file, then quit WinRhizo.
* Checked git, verified that pat files have only changed in the lines that appear to show calibration values.
* Checked length of `EF2014_data_recal.TXT`. 1193 lines, compared to 1486 lines that contain the string '2012.08.13' in `EF2014_data.TXT`. This seems reasonable, given  the older version contains duplicate lines from some tubes. 
* OK, let's re-export the other two days. Reopened WinRhizo, loaded configuration.
* Calibration > Load Calibration > `2014.08.14 calibration.CAL`
* Data > Open File > `EF2014_data_recal.TXT`
* Oh hey, here are some tubes mislabeled in the analysis log: 
	* T48-T56 and T73 all imaged 8-14 not 15 (Yes, 48 included -- apparently we did one tube of block 4 at the very end of our day of Block 0 images). Fixed all in log.
	* T48 & T49 calibration is listed as "2014.08.15!" Checked current data, T48 shows 08-14 calibration and T49 shows 08-15 calibration. I'm about to replace both of these anyway, so changed both to "2014.08.14".
* Opened each of the following tubes that were imaged 2014-08-14. Did not scroll around, just waited for loading indicator to finish and then clicked load again.
	* 48-56, 73, 75, 76, 78-80

Jumping from imager back to local repo for a moment: While doing this, noticed that T75 L001 has a very large "root" that is really tape. Not currently a problem because the cleanup script is stripping all Loc 1 images, but added it to `censorframes2014.csv` to be safe. ==> Hey, tubes 48-56 and 73 are mis-dated in `censorframes2014.csv` too. These frames were probably not being censored correctly! 

Fixed that and committed those changes now. The diff on `stripped2014.csv` looks usually larger at first glance because the lines are sorted differently. This seems weird, but verified that the new output is in fact identical except for changes to centered date and depth columns and the 8 frames now censored that weren't before.

(Lines below were typed 2016-05-01 but left uncommitted until 2016-05-26)
OK, back to calibration updates. Time to do the 2014-08-15 images, then check how much difference this all actually made.

* Closed WinRhizo, reopened WinRhizo, loaded configuration.
* Calibration > Load Calibration > `2014.08.15 calibration.CAL`
* Data > Open File > `EF2014_data_recal.TXT`
* Opened each tube imaged 2014-08-15. Did not scroll around, just waited for loading indicator to finish and then clicked load again:
	* 33-40, 42-45, 47, 57-58, 61-66, 69-72, 81-86, 89-96   
* Closed WinRhizo.
* Copied `EF2014_data_recal.TXT` and edited calibration files to my laptop for testing.

(2016-05-26: committed all resulting changes from this both here and on the tracing computer)

On my laptop:

* Ran mctd_looping.sh as job 1462157607, With updated censoring but calibrations as before. Only ran a subset of dates: 2013 peak, 2014 peak, 2014 destructive harvest. Really could have just cut it down to 2014 peak alone.
* Moved all derived 2014 data files aside by adding "_origcal" to their names.
* Replaced `rawdata/calibs2014/2014.08.13.CAL` with contents of edited version from imager. Ditto with `08.14` and `08.15`
* Replaced `rawdata/EF2014_peak.txt` with contents of `EF2014_peak_recal.txt`
* Ran `make` to regenerate derived data files.
* Looking at the simple polynomial fits, the peak drops a small amount -- maybe a third of a log unit?
* Ran mctd_looping.sh as job 1462158986, with updated censoring as in 1462157607 plus new 2014 calibrations.
* Only tiny differences in depth profiles and maize profile is still predicted to be way more curved than in previous years. Posterior for crop totals barely changes -- tails pull in slightly, but not enough to change interpretation.

(2016-05-27: More notes typed 2016-05-01 and not committed until now.)
1462201306: All days with updated 2014, so I can compare updated crop total figures

1462205956: All days, simulating 2014 sampling pattern in other years by using *all* tubes from perennials and *only block 0* tubes from Maize-soybean:
```
smallblock_cornsoy = which(rzdat$Species=="Maize-Soybean" & rzdat$Block!=0)
if(any(smallblock_cornsoy)){
	print("TEST RUN: Dropping all Maize-Soybean tubes not in Block 0.")
	rzdat = droplevels(rzdat[-smallblock_cornsoy,])
}
```

1462212776: All days, picking 8 tubes at random from any block of maize-soybean:
```
cornsoy_tubes = unique(rzdat$Tube[rzdat$Species=="Maize-Soybean"])
if(length(cornsoy_tubes) > 8){
	print("TEST RUN: Using only 8 tubes from Maize-Soybean, all tubes from others")
	cornsoy_tubes = sample(cornsoy_tubes, 8)
	drop_rows = which(rzdat$Species=="Maize-Soybean" & !(rzdat$Tube %in% cornsoy_tubes))
	rzdat = droplevels(rzdat[-drop_rows,])
}
```

1462238053: 2012-2 and 2014-2 only, still picking 8 tubes at random but with a more detailed rz_pred depth profile: seq(1,130,length.out=20)
1462238611: ditto, plots changed from smooth to line ==> oops, errors on plotting.
1462239004: Removed "se.fit", rerun
1462240135: split predictive plot fo p_detect out by species
1462240518: rerun with no changes ==> identical output ==> oh right, set.seed. 
1462240855: Commented out set.seed, reran.
1462241220: rerun.
1462241671: rerun.
1462242439: rerun.
1462245398: rerun.
1462245972: rerun.

## 2016-05-13

	1463165173: commented 8-tubes code back out; SHOULD be standard model again, just with random seed turned off

## 2016-05-20

	(noted here 2016-05-27 from memory) Met with Evan, discussed results from earlier in the month. Low tube number in 2014 maize seems to produce unstable total volume estimates: simulating in other years by subsampling down to 8 tubes produces (broadly) similar-looking increases. That doesn't explain high maize root volume in S2 2012, though.

	Tentative conclusion: Drop  total volume estimates, focus on presenting depth profiles.

## 2016-05-27

	Found another typo in raw 2011 tractorcore CN data: sample 4S2 50-100 has lower depth entered as "10" instead of "100". Edited this by hand in the raw CSV. Dear future self: Please make sure to propagate this correction if updating from an upstream source!

	Changing mass-per-area calculations in the tractorcore dataset. From an email I sent to Ilsa on 2016-04-04:

	```
		I also see an issue with the calculations of grams per m2, but it applies to both datasets—we’re both calculating it the same way and my values look similar to yours, but I think it’s wrong: we’re dividing (total mass / three_core_area), which treats every value as the total for the whole layer, meaning in the 50-100 and 100+ layers all the short cores get counted as super-low totals. I guess the easiest fix for this would be to scale everything to its expected layer thickness, maybe something like

		BGB_g_m2 = total_mass_g / (area_per_core*soil_length) * ((lower-upper) / (soil_length/num_cores)),

		with lower for the 100+ layer set to some arbitrary value. Mean achieved depth, maybe?
	```

	The approach still seems sound to me, and mean achieved depth seems like a reasonable value. I'll start by re-adding the `Lower` column (was ignoring it) and setting Lower for the 100+ layer to the mean achieved depth, which I can calculate within the 100+ layer as 100+(soil_length/num_cores)). Calculated one value across all blocks/crops, but separately for each each. Mean maximum depth rounds off to 126 cm in 2011, 128 in 2014. Note that this excludes cores <100 cm deep from the mean of maximum depth, but I feel OK about this -- taking the maximum across all layers gives the same answer:

	```
	(tc
		%>% group_by(Year, Treatment, Block, Sample)
		%>% summarize(deepest=max(Upper + Soil_length/Num_cores))
		%>% group_by(Year)
		%>% select(deepest)
		%>% summarize_each(funs(mean(., na.rm=T), sd(., na.rm=T))))
		# Source: local data frame [2 x 3]
		#    Year     mean        sd
		#   (int)    (dbl)     (dbl)
		# 1  2011 126.0382  9.192149
		# 2  2014 127.6299 11.180606
	```

	Edited tractorcore-cleanup.R to add a Lower column.

	Now implementing the biomass correction. Using close to the same formulation I sent Ilsa, but storing the thickness scaling factor as a column in the data and switching it from a multiplier to a fraction (achieved/target instead of target/achieved), which makes no practical difference in the calculation but makes more sense as a freestanding statistic: "We sampled 85% of the target layer" instead of "the target layer is 1.18x as thick as this sample."

	Met with Evan to discuss figure strategy. Working theory:
		* Two figures of tractor core results, each with four panels: 2011 vs 2014 shown as root+rhizome vs as root only, shown as a depth profile (figure 1?) and as stacked bars with total per m^2 in each layer (figure 2?) Key takeaway: root system continues to grow from 2011 to 2014, winner for total root mass depends whether considering roots or rhizome, difference between years is big in either case (roots grew a lot but rhizomes grew a hell of a lot).
		* A rhizotron methods figure of some kind, probably as a Bayesian network diagram of sorts showing the parameters that go into the model. Highlight the importance of correcting for zeroes and surface effects, show how the curve changes when they're added. Key takeaway: Shows that the model is novel.
		* Rhizotron depth profiles from peak sampling each year. Key takeaway: Roots keep growing, more in perennials, numbers are comparable to core-based methods but higher frequency. Challenge: explain away the discrepancy in 2014 maize profile.
		* Rhizotron depth profiles through the season in 2010 and 2012. Key takeaway: We capture seasonal variation, but there isn't much of it in a mature perennial crop -- even in a drought year. Challenge: Need to figure out how to make these look good. Evan reserves the right to can 2010, or possibly both of them, if the improved figure isn't adding anything to the story.

## 2016-06-05

	Replotted tractor cores results into four-panel figures (roots vs root+rhizome, 2011 vs 2014) per Evan request.

## 2016-06-06

	Overhauled methods: New section describing Stan model, droppped paragraphs about operator agreement and destructive harvest.

	Edits to plotfits_mctd.R to make Stan output figures more comprehensible. Working fast to show everything to Evan this afternoon; plotting contains at least one temporary shortcut: Manually labeled session months in 2010/2012 figures rather than extract/rename them programmatically. Starting point:
	```
	strpall %>% filter(Year==2010) %>% group_by(Session) %>% summarize(min(Date), max(Date))
	#   Session  min(Date)  max(Date)
	#     (int)     (date)     (date)
	# 1       1 2010-05-27 2010-05-28
	# 2       3 2010-07-22 2010-07-26
	# 3       4 2010-08-12 2010-08-18
	# 4       5 2010-10-07 2010-10-15

	strpall %>% filter(Year==2012) %>% group_by(Session) %>% summarize(min(Date), max(Date))
	#   Session  min(Date)  max(Date)
	#     (int)     (date)     (date)
	# 1       1 2012-05-21 2012-05-23
	# 2       2 2012-06-05 2012-06-08
	# 3       3 2012-06-20 2012-06-22
	# 4       4 2012-08-02 2012-08-07
	# 5       5 2012-08-29 2012-08-31
	# 6       6 2012-10-22 2012-10-26
	```
	Rounded S1 2010 as "June" and S3 2012 as "July"; would probably be better to identify as month-day or as DOY.

	N.B. updated Pandoc to version 1.17.1 and pandoc-crossref 0.2.1.3 at some point in here; did not record whether before or after compiling the version I showed to Evan. Oops. Note that this means I'm now using the stock version of pandoc-crossref, not the hacked-together version (git branch named "supplemental") I was using for my T-FACE paper. This doesn't matter yet, but should make it easier to add supplemental figures if/when I need them.

## 2016-06-10

	Trying a modified Stan model: Rather than assume surface effect is constant for all four crops, estimate four separate loc_surface and scale_surface parameters. Still using the same prior for all, but no pooling -- each one is estimated only from that crop's data.

	rz_mctd_1465577918 runs mix_crop_tube_depth_foursurf.stan, which allows loc_surface and scale_surface to vary between crops. Some divergent transitions in 2010 (S1,4,5) & 2012 (S1,4,5,6), other years OK.

	rz_mctd_1465583014: reran with adapt_delta set to 0.99. Many fewer divergent transitions, but still a few in 2010 (2 in S1, 59 in S5) & 2012 (45 in S1, 1 in S6). Tiny changes in posteriors from previous run -- suspect it's not exploring the tails well? But all midseason sessions are OK, and posteriors all look good even in sessions with divergent transitions.

	In both runs, posterior invervals on loc_surface and scale_surface get MUCH larger than in pooled version, as expected. But estimated density profiles look MUCH more reasonable -- no runaway maize in 2014! -- and uncertainty on predicted depth means is about the same. Keeping this version.

## 2016-06-11

	Found error in the tractorcore plots: I'm plotting root C, not root biomass. Fixed that.

	Committed some changes to extractfits_mctd.R that I apparently made a while ago: Now writes separate CSVs for most parameters that differ between crops (but not for surface effect -- that's still rolled into the same file as the one-value parameters. Maybe change this eventually?)

	Committed the changes I made to plotfits_mctd.R on 2016-06-06, like I thought I had before.

	Committed changes I made to mix_crop_tube_depth.R... long enough ago I'd forgotten I made them? Jeez, Chris. 

		* generate pred_depths as an evenly spaced sequence instead of hardcoded values
		* break plots of pred_pdet (i.e. chance of detecting >0 roots in an image) out by species
		* draw predicted depth profiles of root volume and pdet using geom_line, not geom_smooth

## 2016-06-12

	Finally wrote up proper stats on tractorcore results and used them to start manuscript results. Script: `scripts/tractorcore-stats.R`. Output: `data/tractorcore_stats.txt`.

	Experimenting with a different parameterization of surface effect: I wonder if some of the difficulty with fits has to do with the surface effect not really being sigmoid. As you approach the surface, the slope of the underdetection factor should probably continue increasing, not level off. I had been expecting that loc_surface would often be negative (i.e. more than half the roots detected near the surface), and therefore that the left tail of the logistic wouldn't be an issue, but the model seems to disagree -- not only is log_surface usually positive, but when it gets close to zero it seems as if the sampler likes to stick at zero rather than cross it. Rather than a logistic function with an inflection point in the middle of the range, let's try an exponential function. First try: a monomolecular growth function. Tried several formulations: 
		* Monomolecular exponential, growth curve flavor: y_obs = y * (1-(1-a)*exp(-2.3*depth/b)), where 0<a<1 is fraction of true mass detected at the soil surface and b is the depth where detected mass = 90% of true mass (hence the constant: when depth=b, 1-exp(-2.3)~=0.9). 
		* Monomolecular exponential, simple curvature flavor: y_obs = y * (1-(1-a)*exp(-b*depth), where a is the same as above and b is a rate constant that I'm not sure how to interpret.
		* Michaelis-Menten with intercept offset: y_obs = y * (a + (1-a)x /(b + x)). Worth noting the derivation: A standard Michaelis-Menten has an intercept of 0, a specified asymptote at a, and a half-saturation point of b: y = ax/(b+x). Then setting the aysmptote to 1, offsetting the whole equation by an intercept term, and repurposing "a" from asymptote to intercept, gives a + (1-a)x/(b+x). Note that b stays in place but its meaning has changed from "x where y is half of saturation" to "x where y has gone halfway from the intercept to saturation."
		* Michaelis-Menten with intercept offset and redefined half-saturation: y_obs = y * (a + (1-a)x / (b'/(1-2a) + x)), where a is again the fraction detected at the surface and b' is the depth where 50% of roots are detected. I derived this by setting y equal to 0.5 and solving for x = b - ab/0.5 (Algebra not shown, but check my work!). Then b' is b'=b/(1-2a) . Therefore y = a + (1-a)x/(b'/(1-2a)+x) is a Michaelis-Menten curve from 0<a<1 at x=0 to to 0.5 at x=b' to 1 at x=infinity.

	Tried these all in a row without committing the changes; the Stan edits involve scale_surface and loc_surface parameters (horribly misnamed for any of these definitions of a and b, but using these names rather than rewrite downstream code): Lines changed are parameter declarations (change constraints), mu_obs(from mu_obs[n] <- mu[n] + log(inv_logit(...)) to mu_obs[n] <- mu[n] + log(the_formula)), priors, generated quantities (same structure as mu_obs). Basic takeaway: All seem to run OK, produce fewer runaway totals than logistic does, and Michaelis-Menten may possibly have fewer numerical issues than others, but all produce really funky-looking total predicted masses and insist that b_depth is positive in all crops in midsummer 2012. Giving up on these for the moment.

## 2016-06-23

	Just sent Evan a draft of methods/results/figures for the paper from this project. The last few days I was "mostly writing" but wound up making a whole rash of code changes that were supposed to be "quick tweaks: that  I would "commit in a second after I test this", and now my working directory is a trash fire. Time to work through, commit changes, and see if I broke anything :)

	* Added error bars to tractorcore-bars.png.
	* Added stacked barplots of core biomass (previously only shown as biomass C). Keeping the C plots as well, for now, but not sure I'll need them -- This is really not a carbon paper!
	* Added to plotfits_mctd.R: plots of fit quality for each individusl (session in year) model. Wrote this before adding whole-dataset residual plot (below) and robably won't use these much, but keeping it for now anyway.
	* Added massive residual plot of observed-vs-predicted for all individual images... OK, all individual images traced as *nonzero*.
	* Renamed annual crop for single-year 2010 and 2012 plots from "Maize-soybean" to "Soybean" and "Maize" respectively.
	* Replaced log(inv_logit(...)) with Stan's built-in (and suppedly faster/more stable/better tested) log_inv_logit(...). Made this change in all Stan files that use it, but only tested in mctd_foursurf.stan!
	* Added to mctd_foursurf.R and mix_crop_tube_depth.R: Observed-vs-predicted plots for images within each run, facetted by species.
	* Edited posterior density plots to show separate lines for each chain. If they disagree substantially, that usually means you have numerical problems.
	* Cleanup in all the bash scripts: Realized I could put the whole contents of the for-loop inside one single subshell (...\n ...\n ... | tee ...) instead of piping every line out individually ( (...| tee ...); (...|tee ...) ) like I had been doing.
	* New figure comparing 2011/2014 tractor cores against Stan predictions from the same day. Going with overlaid lines, not an actual MR-vs-cores regression. As I *think* I've noted before, my conversion taken from generic literature values is: (mm^3 root mm^-2 image)/(0.78 mm^3 soil mm^-2 image)*((x g root cm^), where x equals
		- 0.08 for maize
		- 0.20 for Miscanthus
		- 0.19 for Switchgrass
		- 0.15 for prairie.
	See notes/unit-conversions.txt for details and citations.
	* Script usage for the stan-vs-core plot: $(Rscript scripts/plot-stan-vs-core.R path/to/predmu2011-s4.csv path/to/predmu2011-s2.csv)... which is kinda ridiculous once I think about it because it means the path to the tractorcore data is hard-coded in the file but the path to the Stan data isn't. TODO: decide for real where Stan output lives, and fix this.

## 2016-06-29

	Overhauling manuscript draft. Added skeletons of intro and discussion (Think I like the topic sentences, but all paragraphs need more detail, and no citations at all yet)

	Plotting tweaks:
		* crop names instead of numbers in parameter plots. This means 2012-s6 error bars are no longer one panel over from their matching crop in other days.
		* Much simpler legend in parameter plot
		* Standard axis notation: "variable (units)", not "variable, units"
		* Standardize on "ln(...)" not "log(...)". Feel ambivalent about this, may revisit it later. But I'll change all of them if I change any!
		* Removed plot titles.
		* For depth plots and parameter plot, moved legend inside frame of plot.
		* Plot parameters by date rather than by paste(Year, Session), and identify sessions in depth plots by date rather than manually assigned month.
		* N.B. All Stan plots are currently made from run rz_mctd_1466393993. Still no output committed into Git; really need to fix that soon.

	Bunch of typo fixes & rearrangements, not itemized here.

	Edits to to results and discussion per EHD comments on 20160623 draft. Mostly rearranging results to put biology before stats.

	Sent this draft to Evan, asked mostly for his thoughts on whether intro and discussion structure make sense before I expand them.

## 2016-07-15

	Expanding intro and discussion into complete paragraphs. Here, have some notes about root masses previously reported for comparable crops:

	Monti 10.1016/j.agee.2009.04.007
		5 yr old stand, sampled to 1.2 m
		mxg root 7596 kg ha = 760 g/m2
		switch 8522	= 852
	Dohleman 10.1111/j.1757-1707.2011.01153.x
		5-7th yr stand, sampled to 1 m
		mxg rhizome 21.5 t ha = 2150 g m2
		switch rhizome 7.2 t ha = 720
		both roots 5.6-5.9 t ha = 570
	Christian 10.1016/j.biombioe.2005.11.002
		3 yr old stand, shovel to 24 cm, then core to 50
		mxg rhizome 10 t ha = 1000 g/m2
		mxg roots 2.2 = 220
	Neukirchen 10.1016/S1161-0301(99)00031-3
		4th year stand, measured to 180 cm
		mxg roots 13898 kg ha = 1390 m/m2
	Amougou 10.1007/s11104-010-0443-x
		2-3rd yr stand, sampled top 30 cm
		mxg rhizome 10-17 t ha = 1000-1700 g/m2
		mxg root 1.3-1.9 t ha = 130-190
	Beuch 10.1046/j.1439-037x.2000.00367.x
		4-8th yr stands, measured to 40 cm, 40 cm assumed to contain 35.9% of roots
		mxg rhizomes 11-18 t ha = 1100-1800 g/m2
		mxg roots  2.2-7.4 = 220-740
	Bransby 10.1016/S0961-9534(97)10074-5
		4yr old stand, measured to 75 cm
		switch roots 6242 kg ha = 624 g/m2
	Collins 10.2136/sssaj2010.0020
		3 yr old stand, measured to 90 cm
		switch root 10.2 Mg ha = 1000 g/m2
	Frank 10.2135/cropsci2004.1391
		3 yr old stand, to 1.1 m
		switch root 6540-7670 kg ha = 654-767 g/m2
	Garten 10.1016/j.agee.2009.12.019
		4 yr old stand, to 90 cm
		switch rhizome 299 g/m2
		switch root 1485
	Brye and Riley 10.1097/SS.0b013e3181a93daa
		3,4,5,26 yr old stands + native remnant, sampled to 15 cm
		Probably not usable because root mass reported in "kg/m3" -- actual reading is probably 0.15 of this?
		prairie root 3-6.5 kg/m3, no huge differences but 3-yr is lowest, native remnant and 4-yr both at high end, 26-yr more like native and 5-yr more like 3-yr
	Jelinski 10.1111/j.1526-100X.2009.00551.x
		to 50 cm
		prairie root 720 g/m2 restored 7 yr old, 1670 remnant 
	Kucharik 10.1111/j.1365-2486.2005.01053.x
		to 50 cm
		prairie root remnant 1736-3029 g/m2, restored (65 yr) 1690-2141
	Matamala 10.1890/07-1609.1
		3, 7, 8, 15, 18, 21, 23, and 25 year old
		to 1 m
		hand sorted, "recovered about 60% the root mass that would have been obtained by washing"
		remnant prairie ~1.2 kg/m2 = 1200 g/m2, restored, ~0.3-0.8 =300-800 g/m2

	Committed ~full, but still rough, drafts of intro and discussion. Lots of new citations, hopefully more biologically intelligible discussion of root mass.

## 2016-07-18

Working on (finally!) adding Stan runs to main project Makefile. This will require some script modifications, because right now all output is named by timestamp. Let's work our way forward through the pathway:

	* Modified mctd_foursurf.sh to take two command-line arguments: runname and output directory. If empty, runname defaults to "rz_mctd" plus the current Unix timestamp as before, and output directory defaults to "./stanout". !!Output directory is overwritten if it exists!!

	* Added Make rule with entire data/stan/ directory as a single target and a prerequisite list containing data/stripped*.csv and all scripts called (by scripts called by...) mctd_foursurf.sh. This means every Stan model must be rerun any time I update any of the chain! This whole pipeline needs to be broken up more, but not right now.

	* Paths in scripts/stat-prep.R and stan/mctd_foursurf.* changed to be relative to project root instead of relative to the Stan directory.

	* mctd_foursurf.R gains an output_path argument.

	* extractfits_mctd.R is already directory-agnostic, but renamed arguments to make that clearer.

	* Modified mctd_foursurf.sh to pass output directories in the paths passed to mctd_foursurf.R, extractfits_mctd.R, and to write *.log into output dir instead of cwd.

	* Modified scripts/plot-stan-vs-core.R to pass all filenames as arguments instead of hard-coding them, added it to Makefile.

	* Added stan/plotfits_mctd.R to MAkefile. It works with no change! But the CSV read-in section was intended to handle multiple files per run, and is now a set of elaborate list-read-rbind loops each of which iterates over one single CSV. Did not change that, but did add comments for my confused future self who wonders why it's done this way.

I think this now means the selected best-fitting Stan model (but none of the alternative models) is fully incorporated into the Makefile and will update automatically. Current full Stan run takes a bit over an hour on my laptop and produces roughly 770 MB of Rdata files, plus 51 MB of diagnostic PNGs -- do I want this in the Git repo? 

I suspect I will want them saved eventually -- or at least I'll want to save *some* representation of the posterior samples -- but I think I'll punt on that for now. Added the summary figures and extracted CSV output to Git, will think more about when/how to add larger files.

## 2016-07-19

Committing an old experiment I've had lying around for a while: My calculation of total root volume takes the integral of expected root volume across the whole depth profile, in the form

	```
	integral[p,q](exp(a+b*log(x))) dx = exp(a) * (q^(b+1) - p^(b+1))/(b+1),
	```

which is undefined (division by zero) when b == -1. Since -1 is within the estimated range of b_depth in most fits, this generates occasional NaN warnings from the generated quantities block when the sampler hits within float error of 1.0. To avoid this, note that when b = -1 the integrand reduces to

	```
	exp(a + b*log(x))
	= exp(a + -1*log(x))
	= exp(a - log(x))
	= exp(a) / exp(log(x))
	= exp(a) / x
	==> integral[p,q](exp(a)/x)) dx
		= exp(a) * integral[p,q](1/x)) dx
		= exp(a) * (log(q) - log(p)).
	```

Let's take this a step further and switch our integration starting point from 0.1 cm to 1 cm (= 0 on the log scale). Then log(p) is zero and this further simplifies to `exp(a) * log(q)`.

Edited the generated quantities section of mctd_foursurf.stan to put both `crop_tot` and `pred_tot` inside if statements to compute the expectation as

	```
	crop_tot[c] <- exp(intercept[c] - b_depth[c]*depth_logmean) * log(depth_pred_max);
	```

for individual posterior draws where `b_depth == -1.0` and

	```
	crop_tot[c] <- exp(intercept[c] - b_depth[c]*depth_logmean)
				* (pow(depth_pred_max, b_depth[c] + 1.0) - 1.0)
				/ (b_depth[c] + 1.0);
	```

otherwise. Recall that `intercept[c] - b_depth[c]*depth_logmean` is just to recover the intercept from "expectation at mean depth" to "expectation at log(depth) = zero", i.e. 1 cm.

Test runs confirm that the if statement itself makes no difference in inference: Most chains are binary indentical, as you'd hope given the NaNs were relatively rare in the first place. May slow runs down a tiny bit (6-8 seconds per chain in runs that take 3-5 minutes), but not enough to matter.

Switching the integration start point DOES make a difference, though -- many fewer ridiculously-large total values when integrating from 1 cm than when integrating from 0.1 cm. This is a bit of a judgement call given that I'm fundamentally modeling a function that goes to infinity at zero, but 1 cm seems like the "most natural" cutoff. Keeping these changes.

## 2016-07-31

Stan development team announces that Stan 2.10 contains a subtle bug that biases the HMC sampler and produces veeery subtly wrong distributions. They advise upgrading to Stan 2.11 immediately and not trusting any output from Stan 2.10. Reran all models and committed result, no other changes. 

While I'm at it: the'<-' assignment operator is deprecated in favor of '=' since Stan 2.10. Changed it in all my Stan scripts and reran again.

## 2016-08-05

Updating install/run instructions per suggestions from David LeBauer: Have Make generate a tmp directory if it doesn't exist already, list all dependencies in README, document the steps of the analysis.

Also, fixed some stray commas in `rawdata/censorframes2012.csv`.

## 2016-11-15

Working toward a formal analysis of prior sensitivity. First step: rewrite to pass priors as data rather than hard-coding them in the model. While I'm at it, rewrote prior assignments that were within a loop over crops, e.g. `for(c in 1:C){b_depth[c] ~ normal(-1, 5);}` as vectors (`b_depth ~ normal(b_depth_prior_m, b_depth_prior_s)`). Last time I revisited these I was still confused by the sampling notation and thought I needed to assign them separately to make sure each crop's prior was "drawn separately from the distribution." To convince myself this was wrong, I had to consider the equivalent incrementation syntax, which is what Stan is doing under the hood: `target += normal_lpdf(b_depth | -1, 5)` makes it clear we're just computing a log density that depends only on the current value of b_depth.

Edited extractfits.R to save prior list into same CSV as posterior parameter estimates. Used the change to refactor the rest of the parameter saving code -- now uses a dplyr pipeline for easier reshaping and stores crop and parameter names in separate columns. This should make it much easier to improve the parameter intervals figure (`stanfit-params.png`) when I get to that.

Changed model to reduce unused variables by editing Stan code from assuming ascending order (all zeros at the beginning) to assuming descending order (all zeros at the end) and therefore not storing `sig` for zero values. Also now generating `y_logi` and `n_pos` in transformed data block -- no need to pass them as data. Appears to give about a 20% speedup on 2010 data, but did not rerun for all days yet.

## 2016-11-20

Changing strategies for model-vs-tractorcore plot. Since predicted values in `predmu.csv` are not block-specific, better to take expected values from individual images in `obs_vs_pred.csv` and average them by block and depth range. This will ignore simulation uncertainty (especially since I extract individual `mu_hat`  using rstan's `get_posterior_mean` function and do not track their full posterior distribution), but should capture the block effects, as encoded in variability between tubes, and lets me regress obs vs pred on more than five data points in each crop/year. 

## 2016-11-21

Overhauling parameter plots. Goals: Put crop-specific priors together as rows of panels, show priors at left edge for reference, give user-friendly parameter names, show units for all axes.

* Crop specific priors together: Create one plot of all crop-specific params (every line where crop name is not NA), facet by parameter and crop, then plot the three parameters common across crops (`sig_tube`, `b_detect`, `a_detect`) as separate plot, facetted only by parameter and all on one line. Then assemble both into one figure using cowplot::plot_grid. Had to experiment manually to find the correct relative rowheights so that the panels in both parts of the plot are the same size; `rel_heights=c(3, 1)` seems to be about right.
* Show priors: Added another geom_pointrange call with x aesthetic set to 60 days before the first sampling day and y aesthetic taken from prior mean/sd column, then manually mapped colors to make prior bars grey and posteriors black. This does mean that parameters with priors much wider than posteriors are now hard to read, but arguably this is the crrect interpretation -- "Posteriors are WAY narrower than priors, maybe you should admit you actually started out knowing more than you're letting on?"
* User-friendly parameter names: Added a new column to the dataframe defining symbolic parameter names in unparsed expresion string form (e.g. `"b_depth"="beta^depth"`), passed these to facet_grid instead of plain parameter names along with `labeller=label_parsed`.
* Show units: there's no easy way to give separate y-axis labels for different rows of a facet_grid, so worked around it by removing them and making the facet strip labels *look like* y-axis labels: Set ylab="", added unit annotations to the parameter name expressions and formatted to appear on a second line (e.g. `"b_depth"="atop(beta^depth, (ln~mm^3~mm^-2~ln~cm^-1)"`), moved row strips to the left edge (`switch="y"`), removed strip background (`strip.background=element_blank()`), and set strips to be outside axes (`strip.placement="outside"`). Since the parameters that do not vary by crop have their strip labels on the top instead of the side, I just left them labeled on top -- they fit better that way and help make it more clear that the three bottom panels do no go in any of the crop columns above them.

## 2016-12-05

Done since last posting: deposited dissertation, circulated 20161128 manuscript draft for coauthor edits, incorporated changes, sent to Evan for submission to Ecological Applications. See commit logs for those changes, mostly minor. But a big change, as suggested by David LeBauer: instead of declaring parameters "not different" because their separately-calculated uncertainty intervals overlap, need to actually test whether the uncertainty for the *difference between them* includes 0. New script `plot_chaindiffs.R` does this in possibly overkill fashion, by loading up huge dataframes of every HMC draw for each parameter of interest and computing quantiles/saving violin plots of the differences between samples between model runs. The idea: If `icpt_a` are 20000 validly drawn HMC samples from the posterior distribution of the intercept term in session 4 2010 and  `icpt_b` are 20000 validly drawn HMC samples from the posterior distribution of the intercept term in session 2 2014, then if `quantile(icpt_b - icpt_a, c(0.025, 0.975))` does not include zero we can say that we're 95% certain the intercept changed between midsummers 2010 and 2014. Reworked results to rely heavily on this, added three new supplementary figures showing differences between selected model runs for total root volume, slope term, and intercept.

## 2016-12-07

Manuscript was submitted by EHD on 2016-12-05. Tagged the current version (same contents as used in final submission) as `ecolapp_sub1` for easy reference by reviewers, and now doing some README cleanup:

* Renamed ReadMe.txt to Readme.md, formatted as Markdown, edited for clarity and to match current project layout.
* Added a note indicating that the manuscript is submitted and pointing toward the tagged release.
* Clarified that `operator-agreement/Makefile` is incomplete and documented what I did to get the numbers in the manuscript.

## 2017-01-12

Manuscript was desk-rejected from Ecological Applications. Preparing to resubmit to Plant and Soil with minimal changes:

* Reran model under Stan 2.14 to ensure results aren't affected by a variance bias in previous versions of the NUTS sampler (see [https://github.com/stan-dev/stan/issues/2178]). Result: Only a few tiny changes in tail length.
* Added a model optimization as long as I'm rerunning: All functions I use in the transformed parameters block of `mctd_foursurf.R` are now capable of working on vectors, meaning it's now possible to eliminate the assignment loop over individual elements of `mu` and `mu_obs`. This improves runtime by about 20% -- from 1 hour 20 minutes for a full run down to an hour even!
* Cleaned up generated quantities block for readability and to match model block.
* Makefile complains that it has "no rule" to make `data/stan/*.Rdata`, despite their existing and being listed as prerequisites for all the `plot-chaindiffs.R` outputs. Guessing this is a weirdness of Make not expanding globs the way I think... No idea why this worked in November but not now. Anyway, fixed by replacing `data/stan/*.Rdata` with `$(wildcard data/stan/*.Rdata)`.
* Updated sampler produces slightly shorter tails on the between-year differences in `stanfit-croptot-endyears.png` -- highest point in the Switchgrass violin now goes to 124.8 instead of 135, Miscanthus now ~35 instead of ~45. Moved the y limits in from 55 to 40 for slightly better visibility of the other violins.
* Committed new versions of figures and data.

## 2017-01-13

* Copied updated figures into manuscript directory. Note to self: Next project, don't duplicate figure storage like this.
* Deleted unused images in manuscript image directory (all have long since been replaced by better versions): `coreC.png`, `mass_vs_rhizo.png`, `peak_yearly.png`, `seasonal.png`, `volbyimg.png`.
* Added `tractorcore_stats.txt` to Makefile (previously missing).
* Edited `tractorcore-stats.R` to set lsmeans degrees-of-freedom method: Was Kenward-Roger by default in lsmeans <= 2.23, but changed to Satterthwaite in lsmeans 2.24. I want K-R, so added `lsm.options(lmer.df="ken")` to re-enable old behavior. 
* Tweaked plotting of stanfit-params.png: Better dimension calculations, less ridiculous page size (now plotting at 1.5x final size instead of ~2x), more readable labels. 
* Edited figure caption for `croptot_peak.png`: cut-off tail of Switchgrass violin now extends to 'only' 124.8, not 135.

OK, now finally making changes that are specific to Plant and Soil journal style:
* Added addresses to author affilitations
* Moved keyword section to come before abstract
* Cut keywords from 9 to 5 ("4 to 6" allowed) -- Assuming indexers will pick up species names from the abstract.

## 2017-01-19

* Trimmed abstract down to 200 words and separated into four sections
* Converted reference list style to Plant and Soil (AKA generic Springer) style. This required adding abbreviated journal names and finding DOIs for a few refs that didn't have them already.
* Renamed methods section to "Materials and Methods"
* Removed puntuation from ends of all figure caption (Really, editors??), set "Fig. n" caption prefix to boldface.

Also added a few more updates that are not strictly for journal style:

* Updated references and in-text mentions to use current software versions
* Updated reported half-detection depths reported in results -- I haven't updated these since the 2016-06-23 draft! The code I used to find current values:
	```
	(read.csv("data/stan/params_current.csv")
	%>% filter(parameter=="loc_surface")
	%>% group_by(crop_name)
	%>% select(estimate)
	%>% summarize_each(funs(min, max)))

	# Adding missing grouping variables: `crop_name`
	# A tibble: 4 × 3
	#       crop_name       min      max
	#          <fctr>     <dbl>    <dbl>
	# 1 Maize-Soybean  6.941290 33.32262
	# 2    Miscanthus 10.340915 24.83184
	# 3       Prairie  9.502021 26.17084
	# 4   Switchgrass 13.688185 35.68694
	```
* Added citation of Hall and Sinclair 2015 ("Rooting Front and Water Uptake: What You See and Get May Differ", Agron J) to discussion, to reinforce the notion that rooting depth doesn't guarantee useful water extraction.

## 2017-01-22

Sent updated manuscript to Evan for submission to Plant and Soil.

## 2017-02-16

Evan submitted manuscript on 2017-02-02, but Plant and Soil manuscript processing system seems to have mangled equations containing mu-hats. I *hope* I fixed this by editing the hats from U+005E (what appears in a Word equation generated by Pandoc from the markdown "$\hat\mu$") to U+0302 (what I get by typing "\mu\hat<space><space>" directly into a Word equation box). Full changes below, but first a note about line numbering. Line numbers in the mangled PDF-as-submitted (PLSO-D-17-00175(3).pdf, "PLSO pdf" below) differ from those I see in the submitted Word document AND those I see in the Word document differ from those I see when I save it to PDF:

* My PDF does not number lines occupied by display equations, PLSO pdf does, Word version does but with bugs. In Word version, lines are numbered with equations included and look correct on that page, but all lines beginning on the page AFTER an equation are numbered as if the equation were unnumbered. Concrete example: Equations 1-3 are lines 216-218 on manuscript page 10. Word and PLSO pdf both show page 10 as lines number 213-235, but then page 11 is lines 236-258 in PLSO pdf and 233-255 in Word... including equations 4-5, which make page 12 be numbered as lines  254-272 (compared to 259-277 in PLSO pdf), and so on.
* This means line numbers in the saved PDF always *start* the page agreeing with Word version and only disagrees for the remainder of any page containing equations, while PLSO pdf numbering drifts further from my versions as manuscript progresses and ends 7 lines out of sync (yes, there are seven display equations). Last numbered line (header for "Appendix: Supplemental figures", p. 42) is 744 in PLSO pdf, 767 in Word and my PDF.

Full changes (Line numbers refer to PLSO pdf):

* To fix PDF conversion, I made the following format changes:
	*  line 41, 143, 180, 181: Crosses misaligned in "Miscanthus x giganteus" and dimension listings
		- Fixed by inserting a cross character (U+00D7, "MULTIPLICATION SIGN") instead of inline equations.
	* 170: Whole equation sits above baseline, some letters inappropriately bolded: "s" of "cos" and "8" of "5.8".
		- Fixed by rendering as text not equation.

	* 252, 737, 755, 756,: mu-hat misrendered -- shows as [empty square]^mu.
	* 253, 264: mu-hat_ijk misrendered -- shows as [empty square]^mu_ijk.
	* 262 (eqn 6), 265 (eqn 7): mu-hat_ijk misrendered -- shows as hatless mu over ijk.
	* 743: p(detect|mu-hat, alpha^detect, beta^detect) misrendered as p(detect|^mu, alpha^detect, beta^detect).
		- All of these fixed -- I hope! -- by changing equations to use a different hat character (U+0302, "combining circumflex accent" instead of U+005E, "circumflex accent").
	* 262, eqn 6: Right-parenthesis is misplaced: should be smaller and on second line after "sigma^2", not at end of equation.
		- **No changes made** -- I do not see anything in my manuscript file that could produce this error. Was the equation reset by hand at some point after upload?

*  In addition, I have fixed the following typos:
	* 173, 174: Replaced "x" in dimensions with crosses.
	* 129: Inserted missing "were" after "soybeans".
	* 231: Inserted missing "r" in "corection".
	* 235, 253, 262, 265 (eqns 4-7): Removed punctuation around equations to avoid confusion with preceding subscripts.
	* 240: Inserted missing "i" in "coefficents".
	* 726, 729, 735, 741, 743, 753, 760, 773: Inserted missing space in ",ln"
	* 755: Replaced "<=" with "≤".
	* 756: Replaced ">=" with "≥".

## 2017-06-23

Manuscript is accepted pending minor revisions. While checking over scripts, found a typo: Prior for `scale_surface` was being set to 13±10 (the prior for `loc_surface`) instead of 6±5. Fixed and reran Stan models; very little change in most results, but some welcome shortening in the right tails of each crop's scale_surface posterior, and consequently fewer extreme high outliers in the estimated year-over-year change in total switchgrass root volume.  

Minor script updates to support dplyr 0.7: 

* `plot_chaindiffs.R`: `do()` now requires multi-column results to be a tbl wrapped in a list. N.B. Only reason I'm using `tibble` rather than `data.frame` here is that tibble doesn't check/mangle column names like "5/21, 6/06" to "X5.21..6.06".
* Not dplyr-related, but while I'm at it: The plotting code for `stanfit-croptot-endyears.png` contains hard-coded margins to cut off the above-mentioned long tail of the change in switchgrass root volume. Values are still OK for current output, but could easily be inappropriate if estimates change more. Don't want to mess with automatic calculation today, but added a warning to alert the user if the range of the dataset changes.
* `scripts/tractorcore_stats.R`: `summarize_each` is deprecated in favor of `summarize_at` and `summarize_all`. Results are identical to previous version.

Updated operator-agreement directory:

* Added the main analysis script to the Makefile (previously missing and had to be run by hand).
* Deleted old copies of data files and images/text outputs from old exploratory analyses.
* Excel workbook `allfiles.xls` is left over from my inefficient image selection process, and `blank-id.xlsx` and `idKey.csv` are from abandoned preliminary analyses. All the useful information from these is now summarized much more neatly in `img_id.csv`, with the exception that `idKey.csv` contains the actual filenames of the image files where `img_id.csv` only identifies them by tube and location. Added the filenames to a new "assigned_imgname" column of `img_id.csv`, deleted `allfiles.xls` and `blank-id.xlsx` and `idKey.csv`.

## 2017-06-25

Rewrote `scripts/simrhizo.r` to include surface and detection effects, renamed to `simdat.R`. Added a complete script that uses it for testing the model, complete with diagnostic plots. Hooray, the model recovers known parameters well!

Updated .gitattributes file so $(git diff someimage.png) shows a visual diff. This requires ImageMagick, Preview.app on OS X, and a script not commited here which displays a triptych of old image, red-highlighted differences between old and new, new image.

Addressing reviewer comments:

* Added phrasing about interannual and seasonal variability to abstract
* Clarified that 2014 Miscanthus obs were averaged across N treatments because we didn't collect enough data to look at it, and we are NOT claiming the N treatment had no effect.
* Fixed symbol typos:
	- one in-text reference to surface params in results used a/b instead of alpha/beta
	- Deleted epsilon from eqn 4 (#eq:rzmu) -- this equation is an expectation, not a full regression model! No residual term is needed.
	- Changed discussion of "epsilon" in priors.md to "sigma" -- this *is* the residual term of the model, but I call it sigma everywhere else in the paper and it gets used in scale parameter context way more than residual term context.
* Added a graphical illustration of surface effect (replotting Bragg et al. table 1)
