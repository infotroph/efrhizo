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

Added an alternate line that traces along edges instead of in X across them, but I think I actually like the X's -- good balance between seeing what the tracer did but still being able to pick out where the root edge is in the image. Leaving the edge-trace commented out, running with X's for now.

2015-03-15:

Checking correctness of segment attributes in showpat.py -- suspect I may have some off-by-one errors hiding in the line indexes of the Segment init method. Added a Segment.ordered_values() method for debugging -- dumps segment attributes in the order they appear in the file. Appears to be working when I temporarily replace whole showpat loop with one "print_segs(pat)", but now bedtime before I've actually checked any indexes.

2015-03-16:

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

2015-03-17:

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

2015-03-25:

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

2015-03-28: The `loc.to.depth()` function in RhizoFuncs has an error in depth calculation: it is 22 cm from the top of the tube to the *center* of location 1, not to the top of it. That means `loc.to.depth(1, offset=22)` ought to equal zero, but it currently returns 2. I had been thinking of this as "depth at the bottom of the frame", but even that isn't right.

Changed `loc.to.depth()` by internally subtracting one from the location number; think of it as "how many frames have I moved from the beginning". 

_*NOTE that this will change all previously calculated depths when I rerun make!*_

2015-03-29:

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


2015-03-30:

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

2015-04-06:

Found two typos in `Tractor-core-biomass-2014.csv`: one 30-50 lower depth "5" where it should be "50", one 100+ lower depth empty where others are "+".

While I'm at it: removed lines of empty fields from end of file, changed line endings to LF.

More typos: 

* lines 387-388: 0-10 cm and 10-30 cm layers appear to be transposed from their usual order (0-10 is below 10-30), except that the `Soil Length` column has 30 cm (typical for 0-10) above 60 cm (typical for 10-30). Swapped Soil Length, left the rest of the row as found. 
* line 287: 0-10 cm layer with `Soil Length` listed as 60. All other lines nearby look as expected; changed to 30.

2015-04-29: Did I seriously take no notes about fixing tractor core plots? Shame on me. Will try to reconstruct, but the basic insight is that for lab meeting I was NOT correctly converting tractor cores to per-cm^3 biomass -- what I showed was really (mass in this layer per unit surface area)/100, with no consideration for differing layer thicknesses. Have previously printed plot on my desk and som uncommitted changes in the script in static/, not sure if everything is there or not. I think all the calculations operated directly on columns from the tractor core file?

2015-04-30: Found the unsaved editor window where I developed the conversion, incorporated what I think are the important parts back into figures/static/tractorcore-vs-rhizo-2014-20150331.r. Not committing changes yet -- check diff and think more about whether to make them permanent.

2015-05-05: Added some very simple stats on whether destructive harvest soil had more roots near or far from the tube.

2015-05-06: Started methods section of manuscript in a fresh subrepository. Not sure yet if I want to keep it separate or replay commits into main repo.

2015-08-07: Added peak-season data from August 2011. Also have data from S1 (April), but only tubes 1-8 are traced; not adding these yet.
	Tube 96 is weird: PxSizeH and PxSizeV are set to 0, which leads to strange volume-per-area calculations (some are NA, others Inf). Additionally, all roots are marked as alive, but TotVolume.mm3 does not match AliveVolume.mm3, e.g. loc 45 shows TotVolume.mm3 as 0.000 but AliveVolume.mm3 as 0.213! Assuming for the moment these are all rounding errors from the zero-sized pixels, will fix that before worrying about the volume mismatches. Added all locations from Tube 96 to censor list for now; making a note to go back and try re-exporting with Aug 4th calibration loaded correctly; hopefully this will resolve all the above weirdnesses.

2015-08-08:

Updated EF2013-S1.TXT with newer version from tracing computer; contains traced data from 15 tubes not present in previous version.

2015-08-10: 

Calculation error in tractor core volumes: I was dividing total root mass by (number of cores * area per core * total core length), but total core length already contains the number of cores! Correct volume correction is (g root / cm^3) = (g root in sample)/(cm^2 per core * cm total core length).

Typo in unit-conversions.txt: corn root density of "0.8-1.4" should have been "0.08-1.4", but in the process of checking that I stopped eyeballing and did the math for real. New value: 0.06-1.4, with most values around 0.08-0.09. Highest densities are found in small-diameter roots very near apex (<2 mm from tip), decreases to 0.05-0.06 range (or 0.08 at 19C) beyond ~5-6 mm back.
