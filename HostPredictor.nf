#!/usr/bin/env nextflow

process IPHOP {

    if (params.server) {
        beforeScript 'module load iphop/1.2.0'
        DB = "${params.DATABASEDIR}/iPHoP"
    }

    if (params.server) {
        afterScript 'module unload iphop/1.2.0'
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
    iphop predict --fa_file ${viral_contigs_fasta} --db_dir ${params.DATABASEDIR}/${params.iphopDB} --out_dir iphop_prediction
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