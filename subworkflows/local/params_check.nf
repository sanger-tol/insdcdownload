//
// Check and parse the input parameters
//

include { SAMPLESHEET_CHECK } from '../../modules/local/samplesheet_check'

workflow PARAMS_CHECK {

    take:
    inputs          // tuple, see below


    main:

    def (samplesheet, assembly_accession, assembly_name, outdir) = inputs

    ch_versions = Channel.empty()

    ch_inputs = Channel.empty()
    if (samplesheet) {

        SAMPLESHEET_CHECK ( file(samplesheet, checkIfExists: true) )
            .csv
            // Provides species_dir, assembly_accession, and assembly_name
            .splitCsv ( header:true, sep:',' )
            // Convert to tuple, as required by the download subworkflow
            .map { [
                it["assembly_accession"],
                it["assembly_name"],
                it["species_dir"],
            ] }
            .set { ch_inputs }

        ch_versions = ch_versions.mix(SAMPLESHEET_CHECK.out.versions)

    } else {

        ch_inputs = Channel.of(
            [
                assembly_accession,
                assembly_name,
                outdir,
            ]
        )

    }


    emit:
    assembly_params = ch_inputs        // channel: tuple(assembly_accession, assembly_name, species_dir)
    versions        = ch_versions      // channel: versions.yml
}

