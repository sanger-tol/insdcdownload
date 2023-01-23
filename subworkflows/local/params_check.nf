//
// Check and parse the input parameters
//

include { SAMPLESHEET_CHECK } from '../../modules/local/samplesheet_check'

workflow PARAMS_CHECK {

    take:
    samplesheet  // file
    cli_params   // tuple, see below
    outdir       // file output directory


    main:

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
                (it["species_dir"].startsWith("/") ? "" : outdir + "/") + it["species_dir"],
            ] }
            .set { ch_inputs }

        ch_versions = ch_versions.mix(SAMPLESHEET_CHECK.out.versions)

    } else {
        // Add the other input channel in, as it's expected to have all the parameters in the right order
        // except the output directory which must be appended
        ch_inputs = ch_inputs.mix(cli_params.map { it + [outdir] } )
    }


    emit:
    assembly_params = ch_inputs        // channel: tuple(assembly_accession, assembly_name, species_dir)
    versions        = ch_versions      // channel: versions.yml
}

