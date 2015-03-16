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
        seg_ends.append(len(line_arr))

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
        return [s.midline for s in self.segments]

    def print_segs(self, segs=[]):
        # Takes a list of segments (defaults to all segments in self),
        # prints a dict of the instance attributes from each one.
        # probably just for diagnostic use, I hope.
        if segs==[]:
            segs=self.segments
        for s in segs:
            print(s.ordered_values())

class Segment:
    '''
    Represents a single root segment, as reverse-engineered from a WinRhizo pattern file.
    Basically a named bag of lists, with usefulness of names directly proportional to how
    much I know what the contents mean.
    '''
    def __init__(self, l):
        self.rootname = l[0] # "R<n>"
        self.midline = l[1:9] # [x1 y1 x2 y2] * 2, both repeats identical
        self.edges = l[9:17] # [x1L y1L x2R y2R x1R y1R x2L y2L]
        self.mystery_bool1 = l[17:19]
        self.mystery_int1 = l[19:21]
        self.mystery_reallog = l[21:23]
        self.mystery_nonneglog = l[23:25]
        self.tip_valid = l[25] # 1 = root ends at visible tip, 0 = root extends out of view
        self.rootnum = l[26] # same as <n> in rootname
        self.zeros = l[27:30]
        self.px_size = l[30:32]
        self.mystery_bool3 = l[32]
        self.size_classes = l[33:35]
        self.mystery_real1 = l[35]
        self.live_status = l[36] # 300="alive", 301="dead", 302="gone"
        self.mystery_int2 = l[37] 
        self.mystery_bool4 = l[38] # probably related to live vs. dead
        self.defined_observations = l[39:44] # each one may be "-", "Y", "N", or arbitrary string
        self.mystery_bool5 = l[44] 
        self.last = l[45] # 0 if EOF or any remainder, 7 if another segment follows immediately.
        self.remainder = l[46:]

    def ordered_values(self):
        ''' Return a list of segment values in the order they appear in the pat file.
         TODO: add an optional values argument, default to all if empty.
         probably something like 
           def print_seg(self, values={}): 
               if values == {}: 
                   values = self.__dict__
               [...]
            ... but not sure yet if I want to take a dict, 
            or a list of attribute names, or what.
        Until values arument is added, this method is probably useless for anything but verbose debugging.
        '''
        order={'rootname':0,
            'midline':1,
            'edges':2,
            'mystery_bool1':3,
            'mystery_int1':4,
            'mystery_reallog':5,
            'mystery_nonneglog':6,
            'tip_valid':7,
            'rootnum':8,
            'zeros':9,
            'px_size':10,
            'mystery_bool3':11,
            'size_classes':12,
            'mystery_real1':13,
            'live_status':14,
            'mystery_int2':15,
            'mystery_bool4':16,
            'defined_observations':17,
            'mystery_bool5':18,
            'last':19,
            'remainder':20}
        return sorted(self.__dict__.items(), key=lambda x:order[x[0]])

def limit_range(arr, lowest, highest):
    return [max(lowest, min(i, highest)) for i in arr]

def drawpoint(row, col, diam):
    ri, ci = draw.circle(row, col, diam)
    ri = limit_range(ri, 0, rmax) # don't draw outside edges of image
    ci = limit_range(ci, 0, cmax)
    img[ri, ci] = [0, 255, 0]

def draw_edge(row1, col1, row2, col2):
    ri, ci = draw.line(row1, col1, row2, col2)
    ri = limit_range(ri, 0, rmax) # don't draw outside edges of image
    ci = limit_range(ci, 0, cmax)
    img[ri, ci] = [0, 0, 255]

img = io.imread(argv[1])
rmax,cmax,chans = img.shape
rmax = rmax -1 # convert to 0-indexed
cmax = cmax -1 

#img_grey = rgb2grey(img)
pat = Pat(argv[2])

pat.print_segs()

for s in pat.segments:
    # convert string->int and 1-indexed->0-indexed
    s_mid = [int(i)-1 for i in s.midline]
    s_edge = [int(float(i))-1 for i in s.edges]

    # s_mid is [x1 y1 x2 y2 x3 y3 x4 y4], iterate over pairs:
    # note drawpoint takes row,col; must flip x,y
    [drawpoint(y, x, 2) for x,y in zip(*[iter(s_mid)]*2)] # segment midline
    #[drawpoint(y, x, 2) for x,y in zip(*[iter(s_edge)]*2)] # segment  corners

    # draw an X over each segment (nice because root edges stay visible)
    [draw_edge(y, x, y2, x2) for x,y,x2,y2 in zip(*[iter(s_edge)]*4)]

    # draw lines along root edges (nice because it shows what we're actually looking for)
    # draw_edge(s_edge[1], s_edge[0], s_edge[7], s_edge[6])
    # draw_edge(s_edge[3], s_edge[2], s_edge[5], s_edge[4])

io.imsave(argv[3], img)
