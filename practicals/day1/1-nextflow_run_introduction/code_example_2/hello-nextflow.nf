#!/usr/bin/env nextflow

/*
 * Use echo to print a message to a file
 */
process sayHello {
    input:
        val message

    output:
        path 'message.txt', emit: message

    script:
    """
    echo '$message' > message.txt
    """
}

process saveHello {

    publishDir params.outdir, mode: 'copy'

    input:
        path input_file

    output:
        path 'output.txt'

    script:
    """
    cat $input_file > output.txt
    # Remove the next line to allow successful completion
    exit 1
    """
}

workflow {

    // emit a message
    sayHello(params.message)
    saveHello(sayHello.out.message)

}