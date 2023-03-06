#!/usr/bin/env nextflow

params.cpu = 1

process SPADES {
    conda "bioconda::spades=3.15.5"
    publishDir "${params.outdir}/${pair_id}/Assembly", mode: 'copy'

    cpus = cpu
    input: 
    tuple val(pair_id), path(reads)

    output:
    path('contigs.fasta.gz')

    script:
    def (r1, r2) = reads
    
    """
    spades.py -1 ${r1} -2 ${r2} --meta --phred-offset 33
    if [ -f contigs.fasta ]; then
        gzip -n contigs.fasta
    fi
    """
}

//insert offsetdetector

process offsetdetector {
    input:
    path(reads)

    output:
    val phredscore
    script:
    
    def (r1, r2) = reads
    """
    #!/usr/bin/python3
    import Assembly

    print(offsetdetector.offsetDetector(${r1},${r2}))
    """
}

process SubSampling {
    conda 'agbiome::bbtools'
    input:
    tuple val(pair_id), path(reads), val samplerate, val sampleseed

    output:
    path(subsampled_reads)

    script:
    def (r1,r2) = reads

    subsampled_reads = reads.collect{
        "${it.baseName}_subsampled.fastq"
    }

    """
    reformat.sh in=${r1} in2=${r2} out=${subsampled_reads[0]} out2=${subsampled_reads[1]} samplerate=${samplerate} sampleseed=${sampleseed}
    """

}

