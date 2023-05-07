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
        beforeScript 'module load adapterremoval fastp'
        afterScript 'module unload adapterremoval fastp'
    }
    else {
        conda 'adapterremoval fastqc fastp'
    }
    
    if (skipTrim == false)
    {   cpus 4
        memory 4.GB
        time = 20.m}
    else
    {   cpus 1
        memory 1.GB
        time = 20.s}
    input: 
    tuple(val(pair_id), path(reads))
   


    output:
    val(pair_id)
    path("${pair_id}_1_trimmed.fastq.gz")
    path("${pair_id}_2_trimmed.fastq.gz")

    
    script:
   
    if (params.skipTrim == false){
    """
    AdapterRemoval --file1 ${reads[0]}  --file2 ${reads[1]} --collapse --output1 read1_tmp --output2 read2_tmp --adapter-list ${projectDir}/Adapters.txt --threads ${task.cpus}
    fastp -i read1_tmp -I read2_tmp -o ${pair_id}_1_trimmed.fastq  -O ${pair_id}_2_trimmed.fastq -W 5 -M 30 -e 25 -f 15 -w ${task.cpus} --cut_tail --cut_tail_window_size 1 -c
    
    mkdir -p ${projectDir}/${params.outdir}/${pair_id}/CompiledResults/
    mv fastp.html ${projectDir}/${params.outdir}/${pair_id}/CompiledResults/fastp.html
    
    gzip ${pair_id}_1_trimmed.fastq
    gzip ${pair_id}_2_trimmed.fastq
    rm read?_tmp
    """
    }
    else{
        """
        mv ${reads[0]} ${pair_id}_1_trimmed.fastq.gz
        mv ${reads[1]} ${pair_id}_2_trimmed.fastq.gz
        """
    }
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
            time = 20.m
        }
        cpus 3
        errorStrategy { task.exitStatus in 137..140 ? 'retry' : 'terminate' }
        maxRetries 3

    }
    else {
        conda "kraken2"
        memory "6 GB"
        cpus 2
        time = 20.m
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
        cp report.kraken.txt ${projectDir}/${params.outdir}/${pair_id}/KrakenResults
        cp read.kraken ${projectDir}/${params.outdir}/${pair_id}/KrakenResults

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
        gzip ${pair_id}_1.TrimmedNoEu.fastq
        gzip ${pair_id}_2.TrimmedNoEu.fastq
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
    time = 3.m
    memory 2.GB
    
    publishDir "${params.outdir}/${pair_id}/CompiledResults", mode: 'copy', overwrite: true
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