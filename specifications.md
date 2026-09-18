# Objective

A nextflow pipeline that takes paired-end short reads and long reads
and generates a polished genome assembly. This will include quality control
filtering of the long reads, followed by a draft genome assembly using the
long reads performed by Flye, and finally polishing of the draft assembly using
the short reads. To perform the polishing, the short reads will be subjected to 
quality control before being aligned to the draft genome using Bowtie2. The 
alignments will be sorted and then used by Pilon in conjuction with the draft 
assembly to produce the final genome assembly. The quality and success of the 
genome assembly will be ascertained by running PROKKA and BUSCO on the final 
assembly, and using QUAST to compare the unpolished and final assembly. 

# Inputs

Samplesheet (CSV: name, long_reads, short1, short2)

# Outputs

Per set of reads for each species (short and long)
- QC reports for short reads
- Filtered long reads
- Draft genome assembly
- Polished genome assembly
- BUSCO Outputs
- QUAST outputs for the unpolished and polished assembly
- Genome annotation output from Prokka

# Pipeline Steps

Fill in one row per process in the pipeline. Derive the step list from the Objective and Outputs
sections above. "Depends on" should name the upstream step(s) whose output this step consumes
(used for wiring channels).

The rows below are a simple worked example (not from this pipeline) showing the expected format:
a process that downloads a genome, followed by a process that runs a script on it. Delete this
example table before you submit.

| Step | Input type | Depends on *(sample)* |
|---|---|---|
| Download genome *(sample)* | Accession ID | - |
| Run script on genome *(sample)* | Genome FASTA | Download genome |

| Step | Input type | Depends on |
|---|---|---|
|  |  |  |
|  |  |  |
|  |  |  |
|  |  |  |
|  |  |  |
|  |  |  |
|  |  |  |
|  |  |  |
|  |  |  |
|  |  |  |

# Development Workflow

Every process defines a `stub:` run that produces placeholder output files. All of
the stub runs should use the name from the CSV to identify outputs by their species
of origin.

# Environment and Reproducibility
Conda environments are defined per-tool in the envs/ directory.

For each tool used in the pipeline, confirm the conda env pins an exact version (not just a
channel), and note any tool where exact pinning isn't possible (e.g., no conda-forge/bioconda
package) and how you're mitigating that.

| Tool | Env file | Version pinned? |
|---|---|---|
|  |  |  |
|  |  |  |
|  |  |  |
|  |  |  |
|  |  |  |
|  |  |  |


# Resource Requirements

Every process has been assigned a label found in `nextflow.config` that requisitions
an appropriate amount of resources. The most resource intensive steps include Bowtie2 
index creation, alignment of the short reads, draft assembly by Flye, and assembly polishing
by pilon.


# Success Criteria

The stub-run correctly produces named placeholder outputs for each row in the original CSV.

# Out of Scope

Validation, aggregation and interpretation of genome statistics will be done manually
in the accompanying jupyter notebook.

# Validation Table

The rows below are a worked example from a different (RNA-seq) pipeline, shown only to illustrate
the expected format and level of detail. Replace them with rows for **this** pipeline's steps.
Delete the example table before you submit.

| Step | Parameter justification *(sample)* | Confidence *(sample)* | Validation *(sample)* |
|---|---|---|---|
| Sequencing quality control | Default FastQC parameters; adapter trimming skipped since STAR soft-clips at alignment | High | Per-base quality >Q30 across all cycles, all 3 samples |
| Alignment | Default STAR parameters, appropriate for 100bp paired-end reads | Medium | 88-92% uniquely-mapped across samples |
| Post-alignment QC | Default RSeQC settings; no strandedness flag since library prep is unstranded | Medium | >80% of reads in CDS exons + UTRs, consistent with poly-A selection |
| QC aggregation & reporting | Default MultiQC settings; no custom config needed | High | All 3 samples present in every module of the report |

| Step | Parameter justification | Confidence | Validation |
|---|---|---|---|
| Long-read QC/filtering |  |  |  |
| Draft assembly (Flye) |  |  |  |
| Short-read QC |  |  |  |
| Short-read alignment (Bowtie2) |  |  |  |
| Assembly polishing (Pilon) |  |  |  |
| Completeness (BUSCO) |  |  |  |
| Assembly comparison (QUAST) |  |  |  |
| Annotation (Prokka) |  |  |  |