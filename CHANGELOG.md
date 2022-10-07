# sanger-tol/insdcdownload: Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v1.1.0 - [2022-10-07]

Minor update that fixes a few bugs

### `Fixed`

- BED files were not tabix-indexed with the right settings
- Fasta files now have the `.fa` extension, rather than `.fasta`

### `Added`

- New `species_dir` column to indicate where to download the files to

## v1.0.0 - [2022-08-12]

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
