#!/bin/bash

#SBATCH --job-name=NPhAnToM
#SBATCH --output=/projects/mjolnir1/people/qvx631/BACHELORASSEMBLIES
#SBATCH --error=/projects/mjolnir1/people/qvx631/errors
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=4G
#SBATCH --time=02:00:00
#SBATCH --mail-type=begin
#SBATCH --mail-type=end
#SBATCH --mail-type=fail
#SBATCH --mail-user=s203555@dtu.dk

export NXF_CLUSTER_SEED=$(shuf -i 0-16777216 -n 1)

module purge
module load openjdk/11.0.0
module load miniconda singularity/3.8.0 nextflow
srun 

if [ $1 == "-r" ];
then
    srun nextflow run NPhAnToM.nf -profile TC -with-mpi -with-tower -resume
else
    srun nextflow run NPhAnToM.nf -profile TC -with-mpi -with-tower
fi
