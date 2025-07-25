#!/bin/bash

# Slurm directives
#SBATCH --gres=gpu:1
#SBATCH --qos=normal
#SBATCH --partition=a40
#SBATCH --mem=20G
#SBATCH --cpus-per-task=4
#SBATCH --time=12:00:00
#SBATCH --output=slurm_logs/output_logs/output-wv.log
#SBATCH --error=slurm_logs/error_logs/error-wv.log
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mercurymcindoe@gmail.com
source /scratch/ssd004/scratch/merc0606/miniconda3/etc/profile.d/conda.sh
conda activate NSERC

cd ~/NSERC/data/scripts_for_data

IMAGE_DIR=~/NSERC/data/MSCOCO_images   

for weight_path in ~/NSERC/data/weights/mscoco/*/0_weights.pt; do 
    [[ -e "$weight_path" ]] | continue

    save_dir=$(dirname "$weight_path")
    echo "Running on $weight_path -> $save_dir"
    python weight_visualization.py "$IMAGE_DIR" "$weight_path" "$save_dir"

done