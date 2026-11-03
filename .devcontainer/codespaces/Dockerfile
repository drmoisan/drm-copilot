# Use Python 3.13 base image with Debian Bookworm
# Stage 1: Build kcov from source so the container matches CI (.github/workflows/_shell-coverage.yml).
# kcov is not available via apt in Bookworm, the kcov/kcov image publishes no v43 tag, and its
# "latest" tag is unpinned. Keep KCOV_VERSION equal to the CI value.
FROM mcr.microsoft.com/devcontainers/python:3.13-bookworm AS kcov-build
ARG KCOV_VERSION=v43
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --no-install-recommends \
    binutils-dev \
    build-essential \
    ca-certificates \
    cmake \
    git \
    libcurl4-openssl-dev \
    libdw-dev \
    libelf-dev \
    libiberty-dev \
    libssl-dev \
    libstdc++-12-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/* \
    && git clone --depth 1 --branch "${KCOV_VERSION}" https://github.com/SimonKagstrom/kcov.git /tmp/kcov-src \
    && mkdir /tmp/kcov-src/build \
    && cd /tmp/kcov-src/build \
    && cmake -DCMAKE_INSTALL_PREFIX=/opt/kcov .. \
    && make -j"$(nproc)" \
    && make install

# Stage 2: Main devcontainer image
FROM mcr.microsoft.com/devcontainers/python:3.13-bookworm

# Copy the kcov install tree from the build stage
COPY --from=kcov-build /opt/kcov/ /usr/local/

# Remove Yarn apt repository (inherited from base image; GPG key expired and we don't use Yarn)
RUN rm -f /etc/apt/sources.list.d/yarn.list

# Install PowerShell
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --no-install-recommends \
    # Dependencies for PowerShell and general tooling
    ca-certificates \
    curl \
    git \
    gnupg \
    wget \
    apt-transport-https \
    software-properties-common \
    # Shell QC tooling (shfmt is installed below at the CI-pinned version)
    shellcheck \
    bats \
    # Runtime libraries for the kcov build copied from the first stage
    binutils \
    libcurl4 \
    libdw1 \
    libelf1 \
    libssl3 \
    zlib1g \
    # Bash debugger build dependencies
    autoconf \
    automake \
    build-essential \
    texinfo \
    # Clipboard utilities for pyperclip fallback
    wl-clipboard \
    xclip \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js. CI runs the extension and root TypeScript tests on Node 20
# (node-version "20" in .github/workflows), and Debian Bookworm packages Node 18, so install
# from NodeSource. Node is required for Claude Code, Graphite CLI, ESLint, Jest and bash-language-server.
ARG NODE_MAJOR=20
RUN wget -qO- "https://deb.nodesource.com/setup_${NODE_MAJOR}.x" | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install shfmt at the version CI pins (.github/workflows/_shell-coverage.yml); the Bookworm
# package is older and formats differently. Keep SHFMT_VERSION equal to the CI value.
ARG SHFMT_VERSION=3.8.0
RUN arch="$(dpkg --print-architecture)" \
    && wget -q -O /usr/local/bin/shfmt \
    "https://github.com/mvdan/sh/releases/download/v${SHFMT_VERSION}/shfmt_v${SHFMT_VERSION}_linux_${arch}" \
    && chmod +x /usr/local/bin/shfmt

# Build and install bashdb (not packaged for all Debian/Ubuntu bases)
RUN git clone --depth 1 https://github.com/Trepan-Debuggers/bashdb /tmp/bashdb \
    && cd /tmp/bashdb \
    && bash ./autogen.sh \
    && bash ./configure \
    && make \
    && make install \
    && rm -rf /tmp/bashdb

# Add clip.exe compatibility shim for Linux containers.
# This supports scripts/tools that expect the Windows clip.exe command.
RUN printf '%s\n' '#!/usr/bin/env bash' 'exec xclip -selection clipboard "$@"' > /usr/local/bin/clip.exe \
    && chmod +x /usr/local/bin/clip.exe

# Install PowerShell 7.6 from Microsoft repository (the repository baseline is 7.6;
# the wildcard takes the newest 7.6.x patch and refuses a 7.7 upgrade)
RUN wget -q https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb \
    && apt-get update \
    && apt-get install -y "powershell=7.6.*" \
    && rm -rf /var/lib/apt/lists/*

# Install Graphite CLI for the Graphite VS Code extension.
# Pinned for repeatable devcontainer builds.
ARG GRAPHITE_CLI_VERSION=1.7.14
RUN npm install -g "@withgraphite/graphite-cli@${GRAPHITE_CLI_VERSION}"

# Install the Claude Code CLI, pinned to the version this repository's orchestration is run with.
# Authenticate inside the container (claude, then /login); credentials are not baked into the image.
ARG CLAUDE_CODE_VERSION=2.1.316
RUN npm install -g "@anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}"

# Install claude-swap (the cswap account switcher), pinned. It requires Python 3.12 or newer.
ARG CLAUDE_SWAP_VERSION=0.28.0
RUN pip install --no-cache-dir "claude-swap==${CLAUDE_SWAP_VERSION}"

# Install Poetry
RUN pip install --no-cache-dir poetry==2.2.1

# Configure Poetry to create virtual environments in project directory
RUN poetry config virtualenvs.in-project true

# Set working directory
WORKDIR /workspaces/drm-copilot

# Copy pyproject.toml and poetry.lock for dependency installation
# COPY pyproject.toml poetry.lock* ./

# Install Python dependencies (will be cached unless these files change)
# Note: This creates a basic venv; the post-create script will finalize it
# RUN poetry install --no-interaction --no-ansi --with dev || true

# Install PowerShell modules as root for all users. Pester is held to the range CI imports
# (5.9.0 up to, but not including, 6.0) so an unpinned install cannot pick up Pester 6.
RUN pwsh -NoLogo -NoProfile -Command " \
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted; \
    Install-Module -Name PSScriptAnalyzer -Scope AllUsers -Force; \
    Install-Module -Name Pester -MinimumVersion 5.9.0 -MaximumVersion 5.99.99 -Scope AllUsers -Force; \
    "

# Create non-root user (vscode is created by base image)
# Switch to vscode user
USER vscode

# Set up PowerShell profile location for vscode user
RUN mkdir -p ~/.config/powershell

# Install actionlint for GitHub Actions workflow linting, pinned for repeatable builds.
# The installer script is fetched from the same tag as the binary.
USER root
ARG ACTIONLINT_VERSION=1.7.12
RUN wget -q -O - "https://raw.githubusercontent.com/rhysd/actionlint/v${ACTIONLINT_VERSION}/scripts/download-actionlint.bash" \
    | bash -s -- "${ACTIONLINT_VERSION}" /usr/local/bin

# Install GitHub Copilot CLI (real agentic CLI, not the VS Code extension shim).
# Pinned to a known-good release for repeatable devcontainer builds.
ARG COPILOT_CLI_VERSION=0.0.377
RUN wget -qO- https://gh.io/copilot-install \
    | VERSION="${COPILOT_CLI_VERSION}" PREFIX="/usr/local" bash
USER vscode

# Set default shell to PowerShell for convenience
ENV SHELL=/usr/bin/pwsh

# The actual project files will be mounted at runtime
# Dependencies will be installed via postCreateCommand
