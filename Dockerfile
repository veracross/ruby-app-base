# syntax=docker/dockerfile:1

ARG ruby_version=3.1-slim-bullseye
ARG node_version=18
ARG freetds_version=1.3.9

FROM ruby:${ruby_version}

ARG node_version
ARG freetds_version

RUN apt-get update -qq

# Node.js
# https://github.com/nodesource/distributions/blob/master/README.md#installation-instructions
RUN curl -fsSL https://deb.nodesource.com/setup_${node_version}.x | bash -
RUN apt-get install -y nodejs

# Misc tools
# https://circleci.com/developer/orbs/orb/circleci/browser-tools
RUN apt-get install -y --no-install-recommends gpg curl tar jq libasound2

# FreeTDS
# we aren't installing from git, but these instructions are mostly useful
# https://github.com/FreeTDS/freetds/blob/master/INSTALL.GIT.md
# undeclared requirements: https://github.com/FreeTDS/freetds/issues/172, gperf, etc
RUN apt-get install -y --no-install-recommends autoconf automake bzip2 file g++ gcc libbz2-dev libc6-dev \
    libmagickcore-dev libtool libtool-bin autogen libtool make gcc perl gettext gperf git

RUN curl -fsSL https://github.com/FreeTDS/freetds/archive/refs/tags/v${freetds_version}.tar.gz -o freetds-${freetds_version}.tar.gz && \
    tar -xzf freetds-${freetds_version}.tar.gz && \
    cd freetds-${freetds_version} && \
    git init && git config user.email "n/a" && git config user.name "n/a" && touch blank && git add blank && git commit -m "a commit" && \
    ./autogen.sh --prefix=/usr/local --with-tdsver=7.3 && \
    make && \
    make install && \
    make clean

# clean up after installation of required libraries
RUN apt-get clean
