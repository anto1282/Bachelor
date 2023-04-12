#!/usr/bin/env nextflow


process PHAROKKA {
    if (params.server){
        conda "/projects/mjolnir1/people/zpx817/PipeLineFolder/Bachelor/PharokkaEnv2"
        module "biopython/1.80"
        cpus 16
    }
    else{
        conda 'pharokka'
        cpus 8
    }
    
    publishDir "${params.outdir}/${pair_id}", mode: 'copy'
    errorStrategy= "ignore"

    input: 
    val (pair_id)
    path(viralcontigs) 

    
    output:
    path "pharokka_${pair_id}/*"
    
    
    script:

    """
    pharokka.py -i ${viralcontigs} -o pharokka_${pair_id} -f -t ${task.cpus} -d ${params.phaDB} -g prodigal -m
    """
    
}
