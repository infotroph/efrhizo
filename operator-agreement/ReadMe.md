# Analysis of agreement between technicians when tracing root images

This directory contains a sub-experiment that uses a set of images from the EBI minirhizotron experiment to examine the degree of variability between analysts. These images were our standard training battery: Every technician who worked on the experiment started by tracing these images, then adjusting their tracings in response to feedback from the project manager.

Design: 100 images, with 25 selected from each of the 4 cropping systems in the EBI experiment: Maize-soybean rotation (images are from maize only), Miscanthus, Switchgrass, 32-species prairie mix. 
Only about half the images from each crop contain roots; Images were selected to show a realistic mix of lighting conditions, depths in the tube, presence/absence of roots (roughly half the images were classified as containing no roots), etc.

The images are presented with no crop or depth information, in an order determined randomly but in the same order for all technicians. 12 images are presented 3 times each under different file names as a within-technician consistency check, for a total task size of 124 frames to be traced. For each frame, the technicians are asked to:

1. Look for any image quality issues that would prevent them from seeing roots in some or all of the image area. If any portion of the image is poor to trace (usually because the image is too dark or blurry, occasionally because of mud streaks or scratches from improper tube installation), they are instructed to log the image as unusable even if some roots are visible elsewhere in the image.
2. Identify whether the image contains any roots at all. If none, log a zero and move on to the next image.
3. Trace the length and width of every image feature that:
	3a. can be positively identified as a root, and
	3b. has its full diameter visible and in focus.
4. log that the frame is traced and contains roots, then move on to the next image.

Directory contents:

* rawdata: unprocessed data as it came from the image-tracing computer, including:
	* agreement-<initials>.txt: WinRhizo data file each technician's tracing. Contains raw whole-frame total dimensions and some information about individual roots.
	* calibrations.csv: horizontal and vertical pixel size used by each technician. All measured the same target image, so these SHOULD be very similar. These dimensions are available in the data files too, just collected them here for references.
	* log-<initials>.csv: Running log of when tech traced each frame, whether it contained roots, and any notes.
	* pat-<initials>: Directory of all WinRhizo trace files (*.pat). These contain the raw pixel coordinates of every traced root segment, but in an undocumented format.
	* retrace-log-EA.txt, retraced-agree-EA.txt: Out of curiousity I asked EA to redo the agreement tracing at the end of the summer, changing anything that now looked "wrong" to him after a summer of tracing real data. This is not currently used in the analysis, but comparing the retrace numbers against his initial tracings should give an indication of how much one randomly selected technician's judgement changes with training.
