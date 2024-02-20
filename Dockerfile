# syntax=docker/dockerfile:1

ARG ruby_version=2.7
ARG node_version=14
ARG freetds_version=1.3.9
ARG tag_variant=-slim-bullseye

FROM ruby:${ruby_version}${tag_variant} as freetds_builder

RUN mkdir -p /home/deploy/freetds

# FreeTDS
# we aren't installing from git, but these instructions are mostly useful
# https://github.com/FreeTDS/freetds/blob/master/INSTALL.GIT.md
# undeclared requirements: https://github.com/FreeTDS/freetds/issues/172, gperf, etc
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends autoconf automake bzip2 file g++ gcc libbz2-dev libc6-dev  \
    libmagickcore-dev libtool libtool-bin autogen libtool make gcc perl gettext gperf git gpg curl tar \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean autoclean && \
    apt-get autoremove -y
ARG freetds_version
RUN curl -fsSL https://github.com/FreeTDS/freetds/archive/refs/tags/v${freetds_version}.tar.gz -o freetds-${freetds_version}.tar.gz && \
    tar -xzf freetds-${freetds_version}.tar.gz && \
    cd freetds-${freetds_version} && \
    git init && git config user.email "n/a" && git config user.name "n/a" && touch blank && git add blank && git commit -m "a commit" && \
    ./autogen.sh --prefix=/home/deploy/freetds/ --with-tdsver=7.3 && \
    make && \
    make install

FROM ruby:${ruby_version}${tag_variant} as final

# copying the compiled freetds libraries from the builder image
COPY --chown=root --from=freetds_builder /home/deploy/freetds/bin /usr/local/bin
COPY --chown=root --from=freetds_builder /home/deploy/freetds/lib /usr/local/lib
COPY --chown=root --from=freetds_builder /home/deploy/freetds/include /usr/local/include
COPY --chown=root --from=freetds_builder /home/deploy/freetds/share /usr/local/share
COPY --chown=root --from=freetds_builder /home/deploy/freetds/etc/* /etc/freetds/

# Node.js and PostgreSQL for Clubhouse
# https://github.com/nodesource/distributions/blob/master/README.md#installation-instructions
ARG node_version
RUN apt-get update -qq && apt-get install -y curl libpq-dev gpg wget tar jq libasound2 xvfb unzip git make g++  \
    xz-utils libatk-bridge2.0-0 libatk1.0-0 libatspi2.0-0 libcairo2 libcups2 libdbus-1-3 libgbm1 libglib2.0-0  \
    libgtk-4-1 libnspr4 libnss3 libpango-1.0-0 libu2f-udev libxcomposite1 libxkbcommon0 libxrandr2 xdg-utils && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean autoclean
RUN curl -fsSL https://deb.nodesource.com/setup_${node_version}.x | bash - && \
    apt-get install -y nodejs && \
    apt-mark manual nodejs libpq-dev make g++ && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean autoclean

# create app user & home directory
RUN adduser --uid 55555 --home /home/appuser --disabled-password --gecos "" appuser
WORKDIR /home/appuser

# link future bind mount file(s) to their default location(s)
RUN ln -s /mount/vault-shared/.vault-token /home/appuser/.vault-token
RUN ln -s /mount/vault-shared/.consul-token /home/appuser/.consul-token

# add configuration files
COPY --chown=appuser --chmod=0700 .docker/home ./
