# Nextflow configuration

Druing this practical session we'll get into more details into the nextflow configuration topic

In this step you have learned:

How to write a Nextflow configuration file. x 
How to use configuration files to define parameters, environment variables, and process directives x
How to use configuration files to define Docker, Singularity, and Conda execution x 
How to use configuration files to define process directives

# Exercice 1 

Inside this folder thare is a little script to create reference indexes and a basic alignment

The first part of this exercice is to launch this nextflow pipeline 

'''
nextflow run main.nf \
--input_file ./assets/test_input.tsv \
--reference_genome  /processing_data/reference_datasets/iGenomes/2025.1/Homo_sapiens/NCBI/GRCh38/Sequence/BWAIndex/genome.fa \
--outdir  test_deepvariant_cpu_gvcf
'''

## Output 

Which is the meaning of this error?

'''
Command exit status:
  127
'''

## set conda environment 

As the next step we'll add some configuration to the modules to make nextflow using conda environments to run the process

Add 

'''
conda "${moduleDir}/environment.yml"
'''

to GATK4_CREATESEQUENCEDICTIONARY and SAMTOOLS_FAIDX  processes

In particular we'll change same of the default parameters that are present inside nextflow.config







# Exercice 1 - try to run script on a different reference genome