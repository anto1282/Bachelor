#!/usr/bin/env nextflow


process PHAROKKA {
    if (params.server){
        beforeScript 'module load pharokka/1.2.1' 
    }
    else{
        conda 'pharokka'
    }

    if (params.server){
        afterScript 'module unload pharokka.py/1.2.1' 
    }
    
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