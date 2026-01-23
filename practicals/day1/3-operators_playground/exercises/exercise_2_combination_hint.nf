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

	// Branch (from Exercise 1 - provided as reference)
	greetings_by_family = greeting_files
		.branch{meta, greeting ->
			neo_latin: meta.family == "neo_latin"
			germanic: meta.family == "germanic"
				return tuple(["family": meta.family, "sub_category": meta.sub_category], greeting)
			other: true
				return tuple(meta + ["other_family": true], greeting)
		}

	// ---------- EXERCISE: MIX & CONCAT; GROUP TUPLE & TRANSPOSE ----------
	
	// TODO 1: Group all greeting files by family using groupTuple
	// Transform greeting_files to tuple(["family": meta.family], greeting) then group
	all_languages_grouped = greeting_files
		// YOUR CODE HERE - map to extract family, then groupTuple

	// TODO 2: Use transpose to flatten the grouped collections
	all_languages_grouped_transposed = all_languages_grouped
		// YOUR CODE HERE - apply transpose

	// TODO 3: Group neo latin languages by family
	neo_latin_greetings_grouped = greetings_by_family.neo_latin
		// YOUR CODE HERE - map to group by family, then groupTuple

	// TODO 4: Compare mix vs concat behavior
	// Mix neo_latin_greetings_grouped with greetings_by_family.germanic
	all_greetings_mixed = neo_latin_greetings_grouped
		// YOUR CODE HERE - use mix

	// Concat neo_latin_greetings_grouped with greetings_by_family.germanic  
	all_greetings_concatted = neo_latin_greetings_grouped
		// YOUR CODE HERE - use concat

	// Process the mixed results
	SAVE_FAMILY_GREETINGS(all_greetings_mixed)

	// View results to see the difference
	all_greetings_mixed.view{emission -> "Mixed: $emission"}
	all_greetings_concatted.view{emission -> "Concatenated: $emission"}
}
