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
	
	// TODO 1: Create a reference metadata channel for joining
	merge_key_channel = channel.fromPath(file(params.input_csv, checkIfExists: true))
		.splitCsv(header:true)
		.map{row -> tuple(
				// YOUR CODE HERE - create tuple with family/sub_category as key
				// and language/greeting as value
			)
		}

	// TODO 2: Perform inner join - only matching keys are kept
	inner_join_channel = merge_key_channel
		// YOUR CODE HERE - join with greetings_by_family.germanic

	// TODO 3: Perform outer join - unmatched items from LEFT channel are kept with null
	outer_join_channel = merge_key_channel
		// YOUR CODE HERE - join with remainder: true

	// TODO 4: Use combine for cartesian product by key
	combine_join_channel = merge_key_channel
		// YOUR CODE HERE - combine with greetings_by_family.germanic by key (index 0)

	// TODO 5: Standardize and deduplicate the results
	standardized_unique_merged_product = inner_join_channel
		// YOUR CODE HERE - concat with other join results, map to standardize structure, then unique

	// View results
	inner_join_channel.view{emission -> "Inner Join: $emission"}
	outer_join_channel.view{emission -> "Outer Join: $emission"}
	combine_join_channel.view{emission -> "Combine: $emission"}
	standardized_unique_merged_product.view{emission -> "Standardized Unique: $emission"}
}
