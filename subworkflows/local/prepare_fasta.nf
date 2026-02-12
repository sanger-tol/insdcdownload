//
// Prepare all the indexes for a Fasta file
//

include { SAMTOOLS_FAIDX } from '../../modules/nf-core/samtools/faidx/main'
include { TABIX_BGZIP    } from '../../modules/nf-core/tabix/bgzip/main'


workflow PREPARE_FASTA {
    take:
    fasta // file: /path/to/genome.fa

    main:

    // Compress the Fasta file
    ch_compressed_fasta = TABIX_BGZIP(fasta).output

    // Generate Samtools index and chromosome sizes file
    ch_samtools_faidx = SAMTOOLS_FAIDX(ch_compressed_fasta, [[], []], true).fai

    // Read the .fai file, extract sequence statistics, and make an extended meta map
    sequence_map = ch_samtools_faidx.map { meta, fai ->
        [meta, meta + get_sequence_map(fai)]
    }
    // Update all channels to use the extended meta map
    fasta_gz = ch_compressed_fasta.join(sequence_map).map { _meta, path, extended_meta -> [extended_meta, path] }
    faidx = ch_samtools_faidx.join(sequence_map).map { _meta, path, extended_meta -> [extended_meta, path] }
    gzi = SAMTOOLS_FAIDX.out.gzi.join(sequence_map).map { _meta, path, extended_meta -> [extended_meta, path] }
    sizes = SAMTOOLS_FAIDX.out.sizes.join(sequence_map).map { _meta, path, extended_meta -> [extended_meta, path] }

    emit:
    fasta_gz = fasta_gz // path: genome.fa.gz
    faidx    = faidx // path: genome.fa.gz.fai
    gzi      = gzi // path: genome.fa.gz.gzi
    sizes    = sizes // path: genome.fa.gz.sizes
}

// Read the .fai file to extract the number of sequences, the maximum and total sequence length
// Inspired from https://github.com/nf-core/rnaseq/blob/3.10.1/lib/WorkflowRnaseq.groovy
def get_sequence_map(fai_file) {
    def n_sequences = 0
    def max_length = 0
    def total_length = 0
    fai_file.eachLine { line ->
        def lspl = line.split('\t')
        // def chrom  = lspl[0]
        def length = lspl[1].toLong()
        n_sequences += 1
        total_length += length
        if (length > max_length) {
            max_length = length
        }
    }

    def sequence_map = [:]
    sequence_map.n_sequences = n_sequences
    sequence_map.total_length = total_length
    if (n_sequences) {
        sequence_map.max_length = max_length
    }
    return sequence_map
}
