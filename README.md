# contamination-nf
Nextflow pipeline for checking contamination problems with reads among other tasks

## Metagenomics analysis

- Kraken2
- Bracken

* We can store classified and not classified reads

Deciding read length for bracken from:

```cat ucfs_1.fq | awk '{if(NR%4==2) print length($1)}' | sort -n | uniq -c```

```
singularity exec -e /software/bi/biocore_tools/git/singularity/metacont.sif kraken2 --db /nfs/db/kraken2/ncov19 --report myreport.report --threads 6 --paired /software/bi/biocore_tools/git/nextflow/RNA_virus_assembly/data/illumina/mydata* --classified-out cfs#.fq --unclassified-out ucfs#.fq > my.out 2> err
```

http://ccb.jhu.edu/software/bracken/index.shtml?t=manual

```
singularity exec -e /software/bi/biocore_tools/git/singularity/metacont.sif bracken -d /nfs/db/kraken2/ncov19 -i myreport.report -o my.out -r 151 -l S -t 10 > my.bracken.out 2> bracken.err
```

### Build kraken2

Manual: https://github.com/DerrickWood/kraken2/blob/master/docs/MANUAL.markdown

```
kraken2-build --download-taxonomy --db DB

kraken2-build --download-library viral --db DB
kraken2-build --download-library bacteria --db DB
kraken2-build --download-library archea --db DB
kraken2-build --download-library fungi --db DB
kraken2-build --download-library human --db DB
kraken2-build --download-library UniVec_Core --db DB

kraken2-build --build --db DB
```

### Build bracken

```bracken-build -d /nfs/db/kraken2/ncov19 -t 8 -l 151```


## TODO

To be ported to DSL2 + BioNextflow
