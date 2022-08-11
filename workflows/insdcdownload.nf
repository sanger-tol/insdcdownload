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

include { SAMPLESHEET_CHECK             } from '../modules/local/samplesheet_check'

//
// SUBWORKFLOW: Consisting of a mix of local and nf-core/modules
//
include { PREPARE_GENOME                } from '../subworkflows/local/prepare_genome'
include { DOWNLOAD_GENOME               } from '../subworkflows/local/download_genome'
include { PREPARE_REPEATS               } from '../subworkflows/local/prepare_repeats'

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

    ch_inputs = Channel.empty()
    if (params.input) {

        SAMPLESHEET_CHECK ( file(params.input, checkIfExists: true) )
            .csv
            .splitCsv ( header:true, sep:',' )
            .set { ch_inputs }

    } else {

        ch_inputs = Channel.from( [
            [assembly_accession:params.assembly_accession, assembly_name:params.assembly_name]
        ] )

    }

    // actual download -> all files (incl. masked fasta)
    // remove masking -> unmasked fasta
    DOWNLOAD_GENOME (
        ch_inputs.map { it["assembly_accession"] },
        ch_inputs.map { it["assembly_name"] }
    )
    ch_versions = ch_versions.mix(DOWNLOAD_GENOME.out.versions)

    // bwamem2 index
    // bgzip
    // samtools faidx
    // samtools dict
    // chrom.sizes
    PREPARE_GENOME (
        DOWNLOAD_GENOME.out.fasta_unmasked
    )
    ch_versions = ch_versions.mix(PREPARE_GENOME.out.versions)

    //DOWNLOAD_GENOME.out.fasta_masked.view()
    // masking bed
    // bgzip
    // samtools faidx
    // samtools dict
    PREPARE_REPEATS (
        DOWNLOAD_GENOME.out.fasta_masked
    )
    ch_versions = ch_versions.mix(PREPARE_REPEATS.out.versions)

    // TODO: Add Slack notification in main workflow
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
