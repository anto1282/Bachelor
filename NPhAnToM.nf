#!/usr/bin/env nextflow

nextflow.enable.dsl=2
params.reads = "$baseDir/data/read{1,2}.fastq"


process TRIMTON {
    input:

}