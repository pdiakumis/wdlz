version 1.0

task quickcheck {
  input {
    File in_file
    String prefix
  }

  command {
    ( samtools quickcheck -q ~{in_file} && echo "ok" || echo "fail" ) > ~{prefix}.quickcheck.txt 2>&1
  }

  output {
    File out_file = "~{prefix}.quickcheck.txt"
  }

  runtime {
    docker: "quay.io/biocontainers/samtools:1.9--h8571acd_11"
    memory: "3GB"
    cpu: 1
  }
}

