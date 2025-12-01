// Module that parses an NCBI assembly and assembly report and outputs
// a SAM header template
process BUILD_SAM_HEADER {
    tag "${meta.id}"
    label 'process_single'

    conda "conda-forge::gawk=5.1.0"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/gawk:5.1.0' :
        'biocontainers/gawk:5.1.0'}"

    input:
    tuple val(meta), path(dict), path(report), path(source)

    output:
    tuple val(meta), path(filename_header), emit: header
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    filename_header = "${prefix}.header.sam"

    // Use the supplied speciesRegex or default if not provided
    def speciesRegex = task.ext.speciesRegex ?: '# Organism name:\s*([^\\(]*)\s*(.*)'

    """
    sourcePath=\$(cat $source | tr -d '\\n')
    genBankAccession=\$(awk '/^# GenBank assembly accession:/ { gsub("\\r", ""); print \$NF }' $report)

    duplicate_found=0

    awk -v species_regex='$speciesRegex' -v genBankAccession=\$genBankAccession -v sourcePath=\$sourcePath -v duplicate_found="duplicate_found" '
    BEGIN {
        OFS = "\\t";
        IFS = "\\t";
        AS = "AS:" genBankAccession;
        species_name = "";
    }
    NR == FNR {
        if (\$0 ~ /^# Organism name:/) {
            match(\$0, species_regex, arr);
            species_name = arr[1];
        }
        if (\$0 !~ /^#/) {
            split(\$0, fields, "\\t");
            if (fields[2] == "assembled-molecule") {
                lookup[fields[5]] = fields[3];
            } else {
                lookup[fields[5]] = fields[1];
            }
        }
        next;
    }
    /^@HD/ {
        print;
        next;
    }
    /^@SQ/ {
        split(\$0, fields, "\\t");
        sn = "";
        for (i in fields) {
            if (fields[i] ~ /^SN:/) {
                split(fields[i], sn_field, ":");
                sn = sn_field[2];
            }
            if (fields[i] ~ /^UR:/) {
                fields[i] = "UR:" sourcePath;
            }
        }
        if (sn in lookup) {
            new_field = "AN:" lookup[sn];
        }
        new_sp = "SP:" species_name;
        print join(fields, OFS), AS, new_field, new_sp;
        next;
    }
    {
        print;
    }
    function join(arr, sep) {
        result = arr[1];
        for (i = 2; i <= length(arr); i++) {
            result = result sep arr[i];
        }
        return result;
    }
    ' $report $dict > $filename_header

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        GNU Awk: \$(echo \$(awk --version 2>&1) | grep -i awk | sed 's/GNU Awk //; s/,.*//')
    END_VERSIONS
    """
}
