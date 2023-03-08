#!/usr/bin/env nextflow


process SPADES {
    conda "spades=3.15.4 conda-forge::openmp"
    publishDir "${params.outdir}/${pair_id}/Assembly", mode: 'copy'

    cpus = 4
    input: 
    tuple val(pair_id), path (reads)
    
    val phred

    output:
    path('assembly/contigs.fasta.gz')

    script:
    def (r1, r2) = reads
    
    """
    spades.py -o assembly -1 ${r1} -2 ${r2} --meta --phred-offset ${phred}
    gzip -n assembly/contigs.fasta
    """
}



process OFFSETDETECTOR {
    input:
    tuple val(pair_id), path(reads)

    output:
    stdout

    script:
    
    def (r1, r2) = reads
    
    """
    python3 ${projectDir}/offsetdetector.py ${r1} ${r2}
    
    """
}

process SUBSAMPLING {
    conda 'agbiome::bbtools'

    input:
    tuple val(pair_id), path(reads)
    val samplerate
    val sampleseed

    output:
    tuple val(pair_id), path(subsampled_reads)

    script:
    def (r1,r2) = reads

    subsampled_reads = reads.collect{
        "${it.baseName}_#*_subsampled.fastq"
    }
"""
reformat.sh in=${r1} in2=${r2} out=${subsampled_reads[0]} out2=${subsampled_reads[1]} samplerate=${samplerate} sampleseed=${sampleseed}

"""

}




process N50 {
    conda 'agbiome::bbtools'

    input: 
    path(contigs_fasta)

    output:
    stdout

    script:
    """
    stats.sh in=${contigs_fasta} | grep 'Main genome scaffold N/L50:' | cut -d: -f2 | cut -d/ -f1 | xargs
    """

}


process MULTIASSEMBLY {
    conda 'agbiome::bbtools'
    publishDir "${params.outdir}/${pair_id}/Subsamples", mode: 'copy'
    input:
    tuple val(pair_id), path(reads)
    val samplerate
    val sampleseed

    output:
    tuple val(pair_id), path (subsampled_reads)
    
    script:
    def (r1,r2) = reads

    subsampled_reads = reads.collect{
        "subs#*_read{1,2}.fastq"
    } 
    
    
    script:
    """
    python3 ${projectDir}/SubSampling.py ${r1} ${r2} ${samplerate} ${sampleseed} ${reads.baseName}
    """
}
