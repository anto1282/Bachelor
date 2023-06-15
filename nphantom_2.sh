#!/bin/bash

#SBATCH --job-name=NPhAnToM_%j
#SBATCH --output=/projects/mjolnir1/people/%u/nextflowout/stdout_%j
#SBATCH --error=/projects/mjolnir1/people/%u/nextflowout/error_%j
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=32:00:00
#SBATCH --mail-type=begin
#SBATCH --mail-type=end
#SBATCH --mail-type=fail


export SINGULARITY_CACHEDIR="/maps/projects/mjolnir1/people/${USER}/SingularityTMP"
export SINGULARITY_LOCALCACHEDIR="/maps/projects/mjolnir1/people/${USER}/SingularityTMP"
export SINGULARITY_TMPDIR="/maps/projects/mjolnir1/people/${USER}/SingularityTMP"

export NXF_CLUSTER_SEED=$(shuf -i 0-16777216 -n 1)
export NXF_CONDA_ENABLED=true

#re-direct tmp files away from /tmp directories on compute nodes or the headnode
export NXF_TEMP=/maps/projects/mjolnir1/people/${USER}/.tmp_nfcore

mkdir -p $(pwd)/${SLURM_JOB_NAME}_work
export NXF_WORK=$(pwd)/${SLURM_JOB_NAME}_work

module purge
module load openjdk/17.0.3
module load singularity/3.8.6 nextflow/22.10.4 miniconda/4.11.0

echo $NXF_WORK

srun nextflow run NPhAnToM.nf $@ 
