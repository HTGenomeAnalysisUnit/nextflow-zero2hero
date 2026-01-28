/*
 * Minimal working pipeline
 * This is the starting point for all exercises
 */


process PROCESS_READ {

    publishDir "./results", mode: 'copy'

    cpus 2
    memory '8 GB'

    input:
    path read

    output:
    path "*.txt"

    script:
    def sample = read.simpleName
    
    suffix = "_processed"
    
    def readType = read.simpleName.endsWith('_R1') ? 'forward' :
                   read.simpleName.endsWith('_R2') ? 'reverse' :
                    'single'

    def flag = sample.contains('tumor') ? '--tumor' : '--normal' 

    def threads =  task.cpus ?: 1 

    def memOpt =  "-m ${task.memory.toMega()}"

    """
    echo "Processing file: ${read.name}" > ${sample}${suffix}.txt
    echo "Read type: ${readType}" >> ${sample}.txt
    echo "Command: mytool ${flag} -i ${read.name}" >> ${sample}.txt
    echo "Threads: ${threads}" >> thread.txt
    echo "Memory option: ${memOpt}" >> memory.txt
    echo "Home: \$HOME" > bash_variables.txt
    echo "Path: \$PATH" >> bash_variables.txt
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
