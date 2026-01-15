
process FASTP {
	// tag "${sample_id}"
	// label 'process_low'
	
	// publishDir "${params.outdir}/reads_qc/${sample_id}/fastp", mode: params.publish_mode

	// container 'quay.io/biocontainers/fastp:1.0.1--heae3180_0'
	// conda "${moduleDir}/environment.yml" //TODO use containers for this part, so we explain modules config configuration later on
	
	input:
	tuple val(sample_id), val(fastq_set_id), path(fastq_R1), path(fastq_R2)
	
	output:
	tuple val(sample_id), val(fastq_set_id), path("${fastq_R1_basename}-${fastq_set_id}-qced.fastq.gz"), path("${fastq_R2_basename}-${fastq_set_id}-qced.fastq.gz"), emit: qced_reads
	tuple val(sample_id), val(fastq_set_id), path("${fastq_R1_basename}-${fastq_set_id}_fastp.json"), path("${fastq_R1_basename}-${fastq_set_id}_fastp.html"), emit: fastp_reports
	tuple val("${task.process}"), val('fastp'), eval('fastp --version | head -n 1 | cut -d" " -f2'), topic: versions
	
	script:
	fastq_R1_basename = fastq_R1.baseName.replace('.fastq', '')
	fastq_R2_basename = fastq_R2.baseName.replace('.fastq', '')
	"""
	fastp \
		-i ${fastq_R1} -o ${fastq_R1_basename}-${fastq_set_id}-qced.fastq.gz \
		-I ${fastq_R2} -O ${fastq_R2_basename}-${fastq_set_id}-qced.fastq.gz \
		--json ${fastq_R1_basename}-${fastq_set_id}_fastp.json \
		--html ${fastq_R1_basename}-${fastq_set_id}_fastp.html \
		--thread 4
	"""
}

process BWA_MEM {
	// tag "${sample_id}"
	// label 'process_high'

	// publishDir "${params.outdir}/alignments/${sample_id}/bwa", pattern: '*.log', mode: params.publish_mode

	// container 'community.wave.seqera.io/library/bwa_htslib_samtools:83b50ff84ead50d0'
	// // conda "${moduleDir}/environment.yml"
	
	input:
	tuple val(sample_id), val(fastq_set_id), path(fastq_R1), path(fastq_R2), val(genome_id), path(genome_fasta), path(genome_indexes)

	output:
	tuple val(sample_id), path("${sample_id}-${fastq_set_id}.bwa.bam"), emit: bam_file
	tuple val(sample_id), path("${sample_id}-${fastq_set_id}.bwa.log"), emit: bwa_log
	tuple val("${task.process}"), val('bwa'), eval('bwa 2>&1 | tail -n+3 | head -1 | cut -d" " -f2'), topic: versions
	tuple val("${task.process}"), val('samtools'), eval('samtools --version | head -n 1 | cut -d" " -f2'), topic: versions
	
	script:
	"""
	bwa mem -t 4 \
		-R \"@RG\\tID:${sample_id}\\tSM:${sample_id}\\tPL:Illumina\" \
		${genome_fasta} \
		${fastq_R1} ${fastq_R2} \
		2> ${sample_id}-${fastq_set_id}.bwa.log \
		| samtools view --threads 4 -Sb - > ${sample_id}-${fastq_set_id}.bwa.bam
	"""
}

process SAMTOOLS_SORT {
	// tag "${sample_id}"
	// label 'process_low'

	// publishDir "${params.outdir}/alignments/${sample_id}/merged_bam", mode: params.publish_mode

	// container 'quay.io/biocontainers/samtools:1.22--h96c455f_0'
	// conda "${moduleDir}/environment.yml"
	
	input:
	tuple val(sample_id), file(bam_file)
	
	output:
	tuple val(sample_id), file("${sample_id}.sort.bam"), file("${sample_id}.sort.bam.bai"), emit: sorted_bam
	tuple val("${task.process}"), val('samtools'), eval('samtools --version | head -n 1 | cut -d" " -f2'), topic: versions
	
	script:
	"""
	samtools sort -@ 4 -m 2G -o ${sample_id}.sort.bam ${bam_file}
	samtools index -b ${sample_id}.sort.bam
	"""
}

