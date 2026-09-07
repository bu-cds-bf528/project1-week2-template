#!/usr/bin/env nextflow

nextflow.enable.types = true

record AssemblyReads {
    id: String
    long_reads: Path
    short_reads_r1: Path
    short_reads_r2: Path
}

record FastqRead {
    id: String
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
    touch ${reads.id}_stub_fastqc.html
    touch ${reads.id}_stub_fastqc.zip
    """

}

process FILTLONGER {
    label 'process_single'
    conda 'envs/filterlong_env.yml'

    input:
    reads: AssemblyReads

    output:
    filtered: FastqRead = record(id: reads.id, read: file("${reads.id}.filtered.fastq.gz"))

    script:
    """
    filtlong --min_length 500 --keep_percent 90 $reads.read | gzip > ${reads.id}.filtered.fastq.gz
    """

    stub:
    """
    touch ${reads.id}.filtered.fastq.gz
    """

}

process FLYE {
    label 'process_high'
    conda 'envs/flye_env.yml'

    input:
    reads: FastqRead

    output:
    fasta: Path = file("${reads.id}.assembly.fasta")

    script:
    """
    flye --nano-hq $reads.read -o .
    """

    stub:
    """
    touch ${reads.id}.assembly.fasta
    """
}

workflow {

    read_pairs_ch = channel.of(file(params.reads)).splitCsv(header: true).map { row -> record(name: row.name, short1: file(row.short1), short2: file(row.short2))}

    fastqc_ch = read_pairs_ch.flatMap { it -> [record(id: it.name, read: it.short1), record(id: it.name, read: it.short2)]}
    
    fastqc_out = FASTQC(fastqc_ch)

    filtered_ch = FILTLONGER(read_pairs_ch)
    assembly_ch = FLYE(filtered_ch)


}