version 1.0

import "tasks/picard.wdl" as picard
import "tasks/samtools.wdl" as samtools

workflow CramMetrics {
    input {
        File cram
        File cramindex
        String outdir = "."
        File fasta
        File fastadict
        File fastafai
        Boolean collectAlignmentSummaryMetrics = true
        Boolean collectInsertSizeMetrics = true
        Boolean qualityScoreDistribution = true
        Boolean meanQualityByCycle = true
        Boolean collectBaseDistributionByCycle = true
        Boolean collectGcBiasMetrics = true
        Boolean collectSequencingArtifactMetrics = true
        Boolean collectQualityYieldMetrics = true

    }

    String prefix = outdir + "/" + basename(cram, ".cram")

    call samtools.Flagstat as Flagstat {
        input:
            cram = cram,
            outpath = prefix + ".flagstat"
    }

    call picard.CollectMultipleMetrics as picardMetrics {
        input:
            cram = cram,
            cramindex = cramindex,
            prefix = prefix,
            fasta = fasta,
            fastadict = fastadict,
            fastafai = fastafai,
            collectAlignmentSummaryMetrics = collectAlignmentSummaryMetrics,
            collectInsertSizeMetrics = collectInsertSizeMetrics,
            qualityScoreDistribution = qualityScoreDistribution,
            meanQualityByCycle = meanQualityByCycle,
            collectBaseDistributionByCycle = collectBaseDistributionByCycle,
            collectGcBiasMetrics = collectGcBiasMetrics,
            collectSequencingArtifactMetrics = collectSequencingArtifactMetrics,
            collectQualityYieldMetrics = collectQualityYieldMetrics,
    }

    output {
        File flagstat = Flagstat.flagstat
        Array[File] picardMetricsFiles = picardMetrics.allStats
        Array[File] reports = flatten([picardMetricsFiles, [flagstat]])
    }
}
