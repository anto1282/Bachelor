#!/usr/bin/env nextflow


process PHAROKKA {
    if (params.server){
        //conda "bioconda::pharokka bioconda::mash==2.2 bioconda::bcbio-gff"
        conda "conda-forge::gsl=2.7=he838d99_0"        
        //beforeScript 'module load gsl ; module load mash/2.2 ; module load bcbio-gff/0.7.0 ; module load pharokka' 
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
    module load gsl ; module load mash/2.2 ; module load bcbio-gff/0.7.0 ; module load pharokka
    pharokka.py -i ${viralcontigs} -o pharokka_${pair_id} -f -t ${task.cpus} -d ${params.phaDB} -g prodigal -m
    """
    
}
