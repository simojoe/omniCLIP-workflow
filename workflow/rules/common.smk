from functools import partial
import pandas as pd


# Wildcards constraints
wildcard_constraints:
    SRRid = "SRR[0-9]+",
    bg = "[A-Za-z0-9]+"

# Importing the samples file
samples = pd.read_csv(config['samples'], sep="\t", dtype=str,
                      index_col=False).set_index("sample_id", drop=False)


def format_SRR_download_link(wildcards):
    """Format a SRRid dataset into the download link."""
    SRRid = wildcards['SRRid']
    return '/'.join([
        "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/",
        SRRid[:6],
        SRRid[9:].zfill(3),
        SRRid,
        SRRid
    ])


def get_all_chr(wildcards):
    chrs = config['resources']['species']['chrs']
    return expand(config['paths']['chr'], chr=chrs)


def get_bam_files(formatted, clip, wildcards):
    """Given a RBP, returns all processed BAM files."""
    if clip:
        sample = 'rbp'
    else:
        sample = 'bg'

    SRRids = get_samples_SSRid('sample', wildcards[sample], 'sample_id')
    files = [config['paths']['BAM_files'].format(sample=SRRid)
             for SRRid in SRRids]

    if formatted:
        if clip:
            files = " --clip-files ".join(files)
        else:
            files = " --bg-files ".join(files)
    else:
        indexed = [file + ".bai" for file in files]
        files.extend(indexed)

    return files


def get_fastq_path(SRRid, layout):
    if layout == "PE":
        files = ["data/datasets/{SRRid}_{i}.fastq.gz".format(SRRid=SRRid, i=i)
                 for i in range(1, 3)]
    elif layout == "SE":
        files = ["data/datasets/{SRRid}.fastq.gz".format(SRRid=SRRid)]
    return files


def get_sample_fastqs(joined, wildcards):
    """ """
    SRRid = get_samples_SSRid('sample_id', wildcards['sample'], 'SRRid')[0]
    layout = get_samples_SSRid('sample_id', wildcards['sample'], 'layout')[0]
    paths = get_fastq_path(SRRid, layout)
    if joined:
        paths = " ".join(paths)
    return paths


def get_samples_SSRid(col, key, out_col):
    """Return all SRRid for a given RBP"""
    return samples[samples[col] == key][out_col].tolist()
