version 1.0

task BgzipTabix {
    input {
        File invcf
        String outdir
        String dockerImage = "quay.io/biocontainers/htslib:1.12--h9093b5e_"
    }

    String outpath = outdir + "/" + basename(invcf) + ".gz"
    # Runtime attributes
    Float disk_overhead = 10.0
    Float in_size = size(invcf, "GiB")
    Int vm_disk_size = ceil(in_size + disk_overhead)

    command {
        set -e
        mkdir -p "$(dirname ~{outpath})"
        bgzip -c ~{invcf} > ~{outpath}
        tabix -p "vcf" ~{outpath}
    }

    output {
        File outvcf = outpath
        File outvcfindex = outpath + ".tbi"
    }

    runtime {
        docker: dockerImage
        cpu: 1
        memory: "1G"
        disks: "local-disk " + vm_disk_size + " HDD"
        bootDiskSizeGb: 10
        preemptible: 3
        maxRetries: 1
    }

    parameter_meta {
        invcf: "The VCF file to be compressed and indexed."
        outdir: "Directory for output."
        dockerImage: "Docker image."
        outvcf: "Compressed VCF file."
        outvcfindex: "Index of compressed VCF file."
    }
}

task Flagstat {
    input {
        File crbam
        String outpath
        String dockerImage = "quay.io/biocontainers/samtools:1.12--h9aed4be_1"
    }

    # Runtime attributes
    Float disk_overhead = 10.0
    Int vm_disk_size = ceil(size(crbam, "GiB") + disk_overhead)

    command {
        set -e
        mkdir -p "$(dirname ~{outpath})"
        samtools flagstat ~{crbam} > ~{outpath}
    }

    output {
        File flagstat = outpath
    }

    runtime {
        docker: dockerImage
        cpu: 1
        memory: "1G"
        disks: "local-disk " + vm_disk_size + " HDD"
        bootDiskSizeGb: 10
        preemptible: 3
        maxRetries: 1
    }

    parameter_meta {
        crbam: "The input CRAM/BAM file."
        outpath: "Path to output flagstat json file."
        dockerImage: "Docker image."
        flagstat: "Path to output flagstat json file."
    }
}
