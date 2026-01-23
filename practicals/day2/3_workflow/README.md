# Nextflow Course Workflow

This document outlines the steps to create a Nextflow workflow with one main workflow and three modules:
1. **FASTP**: For cleaning FASTQ data (easy module).
2. **BWA_MEM**: For aligning reads to a reference genome (challenging module).
3. **SAMTOOLS_MERGE**: For merging reads after alignment (challenging module).

---

## Part 1 Workflow

### 1. Creating the Main Workflow

1. Create a main workflow that includes one module called **FASTP**.
2. Define a channel to store FASTQ information from the file specified in `params.input_file`. This channel should include the `part` column from the TSV, which acts as a row counter / FASTQ set ID. The final channel, when using `.view()`, should look like this:

    ```
    [sample_1, 1, /project/nextflow_zero2hero/data/NA12878/fastq/sample1/chunks/reads_R1.part_001.fastq, /project/nextflow_zero2hero/data/NA12878/fastq/sample1/chunks/reads_R2.part_001.fastq]
    [sample_1, 2, /project/nextflow_zero2hero/data/NA12878/fastq/sample1/chunks/reads_R1.part_002.fastq, /project/nextflow_zero2hero/data/NA12878/fastq/sample1/chunks/reads_R2.part_002.fastq]
    [sample_1, 3, /project/nextflow_zero2hero/data/NA12878/fastq/sample1/chunks/reads_R1.part_003.fastq, /project/nextflow_zero2hero/data/NA12878/fastq/sample1/chunks/reads_R2.part_003.fastq]
    [sample_2, 1, /project/nextflow_zero2hero/data/NA12878/fastq/sample2/chunks/reads_R1.part_003.fastq, /project/nextflow_zero2hero/data/NA12878/fastq/sample2/chunks/reads_R2.part_003.fastq]
    ```

    This channel will serve as the sole input for the **FASTP** module.

---

### 2. Creating the FASTP Module

1. Create a module called **FASTP** that:
   - Takes as input a tuple with the structure shown above.
   - Outputs two tuples:
     - **First tuple**: Contains [`sample_id`](command:_github.copilot.openSymbolFromReferences?%5B%22sample_id%22%2C%5B%7B%22uri%22%3A%7B%22%24mid%22%3A1%2C%22fsPath%22%3A%22%2FUsers%2Fbruno.ariano%2Fwork%2FHT%2Fnextflow_course%2Fnextflow-zero2hero%2Fpracticals%2Fday3%2F3_workflow%2FREADME.md%22%2C%22external%22%3A%22file%3A%2F%2F%2FUsers%2Fbruno.ariano%2Fwork%2FHT%2Fnextflow_course%2Fnextflow-zero2hero%2Fpracticals%2Fday3%2F3_workflow%2FREADME.md%22%2C%22path%22%3A%22%2FUsers%2Fbruno.ariano%2Fwork%2FHT%2Fnextflow_course%2Fnextflow-zero2hero%2Fpracticals%2Fday3%2F3_workflow%2FREADME.md%22%2C%22scheme%22%3A%22file%22%7D%2C%22pos%22%3A%7B%22line%22%3A25%2C%22character%22%3A29%7D%7D%5D%5D "Go to definition"), [`fastq_set_id`](command:_github.copilot.openSymbolFromReferences?%5B%22fastq_set_id%22%2C%5B%7B%22uri%22%3A%7B%22%24mid%22%3A1%2C%22fsPath%22%3A%22%2FUsers%2Fbruno.ariano%2Fwork%2FHT%2Fnextflow_course%2Fnextflow-zero2hero%2Fpracticals%2Fday3%2F3_workflow%2FREADME.md%22%2C%22external%22%3A%22file%3A%2F%2F%2FUsers%2Fbruno.ariano%2Fwork%2FHT%2Fnextflow_course%2Fnextflow-zero2hero%2Fpracticals%2Fday3%2F3_workflow%2FREADME.md%22%2C%22path%22%3A%22%2FUsers%2Fbruno.ariano%2Fwork%2FHT%2Fnextflow_course%2Fnextflow-zero2hero%2Fpracticals%2Fday3%2F3_workflow%2FREADME.md%22%2C%22scheme%22%3A%22file%22%7D%2C%22pos%22%3A%7B%22line%22%3A25%2C%22character%22%3A40%7D%7D%5D%5D "Go to definition"), `${fastq_R1_basename}-${fastq_set_id}-qced.fastq.gz`, `${fastq_R2_basename}-${fastq_set_id}-qced.fastq.gz`.
     - **Second tuple**: Contains log and HTML files (not used for now).

