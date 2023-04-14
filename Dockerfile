# syntax=docker/dockerfile:1

ARG ruby_version=2.7
ARG node_version=14
ARG freetds_version=1.3.9

FROM ruby:${ruby_version}

ARG node_version
ARG freetds_version

RUN apt-get update -qq

# Node.js
# https://github.com/nodesource/distributions/blob/master/README.md#installation-instructions
RUN curl -fsSL https://deb.nodesource.com/setup_${node_version}.x | bash -
RUN apt-get install -y nodejs
RUN npm install -g yarn@1

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

# Chromium dependencies
# https://github.com/puppeteer/puppeteer/blob/main/docs/troubleshooting.md#chrome-doesnt-launch-on-linux
RUN apt-get install -y --no-install-recommends \
    ca-certificates \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libc6 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libexpat1 \
    libfontconfig1 \
    libgbm1 \
    libgcc1 \
    libglib2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libstdc++6 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    lsb-release \
    wget \
    xdg-utils

# Misc tools
# https://circleci.com/developer/orbs/orb/circleci/browser-tools
RUN apt-get install -y --no-install-recommends gpg curl tar jq libasound2
