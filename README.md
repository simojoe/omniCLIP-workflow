# Snakemake workflow: omniCLIP
This workflow performs CLIP peak calling using omniCLIP.

# Author

* Joël Simoneau (@simojoe)

# Data sources
This example workflow uses some previously published S. pombe datasets. The GEO
identifiers of the datasets used are the following :

* CLIP data : [GSE112117](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE112117)
* RNA-seq : [GSE148191](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE148191)

# Usage

## 1. Snakemake installation
To run the snakemake workflow, we recommend to usage of a conda environment for
the snakemake installation. conda will also be needed during the execution of
the workflow. Make sure it is [installed](https://docs.conda.io/projects/conda/en/latest/user-guide/install/)
on your system.

The following creates the snakemake conda environment.

```
$ conda create --name smake -c conda-forge -c bioconda snakemake=5.20.1
```

To use the environment, activate it in the following way.

```
$ conda activate smake
```

## 2. Get the workflow
Get a copy of this workflow by cloning and or downloading its latest release.

## 3. Run the workflow
To run the workflow as is, use the following command in the main directory.

```
snakemake --use-conda --cores=$NB_CORES
```

Where `$NB_CORES` is replaced by the number of cores you want to dedicate to
this workflow execution.

# In development
This workflow is still under-development. To be added:

* Information about configuration.
* More flexibility for the type of data to analyze.

# Acknowledgements
This workflow structure is based upon other released snakemake workflows found
in the [snakemake-workflows repository](https://github.com/snakemake-workflows).
