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

	// ---------- EXERCISE: COMBINE, JOIN & UNIQUE ----------
	
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

	// View results
	inner_join_channel.view{emission -> "Inner Join: $emission"}
	outer_join_channel.view{emission -> "Outer Join: $emission"}
	combine_join_channel.view{emission -> "Combine: $emission"}
	standardized_unique_merged_product.view{emission -> "Standardized Unique: $emission"}
}
