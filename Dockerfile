# syntax=docker/dockerfile:1

ARG ruby_version=3.0
ARG node_version=16
ARG freetds_version=1.3.9

FROM ruby:${ruby_version}

ARG node_version
ARG freetds_version

RUN apt-get update -qq

# Node.js
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${node_version}.x nodistro main" > /etc/apt/sources.list.d/nodesource.list && \
    apt-get update -qq && apt-get install -y nodejs

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

# create app user & home directory
RUN adduser --uid 55555 --home /home/appuser --disabled-password --gecos "" appuser
WORKDIR /home/appuser

USER appuser
RUN gem install bundler:2.4.22
USER root

# link future bind mount file(s) to their default location(s)
RUN ln -s /mount/vault-shared/.vault-token /home/appuser/.vault-token
RUN ln -s /mount/vault-shared/.consul-token /home/appuser/.consul-token

# add configuration files
COPY --chown=appuser --chmod=0700 .docker/home ./
