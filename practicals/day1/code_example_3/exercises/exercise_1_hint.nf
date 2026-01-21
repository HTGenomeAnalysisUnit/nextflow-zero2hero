#!/usr/bin/env nextflow

workflow {
    // TODO: Create a basic channel with a tuple containing ("english", "hello")
    basic_ch = channel.Empty()
    
    // TODO: Create a channel from CSV file and split it with headers
    from_csv_ch = channel.Empty()
    
    // TODO: Create a channel from TSV file and split it with headers (tab-separated)
    from_tsv_ch = channel.Empty()
    
    // Print channels to verify they work
    basic_ch.view {channel_content -> "Basic: $channel_content"}
    from_csv_ch.view {channel_content -> "CSV: $channel_content"}
    from_tsv_ch.view {channel_content -> "TSV: $channel_content"}
}
