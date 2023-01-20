//
// This file holds several functions specific to the workflow/insdcdownload.nf in the sanger-tol/insdcdownload pipeline
//

class WorkflowInsdcdownload {

    //
    // Check and validate parameters
    //
    public static void initialise(params, log) {

        // Check input has been provided
        if (params.input) {
            def f = new File(params.input);
            if (!f.exists()) {
                log.error "'${params.input}' doesn't exist"
                System.exit(1)
            }
        } else {
            if (!params.assembly_accession || !params.assembly_name) {
                log.error "Either --input, or --assembly_accession and --assembly_name must be provided"
                System.exit(1)
            }
        }
        if (!params.outdir) {
            log.error "--outdir is mandatory"
            System.exit(1)
        }
    }

}
