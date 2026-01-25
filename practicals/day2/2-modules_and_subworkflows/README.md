# Day 2 – Section 2 – Modules and Subworkflows
---
## Introduction

A **module** in Nextflow is a **reusable definition of a process** that is stored in a **separate file** and can be imported into different pipelines. Modules promote code reuse, standardization, and a clean separation of logic. A **subworkflow** is a higher-level building block that groups **multiple modules** into a logical unit of execution, also stored in a separate file. It defines how several steps are connected together and often represents a pipeline stage (e.g. *read preprocessing*, *alignment*, *report generation*).

Using modules and subworkflows in Nextflow brings major benefits in terms of modularity, readability, and scalability. By decomposing a pipeline into reusable components, code duplication is reduced and individual steps can be developed and maintained independently. This makes complex workflows easier to understand, as each module or subworkflow has a clear and limited responsibility. As pipelines grow or evolve, this structure allows specific steps or entire analysis stages to be modified, replaced, or extended without rewriting the whole workflow. Overall, this approach leads to cleaner code, simpler debugging, and pipelines that can scale in complexity while remaining manageable.

## Practical

In this practical session, you will take the pipeline in *single_file_pipeline.nf* and split it into modules and subworkflows. It is a very basic alignment pipeline in which WGS reads are first processed with *fastp* to remove adapters and then aligned to a reference genome using *BWA*. The resulting BAM file is sorted and indexed using *samtools*, while coverage is calculated with *mosdepth*. Finally, reports from the different tools are aggregated into a single report using *MultiQC*.

Your task is to create the required modules and use them in the following subworkflows:

- **read_qc**: initial preprocessing of the FASTQ reads  
- **alignment**: alignment to the reference genome, sorting, and indexing  
- **alignment_qc**: coverage estimation and calculation of additional alignment statistics  
- **reporting**: generation of a MultiQC report aggregating the results  

### Sanity check & configuration

Before you start, create an interactive session with the required resources and dependencies:

```
# get an interactive session
$ srun --wait=0 --pty -p cpu-interactive -c 4 --mem 24G -J nxf_training /bin/bash

# load the dependencies
$ module load singularity nextflow/25.04.3
```

If you followed our suggestion, you should already have a `practicals_output` folder for running the exercises. Create a dedicated subdirectory for this practical and move into it:

```
# set <practicals_outputs> as the path where you created your workspace
$ mkdir -p practicals_outputs/day2/2-modules_and_subworkflows
$ cd practicals_outputs/day2/2-modules_and_subworkflows
```

As a sanity check, we will first run *single_file_pipeline.nf* as it is, using a very small set of FASTQ reads and a dedicated output folder. Execute the command below and, while the pipeline is running, **take a look at the notes that follow**:

```
# create a dedicated folder for this execution and move to it
$ mkdir single_file
$ cd single_file

# run the pipeline pointing to the .nf file in the reference materials
$ nextflow run nextflow_zero2hero_practicals/nextflow-zero2hero/practicals/day2/2-modules_and_subworkflows/single_file_pipeline.nf
```

Nextflow automatically recognizes and loads the *nextflow.config* file located in the same directory as *single_file_pipeline.nf*. This file contains the configuration required for execution, allowing you to focus exclusively on modularizing the pipeline.

While the pipeline is running, open *nextflow.config* in your code editor and note the following:

- The parameter `input_file` points to the TSV file containing the FASTQ paths for each sample. The `outdir` parameter defines where the pipeline outputs will be saved.  
- Processes are executed using Singularity, as defined in the `singularity` block.  
- Each process has its own configuration block, where resources, the Singularity image (`container`), and the output directory (`publishDir`) are specified.  

If everything ran correctly, you should see a `results` directory containing a MultiQC report under `reporting`.

### Modularizing a pipeline

To complete the exercise, you will need to create one module per process, four subworkflows linking those modules, and a *main.nf* file connecting the subworkflows. Create a dedicated directory called `modular` and move into it:

```
$ mkdir -p practicals_outputs/day2/2-modules_and_subworkflows/modular
$ cd practicals_outputs/day2/2-modules_and_subworkflows/modular
```

It is recommended to start from the smallest building blocks (modules) and build progressively on top of them. In addition to the modules, subworkflows, and *main.nf* files, you will need the configuration file (*nextflow.config*) and the TSV file containing the FASTQ paths. Copy them into the `modular` directory:

```
$ cp nextflow_zero2hero_practicals/nextflow-zero2hero/practicals/day2/2-modules_and_subworkflows/nextflow.config .
$ cp nextflow_zero2hero_practicals/nextflow-zero2hero/practicals/day2/2-modules_and_subworkflows/test_input.tsv .
```

Keep the following points in mind:

- Import modules and subworkflows using the syntax `include { XXX } from '/path/to/YYY'`. 
- Remember to name your subworkflows!
- Use `take`, `main`, and `emit` to control the input, logic, and output of each subworkflow, respectively.  
- Keep the logic for reading the TSV file and preparing the reference genome in *main.nf*, and pass their outputs to the subworkflows that require them.  

Once your code is ready in the `modular` directory, test it by running:

```
$ nextflow run main.nf
```
