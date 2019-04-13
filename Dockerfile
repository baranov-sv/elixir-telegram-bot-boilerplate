FROM elixir:1.8.1-alpine

# Install deps
RUN apk add --no-cache --virtual .build-deps bash

RUN mix local.hex --force && \
    mix local.rebar --force

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY . /usr/src/app
