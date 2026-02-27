//
// Extract the masked regions from a Fasta file as BED,
// and prepare indexes for it
//

include { MASK_SOFTMASK2BED } from '../../modules/sanger-tol/mask/softmask2bed/main'
include { BGZIPTABIX        } from '../../modules/sanger-tol/bgziptabix/main'


workflow PREPARE_REPEATS {
    take:
    fasta // file: /path/to/genome.fa

    main:

    ch_bed = MASK_SOFTMASK2BED(fasta).bed

    BGZIPTABIX(
        ch_bed.map { meta, bed -> [meta, bed, meta.max_length] }
    )

    ch_repeats = BGZIPTABIX.out.gz_index
        .join(BGZIPTABIX.out.tbi, by: 0, remainder: true)
        .join(BGZIPTABIX.out.csi, by: 0, remainder: true)

    emit:
    repeats = ch_repeats // channel: [ meta, bed.gz, bed.gz.gzi, tbi?, csi? ]
}
