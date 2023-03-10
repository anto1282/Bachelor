#!/usr/bin/python3
import subprocess, sys

read1 = sys.argv[1]
read2 = sys.argv[2]
samplerate = int(sys.argv[3]) / 100
sampleseed = sys.argv[4]
covorn50 = sys.argv[5]

def SubSampling(read1,read2,sampleRate,sampleSeed,covorn50): #Subsampling using Reformat.sh 
    if covorn50 == "coverage":
        smp = int(float(sampleRate) * 100)
        for i in range(1,smp,5):
            i = i / 100
            out1 = "subs#cov"+ str(i) + "_read1.fastq"
            out2 = "subs#cov"+ str(i) + "_read2.fastq"
            subprocess.run(["reformat.sh","in=" + read1, "in2=" + read2, "out=" + out1, "out2=" + out2,"samplerate=" + str(i),"sampleseed=" + str(sampleSeed),"overwrite=true"])
    elif covorn50 == "n50":
        for i in range(int(sampleSeed)):
            out1 = "subs#n50"+ str(i) + "_read1.fastq"
            out2 = "subs#n50"+ str(i) + "_read2.fastq"
            subprocess.run(["reformat.sh","in=" + read1, "in2=" + read2, "out=" + out1, "out2=" + out2,"samplerate=" + str(sampleRate),"sampleseed=" + str(i),"overwrite=true"])
    

SubSampling(read1,read2,samplerate,sampleseed,covorn50)