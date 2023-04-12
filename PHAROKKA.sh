#!/bin/bash

#SBATCH --job-name=BACHBOYS
#SBATCH --output=/projects/mjolnir1/people/zpx817/BachAssemblies
#SBATCH --error=/projects/mjolnir1/people/zpx817/errors
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=4G
#SBATCH --time=12:00:00
#SBATCH --mail-type=begin
#SBATCH --mail-type=end
#SBATCH --mail-type=fail
#SBATCH --mail-user=s203557@dtu.dk



"singularity pull docker://quay.io/biocontainers/pharokka:1.3.0--hdfd78af_0 -d /maps/projects/mjolnir1/data/cache/nf-core/singularity"
"singularity run /maps/projects/mjolnir1/data/cache/nf-core/singularity/pharokka:1.3.0--hdfd78af_0.img -i /projects/mjolnir1/people/zpx817/PipeLineFolder/Bachelor/Results/SRR23446273/ViralContigs/SRR23446273_ViralContigs.fasta -o /projects/mjolnir1/people/zpx817/PipeLineFolder/Bachelor/PLSPHAROKKA -f -t 4 -d /projects/mjolnir1/apps/conda/pharokka-1.2.1/pharokka_v1.2.0_databases -g prodigal -m"
