#!/usr/bin/env nextflow



process SUBSAMPLEFORCOVERAGE {
    if (params.server) {
        module load bbtools
    }
    else {
        conda 'agbiome::bbtools'
    }
    
    //publishDir "${params.outdir}/${pair_id}/Subsamplescov", mode: 'copy'
    input:
    tuple val(pair_id), path(reads)
    val samplerate
    val sampleseed

    output:
    //tuple val (samplerate), path(subsampled_reads)
    val samplerate
    path("subs#cov${samplerate}_read1.fastq")
    path("subs#cov${samplerate}_read2.fastq")
    
    script:
    def (r1,r2) = reads

    //subsampled_reads = samplerate.collect{
    //   "subs#cov${it}_read{1,2}.fastq"
    //}
    
    script:
    """
    python3 ${projectDir}/SubSampling.py ${r1} ${r2} ${samplerate} ${sampleseed} coverage
    """
}


process SUBSAMPLEFORN50 {
    conda 'agbiome::bbtools'
    publishDir "${params.outdir}/${pair_id}/Subsamplesn50", mode: 'copy'
    input:
    tuple val(pair_id), path(reads)
    val samplerate
    val sampleseed

    output:
    val sampleseed
    path("subs#n50_${sampleseed}_read1.fastq")
    path("subs#n50_${sampleseed}_read2.fastq")
    
    script:
    def (r1,r2) = reads

    //subsampled_reads = reads.collect{
    //    "subs#n50*_read{1,2}.fastq"
    //} 
    
    
    script:
    """
    python3 ${projectDir}/SubSampling.py ${r1} ${r2} ${samplerate} ${sampleseed} n50
    """
}
