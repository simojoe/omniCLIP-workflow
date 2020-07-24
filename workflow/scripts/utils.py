

# def format_SRR_download_link(wildcards):
#     """Format a SRRid dataset into the download link."""
#     SRRid = wildcards['SRRid']
#     return '/'.join([
#         "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/",
#         SRRid[:6],
#         '00' + SRRid[-1],
#         SRRid,
#         SRRid
#     ])


# def get_clip_files(wildcards):
#     """Given a RBP, returns all processed BAM files."""
#     rbp = wildcards['rbp']
#     print(config)
#     pass
