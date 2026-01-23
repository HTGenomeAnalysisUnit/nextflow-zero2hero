# 0. Setting up the nf-core environment on the cluster

This section describes how to install **nf-core tools** and **Nextflow** on the cluster.
These tools will be used throughout this course.

## Why this setup?

* **nf-core tools** is a Python package that provides utilities for Nextflow pipeline development and execution.
* It is **not available as a system module** on the cluster.
* **Frequent updates** may be necessary during development, so managing it in your own environment is preferable.
* To keep installations isolated, we will use a **python virtual environment** rather than user-wide installation.

---

## 1. Start an interactive session on the cluster

All installation steps must be performed on a compute node, not on the login node.

1. Open a terminal on your local machine

2. Connect to the cluster:

   ```bash
   ssh <username>@hpclogin.fht.org
   ```

3. Start an interactive shell:

   ```bash
   srun --wait=0 --pty -p cpu-interactive -c 1 --mem 8G -J nxf_training /bin/bash
   ```

You should now be on a compute node with an interactive shell.

---

## 2. Create a Python virtual environment with nf-core and Nextflow

### Load required modules

First, load the necessary modules: Python for creating the virtual environment,
and OpenJDK which is required to run Nextflow.

```bash
module load python/3.11.9
module load openjdk/17.0.8.1_1
```

### Create and activate the environment

Create the environment in **scratch space**, which provides faster read/write performance:

```bash
python -m venv /scratch/$USER/nf-core
source /scratch/$USER/nf-core/bin/activate
```

### Install nf-core and Nextflow

With the environment activated, install the latest versions of
**nf-core tools** and **Nextflow** from PyPI using `pip`:

```bash
pip install nextflow nf-core
```

---

## 3. Load Singularity module

The Singularity module on the cluster requires a different
Python version, so unload Python first, then load Singularity:

```bash
module unload python
module load singularity
```

Verify that all tools are installed and accessible:

```bash
nf-core --version
nextflow -version
singularity --version
```

