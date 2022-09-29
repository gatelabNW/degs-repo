#!/bin/bash
#SBATCH --account p31535
#SBATCH --partition genhimem
#SBATCH --job-name generate-degs
#SBATCH --nodes 1
#SBATCH --nodelist qhimem0206
#SBATCH --mem 1500G
#SBATCH --ntasks-per-node 52
#SBATCH --time 48:00:00
#SBATCH --output /projects/b1169/projects/rosmap-project/documents/logs/%x.oe%j.log
#SBATCH --verbose
#SBATCH --mail-type=ALL
#SBATCH --mail-user=austin.reed@northwestern.edu

date
cd /projects/p31535/austin/degs-repo
# bash /projects/p31535/austin/degs-repo/config/load-modules.sh
module purge
module load R/4.2.0
module load pigz/2.4
module load curl/7.73.0
module load hdf5/1.8.19-serial
module load geos/3.8.1
Rscript scripts/rosmap-project/main-2.R
