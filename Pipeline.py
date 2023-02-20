#!/usr/bin/python3

import subprocess, sys, os

acc_nr = sys.argv[1]

parent_directory = acc_nr + "_pipeline_results/"


if not os.path.exists(parent_directory):
    subprocess.run(["mkdir",parent_directory])

acc_nr_1 = acc_nr + "_1.fastq"

acc_nr_2 = acc_nr + "_2.fastq"

print("Running PhAnTomic pipeline!\n2023 v.0.1")

if not os.path.isfile(parent_directory + acc_nr_1) and not os.path.isfile(parent_directory + acc_nr_2): #Checks if the two files exist in folder
    #Downloads reads from SRA - fasterq-dump
    print("Downloading from SRA using fasterq-dump")
    subprocess.run(["fasterq-dump", acc_nr, "--progress"], cwd = parent_directory)



if "--ss" in sys.argv: #Subsampling data
    
    acc_nr_1_trimmed_subs = acc_nr + "_1_subs.fastq"
    acc_nr_2_trimmed_subs = acc_nr + "_2_subs.fastq"
    samplerate = 0.1
    sampleseed = 100
    print("Subsampling data using samplerate =", samplerate, "and sampleseed=", sampleseed)
    subprocess.run(["conda","run","-n", "biopython","reformat.sh","in=" + acc_nr_1, "in2=" + acc_nr_2, "out=" + acc_nr_1_trimmed_subs, "out2=" + acc_nr_2_trimmed_subs,"samplerate=" + str(samplerate),"sampleseed=" + str(sampleseed),"overwrite=true"], cwd = parent_directory)
    acc_nr_1 = acc_nr_1_trimmed_subs
    acc_nr_2 = acc_nr_2_trimmed_subs


#fastp
print("Running fastp")
acc_nr_1_trimmed = "trimmed/" + acc_nr_1 
acc_nr_2_trimmed = "trimmed/" + acc_nr_2

if not os.path.exists(parent_directory + "/trimmed"):
    subprocess.run(["mkdir","trimmed"], cwd = parent_directory)

subprocess.run(["conda", "run", "-n", "qc","fastp","-i", acc_nr_1, "-I", acc_nr_2, "-o", acc_nr_1_trimmed, "-O", acc_nr_2_trimmed, "-f", "15", "-F", "15"], cwd = parent_directory)

print("Fastp finished.")
#Fastqc 
print("Running fastqc")

subprocess.run(["rm", "-rf","fastqc"], cwd = parent_directory)

subprocess.run(["mkdir","fastqc"], cwd = parent_directory)

subprocess.run(["conda", "run", "-n", "qc","fastqc","-o", "fastqc", acc_nr_1_trimmed], cwd = parent_directory)

subprocess.run(["conda", "run", "-n", "qc","fastqc","-o", "fastqc", acc_nr_2_trimmed], cwd = parent_directory)
print("Fastqc finished.")


assemblyfolder = "assembly_" + acc_nr

print("Running spades.py")

subprocess.run(["rm","-rf",assemblyfolder], cwd = parent_directory)

subprocess.run(["conda", "run", "-n", "assembly3", "spades.py", "-o", assemblyfolder, "-1", acc_nr_1_trimmed, "-2", acc_nr_2_trimmed, "--metaviral"], cwd = parent_directory)