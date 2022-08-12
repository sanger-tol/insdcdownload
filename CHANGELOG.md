# sanger-tol/insdcdownload: Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v1.0.0 - [2022-08-12]

Initial release of sanger-tol/insdcdownload, created with the [nf-core](https://nf-co.re/) template.

### `Added`

- Download from the NCBI
- Unmasking of the NCBI assembly
- `samtools faidx` and `samtools dict` indices, as well as `bwa-mem2` for
  the unmasked assembly
- BED file with the coordinates of the masked region

### `Dependencies`

All dependencies are automatically fetched by Singularity.

- bgzip
- BWA-mem2
- samtools
- tabix
- python3
- wget
- awk
- gzip
