#!/usr/bin/env nextflow

process IPHOP {

    if (params.server) {
        beforeScript 'module load iphop'
        DB = "${params.DATABASEDIR}/iPHoP"
    }
        
    publishDir "${params.outdir}/${pair_id}", mode: 'copy'
    
    cpus 8

    input: 
    val (pair_id)
    path (viral_contigs_fasta)
    path (non_viral_fasta)


    output:
    val (pair_id)
    path (predictions)
    

    script:
    """
    iphop predict --fa_file ${viral_contigs_fasta} --db_dir ${params.iphopDB} --out_dir iphop_prediction
    """

    if (params.server) {
        afterScript 'module unload iphop'
    }
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