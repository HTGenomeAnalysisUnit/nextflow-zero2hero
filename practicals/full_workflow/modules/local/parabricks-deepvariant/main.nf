process DEEPVARIANT_PARABRICKS {
	tag "${sample_id}"
    label 'gpu'
    label 'parabricks_gpu'  
     
    container 'nvcr.io/nvidia/clara/clara-parabricks:4.6.0-1'

    input:
        tuple val(sample_id), file(bam_file), file(bai_file)
        tuple file(reference_genome), file(reference_genome_dict), file(reference_genome_indexes)
        val(model_type)
        path(regions)

    output:
        tuple val("${sample_id}"), path("${sample_id}.vcf.gz"), optional: true, emit: vcf
        tuple val("${sample_id}"), path("${sample_id}.g.vcf.gz"), optional: true, emit: gvcf
		tuple val("${task.process}"), val('parabricks'), eval('pbrun version 2>&1 | tail -1 | cut -d" " -f2'), topic: versions
		tuple val("${task.process}"), val('deepvariant'), eval('pbrun deepvariant --version | grep DeepVariant | sed "s/^DeepVariant:\\s\\+//"'), topic: versions

    script:
	if (workflow.profile.tokenize(',').intersect(['conda', 'mamba']).size() >= 1) {
        exit(1, "Parabricks module does not support Conda. Please use Docker / Singularity instead.")
    }
    def opt_regions = regions.exists() ? "--interval-file ${regions}" : ""
    extension = params.variant_mode == 'gvcf' ? "g.vcf.gz" : "vcf.gz"
    def gvcf_output = params.variant_mode == 'gvcf' ? "--gvcf" : ""
    """
    export TCMALLOC_MAX_TOTAL_THREAD_CACHE_BYTES=268435456§
    pbrun deepvariant \
        --ref ${reference_genome} \
        --in-bam ${bam_file} \
        --normalize-reads \
        --run-partition \
        --gpu-num-per-partition 1 \
        --num-streams-per-gpu 4 \
        --num-cpu-threads-per-stream ${task.cpus.intdiv(4)} \
        ${gvcf_output} \
		${opt_regions} \
        --out-variants ${sample_id}.${extension} \
        --tmp-dir \$TMPDIR \
		--num-gpus ${task.accelerator.request}
    """
}