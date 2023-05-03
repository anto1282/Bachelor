#!/usr/bin/env nextflow


process FASTERQDUMP {
    if (params.server) {
        beforeScript 'module load sra-tools'
        afterScript 'module unload sra-tools'
    }
    else {
        conda 'sra-tools'
    }
    label 'shortTask'
    
    
    publishDir "${params.outdir}/${pair_id}/Reads"

    input: 
    val pair_id
    
    output:
    tuple(val(pair_id), path("${pair_id}_{1,2}.fastq.gz"))

    

    script:
    """
    prefetch ${pair_id}
    fasterq-dump ${pair_id} --split-files
    gzip ${pair_id}_1.fastq
    gzip ${pair_id}_2.fastq
    """
}

process TRIM {
    
    if (params.server) {
        beforeScript 'module load perl adapterremoval fastqc fastp'
        afterScript 'module unload perl adapterremoval fastqc fastp'
    }
    else {
        conda 'adapterremoval fastqc fastp'
    }
     
    cpus 4

    input: 
    tuple(val(pair_id), path(reads))
   


    output:
    val(pair_id)
    path("${reads[0].simpleName}_trimmed.fastq.gz")
    path("${reads[1].simpleName}_trimmed.fastq.gz")

    
    script:
   
   
    """
    AdapterRemoval --file1 ${reads[0]}  --file2 ${reads[1]} --collapse --output1 read1_tmp --output2 read2_tmp --adapter-list ${projectDir}/Adapters.txt --threads 4
    fastp -i read1_tmp -I read2_tmp -o ${reads[0].simpleName}_trimmed.fastq  -O ${reads[1].simpleName}_trimmed.fastq -W 5 -M 30 -e 25 -f 15 -w 4
    
    mkdir -p ${projectDir}/${params.outdir}/${pair_id}/CompiledResults/
    mv fastp.html ${projectDir}/${params.outdir}/${pair_id}/CompiledResults/fastp.html
    
    gzip ${reads[0].simpleName}_trimmed.fastq
    gzip ${reads[1].simpleName}_trimmed.fastq
    rm read?_tmp
    """
    
}

process KRAKEN{

    if (params.server) {
        beforeScript 'module load openmpi kraken2'
        afterScript 'module unload kraken2 openmpi'
        if (params.bigDB){
            memory {520.GB}
        }
        else{
            memory {61.GB * task.attempt}
        }
        cpus 3
        errorStrategy { task.exitStatus in 137..140 ? 'retry' : 'terminate' }
        maxRetries 3

    }
    else {
        conda "kraken2"
        memory "6 GB"
        cpus 2
    }

    input:
    val(pair_id)
    path (r1)
    path (r2)
    

    output:
    val(pair_id)
    path("${pair_id}_1.TrimmedNoEu.fastq.gz")
    path("${pair_id}_2.TrimmedNoEu.fastq.gz")
    
    script:
    if (params.server) {
        """
        mkdir -p ${projectDir}/${params.outdir}/${pair_id}/KrakenResults
        gzip -d -f ${r1}
        gzip -d -f ${r2}
        mkdir -p ${projectDir}/${params.outdir}/${pair_id}/Assembly
        kraken2 -d ${params.krakDB} --report report.kraken.txt --paired ${r1.baseName} ${r2.baseName} --output read.kraken --threads ${task.cpus}
        python3 ${projectDir}/TaxRemover.py ${r1.baseName} ${r2.baseName} ${pair_id} report.kraken.txt read.kraken > ${projectDir}/${params.outdir}/${pair_id}/Assembly/assemblyStats.txt
        mv report.kraken.txt ${projectDir}/${params.outdir}/${pair_id}/KrakenResults
        mv read.kraken ${projectDir}/${params.outdir}/${pair_id}/KrakenResults


        rm ${r1.baseName}
        rm ${r2.baseName} 
        gzip ${pair_id}_1.TrimmedNoEu.fastq
        gzip ${pair_id}_2.TrimmedNoEu.fastq
        """
    }
    else {
        """
        gzip -d -f ${r1}
        gzip -d -f ${r2}
        mkdir -p ${projectDir}/${params.outdir}/${pair_id}/Assembly
        kraken2 -d ${params.krakDB} --report report.kraken.txt --paired ${r1.baseName} ${r2.baseName} --output read.kraken --threads ${task.cpus}
        python3 ${projectDir}/TaxRemover.py ${r1.baseName} ${r2.baseName} ${pair_id} report.kraken.txt read.kraken > ${projectDir}/${params.outdir}/${pair_id}/Assembly/assemblyStats.txt
        rm ${r1.baseName}
        rm ${r2.baseName} 
        gzip ${pair_id}_1.TrimmedSubNoEu.fastq
        gzip ${pair_id}_2.TrimmedSubNoEu.fastq
        """
    }
}

process TAXREMOVE{
3
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
    python3 ${projectDir}/TaxRemover.py ${r1} ${r2} ${pair_id} ${reportkraken} ${readkraken} ${projectDir}/CompiledResults
    """

}


process FASTQC{

    if (params.server) {
        beforeScript 'module load perl fastqc'
        afterScript 'module unload perl fastqc'
    }
    else {
        conda "fastqc"
    }
    
    publishDir "${params.outdir}/${pair_id}/CompiledResults"
    input:
    val(pair_id)
    path (r1)
    path (r2)

    output:
    path("*.html")
    script:    
    """ 
    fastqc ${r1} ${r2}
    """

}