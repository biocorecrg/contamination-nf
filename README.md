# contamination-nf
Nextflow pipeline for checking contamination problems with reads among other tasks

## Run:

Modify params.config accordingly or copy it and replace it in the command-line below.

```
nextflow run -bg --config params.config main.nf &> log
```

## TODO

* To be ported to DSL2 + BioNextflow
* Move build process in the pipeline (now in ```build-sh```)

## Links

* [Kraken2 manual](https://github.com/DerrickWood/kraken2/blob/master/docs/MANUAL.markdown)
* [Bracken manual](http://ccb.jhu.edu/software/bracken/index.shtml?t=manual)
