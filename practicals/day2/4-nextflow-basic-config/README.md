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
conda.enabled = true
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
singularity.enabled = true
conda.enabled = false
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


# Exercise 5 – Use `params.yaml` to centralize parameters

## Why use `params.yaml`?

When pipelines grow, command lines become long and error-prone:

```bash
nextflow run main.nf \
  --input_file ... \
  --reference_genome ... \
  --outdir ...
```

To improve reproducibility and readability, we can store all parameters in a YAML file.

---

## Step 1 – Create `params.yaml`

Example:

```yaml
input_file: ./assets/test_input.tsv

reference_genome: /processing_data/reference_datasets/iGenomes/2025.1/Homo_sapiens/NCBI/GRCh38/Sequence/BWAIndex/genome.fa

outdir: test_GRCh38

publish_mode: copy
```

---

## Step 2 – Run using the params file

```bash
nextflow run main.nf -params-file params.yaml
```

---

## What happens internally?

Nextflow loads all values from `params.yaml` and assigns them to:

```nextflow
params.input_file
params.reference_genome
params.outdir
params.publish_mode
```

---

## Advantages

* Cleaner command line
* Easier reproducibility
* Easy to share configurations between users
* Allows multiple parameter sets for different experiments

---

# Exercise 6 – Run the full workflow (FASTP, BWA, SAMTOOLS)

Now we enable the full workflow by uncommenting the related processes in `main.nf`.

We will use containers for each tool.

---

## Process containers

### FASTP

```nextflow
container 'quay.io/biocontainers/fastp:1.0.1--heae3180_0'
```

---

### ALIGNMENT: BWA_MEM

```nextflow
container 'community.wave.seqera.io/library/bwa_htslib_samtools:83b50ff84ead50d0'
```

---

### ALIGNMENT: SAMTOOLS_MERGE

```nextflow
container 'quay.io/biocontainers/samtools:1.22--h96c455f_0'
```

---

## Run the full workflow

```bash
nextflow run main.nf -params-file params.yaml -resume
```

---

## Expected issue

Some processes will fail with:

```text
Command exit status:
  247
```

---

## Why?

Exit status 247 indicates that the scheduler killed the process, usually due to:

* Insufficient memory
* Insufficient CPUs
* Time limit exceeded

In our case, it is mainly **memory**.

---

## Fix: increase resources

Example:

```nextflow
process FASTP {
  ...
  cpus 2
  memory '4.GB'
  ...
}

process BWA_MEM {
    ...
    cpus 4
    memory '8.GB'
    ...

}

process SAMTOOLS_MERGE {
    ...
    cpus 2
    memory '4.GB'
    ...
}
```

---

## Key lesson

Containers provide software, but **resources are controlled only by Nextflow**.

Containers do NOT manage memory or CPU limits.

---

# Exercise 7 – How resources are handled inside modules

We now analyze the `BWA_MEM` module.

Inside the process script you will see something like:

```bash
bwa mem -t ${task.cpus} ref.fa reads.fq > output.sam
```

---

## What is `task.cpus`?

`task.cpus` is automatically set by Nextflow based on:

```nextflow
cpus X
```

in the process definition.

So:

```nextflow
cpus 8
```

becomes:

```bash
-t 8
```

inside the command.

---

## What about `task.memory`?

`task.memory` contains the memory assigned to the job, for example:

```nextflow
memory '16 GB'
```

Inside the script you can use:

```bash
echo "Memory assigned: ${task.memory}"
```

Some tools allow memory specification; others only benefit indirectly through Java or buffer allocation.

---

## Why this is important

This means:

* The module adapts automatically to different resource settings.
* The same module can run on laptop, cluster, or cloud.
* Resource tuning is separated from pipeline logic.

---

## Best practice

Modules should always use:

* `task.cpus`
* `task.memory`
* `task.time`

instead of hard-coding values.

---

# Extra Exercise – Configure Singularity runtime properly

On HPC systems, Singularity requires careful configuration.

Add to `nextflow.config`:

```nextflow
singularity.cacheDir = "/path/.singularity"

process.scratch = "$TMPDIR"

process.beforeScript = 'module load singularity/3.8.5'

process.containerOptions = '-B /localscratch'
```

---

## Explanation

### `singularity.cacheDir`

Defines where Singularity stores images.
This avoids filling up home directories.

---

### `process.scratch`

Tells Nextflow to run each process in a temporary directory for better I/O performance.

---

### `process.beforeScript`

Loads the Singularity module before executing each process.

---

### `process.containerOptions`

Binds local scratch storage into the container for fast temporary I/O.

---

## Why this matters

Without this configuration:

* Containers may fail to pull images.
* Disk quotas may be exceeded.
* Performance may be very poor.

---

# Final takeaway

After these exercises you should understand:

| Topic        | You learned                  |
| ------------ | ---------------------------- |
| Parameters   | CLI vs params.yaml           |
| Environments | Conda vs Singularity         |
| Containers   | Tool isolation               |
| Resources    | cpus, memory, task variables |
| HPC          | Scheduler interaction        |
| Modules      | Portable design              |
| Caching      | Resume and reuse             |
| Scratch      | Performance optimization     |

---

With Nextflow configuration files you can:

* Switch environments (Conda, Singularity, HPC) without touching pipeline code.
* Control resources centrally.
* Make pipelines portable, reproducible, and scalable.

