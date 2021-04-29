version 1.0

import "tasks/picard.wdl" as picard
import "tasks/samtools.wdl" as samtools
import "tasks/mosdepth.wdl" as mosdepth
import "tasks/megadepth.wdl" as megadepth

workflow CrbamMetrics {
    input {
        Array[File] crbam_files
        String outdir = "."
        File fasta
        File fastadict
        File fastafai
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

        call megadepth.Megadepth as Megadepth {
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
                fastafai = fastafai
        }
    }
}
