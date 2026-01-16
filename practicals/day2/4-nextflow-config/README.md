# Nextflow configuration

## Main configuration file

Nextflow automatically reads configuration settings from a file named:

```
nextflow.config
```

located in the project root directory.

This file defines:

* Default parameter values
* Execution settings
* Profiles for different environments
* Process-level resource requirements

The configuration system is hierarchical: values can be overridden by profiles, external config files, or command-line options.

---

## Parameters

Parameters are user-modifiable values accessed in the pipeline as:

```groovy
params.parameter_name
```

Example in `nextflow.config`:

```groovy
params {
    input = "data/*.fastq"
    outdir = "results"
    genome = "hg38"
}
```

These parameters control pipeline behavior without modifying the workflow code.

---

## Profiles

Profiles define environment-specific configurations. Example:

```groovy
profiles {
    standard {
        process.executor = 'local'
    }

    slurm {
        process.executor = 'slurm'
        process.queue = 'short'
        process.cpus = 4
        process.memory = '8 GB'
    }
}
```

Profiles are selected at runtime:

```bash
nextflow run main.nf -profile slurm
```

Profiles allow the same pipeline to run locally, on HPC clusters, or in the cloud without changing the workflow.

---

## Using `params.yaml`

Instead of passing parameters on the command line, we can store them in a YAML file:

```yaml
input: "data/*.fastq"
outdir: "results"
genome: "hg38"
```

Run with:

```bash
nextflow run main.nf -params-file params.yaml
```

Values in `params.yaml` override those defined in `nextflow.config`.

---

## Using a Slurm submission script

On HPC systems, a submission script is often used:

```bash
#!/bin/bash
#SBATCH --job-name=nextflow
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G

nextflow run main.nf -profile slurm -params-file params.yaml
```

This script selects the profile and parameter file while allocating cluster resources.

---

# Additional configuration

## Reference config

A reference configuration contains recommended default settings for a project or organization. It is often stored as:

```
conf/reference.config
```

and included in `nextflow.config`:

```groovy
includeConfig 'conf/reference.config'
```

This improves reproducibility and ensures consistent defaults across pipelines.

---

## Base config

A base configuration defines general settings shared by all profiles:

```groovy
process {
    errorStrategy = 'retry'
    maxRetries = 2
    withName: '*' {
        cpus = 2
        memory = '4 GB'
    }
}
```

Profiles then override only what differs from the base.

---

## External configuration

External configuration files can be loaded at runtime:

```bash
nextflow run main.nf -c custom.config
```

Multiple files can be combined:

```bash
nextflow run main.nf -c base.config,slurm.config
```

Later files override earlier ones.

This mechanism allows:

* Institution-specific configs
* User-specific configs
* Separation of pipeline logic from infrastructure

---

## Configuration priority order

From lowest to highest priority:

1. `nextflow.config`
2. Included config files
3. External `-c` config files
4. Profiles
5. Command-line parameters
6. `params.yaml`
