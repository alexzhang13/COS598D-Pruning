#!/bin/sh

# Remove one # to uncommment
#SBATCH --output=./Logs/%x-%j.out

# Define, how many nodes you need. Here, we ask for 1 node.
#SBATCH -N 1 #nodes
#SBATCH -n 1 #tasks
#SBATCH --cpus-per-task=1
#SBATCH --mem=32G
#SBATCH --time=1-00:00:00    # Run for 4 hours
#SBATCH --gres=gpu:1

# on average one GPU takes 5 cpu and 20GB memory

# Turn on mail notification. There are many possible self-explaining values:
# NONE, BEGIN, END, FAIL, ALL (including all aforementioned)
# For more values, check "man sbatch"
#SBATCH --mail-type=ALL
# Remember to set your email address here instead of nobody
#SBATCH --mail-user=alzhang@cs.princeton.edu


# Define and create a unique scratch directory for this job
tag=run_compression;
OUT_DIRECTORY='./Logs/'${tag}
mkdir ${OUT_DIRECTORY};

# Submit jobs.
for dataset in "cifar10"; do
    for model in "vgg16"; do
        for pruner in "snip" "grasp" "synflow" "rand"; do # "mag" 
            for cp in 0.1 0.2 0.5 1 2; do
                if [ "$pruner" == "mag" ]
                then 
                    srun python main.py \
                    --pre-epochs 200 \
                    --post-epochs 50 \
                    --verbose \
                    --expid NoBut_HYP_${dataset}_${model}_${pruner}_${cp} \
                    --model-class lottery \
                    --model ${model} \
                    --dataset ${dataset} \
                    --experiment singleshot \
                    --pruner ${pruner} \
                    --compression ${cp} \
                    > Logs/NoButterfly/HYP_${dataset}_${model}_${pruner}_${cp}.txt
                elif [ "$pruner" == "butterfly" ]
                then
                    srun python main.py \
                    --verbose \
                    --post-epochs 50 \
                    --expid NoBut_HYP_${dataset}_${model}_${pruner}_${cp} \
                    --model-class lottery \
                    --model ${model} \
                    --dataset ${dataset} \
                    --experiment singleshot \
                    --pruner snip \
                    --compression 0 \
                    --butterfly-layers true \
                    > Logs/NoButterfly/HYP_${dataset}_${model}_${pruner}_${cp}.txt
                else
                    srun python main.py \
                    --verbose \
                    --post-epochs 50 \
                    --expid NoBut_HYP_${dataset}_${model}_${pruner}_${cp} \
                    --model-class lottery \
                    --model ${model} \
                    --dataset ${dataset} \
                    --experiment singleshot \
                    --pruner ${pruner} \
                    --compression ${cp} \
                    > Logs/NoButterfly/HYP_${dataset}_${model}_${pruner}_${cp}.txt
                fi;
            done;
        done;
    done;
done;
wait; #Make sure to wait till all the runs have completed.

# Finish the script
exit 0
