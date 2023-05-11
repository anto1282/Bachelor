#!/bin/bash

mkdir -p /maps/projects/mjolnir1/people/${USER}/SingularityTMP
export SINGULARITY_LOCALCACHEDIR="/maps/projects/mjolnir1/people/${USER}/SingularityTMP"
export SINGULARITY_TMPDIR="/maps/projects/mjolnir1/people/${USER}/SingularityTMP"



export NXF_CLUSTER_SEED=$(shuf -i 0-16777216 -n 1)
export NXF_CONDA_ENABLED=true

module purge
module load openjdk/1.0.0
module load singularity/3.8.0 nextflow miniconda/4.11.0
