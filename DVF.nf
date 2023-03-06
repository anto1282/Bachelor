process DVF {
    conda 'python=3.6 numpy theano=1.0.3 keras=2.2.4 scikit-learn Biopython h5py'
    publishDir "${params.outdir}/${pair_id}/DVFResults", mode: 'copy'

    cpus 4

    input: 
    path(contigs) 


    output:
    path("*dvfpred.txt")
    
    script:
    """
    gunzip ${contigs} > contigs.tmp
    python ${params.DVF} -i contigs.tmp -l 500
    """
}