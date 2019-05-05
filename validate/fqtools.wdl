version 1.0

task fqtools {
  input {
    File in_file
    String prefix
  }

  command {
    ( fqtools validate ~{in_file} || true ) > ~{prefix}.fqtools_validate.txt 2>&1
  }

  output {
    File out_file = "~{prefix}.fqtools_validate.txt"
  }

  runtime {
    docker: "quay.io/biocontainers/fqtools:2.0--hf50d5a6_4"
    memory: "3GB"
    cpu: 1
  }
}

