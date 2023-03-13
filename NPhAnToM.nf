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
params.cutoff = 0.7
params.phaDB = "../PHAROKKADB"



include {FASTERQDUMP;TRIM; KRAKEN; TAXREMOVE} from "./Trimming.nf"
include {SPADES; SPADES1; OFFSETDETECTOR; N50;COVERAGE} from "./Assembly.nf"
include {SUBSAMPLEFORCOVERAGE; SUBSAMPLEFORN50} from "./SubSampling.nf"
include {DVF; DVEXTRACT} from "./DVF.nf"
include {PHAROKKA} from "./Pharokka.nf"
include {DEEPHOST} from "./HostPredictor.nf"



workflow{
    
    KrakenDB_ch = Channel.fromPath(params.krakDB)

    Channel
        .value(params.IDS)
        .set { read_IDS_ch }

    read_pairs_ch = FASTERQDUMP(read_IDS_ch)

    OFFSET = OFFSETDETECTOR(read_pairs_ch)

    TrimmedFiles_ch = TRIM(read_pairs_ch)
    Krak_ch = KRAKEN(TrimmedFiles_ch, KrakenDB_ch)
    NoEUReads_ch = TAXREMOVE(TrimmedFiles_ch, Krak_ch).collect()


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

    //N50CONTIG = N50(ASSEMBLY_ch_N50).max{ a, b -> a[0] <=> b[0] }
    //N50CONTIG.view()

    VIRPREDFILE_ch = DVF(ASSEMBLY_ch)

    VIREXTRACTED_ch = DVEXTRACT(VIRPREDFILE_ch)

    HOSTPREDICTION = DEEPHOST(VIREXTRACTED_ch,)

    PHADB_ch = Channel.fromPath(params.phaDB)

    PHAROKKA_ANNOTATION_ch = PHAROKKA(VIREXTRACTED_ch,PHADB_ch)

}