import sys

SeekerFile = sys.argv[1]


SeekerInfile = open(SeekerFile, "r")
SeekerFlag = False
BacteriaOutfile = open("SeekerBacterials", "w")
PhageOutfile = open("SeekerPhages", "w")

for line in SeekerInfile:
    if len(line) == 1:
        continue
    if SeekerFlag == True:
        if line.split()[1]== "Phage":
            print(line.split()[0], file = PhageOutfile)
        else:
            print(line.split()[0], file = BacteriaOutfile)
    if line.split()[0] =="name":
        SeekerFlag = True