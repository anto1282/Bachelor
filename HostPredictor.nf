#!/usr/bin/env nextflow

process IPHOP {
    
    if (params.server) {
        beforeScript 'module purge'
        conda '/projects/mjolnir1/apps/conda/iphop-1.2.0'
    }
   
    publishDir "${params.outdir}/${pair_id}", mode: 'copy'
    
    cpus 16
    memory '30 GB'
    time = 1.h

    input: 
    tuple val(pair_id), path(viral_contigs_fasta)
   
    output:
    path ("IphopPrediction/")

    
    script:
    if (params.server) {
    """
    export PERL5LIB=\$PERL5LIB:/opt/software/miniconda/4.10.4/pkgs/smrtlink-tools-10.1.0.119588-h5e1937b_0/share/smrtlink-tools-10.1.0.119588-0/install/smrtlink-release_10.1.0.119588/bundles/smrttools/install/smrttools-release_10.1.0.119588/private/thirdparty/gcc/gcc_8.4.0-2.12.1/lib/
    export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/opt/software/miniconda/4.10.4/pkgs/smrtlink-tools-10.1.0.119588-h5e1937b_0/share/smrtlink-tools-10.1.0.119588-0/install/smrtlink-release_10.1.0.119588/bundles/smrttools/install/smrttools-release_10.1.0.119588/private/thirdparty/gcc/gcc_8.4.0-2.12.1/lib/
    

    env
    which python3
    which perl
    echo \$PERL5LIB
    
    
    iphop predict --fa_file ${viral_contigs_fasta} --db_dir ${params.iphopDB} --out_dir IphopPrediction/ --num_threads ${task.cpus}
    
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


