FROM ruby:3.2 AS development

ARG UNAME=app
ARG UID=1000
ARG GID=1000

LABEL maintainer="mrio@umich.edu"

RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
  vim-tiny

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

RUN --mount=type=secret,id=gh_package_read_token,uid=1000 \
  read_token="$(cat /run/secrets/gh_package_read_token)" \
  && BUNDLE_RUBYGEMS__PKG__GITHUB__COM=${read_token} bundle install
