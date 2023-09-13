FROM debian:bullseye-slim

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# No need to specify a version for nodejs since the setup_18.x script is being downloaded and
# executed
# hadolint ignore=DL3008
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y upgrade \
    && apt-get install --no-install-recommends -y curl=7.74.0-1.3+deb11u7 \
    && apt-get install --no-install-recommends -y ca-certificates=20210119 \
    && curl -sL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install --no-install-recommends -y nodejs \
    && apt-get autoremove -y \
    && rm -rf /root/.npm \
    && rm -rf /var/lib/apt/lists/*

ENV CYCLONEDX_NPM_VERSION="9.6.0"

# install dependencies
RUN npm install --global @cyclonedx/cdxgen@$CYCLONEDX_NPM_VERSION \
  && rm -rf /root/.npm

# Create a non-root user and group
RUN addgroup --system --gid 1002 bitbucket-group && \
  adduser --system --uid 1002 --ingroup bitbucket-group bitbucket-user

USER bitbucket-user

WORKDIR /build
ENTRYPOINT ["cdxgen"]
