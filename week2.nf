#!/usr/bin/env nextflow

nextflow.enable.types = true

record BowtieIndex {
    name: String
    index: Path
}

process BOWTIE2_INDEX {
    // TODO: add an appropriate label based on the report, and the
    // scc resource guide. 

    // TODO: update the bowtie2 command via the manual to use the 
    // amount of threads specified in the label using $task.cpus.
    // Hint: Find the argument in bowtie2 that enables the use of
    // multiple threads and provide $task.cpus as the value.

    conda 'envs/bowtie2_env.yml'

    input:
    reference: Path

    output:
    idx: BowtieIndex = record(name: reference.baseName, index: file("bowtie2_index/"))

    script:
    """ 
    mkdir bowtie2_index
    bowtie2-build $reference bowtie2_index/${reference.baseName}
    """
    
    stub:
    """
    mkdir bowtie2_index
    """
}

record ShortReads {
    name: String
    short1: Path
    short2: Path
}

record BamRec {
    name: String
    bam: Path
}

record BamIdx {
    name: String
    bam: Path
    idx: Path

}

process BOWTIE2_ALIGN {
    // TODO: add an appropriate label based on the report, and the
    // scc resource guide. 

    // TODO: update the bowtie2 command via the manual to use the 
    // amount of threads specified in the label using $task.cpus.
    // Hint: Find the argument in bowtie2 that enables the use of
    // multiple threads and provide $task.cpus as the value.

    conda 'envs/bowtie2_env.yml'

    input:
    reads: ShortReads
    idx: BowtieIndex

    output:
    bam: BamRec = record(name: reads.name, bam: file("${reads.name}.bam"))

    script:
    """ 
    bowtie2 -x bowtie2_index/${idx.name} -1 ${reads.short1} -2 ${reads.short2} | samtools view -bS - > ${reads.name}.bam
    """

    stub:
    """
    touch ${reads.name}.bam
    """

}

process SAMTOOLS_SORT {

    // TODO: add an appropriate label based on the report and the SCC
    // resource guide, and use $task.cpus in the command below (see README).
    conda 'envs/samtools_env.yml'

    input:
    aln: BamRec

    output:
    bamidx: BamIdx = record(name: aln.name, bam: file("${aln.bam.baseName}.sorted.bam"), idx: file("${aln.bam.baseName}.sorted.bam.bai"))

    script:
    """ 
    samtools sort $aln.bam > ${aln.bam.baseName}.sorted.bam
    samtools index ${aln.bam.baseName}.sorted.bam
    """

    stub:
    """
    touch ${aln.bam.baseName}.sorted.bam
    touch ${aln.bam.baseName}.sorted.bam.bai
    """

}

process PILON {

    // TODO: add an appropriate label based on the report and the SCC
    // resource guide, and use $task.cpus in the command below (see README).
    conda 'envs/pilon_env.yml'

    input:
    assembly: Path
    bamidx: BamIdx
    
    output:
    improved: Path = file('pilon.fasta')

    script:
    """ 
    pilon --genome $assembly --frags $bamidx.bam -Xmx32G
    """

    stub:
    """
    touch pilon.fasta
    """

}


// TODO: Above, move all of the above modules into their own separate modules like the week 1
// modules. Below, add in an include statement for each of the modules you moved into
// their own directory. 

include {FASTQC} from './modules/fastqc/main.nf'
include {FILTLONGER} from './modules/filtlonger/main.nf'
include {FLYE} from './modules/flye/main.nf'


workflow {

    read_pairs_ch = channel.of(file(params.reads)).splitCsv(header: true).map { row -> record(name: row.name, long_reads: file(row.long_reads), short1: file(row.short1), short2: file(row.short2))}

    fastqc_ch = read_pairs_ch.flatMap { it -> [record(name: it.name, read: it.short1), record(name: it.name, read: it.short2)]}
    
    fastqc_out = FASTQC(fastqc_ch)

    filtered_ch = FILTLONGER(read_pairs_ch)
    assembly_ch = FLYE(filtered_ch)

    // TODO: connect BOWTIE2_INDEX, BOWTIE2_ALIGN, SAMTOOLS_SORT, and PILON
    // below to finish the workflow.
    // - Build a genome index from the assembled genome (assembly_ch) using
    //   BOWTIE2_INDEX.

    // - Build a channel of ShortReads records from read_pairs_ch and align
    //   them to that index with BOWTIE2_ALIGN using `map` and `record`

    // - Sort and index the resulting alignment with SAMTOOLS_SORT.
    
    // - Polish the assembly with PILON, using the original assembly_ch and
    //   the sorted, indexed alignment.
    //
    // Look at each process's input: and output: blocks above, and specifications
    // to work out what channels each process needs and how to access the outputs
    // of a previous process.
}
