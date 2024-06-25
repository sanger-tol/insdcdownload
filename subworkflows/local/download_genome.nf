//
// Download all the files from the NCBI
//

include { NCBI_DOWNLOAD           } from '../../modules/local/ncbi_download'
include { REMOVE_MASKING          } from '../../modules/local/remove_masking'


workflow DOWNLOAD_GENOME {

    take:
    assembly_params         // tuple(assembly_accession, assembly_name, outdir)


    main:
    ch_versions = Channel.empty()

    ch_masked_fasta     = NCBI_DOWNLOAD ( assembly_params ).fasta

    // Parse assembly to build header template
    ch_assembly_report  = NCBI_DOWNLOAD.out.assembly_report

    ch_versions         = ch_versions.mix(NCBI_DOWNLOAD.out.versions.first())
    // Fix meta.id
    ch_masked_fasta_id  = ch_masked_fasta.map { [it[0] + [id: it[0]["id"] + ".masked.ncbi"], it[1]] }

    // Unmask the genome fasta as it is masked by default
    ch_unmasked_fasta   = REMOVE_MASKING ( ch_masked_fasta ).fasta
    ch_versions         = ch_versions.mix(REMOVE_MASKING.out.versions.first())


    emit:
    fasta_unmasked  = ch_unmasked_fasta         // path: genome.unmasked.fa
    fasta_masked    = ch_masked_fasta_id        // path: genome.masked.ncbi.fa
    assembly_report = ch_assembly_report        // path: genome.assembly_report.txt
    versions        = ch_versions.ifEmpty(null) // channel: [ versions.yml ]
}
