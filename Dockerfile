FROM debian:bullseye-slim

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# No need to specify a version for nodejs since the setup_18.x script is being downloaded and
# executed
# To see what versions of packages are available you can run
# apt-cache show <package name> | grep Version
# hadolint ignore=DL3008
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y upgrade \
    && apt-get install --no-install-recommends -y curl=7.74.0-1.3+deb11u11 \
    && apt-get install --no-install-recommends -y ca-certificates=20210119 \
    && apt-get install --no-install-recommends -y openjdk-17-jdk \
    && apt-get install --no-install-recommends -y maven \
    && apt-get install --no-install-recommends -y python3 \
    && apt-get install --no-install-recommends -y pip \
    && curl -sL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install --no-install-recommends -y nodejs \
    && apt-get autoremove -y \
    && rm -rf /root/.npm \
    && rm -rf /var/lib/apt/lists/* \
    && python3 -m pip install --no-cache-dir virtualenv==20.25.0


ENV CYCLONEDX_CDXGEN_VERSION="9.11.1" \
    GO_VERSION="1.21.6" \
    GEN_SBOM_SCRIPT_LOCATION="/opt"

COPY gen_*.sh $GEN_SBOM_SCRIPT_LOCATION/

# install dependencies
ARG ARCH
RUN npm install --global @cyclonedx/cdxgen@$CYCLONEDX_CDXGEN_VERSION \
  && curl -sL -o go${GO_VERSION}.linux-${ARCH}.tar.gz https://go.dev/dl/go${GO_VERSION}.linux-${ARCH}.tar.gz \
  && tar -C /usr/local -xzf go${GO_VERSION}.linux-${ARCH}.tar.gz \
  && ln -s /usr/bin/python3 /usr/bin/python \
  && rm -rf /root/.npm

ENV PATH="${GEN_SBOM_SCRIPT_LOCATION}:/usr/local/go/bin:${PATH}"

# Create a non-root user and group
RUN addgroup --system --gid 1002 bitbucket-group && \
  adduser --system --uid 1002 --ingroup bitbucket-group bitbucket-user

USER bitbucket-user

WORKDIR /build
ENTRYPOINT ["gen_sbom.sh"]