2. Use the following script to process the input and generate the output:

    ```bash
    fastp \
        -i ${fastq_R1} -o ${sample_id}_${fastq_set_id}_R1_qced.fastq.gz \
        -I ${fastq_R2} -O ${sample_id}_${fastq_set_id}_R2_qced.fastq.gz \
        --json ${sample_id}_${fastq_set_id}_fastp.json \
        --html ${sample_id}_${fastq_set_id}_fastp.html \
        --thread 4
    ```

---

### 3. Results: FASTQ

The results should be organized into two folders with the following structure:

You should have as results 2 folders with the following structure:
	- results/reads_qc/sample_1/fastp/sample_1_1_fastp.html  sample_1_1_R1_qced.fastq.gz ...
	- results/reads_qc/sample_2/fastp/sample_2_1_fastp.html  sample_2_1_fastp.json ...


---

## Part 2 Workflow

### 1. Align and Merge FASTQ Files

1. **Expand the Main Workflow**:
   - Add a channel called [`processed_genome`](command:_github.copilot.openSymbolFromReferences?%5B%22processed_genome%22%2C%5B%7B%22uri%22%3A%7B%22%24mid%22%3A1%2C%22fsPath%22%3A%22%2FUsers%2Fbruno.ariano%2Fwork%2FHT%2Fnextflow_course%2Fnextflow-zero2hero%2Fpracticals%2Fday3%2F3_workflow%2FREADME.md%22%2C%22external%22%3A%22file%3A%2F%2F%2FUsers%2Fbruno.ariano%2Fwork%2FHT%2Fnextflow_course%2Fnextflow-zero2hero%2Fpracticals%2Fday3%2F3_workflow%2FREADME.md%22%2C%22path%22%3A%22%2FUsers%2Fbruno.ariano%2Fwork%2FHT%2Fnextflow_course%2Fnextflow-zero2hero%2Fpracticals%2Fday3%2F3_workflow%2FREADME.md%22%2C%22scheme%22%3A%22file%22%7D%2C%22pos%22%3A%7B%22line%22%3A47%2C%22character%22%3A50%7D%7D%5D%5D "Go to definition") that contains a tuple with the reference genome and BWA indexes. The channel should look like this:

     ```
     [/.../genome.fa, [/.../genome.fa.amb, /.../genome.fa.ann, /.../genome.fa.bwt, /.../genome.fa.pac, /.../genome.fa.sa]]
     ```

2. **Update the FASTP Module**:
   - Add an [`emit`](command:_github.copilot.openSymbolFromReferences?%5B%22emit%22%2C%5B%7B%22uri%22%3A%7B%22%24mid%22%3A1%2C%22fsPath%22%3A%22%2FUsers%2Fbruno.ariano%2Fwork%2FHT%2Fnextflow_course%2Fnextflow-zero2hero%2Fpracticals%2Fday3%2F3_workflow%2FREADME.md%22%2C%22external%22%3A%22file%3A%2F%2F%2FUsers%2Fbruno.ariano%2Fwork%2FHT%2Fnextflow_course%2Fnextflow-zero2hero%2Fpracticals%2Fday3%2F3_workflow%2FREADME.md%22%2C%22path%22%3A%22%2FUsers%2Fbruno.ariano%2Fwork%2FHT%2Fnextflow_course%2Fnextflow-zero2hero%2Fpracticals%2Fday3%2F3_workflow%2FREADME.md%22%2C%22scheme%22%3A%22file%22%7D%2C%22pos%22%3A%7B%22line%22%3A51%2C%22character%22%3A30%7D%7D%5D%5D "Go to definition") to output the first tuple as [`qced_reads`](command:_github.copilot.openSymbolFromReferences?%5B%22qced_reads%22%2C%5B%7B%22uri%22%3A%7B%22%24mid%22%3A1%2C%22fsPath%22%3A%22%2FUsers%2Fbruno.ariano%2Fwork%2FHT%2Fnextflow_course%2Fnextflow-zero2hero%2Fpracticals%2Fday3%2F3_workflow%2FREADME.md%22%2C%22external%22%3A%22file%3A%2F%2F%2FUsers%2Fbruno.ariano%2Fwork%2FHT%2Fnextflow_course%2Fnextflow-zero2hero%2Fpracticals%2Fday3%2F3_workflow%2FREADME.md%22%2C%22path%22%3A%22%2FUsers%2Fbruno.ariano%2Fwork%2FHT%2Fnextflow_course%2Fnextflow-zero2hero%2Fpracticals%2Fday3%2F3_workflow%2FREADME.md%22%2C%22scheme%22%3A%22file%22%7D%2C%22pos%22%3A%7B%22line%22%3A51%2C%22character%22%3A80%7D%7D%5D%5D "Go to definition").

