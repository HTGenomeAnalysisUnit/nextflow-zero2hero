# Nextflow - from zero2hero practicals

This folder contains all the code examples used during training. The practicals are organized by day and then in section for each day, following the course schedule.
Each section folder will contain a `README.md` file with detailed instructions for the practical exercises.

- Course repository: `https://github.com/HTGenomeAnalysisUnit/nextflow-zero2hero`
- Training folder on HT HPC: `/project/nextflow_zero2hero/`

## Before you begin

Before you start the practicals, please connect to the HT HPC system and make sure you have the following prerequisites in place:

1. You can read from the course training folder: `/project/nextflow_zero2hero/`. Please try `ls /project/nextflow_zero2hero/` to verify you have access.
2. You can load the Nextflow module by running: `module load Nextflow/25.04.3`.
3. You can load the Singularity module by running: `module load singularity`.

## Setup your working space

It's recommended to create your own working directory to store your practical exercises.

For example, you can create a directory in your home folder or in your group folder. For example:

```bash
# Create a directory in your home folder
mkdir -p ~/nextflow_zero2hero_practicals
cd ~/nextflow_zero2hero_practicals

# Or create a directory in your group folder
mkdir -p /project/your_group/your_username/nextflow_zero2hero_practicals
cd /project/your_group/your_username/nextflow_zero2hero_practicals
```

Now please move into your working directory and clone the course repository there:

```bash
git clone https://github.com/HTGenomeAnalysisUnit/nextflow-zero2hero.git
cd nextflow-zero2hero
```

You are now ready to start the practical exercises! Navigate to the appropriate day and section folder to begin.

You are free to modify files in your local copy of the repository as needed for the practicals.

## How to run the practicals on HT HPC

1. Before starting tests and runs, get an interactive session on a compute node with sufficient resources. An example command is below, you can adjust the parameters as needed (`-c` for number of CPU cores, `--mem` for memory, `-J` for job name):

```bash
srun --wait=0 --pty -p cpu-interactive -c 1 --mem 4G -J nxf_training /bin/bash
```

2. Load the Nextflow module and the Singularity module in your interactive session:

```bash
module load singularity
module load nextflow/25.04.3
```