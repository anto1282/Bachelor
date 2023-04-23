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
    tuple val (pair_id), path(viralcontigs) 

    
    output:
    path "pharokka_${pair_id}/*"
    
    
    script:

    """
    gzip -d -f ${viralcontigs}
    pharokka.py -i ${viralcontigs.baseName} -o pharokka_${pair_id} -f -t ${task.cpus} -d ${params.phaDB} -g prodigal -m
    gzip -f ${viralcontigs.baseName}
    """
    
}


process FASTASPLITTER {
    // publishDir "${params.outdir}/${pair_id}/ViralContigs", mode: 'copy'
    
    // Creates fasta files for each contig
    
    input:
    tuple val (pair_id), path(viralcontigs)

    output:
    val (pair_id)
    path("*.fasta")
    

    script:
    """
    gzip -d -f ${viralcontigs}
    cat ${viralcontigs.baseName} | awk '{
        if (substr(\$0, 1, 1)==">") {filename=(substr(\$1,2) ".fasta")}
        print \$0 >> filename
        close(filename)
    }'
    gzip -f ${viralcontigs.baseName}
    """
}



process PHAROKKA_PLOTTER {
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
    tuple val (pair_id), path(phage_contig) 

    path(pharokka_output_dir)

        
    script:

    """   
    pharokka_plotter.py -i ${phage_contig} -n results/${phage_contig.simpleName} -o ${pharokka_output_dir} -t ${phage_contig.simpleName}
    """
    
}

process RESULTS_COMPILATION {
    errorStrategy= "ignore"
    
    publishDir "${params.outdir}/${pair_id}", mode: 'copy'

    
    input:
            
    val(pair_id)
    path(viralcontigs)

    path(iphop_predictions)

    path(checkv_results)
    
    

    output:
    path "results/compiled_results.html"
    
    
    script:

    if (params.server) {
    """   
    python3 nphantom_compilation.py results/compiled_results.html ${viralcontigs} ${iphop_predictions}/Host_prediction_to_genus_m90.csv ${checkv_results}/completeness.tsv ${pair_id}
    """
    }
    else {
    """   
    python3 nphantom_compilation.py results/compiled_results.html ${viralcontigs} NOIPHOP ${checkv_results}/completeness.tsv ${pair_id}
    """
    }
}