#!/usr/bin/python3
import subprocess, sys,re

read1 = sys.argv[1]
read2 = sys.argv[2]
contig = sys.argv[3]


def coverageFinderAverage(read1,read2,contigfilepath):
    print("Finding maximum coverage among assemblies which are larger than half of the size of the largest contig.")
    contigs = contigfilepath
    coveragestats = "coveragestats.txt"
    subprocess.run(["bbmap.sh","ref=" + contigs,"in=" + read1,"in2=" + read2,"out=coverage_mapping.sam","nodisk=t","fast=t","covstats="+coveragestats])
    print("Finished")
    linecount = 0
    sumcoverage = 0
    longestcontiglength = None
    with open(coveragestats,'r') as covfile:
        for line in covfile:
            linesplit = line.split()
            if linecount == 1:
                print(line)
                longestcontiglength = float(linesplit[2])
                sumcoverage = float(linesplit[1])
            elif linecount > 1:
                if float(linesplit[2]) > longestcontiglength * 0.7:
                    print(line)
                    sumcoverage += float(linesplit[1])
                else:
                    break
                
            linecount += 1      
    averagecoverage = sumcoverage / linecount - 1
    

    if averagecoverage > 20 and 100 > averagecoverage:
        reg_obj = re.search(r'subs#cov(\d\.\d+)_read1\.fastq',read1)
        
        return reg_obj.groups(0)

print(coverageFinderAverage(read1,read2,contig))