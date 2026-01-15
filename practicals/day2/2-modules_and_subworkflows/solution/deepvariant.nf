process DEEPVARIANT {

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