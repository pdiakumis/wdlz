version 1.0

task CollectMultipleMetrics {
    input {
        File cram
        File cramindex
        File fasta
        File fastadict
        File fastafai
        String prefix
        Boolean collectAlignmentSummaryMetrics = true
        Boolean collectInsertSizeMetrics = true
        Boolean qualityScoreDistribution = true
        Boolean meanQualityByCycle = true
        Boolean collectBaseDistributionByCycle = true
        Boolean collectGcBiasMetrics = true
        Boolean collectSequencingArtifactMetrics = true
        Boolean collectQualityYieldMetrics = true

        Int javaXmxMb = 3072
        String dockerImage = "quay.io/biocontainers/picard:2.23.8--0"
    }
    # Runtime attributes
    Float disk_overhead = 10.0
    Float in_size = size(cram, "GiB")
    Int vm_disk_size = ceil(in_size + disk_overhead)

    command {
        set -e
        mkdir -p "$(dirname ~{prefix})"
        picard -Xmx~{javaXmxMb}M -XX:ParallelGCThreads=1 \
        CollectMultipleMetrics \
        I ~{cram} \
        R ~{fasta} \
        O ~{prefix} \
        PROGRAM null \
        ~{true="PROGRAM CollectAlignmentSummaryMetrics" false="" collectAlignmentSummaryMetrics} \
        ~{true="PROGRAM CollectInsertSizeMetrics" false="" collectInsertSizeMetrics} \
        ~{true="PROGRAM QualityScoreDistribution" false="" qualityScoreDistribution} \
        ~{true="PROGRAM MeanQualityByCycle" false="" meanQualityByCycle} \
        ~{true="PROGRAM CollectBaseDistributionByCycle" false="" collectBaseDistributionByCycle} \
        ~{true="PROGRAM CollectGcBiasMetrics" false="" collectGcBiasMetrics} \
        ~{true="PROGRAM CollectSequencingArtifactMetrics" false="" collectSequencingArtifactMetrics} \
        ~{true="PROGRAM CollectQualityYieldMetrics" false="" collectQualityYieldMetrics}
    }

    output {
        File? alignmentSummary = prefix + ".alignment_summary_metrics"
        File? baseDistributionByCycle = prefix + ".base_distribution_by_cycle_metrics"
        File? baseDistributionByCyclePdf = prefix + ".base_distribution_by_cycle.pdf"
        File? errorSummary = prefix + ".error_summary_metrics"
        File? gcBiasDetail = prefix + ".gc_bias.detail_metrics"
        File? gcBiasPdf = prefix + ".gc_bias.pdf"
        File? gcBiasSummary = prefix + ".gc_bias.summary_metrics"
        File? insertSizeHistogramPdf = prefix + ".insert_size_histogram.pdf"
        File? insertSize = prefix + ".insert_size_metrics"
        File? preAdapterDetail = prefix + ".pre_adapter_detail_metrics"
        File? preAdapterSummary = prefix + ".pre_adapter_summary_metrics"
        File? qualityByCycle = prefix + ".quality_by_cycle_metrics"
        File? qualityByCyclePdf = prefix + ".quality_by_cycle.pdf"
        File? qualityDistribution = prefix + ".quality_distribution_metrics"
        File? qualityDistributionPdf = prefix + ".quality_distribution.pdf"
        File? qualityYield = prefix + ".quality_yield_metrics"
        # Using a glob is easier. But will lead to very ugly output directories.
        Array[File] allStats = select_all([
            alignmentSummary,
            baseDistributionByCycle,
            baseDistributionByCyclePdf,
            errorSummary,
            gcBiasDetail,
            gcBiasPdf,
            gcBiasSummary,
            insertSizeHistogramPdf,
            insertSize,
            preAdapterDetail,
            preAdapterSummary,
            qualityByCycle,
            qualityByCyclePdf,
            qualityDistribution,
            qualityDistributionPdf,
            qualityYield
        ])
    }

    runtime {
        docker: dockerImage
        cpu: 1
        memory: "4G"
        disks: "local-disk " + vm_disk_size + " HDD"
        bootDiskSizeGb: 10
        preemptible: 3
        maxRetries: 1
    }

    parameter_meta {
        cram: "The input CRAM file."
        cramindex: "The index of the input CRAM file."
        fasta: "Reference FASTA file used for read mapping."
        fastadict: "The sequence dictionary for the FASTA file."
        fastafai: "The index for the FASTA file."
        prefix: "The prefix of the output files."
        collectAlignmentSummaryMetrics: "Equivalent to the `PROGRAM=CollectAlignmentSummaryMetrics` argument."
        collectInsertSizeMetrics: "Equivalent to the `PROGRAM=CollectInsertSizeMetrics` argument."
        qualityScoreDistribution: "Equivalent to the `PROGRAM=QualityScoreDistribution` argument."
        meanQualityByCycle: "Equivalent to the `PROGRAM=MeanQualityByCycle` argument."
        collectBaseDistributionByCycle: "Equivalent to the `PROGRAM=CollectBaseDistributionByCycle` argument."
        collectGcBiasMetrics: "Equivalent to the `PROGRAM=CollectGcBiasMetrics` argument."
        collectSequencingArtifactMetrics: "Equivalent to the `PROGRAM=CollectSequencingArtifactMetrics` argument."
        collectQualityYieldMetrics: "Equivalent to the `PROGRAM=CollectQualityYieldMetrics` argument."
        javaXmxMb: "Maximum memory available to the program in megabytes."
        dockerImage: "Docker image."
    }
}