process SAMTOOLS_STATS {
	// tag "${sample_id}"
	// label 'process_low'

	// publishDir "${params.outdir}/alignments/${sample_id}/alignment_qc", mode: params.publish_mode

	// container 'quay.io/biocontainers/samtools:1.22--h96c455f_0'
	// conda "${moduleDir}/environment.yml"
	
	input:
	tuple val(sample_id), file(bam_file), file(bai_file)
	
	output:
	tuple val(sample_id), val("${bam_file}"), file("${bam_file}-stats.txt"), emit: stats_file
	tuple val("${task.process}"), val('samtools'), eval('samtools --version | head -n 1 | cut -d" " -f2'), topic: versions
	
	script:
	"""
	samtools stats --threads 4 ${bam_file} > ${bam_file}-stats.txt
	"""
}

process MOSDEPTH {
	// tag "${sample_id}"
	// label 'process_medium'

	// publishDir "${params.outdir}/alignments/${sample_id}/coverage", mode: params.publish_mode

	// container 'quay.io/biocontainers/mosdepth:0.3.12--h0ec343a_0'
	// conda "${moduleDir}/environment.yml"
	
	input:
	tuple val(sample_id), file(bam_file), file(bai_file)
	
	output:
	tuple val(sample_id), val(sample_id), path("${sample_id}.*"), emit: mosdepth_files
	tuple val("${task.process}"), val('mosdepth'), eval('mosdepth --version | head -n 1 | cut -d" " -f2'), topic: versions
	
	script:
	"""
	export MOSDEPTH_Q0=NO_COVERAGE   # 0 -- defined by the arguments to --quantize
    export MOSDEPTH_Q1=LESS_THAN_5  # 1..4
    export MOSDEPTH_Q2=LOW_COV  # 5..9
    export MOSDEPTH_Q3=CALLABLE  # 10..150
    export MOSDEPTH_Q4=HIGH_COV # 150..

    MOSDEPTH_PRECISION=4 mosdepth -n -t 4 --quantize 0:1:5:10:150: ${sample_id} ${bam_file}
	"""
}

process DEEPVARIANT {
	// tag "${sample_id}-${chromosome}"
    // label 'process_high'  
     
    // container 'docker.io/google/deepvariant:1.9.0'

    input:
        tuple val(sample_id), path(bam_file), path(bai_file), val(genome_id), path(reference_genome), path(reference_genome_indexes)

    output:
        tuple val("${sample_id}"), path("${sample_id}.vcf.gz"), emit: vcf
		tuple val("${task.process}"), val('deepvariant'), eval('/opt/deepvariant/bin/run_deepvariant --version 2>&1 | tail -n1 | cut -d" " -f3'), topic: versions

    script:
	
    """
    /opt/deepvariant/bin/run_deepvariant \\
        --ref=${reference_genome} \\
        --reads=${bam_file} \\
        --sample_name=${sample_id} \\
        --output_vcf=${sample_id}.vcf.gz \\
        --intermediate_results_dir=\$TMPDIR \\
        --model_type=WGS \\
        --make_examples_extra_args="normalize_reads=true" \\
        --num_shards=${task.cpus}
    """
}

workflow {


    // Read samplesheet with the sample ids and fastq paths
    def row_counter = 0
	input_fastq_ch = channel.fromPath(params.input_file)
		.splitCsv(header:true, sep:'\t')
		.map { row ->
			row_counter += 1
			[
				sample_id: row.sample_id,
				fastq_set_id: "${row_counter}",
				fastq_R1: file(row.fastq_R1, checkIfExists: true), 
				fastq_R2: file(row.fastq_R2, checkIfExists: true)
			] 
		}
    

    FASTP(input_fastq_ch)
	qc_reads_ch = FASTP.out.qced_reads




	genome_indexes = channel.fromPath(params.reference_genome, checkIfExists: true)
    	.map { fasta_file -> 
        def genome_id = fasta_file.baseName
        def index_files = ['amb', 'ann', 'bwt', 'pac', 'sa', 'fai'].collect { ext ->
            file("${fasta_file}.${ext}")
        }
        tuple(genome_id, fasta_file, index_files)
    	}


	bwa_input_ch = qc_reads_ch.combine(genome_indexes)
	BWA_MEM(bwa_input_ch)
	bam_files_ch = BWA_MEM.out.bam_file


	SAMTOOLS_SORT(bam_files_ch)
	sorted_bam_ch = SAMTOOLS_SORT.out.sorted_bam

	SAMTOOLS_STATS(sorted_bam_ch)
	MOSDEPTH(sorted_bam_ch)

	deepvariant_input_ch = sorted_bam_ch.combine(genome_indexes)
	DEEPVARIANT(deepvariant_input_ch)

}