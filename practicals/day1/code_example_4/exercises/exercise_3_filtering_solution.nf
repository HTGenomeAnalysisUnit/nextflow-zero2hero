#!/usr/bin/env nextflow

process SAVE_GREETING {
	publishDir params.outdir, mode: 'copy'

	input:
		tuple val(meta), val(how_to_say_hello)

	output:
		tuple val(meta), path('*_greeting.txt'), emit: language_greeting

	script:
		"""
		echo '$how_to_say_hello' > ${meta.language}_greeting.txt
		"""
}

workflow {
	// Setup data (same as original)
	greetings = channel.fromPath(file(params.input_csv, checkIfExists: true))
		.splitCsv(header:true)
		.map{row -> tuple(
				[
					"language": row.language,
					"greeting": row.greeting,
					"family": row.language_family,
					"sub_category": row.language_sub_category
				],
				"In ${row.language} you say ${row.greeting}!"
			)
		}

	SAVE_GREETING(greetings)
	greeting_files = SAVE_GREETING.out.language_greeting

	// Group languages by family (from previous exercises)
	all_languages_grouped = greeting_files
		.map{meta, greeting -> tuple(["family": meta.family], greeting)}
		.groupTuple()

	all_languages_grouped_transposed = all_languages_grouped
		.transpose()

	greetings_by_family = greeting_files
		.branch{meta, greeting ->
			neo_latin: meta.family == "neo_latin"
			germanic: meta.family == "germanic"
				return tuple(["family": meta.family, "sub_category": meta.sub_category], greeting)
			other: true
				return tuple(meta + ["other_family": true], greeting)
		}

	neo_latin_greetings_grouped = greetings_by_family.neo_latin
		.map{meta, greeting -> tuple(["family": meta.family], greeting)}
		.groupTuple()

	// ---------- EXERCISE: FILTER, FLATTEN, COLLECT & COLLECT_FILE ----------

	// get all germanic files from grouped channel and have 1 emission for each of them
	germanic_greetings_files_flatten = all_languages_grouped
		.filter{meta, _file -> meta.family == "germanic"}
		.map{_meta, files -> files}
		.flatten()

	// collect all the emissions in a single one with as a list of files
	germanic_greetings_files_collect = all_languages_grouped_transposed
		.filter{meta, _file -> meta.family == "germanic"}
		.map{_meta, files -> files}
		.collect()

	// collect all the emissions into a file where each line is a file path
	neo_latin_greetings_files_collect_file = neo_latin_greetings_grouped
		.collectFile{meta, file_names ->
			def file_content = file_names.join("\n")
			[
				"${meta.family}_greetings_files.txt", file_content
			]
		}

	// View results
	germanic_greetings_files_flatten.view{emission -> "Germanic Flatten: $emission"}
	germanic_greetings_files_collect.view{emission -> "Germanic Collect: $emission"}
	neo_latin_greetings_files_collect_file.view{emission -> "Neo Latin CollectFile: $emission"}
}
