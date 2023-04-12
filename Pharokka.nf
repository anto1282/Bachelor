#!/usr/bin/env nextflow


process PHAROKKA {
    errorStrategy= "ignore"
    if (params.server){
        beforeScript "singularity pull docker://quay.io/biocontainers/pharokka:1.3.0--hdfd78af_0 -d ${singularity.cacheDir}"
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
    singularity run quay.${singularity.cacheDir}/pharokka:1.3.0--hdfd78af_0.img -i ${viralcontigs} -o pharokka_${pair_id} -f -t ${task.cpus} -d ${params.phaDB} -g prodigal -m
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
