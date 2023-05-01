# Pipeline for discovering bacteriophages from metagenomic illumina reads

## About NPhAnToM - Nextflow Pipeline for Phage AnnoTation of Metagenomic samples
NPhAnToM is a nextflow pipeline for prediction and annotation of phages in environmental samples, along with phage host prediction using industry standard bioinformatics tools.

The NPhAnTom pipeline consists of several steps:
- Download reads: fasterqdump for downloading illumina reads from the short read archive.
- Trimming reads: adapterremoval, bbduk.sh
- Removing eukaryotic reads: kraken
- FastQC: Checking the quality of the FastQ reads
- Assembly: metagenomic spades
    - Assembly quality check using stats.sh
- Virus prediction: A combination of DeepVirFinder, Seeker and Phager
- Quality check of viral contigs: CheckV
- Phage annotation: Pharokka
- Phage host prediction: IPHOP
- Compilation of the pipelines results to an HTML file


## Install the pipeline
To install the pipeline, clone the repository using git, and install the necessary dependencies either using conda or mamba. See thorough guide below for how to setup your PC to run NPhAnToM. You must also install nextflow its dependencies to run the pipeline.

Some of the parts of the pipeline need a database, so follow the guide to install those and add the paths for those databases to the relevant variables in the nextflow.config file. 

When running locally on a PC, make sure that nextflow and conda / mamba is properly installed. Our pipeline uses mamba as the standard package manager. 
When running the pipeline on an cluster, the pipeline uses modules to load a specific environment. Therefore the modules must be installed and named the same way on the cluster as they are in the pipeline script. If they are not, either ask your system administrator to download the proper modules or simply change the names of the modules inside the script to match the proper names. 
If you haven't already done it, now is the time to clone the NPhAnToM repository to your desired working directory:
```
git clone https://github.com/anto1282/Bachelor
```

# Paths to databases and scripts
There are two ways of providing the paths to the following script and databases, either by writing the paths in the terminal like this:
'''
nextflow run NPhAnToM.py --DVFPath path/to/DeepVirFinder/dvf.py --krakDB path/to/KRAKENDB --phaDB path/to/phaDB etc. 
'''

or by editing your version of the nextflow.config file in order to contain the correct paths to your scripts and databases. 

**Note**
Be aware that you only need to install the databases and the DeepVirFinder script if you don't have them installed already. 

# DeepVirFinder 
Since DeepVirFinder (DVF) doesn't seem to work using conda or mamba, it must be downloaded manually, so download DeepVirFinder by following the instructions from their github: https://github.com/jessieren/DeepVirFinder
If you only intend to run DVF from within nextflow, you do not need to create a conda environment, as the instructions otherwise tell you to do, since our pipeline creates the proper environment automatically.
Remember the full path to DeepVirFinder/dvf.py as you need to provide it when running the Pipeline. 
Alternatively, you can also add the DVFpath parameter directly to the nextflow.config file and add the DVFpath in there. 
In the command for running NPhAnToM, provide the path like this:
'''
--DVFPath path/to/DeepVirFinder/dvf.py
'''

# Kraken Database
A Kraken Database path must be supplied. For a regular PC we recommend the 8 GB minikraken v2 database as it is small enough to run on a PC. See this github for links to the different kraken databases: https://github.com/BenLangmead/aws-indexes/blob/master/docs/k2.md
Download an appropriate database and provide nextflow with the path to it like this:
'''
--krakDB path/to/KRAKENDB
'''

# CheckV Database 
To download the CheckV Database, you unfortunately have to download CheckV separately through conda, see https://bitbucket.org/berkeleylab/checkv/src/master/. Follow the steps to download CheckV and the database. 
The path to the database must be provided like so:
'''
--checkVDB path/to/CHECKVDB
'''

# PharokkaDB
To download the Pharokka database you need to download pharokka using conda. When Pharokka is downloaded, install the database by following the guide here: https://github.com/gbouras13/pharokka#database-installation

'''
--phaDB path/to/pharokkaDB
'''

# IPHOP Database 
When using the local profile in NPhAnToM, the host prediction tool IPHOP is not run as standard, since the IPHOP database takes up more than 100 GB of space. 

If you run the pipeline on an HPC, or want to run the iphop on a local PC anyway, just provide the path to the database and IPHOP should run without any issues.
Follow this link to download IPHOP and the proper database: https://bitbucket.org/srouxjgi/iphop/src/main/

'''
--iphopDB path/to/iphopDB
'''

## Pipeline profiles (local and cluster)
## Running the pipeline locally (local)
To run the pipeline on a local system:
```
nextflow run NPhAnToM.nf --IDS SRR1234567890 -profile local
```
When running the pipeline on your local system, be aware that the host prediction tool IpHoP, is not practical to run, since the database required is very large (> 100 GB).
We recommend at minimum 8 GB of ram, preferrably 16 GB to run the pipeline locally.

## Running the pipeline on a HPC (cluster)
```
nextflow run NPhAnToM.nf --IDS SRR1234567890 -profile cluster
```
Submit the pipeline to the cluster using an sbatch script. 
Take inspiration from the nphantom.sh sbatch script.

# Run the pipeline with nextflow tower
To monitor the pipeline through nextflow tower, you need an access-token from tower.nf.
```
nextflow run NPhAnToM.nf --IDS SRR1234567890 -profile cluster -with-tower --accessToken qwerty1234567890
```

# Links to the tools we use


