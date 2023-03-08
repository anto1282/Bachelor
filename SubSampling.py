#!/usr/bin/python3
import subprocess, sys

read1 = sys.argv[1]
read2 = sys.argv[2]
samplerate = sys.argv[3]
sampleseed = sys.argv[4]


def SubSampling(read1,read2,sampleRate,sampleSeed): #Subsampling using Reformat.sh 
    for i in range(int(sampleSeed)):
        out1 = "subs#"+str(i) + "_read1.fastq"
        out2 = "subs#"+str(i) + "_read2.fastq"
        subprocess.run(["reformat.sh","in=" + read1, "in2=" + read2, "out=" + out1, "out2=" + out2,"samplerate=" + str(sampleRate),"sampleseed=" + str(sampleSeed),"overwrite=true"])
        

SubSampling(read1,read2,samplerate,sampleseed)