#!/usr/bin/env python3

import sys


#Script that saves predicted viral contigs in one file and the predicted non-viral contigs 
predfile = sys.argv[1]
contigfile = sys.argv[2]
virusfile = sys.argv[3]
cutoff = float(sys.argv[4])

#try: 
print("Running DeepVirExtractor") 
if cutoff > 1 or cutoff < 0:
    print("Cutoff must be between 0 and 1")
    raise ValueError

virusnames = set()


nonvirusfile = "non_viral_assemblies.fasta"

linecount = 0
print("\nCreating set of viral entries...")
with open(predfile,'r') as file: 
    for line in file:
        if linecount > 0:
            if float(line.split()[2]) > cutoff:
                virusnames.add(line.split()[0])
            
        linecount += 1

print("Number of found viruses:", len(virusnames))
print("Writing virus contigs to file...")
virusoutfile = open(virusfile,"w")
nonvirusoutfile = open(nonvirusfile,'w')


with open("vir_pred_file.tsv",'w') as pred_file:
    #Writes header to file
    pred_file.write("Phagename\tPred_counts\tSeeker\tPhager\tDVF\n")
    for phage in sorted(virusnames):
        DVF = False
        if phage in virusnames:
            DVF = True
        pred_string = "\t".join([phage, str(1), str(DVF)]) + "\n"
        pred_file.write(pred_string)



seqcount = 0
with open(contigfile, 'r') as file:
    virusflag = False
    nonvirusflag = False
    for line in file:
        #print(virusflag)
        if line.startswith(">"):
            virusflag = False             
            nonvirusflag = False
        
        if virusflag == True:
            virusoutfile.write(line)
        elif nonvirusflag == True:
            nonvirusoutfile.write(line)
        elif line.startswith(">") and line[1:].strip().split()[0] in virusnames:
            virusflag = True
            virusoutfile.write(line)
            seqcount += 1
        else:
            nonvirusflag = True
            nonvirusoutfile.write(line)
        
        
    
virusoutfile.close()
nonvirusoutfile.close()

print("Viruses written to %s file:" % virusoutfile, seqcount)
print("DeepVirExtractor finished")
""""
except IndexError as error:
    print("Command argument missing:", error)
    sys.exit()
except ValueError as error:
    print("Command argument missing:", error)
    sys.exit()
"""