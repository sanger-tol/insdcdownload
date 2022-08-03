//
// Uncompress and prepare reference genome files
//

include { CHROM_SIZES             } from '../../modules/local/chrom_sizes'
include { BWAMEM2_INDEX           } from '../../modules/nf-core/modules/bwamem2/index/main'
include { SAMTOOLS_FAIDX          } from '../../modules/nf-core/modules/samtools/faidx/main'
include { SAMTOOLS_DICT           } from '../../modules/nf-core/modules/samtools/dict/main'
include { TABIX_BGZIP             } from '../../modules/nf-core/modules/tabix/bgzip/main'


workflow PREPARE_GENOME {

    take:
    fasta  // file: /path/to/genome.fa


    main:
    ch_versions = Channel.empty()

    // Compress the Fasta file
    ch_compressed_fasta = TABIX_BGZIP (fasta).output
    ch_versions         = ch_versions.mix(TABIX_BGZIP.out.versions)

    // Generate BWA index
    ch_bwamem2_index    = BWAMEM2_INDEX (fasta).index
    ch_versions         = ch_versions.mix(BWAMEM2_INDEX.out.versions)

    // Generate Samtools index
    ch_samtools_faidx   = SAMTOOLS_FAIDX (ch_compressed_fasta).fai
    ch_versions         = ch_versions.mix(SAMTOOLS_FAIDX.out.versions)

    // Generate Samtools dictionary
    // FIXME: dict includes full paths in the UR tag. Pass the --uri command-line option
    ch_samtools_dict    = SAMTOOLS_DICT (fasta).dict
    ch_versions         = ch_versions.mix(SAMTOOLS_DICT.out.versions)

    ch_chrom_sizes      = CHROM_SIZES ( ch_samtools_faidx ).chrom_sizes
    ch_versions         = ch_versions.mix(CHROM_SIZES.out.versions)

    emit:
    fasta_gz = ch_compressed_fasta       // path: genome.fasta.gz
    bwaidx   = ch_bwamem2_index          // path: bwamem2/index/
    faidx    = ch_samtools_faidx         // path: samtools/faidx/
    dict     = ch_samtools_dict          // path: samtools/dict/
    sizes    = ch_chrom_sizes            // path: samtools/dict/
    versions = ch_versions.ifEmpty(null) // channel: [ versions.yml ]
}
