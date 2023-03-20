#!/usr/bin/env nextflow


process PHAROKKA {
    if (params.server){
        beforeScript 'module load mash/2.2 bcbio-gff/0.7.0 pharokka/' 
        afterScript 'module unload mash/2.2 bcbio-gff/0.7.0 pharokka/' 
        

        cpus 16
    }
    else{
        conda 'pharokka'
        cpus 8
    }
    
    publishDir "${params.outdir}/${params.IDS}", mode: 'copy'
    

    input: 
    val (pair_id)
    path(viralcontigs) 
    path(nonviralcontigs)

    
    output:
    path "*"
    
    
    script:

    """
    pharokka.py -i ${viralcontigs} -o pharokka -f -t ${task.cpus} -d ${params.phaDB} -g prodigal -m
    """
}
