# Stage 1: Build kcov from source so the container matches CI (.github/workflows/_shell-coverage.yml).
# kcov is not available via apt in Bookworm, the kcov/kcov image publishes no v43 tag, and its
# "latest" tag is unpinned. Keep KCOV_VERSION equal to the CI value.
FROM mcr.microsoft.com/devcontainers/python:3.3.2-3.13-bookworm AS kcov-build
ARG KCOV_VERSION=v43
RUN rm -f /etc/apt/sources.list.d/yarn.list \
    && apt-get update && export DEBIAN_FRONTEND=noninteractive \
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
FROM mcr.microsoft.com/devcontainers/python:3.3.2-3.13-bookworm
USER root
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Keep the selected base's Python and Git; do not copy an older Python over it.
ARG GIT_VERSION=2.56.0
ENV NVM_DIR="" \
    DOTNET_CLI_TELEMETRY_OPTOUT=1 \
    DOTNET_ROOT=/usr/share/dotnet \
    PYTHONPYCACHEPREFIX=/tmp/pycache \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    DISABLE_AUTOUPDATER=1 \
    PATH="/usr/local/bin:/usr/local/py-utils/bin:/usr/local/jupyter:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"
RUN test "$(python --version)" = "Python 3.13.18" \
    && dpkg --compare-versions "$(git --version | awk '{print $3}')" ge "${GIT_VERSION}"

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
    # Shell QC tooling (formatting and lint binaries are pinned below)
    bats \
    # Runtime libraries for the kcov build copied from the first stage
    binutils \
    libcurl4 \
    libdw1 \
    libelf1 \
    libssl3 \
    libicu72 \
    xz-utils \
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

# Match the updated host development runtime; preserve independent consumer engine support.
ARG NODE_VERSION=26.13.0
RUN arch="$(dpkg --print-architecture)" \
    && case "$arch" in amd64) node_arch=x64 ;; arm64) node_arch=arm64 ;; *) exit 1 ;; esac \
    && curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${node_arch}.tar.xz" \
    | tar -xJ -C /usr/local --strip-components=1 --exclude=CHANGELOG.md --exclude=LICENSE --exclude=README.md \
    && test "$(node --version)" = "v${NODE_VERSION}" \
    && test "$(npm --version)" = "11.20.0" \
    && rm -rf /var/lib/apt/lists/*

# Install shfmt at the version CI pins (.github/workflows/_shell-coverage.yml); the Bookworm
# package is older and formats differently. Keep SHFMT_VERSION equal to the CI value.
ARG SHFMT_VERSION=3.14.1
RUN arch="$(dpkg --print-architecture)" \
    && wget -q -O /usr/local/bin/shfmt \
    "https://github.com/mvdan/sh/releases/download/v${SHFMT_VERSION}/shfmt_v${SHFMT_VERSION}_linux_${arch}" \
    && chmod +x /usr/local/bin/shfmt

# Bookworm's ShellCheck package is older than the development baseline.
ARG SHELLCHECK_VERSION=0.11.0
RUN arch="$(uname -m)" \
    && wget -q -O /tmp/shellcheck.tar.xz \
    "https://github.com/koalaman/shellcheck/releases/download/v${SHELLCHECK_VERSION}/shellcheck-v${SHELLCHECK_VERSION}.linux.${arch}.tar.xz" \
    && tar -xJf /tmp/shellcheck.tar.xz -C /tmp \
    && install -m 755 "/tmp/shellcheck-v${SHELLCHECK_VERSION}/shellcheck" /usr/local/bin/shellcheck \
    && rm -rf /tmp/shellcheck.tar.xz "/tmp/shellcheck-v${SHELLCHECK_VERSION}"

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

# Use the verified Debian package version for the updated PowerShell baseline.
ARG POWERSHELL_VERSION=7.6.9
RUN wget -q https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb \
    && apt-get update \
    && apt-get install -y "powershell=${POWERSHELL_VERSION}-1.deb" \
    && rm -rf /var/lib/apt/lists/*

# Install GitHub CLI here so a floating devcontainer feature cannot change its pin.
ARG GH_VERSION=2.103.3
RUN arch="$(dpkg --print-architecture)" \
    && curl -fsSL -o /tmp/gh.deb \
    "https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_${arch}.deb" \
    && apt-get update \
    && apt-get install -y --no-install-recommends /tmp/gh.deb \
    && rm -f /tmp/gh.deb \
    && rm -rf /var/lib/apt/lists/*

# Install Graphite CLI for the Graphite VS Code extension.
# Pinned for repeatable devcontainer builds.
ARG GRAPHITE_CLI_VERSION=1.7.14
RUN npm install -g "@withgraphite/graphite-cli@${GRAPHITE_CLI_VERSION}"

# Install the Claude Code CLI, pinned to the version this repository's orchestration is run with.
# Authenticate inside the container (claude, then /login); credentials are not baked into the image.
ARG CLAUDE_CODE_VERSION=2.1.318
RUN npm install -g "@anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}"

# Install claude-swap (the cswap account switcher), pinned. It requires Python 3.12 or newer.
ARG CODEX_VERSION=0.166.0
RUN npm install -g --include=optional "@openai/codex@${CODEX_VERSION}" \
    && mkdir -p /etc/codex \
    && printf 'check_for_update_on_startup = false\ncli_auth_credentials_store = "file"\n' > /etc/codex/config.toml

# Use the selected base Python for cswap and keep tool environments outside the workspace.
ARG UV_VERSION=0.13.7
ARG CLAUDE_SWAP_VERSION=0.29.0
RUN curl -LsSf "https://astral.sh/uv/${UV_VERSION}/install.sh" \
    | env UV_UNMANAGED_INSTALL=/usr/local/bin sh \
    && UV_TOOL_DIR=/opt/uv/tools UV_TOOL_BIN_DIR=/usr/local/bin UV_PYTHON_DOWNLOADS=never \
    uv tool install "claude-swap==${CLAUDE_SWAP_VERSION}" --python 3.13

ARG DOTNET_SDK_VERSION=10.0.403
RUN curl -fsSL -o /tmp/dotnet-install.sh https://dot.net/v1/dotnet-install.sh \
    && bash /tmp/dotnet-install.sh --version "${DOTNET_SDK_VERSION}" --install-dir /usr/share/dotnet \
    && ln -sf /usr/share/dotnet/dotnet /usr/local/bin/dotnet \
    && rm -f /tmp/dotnet-install.sh

# Install Poetry
ARG POETRY_VERSION=2.5.1
RUN PIPX_HOME=/opt/pipx PIPX_BIN_DIR=/usr/local/bin pipx install "poetry==${POETRY_VERSION}"

# Set working directory
WORKDIR /workspaces/drm-copilot

# Install the selected PowerShell modules for every container user.
ARG PESTER_VERSION=6.2.0
ARG PSSA_VERSION=1.25.0
RUN pwsh -NoLogo -NoProfile -Command " \
    \$ErrorActionPreference = 'Stop'; \
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted; \
    Install-Module -Name PSScriptAnalyzer -RequiredVersion '${PSSA_VERSION}' -Scope AllUsers -Force; \
    Install-Module -Name Pester -RequiredVersion '${PESTER_VERSION}' -Scope AllUsers -Force -SkipPublisherCheck; \
    "

# Empty, user-owned state directories are safe initial contents for optional state volumes.
RUN mkdir -p /home/vscode/.claude /home/vscode/.local/share/claude-swap /home/vscode/.codex \
    && chown -R vscode:vscode /home/vscode/.claude /home/vscode/.local /home/vscode/.codex

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
