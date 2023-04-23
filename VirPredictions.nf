
process DVF {
    
    if (params.server) {
        beforeScript 'module load gcc theano deepvirfinder'
        afterScript 'module unload gcc theano deepvirfinder/'
        cpus 8
        memory '16 GB'
        //clusterOptions '--partition=gpuqueue'
            }
    else {
        conda 'python=3.6 numpy theano=1.0.3 keras=2.2.4 scikit-learn Biopython h5py'
        cpus 8
    }
    
    publishDir "${params.outdir}/${pair_id}/DVFResults", mode: 'copy'


    input: 
    tuple val(pair_id), path(contigs)


    output:
    tuple val(pair_id), path("*dvfpred.txt")
    
    script:
    if (params.server) {
        """
        gzip --decompress --force ${contigs} 
        ${params.DVFPath} -i ${contigs.baseName} -l ${params.minLength} -c ${task.cpus}
        gzip --force ${contigs.baseName} 
        """
            }
    else {
        """
        gzip --decompress --force ${contigs} 
        python ${params.DVFPath} -i ${contigs.baseName} -l ${params.minLength} -c ${task.cpus}
        gzip --force ${contigs.baseName} 
        """
    }
    
}

process PHAGER {
    
    //errorStrategy = 'ignore'
    //Tool for phage prediction from Thomas
    if (params.server) {
        beforeScript "module unload miniconda/4.11.0"
        conda '/projects/mjolnir1/apps/conda/py39'
        module 'python/3.9.9'
        cpus 8
            }
    else {
        cpus 8
    }
    
    publishDir "${params.outdir}/${pair_id}/PHAGERResults", mode: 'copy'


    input: 
    tuple val(pair_id), path(contigs)


    output:
    tuple val (pair_id), path ("${pair_id}_phagerresults/${contigs.simpleName}.phager_results.csv.gz")
    
    
    
    script:
    if (params.server) {
        """
        echo $PATH
        gzip --decompress --force ${contigs} 
        phager.py -c ${params.minLength} -a ${contigs.baseName} -d ${pair_id}_phagerresults -v
        gzip --force ${contigs.baseName}
        """
        }
    
    
}

process VIRSORTER {
    errorStrategy = 'ignore'
    // if (params.server) {
    //     //conda "pandas"
    //     module "virsorter/2.2.4"
    //     //beforeScript 'python3 --version ;echo $PATH ;module load numpy/1.21.2 snakemake; module load screed; module load click ; module load virsorter; echo $PATH;python --version;export PYTHONPATH=$PATH:$PYTHONPATH; echo $PYTHONPATH'
    //     //  afterScript 'module unload snakemake screed click virsorter'
    //     cpus 8
    //     memory '16 GB'
    //     }
    // else {
    //     cpus 8
    // }

    if (params.server){
        container = "jiarong/virsorter:latest"
        cpus 8
        memory '16 GB'
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
    virsorter run -i ${contigs.baseName} -w predictions --min-length ${params.minLength} -j ${task.cpus} -d ${params.virsorterDB} --min-score 0.8 all --forceall
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
        conda 'checkv=1.0.1'
        cpus 8
    }
    
    publishDir "${params.outdir}/${pair_id}/", mode: 'copy'

    

    input: 
    tuple val(pair_id), path(viralcontigs)

    output:
    
    path("CHECKV_RESULTS_${pair_id}/")
    
    script:
    """
    
    checkv end_to_end ${viralcontigs} CHECKV_RESULTS_${pair_id} -t ${task.cpus} -d ${params.checkVDB}
    
    """
}


process SEEKER{
    
    if (params.server) {
        beforeScript 'module load seeker bbmap'
        afterScript 'module unload seeker bbmap'
        cpus 8
            }
    else {
        conda 'seeker python=3.7 pip'
        cpus 8
    }

    publishDir "${params.outdir}/${pair_id}/SEEKER", mode: 'copy'

    
    input:
    tuple val(pair_id), path(contigsFile)
    

    output:
    tuple val(pair_id), path("SeekerFile")


    script:
    """
    reformat.sh in=${contigsFile} out=Contigs_trimmed.fasta minlength=${params.minLength} overwrite=True
    predict-metagenome Contigs_trimmed.fasta > SeekerFile
    rm Contigs_trimmed.fasta
    """

}

process VIREXTRACTOR {
    publishDir "${params.outdir}/${pair_id}/ViralContigs", mode: 'copy'

    
    input:
    tuple val(pair_id), path(contigsFile)
    tuple val(pair_id), path(DVFcontigs)
    tuple val(pair_id), path(SeekerContigs)
    tuple val(pair_id), path(PhagerContigs)

    output:
    tuple val(pair_id), path("${pair_id}_ViralContigs.fasta")
    


    script:
    """
    gzip -d -f ${contigsFile}
    gzip -d -f ${PhagerContigs}
    python3 ${projectDir}/virextractor.py ${contigsFile.baseName} ${pair_id}_ViralContigs.fasta 0.94 ${DVFcontigs} 0.82 ${SeekerContigs} ${PhagerContigs.baseName}
    gzip -f ${contigsFile.baseName}
    gzip -f ${PhagerContigs.baseName}
    
    """
}
