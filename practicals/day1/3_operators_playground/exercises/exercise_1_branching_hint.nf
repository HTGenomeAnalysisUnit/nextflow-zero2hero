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

	// ---------- EXERCISE: IMPLEMENT BRANCH ----------
	// TODO: Create a branch operation that splits greeting_files by language family
	// Create three branches:
	// 1. neo_latin: for Romance languages (family == "neo_latin")
	// 2. germanic: for Germanic languages (family == "germanic") 
	//    - Transform output to tuple(["family": meta.family, "sub_category": meta.sub_category], greeting)
	// 3. other: for any other languages (fallback condition)
	//    - Transform output to tuple(meta + ["other_family": true], greeting)
	
	greetings_by_family = greeting_files
		.branch{meta, greeting ->
			// YOUR CODE HERE
			// neo_latin: 
			// germanic: 
			//     return 
			// other: 
			//     return 
		}

	// View the results to verify branching works
	greetings_by_family.neo_latin.view{emission ->"Neo Latin: $emission"}
	greetings_by_family.germanic.view{emission ->"Germanic: $emission"}
	greetings_by_family.other.view{emission ->"Other: $emission"}
}
