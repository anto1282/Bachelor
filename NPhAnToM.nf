#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include {FASTERQDUMP;TRIM; KRAKEN; TAXREMOVE} from "./Trimming.nf"
include {SPADES; SPADES1; OFFSETDETECTOR; N50;COVERAGE} from "./Assembly.nf"
include {SUBSAMPLEFORCOVERAGE; SUBSAMPLEFORN50} from "./SubSampling.nf"
include {DVF; DVEXTRACT;VIRSORTER;CHECKV; SEEKER} from "./VirPredictions.nf"
include {PHAROKKA} from "./Pharokka.nf"
include {IPHOP} from "./HostPredictor.nf"




workflow{
    
   // KrakenDB_ch = Channel.fromPath(params.krakDB)

    Channel
        .value(params.IDS)
        .flatten()
        .set { read_IDS_ch }

    read_pairs_ch = FASTERQDUMP(read_IDS_ch)

    OFFSET = OFFSETDETECTOR(read_pairs_ch)

    TrimmedFiles_ch = TRIM(read_pairs_ch)
    
    NoEUReads_ch = KRAKEN(TrimmedFiles_ch)


    //SAMPLERATES_ch = Channel.fromList([0.05,0.1,0.15,0.2,0.25]).flatten()
    //SUBSAMPLEFORCOVERAGE(NoEUReads_ch,SAMPLERATES_ch,params.sampleseed)
    //.set { READS_SUBS_ch }
    //ASSEMBLY_ch_COVERAGE = SPADES(READS_SUBS_ch,OFFSET)
    //SAMPLERATE_BEST = COVERAGE(ASSEMBLY_ch_COVERAGE).toInteger().collect()
   // SAMPLERATE_BEST.view()
    //SAMPLERATE_BEST.flatten().max().view()
    //SAMPLESEEDS_ch = Channel.fromList([1,2,3,4,5]).flatten() // MAKE python script to create list
    //SUBSAMPLEFORN50(NoEUReads_ch, SAMPLERATE_BEST.flatten().max(), SAMPLESEEDS_ch)
    //.set { READS_ch_N50 }
    
    ASSEMBLY_ch = SPADES(NoEUReads_ch,OFFSET)

    N50CONTIG = N50(ASSEMBLY_ch)
    //N50CONTIG.view()


    //VIREXTRACTED_ch = DVF(ASSEMBLY_ch)
    VIRSORTER_ch = VIRSORTER(ASSEMBLY_ch)
    SEEKER_ch = SEEKER(ASSEMBLY_ch)


    //HOSTPREDICTION1_ch = DEEPHOST(VIREXTRACTED_ch)
    //HOSTPREDICTION2_ch = IPHOP(VIREXTRACTED_ch) 


    //PHADB_ch = Channel.fromPath(params.phaDB)
    PHAROKKA_ANNOTATION_ch = PHAROKKA(VIREXTRACTED_ch)

    CHECKV(VIREXTRACTED_ch)



}