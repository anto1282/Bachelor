#!/usr/bin/env nextflow

process IPHOP {
    
    if (params.server) {
        beforeScript 'module purge; export LD_LIBRARY_PATH=/projects/mjolnir1/apps/conda/iphop-1.2.0/x86_64-conda-linux-gnu/lib/:/projects/mjolnir1/apps/conda/iphop-1.2.0/lib/:'
        conda '/projects/mjolnir1/apps/conda/iphop-1.2.0'
    }
   
    publishDir "${params.outdir}/${pair_id}/IPHOPPREDICTIONS", mode: 'copy'
    
    cpus 8
    memory '30 GB'
    time = 1.h

    input: 
    val (pair_id)
    path (viral_contigs_fasta)
   
    output:
    val (pair_id)
    path ("iphop_prediction_${pair_id}/*")
    
    
    script:
    if (params.server) {
    """
    
    
    env
    which python3
    which perl
    echo \$PERL5LIB
    
    gzip -d -f ${viral_contigs_fasta}
    iphop predict --fa_file ${viral_contigs_fasta.baseName} --db_dir ${params.iphopDB} --out_dir iphop_prediction_${pair_id} --num_threads ${task.cpus}
    gzip -f ${viral_contigs_fasta.baseName}
    """
    }

   
    
}   

// not working atm

process HOSTPHINDER {

    errorStrategy = 'ignore'
    if (params.server) {
        container = "julvi/hostphinder"
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
    script:
    if (params.server) {
    """
    gzip -d -f ${viral_contigs_fasta}
    hostphinder --fa_file ${viral_contigs_fasta.baseName} --db_dir ${params.iphopDB} --out_dir iphop_prediction_${pair_id}
    gzip -f ${viral_contigs_fasta.baseName}
    """
    }
    
}  


