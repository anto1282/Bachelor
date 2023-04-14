#!/usr/bin/env nextflow


process PHAROKKA {
    errorStrategy= "ignore"
    if (params.server){
        container = "docker://quay.io/biocontainers/pharokka:1.2.1--hdfd78af_0"
        cpus 8
    }
    else{
        conda 'pharokka'
        cpus 8
    }
    
    publishDir "${params.outdir}/${pair_id}", mode: 'copy'

    input: 
    val (pair_id)
    path(viralcontigs) 

    
    output:
    path "pharokka_${pair_id}/*"
    
    
    script:

    """
    gzip -d -f ${viralcontigs}
    pharokka.py -i ${viralcontigs.baseName} -o pharokka_${pair_id} -f -t ${task.cpus} -d ${params.phaDB} -g prodigal -m
    gzip -f ${viralcontigs.baseName}
    """
    
}

process PHAROKKA2 {
    errorStrategy= "ignore"
    if (params.server){
        module "mash=2.2"
        module "bcbio-gff"
        module "pharokka"
        module "biopython/1.80"
        cpus 16
    }
    else{
        conda 'pharokka'
        cpus 8
    }
    
    publishDir "${params.outdir}/${pair_id}", mode: 'copy'

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
