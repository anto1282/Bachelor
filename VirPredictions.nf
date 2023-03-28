
process DVF {
    if (params.server) {
        beforeScript 'module load gcc theano deepvirfinder'
        afterScript 'module unload gcc theano deepvirfinder/'
        cpus 8
        memory '16 GB'
        clusterOptions '--partition=gpuqueue'
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
        ${params.DVFPath} -i ${contigs.baseName} -l 1000 -c ${task.cpus}
        python3 ${projectDir}/DeepVirExtractor.py *dvfpred.txt ${contigs.baseName} ${params.cutoff}
        gzip --force ${contigs.baseName} 
        """
            }
    else {
        """
        gzip --decompress --force ${contigs} 
        python ${params.DVFPath} -i ${contigs.baseName} -l 1000 -c ${task.cpus}
        python3 ${projectDir}/DeepVirExtractor.py *dvfpred.txt ${contigs.baseName} ${params.cutoff}
        gzip --force ${contigs.baseName} 
        """
    }
    
}

process PHAGER {
    errorStrategy = 'ignore'
    //Tool for phage prediction from Thomas
    if (params.server) {
        conda '/maps/projects/mjolnir1/apps/conda/py39'

        beforeScript 'module load lightgbm/3.3.2-cpu'
        afterScript 'module unload lightgbm/3.3.2-cpu'
        
        cpus 8
        //clusterOptions '--partition=gpuqueue'
            }
    else {
        cpus 8
    }
    
    publishDir "${params.outdir}/${pair_id}/PHAGERResults", mode: 'copy'


    input: 
    tuple val(pair_id), path(contigs)


    output:
    val (pair_id)
    path "${pair_id}_phagerresults/phager_results.csv.gz"
    
    
    script:
    if (params.server) {
        """
        
        gzip --decompress --force ${contigs} 
        phager.py -c 1000 -a ${contigs.baseName} -d ${pair_id}_phagerresults -v
        gzip --force ${contigs.baseName} 
        
        """
            }
    
    
}

process VIRSORTER {
    if (params.server) {
        //conda "/projects/mjolnir1/apps/conda/virsorter-2.2.4"
        beforeScript 'module load virsorter snakemake screed'
        afterScript 'module unload virsorter snakemake screed'
        cpus 8
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
    path "predictions/final-viral-score.tsv"
    
    script:
    
    """
    gzip --decompress --force ${contigs} 
    virsorter run -i ${contigs.baseName} -w predictions --min-length 1000 -j ${task.cpus} --min-score 0.8 all --use-conda-off
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
    gzip 
    """

}



process DVF1 {
    if (params.server) {
        beforeScript 'module load deepvirfinder/2020.11.21'
        afterScript 'module unload deepvirfinder/2020.11.21'
        cpus 
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
        cpus 8
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
    path("${pair_id}_checkv/*.tsv")
    
    script:
    """
    
    checkv end_to_end ${viralcontigs} ${pair_id}_checkv -t ${task.cpus} -d ${params.checkVDB}
    
    """
}


process SEEKER{
    if (params.server) {
        beforeScript 'module load seeker bbmap'
        afterScript 'module unload seeker bbmap'
        cpus 8
            }
    else {
        beforeScript 'conda activate seeker'
        cpus 8
    }

    publishDir "${params.outdir}/${pair_id}/SEEKER", mode: 'copy'

    
    input:
    tuple val(pair_id), path(contigsFile)
    

    output:
    path("SeekerBacterials")
    path("SeekerPhages")


    script:
    """
    reformat.sh in=${contigsFile} out=Contigs_trimmed.fasta minlength=10000 overwrite=True
    predict-metagenome Contigs_trimmed.fasta > SeekerFile
    python ${projectDir}/SeekerSplitter.py SeekerFile Contigs_trimmed.fasta
    rm SeekerFile
    rm Contigs_trimmed.fasta
    """

}