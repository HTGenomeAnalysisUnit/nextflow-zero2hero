#!/usr/bin/env nextflow

/*
 * Use echo to print a message to a file
 */
process sayHello {
    input:
        tuple val(language), val(message)

    output:
        tuple val(language), path('*_message.txt'), emit: message

    script:
    """
    echo '$message' > ${language}_message.txt
    """
}

process saveHello {
    publishDir params.outdir, mode: 'copy'

    input:
        tuple val(language), path(input_file)

    output:
        path '*_greeting.txt'

    script:
    """
    cat $input_file > ${language}_greeting.txt
    # Remove the next line to allow successful completion
    #exit 1
    """
}

workflow {

    // channel factories
    basic_ch = channel.of(tuple("english", "hello"))
    from_csv_ch = channel.fromPath(file(params.input_csv, checkIfExists: true))
        .splitCsv(header:true)
    from_tsv_ch = channel.fromPath(file(params.input_tsv, checkIfExists: true))
        .splitCsv(header:true, sep:'\t')

    // basic map example
    all_greatings = from_csv_ch
        .mix(from_tsv_ch)
        .map{row -> tuple(row.language, row.greeting)}
        .mix(basic_ch)
        .map{language, greeting -> tuple(language, "In ${language} you say ${greeting}!")}

    // emit a message
    sayHello(all_greatings)
    saveHello(sayHello.out.message)
}
