version 1.0

task md5sum {
  input {
    File in_file
    String prefix
  }

  command {
    md5sum ~{in_file} > ~{prefix}.md5.txt
  }

  output {
    File out_file = "~{prefix}.md5.txt"
  }

  runtime {
    docker: "ubuntu:latest"
    memory: "3GB"
    cpu: 1
  }
}

