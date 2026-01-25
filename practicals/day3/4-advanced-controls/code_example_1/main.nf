/*
 * Minimal working pipeline
 * This is the starting point for all exercises
 */


process PROCESS_READ {

    publishDir "./results", mode: 'copy'


    input:
    path read

    output:
    path "result.txt"

    script:
    """
    echo "Processing file: ${read.name}" > result.txt
    """
}


workflow {
    
    Channel
    .of(
        file('sample1_R1.fastq.gz'),
        file('sample1_R2.fastq.gz'),
        file('sample_tumor.fastq.gz'),
        file('sample_normal.fastq.gz')
    )
    .set { reads_ch }

    PROCESS_READ(reads_ch)
}
