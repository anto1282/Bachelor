#!/usr/bin/env nextflow


process SPADES {
    if (params.server) {
        beforeScript 'module load spades/3.15.5'
        cpus 16
    }
    else {
        conda "spades=3.15.4 conda-forge::openmp"
        cpus 8
    }
    if (params.server) {
        afterScript 'module unload spades'
    }
    
    publishDir "${params.outdir}/${pair_id}/Assembly", mode: 'copy'

    
    input: 
    tuple val(pair_id), path(reads)
    val phred

    output:
    tuple val(pair_id), path ("contigs.fasta.gz")

    
    script:
    def(r1,r2) = reads
    """
    spades.py -o Assembly${pair_id} -1 ${r1} -2 ${r2} --meta --phred-offset ${phred} --threads ${task.cpus}
    gzip -n Assembly${pair_id}/contigs.fasta
    mv Assembly${pair_id}/contigs.fasta.gz contigs.fasta.gz

    """
}



process OFFSETDETECTOR {
    cpus 1
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


//DEPRECATED FUNCTIONS
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


