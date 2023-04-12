#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include {FASTERQDUMP;TRIM; KRAKEN; TAXREMOVE} from "./Trimming.nf"
include {SPADES; OFFSETDETECTOR; N50} from "./Assembly.nf"
include {DVF; DVEXTRACT;VIRSORTER;CHECKV; SEEKER; PHAGER; VIREXTRACTOR} from "./VirPredictions.nf"
include {PHAROKKA} from "./Pharokka.nf"
include {IPHOP} from "./HostPredictor.nf"



// Main workflow script for the pipeline

workflow{
    
    // CREATES A NEXTFLOW CHANNEL CONTAINING THE READ IDS
    Channel
        .value(params.IDS)
        .flatten()
        .set { read_IDS_ch }

    // DOWNLOADS THE CORRESPONDING READS USING FASTERQDUMP 
    read_pairs_ch = FASTERQDUMP(read_IDS_ch)

    // DETECTING WHICH OFFSET IS USED FOR THE READS
    OFFSET = OFFSETDETECTOR(read_pairs_ch)

    // TRIMS BAD QUALITY READS
    TrimmedFiles_ch = TRIM(read_pairs_ch)
    
    // REMOVES EUKARYOTIC READS USING KRAKEN
    CleanedReads_ch = KRAKEN(TrimmedFiles_ch)
    
    
    // ASSEMBLES THE CLEANED READS USING SPADES
    ASSEMBLY_ch = SPADES(CleanedReads_ch,OFFSET)

    // CALCULATES N50 FROM THE ASSEMBLY
    N50CONTIG = N50(ASSEMBLY_ch)
        

    // VIRUS PREDICTION TOOLS
    DVF_ch = DVF(ASSEMBLY_ch)
    SEEKER_ch = SEEKER(ASSEMBLY_ch)
    PHAGER_ch = PHAGER(ASSEMBLY_ch)

    // EXTRACTS AND JOINS VIRAL PHAGE CONTIGS FROM THE THREE VIRUS PREDICTION TOOLS
    VIRAL_CONTIGS_ch = VIREXTRACTOR(ASSEMBLY_ch, DVF_ch, SEEKER_ch,PHAGER_ch)

    // HOSTPREDICTION TOOL
    HOSTPREDICTION_ch = IPHOP(VIRAL_CONTIGS_ch) 


    //A NNOTATION OF VIRAL CONTIGS USING PHAROKKA
    PHAROKKA_ANNOTATION_ch = PHAROKKA(VIRAL_CONTIGS_ch)

    // CHECKS THE QUALITY OF THE VIRAL CONTIGS
    CHECKV(VIRAL_CONTIGS_ch)



}
