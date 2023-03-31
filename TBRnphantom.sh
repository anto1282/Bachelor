#!/bin/bash

#SBATCH --job-name=NPhAnToM
#SBATCH --output=/projects/mjolnir1/people/qvx631/Bachelor/BACHELORASSEMBLIES
#SBATCH --error=/projects/mjolnir1/people/qvx631/Bachelor/errors
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=4G
#SBATCH --time=01:00:00
#SBATCH --mail-type=begin
#SBATCH --mail-type=end
#SBATCH --mail-type=fail
#SBATCH --mail-user=s203555@dtu.dk

export NXF_CLUSTER_SEED=$(shuf -i 0-16777216 -n 1)

# Get the aliases and functions
#if [ -f ~/.bashrc ]; then
#        . ~/.bashrc
#fi


module purge
module load openjdk/11.0.0
module load miniconda/4.10.4 singularity/3.8.0 nextflow
module load mamba/1.3.1

export PATH="/projects/mjolnir1/apps/conda/py39/lib/python3.9/site-packages:$PATH"

export PATH="/projects/mjolnir1/apps/conda/pkgs/click-8.1.3-py39hf3d152e_0/python3.9/site-packages/:/opt/software/miniconda/4.10.4/bin:/projects/mjolnir1/apps/conda/mamba-1.3.1/bin:/opt/software/nextflow/22.04.3:/opt/software/singularity/3.8.0/bin:/opt/software/miniconda/py39_23.1/bin:/opt/software/openjdk/11.0.0/bin:/projects/mjolnir1/apps/bin:/home/zpx817/bin:/opt/software/miniconda/4.10.4/bin:/opt/software/miniconda/4.10.4/condabin:/projects/mjolnir1/apps/bin:/home/zpx817/bin:/usr/share/Modules/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/opt/software/miniconda/4.10.4/bin:/opt/software/miniconda/4.10.4/bin:$PATH"

if [ $1 == "-r" ];
then
    srun nextflow run NPhAnToM.nf --IDS SRR23875115	-profile cluster -with-mpi -with-tower -resume --accessToken eyJ0aWQiOiA3MTg2fS43NTEwNGQ1ZmU1ZTllYzI0ZTI0NDg5OWExNWMwMjgwMjY0NGE3OTEx
else
    srun nextflow run NPhAnToM.nf --IDS SRR23875115 -profile cluster -with-mpi -with-tower --accessToken eyJ0aWQiOiA3MTg2fS43NTEwNGQ1ZmU1ZTllYzI0ZTI0NDg5OWExNWMwMjgwMjY0NGE3OTEx
fi

echo $PATH