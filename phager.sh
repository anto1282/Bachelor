#!/bin/bash

#SBATCH --job-name=PHAGERTBR
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

cd /maps/projects/mjolnir1/people/qvx631/Bachelor/work/32/49a41dd86313922436024ff4bf10ab


phager.py -c 1000 -a scaffolds.fasta -d SRR23875115_phagerresults -v

echo $PATH