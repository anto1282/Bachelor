
process DVF {
    if (params.server) {
        beforeScript 'module load deepvirfinder theano'
        afterScript 'module unload deepvirfinder theano'
        cpus 16
        memory '16 GB'
            }
    else {
        conda 'python=3.6 numpy theano=1.0.3 keras=2.2.4 scikit-learn Biopython h5py'
        cpus 8
    }
    
    publishDir "${params.outdir}/${pair_id}/DVFResults", mode: 'copy'


    input: 
    tuple val(pair_id), path(contigs)


    output:
    val (pair_id)
    path "predicted_viruses.fasta"
    path "non_viral_assemblies.fasta"
    
    script:
    if (params.server) {
        """
        gzip --decompress --force ${contigs} 
        ${params.DVFPath} -i ${contigs.baseName} -l 500 -c ${task.cpus}
        python3 ${projectDir}/DeepVirExtractor.py *dvfpred.txt ${contigs.baseName} ${params.cutoff}
        gzip --force ${contigs.baseName} 
        """
            }
    else {
        """
        gzip --decompress --force ${contigs} 
        python ${params.DVFPath} -i ${contigs.baseName} -l 500 -c ${task.cpus}
        python3 ${projectDir}/DeepVirExtractor.py *dvfpred.txt ${contigs.baseName} ${params.cutoff}
        gzip --force ${contigs.baseName} 
        """
    }
    
}


process VIRSORTER {
    if (params.server) {
        beforeScript 'module load virsorter/2.2.3'
        afterScript 'module unload virsorter/2.2.3'
        cpus 16
        memory '32 GB'
        }
    else {
        cpus 8
    }
    
    publishDir "${params.outdir}/${pair_id}/VIRSORTER", mode: 'copy'
    

    input: 
    tuple val(pair_id), path(contigs)


    output:
    val (pair_id)
    path "predictions/final-viral-combined.fa"
    path "predictions/final-vira-score.tsv"
    
    script:
    
    """
    gzip --decompress --force ${contigs} 
    virsorter run -i ${contigs.baseName} -w predictions --min-length 1000 -j ${task.cpus}
    gzip --force ${contigs.baseName} 
    """
    
    
}





// NOT IN USE ANYMORE, SAVE FOR NOW
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



process DVF1 {
    if (params.server) {
        beforeScript 'module load deepvirfinder/2020.11.21'
        afterScript 'module unload deepvirfinder/2020.11.21'
        cpus 16
            }
    else {
        conda 'python=3.6 numpy theano=1.0.3 keras=2.2.4 scikit-learn Biopython h5py'
        cpus 8
    }
    
    publishDir "${params.outdir}/${pair_id}/DVFResults", mode: 'copy'

    

    input: 
    tuple val(pair_id), path(contigs)


    output:
    val(pair_id)
    tuple path("*dvfpred.txt"), path(contigs)
    
    script:
    """
    gzip --decompress --force ${contigs} 
    python ${params.DVFPath} -i ${contigs.baseName} -l 500 -c ${task.cpus}
    gzip --force ${contigs.baseName} 
    """
}


process CHECKV {
    if (params.server) {
        beforeScript 'module load checkv'
        afterScript 'module unload checkv'
        cpus 16
            }
    else {
        conda 'checkv'
        cpus 8
    }
    
    publishDir "${params.outdir}/${pair_id}/CHECKVResults", mode: 'copy'

    

    input: 
    val(pair_id)
    path(viralcontigs)
    path(non_viral_contigs)

    output:
    "*.tsv"
    
    script:
    """
    gzip --decompress --force ${viralcontigs} 
    checkv end_to_end ${viralcontigs.baseName} -t ${task.cpus} -d ${params.checkVDB}
    gzip --force ${viralcontigs.baseName} 
    """
}


process SEEKER{
    if (params.server) {
        beforeScript 'module load seeker'
        afterScript 'module unload seeker'
        cpus 16
            }
    else {
        beforeScript 'conda create -n seeker '
        cpus 8
    }

    
    input:
    val(pair_id)
    path(contigsFile)

    output:
    path("SeekerBacterials")
    path("SeekerPhages")


    script
    """
    reformat.sh in=${contigsFile} out=Contigs_trimmed minlength=1000 overwrite=True
    predict-metagenome Contigs_trimmed > SeekerFile
    python SeekerSplitter.py 
    rm SeekerFile
    rm Contigs_trimmed
    """

}