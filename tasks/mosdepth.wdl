version 1.0

task Mosdepth {
    input {
        File crbam
        File ?crbamindex
        String prefix
        File fasta
        File fastadict
        File fastafai
        Int threads = 3
        String dockerImage = "quay.io/biocontainers/mosdepth:0.3.1--h4dc83fb_1"
    }
    Boolean is_bam = basename(crbam, ".bam") + ".bam" == basename(crbam)
    String crbamindex_path = if is_bam then crbam + ".bai" else crbam + ".crai"
    File crbamindex_file = select_first([crbamindex, crbamindex_path])
    # Runtime attributes
    Float disk_overhead = 10.0
    Int vm_disk_size = ceil(size(crbam, "GiB") + size(crbamindex_file, "GiB") + disk_overhead)

    command {
        set -e
        mkdir -p "$(dirname ~{prefix})"
        mosdepth ~{prefix} ~{crbam} \
          --quantize 0:1:10:30:50:75: \
          --no-per-base \
          --fasta ~{fasta} \
          --threads ~{threads}
    }

    runtime {
        docker: dockerImage
        cpu: 4
        memory: "12G"
        disks: "local-disk " + vm_disk_size + " HDD"
        bootDiskSizeGb: 10
        preemptible: 3
        maxRetries: 1
    }

    output {
        File global = prefix + ".mosdepth.global.dist.txt"
        File quantized = prefix + ".quantized.bed.gz"
        File summary = prefix + ".mosdepth.summary.txt"
    }

    parameter_meta {
        crbam: "The input CRAM/BAM file."
        crbamindex: "The index of the input CRAM/BAM file."
        prefix: "The prefix of the output files."
        fasta: "Reference FASTA file used for read mapping."
        fastadict: "The sequence dictionary for the FASTA file."
        fastafai: "The index for the FASTA file."
        threads: "Number of threads to use. Use maximum 4."
        dockerImage: "Docker image."
    }
}
