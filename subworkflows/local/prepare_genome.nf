//
// Uncompress and prepare reference genome files
//

include { BWAMEM2_INDEX           } from '../../modules/nf-core/modules/bwamem2/index/main'
include { GUNZIP                  } from '../../modules/nf-core/modules/gunzip/main'
include { MASKING_TO_BED          } from '../../modules/local/masking_to_bed'
include { MINIMAP2_INDEX          } from '../../modules/nf-core/modules/minimap2/index/main'
include { REMOVE_MASKING          } from '../../modules/local/remove_masking'
include { SAMTOOLS_FAIDX          } from '../../modules/nf-core/modules/samtools/faidx/main'
include { SAMTOOLS_DICT           } from '../../modules/nf-core/modules/samtools/dict/main'


workflow PREPARE_GENOME {

    take:
    fasta  // file: /path/to/genome.fa.gz


    main:
    ch_versions = Channel.empty()

    // gunzip .fa.gz files
    ch_unzipped_fasta = GUNZIP ( [ [:], fasta ] ).gunzip
    ch_versions       = ch_versions.mix(GUNZIP.out.versions)

    // BED file
    ch_masking_bed    = MASKING_TO_BED ( ch_unzipped_fasta ).bed
    ch_versions       = ch_versions.mix(MASKING_TO_BED.out.versions)

    // Unmask genome fasta
    ch_unmasked_fasta = REMOVE_MASKING ( ch_unzipped_fasta ).fasta
    ch_versions       = ch_versions.mix(REMOVE_MASKING.out.versions)

    // Generate BWA index
    ch_bwamem2_index  = BWAMEM2_INDEX (REMOVE_MASKING.out.fasta).index
    ch_versions       = ch_versions.mix(BWAMEM2_INDEX.out.versions)

    // Generate Minimap2 index
    // NOTE: minimap2/index doesn't support the meta map
    ch_minimap2_index = MINIMAP2_INDEX (ch_unmasked_fasta.map { it[1] }).index
    ch_versions       = ch_versions.mix(MINIMAP2_INDEX.out.versions)

    // Generate Samtools index
    ch_samtools_faidx = SAMTOOLS_FAIDX (ch_unmasked_fasta).fai
    ch_versions       = ch_versions.mix(SAMTOOLS_FAIDX.out.versions)

    // Generate Samtools dictionary
    ch_samtools_dict  = SAMTOOLS_DICT (ch_unmasked_fasta).dict
    ch_versions       = ch_versions.mix(SAMTOOLS_FAIDX.out.versions)


    emit:
    fasta    = ch_unmasked_fasta         // path: genome.unmasked.fasta
    bed      = ch_masking_bed            // path: genome.unmasked.fasta
    bwaidx   = ch_bwamem2_index          // path: bwamem2/index/
    minidx   = ch_minimap2_index         // path: minimap2/index/
    faidx    = ch_samtools_faidx         // path: samtools/faidx/
    dict     = ch_samtools_dict          // path: samtools/dict/
    versions = ch_versions.ifEmpty(null) // channel: [ versions.yml ]
}
