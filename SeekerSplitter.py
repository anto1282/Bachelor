import sys

SeekerFile = sys.argv[1]
ScaffoldFile = sys.argv[2]


ScaffoldInfile = open(ScaffoldFile, "r")
SeekerInfile = open(SeekerFile, "r")
SeekerFlag = False
BacteriaOutfile = open("SeekerBacterials", "w")
PhageOutfile = open("SeekerPhages", "w")
PhageSet = set()
BacterialSet = set()
CutOff = 0.8


for line in SeekerInfile:
    if len(line) == 1:
        continue
    if SeekerFlag == True:
        if line.split()[1]== "Phage" and float(line.split()[-1]) > CutOff:
            PhageSet.add(line.split[0])
        if line.split()[1]== "Bacteria":
            BacterialSet.add(line.split[0])
    if line.split()[0] =="name":
        SeekerFlag = True

SeekerInfile.close()

PhageFlag = False
BacFlag = False
for line in ScaffoldInfile:

    if line.startswith(">"):
        BacFlag = False
    if line[1:-1] in BacterialSet:
        BacFlag = True
    if BacFlag == True:
        print(line, file = BacteriaOutfile)


    if line.startswith(">"):
        PhageFlag = False
    if line[1:-1] in PhageSet:
        PhageFlag = True
    if PhageFlag == True:
        print(line, file = PhageOutfile)
PhageOutfile.close()
BacteriaOutfile.close()
ScaffoldInfile.close()