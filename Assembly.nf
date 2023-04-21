#!/usr/bin/env nextflow

// Script that contains nextflow processes for assembling illumina reads, as well as for detecting the offset of 
// the reads and calculating a N50 score.

// Assembly using spades
process SPADES {
    if (params.server) {
        beforeScript 'module load spades/3.15.5'
        cpus 24
        memory { 16.GB + (16.GB * 1/2*task.attempt) }
        errorStrategy 'retry'
        maxRetries  = 3
        afterScript 'module unload spades/3.15.5'
         time = 2.h
    }
    else {
        conda "spades=3.15.5 conda-forge::openmp"
        cpus 8
        memory '4 GB'
    }
    
    
    publishDir "${params.outdir}/${pair_id}/Assembly", mode: 'copy'

    
    input: 
    val(pair_id)
    path(r1)
    path(r2)

    val phred

    output:
    tuple val(pair_id), path ("${params.contigs}.fasta.gz")

    
    script:
    """
    gzip -d -f ${r1}
    gzip -d -f ${r2}
    spades.py -o Assembly${pair_id} -1 ${r1.baseName} -2 ${r2.baseName} --meta --threads ${task.cpus} --memory ${task.cpus + (8 * task.attempt)} --phred-offset ${phred} 
    gzip -n Assembly${pair_id}/${params.contigs}.fasta   
    mv Assembly${pair_id}/${params.contigs}.fasta.gz ${params.contigs}.fasta.gz
    gzip ${r1.baseName}
    gzip ${r2.baseName}
    """
}


// Offset detection using offsetdetector.py

process OFFSETDETECTOR {
    cpus 2
    input:
    val(pair_id)
    path(r1)
    path(r2)

    output:
    stdout

    script:
    
    """
    gzip -d ${r1} -f
    gzip -d ${r2} -f
    python3 ${projectDir}/offsetdetector.py ${r1.baseName} ${r2.baseName}
    gzip ${r1.baseName}
    gzip ${r2.baseName}
    """
}


// Calculating N50 score from contigs using the bbmap stash.sh script

process N50 {
    if (params.server) {
        beforeScript 'module load bbmap'
        cpus 4
        memory '16 GB'
    }
    else {
        conda "agbiome::bbtools"
        cpus 4
        memory '4 GB'
    }
    publishDir "${params.outdir}/${pair_id}/Assembly", mode: 'copy'



    input: 
    tuple val (pair_id), path(contigs_fasta)
    


    output:    

    script:
    """
    gzip -f -d ${contigs_fasta}
    stats.sh in=${contigs_fasta.baseName} >> ${projectDir}/${params.outdir}/${pair_id}/assemblyStats
    gzip ${contigs_fasta.baseName}
    """

}
