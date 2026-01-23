workflow {
    // Channels from Exercise 1
    basic_ch = channel.of(tuple("english", "hello"))
    from_csv_ch = channel.fromPath(file(params.input_csv, checkIfExists: true))
        .splitCsv(header:true)
    from_tsv_ch = channel.fromPath(file(params.input_tsv, checkIfExists: true))
        .splitCsv(header:true, sep:'\t')

    // Combine CSV and TSV channels
    combined_file_channels = from_csv_ch.mix(from_tsv_ch)
    
    // Transform to extract language and greeting as tuples
    file_greetings = combined_file_channels.map{row -> tuple(row.language, row.greeting)}
    
    // Mix with basic channel
    all_channels_mixed = file_greetings.mix(basic_ch)
    
    // Transform to create formatted messages
    all_greetings = all_channels_mixed.map {language, greeting -> tuple(language, "In ${language} you say ${greeting}!")}
    
    // View the final result
    all_greetings.view{emission -> "Final greeting: $emission"}
}
