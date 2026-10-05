# syntax=docker/dockerfile:1.7
ARG BASE_IMAGE=docker/sandbox-templates:shell-docker
FROM ${BASE_IMAGE}

ARG BASE_IMAGE

USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        fd-find \
        pkg-config && \
    rm -rf /var/lib/apt/lists/* && \
    ln -sf "$(command -v fdfind)" /usr/local/bin/fd

ARG PI_VERSION=latest
ARG OPENSPEC_VERSION=latest
USER root
ADD --chmod=644 https://registry.npmjs.org/@earendil-works%2Fpi-coding-agent/${PI_VERSION} /tmp/pi-latest.json
ADD --chmod=644 https://registry.npmjs.org/@fission-ai%2Fopenspec/${OPENSPEC_VERSION} /tmp/openspec-latest.json

USER agent
ENV CARGO_HOME=/home/agent/.cargo \
    RUSTUP_HOME=/home/agent/.rustup \
    PATH=/home/agent/.cargo/bin:${PATH}
RUN pi_version="$(node -p 'require("/tmp/pi-latest.json").version')" && \
    openspec_version="$(node -p 'require("/tmp/openspec-latest.json").version')" && \
    npm install -g \
        "@earendil-works/pi-coding-agent@${pi_version}" \
        "@fission-ai/openspec@${openspec_version}" && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
        sh -s -- -y --profile minimal --default-toolchain stable && \
    rustup component add clippy rustfmt && \
    pi --version && \
    openspec --version && \
    cargo --version && \
    rustc --version && \
    cargo clippy --version && \
    rustfmt --version

USER root
RUN ln -sf "$(npm prefix -g)/bin/pi" /usr/local/bin/pi && \
    ln -sf "$(npm prefix -g)/bin/openspec" /usr/local/bin/openspec

LABEL com.docker.sandboxes.start-docker="true"
LABEL com.docker.sandboxes.flavor="pi"
LABEL com.docker.sandboxes.base="${BASE_IMAGE}"
LABEL org.opencontainers.image.source="https://github.com/rocknitive/pi-kit"

USER agent
WORKDIR /home/agent
CMD ["pi"]
