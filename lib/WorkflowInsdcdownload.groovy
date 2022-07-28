//
// This file holds several functions specific to the workflow/insdcdownload.nf in the sanger-tol/insdcdownload pipeline
//

class WorkflowInsdcdownload {

    //
    // Check and validate parameters
    //
    public static void initialise(params, log) {

        if (!params.assembly_accession) {
            log.error "Assemly accession (GCA_*) not specified with e.g. '--assembly_accession GCA_XXXXXX.X' or via a detectable config file."
            System.exit(1)
        }
        if (!params.assembly_name) {
            log.error "Assemly name not specified with e.g. '--assembly_name <str>' or via a detectable config file."
            System.exit(1)
        }
    }

}
