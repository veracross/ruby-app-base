# syntax=docker/dockerfile:1

ARG ruby_version=2.5
ARG node_version=16
ARG freetds_version=1.3.9

FROM ruby:${ruby_version}

ARG node_version
ARG freetds_version

RUN apt-get update -qq

# Node.js
# https://github.com/nodesource/distributions/blob/master/README.md#installation-instructions
RUN curl -fsSL https://deb.nodesource.com/setup_${node_version}.x | bash -
RUN apt-get install -y nodejs

# FreeTDS
# we aren't installing from git, but these instructions are mostly useful
# https://github.com/FreeTDS/freetds/blob/master/INSTALL.GIT.md
# undeclared requirements: https://github.com/FreeTDS/freetds/issues/172, gperf, etc
RUN apt-get install -y --no-install-recommends automake autoconf libtool make gcc perl gettext gperf git

RUN curl -fsSL https://github.com/FreeTDS/freetds/archive/refs/tags/v${freetds_version}.tar.gz -o freetds-${freetds_version}.tar.gz && \
    tar -xzf freetds-${freetds_version}.tar.gz && \
    cd freetds-${freetds_version} && \
    git init && git config user.email "n/a" && git config user.name "n/a" && touch blank && git add blank && git commit -m "a commit" && \
    ./autogen.sh --prefix=/usr/local --with-tdsver=7.3 && \
    make && \
    make install

# Misc tools
# https://circleci.com/developer/orbs/orb/circleci/browser-tools
RUN apt-get install -y --no-install-recommends gpg curl tar jq libasound2
