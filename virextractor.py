#!/usr/bin/env python3


#Program that extracts viral contigs from various phage prediction tools

import sys

contigfile = str(sys.argv[1])
outputfilename = str(sys.argv[2])
dvfcutoff = float(sys.argv[3])
dvffile = str(sys.argv[4])
seekercutoff = float(sys.argv[5])
seekerfile = str(sys.argv[6])
phagerfile = str(sys.argv[7])

DVFset = set()
def DVFExtract(DVFfile):
    linecount = 0
    for line in DVFfile:
        if linecount > 0:
            if float(line.split()[2]) > dvfcutoff:
                DVFset.add(line.split()[0])
        linecount += 1
    return DVFset




SeekerSet = set()
def SeekerExtract(SeekerInFile):
    SeekerFlag = False
    for line in SeekerInFile:
        if len(line) == 1:
            continue
        if SeekerFlag == True:
            if line.split()[1]== "Phage" and float(line.split()[-1]) > seekercutoff:
                SeekerSet.add(line.split()[0])
        if line.split()[0] =="name":
            SeekerFlag = True
    return  SeekerSet               


#with open(virsorterfile, 'r') as VirSorterFile:

PhagerSet = set()
def PhagerExtract(file):
    linecount = 0
    for line in file:
        if linecount > 0:
            if int(line.split()[3]) == 1:
                PhagerSet.add(line.split()[1])
        linecount += 1
    return PhagerSet


#Burde ikke give problemer, men fungerer ikke som det skal:
try:
    DVFfile = open(dvffile,"r")
    SeekerInFile = open(seekerfile,"r")
    PhagerInfile = open(phagerfile,"r")
except FileNotFoundError:
    try:
        SeekerInFile = open(seekerfile,"r")
        PhagerInfile = open(phagerfile,"r")
    except:
        try:
            PhagerInfile = open(phagerfile,"r")
        except:
            print("No files found, exiting")
            
DVFset = DVFExtract(DVFfile)
SeekerSet = SeekerExtract(SeekerInFile)
PhagerSet = PhagerExtract(PhagerInfile)


print(DVFset)
print(SeekerSet)
print(PhagerSet)


SeekerDVFInter = SeekerSet.intersection(DVFset)
SeekerPhagerInter = SeekerSet.intersection(PhagerSet)
DVFPhagerInter = DVFset.intersection(PhagerSet)

final_viral_set = SeekerDVFInter.union(SeekerPhagerInter,DVFPhagerInter)

virusoutfile = open(outputfilename,'w')


#Prints out all phages into one file
with open(contigfile, 'r') as file:
    virusflag = False

    seqcount = 0
    for line in file:
        if line.startswith(">"):
            virusflag = False             
        
        if virusflag == True:
            virusoutfile.write(line)
        
        elif line.startswith(">") and line[1:].strip().split()[0] in final_viral_set:
            virusflag = True
            virusoutfile.write(line)
            seqcount += 1
        
        
        
    print(seqcount, "sequence entries written to output file:", outputfilename)

virusoutfile.close()


def extract_sequences(fasta_file, ids_set):
    """
    Searches through a fasta file and extracts the sequences for a given set of IDs.
    Writes each ID and sequence to a separate output file with the given prefix.
    """
    fasta_dict = {}
    with open(fasta_file, 'r') as infile:
        header = ''
        sequence = ''
        for line in infile:
            line = line
            if line.startswith('>'):
                if header != '':
                    fasta_dict[header] = sequence
                    sequence = ''
                header = line[1:].strip()
            else:
                sequence += line
        fasta_dict[header] = sequence

    for seq_id in ids_set:
        output_file = seq_id + '.fasta'
        if seq_id in fasta_dict:
            with open(output_file, 'w') as outfile:
                outfile.write('>' + seq_id + '\n' + fasta_dict[seq_id] + '\n')
                print(f"Sequence {seq_id} found and written to {output_file}.")
        else:
            print(f"Sequence {seq_id} not found in the fasta file.")

extract_sequences(contigfile, final_viral_set)