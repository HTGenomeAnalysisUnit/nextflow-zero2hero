process MULTIQC {
	
	input:
	path qc_reports, stageAs: "?/*"
	

	output:
	path "*_report.html"  , emit: report
    path "*_data"      , emit: data
    path "*_plots"     , optional:true, emit: plots
    tuple val("${task.process}"), val('multiqc'), eval('multiqc --version | sed "s/.* //g"'), topic: versions
	
	script:
	"""
	multiqc .
	"""
}