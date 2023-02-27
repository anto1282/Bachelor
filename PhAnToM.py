#!/usr/bin/python3

import subprocess, sys, os, multiprocessing
from argparse import ArgumentParser
import Assembly
import TaxRemover
import Kraken2
from DeepVirExtractor import DeepVirExtractor

#Command line arguments

parser = ArgumentParser(prog = 'PhAnTom.py',description="Help me!")
parser.add_argument("-i","--input", action="store", dest = "sraAccNr", help ="Input valid accesion number from Sequence Read Archive.")
parser.add_argument("--flag",'-f', action = "store", dest = "whatSPADES", default = "--meta", help = "Runs spades with the specified flag. (skip skips spades)")
parser.add_argument("--threads","-t",action = "store", dest = "threads", type = int, default = multiprocessing.cpu_count(),help = "Specifies the total number of threads used in various of the programs in the pipeline.")
parser.add_argument("-r","--ref", action="store", dest="refFile", help ="Input fasta file for filtering out", default=False)
parser.add_argument("-p","-pred",action="store",dest = "virpredflag", default = "dontskip", help = "Write skip to skip deepvirfinder.")
parser.add_argument("-a","--assemblies",action="store",dest = "nrofassemblies",default = "1", help ="Determines the number of assemblies and subsamplings to be performed (Default is 1)")

args = parser.parse_args()


#Creates results directory for the pipeline results
def directory_maker(sraAccNr):
    parent_directory =  "../Results" + sraAccNr
    if not os.path.exists(parent_directory): 
        subprocess.run(["mkdir",parent_directory])
    return parent_directory

#Downloads sequence reads from SRA using fasterq-dump
def sra_get(sraAccNr,directory):
    if not os.path.exists(directory + "/" +sraAccNr + "_1.fastq") and not os.path.exists(directory + "/" + sraAccNr + "_2.fastq"):
        print("Downloading", sraAccNr, "from SRA using fasterq-dump")
        subprocess.run(["fasterq-dump", sraAccNr, "--progress", "--split-files"], cwd = directory)
    else:
        print("Reads already present in directory! Continuing...")
    return sraAccNr + "_1.fastq", sraAccNr + "_2.fastq"



def trimming(read1, read2, directory, refFile,offset):
    
    
    read1_trimmed = "trimmed/" + read1
    read2_trimmed = "trimmed/" + read2

    if not os.path.exists(directory + "/trimmed"):
        subprocess.run(["mkdir","trimmed"], cwd = directory) 
    if args.refFile:
        subprocess.run(["mamba", "run", "-n", "QC","bbduk.sh","-in=" + read2,  "-in2=" + read2, "-out=" + read1_trimmed, "-out2=" + read2_trimmed, "ref=" + refFile , "trimq=30", "qtrim=rl","forcetrimleft=15" ,"overwrite=true"], cwd =directory)
        print("Trim finished.")
    else:
        subprocess.run(["mamba", "run", "-n", "QC","bbduk.sh","-in=%s" % read1,  "-in2=%s" % read2, "-out=%s" % read1_trimmed, "-out2=%s" % read2_trimmed, "trimq=30", "qtrim=rl","forcetrimleft=15" ,"overwrite=true"], cwd =directory)
        print("Trim finished.")
    return read1_trimmed, read2_trimmed



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

    phredOffset = Assembly.offsetDetector(read1,read2,parent_directory)

    refFile = args.refFile

    read1Trimmed, read2Trimmed = trimming(read1, read2, parent_directory, refFile, phredOffset)
    
    Kraken2.Kraken(parent_directory,read1Trimmed,read2Trimmed, "../KrakenDB")
    
    read1Trimmed, read2Trimmed = TaxRemover.EuRemover(parent_directory,read1Trimmed, read2Trimmed)

    assemblydirectory = Assembly.MultiAssembly(read1Trimmed,read2Trimmed,parent_directory,args.whatSPADES,phredOffset,0.1,args.nrofassemblies)
    
    #Implement filtering of contigs that are too short
    Contigs_Trimmed = Assembly.contigTrimming(assemblydirectory, "contigs.fasta", minLength=200)

    pathToDeepVirFinder = "../../DeepVirFinder"

    predfile = Assembly.DeepVirFinder(pathToDeepVirFinder, assemblydirectory,threads, Contigs_Trimmed,args.virpredflag)
    
    viralcontigs = DeepVirExtractor(predfile,assemblydirectory,parent_directory,0.95)

    
    Assembly.PHAROKKA(parent_directory, viralcontigs, threads)

main()

### The end ###
print("\nThanks for using the PhAnTomic's pipeline :-P")