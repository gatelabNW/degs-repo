#!/bin/bash
#SBATCH --account p31535
#SBATCH --partition genhimem
#SBATCH --job-name FastIntegration-2_remove-unannotated
#SBATCH --nodes 1
#SBATCH --nodelist qhimem0206
#SBATCH --mem 0
#SBATCH --ntasks-per-node 20
#SBATCH --time 6:00:00
#SBATCH --output /projects/b1169/projects/rosmap-project/documents/logs/%x.oe%j.log
#SBATCH --verbose
#SBATCH --mail-type=ALL
#SBATCH --mail-user=austin.reed@northwestern.edu
#SBATCH --dependency=afterok:6427015

date
cd /projects/p31535/austin/degs-repo
bash /projects/p31535/austin/degs-repo/sbatch/generate-degs.sh
Rscript r/main.R
