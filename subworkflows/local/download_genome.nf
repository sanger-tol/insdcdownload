//
// Download all the files from the NCBI
//

include { NCBI_DOWNLOAD           } from '../../modules/local/ncbi_download'
include { REMOVE_MASKING          } from '../../modules/local/remove_masking'


workflow DOWNLOAD_GENOME {

    take:
    assembly_accession  // val: GCA_927399515.1
    assembly_name       // val: gfLaeSulp1.1
    species_dir         // /lustre/scratch124/tol/projects/darwin/data/insects/Vanessa_atalanta


    main:
    ch_versions = Channel.empty()

    ch_masked_fasta     = NCBI_DOWNLOAD ( assembly_accession, assembly_name, species_dir ).fasta
    ch_versions         = ch_versions.mix(NCBI_DOWNLOAD.out.versions)

    // Unmask the genome fasta as it is masked by default
    ch_unmasked_fasta   = REMOVE_MASKING ( ch_masked_fasta ).fasta
    ch_versions         = ch_versions.mix(REMOVE_MASKING.out.versions)

    emit:
    fasta_unmasked  = ch_unmasked_fasta         // path: genome.unmasked.fasta
    fasta_masked    = ch_masked_fasta.map { [it[0] + [id: it[0]["id"] + ".masked.ncbi"], it[1]] }  // path: genome.unmasked.fasta
    versions        = ch_versions.ifEmpty(null) // channel: [ versions.yml ]
}
