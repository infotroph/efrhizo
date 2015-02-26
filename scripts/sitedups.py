#!/usr/bin/env python3

'''
Given a directory full of rhizotron images, 
check for duplicates, i.e. multiple images from same 
tube, location, session.

usage: sitedups.py img_dir/
'''

from sys import argv
import os, subprocess

'''Bartz naming convention is:
experiment_Tnnn_Lnnn_yyyy.mm.dd_hhmmss_nnn_operator
e.g. for Tube 1, Location 50, Session 3 in EF2013:
EF2013_T001_L050_2013.07.09_160735_003_LCR.jpg
==> * drop date, time, operator. 
    * Keep expt, tube, location, session.'''
def extract_sites(s):
    ss = s.split("_")
    del(ss[6]) # e.g. drop 'LCR.jpg'
    ss[3:5]=[] # e.g. drop "2013.07.09_160735"
    return("_".join(ss))

img_path = argv[1]

imgs = [f for f in os.listdir(img_path) if f.endswith('.jpg')]
sites = [extract_sites(name) for name in imgs]

seen_already = set()
dup_sites = []
for site in sites:
    # print(site)
    if site in seen_already:
        dup_sites.append(site)
    else: 
        seen_already.add(site)
        
print(dup_sites)    