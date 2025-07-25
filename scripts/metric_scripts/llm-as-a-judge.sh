#!/bin/bash

# Slurm directives
#SBATCH --gres=gpu:2
#SBATCH --qos=normal
#SBATCH --partition=a40
#SBATCH --mem=80G
#SBATCH --cpus-per-task=14
#SBATCH --time=16:00:00
#SBATCH --output=slurm_logs/output_logs/output-llmjudge.log
#SBATCH --error=slurm_logs/error_logs/error-llmjudge.log
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mercurymcindoe@gmail.com

module load cuda-12.4
export CUDA_HOME=/pkgs/cuda-12.4
export PATH=$CUDA_HOME/bin:$PATH

echo "CUDA_HOME = $CUDA_HOME"
which nvcc
python -c "import torch; print(torch.version.cuda); print(torch.cuda.is_available()); print(torch.cuda.get_device_name(0))"

source /scratch/ssd004/scratch/merc0606/miniconda3/etc/profile.d/conda.sh
conda activate internvl

# python gradioServer.py &
# SERVER_PID=$!

# until curl -s http://127.0.0.1:7860/; do
#     echo "Waiting for server to start"
#     sleep 2 
# done

# echo "Server launched, now running client"

# sleep 20

# python gradioClient.py "$GT_CAPTIONS" "$GEN_CAPTIONS" "$SAVE_DIR"

# kill $SERVER_PID

GT_CAPTIONS=~/NSERC/data/generated_captions/CUB_captions/CUB_captions.json
SAVE_DIR=~/NSERC/data/generated_captions/jun26_samples/llm-judge-ratings
gen_captions=(
    # ~/NSERC/data/generated_captions/jun26_samples/generated_captions/cub/plain_captions.json
    ~/NSERC/data/generated_captions/jun26_samples/generated_captions/cub/pd_last_captions.json
    ~/NSERC/data/generated_captions/jun26_samples/generated_captions/cub/pdm_last_captions.json
    ~/NSERC/data/generated_captions/jun26_samples/generated_captions/cub/pdt_last_captions.json
    ~/NSERC/data/generated_captions/jun26_samples/generated_captions/cub/pdtm_last_captions.json
    ~/NSERC/data/generated_captions/jun26_samples/generated_captions/cub/gaussian_last_captions.json
)

cd ~/NSERC/eval/captions/llm-as-a-judge

for GEN_CAPTIONS in "${gen_captions[@]}";
do 
    python qwen3B-judge.py "$GT_CAPTIONS" "$GEN_CAPTIONS" "$SAVE_DIR" || {
        echo "Failed on $GEN_CAPTIONS"
        exit 1
    }
done



