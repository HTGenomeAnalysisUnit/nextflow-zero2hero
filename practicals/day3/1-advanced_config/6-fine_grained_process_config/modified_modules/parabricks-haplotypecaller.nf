process HAPLOTYPECALLER_GPU {
    tag "${sample_id}"
    label 'process_high'
    label 'process_high_memory'

    publishDir "${params.outdir}/variants/${sample_id}", pattern: "*.gatk_realigned.bam", mode: params.publish_mode

    container "nvcr.io/nvidia/clara/clara-parabricks:4.4.0-1"

    input:
    tuple val(sample_id), path(bam_file), path(bai_file), path(reference_genome), path(reference_genome_dict), path(reference_genome_indexes)

    output:
    tuple val(sample_id), path("${sample_id}.vcf"),      emit: variants

    script:
    // Exit if running this module with -profile conda / -profile mamba
    if (workflow.profile.tokenize(',').intersect(['conda', 'mamba']).size() >= 1) {
        exit(1, "Parabricks module does not support Conda. Please use Docker / Singularity instead.")
    }
    """
    pbrun \\
        haplotypecaller \\
        --ref ${reference_genome} \\
        --in-bam ${bam_file} \\
        --out-variants ${sample_id}.vcf \\
        --num-htvc-threads ${task.cpus} \\
        --run-partition \\
        --gpu-num-per-partition 1 \\
        --num-gpus 1
    """
}