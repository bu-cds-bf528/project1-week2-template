#!/usr/bin/env nextflow

nextflow.enable.types = true

record FastqRead {
    name: String
    read: Path
}

process FLYE {
    label 'process_high'
    conda 'envs/flye_env.yml'

    input:
    reads: FastqRead

    output:
    fasta: Path = file("${reads.name}.assembly.fasta")

    script:
    """
    flye --nano-hq $reads.read -o .
    """

    stub:
    """
    touch ${reads.name}.assembly.fasta
    """
}
