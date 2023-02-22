#!/usr/bin/python3

import subprocess, sys
from argparse import ArgumentParser


parser = ArgumentParser(description="Help me!")

#Test for subsampling
parser.add_argument(["-ss","-subsampling"], action="store", dest="subsampling", type=float,default = 1,help = "Subsampling percentage")

args = parser.parse_args()

if len(sys.argv) < 2:
    parser.print_help()