#!/usr/bin/env nextflow


process DEEPHOST {
    
    publishDir "${params.outdir}/${pair_id}", mode: 'copy'

    //cpus 8
    input: 
    val (pair_id)
    path (viral_contigs_fasta)
    path (non_viral_fasta)


    output:
    val (pair_id)
    path (predictions)
    

    script:
    """
    cd ${projectDir}/../DeepHost/DeepHost_scripts
    python DeepHost.py ${workDir}/${viral_contigs_fasta} --out ${pair_id}_host_predictions.txt --rank species --thread 8
    mv ${pair_id}_host_predictions.txt ${workDir}/${pair_id}_host_predictions.txt
    """
}   


process IPHOP {
    conda "iphop"
    publishDir "${params.outdir}/${pair_id}", mode: 'copy'
    


    //cpus 8
    input: 
    val (pair_id)
    path (viral_contigs_fasta)
    path (non_viral_fasta)


    output:
    val (pair_id)
    path (predictions)
    

    script:
    """
    iphop 
    """
}   