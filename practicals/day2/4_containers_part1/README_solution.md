# Containers practice

module load singularity
### Go to biocontainers and search for the tool fastp

### Pull the container
singularity pull https://depot.galaxyproject.org/singularity/fastp:0.24.0--heae3180_1

### Enter in the shell of the container making sure you mounted the path /project/nextflow_zero2hero/data/NA12878/fastq/sample1 within a folder called fastq_files
singularity shell --bind /project/nextflow_zero2hero/data/NA12878/fastq/sample1/:/work fastp\:0.24.0--heae3180_1

### Once in the container make sure the files are within the folder and run the program faspt using the following command

fastp \
      -i /work/reads_R1.fastq  -o sample1_reads_R1_qced.fastq.gz \
      -I /work/reads_R2.fastq -O sample1_reads_R1_qced.fastq.gz \
      --json sample1_fastp.json \
      --html sample1_fastp.html \
      --thread 4

# Repeat the same process without entering the container first
singularity exec --bind /project/nextflow_zero2hero/data/NA12878/fastq/sample1/:/work fastp\:0.24.0--heae3180_1 fastp -i /work/reads_R1.fastq  -o sample1_reads_R1_qced.fastq.gz -I /work/reads_R2.fastq -O sample1_reads_R2_qced.fastq.gz --json sample1_fastp.json --html sample1_fastp.html  --thread 4
