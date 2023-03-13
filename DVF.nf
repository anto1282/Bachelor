process DVF {
    conda 'python=3.6 numpy theano=1.0.3 keras=2.2.4 scikit-learn Biopython h5py'
    publishDir "${params.outdir}/DVFResults", mode: 'copy'

    cpus 8

    input: 
    tuple val(N50score), path(contigs) 


    output:
    tuple path("*dvfpred.txt"), path(contigs)
    
    script:
    """
    gzip --decompress --force ${contigs} 
    python ${projectDir}/../DeepVirFinder/dvf.py -i ${contigs.baseName} -l 500 -c ${task.cpus}
    gzip --force ${contigs.baseName} 
    """
}

process DVEXTRACT{
    //publishDir "${params.outdir}/${pair_id}", mode: "copy"

    input:
    tuple path (predfile), path (contigs)
    
    output:
    path "predicted_viruses.fasta"
    path "non_viral_assemblies.fasta"

    script:

    """ 
    gzip --decompress --force ${contigs} 
    python3 ${projectDir}/DeepVirExtractor.py ${predfile} ${contigs.baseName} ${params.cutoff}
    gzip --force ${contigs.baseName} 
    """

}
