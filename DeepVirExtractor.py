#!/usr/bin/env python3

import sys


def DeepVirExtractor(predfile,assemblyDirectory,directory,cutoff):
    try: 
        print("Running DeepVirExtractor") 
        if cutoff > 1 or cutoff < 0:
            raise ValueError

        fastanames = set()
        
        contigfile = directory + "/" + assemblyDirectory + "/contigs.fasta"
        outputfile = directory + "/predicted_viruses.fastq"
        
        linecount = 0
        print("\nCreating set...")
        with open(predfile,'r') as file: 
            for line in file:
                if linecount > 0:
                    if float(line.split()[3]) < cutoff:
                        fastanames.add(line.split()[0])
                        
                linecount += 1

        print(linecount - 1, "total entries.")
        print(len(fastanames), "fasta entries passed cutoff.")
        
        outfile = open(outputfile,"w")

        with open(contigfile, 'r') as file:
            writeflag = False
            seqcount = 0
            for line in file:
                #print(writeflag)
                if line.startswith(">"):
                    writeflag = False             
                if writeflag == True:
                    outfile.write(line)
                elif line.startswith(">") and line[1:].strip().split()[0] in fastanames:
                    writeflag = True
                    outfile.write(line)
                    seqcount += 1
                
                
            print(seqcount, "sequence entries written to output file:", outputfile)
            
            
        outfile.close()
        return outputfile
    
        
    except IndexError as error:
        print("Command argument missing:", error)
        sys.exit()
    except ValueError as error:
        print("Command argument missing:", error)
        sys.exit()