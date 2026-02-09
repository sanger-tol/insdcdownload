// Create a SAM header template from NCBI assembly report and SAMtools .dict
include { SAMTOOLS_DICT    } from '../../modules/nf-core/samtools/dict/main'
include { BUILD_ACC_TABLE  } from '../../modules/local/build_accession_table'
include { BUILD_SAM_HEADER } from '../../modules/local/build_sam_header'

workflow PREPARE_HEADER {
    take:
    fasta // tuple(meta, file: /path/to/genome.fa.gz)
    report // tuple(meta, file: /path/to/genome.assembly_report.txt)

    main:
    ch_versions = channel.empty()

    // Generate Samtools dictionary
    ch_samtools_dict = SAMTOOLS_DICT(fasta).dict
    ch_versions = ch_versions.mix(SAMTOOLS_DICT.out.versions)

    // The meta maps differ, so join the channels by meta.id
    dict_mapped = ch_samtools_dict.map { meta, path -> [meta.id, meta, path] }
    report_mapped = report.map { meta, path -> [meta.id, path] }

    joined = dict_mapped
        .join(report_mapped)
        .map { _meta_id, meta, dict_path, report_path ->
            [
                meta,
                dict_path,
                report_path,
            ]
        }

    // Get header template
    ch_header = BUILD_SAM_HEADER(joined).header
    ch_versions = ch_versions.mix(BUILD_SAM_HEADER.out.versions.first())

    // Get accession table
    ch_acc_table = BUILD_ACC_TABLE(report).table
    ch_versions = ch_versions.mix(BUILD_ACC_TABLE.out.versions.first())

    emit:
    header    = ch_header // tuple(meta, path: genome.header.sam)
    acc_table = ch_acc_table // tuple(meta, path: table)
    versions  = ch_versions // channel: [ versions.yml ]
}
