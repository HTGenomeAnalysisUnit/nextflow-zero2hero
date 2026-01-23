workflow {
    // Channels from Exercise 1
    basic_ch = channel.of(tuple("english", "hello"))
    from_csv_ch = channel.fromPath(file(params.input_csv, checkIfExists: true))
        .splitCsv(header:true)
    from_tsv_ch = channel.fromPath(file(params.input_tsv, checkIfExists: true))
        .splitCsv(header:true, sep:'\t')

    // TODO: Combine CSV and TSV channels using mix()
    combined_file_channels = channel.Empty()
    
    // TODO: Transform the combined channels to extract language and greeting as tuples
    file_greetings = channel.Empty()
    
    // TODO: Mix the file greetings with the basic channel
    all_channels_mixed = channel.Empty()
    
    // TODO: Transform all greetings to create formatted messages
    all_greetings = channel.Empty()
    
    // View the final result
    all_greetings.view{emission -> "Final greeting: $emission"}
}
