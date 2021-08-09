add_targets("pairNumber.txt")

from snakemake.remote.HTTP import RemoteProvider as HTTPRemoteProvider
HTTP = HTTPRemoteProvider()

rule countReads:
    input:
      lambda wc: HTTP.remote(EF("[P:R1]")(wc)),
      lambda wc: HTTP.remote(EF("[P:R2]")(wc))
    output: T("pairNumber.txt")
    run:
        import gzip
        nPairs= 0
        buff = []
        with gzip.open(input[0]) as R1F, gzip.open(input[1]) as R2F:
          for l1,l2 in zip(R1F,R2F):
                buff.append((l1,l2))
                if len(buff) == 4:
                    nPairs += 1
                    buff = []
        
        with open(output[0],"w") as OF:
            OF.write(f'{wildcards.oid}\t{nPairs}\n')

add_targets("fastq.bam")

rule align:
    input:
        DT("chrAll.fa.fai"),
	DT("chrAll.fa.bwt"),
	DT("chrAll.fa.pac"),
	DT("chrAll.fa.ann"),DT("chrAll.fa.amb"),
	DT("chrAll.fa.sa"),
        refFile       = DT("chrAll.fa"),
        refFileBwaIdx = DT("chrAll.bwaIndex.flag"),
	R1File        = lambda wc: HTTP.remote(EF("[P:R1]")(wc)),
        R2File        = lambda wc: HTTP.remote(EF("[P:R2]")(wc))	
    output:
        T("fastq.bam")
    params:
        sId = P('sampleId')
    conda: "env-bwa.yaml"
    resources: 
        mem_mb = 5*1024
    threads: 5
    log: **LFS('align')    
    shell:
        "(time bwa mem -t {threads}                                        \
              -R '@RG\\tID:{wildcards.oid}\\tSM:{params.sId}'              \
              {input.refFile} {input.R1File} {input.R2File} 2> {log.E} |   \
               samtools view -Sb - > {output} ) 2> {log.T}"
