#!/usr/bin/env nextflow


process SPADES {
    conda "spades=3.15.4 conda-forge::openmp seqkit"
    publishDir "${params.outdir}/${params.IDS}/Assembly", mode: 'copy'

    cpus 4
    input: 
    path(reads)
    
    val phred

    output:
    path(assemblies)

    script:
    def (r1, r2) = reads
    

    assemblies = reads.collect{
        "assembly${r1.baseName}/${r1}_contigs.fasta.gz"
    } 

    """
    spades.py -o assembly${r1.baseName} -1 ${r1} -2 ${r2} --meta --phred-offset ${phred}
    seqkit sort assembly${r1.baseName}/contigs.fasta > contigs.fasta
    gzip -n assembly${r1.baseName}/contigs.fasta
    mv assembly${r1.baseName}/contigs.fasta.gz assembly${r1.baseName}/${r1}_contigs.fasta.gz

    """
}

process SPADES1 {
    conda "spades=3.15.4 conda-forge::openmp"
    publishDir "${params.outdir}/${params.IDS}/Assembly", mode: 'copy'

    cpus 4
    input: 
    path(reads)
    
    val phred

    output:
    path(assemblies)

    script:
    def (r1, r2) = reads
    

    assemblies = reads.collect{
        "assembly${r1.baseName}/${r1}_contigs.fasta.gz"
    } 

    """
    spades.py -o assembly${r1.baseName} -1 ${r1} -2 ${r2} --meta --phred-offset ${phred}
    gzip -n assembly${r1.baseName}/contigs.fasta
    
    mv assembly${r1.baseName}/contigs.fasta.gz assembly${r1.baseName}/${r1}_contigs.fasta.gz

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


process SUBSAMPLEFORCOVERAGE {
    conda 'agbiome::bbtools'
    publishDir "${params.outdir}/${pair_id}/Subsamplescov", mode: 'copy'
    input:
    tuple val(pair_id), path(reads)
    val samplerate
    val sampleseed

    output:
    path (subsampled_reads)
    
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


process COVERAGE {
    conda 'agbiome::bbtools'
    
    input:
    path(reads)
    path(contigs_fasta)

    output:
    stdout
    
    script:
    def (r1,r2) = reads
    
    script:
    """
    python3 ${projectDir}/CoverageFinder.py ${r1} ${r2} ${contigs_fasta}
    """
}