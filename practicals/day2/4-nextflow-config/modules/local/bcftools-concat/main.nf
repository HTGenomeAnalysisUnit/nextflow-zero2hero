process BCFTOOLS_CONCAT {
    tag "${sample_id}"
    label 'process_small'

	publishDir "${params.outdir}/variants/${sample_id}/${variant_caller}", mode: params.publish_mode

    conda "${moduleDir}/environment.yml"
    container 'community.wave.seqera.io/library/bcftools_htslib:0a3fa2654b52006f' 

    input:
    tuple val(sample_id), path(vcfs)
    val(variant_caller)

    output:
    tuple val(sample_id), path("${sample_id}.${extension}"), path("${sample_id}.${extension}.csi")   , emit: vcf
    tuple val("${task.process}"), val('bcftools'), eval('bcftools --version | head -n 1 | cut -d" " -f2'), topic: versions

    script:
    extension = vcfs[0].toString().endsWith(".bcf.gz") ? "bcf.gz" :
				vcfs[0].toString().endsWith(".bcf")    ? "bcf" :
				vcfs[0].toString().endsWith(".g.vcf.gz") ? "g.vcf.gz" :
				vcfs[0].toString().endsWith(".vcf.gz")   ? "vcf.gz" :
				"vcf"
    def input = vcfs.sort{vcf -> vcf.toString()}.join(" ")
    """
    bcftools concat \\
        --output ${sample_id}.${extension} \\
        --write-index \\
        --threads $task.cpus \\
        ${input}
    """
}