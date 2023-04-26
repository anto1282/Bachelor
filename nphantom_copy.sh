#!/bin/bash

#SBATCH --job-name=BACHBOYS
#SBATCH --output=/projects/mjolnir1/people/zpx817/BachAssemblies
#SBATCH --error=/projects/mjolnir1/people/zpx817/errors
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=1G
#SBATCH --time=0:30:00
#SBATCH --mail-type=begin
#SBATCH --mail-type=end
#SBATCH --mail-type=fail
#SBATCH --mail-user=s203557@dtu.dk

while [[ $# -gt 0 ]]; do
  case $1 in
    --SRR)
      SRRNUMBER="$2"
      shift # past argument
      shift # past value
      ;;
    --tower)
      TOWERTOKEN="$2"
      shift 
      shift 
      ;;
    --profile)
      PROFILE="$2"
      shift
      shift
      ;;
    --minlength)
      MINLENGTH="$2"
      shift
      shift
      ;;
    --contigs)
      CONTIGS="$2"
      shift
      shift
      ;;
    --resume)
        RESUME=-resume
        shift
        ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done

if [${CONTIGS} == "c"]
then
  CONTIGS="contigs"
fi
elif [${CONTIGS} == "s"]
then
  CONTIGS="scaffolds"
fi
else
  CONTIGS="contigs"
fi
echo ${SRRNUMBER} ${PROFILE} 

export SINGULARITY_LOCALCACHEDIR="/maps/projects/mjolnir1/people/${USER}/SingularityTMP"
export SINGULARITY_TMPDIR="/maps/projects/mjolnir1/people/${USER}/SingularityTMP"



export NXF_CLUSTER_SEED=$(shuf -i 0-16777216 -n 1)
export NXF_CONDA_ENABLED=true

module purge
module load openjdk/11.0.0
module load singularity/3.8.0 nextflow miniconda/4.11.0

srun nextflow run NPhAnToM.nf --IDS ${SRRNUMBER} -profile ${PROFILE} ${RESUME} -with-mpi -with-tower --accessToken ${TOWERTOKEN} --minlength ${MINLENGTH} --contigs ${CONTIGS}

