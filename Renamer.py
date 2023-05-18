
import sys
import re

InputName = sys.argv[1]

Infile = open(InputName, "r")
OutFile = open(InputName + "_renamed", "w")

a = InputName[0:-19]

for line in Infile:
    if line.startswith(">"):
        x = re.search(">(NODE_\d*_).*",line)

        print(">" + a+ "_"+  x.group(1), file = OutFile)
    else:
        print(line, end= "", file = OutFile)
