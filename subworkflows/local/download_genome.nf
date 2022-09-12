//
// Download all the files from the NCBI
//

include { NCBI_DOWNLOAD           } from '../../modules/local/ncbi_download'
include { REMOVE_MASKING          } from '../../modules/local/remove_masking'


workflow DOWNLOAD_GENOME {

    take:
    inputs  // maps that indicate what to download (straight from the samplesheet)


    main:
    ch_versions = Channel.empty()

    ch_assembly_params  = inputs.map { [
                                it["assembly_accession"],
                                it["assembly_name"],
                                it["species_dir"],
                            ] }
    ch_masked_fasta     = NCBI_DOWNLOAD ( ch_assembly_params ).fasta
    ch_versions         = ch_versions.mix(NCBI_DOWNLOAD.out.versions)
    // Fix meta.id
    ch_masked_fasta_id  = ch_masked_fasta.map { [it[0] + [id: it[0]["id"] + ".masked.ncbi"], it[1]] }

    // Unmask the genome fasta as it is masked by default
    ch_unmasked_fasta   = REMOVE_MASKING ( ch_masked_fasta ).fasta
    ch_versions         = ch_versions.mix(REMOVE_MASKING.out.versions)


    emit:
    fasta_unmasked  = ch_unmasked_fasta         // path: genome.unmasked.fa
    fasta_masked    = ch_masked_fasta_id        // path: genome.masked.ncbi.fa
    versions        = ch_versions.ifEmpty(null) // channel: [ versions.yml ]
}
