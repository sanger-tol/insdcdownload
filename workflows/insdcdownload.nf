/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// SUBWORKFLOW: Consisting of a mix of local and nf-core/modules
//
include { DOWNLOAD_GENOME                                } from '../subworkflows/local/download_genome'
include { PREPARE_FASTA as PREPARE_UNMASKED_FASTA        } from '../subworkflows/local/prepare_fasta'
include { PREPARE_FASTA as PREPARE_REPEAT_MASKED_FASTA   } from '../subworkflows/local/prepare_fasta'
include { PREPARE_HEADER as PREPARE_UNMASKED_HEADER      } from '../subworkflows/local/prepare_header'
include { PREPARE_REPEATS                                } from '../subworkflows/local/prepare_repeats'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { paramsSummaryMap       } from 'plugin/nf-schema'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_insdcdownload_pipeline'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow INSDCDOWNLOAD {

    take:
    inputs      // channel: tuple(assembly_accession, assembly_name, outdir)
    main:

    ch_versions = Channel.empty()

    // Actual download
    DOWNLOAD_GENOME (
        inputs
    )
    ch_versions         = ch_versions.mix(DOWNLOAD_GENOME.out.versions)

    // Preparation of Fasta files
    PREPARE_UNMASKED_FASTA (
        DOWNLOAD_GENOME.out.fasta_unmasked
    )
    ch_versions         = ch_versions.mix(PREPARE_UNMASKED_FASTA.out.versions)

    // Header for unmasked fasta
    PREPARE_UNMASKED_HEADER (
        PREPARE_UNMASKED_FASTA.out.dict,
        DOWNLOAD_GENOME.out.assembly_report,
        DOWNLOAD_GENOME.out.source
    )
    ch_versions         = ch_versions.mix(PREPARE_UNMASKED_HEADER.out.versions)

    // Preparation of repeat-masking files
    PREPARE_REPEAT_MASKED_FASTA (
        DOWNLOAD_GENOME.out.fasta_masked
    )
    ch_versions         = ch_versions.mix(PREPARE_REPEAT_MASKED_FASTA.out.versions)

    PREPARE_REPEATS (
        PREPARE_REPEAT_MASKED_FASTA.out.fasta_gz
    )
    ch_versions         = ch_versions.mix(PREPARE_REPEATS.out.versions)

    //
    // Collate and save software versions
    //
    softwareVersionsToYAML(ch_versions)
        .collectFile(
            storeDir: "${params.outdir}/pipeline_info",
            name:  'insdcdownload_software_'  + 'versions.yml',
            sort: true,
            newLine: true
        ).set { ch_collated_versions }


    emit:
    versions       = ch_versions                 // channel: [ path(versions.yml) ]

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
