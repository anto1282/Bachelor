#!/usr/bin/env nextflow


// TODO TJEK OM FIL ER TILSTEDE FØR VI LAVER FASTERQDUMP
process FASTERQDUMP {
    if (params.server) {
        beforeScript 'module load sra-tools'
        afterScript 'module unload sra-tools'
    }
    else {
        conda 'sra-tools'
    }
    
    memory '1 GB'
    
    publishDir "${params.outdir}/${sra_nr}/reads"

    input: 
    val sra_nr
    
    output:
    tuple val (sra_nr), path ("${sra_nr}_*.fastq")
    

    script:
    """
    fasterq-dump ${sra_nr} --split-files
    gzip ${sra_nr}_*.fastq
    """
}

process TRIM {
    
    if (params.server) {
        beforeScript 'module load adapterremoval bbmap'
        afterScript 'module unload adapterremoval bbmap'
    }
    else {
        conda 'adapterremoval agbiome::bbtools'
    }
     

    cpus 4

    input: 
    tuple val(pair_id), path(reads) 


    output:
    val(pair_id)
    path("${r1}_trimmed.fastq")
    path("${r2}_trimmed.fastq")

    
    script:
    def (r1, r2) = reads

   
    
    """
    AdapterRemoval --file1 ${r1}  --file2 ${r2} --output1 read1_tmp --output2 read2_tmp 
    bbduk.sh -in=read1_tmp -in2=read2_tmp -out=${r1}_trimmed.fastq -out2=${r2}_trimmed.fastq trimq=25 qtrim=r forcetrimleft=15 overwrite=true ordered=t
    gzip ${r1}_trimmed.fastq
    gzip ${r2}_trimmed.fastq
    rm read?_tmp
    """
}

process KRAKEN{

    if (params.server) {
        beforeScript 'module load kraken2/2.1.2'
        afterScript 'module unload kraken2/2.1.2'
        memory '50 GB'
        cpus 8
    }
    else {
        conda "kraken2"
        memory "6 GB"
        cpus 4
    }
    

    input:
    tuple val(pair_id), path(reads)
    

    output:
    tuple val(pair_id), path(trimmed_reads)

    script:

    def (r1, r2) = reads

    trimmed_reads = reads.collect{
      "${it.baseName}SubNoEu.fastq"
    }

    """
    kraken2 --preload -d ${params.DATABASEDIR}/${params.krakDB} --report report.kraken.txt --paired ${r1} ${r2} --output read.kraken --threads ${task.cpus}
    python3 ${projectDir}/TaxRemover.py ${r1} ${r2} ${pair_id} report.kraken.txt read.kraken ${projectDir}/Results
    """
}

process TAXREMOVE{

    cpus 1
    memory '500 MB'

    input:
    tuple val(pair_id), path(reads)
    path readkraken
    path reportkraken

    output:
    
    tuple val(pair_id), path(trimmed_reads)

    script:

    def (r1, r2) = reads

    trimmed_reads = reads.collect{
      "${it.baseName}SubNoEu.fastq"
    }

    """ 
    python3 ${projectDir}/TaxRemover.py ${r1} ${r2} ${pair_id} ${reportkraken} ${readkraken} ${projectDir}/Results
    """

}
