#!/usr/bin/env nextflow


/*
 * Copyright (c) 2020-2022, Centre for Genomic Regulation (CRG)
 *
 */


/*
===========================================================
Contamination and Metagenomics pipeline from Bioinformatics Core @ CRG

 @authors
 Toni Hermoso Pulido <toni.hermoso@crg.eu>
===========================================================
*/

nextflow.enable.dsl=2

version = '0.1'

/*
 * Input parameters: read pairs, db fasta file, etc
 */

params.help            = false
params.resume          = false

log.info """
Biocore Contamination and Metagenomics pipeline  ~  version ${version}

====================================================
reads                       : ${params.reads}
protocol                    : ${params.protocol}
bracken                     : ${params.bracken}
brackendb                   : ${params.brackendb}
kraken2db                   : ${params.kraken2db}
output (output folder)      : ${params.output}
email for notification      : ${params.email}
"""

if (params.help) {
    log.info 'This is the Biocore\'s Contamination and Metagenomics pipeline'
    log.info '\n'
    exit 1
}


if (params.resume) exit 1, "Are you making the classical --resume typo? Be careful!!!! ;)"

def subworkflowsDir = "${baseDir}/BioNextflow/subworkflows"

include { RUN as KRAKEN2 } from "${subworkflowsDir}/metagenomics/kraken2" addParams(OUTPUT: params.output)
include { BUILD as KRAKEN2_BUILD } from "${subworkflowsDir}/metagenomics/kraken2" addParams(OUTPUT: params.output)
include { RUN as BRACKEN } from "${subworkflowsDir}/metagenomics/bracken" addParams(OUTPUT: params.output)
include { BUILD as BRACKEN_BUILD } from "${subworkflowsDir}/metagenomics/bracken" addParams(OUTPUT: params.output)


/*
 * Create channels for sequences data
 */
Channel
 .fromFilePairs( params.reads , size: ("${params.reads}" =~ /\{/) ? 2 : 1)
 .ifEmpty { error "Cannot find any reads matching: ${params.reads}" }
 .set { read_files }


workflow {

  KRAKEN2(read_files, params.kraken2db)

}

workflow build {

  KRAKEN2_BUILD(params.groups, params.dbname)

}

workflow bracken {

  (report, output, classified, unclassified) = KRAKEN2(read_files, params.kraken2db)
  (brackendb, bracken_out) = BRACKEN_BUILD(read_files, params.kraken2db)
  (report_bracken, output_bracken, default_report) = BRACKEN(read_files, brackendb, report, output, bracken_out)

}

/*
 * Mail notification
 */

if (params.email == "yourmail@yourdomain" || params.email == "") {
    log.info 'Skipping the email\n'
}
else {
    log.info "Sending the email to ${params.email}\n"

    workflow.onComplete {

      def msg = """\
        Pipeline execution summary
        ---------------------------
        Completed at: ${workflow.complete}
        Duration    : ${workflow.duration}
        Success     : ${workflow.success}
        workDir     : ${workflow.workDir}
        exit status : ${workflow.exitStatus}
        Error report: ${workflow.errorReport ?: '-'}
        """
        .stripIndent()

        sendMail(to: params.email, subject: "Pipeline execution finished", body: msg )
    }
}

workflow.onComplete {
    println "Pipeline execution completed at: $workflow.complete"
    println "Execution status: ${ workflow.success ? 'OK' : 'failed' }"
}
