import sys
PharokkaGFFFile = sys.argv[1]
PharokkaGBKFile = sys.argv[2]


GFFFile = open(PharokkaGFFFile, "r")

contigs = list()
for line in GFFFile:
    if line.split()[0] == "##sequence-region":
        contigs.append(line.split()[1])
    if line[0:4] == "NODE":
        break

GFFFile.close()

GFFFile = open(PharokkaGFFFile, "r")
GBKFile = open(PharokkaGBKFile, "r")

FastaFlag = False
for Nodes in contigs:
    GFFOutFile = open(Nodes + ".gff","w")
    GBKOutfile = open(Nodes + ".gbk", "w")
    for line in GFFFile:
        if line.split()[0] == Nodes:
            print(line, file = GFFOutFile, end="")
        if line[0] == ">":
            FastaFlag = False
            if line == ">" + Nodes:
                FastaFlag = True
        if FastaFlag == True:
            print(line, file =GFFOutFile, end= "")
    GBKFlag = False
    for line in GBKFile:
        if line.split()[0] == "LOCUS":
            GBKFlag = False
            if line.split()[1] == Nodes:
                 GBKFlag = True
        if GBKFlag == True:
            print(line, file = GBKOutfile, end = "")

GBKFile.close()
GFFFile.close()



