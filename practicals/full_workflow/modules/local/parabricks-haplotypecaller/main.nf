process PARABRICKS_HAPLOTYPECALLER {
    tag "${sample_id}"
    label 'gpu'
    label 'parabricks_gpu' 

    publishDir "${params.outdir}/variants/${sample_id}", pattern: "*.gatk_realigned.bam", mode: params.publish_mode

    container "nvcr.io/nvidia/clara/clara-parabricks:4.6.0-1"

    input:
    tuple val(sample_id), path(bam_file), path(bai_file), path(reference_genome), path(reference_genome_dict), path(reference_genome_indexes)
	path(interval_file)

    output:
    tuple val(sample_id), path("${sample_id}.${extension}"),      emit: variants
    tuple val(sample_id), path("${sample_id}.gatk_realigned.bam"), 		emit: bam, optional: true
    tuple val("${task.process}"), val('parabricks'), eval('pbrun version 2>&1 | tail -1 | cut -d" " -f2'), topic: versions

    script:
    // Exit if running this module with -profile conda / -profile mamba
    if (workflow.profile.tokenize(',').intersect(['conda', 'mamba']).size() >= 1) {
        exit(1, "Parabricks module does not support Conda. Please use Docker / Singularity instead.")
    }
    extension = params.variant_mode == 'gvcf' ? "g.vcf.gz" : "vcf.gz"
    def gvcf_output = params.variant_mode == 'gvcf' ? "--gvcf" : ""
    def interval_file_command = interval_file.exists() ? "--interval-file ${interval_file}" : ""
    def bamout_command = params.save_gatk_realigned_bam ? "--htvc-bam-output ${sample_id}.gatk_realigned.bam" : ""
    def num_gpus = task.accelerator ? "${task.accelerator.request}" : '1'
    """
    pbrun \\
        haplotypecaller \\
        --ref ${reference_genome} \\
        --in-bam ${bam_file} \\
        --out-variants ${sample_id}.${extension} \\
        ‑‑num‑htvc‑threads ${task.cpus.intdiv(num_gpus.toInteger())} \\
        --num-gpus ${num_gpus} \\
        ${bamout_command} \\
        ${gvcf_output} \\
        ${interval_file_command}
    """
}