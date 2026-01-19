# Nextflow Configuration – Practical Session

In this practical session we will explore how **Nextflow configuration files** control how a pipeline is executed.
You will learn how to switch between Conda, Singularity, and HPC execution simply by editing `nextflow.config`, without changing the pipeline code.

---

## Learning objectives

By the end of this session you should be able to:

* Write and understand a Nextflow configuration file.
* Use configuration files to define:

  * Parameters
  * Environment variables
  * Process directives (cpus, memory, container, conda, executor).
* Enable and disable execution backends:

  * Conda
  * Singularity
  * HPC schedulers (SLURM).
* Understand how configuration affects pipeline portability.

---

# Exercise 1 – Run the pipeline without Conda

Inside this folder you will find a simple pipeline that:

1. Creates reference genome indexes.
2. Runs a basic alignment workflow.

Run the pipeline:

```bash
nextflow run main.nf \
  --input_file ./assets/test_input.tsv \
  --reference_genome /processing_data/reference_datasets/iGenomes/2025.1/Homo_sapiens/NCBI/GRCh38/Sequence/BWAIndex/genome.fa \
  --outdir test
```

---

## Output

You should see an error similar to:

```text
Command exit status:
  127
```

### Question

What does exit status **127** mean?

### Explanation

Exit code **127** means:

> The command was not found.

This happens because the required tools (e.g. `gatk`, `samtools`) are **not available in the environment**.

This motivates the need for **Conda environments**.

---

# Exercise 1b – Enable Conda environments

We will now configure Nextflow to use Conda environments for the processes.

### Step 1 – Modify the process definitions

Add the following line to both processes:

* `GATK4_CREATESEQUENCEDICTIONARY`
* `SAMTOOLS_FAIDX`

```nextflow
conda "${moduleDir}/environment.yml"
```

---

### Step 2 – Enable Conda in `nextflow.config`

Edit `nextflow.config` and add:

```nextflow
conda.enable = true
```

---

### Step 3 – Run again

```bash
nextflow run main.nf \
  --input_file ./assets/test_input.tsv \
  --reference_genome /processing_data/reference_datasets/iGenomes/2025.1/Homo_sapiens/NCBI/GRCh38/Sequence/BWAIndex/genome.fa \
  --outdir test_grch38
```

---

### Question

What changed compared to the previous run?

### Explanation

Now Nextflow:

1. Creates a Conda environment from `environment.yml`.
2. Runs each process inside that environment.
3. Finds the required tools correctly.

The pipeline should now proceed further.

---

# Exercise 2 – Change default parameters using `nextflow.config`

Now we will run the same pipeline using a **different reference genome**.

List the available references:

```bash
ls /processing_data/reference_datasets/iGenomes/2025.1/Homo_sapiens/NCBI/
```

Choose a different reference, for example:

```text
/processing_data/reference_datasets/iGenomes/2025.1/Homo_sapiens/NCBI/build37.1/Sequence/BWAIndex/genome.fa
```

Run the pipeline again:

```bash
nextflow run main.nf \
  --input_file ./assets/test_input.tsv \
  --reference_genome /processing_data/reference_datasets/iGenomes/2025.1/Homo_sapiens/NCBI/build37.1/Sequence/BWAIndex/genome.fa \
  --outdir test_build37.1 \
  -resume
```

---

### What does `-resume` do?

It tells Nextflow to reuse results from previous executions when possible, avoiding recomputation.

---

# Exercise 3 – Use Singularity containers

Containers are often built from Docker images and converted to Singularity images for HPC usage.

We will now switch from Conda to Singularity.

---

## Step 1 – Modify process containers

### SAMTOOLS_FAIDX

```nextflow
container 'quay.io/biocontainers/samtools:1.22--h96c455f_0'
```

### GATK4_CREATESEQUENCEDICTIONARY

```nextflow
container 'community.wave.seqera.io/library/gatk4_gcnvkernel:edb12e4f0bf02cd3'
```

---

## Step 2 – Update `nextflow.config`

```nextflow
singularity.enable = true
conda.enable = false
```

---

## Step 3 – Run again

```bash
nextflow run main.nf \
  --input_file ./assets/test_input.tsv \
  --reference_genome /processing_data/reference_datasets/iGenomes/2025.1/Homo_sapiens/NCBI/GRCh38/Sequence/BWAIndex/genome.fa \
  --outdir test_GRCh38 \
  -resume
```

---

### What is happening now?

Each process is executed inside a Singularity container instead of a Conda environment.

---

# Exercise 4 – Run on an HPC cluster

## What is an HPC?

An HPC (High Performance Computing) cluster is a group of machines managed by a scheduler (e.g. SLURM).
Jobs are submitted to queues and executed with specific resource requests (CPUs, memory, time).

Nextflow interacts with the scheduler through the **executor**.

---

## Step 1 – Configure SLURM in `nextflow.config`

```nextflow
executor = "slurm"
queue    = "cpuq"
```

---

## Step 2 – Run on the cluster

```bash
nextflow run main.nf \
  --input_file ./assets/test_input.tsv \
  --reference_genome /processing_data/reference_datasets/iGenomes/2025.1/Homo_sapiens/NCBI/GRCh38/Sequence/BWAIndex/genome.fa \
  --outdir test_GRCh38 \
  -resume
```

---

## Monitor your jobs

```bash
squeue -u name.surname
```

---

## Output

You will likely see:

```text
Command exit status:
  247
```

---

## Question

How many resources are given to each process?

---

## Explanation

If no resources are defined, Nextflow uses **default values**, which are usually:

* 1 CPU
* ~1–2 GB memory

This is not enough for GATK, so the job is killed by the scheduler (OOM kill).

---

## Solution – Set process resources

Modify the process definition:

```nextflow
process GATK4_CREATESEQUENCEDICTIONARY {

    conda "${moduleDir}/environment.yml"
    publishDir "${params.outdir}/genome_index", mode: params.publish_mode
    container 'community.wave.seqera.io/library/gatk4_gcnvkernel:edb12e4f0bf02cd3'

    cpus 4
    memory '8 GB'

    ...
}
```

---

### What changed?

Now Nextflow will request:

* 4 CPUs
* 8 GB RAM

from SLURM, and the job will run successfully.

---

# Final takeaway

With Nextflow configuration files you can:

* Switch environments (Conda, Singularity, HPC) without touching pipeline code.
* Control resources centrally.
* Make pipelines portable, reproducible, and scalable.

---

If you want, I can now:

* Add diagrams for Conda vs Singularity vs HPC.
* Convert this README into Markdown with callout boxes.
* Or rewrite it into a teaching slide format.
