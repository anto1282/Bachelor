process DVF {
    conda 'python=3.6 numpy theano=1.0.3 keras=2.2.4 scikit-learn Biopython h5py'
    publishDir "${params.outdir}/${pair_id}/DVFResults", mode: 'copy'

    cpus 6


    input: 
    path(contigs) 


    output:
    path("*dvfpred.txt")
    
    script:
    """
    gunzip ${contigs} > contigs.tmp
    python ${params.DVF}/dvf.py -i contigs.tmp -l 500
    """
}

process DVEXTRACT{
    publishDir "${params.outdir}/${pair_id}", mode: "copy"
    cpus 7
    memory "3 GB"

    input:
    path predfile
    path contigs
    
    output:
    path "predicted_viruses.fasta"
    path "non_viral_assemblies.fasta"

    script:

    """ 
    python3 ${projectDir}/TaxRemover.py ${r1} ${r2} ${pair_id} ${reportkraken} ${readkraken} ${projectDir}/Results
    """

}
