import pandas as pd
from pathlib import Path
from collections import defaultdict

def run(proj, OG):
    fastqDir = proj.parameters['fastqDir']
    fastqs = pd.read_table(proj.parameters["fastqsFile"], sep='\t', header=0)

    OG.add('reference','o', {'chrAll.fa':proj.parameters['chrAllFile']})

    for i, r in fastqs.iterrows():
        suffix = "/"+r['flowcell']+"/"+r['lane']+"/"+f"bc{r['barcode']}_R1.fastq.gz"
        OG.add('fastq', 
                ".".join([r['flowcell'],r['lane'],r['barcode']]),
                {
                    'R1':       fastqDir+suffix,
                    'R2':       fastqDir+suffix,
                    'sampleId': r['individual']
                },
                OG['reference']
             )
    OG.add('fastqSummary','o',deps=OG['fastq'])

    sampleFastqOs = defaultdict(list)
    for o in OG['fastq']:
        sampleFastqOs[o.params['sampleId']].append(o) 
    for smId,fqOs in sampleFastqOs.items():
        OG.add('sample',smId,deps=fqOs)

    OG.add('sampleSummary','o',deps=OG['sample'])

    ped = pd.read_table(proj.parameters["pedigree"], sep='\t', header=0)
    for i, r in ped.iterrows():
        if r['fatherId'] == '.' or r['motherId'] == '.': continue
        if not set([r['fatherId'],r['motherId'],r['personId']]).issubset(set(sampleFastqOs)): continue
        OG.add('trio',r['personId'], {"familyId":r['familyId'],"sex":r['sex'],"affected":r['affected'] }, [
                    OG['sample',r['fatherId']],
                    OG['sample',r['motherId']],
                    OG['sample',r['personId']]
                ])
    OG.add('trioSummary','o',deps=OG['trio'])
    
