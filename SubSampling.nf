#!/usr/bin/env nextflow



process SUBSAMPLEFORCOVERAGE {
    if (params.server) {
        """
        module load bbtools
        """
    }
    else {
        conda 'agbiome::bbtools'
    }
    
    input:
    tuple val(pair_id), path(reads)
    val samplerate
    val sampleseed

    output:
    val (pair_id)
    val samplerate
    path("subs#cov${samplerate}_read1.fastq")
    path("subs#cov${samplerate}_read2.fastq")
    
    script:
    def (r1,r2) = reads
    
    script:
    """
    python3 ${projectDir}/SubSampling.py ${r1} ${r2} ${samplerate} ${sampleseed} coverage
    """
}


process SUBSAMPLEFORN50 {
    conda 'agbiome::bbtools'

    input:
    tuple val(pair_id), path(reads)
    val samplerate
    val sampleseed

    output:
    val (pair_id)
    val sampleseed
    path("subs#n50_${sampleseed}_read1.fastq")
    path("subs#n50_${sampleseed}_read2.fastq")
    
    script:
    def (r1,r2) = reads
  
    script:
    """
    python3 ${projectDir}/SubSampling.py ${r1} ${r2} ${samplerate} ${sampleseed} n50
    """
}
