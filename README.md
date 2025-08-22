# ![sanger-tol/insdcdownload](docs/images/sanger-tol-insdcdownload_logo.png)

[![GitHub Actions CI Status](https://github.com/sanger-tol/insdcdownload/actions/workflows/nf-test.yml/badge.svg)](https://github.com/sanger-tol/insdcdownload/actions/workflows/nf-test.yml)
[![GitHub Actions Linting Status](https://github.com/sanger-tol/insdcdownload/actions/workflows/linting.yml/badge.svg)](https://github.com/sanger-tol/insdcdownload/actions/workflows/linting.yml)
[![Cite with Zenodo](http://img.shields.io/badge/DOI-10.5281/zenodo.6983932-1073c8?labelColor=000000)](https://doi.org/10.5281/zenodo.6983932)
[![nf-test](https://img.shields.io/badge/unit_tests-nf--test-337ab7.svg)](https://www.nf-test.com)

[![Nextflow](https://img.shields.io/badge/version-%E2%89%A524.10.5-green?style=flat&logo=nextflow&logoColor=white&color=%230DC09D&link=https%3A%2F%2Fnextflow.io)](https://www.nextflow.io/)
[![nf-core template version](https://img.shields.io/badge/nf--core_template-3.3.2-green?style=flat&logo=nfcore&logoColor=white&color=%2324B064&link=https%3A%2F%2Fnf-co.re)](https://github.com/nf-core/tools/releases/tag/3.3.2)
[![run with conda](http://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://docs.conda.io/en/latest/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)
[![Launch on Seqera Platform](https://img.shields.io/badge/Launch%20%F0%9F%9A%80-Seqera%20Platform-%234256e7)](https://cloud.seqera.io/launch?pipeline=https://github.com/sanger-tol/insdcdownload)

[![Follow on Twitter](http://img.shields.io/badge/twitter-%40sangertol-1DA1F2?labelColor=000000&logo=twitter)](https://twitter.com/sangertol)
[![Watch on YouTube](http://img.shields.io/badge/youtube-tree--of--life-FF0000?labelColor=000000&logo=youtube)](https://www.youtube.com/channel/UCFeDpvjU58SA9V0ycRXejhA)

## Introduction

**sanger-tol/insdcdownload** is a pipeline that downloads assemblies from INSDC into a Tree of Life directory structure.

The pipeline takes an assembly accession number, as well as the assembly name, and downloads it. It also builds a set of common indices (such as `samtools faidx`), and extracts the repeat-masking performed by the NCBI.

Steps involved:

- Download from the NCBI the genomic sequence (Fasta) and the assembly
  stats and reports files.
- Turn the masked Fasta file into an unmasked one.
- Compress and index all Fasta files with `bgzip`, `samtools faidx`, and
  `samtools dict`.
- Generate the `.sizes` file usually required for conversion of data
  files to UCSC's "big" formats, e.g. bigBed.
- Extract the coordinates of the masked regions into a BED file.
- Compress and index the BED file with `bgzip` and `tabix`.

## Usage

> [!NOTE]
> If you are new to Nextflow and nf-core, please refer to [this page](https://nf-co.re/docs/usage/installation) on how to set-up Nextflow. Make sure to [test your setup](https://nf-co.re/docs/usage/introduction#how-to-run-a-pipeline) with `-profile test` before running the workflow on actual data.

The easiest is to provide the exact name and accession number of the assembly like this:

```console
nextflow run sanger-tol/insdcdownload --assembly_accession GCA_927399515.1 --assembly_name gfLaeSulp1.1
```

> [!WARNING]
> Please provide pipeline parameters via the CLI or Nextflow `-params-file` option. Custom config files including those provided by the `-c` Nextflow option can be used to provide any configuration _**except for parameters**_; see [docs](https://nf-co.re/docs/usage/getting_started/configuration#custom-configuration-files).

The pipeline also supports bulk downloads through a sample-sheet.
More information about this mode on our [pipeline website](https://pipelines.tol.sanger.ac.uk/insdcdownload/usage).

## Credits

sanger-tol/insdcdownload was mainly written by [Matthieu Muffato](https://github.com/muffato), with major borrowings from a's [read-mapping](https://github.com/sanger-tol/readmapping) pipeline, e.g. the script to remove the repeat-masking, and the overall structure and layout of the sub-workflows.

We thank the following people for their extensive assistance in the development of this pipeline:

- [Priyanka Surana](https://github.com/priyanka-surana) for providing reviews.

## Contributions and Support

If you would like to contribute to this pipeline, please see the [contributing guidelines](.github/CONTRIBUTING.md).

## Citations

If you use sanger-tol/insdcdownload for your analysis, please cite it using the following doi: [10.5281/zenodo.6983932](https://doi.org/10.5281/zenodo.6983932)

An extensive list of references for the tools used by the pipeline can be found in the [`CITATIONS.md`](CITATIONS.md) file.

This pipeline uses code and infrastructure developed and maintained by the [nf-core](https://nf-co.re) community, reused here under the [MIT license](https://github.com/nf-core/tools/blob/main/LICENSE).

> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).
