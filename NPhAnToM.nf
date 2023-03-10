#!/usr/bin/env nextflow


//nextflow.preview.recursion=true
nextflow.enable.dsl=2
params.IDS = "SRR23446271"
params.outdir = "./Results"
params.krakDB = "../KrakenDB"
params.DVF = "../DeepVirFinder"
params.samplerate = 0.3
params.sampleseed = 5



include {FASTERQDUMP;TRIM; KRAKEN; TAXREMOVE} from "./Trimming.nf"
include {SPADES; SPADES1; OFFSETDETECTOR; N50;SUBSAMPLEFORCOVERAGE;SUBSAMPLEFORN50;COVERAGE} from "./Assembly.nf"
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


   // READ1_ch = Channel.create()
    //READ2_ch = Channel.create()

    SUBSAMPLEFORCOVERAGE(NoEUReads_ch,params.samplerate,params.sampleseed)
    .toSortedList( {a, b -> a[1] <=> b[1]})
    .flatmap()
    .multiMap{
        it -> 
        READ1_ch: it 
        READ2_ch: it
    }
    .set { results1 }

    results1.READ1_ch.view()
    
    results1.READ1_ch.merge(results1.READ2_ch).view()

    READS_SUBS_ch.view()
    



    READS_ch.view()
    ASSEMBLY_ch_COVERAGE = SPADES(READS_ch,OFFSET)

    //READS_ch.view()
    ASSEMBLY_ch_COVERAGE = SPADES(READS_SUBS_ch,OFFSET)

    SAMPLERATE_LIST = COVERAGE(READS_SUBS_ch,ASSEMBLY_ch_COVERAGE).collect().max()

    

    //READS_SUBS_ch = SUBSAMPLEFORN50(NoEUReads_ch, SAMPLERATE_LIST.max(), params.sampleseed)
    
    //READS_ch_N50 = Channel.fromFilePairs("/${projectDir}/Results/${params.IDS}/Subsamplesn50/*_read{1,2}*")
    
   // ASSEMBLY_ch_N50 = (SPADES1(READS_ch_N50,OFFSET))

    //N50STATS = N50(ASSEMBLY_ch_N50)

    // VIRPREDFILE_ch = DVF(ASSEMBLY_ch_N50)

}