include { DEEPVARIANT_PARABRICKS as DEEPVARIANT_GPU } from '../../modules/local/parabricks-deepvariant/main.nf'	
include { PARABRICKS_HAPLOTYPECALLER as HAPLOTYPECALLER_GPU } from '../../modules/local/parabricks-haplotypecaller/main.nf'
include { DEEPVARIANT as DEEPVARIANT_CPU} from '../../modules/local/deepvariant/main.nf'
include { GATK4_HAPLOTYPECALLER as HAPLOTYPECALLER_CPU } from '../../modules/local/gatk-haplotypecaller/main.nf'
include { BCFTOOLS_CONCAT } from '../../modules/local/bcftools-concat/main.nf'
include { BCFTOOLS_INDEX } from '../../modules/local/bcftools-index/main.nf'

workflow CALL_VARIANTS {
	take:
		bam_per_sample_ch // tuple sample_id, bam_file, bai_file
		processed_genome // tuple genome_fasta, genome_dict, genome_indexes
		chromosomes_list // List of chromosomes to process

	main:
		log.info "Using chromosomes: ${chromosomes_list.join(', ')} for variant calling"
		regions_file = params.variant_regions ? file(params.variant_regions, checkIfExists: true) : file('NO_REGIONS')
		// TODO: Add BQSR to GATK workflow

		if (params.variant_caller_use_gpu) {
			// when using gpu, variant calling is done on the full bam per sample
			variantcall_input_ch = bam_per_sample_ch.combine(processed_genome)
			if (params.variant_caller == 'deepvariant') {
				DEEPVARIANT_GPU(
					variantcall_input_ch, 
					params.deepvariant_model_type,
					regions_file
				)
				if (params.variant_mode == 'gvcf') {
					per_sample_ch = DEEPVARIANT_GPU.out.gvcf
				} else {
					per_sample_ch = DEEPVARIANT_GPU.out.vcf
				}	
			}
			else if (params.variant_caller == 'gatk-haplotypecaller') {
				HAPLOTYPECALLER_GPU(
					variantcall_input_ch, 
					regions_file
				)
				if (params.variant_mode == 'gvcf') {
					per_sample_ch = HAPLOTYPECALLER_GPU.out.gvcf
				} else {
					per_sample_ch = HAPLOTYPECALLER_GPU.out.vcf
				}	
			}
			per_sample_vcf_idx_ch = BCFTOOLS_INDEX(per_sample_ch)
		} else {
			// when not using gpu, variant calling is split by chromosome
			variantcall_input_ch = bam_per_sample_ch
				.combine(chromosomes_list)
			if (params.variant_caller == 'deepvariant') 
			{
				DEEPVARIANT_CPU(
					variantcall_input_ch, 
					processed_genome, 
					params.deepvariant_model_type,
					regions_file
				)
				if (params.variant_mode == 'gvcf') {
					per_chromosome_ch = DEEPVARIANT_CPU.out.gvcf
				} else {
					per_chromosome_ch = DEEPVARIANT_CPU.out.vcf
				}
			}
			else if (params.variant_caller == 'gatk-haplotypecaller') 
			{
				HAPLOTYPECALLER_CPU(
					variantcall_input_ch, 
					processed_genome, 
					regions_file
				)
				if (params.variant_mode == 'gvcf') {
					per_chromosome_ch = HAPLOTYPECALLER_CPU.out.gvcf
				} else {
					per_chromosome_ch = HAPLOTYPECALLER_CPU.out.vcf
				}
			}
			
			per_sample_chunks = per_chromosome_ch
				.groupTuple(by: 0, size: chromosomes_list.size())

			BCFTOOLS_CONCAT(per_sample_chunks)
			per_sample_vcf_idx_ch = BCFTOOLS_CONCAT.out.vcf
		}

		// TODO: Merge samples
		
	emit:
		per_sample_vars = per_sample_vcf_idx_ch
		// cohort_vars = cohort_vcf_idx_ch
}