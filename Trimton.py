import subprocess, argparse, os
from argparse import ArgumentParser


parser = ArgumentParser(description="Help me!")
parser.add_argument(["-r","--ref"], action="store", dest="refFile", type = str, help ="Input fasta file for filtering out")
args = parser.parse_args()



def trimming(read1, read2, directory, refFile):
    
    
    read1_trimmed = "trimmed/" + read1
    read2_trimmed = "trimmed/" + read2

    if not os.path.exists(directory + "/trimmed"):
        subprocess.run(["mkdir","trimmed"], cwd = directory) 
    if args.refFile:
        subprocess.run(["mamba", "run", "-n", "QC","bbduk.sh","-in=" + read2,  "-in2=" + read2, "-out=" + read1_trimmed, "-out2=" + read2_trimmed, "ref=" + refFile , "forcetrimleft=15", "qtrim=w", "trimq=30" ], cwd =directory)
        print("Trim finished.")
    else:
        subprocess.run(["mamba", "run", "-n", "QC","bbduk.sh","-in=%s" % read1,  "-in2=%s" % read2, "-out=%s" % read1_trimmed, "-out2=%s" % read2_trimmed,"forcetrimleft=15", "qtrim=w", "trimq=30"], cwd =directory)
        print("Trim finished.")
    return read1_trimmed, read2_trimmed



