# sanger-tol/insdcdownload: Output

## Introduction

This document describes the output produced by the pipeline.

The directories listed below will be created in a directory based on the `--outdir` command-line parameter and the `outdir` column of the samplesheet.
) after the pipeline has finished.
All paths are relative to the top-level results directory.

The directories comply with Tree of Life's canonical directory structure.

## Pipeline overview

The pipeline is built using [Nextflow](https://www.nextflow.io/) and processes data using the following steps:

- [Assembly files](#assembly-files) - Assembly files, either straight from the NCBI FTP, or indices built on them
- [Primary analysis files](#primary-analysis-files) - Files corresponding to analyses run (by the NCBI) on the original assembly, e.g repeat masking
- [Pipeline information](#pipeline-information) - Report metrics generated during the workflow execution

### Assembly files

Here are the files you can expect in the `assembly/` sub-directory.

```text
assembly
├── ACCESSION
├── GCA_927399515.1.assembly_report.txt
├── GCA_927399515.1.assembly_stats.txt
├── GCA_927399515.1.fa.dict
├── GCA_927399515.1.fa.gz
├── GCA_927399515.1.fa.gz.fai
├── GCA_927399515.1.fa.gz.gzi
└── GCA_927399515.1.fa.gz.sizes
```

All files are named after the assembly accession, e.g. `GCA_927399515.1`.

- `GCA_*.assembly_report.txt` and `GCA_*.assembly_stats.txt`: report and statistics files, straight from the NCBI FTP
- `GCA_*.fa.gz`: Unmasked assembly in Fasta format, compressed with `bgzip` (whose index is `GCA_*.fa.gz.gzi`)
- `GCA_*.fa.gz.fai`: `samtools faidx` index, which allows accessing any region of the assembly in constant time
- `GCA_*.fa.dict`: `samtools dict` index, which allows identifying a sequence by its MD5 checksum
- `GCA_*.fa.gz.sizes`: Tabular file with the size of all sequences in the assembly. Typically used to build "big" files (bigBed, etc).

with the exception of `ACCESSION`, which contains a single line of text: the assembly accession.

### Primary analysis files

Here are the files you can expect in the `repeats/` sub-directory.

```text
repeats
└── ncbi
    ├── GCA_927399515.1.masked.ncbi.bed.gz
    ├── GCA_927399515.1.masked.ncbi.bed.gz.csi
    ├── GCA_927399515.1.masked.ncbi.bed.gz.tbi
    ├── GCA_927399515.1.masked.ncbi.fa.dict
    ├── GCA_927399515.1.masked.ncbi.fa.gz
    ├── GCA_927399515.1.masked.ncbi.fa.gz.fai
    ├── GCA_927399515.1.masked.ncbi.fa.gz.gzi
    └── GCA_927399515.1.masked.ncbi.fa.gz.sizes
```

They all correspond to the repeat-masking analysis run by the NCBI themselves. Like for the `assembly/` sub-directory,
all files are named after the assembly accession, e.g. `GCA_927399515.1`.

- `GCA_*.masked.ncbi.fa.gz`: Masked assembly in Fasta format, compressed with `bgzip` (whose index is `GCA_*.fa.gz.gzi`)
- `GCA_*.masked.ncbi.fa.gz.fai`: `samtools faidx` index, which allows accessing any region of the assembly in constant time
- `GCA_*.masked.ncbi.fa.dict`: `samtools dict` index, which allows identifying a sequence by its MD5 checksum
- `GCA_*.masked.ncbi.bed.gz`: BED file with the coordinates of the regions masked by the NCBI pipeline, with accompanying `tabix` indices (`.csi` and `.tbi`), depending on the sequence lengths

### Pipeline information

- `pipeline_info/insdcdownload/`
  - Reports generated by Nextflow: `execution_report.html`, `execution_timeline.html`, `execution_trace.txt` and `pipeline_dag.dot`/`pipeline_dag.svg`.
  - Reports generated by the pipeline: `pipeline_report.html`, `pipeline_report.txt` and `software_versions.yml`. The `pipeline_report*` files will only be present if the `--email` / `--email_on_fail` parameter's are used when running the pipeline.
  - Reformatted samplesheet files used as input to the pipeline: `samplesheet.valid.csv`.

[Nextflow](https://www.nextflow.io/docs/latest/tracing.html) provides excellent functionality for generating various reports relevant to the running and execution of the pipeline. This will allow you to troubleshoot errors with the running of the pipeline, and also provide you with other information such as launch commands, run times and resource usage.
