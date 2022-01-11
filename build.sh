#!/usr/bin/env bash

# PATH where to download
export DB=/nfs/db/kraken2/hittheleria
# Singularity image
export SING="singularity exec -e /software/bi/singularity/kraken2/kraken2-202112.sif"

export ADDFASTA="/nfs/db/kraken2/tmp/ncbi-genomes-2021-12-16/GCF_002263795.1_ARS-UCD1.2_genomic.fna"

# Taxonomy
$SING kraken2-build --download-taxonomy --db $DB

# Additional files
$SING kraken2-build --add-to-library $ADDFASTA --db $DB

# Defined groups
orgs=( viral bacteria archaea fungi protozoa human UniVec_Core )
for i in "${orgs[@]}"
do
       $SING kraken2-build --download-library $i --db $DB
       sleep 30
done

$SING kraken2-build --build --db $DB
