import subprocess, argparse, os
from argparse import ArgumentParser


parser = ArgumentParser(description="Help me!")
parser.add_argument(["-r","--ref"], action="store", dest="refFile", type = str, help ="Input fasta file for filtering out")
args = parser.parse_args()



def trimming(sraACCnr, directory, read1,read2, refFile):


    acc_nr_1 = sraACCnr + "_1.fastq"
    acc_nr_2 = sraACCnr + "_2.fastq"
    
    acc_nr_1_trimmed = "trimmed/" + acc_nr_1
    acc_nr_2_trimmed = "trimmed/" + acc_nr_2

    if not os.path.exists(directory + "/trimmed"):
        subprocess.run(["mkdir","trimmed"], cwd = directory) 
    if args.refFile:
        subprocess.run(["mamba", "run", "-n", "QC","bbduk.sh","-in=" + acc_nr_1,  "-in2=" + acc_nr_2, "-out=" + acc_nr_1_trimmed, "-out2=" + acc_nr_2_trimmed, "ref=" + refFile , "forcetrimleft=15" , "minbasequality=30"], cwd =directory)
        print("Trim finished.")
    else:
        subprocess.run(["mamba", "run", "-n", "QC","bbduk.sh","-in=%s" % acc_nr_1,  "-in2=%s" % acc_nr_2, "-out=%s" % acc_nr_1_trimmed, "-out2=%s" % acc_nr_2_trimmed,"forcetrimleft=15" , "minbasequality=30"], cwd =directory)
        print("Trim finished.")



