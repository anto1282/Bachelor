#!/usr/bin/env nextflow


process PHAROKKA {
    conda 'pharokka'
    publishDir "${params.outdir}/${params.IDS}", mode: 'copy'

    cpus 8
    input: 
    val (pair_id)
    path(viralcontigs) 
    path(nonviralcontigs)
    path phaDB

    output:
    path "*"
    
    
    script:

    """
    pharokka.py -i ${viralcontigs} -o pharokka -f -t ${task.cpus} -d ${phaDB} -g prodigal -m
    """
}
params.phaDB = "../PHAROKKADB"