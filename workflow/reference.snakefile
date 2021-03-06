add_targets("chrAll.bwaIndex.flag", "chrAll.fa", "chrAll.fa.fai","chrAll.fa.bwt","chrAll.fa.pac","chrAll.fa.ann","chrAll.fa.amb","chrAll.fa.sa")

from snakemake.remote.HTTP import RemoteProvider as HTTPRemoteProvider
HTTP = HTTPRemoteProvider()

rule copyChrAll:
    input: HTTP.remote(PP("chrAllFile"))
    output: T("chrAll.fa"), T("chrAll.fa.fai")
    conda: "env-bwa.yaml"
    shell: "cp {input[0]} {output[0]} && samtools faidx {output[0]}"

rule makeBwaIndex:
    input: T("chrAll.fa"),T("chrAll.fa.fai")
    output:
      touch(T("chrAll.bwaIndex.flag")),
      T("chrAll.fa.bwt"),
      T("chrAll.fa.pac"),
      T("chrAll.fa.ann"),
      T("chrAll.fa.amb"),
      T("chrAll.fa.sa")
    conda: "env-bwa.yaml"
    resources: mem_mb=10*1024
    log: **LFS("bwa_index")
    shell: "(time bwa index {input[0]} -a bwtsw > {log.O} 2> {log.E} ) 2> {log.T}"
