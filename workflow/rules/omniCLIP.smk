
rule git_omniCLIP:
    """Fetch the omniCLIP git project."""
    output:
        path = directory(config['paths']['omniCLIP_dir'])
    conda:
        "../envs/git.yaml"
    params:
        link = config['resources']['software']['omniCLIP'],
        commit = config['resources']['software']['omniCLIP_commit'],
        omni_dir = config['paths']['omniCLIP_dir']
    shell:
        "mkdir {output.path} "
        "&& git clone {params.link} {output.path} "
        "&& git --git-dir {params.omni_dir}/.git checkout {params.commit}"


rule compile_omniCLIP_requirements:
    """Compiling viterbi through cython/gcc."""
    input:
        path = rules.git_omniCLIP.output.path
    output:
        tkn = config['paths']['omniCLIP_dir'] + '.tkn'
    conda:
        "../envs/omniCLIP.yaml"
    shell:
        "cd git_repos/omniCLIP && python3 setup.py "
        "&& touch ../../{output.tkn}"


rule prepare_omniCLIP_annotation:
    """Prepare the DB file for omniCLIP."""
    input:
        gff = rules.download_annotation.output.annotation,
        tkn = rules.compile_omniCLIP_requirements.output.tkn
    output:
        gff_db = "data/references/annotation.gff.db"
    params:
        omni_dir = config['paths']['omniCLIP_dir'],
        gene_features = ','.join(config['params']['omniCLIP']['gene_features'])
    conda:
        "../envs/omniCLIP.yaml"
    shell:
        "PYTHONPATH={params.omni_dir}/stat:{params.omni_dir}/data_parsing "
        "python3 {params.omni_dir}/omniCLIP.py generateDB "
        "--gff-file {input.gff} "
        "--db-file {output.gff_db} "
        "--gene_features {params.gene_features}"


rule prepare_bg_dat:
    input:
        bg_files = partial(get_bam_files, False, False),
        gff_db = rules.prepare_omniCLIP_annotation.output.gff_db
    output:
        dat = "results/omniCLIP/{bg}/bg_dat.dat"
    params:
        bg_files = partial(get_bam_files, True, False),
        omni_dir = config['paths']['omniCLIP_dir'],
        genome_dir = config['paths']['genome_dir']
    conda:
        "../envs/omniCLIP.yaml"
    shell:
        "PYTHONPATH={params.omni_dir}/stat:{params.omni_dir}/data_parsing "
        "python3 {params.omni_dir}/omniCLIP.py parsingBG "
        "--bg-files {params.bg_files} "
        "--db-file {input.gff_db} "
        "--genome-dir {params.genome_dir} "
        "--out-file {output.dat} "
        "--bck-var"


rule prepare_clip_dat:
    input:
        clip_files = partial(get_bam_files, False, True),
        gff_db = rules.prepare_omniCLIP_annotation.output.gff_db
    output:
        dat = "results/omniCLIP/{rbp}/clip_dat.dat"
    params:
        clip_files = partial(get_bam_files, True, True),
        omni_dir = config['paths']['omniCLIP_dir'],
        genome_dir = config['paths']['genome_dir']
    conda:
        "../envs/omniCLIP.yaml"
    shell:
        "PYTHONPATH={params.omni_dir}/stat:{params.omni_dir}/data_parsing "
        "python3 {params.omni_dir}/omniCLIP.py parsingCLIP "
        "--clip-files {params.clip_files} "
        "--db-file {input.gff_db} "
        "--genome-dir {params.genome_dir} "
        "--out-file {output.dat} "
        "--min-peak 25 "
        "--min-coverage 1000"


rule run_omniCLIP:
    """ Still working out the best way to run omniCLIP """
    input:
        bg_dat = rules.prepare_bg_dat.output.dat,
        clip_dat = rules.prepare_clip_dat.output.dat,
        gff_db = rules.prepare_omniCLIP_annotation.output.gff_db,
        tkn = "git_repos/omniCLIP.tkn",
        genome = get_all_chr
    output:
        out_dir = directory(config['paths']['omniCLIP_output'])
    params:
        genome_dir = config['paths']['genome_dir'],
        omni_dir = config["paths"]["omniCLIP_dir"],
    conda:
        "../envs/omniCLIP.yaml"
    threads:
        28
    shell:
        "mkdir -p {output.out_dir} && "
        "PYTHONPATH={params.omni_dir}/stat:{params.omni_dir}/data_parsing "
        "python {params.omni_dir}/omniCLIP.py run_omniCLIP "
        "--clip-dat {input.clip_dat} "
        "--bg-dat {input.bg_dat} "
        "--db-file {input.gff_db} "
        "--out-dir {output.out_dir} "
        "--tmp-dir {output.out_dir} "
        "--nb-cores {threads} "
        "--filter-snps "
        "--max-it 4 "
        "--nr_mix_comp 10 "
        "--diag_event_mod DirchMultK "
        "--diag-bg "
        "--norm_class "
        "--bg-type Coverage_bck "
