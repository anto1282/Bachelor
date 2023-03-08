process DVF {
    conda 'python=3.6 numpy theano=1.0.3 keras=2.2.4 scikit-learn Biopython h5py'
    publishDir "${params.outdir}/DVFResults", mode: 'copy'

    cpus 8


    input: 
    path(contigs) 


    output:
    path("*dvfpred.txt")
    
    script:
    """
    gzip --decompress --force ${contigs}
    python ${projectDir}/../DeepVirFinder/dvf.py -i contigs.fasta -l 500 -t ${task.cpus}
    """
}

process DVEXTRACT{
    publishDir "${params.outdir}/${pair_id}", mode: "copy"

    input:
    path predfile
    path contigs
    
    output:
    path "predicted_viruses.fasta"
    path "non_viral_assemblies.fasta"

    script:

    """ 
    python3 ${projectDir}/DeepVirExtractor.py ${predfile} ${contigs} ${params.cutoff}
    """

}
