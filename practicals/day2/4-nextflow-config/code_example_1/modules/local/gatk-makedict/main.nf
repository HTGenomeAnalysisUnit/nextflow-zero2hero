process GATK4_CREATESEQUENCEDICTIONARY {
    tag "${genome_id}"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container 'community.wave.seqera.io/library/gatk4_gcnvkernel:edb12e4f0bf02cd3'

    publishDir "${params.outdir}/genome_index", mode: params.publish_mode

    input:
    tuple val(genome_id), path(fasta)

    output:
    tuple val(genome_id), path(fasta), path("${fasta.baseName}.dict"), emit: dict
    tuple val("${task.process}"), val('gatk4'), eval('gatk --version 2>&1 | head -1 | sed "s/^.*gatk-package-//; s/-.*$//"'), topic: versions

    script:
    def avail_mem = 6144
    if (!task.memory) {
        log.info('[GATK CreateSequenceDictionary] Available memory not known - defaulting to 6GB. Specify process memory requirements to change this.')
    }
    else {
        avail_mem = (task.memory.mega * 0.8).intValue()
    }
    """
    gatk --java-options "-Xmx${avail_mem}M -XX:-UsePerfData" \\
        CreateSequenceDictionary \\
        --REFERENCE ${fasta} \\
        --URI ${fasta} \\
        --TMP_DIR . 
    """
}