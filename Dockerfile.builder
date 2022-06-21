ARG PHP_VERSION=8.1
ARG CONTAINER_IMAGE=php:${PHP_VERSION}-cli

FROM ${CONTAINER_IMAGE} AS downloader
ARG COMPOSER_VERSION=2.3.5
RUN apt update \
  && apt install wget \
  && wget -q -O /tmp/composer https://github.com/composer/composer/releases/download/${COMPOSER_VERSION}/composer.phar

FROM ${CONTAINER_IMAGE} AS final_image

COPY ./nodesource-signing-key.gpg  /etc/apt/trusted.gpg.d/
COPY --from=downloader /tmp/composer /usr/local/bin/composer

RUN useradd -u 1000 -m user \
  && mkdir /app \
  && chown user:user /app \
  && chmod +x /usr/local/bin/composer

ARG NODE_VERSION=14
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt -y install ca-certificates git zip unzip \
  && apt -y upgrade \
  && export DISTRO=`cat /etc/os-release | grep ^VERSION_CODENAME | cut -d= -f2` \
  && export REPO_SUFFIX="node_$NODE_VERSION.x" \
  && echo "deb https://deb.nodesource.com/$REPO_SUFFIX $DISTRO main" > /etc/apt/sources.list.d/nodesource_$NODE_VERSION.list \
  && cat /etc/apt/sources.list.d/nodesource_$NODE_VERSION.list \
  && apt update \
  && apt -y  --no-install-recommends install nodejs \
  && ls -l /usr/local/bin/composer \
  && apt-get clean

WORKDIR /app
USER 1000
