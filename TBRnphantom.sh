#!/bin/bash

#SBATCH --job-name=NPhAnToM
#SBATCH --output=/projects/mjolnir1/people/qvx631/Bachelor/BACHELORASSEMBLIES
#SBATCH --error=/projects/mjolnir1/people/qvx631/Bachelor/errors
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=4G
#SBATCH --time=03:00:00
#SBATCH --mail-type=begin
#SBATCH --mail-type=end
#SBATCH --mail-type=fail
#SBATCH --mail-user=s203555@dtu.dk

export NXF_CLUSTER_SEED=$(shuf -i 0-16777216 -n 1)

module purge
module load openjdk/11.0.0
module load miniconda/py39_23.1 singularity/3.8.0 nextflow

export PATH="/opt/software/miniconda/4.10.4/bin:$PATH"

if [ $1 == "-r" ];
then
    srun nextflow run NPhAnToM.nf --IDS SRR23875115	-profile cluster -with-mpi -with-tower -resume --accessToken eyJ0aWQiOiA3MTg2fS43NTEwNGQ1ZmU1ZTllYzI0ZTI0NDg5OWExNWMwMjgwMjY0NGE3OTEx
else
    srun nextflow run NPhAnToM.nf --IDS SRR23875115 -profile cluster -with-mpi -with-tower --accessToken eyJ0aWQiOiA3MTg2fS43NTEwNGQ1ZmU1ZTllYzI0ZTI0NDg5OWExNWMwMjgwMjY0NGE3OTEx
fi
