#!/usr/bin/env nextflow


process DEEPHOST {
    //conda "spades=3.15.4 conda-forge::openmp seqkit"
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
    python ${projectDir}../DeepHost/DeepHost_scripts/DeepHost.py ${viral_contigs_fasta} --out ${pair_id}_host_predictions.txt --rank species --thread 8
    """
}   