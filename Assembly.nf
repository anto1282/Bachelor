#!/usr/bin/env nextflow


process SPADES {
    if (params.server) {
        beforeScript 'module load spades/3.15.5'
        cpus 16
        memory '16 GB'
    }
    else {
        conda "spades=3.15.4 conda-forge::openmp"
        cpus 8
        memory '4 GB'
    }
    if (params.server) {
        afterScript 'module unload spades'
    }
    
    publishDir "${params.outdir}/${pair_id}/Assembly", mode: 'copy'

    
    input: 
    val(pair_id)
    path(r1)
    path(r2)

    val phred

    output:
    tuple val(pair_id), path ("contigs.fasta.gz")

    
    script:
    """
    gzip -d -f ${r1}
    gzip -d -f ${r2}
    spades.py -o Assembly${pair_id} -1 ${r1.baseName} -2 ${r2.baseName} --meta --threads ${task.cpus} --memory ${task.cpus} --phred-offset ${phred} 
    gzip -n Assembly${pair_id}/contigs.fasta   
    mv Assembly${pair_id}/contigs.fasta.gz contigs.fasta.gz
    gzip ${r1.baseName}
    gzip ${r2.baseName}
    """
}



process OFFSETDETECTOR {
    cpus 1
    input:
    val(pair_id)
    path(r1)
    path(r2)

    output:
    stdout

    script:
    
    """
    gzip -d ${r1} -f
    gzip -d ${r2} -f
    python3 ${projectDir}/offsetdetector.py ${r1.baseName} ${r2.baseName}
    gzip ${r1.baseName}
    gzip ${r2.baseName}
    """
}


process N50 {
    if (params.server) {
        beforeScript 'module load bbmap'
        cpus 4
        memory '16 GB'
    }
    else {
        conda "agbiome::bbtools"
        cpus 4
        memory '4 GB'
    }
    

    input: 
    tuple val (pair_id), path(contigs_fasta)
    


    output:
    tuple stdout, path (contigs_fasta), val (pair_id)
    

    script:
    """
    gzip -d ${contigs_fasta}
    stats.sh in=${contigs_fasta.baseName} | grep 'Main genome scaffold N/L50:' | cut -d: -f2 | cut -d/ -f1 | xargs
    gzip ${contigs_fasta.baseName}
    """

}




//DEPRECATED FUNCTIONS
process SPADES1 {
    conda "spades=3.15.4 conda-forge::openmp seqkit"
    publishDir "${params.outdir}/${pair_id}/Assembly", mode: 'copy'

    cpus 4
    input: 
    val (pair_id)
    val sampleseed
    path(r1)
    path(r2)
    
    val phred

    output:
    val (pair_id)
    path ("n50_${sampleseed}_contigs.fasta.gz")


    script:
    """
    spades.py -o assembly${r1.baseName} -1 ${r1} -2 ${r2} --meta --phred-offset ${phred}
    gzip -n assembly${r1.baseName}/contigs.fasta
    mv assembly${r1.baseName}/contigs.fasta.gz n50_${sampleseed}_contigs.fasta.gz

    """
}

process COVERAGE {
    conda 'agbiome::bbtools'
    
    input:
    val pair_id
    path(contigs_fasta)
    path(r1)
    path(r2)
    

    output:
    stdout
    

    script:
    """
    python3 ${projectDir}/CoverageFinder.py ${r1} ${r2} ${contigs_fasta}
    """
}


