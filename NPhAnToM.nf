#!/usr/bin/env nextflow


//nextflow.preview.recursion=true
nextflow.enable.dsl=2
params.IDS = "SRP043510"
params.outdir = "./Results"
params.krakDB = "../KrakenDB"
params.DVF = "../DeepVirFinder"

include {FASTERQDUMP;TRIM; KRAKEN; TAXREMOVE} from "./Trimming.nf"
include {DVF} from "./DVF.nf"
include {SPADES; offsetdetector} from "./Assembly.nf"

workflow{
    


    KrakenDB_ch = Channel.fromPath(params.krakDB)

    Channel
        .value(params.IDS)
        .set { read_IDS_ch }

    read_pairs_ch = FASTERQDUMP(read_IDS_ch)

    OFFSET = offsetdetector(read_pairs_ch)
    OFFSET.view()

    TrimmedFiles_ch = TRIM(read_pairs_ch)
    Krak_ch = KRAKEN(TrimmedFiles_ch, KrakenDB_ch)
    NoEUReads_ch = TAXREMOVE(TrimmedFiles_ch, Krak_ch)

    ASSEMBLY_ch = SPADES(NoEUReads_ch)  
    VIRPREDFILE_ch = DVF(ASSEMBLY_ch)

}