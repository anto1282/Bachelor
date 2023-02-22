#!/usr/bin/python3

import subprocess, sys
from argparse import ArgumentParser

#Command line arguments

parser = ArgumentParser(description="Help me!")
parser.add_argument(["-i","input"], action="store", dest="sraAccNr", type = str, help ="Input valid accesion number from Sequence Read Archive")
args = parser.parse_args()

if len(sys.argv) < 2:
    parser.print_help()
    sys.exit()

#Creates results directory for the pipeline results
def directory_maker(sraAccNr):
    global parent_directory
    parent_directory = "PhAnTom" + sraAccNr
    if not os.path.exists(parent_directory): 
        subprocess.run(["mkdir",parent_directory])
#Downloads sequence reads from SRA using fasterq-dump
def sra_get(sraAccNr,directory):
    print("Downloading from SRA using fasterq-dump")
    subprocess.run(["fasterq-dump", sraAccNr, "--progress"], cwd = directory)

def eukaryote_removal():
    
