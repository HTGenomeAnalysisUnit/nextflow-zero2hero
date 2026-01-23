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

	neo_latin_greetings_files_collect_file = neo_latin_greetings_grouped
		.collectFile{meta, file_names ->
			def file_content = file_names.join("\n")
			[
				"${meta.family}_greetings_files.txt", file_content
			]
		}

	// ---------- EXERCISE: ADVANCED MAP FUNCTIONS & MULTIMAP ----------

	// use regex to infer metadata from the name of a file
	regex_map_channel = neo_latin_greetings_files_collect_file
		.map{neo_latin_greeting ->
			def (_full_match, family) = (neo_latin_greeting =~ /.+\/(\w+)_greetings_files\.txt/)[0]
			tuple(
				[
					"family": family
				],
				neo_latin_greeting
			)
		}

	// create 2 channels with different structures starting from the same channel
	greetings_multimap = greeting_files
		.multiMap{meta, greeting ->
			only_family: tuple(["family": meta.family], greeting)
			only_sub_category: tuple(["sub_category": meta.sub_category], greeting)
		}

	// View results
	regex_map_channel.view{emission -> "Regex Extracted: $emission"}
	greetings_multimap.only_family.view{emission -> "Only Family: $emission"}
	greetings_multimap.only_sub_category.view{emission -> "Only Sub Category: $emission"}
}
