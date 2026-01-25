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
	/// read greetings from file: tuple([language, greeting, family, sub_category])
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

	// View results to see the difference
	all_greetings_mixed.view{emission -> "Mixed: $emission"}
	all_greetings_concatted.view{emission -> "Concatenated: $emission"}
}
