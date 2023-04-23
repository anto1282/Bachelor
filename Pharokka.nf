#!/usr/bin/env nextflow


process PHAROKKA {
    errorStrategy= "finish"
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
    path "pharokka_${pair_id}/"
    
    
    script:

    """
    
    pharokka.py -i ${viralcontigs} -o pharokka_${pair_id} -f -t ${task.cpus} -d ${params.phaDB} -g prodigal -m
    
    """
    
}


process FASTASPLITTER {
    // publishDir "${params.outdir}/${pair_id}/ViralContigs", mode: 'copy'
    
    // Creates fasta files for each contig
    
    input:
    tuple val(pair_id), path(viralcontigs)

    output:
    //tuple val(pair_id), path("*.fasta")
    path("*.fasta")

    script:

    //Reads a fasta file and saves each sequence to a separate output file.
    //The output file name is the same as the sequence header with a .fasta extension.
    
    """
    python3 ${projectDir}/fastasplitter.py ${viralcontigs}
    """
}



process PHAROKKA_PLOTTER {
    errorStrategy= "finish"
    if (params.server){
        container = "docker://quay.io/biocontainers/pharokka:1.3.0--hdfd78af_0"
        cpus 8
    }
    else{
        conda 'pharokka'
        cpus 8
    }
    
    publishDir "${params.outdir}/${pair_id}/results", mode: 'copy'

    input: 
    //tuple val(pair_id), path (phage_contig) 
    path(phage_contig)
    path(pharokka_output_dir)

    output:
    path("${phage_contig.baseName}.png")
    
    script:

    """   
    pharokka_plotter.py -i ${phage_contig} -n ${phage_contig.baseName} -o ${pharokka_output_dir} -t ${phage_contig.baseName}
    rm ${phage_contig}
    """
    
}

process RESULTS_COMPILATION {
    
    
    publishDir "${params.outdir}/${pair_id}/results", mode: 'copy'

    
    input:
            
    tuple val(pair_id), path(viralcontigs)

    path(iphop_predictions)

    path(checkv_results)
    
    

    output:
    path "compiled_results.html"
    
    
    script:

    if (params.server) {
    """   
    python3 ${projectDir}/nphantom_compilation.py compiled_results.html ${viralcontigs} ${iphop_predictions}/Host_prediction_to_genus_m90.csv ${checkv_results}/completeness.tsv ${projectDir}/${params.outdir}/${pair_id}/assemblyStats ${pair_id}
    """
    }
    else {
    """   
    python3 ${projectDir}/nphantom_compilation.py compiled_results.html ${viralcontigs} NOIPHOP ${checkv_results}/completeness.tsv ${projectDir}/${params.outdir}/${pair_id}/assemblyStats ${pair_id}
    """
    }
}