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

process SAVE_FAMILY_GREETINGS {
	publishDir params.outdir, mode: 'copy'

	input:
		tuple val(meta), path(greetings)

	output:
		path '*_greeting.txt', emit: family_greetings

	script:
		"""
		cat $greetings > ${meta.family}_greeting.txt
		"""
}

workflow {

	// read greetings from file: tuple([language, greeting, family, sub_category])
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

	// greet in all the languages: tuple([language, greeting, family, sub_category], greeting_string)
	SAVE_GREETING(greetings)
	greeting_files = SAVE_GREETING.out.language_greeting

	// ---------- BRANCH ----------

	// split langagues by family
	greetings_by_family = greeting_files
		.branch{meta, greeting ->
			neo_latin: meta.family == "neo_latin"
			germanic: meta.family == "germanic"
				return tuple(["family": meta.family, "sub_category": meta.sub_category], greeting)
			other: true
				return tuple(meta + ["other_family": true], greeting)
		}

	// ---------- MIX & CONCAT; GROUP TUPLE & TRANSPOSE ----------

	// group germanic languages by family and sub_category: tuple([family, sub_category], [list of greetings of that family])
	all_languages_grouped = greeting_files
		.map{meta, greeting -> tuple(["family": meta.family], greeting)}
		.groupTuple()

	// transpose list elements to common key: tuple([family, sub_category], [list of greetings]) --> tuple([family, sub_category], greeting)
	all_languages_grouped_transposed = all_languages_grouped
		.transpose()

	// group neo latin languages by family: tuple([family], [list of greetings of that family])
	neo_latin_greetings_grouped = greetings_by_family.neo_latin
		.map{meta, greeting -> tuple(["family": meta.family], greeting)}
		.groupTuple()

	// all greetings mixed and concatted
	all_greetings_mixed = neo_latin_greetings_grouped
		.mix(greetings_by_family.germanic)
	all_greetings_concatted = neo_latin_greetings_grouped
		.concat(greetings_by_family.germanic)
	SAVE_FAMILY_GREETINGS(all_greetings_mixed)

	// ---------- FILTER, FLATTEN, COLLECT & COLLECT_FILE ----------

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

	// ---------- COMBINE, JOIN & UNIQUE ----------
	
	// reference metadata channel
	merge_key_channel = channel.fromPath(file(params.input_csv, checkIfExists: true))
		.splitCsv(header:true)
		.map{row -> tuple(
				[
					"family": row.language_family,
					"sub_category": row.language_sub_category
				],
				[
					"language": row.language,
					"greeting": row.greeting
				]
			)
		}

	// inner join example: tuple([family, sub_category], greeting_file, [language, greeting]) --> missing [family, sub_category] (non-germanic languages) are discarded --> use it when you want a 1:1 between the two channels
	inner_join_channel = merge_key_channel
		.join(greetings_by_family.germanic)
	// outer join example: tuple([family, sub_category], greeting_file, [language, greeting]) --> missing [family, sub_category] (non-germanic languages) are returned with null --> use it if you want to preserve elements in the LEFT channel that are not in the RIGHT channel
	outer_join_channel = merge_key_channel
		.join(greetings_by_family.germanic, remainder: true)
	// combine to have all possible combinations: tuple([family, sub_category], greeting_file, [language, greeting]) --> missing [family, sub_category] (non-germanic languages) are discarded, cartesian product --> use it when you want ALL possible combinations between the two channels by a given key (index 0)
	combine_join_channel = merge_key_channel
		.combine(greetings_by_family.germanic, by: 0)

	//concat, uniform and unique the join/merge product
	standardized_unique_merged_product = inner_join_channel
		.concat(outer_join_channel)
		.concat(combine_join_channel)
		.map{meta_family_category, meta_language_greeting, greeting_file -> tuple(meta_family_category + meta_language_greeting, greeting_file)}
		.unique()

	// ---------- ADVANCED MAP FUNCTIONS & MULTIMAP ----------

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
}
