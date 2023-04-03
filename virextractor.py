#!/usr/bin/env python3


#Program that extracts viral contigs from various phage prediction tools

import sys

contigfile = sys.argv[1]
outputfilename = sys.argv[2]
cutoff = float(sys.argv[3])
dvffile = sys.argv[4]
seekerfile = sys.argv[5]
phagerfile = sys.argv[6]

DVFset = set()



with open(dvffile,'r') as file: 
    linecount = 0
    for line in file:
        if linecount > 0:
            if float(line.split()[2]) > cutoff:
                DVFset.add(line.split()[0])
            
        linecount += 1

print(DVFset)
SeekerSet = set()


with open(seekerfile,'r') as SeekerInFile:
    SeekerFlag = False
    for line in SeekerInFile:
        if len(line) == 1:
            continue
        if SeekerFlag == True:
            if line.split()[1]== "Phage" and float(line.split()[-1]) > cutoff:
                SeekerSet.add(line.split()[0])
        if line.split()[0] =="name":
            SeekerFlag = True


#with open(virsorterfile, 'r') as VirSorterFile:
print(SeekerSet)

PhagerSet = set()
with open(phagerfile, 'r') as file:
    linecount = 0
    for line in file:
        if linecount > 0:
            if int(line.split()[3]) == 1:
                PhagerSet.add(line.split()[1])
        linecount += 1

print(PhagerSet)

final_viral_set = SeekerSet.intersection(DVFset,PhagerSet)


print(final_viral_set)
virusoutfile = open(outputfilename,'w')

with open(contigfile, 'r') as file:
    virusflag = False

    seqcount = 0
    for line in file:
        if line.startswith(">"):
            virusflag = False             
            nonvirusflag = False
        
        if virusflag == True:
            virusoutfile.write(line)
        
        elif line.startswith(">") and line[1:].strip().split()[0] in final_viral_set:
            virusflag = True
            virusoutfile.write(line)
            seqcount += 1
        
        
        
    print(seqcount, "sequence entries written to output file:", virusoutfile)


    
virusoutfile.close()
