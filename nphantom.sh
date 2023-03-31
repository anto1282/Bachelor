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
export NXF_CONDA_ENABLED=true

module purge
module load openjdk/11.0.0
module load singularity/3.8.0 nextflow
module load mamba/1.3.1
export PATH="/opt/software/miniconda/py39_23.1/bin:$PATH"



if [ $1 == "-r" ];
then
    srun nextflow run NPhAnToM.nf --IDS SRR23446273	 -profile AC -resume -with-mpi -with-tower
else
    srun nextflow run NPhAnToM.nf --IDS SRR23446273	 -profile AC -with-mpi -with-tower
fi

