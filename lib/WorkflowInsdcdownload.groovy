//
// This file holds several functions specific to the workflow/insdcdownload.nf in the sanger-tol/insdcdownload pipeline
//

import nextflow.Nextflow

class WorkflowInsdcdownload {

    //
    // Check and validate parameters
    //
    public static void initialise(params, log) {

        // Check input has been provided
        if (params.input) {
            def f = new File(params.input);
            if (!f.exists()) {
                Nextflow.error "'${params.input}' doesn't exist"
            }
        } else {
            if (!params.assembly_accession || !params.assembly_name) {
                Nextflow.error "Either --input, or --assembly_accession and --assembly_name must be provided"
            }
        }
        if (!params.outdir) {
            Nextflow.error "--outdir is mandatory"
        }
    }

}
