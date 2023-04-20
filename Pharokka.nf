#!/usr/bin/env nextflow


process PHAROKKA {
    errorStrategy= "ignore"
    if (params.server){
        container = "docker://quay.io/biocontainers/pharokka:1.3.0--hdfd78af_0"
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

process PHAROKKAPLOTTER {
    errorStrategy= "ignore"
    if (params.server){
        container = "docker://quay.io/biocontainers/pharokka:1.3.0--hdfd78af_0"
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
    path(phage_contig) 

    path(pharokka_output_dir)

    
    output:
    path "pharokka_${pair_id}/plots/*"
    
    
    script:

    """   
    pharokka_plotter.py -i ${phage_contig} -n pharokka_${pair_id}/plots/${phage_contig} -o ${pharokka_output_dir} 
    """
    
}

process RESULTS_COMPILATION {
    errorStrategy= "ignore"
    
    publishDir "${params.outdir}/${pair_id}", mode: 'copy'

    input: 
    val (pair_id)
    path(viralcontigs)
    path(iphop_predictions_genus)
    path(phage_images) //needs to be list

    output:
    path "compiled_results.html"
    
    
    script:

    """   
    python3 nphantom_compilation.py compiled_results.html ${viralcontigs} ${iphop_predictions_genus} ${phage_images}
    """
    
}