process MASKING_TO_BED {
    tag "${genome.baseName}"
    label 'process_single'

    conda (params.enable_conda ? "conda-forge::python=3.9.1" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.9--1' :
        'quay.io/biocontainers/python:3.9--1' }"

    input:
    tuple val(meta), path(genome)

    output:
    tuple val(meta), path("*.bed"), emit: bed
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    masking_to_bed.py $genome > ${prefix}.bed

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        masking_to_bed: c9745041e9512d9531efc1f470f8bd01
    END_VERSIONS
    """
}
