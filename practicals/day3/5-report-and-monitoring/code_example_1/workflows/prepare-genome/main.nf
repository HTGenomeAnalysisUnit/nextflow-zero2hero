include { BWA_INDEX } from '../../modules/local/bwa-index'
include { GATK4_CREATESEQUENCEDICTIONARY } from '../../modules/local/gatk-makedict'
include { SAMTOOLS_FAIDX } from '../../modules/local/samtools-faidx'

workflow PREPARE_GENOME {
	take:
		genome_fasta // value of genome fasta file path

	main:
	genome_dict_input = channel.fromPath(genome_fasta, checkIfExists: true)
		.map { fasta_file -> tuple(
			"${fasta_file.baseName}",
			fasta_file,
			file("${fasta_file.baseName}.dict")
		) }

	genome_dict_input
		.branch { genome_id, fasta_file, fasta_dict ->
			missing_dict: !fasta_dict.exists()
				return tuple(genome_id, fasta_file)
			has_dict: true 
		}
		.set { genome_dict_processing } 

	genome_bwa_index_input = channel.fromPath(genome_fasta, checkIfExists: true)
    	.map { fasta_file -> 
        def genome_id = fasta_file.baseName
        def index_files = ['amb', 'ann', 'bwt', 'pac', 'sa'].collect { ext ->
            file("${fasta_file}.${ext}")
        }
        def all_exist = index_files.every { index_file -> index_file.exists() }
        tuple(genome_id, fasta_file, index_files, all_exist)
    	}

	genome_bwa_index_input
		.branch { genome_id, fasta_file, index_files, all_exist ->
			missing_index: !all_exist
				return tuple(genome_id, fasta_file)
			has_index: all_exist
				return tuple(genome_id, fasta_file, index_files)
		}
		.set { genome_bwa_index_processing }

	genome_fai_input = channel.fromPath(genome_fasta, checkIfExists: true)
		.map { fasta_file -> tuple(
			"${fasta_file.baseName}",
			fasta_file,
			file("${fasta_file.baseName}.fai")
		) }

	genome_fai_input
		.branch { genome_id, fasta_file, fasta_fai ->
			missing_fai: !fasta_fai.exists()
				return tuple(genome_id, fasta_file)
			has_fai: true 
		}
		.set { genome_fai_processing } 

	GATK4_CREATESEQUENCEDICTIONARY(genome_dict_processing.missing_dict)
	BWA_INDEX(genome_bwa_index_processing.missing_index)
	SAMTOOLS_FAIDX(genome_fai_processing.missing_fai)

	processed_genome_dict = genome_dict_processing.has_dict
		.mix(GATK4_CREATESEQUENCEDICTIONARY.out.dict)
	processed_genome_index = genome_bwa_index_processing.has_index
		.mix(BWA_INDEX.out.indexed_reference)
		.map { genome_id, _fasta_file, index_files -> 
			tuple(genome_id, index_files)
		}
	processed_genome_fai = genome_fai_processing.has_fai
		.mix(SAMTOOLS_FAIDX.out.genome_fai)
		.map { genome_id, _fasta_file, fai_file -> 
			tuple(genome_id, fai_file)
		}

	processed_genome = processed_genome_dict
		.join(processed_genome_index, by: 0)
		.join(processed_genome_fai, by: 0)
		.map { _genome_id, fasta_file, genome_dict, index_files, fai_file ->
			tuple(fasta_file, genome_dict, [index_files, fai_file].flatten())
		}

	emit:
		processed_genome = processed_genome // channel with tuples: fasta_file, fasta_dict, accessory_index_files
}