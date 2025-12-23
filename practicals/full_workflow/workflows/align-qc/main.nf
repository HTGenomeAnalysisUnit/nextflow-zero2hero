include { SAMTOOLS_STATS } from '../../modules/local/samtools-stats'
include { SAMTOOLS_FLAGSTATS } from '../../modules/local/samtools-flagstats'
include { MOSDEPTH } from '../../modules/local/mosdepth'
include { MULTIQC } from '../../modules/local/multiqc'

workflow ALIGNMENT_QC {
	take:
		input_bam_files // channel with tuples: sample_id, input_bam_file

	main:
		SAMTOOLS_STATS(input_bam_files)
		SAMTOOLS_FLAGSTATS(input_bam_files)
		MOSDEPTH(input_bam_files)

		sample_id_map = SAMTOOLS_STATS.out.stats_file
			.mix(SAMTOOLS_FLAGSTATS.out.flagstats_file)
			.map { sample_id, outfile_prefix, _file ->  "${outfile_prefix}\t${sample_id}" }
			.unique()
			.collectFile(name: 'sample_id_map.tsv', newLine: true, storeDir: "${params.outdir}/alignments")

		alignment_qc_files = SAMTOOLS_STATS.out.stats_file
			.mix(SAMTOOLS_FLAGSTATS.out.flagstats_file)
			.mix(MOSDEPTH.out.mosdepth_files)
			.map { _sample_id, qc_file -> qc_file }
			.collect(flat: true)

		MULTIQC(alignment_qc_files, sample_id_map, 'alignments')

	emit:
		aligned_qc_files = alignment_qc_files // channel with tuples: sample_id, qc_report_file
}