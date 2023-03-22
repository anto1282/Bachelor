#!/usr/bin/env nextflow


process PHAROKKA {
    if (params.server){
        beforeScript 'module load mash/2.2 bcbio-gff/0.7.0 pharokka' 
        afterScript 'module unload pharokka mash/2.2 bcbio-gff/0.7.0' 
        

        cpus 16
    }
    else{
        conda 'pharokka'
        cpus 8
    }
    errorStrategy = 'ignore'
    
    publishDir "${params.outdir}/${params.IDS}", mode: 'copy'
    

    input: 
    val (pair_id)
    path(viralcontigs) 
    path(nonviralcontigs)

    
    output:
    path "pharokka_${pair_id}/*"
    
    
    script:
    
    
    """
    pharokka.py -i ${viralcontigs} -o pharokka_${pair_id} -f -t ${task.cpus} -d ${params.phaDB} -g prodigal -m
    """
    
}
