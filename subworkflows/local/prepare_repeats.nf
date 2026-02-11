//
// Extract the masked regions from a Fasta file as BED,
// and prepare indexes for it
//

include { REPEATS_BED                    } from '../../modules/local/repeats_bed'
include { TABIX_BGZIP                    } from '../../modules/nf-core/tabix/bgzip/main'
include { TABIX_TABIX as TABIX_TABIX_CSI } from '../../modules/nf-core/tabix/tabix/main'
include { TABIX_TABIX as TABIX_TABIX_TBI } from '../../modules/nf-core/tabix/tabix/main'


workflow PREPARE_REPEATS {
    take:
    fasta // file: /path/to/genome.fa

    main:
    // BED file
    ch_bed = REPEATS_BED(fasta).bed

    // Compress the BED file
    ch_compressed_bed = TABIX_BGZIP(ch_bed).output

    // Try indexing the BED file in two formats for maximum compatibility
    // but each has its own limitations
    tabix_selector = ch_compressed_bed.branch { meta, _bed ->
        tbi_and_csi: meta.max_length < 2 ** 29
        only_csi: meta.max_length < 2 ** 32
        no_tabix: true
    }

    // Output channels to tell the downstream subworkflows which indexes are missing
    // (therefore, only meta is available)
    no_csi = tabix_selector.no_tabix.map { meta, _bed -> meta }
    no_tbi = tabix_selector.only_csi.mix(tabix_selector.no_tabix).map { meta, _bed -> meta }

    // Do the indexing on the compatible Fasta files
    ch_indexed_bed_csi = TABIX_TABIX_CSI(tabix_selector.tbi_and_csi.mix(tabix_selector.only_csi)).index
    ch_indexed_bed_tbi = TABIX_TABIX_TBI(tabix_selector.tbi_and_csi).index

    emit:
    bed_gz   = ch_compressed_bed // path: genome.bed.gz
    bed_csi  = ch_indexed_bed_csi // path: genome.bed.gz.csi
    bed_tbi  = ch_indexed_bed_tbi // path: genome.bed.gz.tbi
    no_csi   = no_csi // (only meta)
    no_tbi   = no_tbi // (only meta)
}
