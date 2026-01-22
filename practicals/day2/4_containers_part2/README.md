# Configure containers in Nextflow

## Goal

Create a Nextflow module named **`FASTQC`** that runs **FastQC** inside a **Singularity** container.

---

## Requirements

### 1) Inputs
- The module must **take as input** a list of **FASTQ files** located in the `assets/` folder.

### 2) Outputs
- The module must **emit** the following tuple:

```nextflow
tuple val(sample_id), path("*_fastqc.zip"), path("*_fastqc.html")
```

### 3) Container (Singularity)
- The module must use a **Singularity container** that provides `fastqc`.
- You may use **any public image repository** (e.g., BioContainers, Quay, DockerHub) as the source.

### 4) Nextflow configuration
- Enable Singularity in the Nextflow configuration using the appropriate options (e.g., enabling Singularity, setting cache directory, auto-mounts, etc.).

### 5) Where to define the container
- First, define the container **directly inside the `process`** (i.e., set the `container` directive on the process itself).

---