process MULTIQC {
	label 'process_low'
	
	input:
	path qc_reports, stageAs: "?/*"
	path multiqc_config
	path ht_logo
	

	output:
	path "*_report.html"  , emit: report
    path "*_data"      , emit: data
    path "*_plots"     , optional:true, emit: plots
    tuple val("${task.process}"), val('multiqc'), eval('multiqc --version | sed "s/.* //g"'), topic: versions
	
	script:
	"""
	multiqc -c ${multiqc_config} .
	"""
}