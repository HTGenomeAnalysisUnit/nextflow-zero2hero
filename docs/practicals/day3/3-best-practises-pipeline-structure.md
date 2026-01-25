# Day 3 – Section 3 – Best practices for pipeline structure

## Introduction

As bioinformatics pipelines grow in complexity, maintaining a clear and modular structure becomes essential for ensuring maintainability and scalability. A well-structured pipeline not only facilitates workflow comprehension by other collaborators but also enables more efficient error identification and correction. Nextflow recognizes several conventional directories that are automatically integrated into the execution environment, such as *bin/* (for executable scripts that become available in the process PATH), *lib/* (for reusable Groovy classes that can be imported without explicit configuration), or *templates/* (for script templates used by processes). Also, separating configuration into multiple files through the `includeConfig` directive allows for better organization of environment-specific settings, resource requirements, and execution profiles. These built-in conventions enable developers to create modular, maintainable pipelines that follow community best practices and adapt seamlessly to different computing environments.

## Practical

In this session, we will reorganize the pipeline you created in `day2/2-modules_and_subworkflows` to ensure it follows best practices. By modularizing it, you have already done a great part of the job, but there are still a few aspects that can be improved. Additionally, you will implement a module on your own.

### Configuration

Before you start, create an interactive session with the required resources and dependencies:

```bash
# get an interactive session
$ srun --wait=0 --pty -p cpu-interactive -c 4 --mem 24G -J nxf_training /bin/bash

# load the dependencies
$ module load singularity nextflow/25.04.3
```

If you followed our suggestion, you should already have a `practicals_output` folder for running the exercises. Create a dedicated subdirectory for this practical and move into it:

```bash
# set <practicals_outputs> as the path where you created your workspace
mkdir -p practicals_outputs/day3/3-best_practices_for_pipeline_structure
cd practicals_outputs/day3/3-best_practices_for_pipeline_structure
```

Copy the content of the reference material to your directory:

```bash
cp -r nextflow_zero2hero_practicals/nextflow-zero2hero/practicals/day3/3-best_practices_for_pipeline_structure/* .
```

### Exercise

To complete this exercise you will need to:

1. Create a new module *rdeval* and use it in the `READS_QC` workflow. Don't forget to set the configuration for this new module.
2. Create a *bin/* folder and put the executable files there.
3. Create an *assets/* folder and put little accessory files and schemas there.
4. Create a *conf/* folder and split the Nextflow configuration from *all.config* into multiple configuration files.

#### A note on `rdeval`

[rdeval](https://github.com/vgl-hub/rdeval) is a software for obtaining summary statistics from sequence read files. For analyzing a single FASTQ file you could use a command line like the one below. Take into account this is for a single FASTQ, but we have two of them (R1 and R2).

```bash
rdeval --sequence-report --tabular --threads <THREADS> <FASTQ_FILE> > <FASTQ_FILE_BASENAME>-rdeval_report.tsv
```

You can find the executable version of this software in the *rdeval* file.
