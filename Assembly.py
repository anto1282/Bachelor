#!/usr/bin/python3
import subprocess, re, os, glob

def offsetDetector(read1,read2,directory):
    maxASCII = None
    minASCII = None
    print("Finding phred-offset")
    reads = [read1,read2]
    for read in reads:
        with open(directory + "/" + read) as file:
            phredflag = False
            for line in file:
                if line.startswith("+"):
                    phredflag = True
                elif line.startswith("@"):
                    phredflag = False
                elif phredflag == True:
                    
                    for char in line.strip():
                        if maxASCII is None or char > maxASCII:
                            maxASCII = char
                        if minASCII is None or char < minASCII:
                            minASCII = char
                    
                    if minASCII < "@":
                        phredoffset = "33"
                        print("Phred-Offset:", phredoffset)
                        return phredoffset
                    
                    if maxASCII > "K":
                        phredoffset = "64"
                        print(phredoffset)
                        return phredoffset

def SPADES(read1,read2,directory,spades_tag,phred_offset):
    output_dir = "assembly" 
    
    if spades_tag != "skip":
        print("Running spades.py")
        SPADES = subprocess.run(["conda", "run", "-n", "ASSEMBLY", "spades.py", "-o", output_dir, "-1", read1, "-2", read2, spades_tag,"--phred-offset",phred_offset], cwd = directory)
        print("Spades.py finished. \n")
    
    return output_dir


def SubSampling(read1,read2,directory,sampleRate,sampleSeed): #Subsampling using Reformat.sh 
    print(read1)
    read1WithNoFileFormat = re.search(r'(\w+)\.fastq',read1).groups()[0]
    read2WithNoFileFormat = re.search(r'(\w+)\.fastq',read2).groups()[0]
    read1Trimmed = read1WithNoFileFormat + "_trimmed.fastq"
    read2Trimmed = read2WithNoFileFormat + "_trimmed.fastq"
    
    print("Subsampling reads using reformat.sh with samplerate =", sampleRate, "and sampleseed =", sampleSeed, "\n")
    subprocess.run(["conda","run","-n", "QC","reformat.sh","in=" + read1, "in2=" + read2, "out=" + read1Trimmed, "out2=" + read2Trimmed,"samplerate=" + str(sampleRate),"sampleseed=" + str(sampleSeed),"overwrite=true"], cwd = directory)
    
    return read1Trimmed, read2Trimmed


def MultiAssembly(read1, read2, directory, spades_tag, phred_offset, sampleRate, nrofassemblies):
    #Assembles the 
    
    maxN50 = None
    maxseed = None
    for sampleSeed in range(1,int(nrofassemblies)+1):
        print("Assembling using SPADES.py", sampleSeed ,"out of", nrofassemblies, "...")
        read1Trimmed, read2Trimmed = SubSampling(read1,read2,directory,sampleRate,sampleSeed)
        assemblydirectory = SPADES(read1Trimmed,read2Trimmed,directory, spades_tag, phred_offset)
        if maxN50 is None or N50(directory,assemblydirectory) > maxN50:
            maxseed = sampleSeed
            maxN50 = N50(directory,assemblydirectory)
        print("\nMax N50:", maxN50)
        print("Best seed:", maxseed, "\n")
        subprocess.run(["rm","-rf",assemblydirectory],cwd = directory)
    print("Running assembly for the best subsampling seed...\n")
    read1Trimmed, read2Trimmed = SubSampling(read1,read2,directory,sampleRate, maxseed)
    assemblydirectory = SPADES(read1Trimmed,read2Trimmed,directory, spades_tag, phred_offset)
    print("Finished assembly for the best subsampling seed:", maxseed,"\n")
    return assemblydirectory #, read1Trimmed, read2Trimmed


def N50(directory,assemblydirectory): #Calculating N50 using stats.sh from BBtools
    filename = "N50assemblystats.txt"
    subprocess.run(["conda","run","-n","QC","stats.sh","in=" + assemblydirectory + "/contigs.fasta",">",filename],cwd = directory)
    
    with open(filename,'r') as file:
        for line in file:
            if line.startswith("Main genome contig N/L50:"):
                nl50 = line.split()[4]
                reg_obj = re.search(r'(\w+)\/',nl50)
                N50 = reg_obj.groups()[0]
                print(N50)
    subprocess.run(["rm",filename],cwd = directory)
    print("N50 =", N50)
    return N50


def contigTrimming(directory,Contigs_fasta, minLength=200):
    Contigs_trimmed = "contigs_trimmed.fasta"

    subprocess.run(["conda", "run", "-n","QC","reformat.sh","in="+Contigs_fasta, "out=" + Contigs_trimmed, "minlength="+str(minLength),"overwrite=True"], cwd = directory)
    return Contigs_trimmed


def DeepVirFinder(pathtoDeepVirFinder,assemblydirectory,threads,inFile,PredTag):
    DVPDir = "DeepVirPredictions"
    filename = glob.glob(DVPDir + "/contigs*")
    if PredTag != "skip":
        print("Running DeepVirFinder")
        
        if not os.path.exists(DVPDir): 
            subprocess.run(["mkdir","../" + DVPDir],cwd = assemblydirectory)
        
        subprocess.run(["conda","run","-n","VIRFINDER","python", pathtoDeepVirFinder + "/dvf.py", "-i", inFile,"-o","../" + DVPDir,"-c", str(threads)],cwd = assemblydirectory)
    else:
        print("DeepVirFinder was skipped")
    resultpath = filename[0]
    return resultpath



# TODO Map reads to contigs to reveal coverage of potential phages

def PHAROKKA(directory, viralcontigs,threads): ##TODO remove phanotate, use prodigal instead

    print("Running pharokka.py")
    print("Using:", threads, "threads.")
    pathToDB = "../PHAROKKADB"
    subprocess.run(["conda", "run", "-n", "PHAROKKA", "pharokka.py","-i", viralcontigs, "-o", "pharokka","-f","-t",str(threads),"-d",pathToDB, "-g","prodigal","--meta"],cwd = directory)

    print("Pharokka.py finished running.")