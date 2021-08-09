This repository contains workflow for snakeobjectsTutorial example.
The directory structure is

.
├── README.md
├── allDenovoCalls.txt
├── fastqs-small.txt
├── so_project.yaml
└── workflow
    ├── __pycache__
    │   └── build_object_graph.cpython-39.pyc
    ├── build_object_graph.py
    ├── call_denovo.py
    ├── env-bwa.yaml
    ├── env-pysam.yaml
    ├── environment.yml
    ├── fastq.snakefile
    ├── fastqSummary.snakefile
    ├── reference.snakefile
    ├── reference.snakefile~
    ├── sample.snakefile
    ├── sampleSummary.snakefile
    ├── trio.snakefile
    └── trioSummary.snakefile

README.md - this file
fastqs-small.txt      - a subset for individuals for testing workflow
so_project.yaml       - configuration file for the project
allDenovoCalls.txt    - results to thest against the run with fastqs-small.txt
build_object_graph.py - a python script creating OG.json and workflow/Snakefile
*.snakefile - snakefiles for different type objects in the project
environment.yaml      - is global environment for the project
env-pysam.yml and env-bwa.yml - environment for individual rules in snakefile

Installation and usage

Prequisite: conda.

First, clone the repository to a local directory

git clone https://github.com/iossifovlab/snakeobjectsTutorial.git

After cloning repository type:

cd snakeobjectsTutorial
conda env create -f workflow/environment.yml
conda activate snakeobjectsTuroria

Familiarize yourself with sobjects commands by typing 'sobjects help.'

Typical sequence of command:
sobjects describe
sobjects prepare
sobjects run [<args>]

More details of sobjects can be found in https://snakeobjects.readthedocs.io/en/latest/

content of the so_project.yaml:

default_snakemake_args: "--use-conda"
inputDir:   "https://raw.githubusercontent.com/iossifovlab/snakeobjectsTutorialInput/main"
fastqDir:   "https://raw.githubusercontent.com/iossifovlab/snakeobjectsTutorialInput/main/fastq"
chrAllFile: "[PP:inputDir]/chrAll.fa"
target:     "[PP:inputDir]/targetRegions.bed"
pedigree:   "[PP:inputDir]/collection.ped"
#
# For testing uncomment the line with fastqs-small.txt
# For full 100 families uncomment the line with fastqs.txt
#
#
fastqsFile: "[D:project]/fastqs-small.txt"
#fastqsFile: "[PP:inputDir]/fastqs.txt"

The first line indicates that sobjects will run snakemake with --use-conda option, since some rules require software tools not included in the main environment.yaml

The next two lines specify location for the main input directory for the input data and subdirectory with fastq data files

chrAllFile variable stores the location of a fasta file.
Since the fastq files are created for exome capture, the target variable stores
bed file specifying exome regions.
pedigree variable links sample ids with appropriate flowcells, lanes, and barcodes.

Running fastqs-small.txt subset of individuals takes about two minutes on mac bookAir. The full 100 families should take less than one hour.

