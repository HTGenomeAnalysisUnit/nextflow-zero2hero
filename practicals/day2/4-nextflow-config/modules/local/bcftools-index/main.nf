process BCFTOOLS_INDEX {
    tag "${sample_id}"
    label 'process_small'

    publishDir "${params.outdir}/variants/${sample_id}", mode: params.publish_mode

    conda "${moduleDir}/environment.yml"
    container 'community.wave.seqera.io/library/bcftools_htslib:0a3fa2654b52006f' 

    input:
    tuple val(sample_id), path(vcf_file)

    output:
    tuple val(sample_id), path(output_filename), path("${output_filename}.csi")   , emit: indexed_vcf
    tuple val("${task.process}"), val('bcftools'), eval('bcftools --version | head -n 1 | cut -d" " -f2'), topic: versions

    script:
    output_filename = vcf_file.name.endsWith('.vcf') ? "${vcf_file}.gz" : "${vcf_file}"
    // When vcf_file ends in vcf, first use bcftools view to create a bgzipped version
    def bcftools_view_cmd = vcf_file.name.endsWith('.vcf') ? "bcftools view --threads ${task.cpus} -Oz -o ${vcf_file}.gz ${vcf_file}" : ""
    def index_input_vcf = vcf_file.name.endsWith('.vcf') ? "${vcf_file}.gz" : "${vcf_file}"
    """
    ${bcftools_view_cmd}

    bcftools index \\
        --threads $task.cpus \\
        ${index_input_vcf}
    """
}