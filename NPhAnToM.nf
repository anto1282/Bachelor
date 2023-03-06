#!/usr/bin/env nextflow

nextflow.enable.dsl=2
nextflow.preview.recursion=true
params.reads = "$baseDir/data/read{1,2}.fastq"


workflow{
    Channel
        .fromFilePairs(params.reads, checkIfExists: true)
        .set { read_pairs_ch }

    KrakenDB_ch = Channel.fromPath("../KrakenDB")

    TrimmedFiles_ch = TRIM(read_pairs_ch)
    Krak_ch = KRAKEN(TrimmedFiles_ch, KrakenDB_ch)
    NoEUReads_ch = TAXREMOVE(TrimmedFiles_ch, Krak_ch)

}