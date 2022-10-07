/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VALIDATE INPUTS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

def summary_params = NfcoreSchema.paramsSummaryMap(workflow, params)

// Validate input parameters
WorkflowInsdcdownload.initialise(params, log)

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// SUBWORKFLOW: Consisting of a mix of local and nf-core/modules
//
include { DOWNLOAD_GENOME                              } from '../subworkflows/local/download_genome'
include { PARAMS_CHECK                                 } from '../subworkflows/local/params_check'
include { PREPARE_FASTA as PREPARE_UNMASKED_FASTA      } from '../subworkflows/sanger-tol/prepare_fasta'
include { PREPARE_FASTA as PREPARE_REPEAT_MASKED_FASTA } from '../subworkflows/sanger-tol/prepare_fasta'
include { PREPARE_REPEATS                              } from '../subworkflows/sanger-tol/prepare_repeats'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// MODULE: Installed directly from nf-core/modules
//
include { CUSTOM_DUMPSOFTWAREVERSIONS } from '../modules/nf-core/modules/custom/dumpsoftwareversions/main'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow INSDCDOWNLOAD {

    ch_versions = Channel.empty()

    PARAMS_CHECK (
        [
            params.input,
            params.assembly_accession,
            params.assembly_name,
            params.outdir,
        ]
    )
    ch_versions         = ch_versions.mix(PARAMS_CHECK.out.versions)

    // Actual download
    DOWNLOAD_GENOME (
        PARAMS_CHECK.out.assembly_params
    )
    ch_versions         = ch_versions.mix(DOWNLOAD_GENOME.out.versions)

    // Preparation of Fasta files
    PREPARE_UNMASKED_FASTA (
        DOWNLOAD_GENOME.out.fasta_unmasked
    )
    ch_versions         = ch_versions.mix(PREPARE_UNMASKED_FASTA.out.versions)

    // Preparation of repeat-masking files
    PREPARE_REPEAT_MASKED_FASTA (
        DOWNLOAD_GENOME.out.fasta_masked
    )
    ch_versions         = ch_versions.mix(PREPARE_REPEAT_MASKED_FASTA.out.versions)
    PREPARE_REPEATS (
        DOWNLOAD_GENOME.out.fasta_masked
    )
    ch_versions         = ch_versions.mix(PREPARE_REPEATS.out.versions)

    CUSTOM_DUMPSOFTWAREVERSIONS (
        ch_versions.unique().collectFile(name: 'collated_versions.yml')
    )
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    COMPLETION EMAIL AND SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow.onComplete {
    if (params.email || params.email_on_fail) {
        NfcoreTemplate.email(workflow, params, summary_params, projectDir, log)
    }
    NfcoreTemplate.summary(workflow, params, log)
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
