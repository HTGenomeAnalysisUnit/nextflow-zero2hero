#!/usr/bin/env nextflow
nextflow.enable.dsl=2

process hello {
    container 'shub://vsoch/hello-world'

    input:
    path input_file

    script:
    """
    cat ${input_file}
    """
}

workflow {
    file_input = Channel.fromPath(params.input_file)
    hello(file_input)

}

