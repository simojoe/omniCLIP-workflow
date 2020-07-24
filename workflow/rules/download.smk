
rule download_chrs:
    """Download the chr sequence files for omniCLIP."""
    output:
        chr = config['paths']['chr']
    params:
        link = config['resources']['ref']['chr_fa']
    shell:
        "wget --quiet -O {output.chr} {params.link} "


rule download_annotation:
    """ Download annotation file."""
    output:
        annotation = "data/references/annotation.gff"
    conda:
        "../envs/omniCLIP.yaml"
    params:
        link = config['resources']['ref']['gff']
    shell:
        "wget --quiet -O {output.annotation}.gz {params.link} && "
        "gunzip {output}.gz"


rule download_genome:
    """ Download the genome."""
    output:
        genome = "data/references/genome.fa"
    params:
        link = config['resources']['ref']['genome_fa']
    shell:
        "wget --quiet -O {output.genome}.gz {params.link} && "
        "gunzip {output}.gz"


rule download_SRR_PE_datasets:
    """ Download with two FASTQ files for PE datasets """
    output:
        fastq1 = "data/datasets/{SRRid}_1.fastq.gz",
        fastq2 = "data/datasets/{SRRid}_2.fastq.gz"
    params:
        link = format_SRR_download_link
    shell:
        "wget --quiet -O {output.fastq1} {params.link}_1.fastq.gz && "
        "wget --quiet -O {output.fastq2} {params.link}_2.fastq.gz"


rule download_SRR_SE_datasets:
    """ Download with two FASTQ files for SE datasets """
    output:
        fastq = "data/datasets/{SRRid}.fastq.gz",
    params:
        link = format_SRR_download_link
    shell:
        "wget --quiet -O {output.fastq} {params.link}.fastq.gz"


# rule download_SRR_datasets:
#     output:
#         "data/datasets/{SRRid}.stuff"
#     params:
#         out_dir = "data/datasets/"
#     conda:
#         "../envs/sra-tools.yaml"
#     shell:
#         "fastq-dump --gzip "
#         "--skip-technical "
#         "--split-files --readids "
#         # "--read-filter pass "
#         "--clip --dumpbase "
#         "--outdir {params.out_dir} "
#         "{wildcards.SRRid}"
