#!/bin/bash
#SBATCH --job-name=BACHBOYS
#SBATCH --output=/projects/mjolnir1/people/zpx817/BachAssemblies
#SBATCH --error=/projects/mjolnir1/people/zpx817/errors
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=8G
#SBATCH --time=2:00:00
#SBATCH --mail-type=begin
#SBATCH --mail-type=end
#SBATCH --mail-type=fail
#SBATCH --mail-user=s203557@dtu.dk

conda activate /projects/mjolnir1/apps/conda/iphop-1.2.0
iphop predict --fa_file /projects/mjolnir1/people/zpx817/PipeLineFolder/Bachelor/Results/SRR23446273/ViralContigs/SRR23446273_ViralContigs.fasta --db_dir /maps/projects/mjolnir1/data/databases/iphop/20230317/Sept_2021_pub --out_dir /projects/mjolnir1/people/zpx817/PipeLineFolder/Bachelor/Results/SRR23446273/ViralContigs/iphop_prediction --num_threads 8
