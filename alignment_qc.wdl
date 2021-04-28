version 1.0

import "tasks/picard.wdl" as picard
import "tasks/samtools.wdl" as samtools
import "tasks/mosdepth.wdl" as mosdepth

workflow CrbamMetrics {
    input {
        Array[File] crbam_files
        String outdir = "."
        File fasta = "gs://cpg-reference/hg38/v0/Homo_sapiens_assembly38.fasta"
        File fastadict = "gs://cpg-reference/hg38/v0/Homo_sapiens_assembly38.dict"
        File fastafai = "gs://cpg-reference/hg38/v0/Homo_sapiens_assembly38.fasta.fai"
        Boolean collectAlignmentSummaryMetrics = true
        Boolean collectInsertSizeMetrics = true
        Boolean qualityScoreDistribution = true
        Boolean meanQualityByCycle = true
        Boolean collectBaseDistributionByCycle = true
        Boolean collectGcBiasMetrics = true
        Boolean collectSequencingArtifactMetrics = true
        Boolean collectQualityYieldMetrics = true

    }

    scatter (crbam in crbam_files) {

        Boolean is_bam = basename(crbam, ".bam") + ".bam" == basename(crbam)
        String bname = if is_bam then basename(crbam, ".bam") else basename(crbam, ".cram")
        String prefix = outdir + "/" + bname

        call samtools.Flagstat as Flagstat {
            input:
                crbam = crbam,
                outpath = prefix + ".flagstat.txt"
        }

        call mosdepth.Mosdepth as Mosdepth {
            input:
                crbam = crbam,
                prefix = prefix,
                fasta = fasta,
                fastadict = fastadict,
                fastafai = fastafai
        }

        call picard.CollectMultipleMetrics as picardMetrics {
            input:
                crbam = crbam,
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
    }
}
