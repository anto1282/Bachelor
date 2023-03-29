#!/usr/bin/env nextflow


process PHAROKKA {
    if (params.server){
        conda "bioconda::pharokka bioconda::mash==2.2 bioconda::bcbio-gff"
        //beforeScript 'module load gsl ; module load mash/2.2 ; module load bcbio-gff ; module load pharokka' 
        //afterScript 'module unload pharokka mash bcbio-gff/0.7.0' 

        cpus 16
    }
    else{
        conda 'pharokka'
        cpus 8
    }
    
    publishDir "${params.outdir}/${pair_id}", mode: 'copy'
    errorStrategy= "finish"

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
