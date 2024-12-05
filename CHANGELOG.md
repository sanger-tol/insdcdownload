# sanger-tol/insdcdownload: Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [[2.0.1](https://github.com/sanger-tol/insdcdownload/releases/tag/2.0.1)] - Light elf (patch 1) - [2024-12-05]

### Enhancements & fixes

- Update module versions
- Remove reference to Anaconda repositories

### Software dependencies

Note, since the pipeline is using Nextflow DSL2, each process will be run with its own [Biocontainer](https://biocontainers.pro/#/registry). This means that on occasion it is entirely possible for the pipeline to be using different versions of the same tool. However, the overall software dependency changes compared to the last release have been listed below for reference. Only `Docker` or `Singularity` containers are supported, `conda` is not supported.

| Dependency | Old version | New version |
| ---------- | ----------- | ----------- |
| multiqc    | 1.13        | 1.14        |

| Dependency | Old version | New version |
| ---------- | ----------- | ----------- |
| `Python `  | 3.8.3,3.9.1 | 3.9.1       |
| `samtools` | 1.17        | 1.21        |
| `tabix`    | 1.11        | 1.20        |

## [[2.0.0](https://github.com/sanger-tol/insdcdownload/releases/tag/2.0.0)] – Light elf – [2024-06-04]

This version supports the new FTP structure of Ensembl

### Enhancements & fixes

- The sample-sheet column `species_dir` is replaced with the `outdir` column which
  represents where the assembly and repeats are downloaded (in immediate sub-directories)
- Relative paths in the sample-sheet are now evaluated from the `--outdir` parameter
- Memory usage rules for `samtools dict`
- Appropriate use of `tabix`'s TBI and CSI indexing, depending on the sequence lengths
- `--outdir` is a _mandatory_ parameter

### Parameters

_In the samplesheet_

| Old parameter | New parameter |
| ------------- | ------------- |
| species_dir   | outdir        |

> **NB:** Parameter has been **updated** if both old and new parameter information is present. </br> **NB:** Parameter has been **added** if just the new parameter information is present. </br> **NB:** Parameter has been **removed** if new parameter information isn't present.

### Software dependencies

Note, since the pipeline is using Nextflow DSL2, each process will be run with its own [Biocontainer](https://biocontainers.pro/#/registry). This means that on occasion it is entirely possible for the pipeline to be using different versions of the same tool. However, the overall software dependency changes compared to the last release have been listed below for reference. Only `Docker` or `Singularity` containers are supported, `conda` is not supported.

| Dependency | Old version | New version |
| ---------- | ----------- | ----------- |
| multiqc    | 1.13        | 1.14        |

## [[1.1.0](https://github.com/sanger-tol/insdcdownload/releases/tag/1.1.0)] – Deciduous ent – [2022-10-07]

Minor update that fixes a few bugs

### `Fixed`

- BED files were not tabix-indexed with the right settings
- Fasta files now have the `.fa` extension, rather than `.fasta`

### `Added`

- New `species_dir` column to indicate where to download the files to

## [[1.0.0](https://github.com/sanger-tol/insdcdownload/releases/tag/1.0.0)] – Flaming balrog – [2022-08-12]

Initial release of sanger-tol/insdcdownload, created with the [nf-core](https://nf-co.re/) template.

### `Added`

- Download from the NCBI
- Unmasking of the NCBI assembly
- `samtools faidx` and `samtools dict` indices
- BED file with the coordinates of the masked region

### `Dependencies`

All dependencies are automatically fetched by Singularity.

- bgzip
- samtools
- tabix
- python3
- wget
- awk
- gzip
