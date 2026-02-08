// Module that parses an NCBI assembly report and outputs a table
// mapping sequence accessions with their names
process BUILD_ACC_TABLE {
    tag "${meta.id}"
    label 'process_single'

    conda "conda-forge::gawk=5.1.0"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/gawk:5.1.0'
        : 'biocontainers/gawk:5.1.0'}"

    input:
    tuple val(meta), path(report)

    output:
    tuple val(meta), path(filename_table), emit: table
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    filename_table = "${prefix}.name_mapping.tsv"

    """
    awk '
    BEGIN {
        OFS = "\\t";
        IFS = "\\t";
    }
    /^[^#]/ {
        genbank = \$5
        name = \$1
        if (\$2 == "assembled-molecule") {
            chrom = \$3
        } else {
            chrom = ""
        }
        if ((\$6 == "=") && (\$7 != "na")) {
            refseq = \$7
        } else {
            refseq = ""
        }
        print genbank, name, chrom, refseq
    }
    ' ${report} > ${filename_table}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        GNU Awk: \$(echo \$(awk --version 2>&1) | grep -i awk | sed 's/GNU Awk //; s/,.*//')
    END_VERSIONS
    """
}
