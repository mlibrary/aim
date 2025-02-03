FROM ruby:3.3 AS development

ARG UNAME=app
ARG UID=1000
ARG GID=1000

LABEL maintainer="mrio@umich.edu"

RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
  vim-tiny \
  default-mysql-client

RUN gem install bundler

RUN groupadd -g ${GID} -o ${UNAME}
RUN useradd -m -d /app -u ${UID} -g ${GID} -o -s /bin/bash ${UNAME}
RUN mkdir -p /gems && chown ${UID}:${GID} /gems

ENV PATH="$PATH:/app/exe:/app/bin"
USER $UNAME

ENV BUNDLE_PATH /gems

WORKDIR /app

FROM development AS production

COPY --chown=${UID}:${GID} . /app

RUN --mount=type=secret,id=github_token,uid=1000 \
  github_token="$(cat /run/secrets/github_token)" \
  && BUNDLE_RUBYGEMS__PKG__GITHUB__COM=${github_token} bundle install
