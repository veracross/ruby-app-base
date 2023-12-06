ARG ruby_version=3.1-slim-bullseye
ARG node_version=18
ARG freetds_version=1.3.9

FROM debian:bullseye-slim as tds_builder
RUN apt-get update -qq
RUN apt-get install -y --no-install-recommends autoconf automake bzip2 file g++ gcc libbz2-dev libc6-dev  \
    libmagickcore-dev libtool libtool-bin autogen libtool make gcc perl gettext gperf git gpg curl tar jq libasound2 \
    ca-certificates

ARG freetds_version
RUN curl -fsSL https://github.com/FreeTDS/freetds/archive/refs/tags/v${freetds_version}.tar.gz -o \
    freetds-${freetds_version}.tar.gz && \
    tar -xzf freetds-${freetds_version}.tar.gz && \
    cd freetds-${freetds_version} && \
    git init && git config user.email "n/a" && git config user.name "n/a" && touch blank && git add blank && \
    git commit -m "a commit" && ./autogen.sh --prefix=/home/deploy/tds --with-tdsver=7.3 &&  \
    make && make install && make clean


FROM ruby:${ruby_version} as final

RUN apt-get update -qq

# Node.js
# https://github.com/nodesource/distributions/blob/master/README.md#installation-instructions
ARG node_version
RUN curl -fsSL https://deb.nodesource.com/setup_${node_version}.x | bash -
RUN apt-get install -y nodejs npm git-core

COPY --chown=root --from=tds_builder /home/deploy/tds/bin/* /usr/local/bin/
COPY --chown=root --from=tds_builder /home/deploy/tds/lib/* /usr/local/lib/
COPY --chown=root --from=tds_builder /home/deploy/tds/include/* /usr/local/include/
COPY --chown=root --from=tds_builder /home/deploy/tds/share/* /usr/local/share/
COPY --chown=root --from=tds_builder /home/deploy/tds/etc/* /etc/freetds/

# clean up after installation of required libraries
RUN apt-get clean
