#!/usr/bin/env python3

'''
Read traced roots from a WinRhizo .pat file and overlay them on an existing image—hopefully the same one the tracing came from!

Usage: showpat.py input.jpg tracing_of_input.pat output.jpg

Input and output image format are determined by file extension and may be anything recognized by skimage.io.
'''

from skimage import io, draw
# from skimage.color import rgb2grey
from os.path import basename
from sys import argv

class Pat:
    def __init__(self, path):
        self.filename = basename(path)
        self.header = []
        self.roots = set()
        self.segments = []
        self.read_pat(path)

    def read_pat(self, path):
        '''
        Reads a traced-root pattern file from the given path,
        populates self with
            self.header (a list), 
            self.roots (a set), 
            and self.segments (a list of Segment objects),
        returns nothing.
        '''
        with open(path) as f:
            line_arr = [line.strip() for line in f.readlines()]

        self.header = line_arr[:5]
        expected_header = ['6', '-', '-', '-', '-']
        if self.header != expected_header:
            raise ValueError("Unexpected headers: expected {}, got {}".format(expected_header, self.header))

        # Each segment starts with a root name (e.g. "R1"), 
        seg_starts = [i for i,j in enumerate(line_arr) if j[0]=='R']
        if len(seg_starts) == 0:
            return # no roots in this file
        if seg_starts[0] != 6:
            raise ValueError("First root found at line {} instead of line 7!".format(seg_starts[0]))

        # Segment extends to start of next segment or to EOF.
        #seg_ends = [i-1 for i in seg_starts[1:]] # <-- should this line be re-added? Test first.
        seg_ends = seg_starts[1:]
        seg_ends.append(len(line_arr)-1)

        # Segments are USUALLY 46 lines long, but sometimes longer.
        seg_lengths = [j-i for i,j in zip(seg_starts, seg_ends)]
        if any(seglen < 46 for seglen in seg_lengths):
            raise ValueError("Segment missing lines: lengths {}".format(seg_lengths))

        # Break array up and assign each start:end chunk to a new Segment.
        [self.new_segment(line_arr[i:j]) for i,j in zip(seg_starts, seg_ends)]


    def new_segment(self, list):
        seg = Segment(list)
        self.roots.add(seg.rootname)
        self.segments.append(seg)

    def seg_coords(self):
        # a list of the coordinates for all segments in the file.
        return [s.coords for s in self.segments]


class Segment:
    '''
    Represents a single root segment, as reverse-engineered from a WinRhizo pattern file.
    Basically a named bag of lists, with usefulness of names directly proportional to how
    much I know what the contents mean.
    '''
    def __init__(self, l):
        self.rootname = l[0]
        self.coords = l[1:8]
        self.dec_coords = l[9:16]
        self.mystery_bool1 = l[17:18]
        self.mystery_int1 = l[19:20]
        self.mystery_reallog = l[21:22]
        self.mystery_nonneglog = l[23:24]
        self.mystery_bool2 = l[25]
        self.rootnum = l[26]
        self.zeros = l[27:29]
        self.px_size = l[30:31]
        self.mystery_bool3 = l[32]
        self.size_classes = l[33:34]
        self.mystery_real1 = l[35]
        self.mystery_int2 = l[36]
        self.mystery_bool4 = l[37:38]
        self.strs = l[39:43]
        self.one = l[44]
        self.last = l[45]
        self.remainder = l[45:]


def drawpoint(row, col, diam):
    ri, ci = draw.circle(row, col, diam)
    ri = [min(i, rmax) for i in ri] # don't draw outside edges of image
    ci = [min(i, cmax) for i in ci]
    img[ri, ci] = [0, 255, 0]

img = io.imread(argv[1])
rmax,cmax,chans = img.shape
rmax = rmax -1 # convert to 0-indexed
cmax = cmax -1 

#img_grey = rgb2grey(img)
pat = Pat(argv[2])

for sc in pat.seg_coords():
    # convert string->int and 1-indexed->0-indexed
    sc = [int(i)-1 for i in sc]
    # sc is [x1 y1 x2 y2 x3 y3 x4 y4], iterate over pairs:
    # note drawpoint takes row,col; must flip x,y
    [drawpoint(y, x, 10) for x,y in zip(*[iter(sc)]*2)]

io.imsave(argv[3], img)
