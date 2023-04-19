#!/usr/bin/env python3


# Create file/folder for each phage with the following information
# Alternatively, an html script that makes a website for each phage

# Statistics file, how much eukaryote we removed


#Create a script that runs pharokkas imager tool


#Take the extracted viruses from virextractor.py
#Find the corresponding viruses in the iphop results
#Add a picture of the assembled phage

import sys
from virextractor import *

contigname = str(sys.argv[1])
predictedviruses = str(sys.argv[2])
iphoppredictions = str(sys.argv[3])

virusdict = dict()

with open(predictedviruses,'r') as file:
    phagekey, phagecontig = "", ""
    linecount = 0
    for line in file:
        if line.startswith(">"):
            if linecount > 0:
                virusdict[phagekey] = phagecontig
            phagekey = line.strip()
        else:
            phagecontig += line
    
        linecount += 1
    #Adding the last key/value combination to the set
    virusdict[phagekey] = phagecontig

iphopdict = dict()
with open(iphoppredictions, 'r') as file:
    for line in file:
        line = line.split(',')
        iphopdict[line[0]] = line[1]


html_template = '''
<!DOCTYPE html>
<html>
<head>
	<title>{}</title>
</head>
<body>
	<h1>{}</h1>
	<p>{}</p>
    <h1>{}</h1>
    <p>{}</p>
    
	
</body>
</html>
'''

#Creating a file for each phage with name, contig and genus
with open(outputfilename,'w') as file:
    for key in iphopdict:
        
        host = "Likely host: " + iphopdict[key]
        DNA = "The DNA of the phage: "
        contig = virusdict[key]
        file.write(html_template.format(contigname,key,host, DNA, contig))





