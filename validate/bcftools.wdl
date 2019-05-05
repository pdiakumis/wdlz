version 1.0

task querysamplenames {
  input {
    File in_file
    String prefix
  }

  command {
    # outputs list of VCF sample names - doesn't require .tbi
    ( bcftools query -l ~{in_file} && echo "ok" || echo "fail" ) > ~{prefix}.query_sn.txt 2>&1
  }

  output {
    File out_file = "~{prefix}.query_sn.txt"
  }

  runtime {
    docker: "quay.io/biocontainers/bcftools:1.9--ha228f0b_3"
    memory: "3GB"
    cpu: 1
  }
}

