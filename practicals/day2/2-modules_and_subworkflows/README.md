# Day 2 - Modules and Subworkflows

## Introduction

A **module** in Nextflow is a reusable definition of a process that is stored in a **separate file** and can be imported into different pipelines. They promote code reuse, standardization, and clean separation of logic. A **subworkflow** is a higher-level building block that groups **multiple processes** and/or modules into a logical unit of execution, also in a seprate file. It defines how several steps are connected together, and often represents a pipeline stage (e.g. “read preprocessing”, “alignment”, “report generation”...).

Using modules and subworkflows in Nextflow brings major benefits in terms of modularity, readability, and scalability. By decomposing a pipeline into reusable components, code duplication is reduced and individual steps can be developed and maintained independently. This makes complex workflows easier to understand, as each module or subworkflow has a clear and limited responsibility. As pipelines grow or evolve, this structure allows specific steps or entire analysis stages to be modified, replaced, or extended without rewriting the whole workflow. Overall, this approach leads to cleaner code, simpler debugging, and pipelines that can scale in complexity while remaining manageable.

## Practical
In this practical session you will take single_file_pipeline.nf and split it into modules and subworkflows. It is a very basic pipeline of variant calling where WGS reads are first processed with fastp to remove adapters, and then aligned to a reference genome using BWA. Resulting BAM file is sorted and indexed using samtools, while the coverage is calculated with mosdepth. To conclude, variants are identified using deepvariant. 

Your job is to create the required modules and to use them in the following subworkflows:

- read_qc: with the initial preprocessing of the FASTQ reads
- alignment: with the alignment to the reference genome, sorting and coverage estimation
- variant_calling: with the variant calling step

### Sanity check & configuration
To speed things up we will be using a small set of FASTQ reads and chr21 as reference genome. As a sanity check, start by executing the pipeline as it is by moving to the *practicals/day2/2-modules_and_subworkflows* directory and running:

```
nextflow run single_file_pipeline.nf -w work
```

It should work smoothly (hopefully). Take a look at *nextflow.config* while it is running. We set the configurations needed by the pipeline in there so just have to focus on modularizing the pipeline. Most of the configurations will be covered in the coming sections, but we can quickly peek on them:

- The pipeline will spawn processes using `slurm`, and these will run in the `cpuq` queue.
- Processes run using Singularity, as defined in the `singularity` block.
- Notice how each process has its own configuration block. 

### Hands on

To complete the exercise you will have to create one module for each process, create 4 subworkflows linking the processes, and a *main.nf* file linking the subworkflows. It is better if you start from the smallest building block (modules) and build on that progresively. 

Here are some aspects you will need to remember:

- Import your modules and subworkflows with the syntax `include { XXX } from '/path/to/YYY'`. 
- Use `take`, `main` and `emit` to control de input, logic and output of your subworkflow, respectively.









