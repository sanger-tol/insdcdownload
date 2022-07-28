//
// Uncompress and prepare reference genome files
//

include { MASKING_TO_BED          } from '../../modules/local/masking_to_bed'
include { SAMTOOLS_FAIDX          } from '../../modules/nf-core/modules/samtools/faidx/main'
include { SAMTOOLS_DICT           } from '../../modules/nf-core/modules/samtools/dict/main'
include { TABIX_BGZIP             } from '../../modules/nf-core/modules/tabix/bgzip/main'


workflow PREPARE_REPEATS {

    take:
    fasta  // file: /path/to/genome.fa

    main:
    ch_versions = Channel.empty()

    // BED file
    ch_masking_bed      = MASKING_TO_BED ( fasta ).bed
    ch_versions         = ch_versions.mix(MASKING_TO_BED.out.versions)

    // Compress the Fasta file
    ch_compressed_fasta = TABIX_BGZIP (fasta).output
    ch_versions         = ch_versions.mix(TABIX_BGZIP.out.versions)

    // Generate Samtools index
    ch_samtools_faidx   = SAMTOOLS_FAIDX (ch_compressed_fasta).fai
    ch_versions         = ch_versions.mix(SAMTOOLS_FAIDX.out.versions)

    // Generate Samtools dictionary
    // FIXME: dict includes full paths in the UR tag. Pass the --uri command-line option
    ch_samtools_dict    = SAMTOOLS_DICT (fasta).dict
    ch_versions         = ch_versions.mix(SAMTOOLS_DICT.out.versions)

    emit:
    bed      = ch_masking_bed            // path: genome.bed
    fasta_gz = ch_compressed_fasta       // path: genome.fasta.gz
    faidx    = ch_samtools_faidx         // path: samtools/faidx/
    dict     = ch_samtools_dict          // path: samtools/dict/
    versions = ch_versions.ifEmpty(null) // channel: [ versions.yml ]
}
