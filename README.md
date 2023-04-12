# Pipeline for discovering bacteriophages from metagenomic illumina reads.
### A work in progress


## Install and run this pipeline
To install the pipeline, clone the repository using git, and install the necessary dependencies
either using conda or mamba. 

```
git clone https://github.com/anto1282/Bachelor
```

Some of the dependencies need a database, so install those and add the paths for those databases to the
relevant variables in the nextflow.config file.

## Running the pipeline locally
```
nextflow run NPhAnToM.nf --IDS SRR1234567890 -profile standard
```
## Running the pipeline on a cluster
```
nextflow run NPhAnToM.nf --IDS SRR1234567890 -profile cluster
```
## Run the pipeline with nextflow tower
You need an access token from tower.nf
```
nextflow run NPhAnToM.nf --IDS SRR1234567890 -profile standard -with-tower --accessToken qwerty1234567890
```
