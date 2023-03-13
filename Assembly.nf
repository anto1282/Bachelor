#!/usr/bin/env nextflow


process SPADES {
    conda "spades=3.15.4 conda-forge::openmp seqkit"
    publishDir "${params.outdir}/${pair_id}/Assembly", mode: 'copy'

    cpus 4
    input: 
    val (pair_id)
    val samplerate
    path(r1)
    path(r2)
    
    val phred

    output:
    //path(assemblies)
    val (pair_id)
    path ("cov_${samplerate}_contigs.fasta.gz")
    path (r1)
    path (r2)

    script:
    """
    spades.py -o assembly${r1.baseName} -1 ${r1} -2 ${r2} --meta --phred-offset ${phred}
    gzip -n assembly${r1.baseName}/contigs.fasta
    mv assembly${r1.baseName}/contigs.fasta.gz cov_${samplerate}_contigs.fasta.gz

    """
}

process SPADES1 {
    conda "spades=3.15.4 conda-forge::openmp seqkit"
    publishDir "${params.outdir}/${pair_id}/Assembly", mode: 'copy'

    cpus 4
    input: 
    val (pair_id)
    val sampleseed
    path(r1)
    path(r2)
    
    val phred

    output:
    val (pair_id)
    path ("n50_${sampleseed}_contigs.fasta.gz")


    script:
    """
    spades.py -o assembly${r1.baseName} -1 ${r1} -2 ${r2} --meta --phred-offset ${phred}
    gzip -n assembly${r1.baseName}/contigs.fasta
    mv assembly${r1.baseName}/contigs.fasta.gz n50_${sampleseed}_contigs.fasta.gz

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

process COVERAGE {
    conda 'agbiome::bbtools'
    
    input:
    val pair_id
    path(contigs_fasta)
    path(r1)
    path(r2)
    

    output:
    stdout
    

    script:
    """
    python3 ${projectDir}/CoverageFinder.py ${r1} ${r2} ${contigs_fasta}
    """
}

process N50 {
    conda 'agbiome::bbtools'

    input: 
    val (pair_id)
    path(contigs_fasta)


    output:
    tuple stdout, path (contigs_fasta), val (pair_id)
    

    script:
    """
    stats.sh in=${contigs_fasta} | grep 'Main genome scaffold N/L50:' | cut -d: -f2 | cut -d/ -f1 | xargs
    """

}


