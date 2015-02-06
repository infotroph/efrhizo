#!/usr/bin/env python3

'''
Given a directory full of rhizotron images, 
make contact sheets each showing all the images from one imaging site.

usage: contact_sheet.py img_dir/ output_dir/
'''

from sys import argv
import os, subprocess

'''We want to put together all images that share 
the same site within the soil, i.e. 
experiment, tube & location are the same without regard to 
time of capture/session number/operator.

Bartz naming convention is:
experiment_Tnnn_Lnnn_yyyy.mm.dd_hhmmss_nnn_operator

e.g. for Tube 1, Location 50, Session 3 in EF2013:
EF2013_T001_L050_2013.07.09_160735_003_LCR.jpg

==> drop everything after the 3rd underscore, match on what remains.'''
def strip_date(s):
    return("_".join(s.split("_")[:3]))

'''Assemble images 
at full size with 5px margins
on a black background
with filename underneath each image
in 24-point white text'''
cmdbase = [
    "montage",
    "-geometry", "100%x100%+5+5",
    "-background", 'black',
    "-label", "'%f'",
    "-fill", 'white',
    "-pointsize", "24"]

img_path = argv[1]
out_path = argv[2]

# Ready? Go.
imgs = [f for f in os.listdir(img_path) if f.endswith('.jpg')]
sites = set([strip_date(i) for i in imgs])

for site in sites:
    filestr = "%s*.jpg" % site
    outstr = "%s%s.jpg" % (out_path, site)
    subprocess.call(cmdbase + [filestr, outstr])
    