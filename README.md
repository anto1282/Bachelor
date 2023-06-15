# Pipeline for discovering bacteriophages from metagenomic illumina reads

## About NPhAnToM - Nextflow Pipeline for Phage AnnoTation of Metagenomic samples
NPhAnToM is a nextflow pipeline for prediction and annotation of phages in environmental samples, along with phage host prediction using industry standard bioinformatics tools.
![image](https://github.com/anto1282/NPhAnTom/assets/114398738/f8315d60-54d8-4df0-bc02-3af5ccee0a5c)

The NPhAnTom pipeline consists of several steps:
- Providing reads either by:
    - Downloading reads: fasterqdump for downloading illumina reads from the NCBI Sequence Read Archive.
    - Fetching reads from local directory
- Trimming reads: adapterremoval, bbduk.sh
- Removing eukaryotic reads: kraken
- FastQC: Checking the quality of the FastQ reads
- Assembly: metagenomic spades
    - Assembly quality check using stats.sh
- Virus prediction: A combination of DeepVirFinder, Seeker and Phager
- Checking phage completeness: CheckV
- Phage annotation: Pharokka
- Phage host prediction: IPHOP
- Compilation of the pipelines results to an HTML file

# Quick start - for KU users (MJOLNIR HPC)
The pipeline is very easily run on the Mjolnir HPC located on KU. 
Just clone this repository and run the pipeline using this command. All database paths are already set up. 
```
sbatch --mail-user=your@email.com nphantom_2.sh --IDS SRR123456 -profile cluster 
```

## Install the pipeline
To install the pipeline on your system, clone the repository using git, and install the necessary dependencies either using conda or mamba. See thorough guide below for how to setup your PC to run NPhAnToM. You must also install nextflow and its dependencies to run the pipeline.

Some of the parts of the pipeline need a database, so follow the guide to install those and add the paths to the databases in the nextflow.config file. 

When running locally on a PC, make sure that nextflow and conda / mamba is properly installed. Our pipeline uses mamba as the standard package manager. 
When running the pipeline on an cluster, the pipeline uses modules to load a specific environment. Therefore the modules must be installed and named the same way on the cluster as they are in the pipeline script. If they are not, either ask your system administrator to download the proper modules or simply change the names of the modules inside the script to match the proper names. 
If you haven't already done it, now is the time to clone the NPhAnToM repository to your desired working directory:
```
git clone https://github.com/anto1282/Bachelor
```

### Paths to databases and scripts
There are two ways of providing the paths to the following script and databases, either by writing the paths in the terminal like this:
```
nextflow run NPhAnToM.py --DVFPath path/to/DeepVirFinder/dvf.py --krakDB path/to/KRAKENDB --phaDB path/to/phaDB etc. 
```

or by editing your version of the nextflow.config file in order to contain the correct paths to your scripts and databases. 

>**Note**
>Be aware that you only need to install the databases and the DeepVirFinder script if you don't have them installed already. 

### DeepVirFinder 
Since DeepVirFinder (DVF) doesn't seem to work using conda or mamba, it must be downloaded manually. 
Download DeepVirFinder by following the instructions from their github: https://github.com/jessieren/DeepVirFinder.
If you only intend to run DVF from within nextflow, you do not need to create a conda environment for it, as the instructions otherwise tell you to do, since our pipeline creates the proper environment automatically.
Remember the full path to DeepVirFinder/dvf.py as you need to provide it when running the Pipeline. 
Alternatively, you can also add the DVFpath parameter directly to the nextflow.config file and add the ```--DVFpath``` in there. 
In the command for running NPhAnToM, provide the path like this:
```
--DVFPath path/to/DeepVirFinder/dvf.py
```

### Kraken Database
A Kraken Database path must be supplied. For a regular PC we recommend the 8 GB minikraken v2 database as it is small enough to run on a PC. See this github for links to the different kraken databases: https://github.com/BenLangmead/aws-indexes/blob/master/docs/k2.md.
Download an appropriate database and provide nextflow with the ```--krakDB``` path like this:
```
--krakDB path/to/KRAKENDB
```

### CheckV Database 
To download the CheckV Database, you unfortunately have to download CheckV separately through conda, see https://bitbucket.org/berkeleylab/checkv/src/master/. Follow the steps to download CheckV and the database. 
The path to the ```--checkVDB``` database must be provided like so:
```
--checkVDB path/to/CHECKVDB
```

### Pharokka Database
To download the Pharokka database you need to download pharokka using conda. When Pharokka is downloaded, install the database by following the guide here: https://github.com/gbouras13/pharokka#database-installation. Provide the ```--phaDB``` like this:
```
--phaDB path/to/pharokkaDB
```

### IPHOP Database 
When using the local profile in NPhAnToM, the host prediction tool IPHOP is not run as standard, since the IPHOP database takes up more than 100 GB of space. 

If you run the pipeline on an HPC, or want to run the iphop on a local PC anyway, just provide the ```--iphopDB``` path to the database and IPHOP should run without any issues.
Follow this link to download IPHOP and the proper database: https://bitbucket.org/srouxjgi/iphop/src/main/.

```
--iphopDB path/to/iphopDB
```

## Pipeline profiles (local and cluster)
## Running the pipeline locally (local)
To run the pipeline on a local system use the local profile:
```
nextflow run NPhAnToM.nf --IDS SRR1234567890 -profile local
```
When running the pipeline on your local system, be aware that the host prediction tool IpHoP, is not practical to run, since the database required is very large (> 100 GB).
>**NOTE**
>We recommend a minimum of 8 GB ram, preferrably 16 GB to run the pipeline locally.

## Running the pipeline on a HPC (cluster)
```
nextflow run NPhAnToM.nf --IDS SRR1234567890 -profile cluster
```
The pipeline is easily run on an HPC using the SLURM workload manager. 
Submit a sbatch script containing the command above. 
We provide an sbatch script called nphantom_2.sh which you can use it its entirety or take inspiration from. Using this script, you can run the pipeline in the following way by just replacing ```nextflow run NPhAnToM.sh``` with ```sbatch --mail-user=your@email.com nphantom_2.sh```. Make sure to also provide the script with a directive for --output and --error directories as well as changing the different cache and temp dirs defined in the script. The syntax of the pipeline parameters stays the same when using this command. 
Remember to make sure that the database directories specified in the nextflow.config file are correct for your specific HPC.

```
sbatch --mail-user=your@email.com nphantom_2.sh --IDS SRR123456 -profile cluster 
```

# Run the pipeline with nextflow tower
To monitor the pipeline through nextflow tower, you need to provide an access-token from tower.nf.
```
nextflow run NPhAnToM.nf --IDS SRR1234567890 -profile cluster -with-tower --accessToken qwerty1234567890
```

# Different ways to provide reads to the pipeline
If you have the SRA nr for the reads you want to run through the pipeline, just provide the SRA nr. like this, using the parameter ```--IDS``` in the terminal.
If you already have the reads locally or on an accesible server in a file pair, provide the path to the file pair using the ```--pair_file_names``` parameter and a glob pattern like this.
```
nextflow run NPhAnToM.sh --pair_file_names "/path/to/file/pair/SRR123456_{R1,R2}.fastq.gz"
```
Multiple pairs of reads can be given this way at once by replacing the SRR number with a glob, which takes all reads in a directory and analyzes paired reads together, like this:
```
nextflow run NPhAnToM.sh --pair_file_names "/path/to/file/pair/*_{R1,R2}.fastq.gz"
```
