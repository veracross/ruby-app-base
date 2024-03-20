# syntax=docker/dockerfile:1

ARG ruby_version=2.7
ARG node_version=14
ARG freetds_version=1.3.10

FROM ruby:${ruby_version}-alpine

ARG node_version
ARG freetds_version

RUN apk update
RUN apk add --no-cache curl build-base postgresql-dev

# Node.js
RUN curl -fsSL https://unofficial-builds.nodejs.org/download/release/v14.4.0/node-v14.4.0-linux-x64-musl.tar.xz -o /tmp/node.tar.xz && \
    tar -xvf /tmp/node.tar.xz -C /usr/local --strip-components=1 && \
    rm /tmp/node.tar.xz

# FreeTDS
RUN apk add --no-cache freetds-dev=$freetds_version-r0

# Misc tools
# https://circleci.com/developer/orbs/orb/circleci/browser-tools
RUN apk add --no-cache gpg jq

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
