#!/usr/bin/python3
import subprocess, multiprocessing

def SPADES(read1,read2,directory,spades_tag):
    print("Running spades.py")
    output_dir = directory + "/assembly"
    subprocess.run(["conda", "run", "-n", "ASSEMBLY", "spades.py", "-o", output_dir, "-1", read1, "-2", read2, spades_tag], cwd = directory)

    print("Spades.py finished.")
    return output_dir


def N50(directory,assemblydirectory): #Calculating N50 using stats.sh from BBtools
    subprocess.run(["conda","run","-n","QC","stats.sh","in=" + assemblydirectory + "/contigs.fasta",">",assemblydirectory + "/assemblystats"],cwd = directory)

def DeepVirFinder(pathtoDeepVirFinder,assemblydirectory):
    DVPDir = "../DeepVirPredictions"
    subprocess.run(["mkdir",DVPDir])
    subprocess.run(["conda","run","-n","VIRFINDER","python" + pathtoDeepVirFinder + "/dvf.py", "-i", assemblydirectory + "/contigs.fasta","-o",DVPDir],cwd = assemblydirectory)


def PHAROKKA(directory, assemblydirectory,threads):

    print("Running pharokka.py")
    
    print("Using:", threads, "threads.")

    subprocess.run(["conda", "run", "-n", "PHAROKKA", "pharokka.py","-i", assemblydirectory + "/contigs.fasta", "-o", "pharokka", "-f","-t",str(threads)],cwd = directory)

    print("Pharokka.py finished running.")