// Create a SAM header template from NCBI assembly report and SAMtools .dict
include { BUILD_SAM_HEADER } from '../../modules/local/build_sam_header'

workflow PREPARE_HEADER {

    take:
    dict    // file: /path/to/genome.dict
    report  // file: /path/to/genome.assembly_report.txt
    source  // file: /path/to/SOURCE (ftp path as string)

    main:
    ch_versions = Channel.empty()

    // Normalize the dict ID by removing .masked.ncbi if present and join
    dict_mapped = dict.map { meta, path ->
        def id = meta.id.replace('.masked.ncbi', '')
        [id, [meta, path]]
    }
    report_mapped = report.map { meta, path -> [meta.id, path] }
    source_mapped = source.map { meta, path -> [meta.id, path] }

    joined = dict_mapped.join(report_mapped).join(source_mapped)

    // Create input tuple with original meta.id
    formatted_joined = joined.map { id, dict_tuple, report_path, source_path ->
        def original_meta = dict_tuple[0] // Get the original ID with .masked.ncbi if present
        def dict_path = dict_tuple[1]
        return [original_meta, dict_path, report_path, source_path]
    }

    // Get header template
    ch_header = BUILD_SAM_HEADER(formatted_joined).header

    ch_versions = ch_versions.mix(BUILD_SAM_HEADER.out.versions.first())

    emit:
    header = ch_header                   // path: genome.header.sam
    versions = ch_versions.ifEmpty(null) // channel: [ versions.yml ]
}
