#!/bin/bash
#SBATCH --time=96:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --partition=cpuq
#SBATCH --job-name=nf_data_pipelines
#SBATCH --mem=2GB
#SBATCH --mail-type=END
#SBATCH --output=%x_%j.log
 
echo; echo "Starting slurm job..."
echo "PWD:  $(pwd)"
echo "HOST: $(hostname)"
echo "DATE: $(date)"; echo
 
# >>> conda initialize >>>
__conda_setup="$('/facility/nfdata-omics/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
eval "$__conda_setup"
unset __conda_setup
# <<< conda initialize <<<


# load singularity and snakemake
module load singularity
module load openjdk/17.0.8.1_1
conda activate nextflow-25.10.0


nextflow run main.nf \
	-profile ht_cluster \
	-params-file params.yaml \
	-resume 

echo; echo "Terminating slurm job..."
echo "DATE: $(date)"; echo
exit