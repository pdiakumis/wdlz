version 1.0

task count_vars {

    input {
        File vcf
        File vcf_tbi = vcf + ".tbi"
        String outdir # woof/final/vcf_counts/<f1-or-f2>/<vcf-typeX>/<all-or-pass>/
        String txt = outdir + "count_vars.txt"
    }

    command {
        mkdir -p ~{outdir}
        gunzip -c ~{vcf} | grep -v "^#" | wc -l > ~{txt}
    }

    output {
        File out = "~{txt}"
    }
}

