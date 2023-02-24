import subprocess, os


def Kraken(sraACCnr, directory, read1,read2, refFile, acc_1,acc_2,DBPath):

    if not os.path.exists(directory + "/krakenResult"):
        subprocess.run(["mkdir","krakenResult"], cwd = directory) 
    
    subprocess.run(["mamba", "run", "-n", "KRAKEN","kraken2", "--use-names", "--threads", 4, "--db", DBPath, "--fastq-input", "--report evol1", "--gzip-compressed", "--paired", read1, read2,  "--output", sraACCnr + ".kraken"], cwd =directory)
    print("Kraken finished.")

