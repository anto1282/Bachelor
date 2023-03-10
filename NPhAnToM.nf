#!/usr/bin/env nextflow


//nextflow.preview.recursion=true
nextflow.enable.dsl=2
params.IDS = "SRR23446271"
params.outdir = "./Results"
params.krakDB = "../KrakenDB"
params.DVF = "../DeepVirFinder"
params.samplerate = 0.3
params.sampleseed = 5
params.server = false


include {FASTERQDUMP;TRIM; KRAKEN; TAXREMOVE} from "./Trimming.nf"
include {SPADES; SPADES1; OFFSETDETECTOR; N50;COVERAGE} from "./Assembly.nf"
include {SUBSAMPLEFORCOVERAGE; SUBSAMPLEFORN50} from "./SubSampling.nf"
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


    SAMPLERATES_ch = Channel.fromList([0.05,0.1,0.15,0.2,0.25])

    SUBSAMPLEFORCOVERAGE(NoEUReads_ch,SAMPLERATES_ch,params.sampleseed)
    // .flatten()
    // .unique()
    // .buffer( size: 2 )
    
    .set { READS_SUBS_ch }

    READS_SUBS_ch[0].view()

    ASSEMBLY_ch_COVERAGE = SPADES(READS_SUBS_ch,OFFSET).flatten().unique().join(READS_SUBS_ch)



    SAMPLERATE_BEST = COVERAGE(ASSEMBLY_ch_COVERAGE).toInteger().collect()



    // SAMPLERATE_BEST.view()
    // SAMPLERATE_BEST.flatten().max().view()

    // READS_ch_N50= SUBSAMPLEFORN50(NoEUReads_ch, SAMPLERATE_BEST.flatten().max(), params.sampleseed)
    // .flatten()
    // .unique()
    // .buffer( size: 2 )
    
    // ASSEMBLY_ch_N50 = SPADES1(READS_ch_N50,OFFSET).flatten().unique()

    // N50STATS = N50(ASSEMBLY_ch_N50)

    // VIRPREDFILE_ch = DVF(ASSEMBLY_ch_N50)

}