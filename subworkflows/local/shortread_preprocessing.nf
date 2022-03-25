//
// Check input samplesheet and get read channels
//


include { SHORTREAD_FASTP             } from './shortread_fastp'
include { FASTQC as FASTQC_PROCESSED       } from '../../modules/nf-core/modules/fastqc/main'

workflow SHORTREAD_PREPROCESSING {
    take:
    reads // file: /path/to/samplesheet.csv

    main:
    ch_versions       = Channel.empty()
    ch_multiqc_files  = Channel.empty()

    //
    // STEP: Read clipping and merging
    //
    // TODO give option to clip only and retain pairs
    // TODO give option to retain singletons (probably fastp option likely)
    // TODO move to subworkflow

    if ( params.shortread_clipmerge_tool == "fastp" ) {
        ch_processed_reads = SHORTREAD_FASTP ( reads ).reads
        ch_versions        =  ch_versions.mix( SHORTREAD_FASTP.out.versions )
        ch_multiqc_files   =  ch_multiqc_files.mix( SHORTREAD_FASTP.out.mqc )
    } else {
        ch_processed_reads = reads
    }

    FASTQC_PROCESSED ( ch_processed_reads )
    ch_versions = ch_versions.mix( FASTQC_PROCESSED.out.versions )
    ch_multiqc_files = ch_multiqc_files.mix( FASTQC_PROCESSED.out.zip.collect{it[1]} )

    emit:
    reads    = ch_processed_reads   // channel: [ val(meta), [ reads ] ]
    versions = ch_versions          // channel: [ versions.yml ]
    mqc      = ch_multiqc_files
}

