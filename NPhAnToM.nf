#!/usr/bin/env nextflow


nextflow.preview.recursion=true
nextflow.enable.dsl=2
params.IDS = "SRP043510"
params.outdir = "./Results"
params.krakDB = "../KrakenDB"
params.DVF = "../DeepVirFinder"
params.samplerate = 0.1
params.sampleseed = 100


include {FASTERQDUMP;TRIM; KRAKEN; TAXREMOVE} from "./Trimming.nf"
include {SPADES; OFFSETDETECTOR; N50;SUBSAMPLING} from "./Assembly.nf"
include {DVF} from "./DVF.nf"



workflow{
    
    KrakenDB_ch = Channel.fromPath(params.krakDB)

    Channel
        .value(params.IDS)
        .set { read_IDS_ch }

    read_pairs_ch = FASTERQDUMP(read_IDS_ch)

    OFFSET = OFFSETDETECTOR(read_pairs_ch)

    TrimmedFiles_ch = TRIM(read_pairs_ch)
    Krak_ch = KRAKEN(TrimmedFiles_ch, KrakenDB_ch)
    NoEUReads_ch = TAXREMOVE(TrimmedFiles_ch, Krak_ch)


    READS_SUB_ch = SUBSAMPLING(NoEUReads_ch,params.samplerate,params.sampleseed)
    ASSEMBLY_ch = SPADES(READS_SUB_ch,OFFSET)  
    N50STATS = N50(ASSEMBLY_ch)
    
    MULTIASSEMBLY
        .recurse(NoEUReads_ch)
        .times(3)

    VIRPREDFILE_ch = DVF(ASSEMBLY_ch)

}