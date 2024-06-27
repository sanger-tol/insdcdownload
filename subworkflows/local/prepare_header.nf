// Create a SAM header template from NCBI assembly report and SAMtools .dict
include { BUILD_SAM_HEADER } from '../../modules/local/build_sam_header'

workflow PREPARE_HEADER {

    take:
    dict    // file: /path/to/genome.dict
    report  // file: /path/to/genome.assembly_report.txt
    source  // file: /path/to/SOURCE (ftp path as string)

    main:
    ch_versions = Channel.empty()

    // The meta maps differ, so join the channels by meta.id
    dict_mapped = dict.map { meta, path -> [meta.id, meta, path] }
    report_mapped = report.map { meta, path -> [meta.id, path] }
    source_mapped = source.map { meta, path -> [meta.id, path] }

    joined = dict_mapped
        | join(report_mapped)
        | join(source_mapped)
        | map { it[1..-1] } // remove leading meta.id

    // Get header template
    ch_header = BUILD_SAM_HEADER(joined).header

    ch_versions = ch_versions.mix(BUILD_SAM_HEADER.out.versions.first())

    emit:
    header = ch_header                   // path: genome.header.sam
    versions = ch_versions.ifEmpty(null) // channel: [ versions.yml ]
}
