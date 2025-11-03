# syntax=docker/dockerfile:1
# check=error=true

ARG RUBY_VERSION=3.4.7
FROM docker.io/library/ruby:${RUBY_VERSION}-slim AS base

WORKDIR /rails

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      curl \
      git \
      libjemalloc2 \
      libmariadb-dev \
      libvips \
      libyaml-dev \
      pkg-config \
      sqlite3 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ARG uid=1000

RUN groupadd --system --gid ${uid} rails && \
    useradd rails --uid ${uid} --gid ${uid} --create-home --shell /bin/bash

ENV RAILS_ENV="development" \
    BUNDLE_DEPLOYMENT="0" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="" 

FROM base AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      git \
      libmariadb-dev \
      libyaml-dev \
      pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY Gemfile Gemfile.lock ./

RUN bundle install && \
    rm -rf ~/.bundle/ \
           "${BUNDLE_PATH}"/ruby/*/cache \
           "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

COPY . .

RUN bundle exec bootsnap precompile app/ lib/

FROM base

COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

RUN mkdir -p db log storage tmp && \
    groupadd --system --gid ${uid} rails && \
    useradd rails --uid ${uid} --gid ${uid} --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp

USER ${uid}:${uid}

ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 3000 
CMD ["./bin/rails", "server", "-b", "0.0.0.0"] # Lệnh chạy server