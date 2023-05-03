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
    if line.split()[-1] in ["Archaea","Bacteria","Viruses"] and Flag == True:
        break
    if Flag == True:
        TaxIDSet.add(line.split()[4])
infile.close()
print(TaxIDSet)
Flag = False

ReadNumSet = set()
infile = open(read_kraken)
for line in infile:
    if line.split()[2] in TaxIDSet:
        ReadNumSet.add(line.split()[1])
TaxIDSet.clear()
infile.close()

print(ReadNumSet)

infile1 = open(read1TrimmedSub)
infile2 = open(read2TrimmedSub)
OutName1 = sraNR+"_1.TrimmedNoEu.fastq"
OutName2 = sraNR+"_2.TrimmedNoEu.fastq"
outfile1 = open(OutName1,"w")
outfile2 = open(OutName2, "w")

DeletedFile1 = open("DeletedSeqs" , "w")
DeletedFile2 = open("DeletedSeqs2" , "w")
LineCounter = 0
Counter = 0
for line in infile1:
    LineCounter = LineCounter + 1
    print(LineCounter)
    if LineCounter % 4 == 0 or LineCounter == 0:
        Flag = False
        if line.split()[0][1:] in ReadNumSet:
            Flag = True
            Counter += 1
    if Flag == True:
        print(line, file = DeletedFile1,end = "")
    if Flag == False:
        print(line, file = outfile1, end = "")
print("Number of eukaryotic sequences removed from read1:", Counter)
       

infile1.close()
outfile1.close()
LineCounter = 0
Counter = 0
for line in infile2:
    LineCounter = LineCounter + 1
    if LineCounter % 4 == 0 or LineCounter == 0:
        Flag = False
        if line.split()[0][1:] in ReadNumSet:
            print(LineCounter)
            print(line)
            Flag = True
            Counter += 1
    if Flag == True:
        print(line, file = DeletedFile2,end = "")
    if Flag == False:
        print(line, file = outfile2, end = "")


print("Number of eukaryotic sequences removed from read2:", Counter)
ReadNumSet.clear()
infile2.close()
outfile2.close()




