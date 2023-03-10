#!/usr/bin/env nextflow



process SUBSAMPLEFORCOVERAGE {
    if (params.server) {
        module load bbtools
    }
    else {
        conda 'agbiome::bbtools'
    }
    
    publishDir "${params.outdir}/${pair_id}/Subsamplescov", mode: 'copy'
    input:
    tuple val(pair_id), path(reads)
    val samplerate
    val sampleseed

    output:
    tuple samplerate, path(subsampled_reads)
    
    script:
    def (r1,r2) = reads

    subsampled_reads = reads.collect{
        "subs#cov*_read{1,2}.fastq"
    } 
    
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
    path (subsampled_reads)
    
    script:
    def (r1,r2) = reads

    subsampled_reads = reads.collect{
        "subs#n50*_read{1,2}.fastq"
    } 
    
    
    script:
    """
    python3 ${projectDir}/SubSampling.py ${r1} ${r2} ${samplerate} ${sampleseed} n50
    """
}
