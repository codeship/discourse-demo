FROM ruby:2.3.1-slim
MAINTAINER maintainers@codeship.com

ENV \
  DEBIAN_DISTRIBUTION="jessie" \
  DEBIAN_FRONTEND="noninteractive" \
  NODE_VERSION="4.x" \
  PHANTOMJS_VERSION="1.9.7"

RUN \
  apt-get update \
  && apt-get install -y --no-install-recommends \
    apt-transport-https \
  && curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - \
  && echo "deb https://deb.nodesource.com/node_${NODE_VERSION} ${DEBIAN_DISTRIBUTION} main" > /etc/apt/sources.list.d/nodesource.list \
  && curl -s https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
  && echo "deb http://apt.postgresql.org/pub/repos/apt/ ${DEBIAN_DISTRIBUTION}-pgdg main" >  /etc/apt/sources.list.d/postgresql.list \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    postgresql-client-9.5 \
    apt-utils \
    build-essential \
    bzip2 \
    gifsicle \
    git \
    graphicsmagick-imagemagick-compat \
    jhead \
    jpegoptim \
    libfontconfig \
    libfreetype6 \
    libjpeg-progs \
    libpq-dev \
    nodejs \
    optipng \
    postgresql-client-9.4 \
    python-pip \
    time \
    vim \
    wget \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/* \
  && pip install awscli \
  && npm config set "production" "true" \
  && npm config set "loglevel" "error" \
  && npm install npm -g \
  && npm install -g svgo

RUN \
  wget --no-verbose --output-document /tmp/phantomjs-linux-x86_64.tar.bz2 "https://s3.amazonaws.com/codeship-packages/phantomjs-${PHANTOMJS_VERSION}-linux-x86_64.tar.bz2" \
  && tar -xaf /tmp/phantomjs-linux-x86_64.tar.bz2 --directory /tmp/ \
  && mv "/tmp/phantomjs-${PHANTOMJS_VERSION}-linux-x86_64/bin/phantomjs" /usr/bin/phantomjs \
  && rm -rf /tmp/phantomjs-linux-x86_64.tar.bz2 "/tmp/phantomjs-${PHANTOMJS_VERSION}-linux-x86_64"

RUN mkdir /code
WORKDIR /code

COPY Gemfile Gemfile.lock vendor ./
RUN \
  bundle install --jobs 20 --retry 5 \
  && gem install parallel_tests

COPY . ./

RUN \
  mkdir -p ./public/backups/default tmp
