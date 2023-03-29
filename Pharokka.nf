#!/usr/bin/env nextflow


process PHAROKKA {
    if (params.server){
        conda "/projects/mjolnir1/people/zpx817/KomNy2/py39"
        //conda "conda-forge::gsl=2.6"     
        //beforeScript 'mamba activate ' 
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
    
    //module load mash/2.2 ; module load bcbio-gff/0.7.0 ; module load pharokka
    """
    conda install pandas -y
    module load bcbio-gff
    pharokka.py -i ${viralcontigs} -o pharokka_${pair_id} -f -t ${task.cpus} -d ${params.phaDB} -g prodigal -m
    """
    
}
