process MULTIQC {
	tag "${stage_name}"
	label 'process_low'

	publishDir "${params.outdir}/${stage_name}/multi_qc", mode: params.publish_mode

	container 'quay.io/biocontainers/multiqc:1.33--pyhdfd78af_0'
	conda "${moduleDir}/environment.yml"
	
	input:
	path qc_reports, stageAs: "?/*"
	file(sample_id_map)
	val(stage_name)

	output:
	path "${stage_name}_multiqc_report.html"      , emit: report
    path "*_data"      , emit: data
    path "*_plots"     , optional:true, emit: plots
    tuple val("${task.process}"), val('multiqc'), eval('multiqc --version | sed "s/.* //g"'), topic: versions
	
	script:
	"""
	multiqc \
        --force \
        --replace-names ${sample_id_map} \
		--title "${stage_name} MultiQC Report" \
		--filename "${stage_name}_multiqc_report.html" \
        .
	"""
}