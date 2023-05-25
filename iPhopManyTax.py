
# Example Usage CLI: for file in ../GalatheaDResults/GalatheaResults_DSamples/*/; do python3 iPhopManyTax.py $file; done 

import os
import re
import sys

iphopFile = sys.argv[1]
sampleName = (sys.argv[1]).split("/")[-1]
print(iphopFile)


infile = open(iphopFile + "IphopPrediction/Host_prediction_to_genome_m90.csv","r")
infile2 = open(iphopFile + "IphopPrediction/Host_prediction_to_genus_m90.csv","r")
outfile = open(sampleName + "_HostPredictions", "w")
nameSet = set()


lineCount = 0

for line in infile:
    if lineCount == 0:
        lineCount +=1
        continue
    name = re.search("(NODE_\d*_length_\d*).*", line)
    x = name.group(1)

    if x not in nameSet:
        print(sampleName + "\t" +line.split(",")[0] +"\t" +  line.split(",")[2],file = outfile)
        nameSet.add(x)

lineCount = 0
for line in infile2:
    if lineCount == 0:
        lineCount +=1
        continue
    name = re.search("(NODE_\d*_length_\d*).*", line)
    x = name.group(1)

    if x not in nameSet:
        print(sampleName + "\t" +line.split(",")[0] +"\t" +  line.split(",")[2],file = outfile)
        nameSet.add(x)