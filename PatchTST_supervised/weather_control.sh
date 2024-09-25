#!/usr/bin/bash
#SBATCH --partition=tier3
#SBATCH --account=examm
#SBATCH --mem=32G
#SBATCH --time=05-00:00:00  # 5 days
#SBATCH --mail-user=slack:@rn7823
#SBATCH --mail-type=ALL
#SBATCH --output=output/%x_%j.out    # Standard output log
#SBATCH --error=error/%x_%j.err      # Standard error log

# Get the current date
DATE_TIME=$(date +"%Y%m%d_%H%M")

# Create output and error directories
mkdir -p output error logs logs/LongForecasting

# Activate the virtual environment
source venv/bin/activate

# Set your variables
seq_len=336
model_name=PatchTST
root_path_name=./dataset/
data_path_name=weather.csv
model_id_name=weather
data_name=custom
random_seed=2021

# Loop through prediction lengths and run the experiment
for pred_len in 96 192 336 720
do
    # Run the python script with specific parameters and log output
    python -u run_longExp.py \
      --random_seed $random_seed \
      --is_training 1 \
      --root_path $root_path_name \
      --data_path $data_path_name \
      --model_id ${model_id_name}_${seq_len}_${pred_len} \
      --model $model_name \
      --data $data_name \
      --features M \
      --seq_len $seq_len \
      --pred_len $pred_len \
      --enc_in 21 \
      --e_layers 3 \
      --n_heads 16 \
      --d_model 128 \
      --d_ff 256 \
      --dropout 0.2 \
      --fc_dropout 0.2 \
      --head_dropout 0 \
      --patch_len 16 \
      --stride 8 \
      --des 'Exp' \
      --train_epochs 100 \
      --patience 20 \
      --itr 1 \
      --batch_size 128 \
      --learning_rate 0.0001 \
      > logs/LongForecasting/${model_name}_${model_id_name}_${seq_len}_${pred_len}.log 2>&1
done

# Deactivate the virtual environment
deactivate
