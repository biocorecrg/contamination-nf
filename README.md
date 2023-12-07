# contamination-nf
Nextflow pipeline for checking contamination problems with reads among other tasks

## Install
git clone git@github.com:biocorecrg/contamination-nf.git --recurse-submodules 


## Run:

Modify params.config accordingly or copy it and replace it in the command-line below.

```
# Running KRAKEN2
nextflow run -bg --config params.config main.nf &> log
```

Different subworkflows:

* build
* bracken

## TODO

* Allow adding custom FASTAs (now in ```build.sh```)

## Links

* [Kraken2 manual](https://github.com/DerrickWood/kraken2/blob/master/docs/MANUAL.markdown)
* [Bracken manual](http://ccb.jhu.edu/software/bracken/index.shtml?t=manual)
