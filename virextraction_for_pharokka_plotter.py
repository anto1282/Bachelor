#!/usr/bin/env python3


#Program that extracts viral contigs from various phage prediction tools and saves each contig to its own file

import sys

contigfile = str(sys.argv[1])

dvfcutoff = float(sys.argv[2])
dvffile = str(sys.argv[3])
seekercutoff = float(sys.argv[4])
seekerfile = str(sys.argv[5])
phagerfile = str(sys.argv[6])

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
DVFfile = open(dvffile,"r")
SeekerInFile = open(seekerfile,"r")
PhagerInfile = open(phagerfile,"r")

            
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
        output_file = 'contig_' + seq_id + '.fasta'
        if seq_id in fasta_dict:
            with open(output_file, 'w') as outfile:
                outfile.write('>' + seq_id + '\n' + fasta_dict[seq_id] + '\n')
                print(f"Sequence {seq_id} found and written to {output_file}.")
        else:
            print(f"Sequence {seq_id} not found in the fasta file.")

extract_sequences(contigfile, final_viral_set)