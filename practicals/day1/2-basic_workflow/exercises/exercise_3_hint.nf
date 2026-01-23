#!/usr/bin/env nextflow

// TODO: Define the sayHello process
// Input: tuple val(language), val(message)
// Output: tuple val(language), path('*_message.txt'), emit: message
// Script: echo the message to a file named ${language}_message.txt
process sayHello {
    // YOUR CODE HERE
}

// TODO: Define the saveHello process  
// publishDir: params.outdir, mode: 'copy'
// Input: tuple val(language), path(input_file)
// Output: path '*_greeting.txt'
// Script: copy input_file content to ${language}_greeting.txt
process saveHello {
    // YOUR CODE HERE
}

workflow {
    // Complete channel operations from Exercise 2
    basic_ch = channel.of(tuple("english", "hello"))
    from_csv_ch = channel.fromPath(file(params.input_csv, checkIfExists: true))
        .splitCsv(header:true)
    from_tsv_ch = channel.fromPath(file(params.input_tsv, checkIfExists: true))
        .splitCsv(header:true, sep:'\t')

    // try to use a series of operators without creating intermediate channels to create the greetings channel
    all_greetings = channel.empty()

    // TODO: Call sayHello process with all_greetings channel
    // YOUR CODE HERE
    
    // TODO: Call saveHello process with the output from sayHello
    // YOUR CODE HERE
}
