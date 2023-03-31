#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include {FASTERQDUMP;TRIM; KRAKEN; TAXREMOVE} from "./Trimming.nf"
include {SPADES; SPADES1; OFFSETDETECTOR; N50;COVERAGE} from "./Assembly.nf"
include {SUBSAMPLEFORCOVERAGE; SUBSAMPLEFORN50} from "./SubSampling.nf"
include {DVF; DVEXTRACT;VIRSORTER;CHECKV; SEEKER; PHAGER; VIREXTRACTOR} from "./VirPredictions.nf"
include {PHAROKKA} from "./Pharokka.nf"
include {IPHOP;DEEPHOST;PHIST} from "./HostPredictor.nf"




workflow{

    Channel
        .value(params.IDS)
        .flatten()
        .set { read_IDS_ch }

    read_pairs_ch = FASTERQDUMP(read_IDS_ch)

    OFFSET = OFFSETDETECTOR(read_pairs_ch)

    TrimmedFiles_ch = TRIM(read_pairs_ch)
    
    NoEUReads_ch = KRAKEN(TrimmedFiles_ch)
   
    ASSEMBLY_ch = SPADES(NoEUReads_ch,OFFSET)

    N50CONTIG = N50(ASSEMBLY_ch)
    
    

    // VIRUS PREDICTION TOOLS
    DVF_ch = DVF(ASSEMBLY_ch)
    VIRSORTER_ch = VIRSORTER(ASSEMBLY_ch) //NOT WORKING (Vi mangler permission til at oprette filer i database mappen til virsorter)
    SEEKER_ch = SEEKER(ASSEMBLY_ch)

    PHAGER_ch = PHAGER(ASSEMBLY_ch)

    VIRAL_CONTIGS_ch = VIREXTRACTOR(ASSEMBLY_ch, DVF_ch, SEEKER_ch)

    // HOSTPREDICTION TOOLS
    //HOSTPREDICTION1_ch = DEEPHOST(VIREXTRACTED_ch)
    HOSTPREDICTION2_ch = IPHOP(VIRAL_CONTIGS_ch) 

    //HOSTPREDICTION3_ch = PHIST(VIREXTRACTED_ch) 


    //ANNOTATION OF VIRAL CONTIGS
    //PHAROKKA_ANNOTATION_ch = PHAROKKA(VIREXTRACTED_ch)

    CHECKV(VIRAL_CONTIGS_ch)



}