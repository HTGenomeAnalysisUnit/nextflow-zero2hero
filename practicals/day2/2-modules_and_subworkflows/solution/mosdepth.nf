process MOSDEPTH {

	input:
	tuple val(sample_id), file(bam_file), file(bai_file)
	
	output:
	tuple val(sample_id), path("${sample_id}.*"), emit: mosdepth_files
	tuple val("${task.process}"), val('mosdepth'), eval('mosdepth --version | head -n 1 | cut -d" " -f2'), topic: versions
	
	script:
	"""
	export MOSDEPTH_Q0=NO_COVERAGE   # 0 -- defined by the arguments to --quantize
    export MOSDEPTH_Q1=LESS_THAN_5  # 1..4
    export MOSDEPTH_Q2=LOW_COV  # 5..9
    export MOSDEPTH_Q3=CALLABLE  # 10..150
    export MOSDEPTH_Q4=HIGH_COV # 150..

    MOSDEPTH_PRECISION=4 mosdepth -n -t 4 --quantize 0:1:5:10:150: ${sample_id} ${bam_file}
	"""
}