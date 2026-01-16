process DEEPVARIANT {
	tag "${sample_id}-${chromosome}"
    label 'process_high'  
     
    container 'docker.io/google/deepvariant:1.9.0'

    input:
        tuple val(sample_id), path(bam_file), path(bai_file), val(chromosome), path(reference_genome), path(reference_genome_dict), path(reference_genome_indexes)
        val(model_type)
        path(regions)

    output:
        tuple val("${sample_id}"), path("${sample_id}.${chromosome}.vcf.gz"), emit: vcf
        tuple val("${sample_id}"), path("${sample_id}.${chromosome}.g.vcf.gz"), optional: true, emit: gvcf
		tuple val("${task.process}"), val('deepvariant'), eval('/opt/deepvariant/bin/run_deepvariant --version 2>&1 | tail -n1 | cut -d" " -f3'), topic: versions

    script:
	if (workflow.profile.tokenize(',').intersect(['conda', 'mamba']).size() >= 1) {
        exit(1, "Deepvariant module does not support Conda. Please use Docker / Singularity instead.")
    }
    def regions_string = regions.exists() ? "${chromosome} ${regions}" : "${chromosome}"
    def gvcf_output = params.variant_mode == 'gvcf' ? "--output_gvcf=${sample_id}.${chromosome}.g.vcf.gz" : ""
    """
    /opt/deepvariant/bin/run_deepvariant \\
        --ref=${reference_genome} \\
        --reads=${bam_file} \\
        --sample_name=${sample_id} \\
        --output_vcf=${sample_id}.${chromosome}.vcf.gz \\
        --regions="${regions_string}" \\
        ${gvcf_output} \\
        --intermediate_results_dir=\$TMPDIR \\
        --model_type=${model_type} \\
        --make_examples_extra_args="normalize_reads=true" \\
        --num_shards=${task.cpus}
    """
}