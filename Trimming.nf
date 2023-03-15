#!/usr/bin/env nextflow


// TODO TJEK OM FIL ER TILSTEDE FØR VI LAVER FASTERQDUMP
process FASTERQDUMP {
    if (params.server) {
        beforeScript 'module load sra-tools/3.0.0'
        afterScript 'module unload sra-tools/3.0.0'
    }
    else {
        conda 'sra-tools'
    }
    
    publishDir "${params.outdir}/${sra_nr}/reads"

    input: 
    val sra_nr
    
    output:
    tuple val (sra_nr), path ("${sra_nr}_*.fastq")
    

    script:
    """
    fasterq-dump ${sra_nr} --split-files
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
    tuple val(pair_id), path(trimmed_reads)
    
    script:
    def (r1, r2) = reads

   
    trimmed_reads = reads.collect{
      "${it.baseName}.Trimmed.fastq"
    }
    """
    AdapterRemoval --file1 ${r1}  --file2 ${r2} --output1 read1_tmp --output2 read2_tmp 
    bbduk.sh -in=read1_tmp -in2=read2_tmp -out=${trimmed_reads[0]} -out2=${trimmed_reads[1]} trimq=25 qtrim=r forcetrimleft=15 overwrite=true ordered=t
    """
}

process KRAKEN{

    if (params.server) {
        beforeScript 'module load kraken2'
        afterScript 'module unload kraken2'
        memory '70 GB'
    }
    else {
        conda "kraken2"
        memory "6 GB"
    }

    DB = params.krakDB
    cpus 4
    

    input:
    tuple val(pair_id), path(reads)
    path DB

    output:
    path "read.kraken"
    path "report.kraken.txt"


    script:
    def (r1, r2) = reads

    """
    kraken2 -d ${params.DATABASEDIR}${DB} --memory-mapping --report report.kraken.txt --paired ${r1} ${r2} --output read.kraken
    """
}

process TAXREMOVE{

    cpus 1

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
