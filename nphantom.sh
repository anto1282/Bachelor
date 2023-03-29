#!/bin/bash

#SBATCH --job-name=BACHBOYS
#SBATCH --output=/projects/mjolnir1/people/zpx817/BachAssemblies
#SBATCH --error=/projects/mjolnir1/people/zpx817/errors
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=4G
#SBATCH --time=03:00:00
#SBATCH --mail-type=begin
#SBATCH --mail-type=end
#SBATCH --mail-type=fail
#SBATCH --mail-user=s203557@dtu.dk
export NXF_CLUSTER_SEED=$(shuf -i 0-16777216 -n 1)

module purge
module load openjdk/11.0.0
module load miniconda singularity/3.8.0 nextflow

export PATH="/opt/software/miniconda/4.10.4/bin:$PATH"

export PATH="/projects/mjolnir1/apps/conda/pkgs/click-8.1.3-py39hf3d152e_0/python3.9/site-packages/:$PATH"


if [ $1 == "-r" ];
then
    srun nextflow run NPhAnToM.nf --IDS SRR23446273	 -profile AC -resume -with-mpi -with-tower
else
    srun nextflow run NPhAnToM.nf --IDS SRR23446273	 -profile AC -with-mpi -with-tower
fi

aa