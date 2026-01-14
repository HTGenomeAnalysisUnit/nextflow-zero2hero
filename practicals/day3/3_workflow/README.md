## Nextflow course workflow part

We need to create 3 workflows today, one for cleaning the FASTQ data, one for aligning the reads to a reference genome and
one main workflow to run everything

## Easy/medium workflow


### 1 Creating the main workflows

1) Create a main workflow that include 1 module inside called FASTP
2) Create a channel that store the FASTQ information from the file indicated in params.input_file. Inside this channel define an additional variable
called row_counter that keep track of the row number. The final channel when using .view() needs to be as below:

[sample_1, 1, /project/nextflow_zero2hero/data/NA12878/fastq/sample1/chunks/reads_R1.part_001.fastq, /project/nextflow_zero2hero/data/NA12878/fastq/sample1/chunks/reads_R2.part_001.fastq]
[sample_1, 2, /project/nextflow_zero2hero/data/NA12878/fastq/sample1/chunks/reads_R1.part_002.fastq, /project/nextflow_zero2hero/data/NA12878/fastq/sample1/chunks/reads_R2.part_002.fastq]
[sample_1, 3, /project/nextflow_zero2hero/data/NA12878/fastq/sample1/chunks/reads_R1.part_003.fastq, /project/nextflow_zero2hero/data/NA12878/fastq/sample1/chunks/reads_R2.part_003.fastq]
[sample_2, 1, /project/nextflow_zero2hero/data/NA12878/fastq/sample2/chunks/reads_R1.part_003.fastq, /project/nextflow_zero2hero/data/NA12878/fastq/sample2/chunks/reads_R2.part_003.fastq]
.
.
.

This channel will be the sole input of the module called FASTP

### 2 Create FASTP module

1) Create a module called FASTP which takes in input a tuple with the above structure and gives in output 2 tuples like these:
	- The first tuple contains: sample_id, fastq_set_id, ${fastq_R1_basename}-${fastq_set_id}-qced.fastq.gz, ${fastq_R1_basename}-${fastq_set_id}-qced.fastq.gz
	- The second tuple is simply a series of *.log and *.html that we are not interested in for now

2) Once created the input and output channels execute the following script:
	     fastp \
            -i ${fastq_R1} -o ${sample_id}_${fastq_set_id}_R1_qced.fastq.gz \
            -I ${fastq_R2} -O ${sample_id}_${fastq_set_id}_R2_qced.fastq.gz \
            --json ${sample_id}_${fastq_set_id}_fastp.json \
            --html ${sample_id}_${fastq_set_id}_fastp.html \
            --thread 4

### 3 Results FASTQ

You should have as results 2 folder wiht the following structure:
	- results/reads_qc/sample_1/fastp/sample_1_1_fastp.html  sample_1_1_R1_qced.fastq.gz ...
	- results/reads_qc/sample_2/fastp/sample_2_1_fastp.html  sample_2_1_fastp.json ...

## Medium/hard part


### Align and merge the FASTQ files

1) Expand the main workflow with a channel called processed_genome that contains a tuple with both the reference genome and the bwa indexes. The final channel when using .view() needs to be as follow:

[/.../genome.fa, [/.../genome.fa.amb, /.../genome.fa.ann, /.../genome.fa.bwt, /.../genome.fa.pac, /.../genome.fa.sa]]

2) Add to the FASTP module an emit to the output of the first tuple and call it qced_reads

3) Combine the processed_genome and the qced_reads input into one channel called bwa_input_ch

4) Create a new module called BWA_MEM. This module takes
	- Input the channel bwa_input_ch which has the following shape:
		val(sample_id), val(fastq_set_id), path(fastq_R1), path(fastq_R2), path(reference_genome),  path(reference_genome_indexes)
	- Output 2 tuples: 	val(sample_id), path("${sample_id}-${fastq_set_id}.bwa.bam")
				val(sample_id), path("${sample_id}-${fastq_set_id}.bwa.log")

In the script part you need to run the following command using the arguments from the input part:
        bwa mem -t 4 \
                -R \"@RG\\tID:${sample_id}\\tSM:${sample_id}\\tPL:Illumina\" \
                ${reference_genome} \
                ${fastq_R1} ${fastq_R2} \
                2> ${sample_id}-${fastq_set_id}.bwa.log \
                | samtools view --threads 4 -Sb - > ${sample_id}-${fastq_set_id}.bwa.bam


5) Create another final module called SAMTOOLS_MERGE which takes
	- Input the output from the BWA_MEM process (val(sample_id), path("${sample_id}-${fastq_set_id}.bwa.bam"))
	- The output of this module should be a tuple like: val(sample_id), file("${sample_id}.merged_raw.bam")
	-The script to run is the following one:  samtools merge -n -@ ${task.cpus} -o ${sample_id}.merged_raw.bam ${bam_files}

### Results ALIGN
results/alignments/sample_1/merged_bam/sample_1.merged_raw.bam
results/alignments/sample_2/merged_bam/sample_2.merged_raw.bam

