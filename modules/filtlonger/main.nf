#!/usr/bin/env nextflow

nextflow.enable.types = true

record FastqRead {
    name: String
    read: Path
}

record AssemblyReads {
    name: String
    long_reads: Path
    short_reads_r1: Path
    short_reads_r2: Path
}

process FILTLONGER {
    label 'process_single'
    conda 'envs/filterlong_env.yml'

    input:
    reads: AssemblyReads

    output:
    filtered: FastqRead = record(name: reads.name, read: file("${reads.name}.filtered.fastq.gz"))

    script:
    """
    filtlong --min_length 500 --keep_percent 90 $reads.long_reads | gzip > ${reads.name}.filtered.fastq.gz
    """

    stub:
    """
    touch ${reads.name}.filtered.fastq.gz
    """

}