3. **Combine Channels**:
   - Combine [`processed_genome`](command:_github.copilot.openSymbolFromReferences?%5B%22processed_genome%22%2C%5B%7B%22uri%22%3A%7B%22%24mid%22%3A1%2C%22fsPath%22%3A%22%2FUsers%2Fbruno.ariano%2Fwork%2FHT%2Fnextflow_course%2Fnextflow-zero2hero%2Fpracticals%2Fday3%2F3_workflow%2FREADME.md%22%2C%22external%22%3A%22file%3A%2F%2F%2FUsers%2Fbruno.ariano%2Fwork%2FHT%2Fnextflow_course%2Fnextflow-zero2hero%2Fpracticals%2Fday3%2F3_workflow%2FREADME.md%22%2C%22path%22%3A%22%2FUsers%2Fbruno.ariano%2Fwork%2FHT%2Fnextflow_course%2Fnextflow-zero2hero%2Fpracticals%2Fday3%2F3_workflow%2FREADME.md%22%2C%22scheme%22%3A%22file%22%7D%2C%22pos%22%3A%7B%22line%22%3A47%2C%22character%22%3A50%7D%7D%5D%5D "Go to definition") and [`qced_reads`](command:_github.copilot.openSymbolFromReferences?%5B%22qced_reads%22%2C%5B%7B%22uri%22%3A%7B%22%24mid%22%3A1%2C%22fsPath%22%3A%22%2FUsers%2Fbruno.ariano%2Fwork%2FHT%2Fnextflow_course%2Fnextflow-zero2hero%2Fpracticals%2Fday3%2F3_workflow%2FREADME.md%22%2C%22external%22%3A%22file%3A%2F%2F%2FUsers%2Fbruno.ariano%2Fwork%2FHT%2Fnextflow_course%2Fnextflow-zero2hero%2Fpracticals%2Fday3%2F3_workflow%2FREADME.md%22%2C%22path%22%3A%22%2FUsers%2Fbruno.ariano%2Fwork%2FHT%2Fnextflow_course%2Fnextflow-zero2hero%2Fpracticals%2Fday3%2F3_workflow%2FREADME.md%22%2C%22scheme%22%3A%22file%22%7D%2C%22pos%22%3A%7B%22line%22%3A51%2C%22character%22%3A80%7D%7D%5D%5D "Go to definition") into a new channel called [`bwa_input_ch`](command:_github.copilot.openSymbolFromReferences?%5B%22bwa_input_ch%22%2C%5B%7B%22uri%22%3A%7B%22%24mid%22%3A1%2C%22fsPath%22%3A%22%2FUsers%2Fbruno.ariano%2Fwork%2FHT%2Fnextflow_course%2Fnextflow-zero2hero%2Fpracticals%2Fday3%2F3_workflow%2FREADME.md%22%2C%22external%22%3A%22file%3A%2F%2F%2FUsers%2Fbruno.ariano%2Fwork%2FHT%2Fnextflow_course%2Fnextflow-zero2hero%2Fpracticals%2Fday3%2F3_workflow%2FREADME.md%22%2C%22path%22%3A%22%2FUsers%2Fbruno.ariano%2Fwork%2FHT%2Fnextflow_course%2Fnextflow-zero2hero%2Fpracticals%2Fday3%2F3_workflow%2FREADME.md%22%2C%22scheme%22%3A%22file%22%7D%2C%22pos%22%3A%7B%22line%22%3A53%2C%22character%22%3A81%7D%7D%5D%5D "Go to definition").

---

### 2. Creating the BWA_MEM Module

