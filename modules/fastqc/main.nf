#!/usr/bin/env nextflow

nextflow.enable.types = true

record FastqRead {
    name: String
    read: Path
}

record FastqcReport {
    html: Path
    zip: Path
}


process FASTQC {
    label 'process_single'
    conda 'envs/fastqc_env.yml'

    input:
    reads: FastqRead

    output:
    report: FastqcReport = record(html: file("*_fastqc.html"), zip: file("*_fastqc.zip"))

    script:
    """
    fastqc $reads.read
    """

    stub:
    """
    touch ${reads.read.baseName}_stub_fastqc.html
    touch ${reads.read.baseName}_stub_fastqc.zip
    """

}