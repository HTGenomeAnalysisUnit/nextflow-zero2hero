workflow {
    // Create a basic channel with a tuple
    basic_ch = channel.of(tuple("english", "hello"))
    
    // Create channel from CSV file
    from_csv_ch = channel.fromPath(file(params.input_csv, checkIfExists: true))
        .splitCsv(header:true)
    
    // Create channel from TSV file
    from_tsv_ch = channel.fromPath(file(params.input_tsv, checkIfExists: true))
        .splitCsv(header:true, sep:'\t')
    
    // Print channels to verify they work
    basic_ch.view {emission -> "Basic: $emission"}
    from_csv_ch.view {emission -> "CSV: $emission"}
    from_tsv_ch.view {emission -> "TSV: $emission"}
}
