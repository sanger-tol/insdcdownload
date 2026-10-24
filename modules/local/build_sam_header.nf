// Module that parses an NCBI assembly and assembly report and outputs
// a SAM header template
process BUILD_SAM_HEADER {
    tag "${meta.id}"
    label 'process_single'

    conda "conda-forge::gawk=5.3.1"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/gawk:5.3.1'
        : 'biocontainers/gawk:5.3.1'}"

    input:
    tuple val(meta), path(dict), path(report)

    output:
    tuple val(meta), path(filename_header), emit: header
    tuple val("${task.process}"), val('BUILD_SAM_HEADER'), eval('echo 1.0'), topic: versions
    tuple val("${task.process}"), val('gawk'), eval('gawk --version | grep -o -E "[0-9]+(.[0-9]+)+" | head -n1'), topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    filename_header = "${prefix}.header.sam"

    // Use the supplied speciesRegex or default if not provided
    def speciesRegex = task.ext.speciesRegex ?: '# Organism name:\s*([^(]*)\s*(.*)'

    """
    genBankAccession=\$(awk '/^# GenBank assembly accession:/ { gsub("\\r", ""); print \$NF }' ${report})

    awk -v species_regex='${speciesRegex}' -v genBankAccession=\$genBankAccession '
    BEGIN {
        OFS = "\\t";
        FS = "\\t";
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
                lookup[fields[5]] = fields[1] "," fields[3];
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

        out = fields[1];
        sn = "";
        for (i = 2; i <= length(fields); i++) {
            # skip UR: fields
            if (fields[i] ~ /^UR:/) continue;
            if (fields[i] ~ /^SN:/) {
                split(fields[i], sn_field, ":");
                sn = sn_field[2];
            }
            out = out OFS fields[i];
        }

        # Optional AN: only when SN exists and maps in lookup
        if (sn != "" && (sn in lookup)) {
            out = out OFS "AN:" lookup[sn];
        }

        # Always add AS: and SP:
        out = out OFS AS OFS "SP:" species_name;

        print out;
        next;
    }
    {
        print;
    }
    ' ${report} ${dict} > ${filename_header}
    """
}
