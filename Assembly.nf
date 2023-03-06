#!/usr/bin/env nextflow

params.cpu = 1

process SPADES {
    conda "bioconda::spades=3.15.5"
    publishDir "${params.outdir}/${pair_id}/Assembly", mode: 'copy'

    cpus = cpu
    input: 
    tuple val(pair_id), path(reads)

    output:
    path('*.contigs.fasta')

    script:
    """
    spades.py -o 
    if [ -f contigs.fasta ]; then
        mv contigs.fasta ${prefix}.contigs.fa
        gzip -n ${prefix}.contigs.fa
    fi
    """
}
