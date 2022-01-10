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

/*
 * Create channels for sequences data
 */
Channel
 .fromFilePairs( params.reads , size: ("${params.reads}" =~ /\{/) ? 2 : 1)
 .ifEmpty { error "Cannot find any reads matching: ${params.reads}" }
 .set { read_files }

/*
 * Extract read length
*/
// process getReadLength {
//   input:
//   file(single_read_pairs) from read_files_for_size
//
//   output:
//   stdout into (read_length_for_bracken)
//
// 	script:
// 	"""
//         if [ `echo ${single_read_pairs} | grep "gz"` ]; then cat="zcat"; else cat="cat"; fi
//         \$cat ${single_read_pairs} | awk '{num++}{if (num%4==2){line++; sum+=length(\$0)} if (line==100) {printf "%.0f", sum/100; exit} }'
// 	"""
// }
//
// if (params.bracken == "YES") {
//
//   process brackenFormat {
//
//     maxForks 1
//
//     publishDir params.brackendb, mode: 'copy'
//
//     label 'brackenFormat'
//
//     input:
//     val read_size from read_length_for_bracken.unique().map { it.trim().toInteger() }
//
//     output:
//     file("database.kraken") into bracken_database1
//     file("database${read_size}mers.kraken") into bracken_database2
//     file("database${read_size}mers.kmer_distrib") into bracken_database3
//     file("out${read_size}") into brackenFormat_out
//
//     script:
//     """
//       if [ -f "${params.brackendb}/database.kraken" ]; then
//         ln -s "${params.brackendb}/database.kraken" .
//       else
//         kraken2 --db=${params.kraken2db} --threads=${task.cpus} <( find -L ${params.kraken2db}/library \\( -name "*.fna" -o -name "*.fasta" -o -name "*.fa" \\) -exec cat {} + ) > database.kraken
//       fi
//       if [ -f "${params.brackendb}/database${read_size}mers.kmer_distrib}" ]; then
//         ln -s "${params.brackendb}/database${read_size}mers.kraken" .
//         ln -s "${params.brackendb}/database${read_size}mers.kmer_distrib" .
//         touch out${read_size}
//       else
//         /usr/local/bracken/src/kmer2read_distr --seqid2taxid ${params.kraken2db}/seqid2taxid.map --taxonomy ${params.kraken2db}/taxonomy --kraken database.kraken --output database${read_size}mers.kraken -l ${read_size} -t ${task.cpus}
//         python /usr/local/bracken/src/generate_kmer_distribution.py -i database${read_size}mers.kraken -o database${read_size}mers.kmer_distrib > out${read_size}
//       fi
//     """
//
//   }
//
//   process bracken {
//
//     publishDir output+"/${pair_id}", mode: 'copy'
//
//     input:
//     file("kraken2_${pair_id}.report") from kraken2_report
//     file("kraken2_${pair_id}.out") from kraken2_output
//     set pair_id, file(reads) from (read_files_for_kraken2_2)
//     file "out*" from brackenFormat_out.collect()
//
//     output:
//     file "bracken_${pair_id}.*.report" into bracken_report
//     file "bracken_${pair_id}.*.out" into bracken_out
//     file "kraken2_${pair_id}_bracken_species.report" into bracken_default_report
//
//     script:
//     """
//     FIRST=\$(echo ${reads} | head -n1 | awk '{print \$1;}')
//     if [ `echo \$FIRST | grep "gz"` ]; then cat="zcat"; else cat="cat"; fi
//     READSIZE=\$(\$cat \$FIRST | awk '{num++}{if (num%4==2){line++; sum+=length(\$0)} if (line==100) {printf "%.0f", sum/100; exit} } ')
//     bracken -d ${params.brackendb} -i kraken2_${pair_id}.report -o bracken_${pair_id}.\${READSIZE}.report -r \$READSIZE -l S -t ${task.cpus} > bracken_${pair_id}.\${READSIZE}.out
//     """
//
//   }
//
// }

workflow {

  KRAKEN2(read_files, params.database)

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
