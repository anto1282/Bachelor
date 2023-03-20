#!/usr/bin/env nextflow

process IPHOP {
    errorStrategy = 'ignore'
    if (params.server) {
        beforeScript 'module load iphop/1.2.0'
        DB = "${params.DATABASEDIR}/iPHoP"
    }

    if (params.server) {
        afterScript 'module unload iphop/1.2.0'
    }
        
    publishDir "${params.outdir}/${pair_id}/IPHOPPREDICTIONS", mode: 'copy'
    
    cpus 8

    input: 
    val (pair_id)
    path (viral_contigs_fasta)
    path (non_viral_fasta)


    output:
    val (pair_id)
    //path (predictions)
    

    script:
    """
    iphop predict --fa_file ${viral_contigs_fasta} --db_dir ${params.iphopDB} --out_dir iphop_prediction_${pair_id}
    """

    
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
    path (non_viral_fasta)


    output:
    val (pair_id)
    path ("phist_results_${pair_id}")


    script:
    """
    python3 ${projectDir}/../PHIST/phist.py -t ${task.cpus} ${viral_contigs_fasta} ${non_viral_fasta} phist_results_${pair_id}
    """
}  




//Deprecated module:

process DEEPHOST {
    

    publishDir "${params.outdir}/${pair_id}", mode: 'copy'

    //cpus 8
    input: 
    val (pair_id)
    val (viral_contigs_fasta)
    path (non_viral_fasta)


    output:
    val (pair_id)
    //path (predictions)
    path ("${pair_id}_host_predictions.txt")


    script:
    """
    cd ${projectDir}/../DeepHost/DeepHost_scripts
    python DeepHost.py ${viral_contigs_fasta} --out ${pair_id}_host_predictions.txt --rank species --thread 8
    
    """
}   