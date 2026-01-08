#!/usr/bin/env nextflow

/*
 * Use echo to print a message to a file
 */
process sayHello {

    publishDir params.outdir, mode: 'copy'

    input:
        val message

    output:
        path 'output.txt'

    script:
    """
    echo '$message' > output.txt
    """
}

workflow {

    // emit a message
    sayHello(params.message)
}