# Pipeline for discovering bacteriophages from metagenomic illumina reads.
### A work in progress

## About NPhAnToM - Nextflow Pipeline for Phage AnnoTation of Metagenomic samples
NPhAnToM is a nextflow pipeline for prediction and annotation of phages in environmental samples, along with phage host prediction using industry standard bioinformatics tools.

The NPhAnTom pipeline consists of several steps:
- Download reads: fasterqdump for downloading illumina reads from the short read archive.
- Trimming reads: adapterremoval, bbduk.sh
- Removing eukaryotic reads: kraken
- Assembly: metagenomic spades
- N50: assembly quality check using stats.sh
- Virus prediction: A combination of DeepVirFinder, Seeker and Phager
- Quality check of viral contigs: CheckV
- Phage annotation: Pharokka
- Phage host prediction: IPHOP


## Install the pipeline
To install the pipeline, clone the repository using git, and install the necessary dependencies either using conda or mamba. 

```
git clone https://github.com/anto1282/Bachelor
```

Some of the dependencies need a database, so install those and add the paths for those databases to the relevant variables in the nextflow.config file.

Take a look at the configuration file for the pipeline, the 'nextflow.config' file, and make sure to type in the correct paths for all the databases.



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
