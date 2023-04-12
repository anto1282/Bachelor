#!/usr/bin/env nextflow

process IPHOP {
    errorStrategy = 'ignore'
    // if (params.server) {
    //     beforeScript 'module load iphop/1.2.0'
    //     afterScript 'module unload iphop/1.2.0'
    // }

    if (params.server) {
        container = "quay.io/biocontainers/iphop:1.1.0--pyhdfd78af_2"
        }
    
    
    publishDir "${params.outdir}/${pair_id}/IPHOPPREDICTIONS", mode: 'copy'
    
    cpus 8
    memory '60 GB'

    input: 
    val (pair_id)
    path (viral_contigs_fasta)
    //path (non_viral_fasta)


    output:
    val (pair_id)
    path ("iphop_prediction_${pair_id}/*")
    
    
    // script:
    // if (params.server) {
    // """
    // gzip -d -f ${viral_contigs_fasta}
    // iphop predict --fa_file ${viral_contigs_fasta.baseName} --db_dir ${params.iphopDB} --out_dir iphop_prediction_${pair_id}
    // gzip -f ${viral_contigs_fasta.baseName}
    // """
    // }

    script:
    if (params.server) {
    """
    gzip -d -f ${viral_contigs_fasta}
    iphop predict --fa_file ${viral_contigs_fasta.baseName} --db_dir ${params.iphopDB} --out_dir iphop_prediction_${pair_id}
    gzip -f ${viral_contigs_fasta.baseName}
    """
    }
    
}   


process PHIST {

    errorStrategy = 'ignore'
    if (params.server) {
        cpus 8
    }
    else {
        cpus 4
    }

    publishDir "${params.outdir}/${pair_id}", mode: 'copy'

    
    input: 
    val (pair_id)
    val (viral_contigs_fasta)
    val (non_viral_fasta)


    output:
    val (pair_id)
    path ("phist_results_${pair_id}")


    script:
    """
    python3 ${projectDir}/PHIST/phist.py -t ${task.cpus} ${viral_contigs_fasta} ${non_viral_fasta} phist_results_${pair_id}
    """
}  


