version 1.0

task isec {
  input {

    File vcf1
    File vcf2
    # indices required
    File vcf1_tbi = vcf1 + ".tbi"
    File vcf2_tbi = vcf2 + ".tbi"
    String outdir # woof/final/bcftools_isec/<vcf_type>/<all-or-pass>
  }

  command {
    conda activate woof
    bcftools isec ~{vcf1} ~{vcf2} -p ~{outdir}
  }

  output {
    File false_pos = "~{outdir}/0000.vcf"
    File false_neg = "~{outdir}/0001.vcf"
    File true_pos = "~{outdir}/0002.vcf"
  }
}

task filter_pass {
    input {
        File vcf_in
        String outdir # woof/final/vcf_pass/<f1-or-f2>/<vcf_type>
        String vcf_out = outdir + "_PASS.vcf.gz"
    }

    command {
        conda activate woof

        mkdir -p $(dirname ~{outdir})

        # include only header; exclude Header, keep only variants with . or PASS FILTER,
        # sort by CHROM and POS (-V = like mixedsort), bgzip to stdout
        (bcftools view -h ~{vcf_in} ; bcftools view -H -f .,PASS ~{vcf_in} | sort -k1,1V -k2,2n) | \
        bgzip -c > ~{vcf_out} && tabix -f -p vcf ~{vcf_out}
    }

    output {
        File out = "~{vcf_out}"
        File out_tbi = "~{vcf_out}.tbi"
    }
}

