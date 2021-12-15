FROM biocorecrg/debian-perlbrew-pyenv3-java:buster

MAINTAINER Toni Hermoso Pulido <toni.hermoso@crg.eu>

#ARG KRAKEN_VERSION= To have
ARG BRACKEN_VERSION=2.6.2

# Upgrade system
RUN set -x ; apt-get update && apt-get -y upgrade

# Additional software
RUN set -x ; apt-get install -y rsync

# Adding perl module
RUN cpanm List::MoreUtils

# Upgrade pip
RUN pip install --upgrade pip

# Adding kraken2
RUN cd /tmp; git clone https://github.com/DerrickWood/kraken2.git
#RUN  cd /tmp/kraken2; git checkout ${KRAKEN_VERSION} # To consider
RUN cd /tmp/kraken2; bash ./install_kraken2.sh /usr/local/kraken2
RUN cd /usr/local/bin; ln -s /usr/local/kraken2/kraken2 . ; ln -s /usr/local/kraken2/kraken2-build . ; ln -s /usr/local/kraken2/kraken2-inspect .
RUN rm -rf /tmp/kraken2

# Adding Braken
RUN cd /tmp; curl --fail --silent --show-error --location --remote-name https://github.com/jenniferlu717/Bracken/archive/v${BRACKEN_VERSION}.tar.gz
RUN cd /tmp; tar zxf v${BRACKEN_VERSION}.tar.gz; cd Bracken-${BRACKEN_VERSION}; bash install_bracken.sh
RUN mkdir -p /usr/local/bracken; cd /usr/local/bracken; cp -prf /tmp/Bracken-${BRACKEN_VERSION}/src .; cp -prf /tmp/Bracken-${BRACKEN_VERSION}/analysis_scripts .; cp /tmp/Bracken-${BRACKEN_VERSION}/bracken* .
RUN cd /usr/local/bin; ln -s /usr/local/bracken/bracken* .
RUN rm -rf /tmp/Bracken*

# Clean cache
RUN apt-get clean
RUN set -x; rm -rf /var/lib/apt/lists/*
