process GATK4_HAPLOTYPECALLER {
    tag "${sample_id}"
    label 'process_medium'

    publishDir "${params.outdir}/variants/${sample_id}", pattern: "*.gatk_realigned.bam", mode: params.publish_mode

    conda "${moduleDir}/environment.yml"
    container 'community.wave.seqera.io/library/gatk4_gcnvkernel:edb12e4f0bf02cd3'

    input:
    tuple val(sample_id), path(input), path(input_index), val(chromosome)
    tuple path(fasta), path(fasta_fai), path(fasta_dict)
    path(intervals)

    output:
    tuple val(sample_id), path("${sample_id}.${extension}"),		    emit: vcf
    tuple val(sample_id), val(chromosome), path("${sample_id}.${chromosome}.gatk_realigned.bam"), 		emit: bam, optional: true
    tuple val("${task.process}"), val('gatk4'), eval('gatk --version 2>&1 | head -1 | sed "s/^.*gatk-package-//; s/-.*$//"'), topic: versions

    script:
	extension = params.variant_mode == 'gvcf' ? "g.vcf.gz" : "vcf.gz"
    def interval_command = intervals.exists() ? "--intervals ${intervals}" : ""
    def bamout_command = params.save_gatk_realigned_bam ? "--bam-output ${sample_id}.${chromosome}.gatk_realigned.bam" : ""
	def gvcf_command = params.variant_mode == 'gvcf' ? "--emit-ref-confidence GVCF" : ""

    def avail_mem = 3072
    if (!task.memory) {
        log.info('[GATK HaplotypeCaller] Available memory not known - defaulting to 3GB. Specify process memory requirements to change this.')
    }
    else {
        avail_mem = (task.memory.mega * 0.8).intValue()
    }
    """
    gatk --java-options "-Xmx${avail_mem}M -XX:-UsePerfData" \\
        HaplotypeCaller \\
        --input ${input} \\
        --output ${sample_id}.${extension} \\
        --reference ${fasta} \\
        --native-pair-hmm-threads ${task.cpus} \\
        --intervals ${chromosome} \\
        ${interval_command} \\
        ${bamout_command} \\
		${gvcf_command} \\
        --tmp-dir .
    """
}