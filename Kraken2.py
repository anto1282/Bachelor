#!/usr/bin/python3
import subprocess, os

def Kraken(directory,read1,read2,DBPath):

    
    if not os.path.exists(directory + "/krakenResult"):
        subprocess.run(["mkdir","krakenResult"], cwd = directory) 
    
    subprocess.run(["mamba", "run", "-n", "KRAKEN","kraken2", "--threads", 4, "--d", DBPath, "--memory-mapping", "--report","Report.kraken.txt", "--paired", read1, read2,  "--output", "Read.kraken"], cwd =directory)
    print("Kraken finished.")
    return