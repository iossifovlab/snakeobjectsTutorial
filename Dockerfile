FROM condaforge/mambaforge:latest
LABEL io.github.snakemake.containerized="true"
LABEL io.github.snakemake.conda_env_hash="fe542b9df7e11b49d62c249267965095235950f401f52492ba8fafe38e83e695"

# Step 1: Retrieve conda environments

# Conda environment:
#   source: workflow/env-bwa.yaml
#   prefix: /conda-envs/a2df1b4c49e9aebb091721e0f785660b
#   channels:
#     - bioconda
#   dependencies:
#     - samtools 
#     - bwakit
RUN mkdir -p /conda-envs/a2df1b4c49e9aebb091721e0f785660b
COPY workflow/env-bwa.yaml /conda-envs/a2df1b4c49e9aebb091721e0f785660b/environment.yaml

# Conda environment:
#   source: workflow/env-pysam.yaml
#   prefix: /conda-envs/8df341d8f17607c24e6c2e67dd928d39
#   channels:
#     - bioconda
#   dependencies:
#     - pysam
#     - numpy
#     - pandas
RUN mkdir -p /conda-envs/8df341d8f17607c24e6c2e67dd928d39
COPY workflow/env-pysam.yaml /conda-envs/8df341d8f17607c24e6c2e67dd928d39/environment.yaml

# Step 2: Generate conda environments

RUN mamba env create --prefix /conda-envs/a2df1b4c49e9aebb091721e0f785660b --file /conda-envs/a2df1b4c49e9aebb091721e0f785660b/environment.yaml && \
    mamba env create --prefix /conda-envs/8df341d8f17607c24e6c2e67dd928d39 --file /conda-envs/8df341d8f17607c24e6c2e67dd928d39/environment.yaml && \
    mamba clean --all -y

FROM snakeobjects

WORKDIR /workdir

# copy workflow and create the ENTRYPOINT:
COPY . /workdir

RUN echo "conda init bash" >> ~/.bashrc
RUN echo "conda activate snakeobjects" >> ~/.bashrc
RUN echo "export PATH=/workdir/workflow:$PATH" >> ~/.bashrc
ENV PATH /opt/conda/envs/snakeobjects/bin:${PATH}

ENTRYPOINT ["conda", "run", "-n", "snakeobjects", "/bin/bash", "-c"]
CMD ["./run.sh"]
