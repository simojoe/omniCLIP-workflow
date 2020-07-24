rule STAR_genomeGenerate:
    """Create the STAR index file."""
    input:
        genome = rules.download_genome.output.genome,
        gff3 = rules.download_annotation.output.annotation
    output:
        dir = directory(config['paths']['STAR_index'])
    params:
        readLength = config['params']['STAR']['CLIP_read_length']
    conda:
        "../envs/STAR.yaml"
    threads:
        28
    shell:
        "mkdir {output.dir} && "
        "STAR "
        "--runMode genomeGenerate "
        "--runThreadN {threads} "
        "--genomeDir {output.dir} "
        "--genomeFastaFiles {input.genome} "
        "--sjdbGTFfile {input.gff3} "
        "--genomeSAindexNbases 10 "
        "--sjdbGTFtagExonParentTranscript Parent "
        "--sjdbOverhang {params.readLength}"


rule STAR_CLIP_alignment:
    """STAR alignment for the CLIP FASTQ files."""
    input:
        fastqs = partial(get_sample_fastqs, False),
        index = rules.STAR_genomeGenerate.output.dir
    output:
        bam = config['paths']['BAM_files']
    params:
        fastqs = partial(get_sample_fastqs, True),
        out_dir = "results/BAM/{sample}/"
    threads:
        28
    conda:
        "../envs/STAR.yaml"
    shell:
        "STAR "
        "--genomeDir {input.index} "
        "--readFilesIn {params.fastqs} "
        "--readFilesCommand zcat "
        "--outFileNamePrefix {params.out_dir} "
        "--runThreadN {threads} "
        "--outSAMtype BAM SortedByCoordinate "
        "--alignEndsType EndToEnd "
        "--outFilterMultimapNmax 100 "
        "--seedSearchStartLmax 15 "
        "--sjdbScore 2 "
        "--alignSJoverhangMin 12 "
        "--outFilterMatchNmin 15 "
        "--outSAMattributes All "
        "--limitBAMsortRAM 4183005570"


rule sort_index_BAM:
    """ Sorting and indexing the BAM files """
    input:
        bam_file = "{file}.bam"
    output:
        indexed_bam = "{file}.bam.bai",
    conda:
        "../envs/samtools.yaml"
    shell:
        "samtools index {input.bam_file}"
