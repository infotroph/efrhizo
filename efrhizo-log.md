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


2014-03-31:

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
