//
// Download all the files from the NCBI
//

include { UNMASK        } from '../../modules/sanger-tol/unmask/main'
include { NCBI_DOWNLOAD } from '../../modules/local/ncbi_download'


workflow DOWNLOAD_GENOME {
    take:
    assembly_params // tuple(outdir, assembly_name, assembly_accession)

    main:

    // Download assembly
    ch_masked_fasta = NCBI_DOWNLOAD(assembly_params).fasta
    // Fix meta.id
    ch_masked_fasta_id = ch_masked_fasta.map { meta, fasta -> [meta + [id: meta["id"] + ".repeats.ncbi"], fasta] }

    // Unmask the genome fasta as it is masked by default
    ch_unmasked_fasta = UNMASK(ch_masked_fasta).unmasked

    emit:
    fasta_unmasked  = ch_unmasked_fasta // path: genome.unmasked.fa
    fasta_masked    = ch_masked_fasta_id // path: genome.repeats.ncbi.fa
    assembly_report = NCBI_DOWNLOAD.out.assembly_report // path: genome.assembly_report.txt
    assembly_stats  = NCBI_DOWNLOAD.out.assembly_stats // path: genome.assembly_stats.txt
    accession       = NCBI_DOWNLOAD.out.accession // path: ACCESSION (contains accession number)
    source          = NCBI_DOWNLOAD.out.source // path: SOURCE (contains URL)
}
