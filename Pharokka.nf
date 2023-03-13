#!/usr/bin/env nextflow


process PHAROKKA {
    conda 'pharokka'
    publishDir "${params.outdir}/${params.IDS}/Pharokka", mode: 'copy'

    cpus 8
    input: 
    path(viralcontigs) 
    path(nonviralcontigs)

    output:
    path "*"
    
    
    script:

    """
    pharokka.py -i ${viralcontigs} -o pharokka -f -t ${task.cpus} -d ${params.phaDB} -g prodigal -m
    """
}
