#!/usr/bin/python3
import os
import sys
import re


read1TrimmedSub, read2TrimmedSub= sys.argv[1], sys.argv[2]
sraNR = sys.argv[3]
report_kraken = sys.argv[4]
read_kraken = sys.argv[5]

infile = open(report_kraken, "r")
Flag = False
TaxIDSet = set()

for line in infile:
    if line.split()[-1] == "Eukaryota":
        Flag = True
    if line.split()[-1] in ["Archaea","Bacteria","Viruses"]:
        if Flag == True:
            Flag = False
            break
    if Flag == True:
        TaxIDSet.add(line.split()[4])
infile.close()

Flag = False

ReadNumSet = set()
infile = open(read_kraken)
for line in infile:
    if line.split()[2] in TaxIDSet:
        ReadNumSet.add(line.split()[1])
TaxIDSet.clear()
infile.close()

infile1 = open(read1TrimmedSub)
infile2 = open(read2TrimmedSub)
OutName1 = sraNR+"_1.TrimmedSubNoEu.fastq"
OutName2 = sraNR+"_2.TrimmedSubNoEu.fastq"
outfile1 = open(OutName1,"w")
outfile2 = open(OutName2, "w")
Counter = 0
for line in infile1:
    if line.split(" ")[0][0] == "@":
        if line.split()[0][1:] in ReadNumSet:
            Flag = True
        else:
            Flag = False
    if Flag == False:
        print(line.strip(), file = outfile1)
    if Flag == True:
        Counter =+ 1
print("Number of eukaryotic sequences removed from read1:", Counter)
       

infile1.close()
outfile1.close()
Counter = 0
for line in infile2:
    if line.split(" ")[0][0] == "@":
        if line.split()[0][1:] in ReadNumSet:
            Flag = True
        else:
            Flag = False
    if Flag == False:
        print(line.strip(), file = outfile2)
    if Flag == True:
        Counter += 1
print("Number of eukaryotic sequences removed from read2:", Counter)
ReadNumSet.clear()
infile2.close()
outfile2.close()




