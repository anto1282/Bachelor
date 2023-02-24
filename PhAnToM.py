#!/usr/bin/python3

import subprocess, sys, os, multiprocessing
from argparse import ArgumentParser
import Assembly
import Trimton


#Command line arguments

parser = ArgumentParser(prog = 'PhAnTom.py',description="Help me!")
parser.add_argument("-i","--input", action="store", dest = "sraAccNr", help ="Input valid accesion number from Sequence Read Archive.")
parser.add_argument("--flag", action = "store", dest = "whatSPADES", default = "--meta", help = "Runs spades with the specified flag.")
parser.add_argument("--threads","-t",action = "store", dest = "threads", type = int, default = multiprocessing.cpu_count(),help = "Specifies the total number of threads used in various of the programs in the pipeline.")

args = parser.parse_args()


#Creates results directory for the pipeline results
def directory_maker(sraAccNr):
    parent_directory = "Results" + sraAccNr
    if not os.path.exists(parent_directory): 
        subprocess.run(["mkdir",parent_directory])
    return parent_directory

#Downloads sequence reads from SRA using fasterq-dump
def sra_get(sraAccNr,directory):
    if not os.path.exists(directory + "/" +sraAccNr + "_1.fastq") and not os.path.exists(directory + "/" + sraAccNr + "_2.fastq"):
        print("Downloading", sraAccNr, "from SRA using fasterq-dump")
        subprocess.run(["fasterq-dump", sraAccNr, "--progress"], cwd = directory)
    else:
        print("Reads already present in directory! Continuing...")
    return sraAccNr + "_1.fastq", sraAccNr + "_2.fastq"

def main():
    #Initialization

    threads = args.threads

    if len(sys.argv) < 2:
        parser.print_help()
        sys.exit()

    #Implement steps to stop pipeline if arguments are missing

    sraAccNr = args.sraAccNr 
    parent_directory = directory_maker(sraAccNr)
    read1, read2 = sra_get(sraAccNr,parent_directory)

    read1Trimmed, read2Trimmed = Assembly.SubSampling(read1,read2,parent_directory,0.1,100)
    assemblydirectory = Assembly.SPADES(read1Trimmed,read2Trimmed,parent_directory,args.whatSPADES)
    
    Assembly.N50(parent_directory,assemblydirectory)
    Assembly.PHAROKKA(parent_directory, assemblydirectory, threads)

main()

### The end ###
print("Pharokka.py finished running.")
print("\nThanks for using the PhAnTomic's pipeline :-P")