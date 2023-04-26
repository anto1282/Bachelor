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
    
    
    publishDir "${params.outdir}/${sra_nr}/Reads"

    input: 
    val sra_nr
    
    output:
    val (sra_nr)
    path("${sra_nr}_1.fastq.gz")
    path("${sra_nr}_2.fastq.gz")
    

    script:
    """
    prefetch ${sra_nr}
    fasterq-dump ${sra_nr} --split-files
    gzip ${sra_nr}_1.fastq
    gzip ${sra_nr}_2.fastq
    """
}

process TRIM {
    
    // Openjdk is already loaded, should not also be loaded here
    if (params.server) {
        beforeScript 'module load perl adapterremoval fastqc fastp'
        afterScript 'module unload perl adapterremoval fastqc fastp'
    }
    else {
        conda 'adapterremoval fastqc fastp'
    }
     
    cpus 4

    input: 
    val(pair_id)
    path(r1) 
    path(r2)


    output:
    val(pair_id)
    path("${r1.simpleName}_trimmed.fastq.gz")
    path("${r2.simpleName}_trimmed.fastq.gz")

    
    script:
   
    if (params.refGenome == ""){
    """
    AdapterRemoval --file1 ${r1}  --file2 ${r2} --output1 read1_tmp --output2 read2_tmp 
    fastp -i read1_tmp -I read2_tmp -o ${r1.simpleName}_trimmed.fastq  -O ${r2.simpleName}_trimmed.fastq  -W 5 -M 30 -5 -3 -e 25 -f 15 -t 15
    
    mkdir -p ${projectDir}/${params.outdir}/${pair_id}/CompiledResults/
    mv fastp.html ${projectDir}/${params.outdir}/${pair_id}/CompiledResults/fastp.html
    
    gzip ${r1.simpleName}_trimmed.fastq
    gzip ${r2.simpleName}_trimmed.fastq
    rm read?_tmp
    
    """
    }
    else{
     """
    AdapterRemoval --file1 ${r1}  --file2 ${r2} --output1 read1_tmp --output2 read2_tmp 
    fastp -i read1_tmp -I read2_tmp -o ${r1.simpleName}_trimmed.fastq  -O ${r2.simpleName}_trimmed.fastq  -W 5 -M 30 -5 -3 -e 30 -f 15 -t 15 
    
    mkdir -p ${projectDir}/${params.outdir}/${pair_id}/CompiledResults/
    mv fastp.html ${projectDir}/${params.outdir}/${pair_id}/CompiledResults/fastp.html
    
    gzip ${r1.simpleName}_trimmed.fastq
    gzip ${r2.simpleName}_trimmed.fastq
    rm read?_tmp

    """
    }
}

process KRAKEN{

    if (params.server) {
        beforeScript 'module load openmpi kraken2'
        afterScript 'module unload kraken2 openmpi'
        memory {61.GB * task.attempt}
        cpus 8
        errorStrategy { task.exitStatus in 137..140 ? 'retry' : 'terminate' }
        maxRetries 3

    }
    else {
        conda "kraken2"
        memory "6 GB"
        cpus 4
    }
    
    publishDir "${params.outdir}/${pair_id}/Assembly"
    
    input:
    val(pair_id)
    path (r1)
    path (r2)
    

    output:
    val(pair_id)
    path("${pair_id}_1.TrimmedSubNoEu.fastq.gz")
    path("${pair_id}_2.TrimmedSubNoEu.fastq.gz")
    
    script:
    if (params.server) {
        """
        gzip -d -f ${r1}
        gzip -d -f ${r2}
        mkdir ${projectDir}/${params.outdir}/${pair_id}/Assembly
        kraken2 -d ${params.krakDB} --report report.kraken.txt --paired ${r1.baseName} ${r2.baseName} --output read.kraken --threads ${task.cpus}
        python3 ${projectDir}/TaxRemover.py ${r1.baseName} ${r2.baseName} ${pair_id} report.kraken.txt read.kraken > ${projectDir}/${params.outdir}/${pair_id}/Assembly/assemblyStats.txt
        
        rm ${r1.baseName}
        rm ${r2.baseName} 
        gzip ${pair_id}_1.TrimmedSubNoEu.fastq
        gzip ${pair_id}_2.TrimmedSubNoEu.fastq
        """
    }
    else {
        """
        gzip -d -f ${r1}
        gzip -d -f ${r2}
        mkdir ${projectDir}/${params.outdir}/${pair_id}/Assembly
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