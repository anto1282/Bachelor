#!/bin/bash

#SBATCH --job-name=BACHBOYS
#SBATCH --output=/projects/mjolnir1/people/zpx817/BachAssemblies
#SBATCH --error=/projects/mjolnir1/people/zpx817/errors
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=2G
#SBATCH --time=1:00:00
#SBATCH --mail-type=begin
#SBATCH --mail-type=end
#SBATCH --mail-type=fail
#SBATCH --mail-user=s203557@dtu.dk



singularity pull --dir /maps/projects/mjolnir1/data/cache/nf-core/singularity docker://quay.io/biocontainers/pharokka:1.2.1--hdfd78af_0 
singularity run -B /projects/mjolnir1/people/zpx817/PipeLineFolder/Bachelor/Results/SRR23446273/ViralContigs/SRR23446273_ViralContigs.fasta,/projects/mjolnir1/people/zpx817/PipeLineFolder/Bachelor/PLSPHAROKKA,/projects/mjolnir1/apps/conda/pharokka-1.2.1/pharokka_v1.2.0_databases /maps/projects/mjolnir1/data/cache/nf-core/singularity/pharokka_1.2.1--hdfd78af_0.sif pharokka.py -i /projects/mjolnir1/people/zpx817/PipeLineFolder/Bachelor/Results/SRR23446273/ViralContigs/SRR23446273_ViralContigs.fasta -o $HOME/output -f -t 4 -d /projects/mjolnir1/apps/conda/pharokka-1.2.1/pharokka_v1.2.0_databases -g prodigal -m
mv $HOME/output /projects/mjolnir1/people/zpx817/PipeLineFolder/Bachelor/PLSPHAROKKA