    process DVF {
    if (params.server) {
        beforeScript 'module load deepvirfinder'
        afterScript 'module unload deepvirfinder'
        RunDVF = "dvf.py"
    }
    else {
        RunDVF= "${projectDir}/../DeepVirFinder/dvf.py"
        conda 'python=3.6 numpy theano=1.0.3 keras=2.2.4 scikit-learn Biopython h5py'
    
    }
    
    publishDir "${params.outdir}/${pair_id}/DVFResults", mode: 'copy'

    cpus 10

    input: 
    tuple val(pair_id), path(contigs)


    output:
    val(pair_id)
    tuple path("*dvfpred.txt"), path(contigs)
    
    script:
    """
    gzip --decompress --force ${contigs} 
    python ${RunDVF} -i ${contigs.baseName} -l 500 -c ${task.cpus}
    gzip --force ${contigs.baseName} 
    """
}

process DVEXTRACT{
    publishDir "${params.outdir}/${pair_id}/DVFResults", mode: "copy"

    input:
    val (pair_id)
    tuple path (predfile), path (contigs)
    
    output:
    val (pair_id)
    path "predicted_viruses.fasta"
    path "non_viral_assemblies.fasta"

    script:

    """ 
    gzip --decompress --force ${contigs} 
    python3 ${projectDir}/DeepVirExtractor.py ${predfile} ${contigs.baseName} ${params.cutoff}
    gzip --force ${contigs.baseName} 
    """

}