1. Create a module called **BWA_MEM** that:
   - Takes as input the [`bwa_input_ch`](command:_github.copilot.openSymbolFromReferences?%5B%22bwa_input_ch%22%2C%5B%7B%22uri%22%3A%7B%22%24mid%22%3A1%2C%22fsPath%22%3A%22%2FUsers%2Fbruno.ariano%2Fwork%2FHT%2Fnextflow_course%2Fnextflow-zero2hero%2Fpracticals%2Fday3%2F3_workflow%2FREADME.md%22%2C%22external%22%3A%22file%3A%2F%2F%2FUsers%2Fbruno.ariano%2Fwork%2FHT%2Fnextflow_course%2Fnextflow-zero2hero%2Fpracticals%2Fday3%2F3_workflow%2FREADME.md%22%2C%22path%22%3A%22%2FUsers%2Fbruno.ariano%2Fwork%2FHT%2Fnextflow_course%2Fnextflow-zero2hero%2Fpracticals%2Fday3%2F3_workflow%2FREADME.md%22%2C%22scheme%22%3A%22file%22%7D%2C%22pos%22%3A%7B%22line%22%3A53%2C%22character%22%3A81%7D%7D%5D%5D "Go to definition") channel with the following structure:
     ```
     val(sample_id), val(fastq_set_id), path(fastq_R1), path(fastq_R2), path(reference_genome), path(reference_genome_indexes)
     ```
   - Outputs two tuples:
     - [`val(sample_id), path("${sample_id}-${fastq_set_id}.bwa.bam")`](command:_github.copilot.openSymbolFromReferences?%5B%22val(sample_id)%2C%20path(%5C%22%24%7Bsample_id%7D-%24%7Bfastq_set_id%7D.bwa.bam%5C%22)%22%2C%5B%7B%22uri%22%3A%7B%22%24mid%22%3A1%2C%22fsPath%22%3A%22%2FUsers%2Fbruno.ariano%2Fwork%2FHT%2Fnextflow_course%2Fnextflow-zero2hero%2Fpracticals%2Fday3%2F3_workflow%2FREADME.md%22%2C%22external%22%3A%22file%3A%2F%2F%2FUsers%2Fbruno.ariano%2Fwork%2FHT%2Fnextflow_course%2Fnextflow-zero2hero%2Fpracticals%2Fday3%2F3_workflow%2FREADME.md%22%2C%22path%22%3A%22%2FUsers%2Fbruno.ariano%2Fwork%2FHT%2Fnextflow_course%2Fnextflow-zero2hero%2Fpracticals%2Fday3%2F3_workflow%2FREADME.md%22%2C%22scheme%22%3A%22file%22%7D%2C%22pos%22%3A%7B%22line%22%3A57%2C%22character%22%3A2%7D%7D%5D%5D "Go to definition")
     - [`val(sample_id), path("${sample_id}-${fastq_set_id}.bwa.log")`](command:_github.copilot.openSymbolFromReferences?%5B%22val(sample_id)%2C%20path(%5C%22%24%7Bsample_id%7D-%24%7Bfastq_set_id%7D.bwa.log%5C%22)%22%2C%5B%7B%22uri%22%3A%7B%22%24mid%22%3A1%2C%22fsPath%22%3A%22%2FUsers%2Fbruno.ariano%2Fwork%2FHT%2Fnextflow_course%2Fnextflow-zero2hero%2Fpracticals%2Fday3%2F3_workflow%2FREADME.md%22%2C%22external%22%3A%22file%3A%2F%2F%2FUsers%2Fbruno.ariano%2Fwork%2FHT%2Fnextflow_course%2Fnextflow-zero2hero%2Fpracticals%2Fday3%2F3_workflow%2FREADME.md%22%2C%22path%22%3A%22%2FUsers%2Fbruno.ariano%2Fwork%2FHT%2Fnextflow_course%2Fnextflow-zero2hero%2Fpracticals%2Fday3%2F3_workflow%2FREADME.md%22%2C%22scheme%22%3A%22file%22%7D%2C%22pos%22%3A%7B%22line%22%3A57%2C%22character%22%3A2%7D%7D%5D%5D "Go to definition")

2. Use the following script to process the input:

    ```bash
    bwa mem -t 4 \
        -R "@RG\tID:${sample_id}\tSM:${sample_id}\tPL:Illumina" \
        ${reference_genome} \
        ${fastq_R1} ${fastq_R2} \
        2> ${sample_id}-${fastq_set_id}.bwa.log \
        | samtools view --threads 4 -Sb - > ${sample_id}-${fastq_set_id}.bwa.bam
    ```

---

### 3. Creating the SAMTOOLS_MERGE Module

1. Create a module called **SAMTOOLS_MERGE** that:
   - Takes as input the output from the **BWA_MEM** module:
     ```
     val(sample_id), path("${sample_id}-${fastq_set_id}.bwa.bam")
     ```
   - Outputs a tuple:
     ```
     val(sample_id), file("${sample_id}.merged_raw.bam")
     ```

2. Use the following script to merge BAM files:

    ```bash
    samtools merge -n -@ ${task.cpus} -o ${sample_id}.merged_raw.bam ${bam_files}
    ```

---

### 4. Results: Alignments

The results should be organized into the following structure:

results/alignments/sample_1/merged_bam/sample_1.merged_raw.bam
results/alignments/sample_2/merged_bam/sample_2.merged_raw.bam

