#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

install_with_retries() {
  local attempts=5
  local delay=5
  local i=1
  while [ "$i" -le "$attempts" ]; do
    if "$@"; then
      return 0
    fi
    echo "Attempt $i/$attempts failed; retrying in ${delay}s..."
    sleep "$delay"
    i=$((i + 1))
  done
  echo "ERROR: command failed after $attempts attempts: $*" >&2
  return 1
}

apt_with_retries() {
  local attempts="${APT_RETRY_ATTEMPTS:-5}"
  local delay="${APT_RETRY_DELAY_SECONDS:-5}"
  local i=1
  while [ "$i" -le "$attempts" ]; do
    if "$@"; then
      return 0
    fi
    echo "Attempt $i/$attempts failed; retrying in ${delay}s..."
    if [ "$i" -lt "$attempts" ]; then
      sleep "$delay"
    fi
    i=$((i + 1))
  done
  echo "ERROR: command failed after $attempts attempts: $*" >&2
  return 1
}

apt_update() {
  local timeout="${APT_HTTP_TIMEOUT_SECONDS:-30}"
  local opts=(-o "Acquire::http::Timeout=${timeout}")
  if [ "${APT_DISABLE_PIPELINING:-0}" = "1" ]; then
    opts+=(-o "Acquire::http::Pipeline-Depth=0")
  fi
  apt_with_retries apt-get "${opts[@]}" update -qq
}

apt_install() {
  local timeout="${APT_HTTP_TIMEOUT_SECONDS:-30}"
  local opts=(-o "Acquire::http::Timeout=${timeout}")
  apt_with_retries apt-get "${opts[@]}" install -y --no-install-recommends --fix-missing "$@"
}

check_pypi_connectivity() {
  if [ "${ALLOW_OFFLINE_INSTALL:-0}" = "1" ]; then
    echo "ALLOW_OFFLINE_INSTALL=1 set; skipping PyPI connectivity check."
    return 0
  fi

  if curl -I -s --max-time 5 https://pypi.org/simple >/dev/null; then
    return 0
  fi

  echo "ERROR: Unable to reach pypi.org (check network/DNS or set ALLOW_OFFLINE_INSTALL=1 to skip)." >&2
  echo "Tip: set POETRY_PYPI_URL to a reachable mirror if direct PyPI access is blocked." >&2
  return 1
}

ensure_pwsh() {
  local required="7.6.0"

  if command -v pwsh >/dev/null 2>&1; then
    local current
    current="$(pwsh --version | awk '{print $2}')"
    if dpkg --compare-versions "$current" ge "$required"; then
      echo "pwsh $current present; meets requirement ($required)."
      return 0
    fi
    echo "pwsh $current present; upgrading to >= $required..."
  else
    echo "pwsh not found; installing PowerShell..."
  fi

  local os_id="" os_version="" repo_url="" fallback_version="7.6.0"
  if [ -r /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    os_id="${ID:-}"
    os_version="${VERSION_ID:-}"
  fi

  if [[ "$os_id" == "ubuntu" || "$os_id" == "debian" ]]; then
    repo_url="https://packages.microsoft.com/config/${os_id}/${os_version:-12}/packages-microsoft-prod.deb"
  else
    repo_url="https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb"
  fi

  apt_update
  apt_install ca-certificates curl wget apt-transport-https gnupg software-properties-common

  local repo_ok=0
  if wget -q "$repo_url" -O /tmp/packages-microsoft-prod.deb; then
    if dpkg -i /tmp/packages-microsoft-prod.deb; then
      repo_ok=1
    fi
  fi
  rm -f /tmp/packages-microsoft-prod.deb

  if [ "$repo_ok" -eq 1 ]; then
    apt_update
    if apt_install powershell; then
      return 0
    fi
    echo "PowerShell install from distro feed failed; falling back to GitHub package." >&2
  else
    echo "PowerShell feed bootstrap failed for ${os_id:-unknown}; falling back to GitHub package." >&2
  fi

  local pwsh_deb="powershell_${fallback_version}-1.deb_amd64.deb"
  local pwsh_url="https://github.com/PowerShell/PowerShell/releases/download/v${fallback_version}/${pwsh_deb}"
  echo "Downloading PowerShell fallback from: ${pwsh_url}"
  wget -qO /tmp/powershell.deb "$pwsh_url"
  apt_install /tmp/powershell.deb
  rm -f /tmp/powershell.deb
}

main() {
  echo "=== drm-copilot setup: start ==="
  echo "Working directory: $(pwd)"

  PYTHON_EXE="${PYTHON_EXE:-}"
  if [ -n "$PYTHON_EXE" ]; then
    if [ ! -x "$PYTHON_EXE" ]; then
      echo "ERROR: PYTHON_EXE was provided but is not executable: $PYTHON_EXE" >&2
      exit 1
    fi

    python_bin_dir="$(dirname "$PYTHON_EXE")"
    export PATH="$python_bin_dir:$PATH"
    echo "Using explicit PYTHON_EXE=$PYTHON_EXE"
  else
    PYTHON_EXE="python3"
    echo "PYTHON_EXE not provided; falling back to $PYTHON_EXE from PATH"
  fi

  REPO_ROOT="${WORKSPACE_FOLDER:-}"
  if [ -z "$REPO_ROOT" ] || [ ! -d "$REPO_ROOT" ]; then
    REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
  fi

  REPO_ROOT="$(cd "$REPO_ROOT" && pwd)"
  export REPO_ROOT

  if [ ! -f "$REPO_ROOT/scripts/powershell/PoshQC/PoshQC.psd1" ]; then
    repo_name="$(basename "$REPO_ROOT")"
    for candidate in "/workspaces/$repo_name" "/workspace/$repo_name"; do
      if [ -f "$candidate/scripts/powershell/PoshQC/PoshQC.psd1" ]; then
        REPO_ROOT="$candidate"
        export REPO_ROOT
        break
      fi
    done
  fi

  if command -v poetry >/dev/null 2>&1; then
    echo "Poetry present ($(poetry --version)); reusing existing installation."
  else
    echo "Poetry not found; installing Poetry 2.2.1 (devcontainer baseline)..."
    "$PYTHON_EXE" -m pip install --no-cache-dir "poetry==2.2.1"
  fi

  cd "$REPO_ROOT"
  poetry config virtualenvs.in-project true --local

  if [ -n "${POETRY_PYPI_URL:-}" ]; then
    echo "Using custom POETRY_PYPI_URL=${POETRY_PYPI_URL}"
    poetry config repositories.main "$POETRY_PYPI_URL"
    poetry config pypi-token.main "" 2>/dev/null || true
  fi

  check_pypi_connectivity

  if [ -d ".venv" ] && [ ! -x ".venv/bin/python" ]; then
    echo "Detected broken .venv; removing and recreating..."
    rm -rf .venv
  fi

  if [ -f "poetry.lock" ]; then
    echo "poetry.lock found; installing locked dependencies with --with dev..."
    install_with_retries poetry install --no-interaction --no-ansi --with dev
  elif [ -f "pyproject.toml" ]; then
    echo "poetry.lock missing; locking and installing with --with dev..."
    install_with_retries poetry lock --no-interaction --no-ansi
    install_with_retries poetry install --no-interaction --no-ansi --with dev
  else
    echo "No pyproject.toml found; skipping Python dependency installation."
  fi

  ensure_pwsh

  if command -v pwsh >/dev/null 2>&1; then
    echo "PowerShell installed. Checking modules from PSGallery..."

    # shellcheck disable=SC2016  # PowerShell variables must remain literal inside the single-quoted command string.
    pwsh -NoLogo -NoProfile -Command '
      $ErrorActionPreference = "Stop"

      Write-Host "=== [ps] Checking PSScriptAnalyzer / Pester availability ==="

      try {
        if (-not (Get-PSRepository -Name "PSGallery" -ErrorAction SilentlyContinue)) {
          Register-PSRepository -Default -ErrorAction SilentlyContinue
        }
      } catch {
        Write-Warning "Register-PSRepository -Default failed: $($_.Exception.Message)"
      }

      try {
        Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted -ErrorAction SilentlyContinue
      } catch {
        Write-Warning "Set-PSRepository PSGallery failed: $($_.Exception.Message)"
      }

      $required = @(
        @{ Name = "PSScriptAnalyzer"; Version = "1.22.0" },
        @{ Name = "Pester"; Version = "5.6.1" }
      )

      foreach ($module in $required) {
        $installed = Get-Module -ListAvailable -Name $module.Name |
          Where-Object { $_.Version -ge [version]$module.Version } |
          Sort-Object Version -Descending |
          Select-Object -First 1

        if ($installed) {
          Write-Host "Found $($module.Name) $($installed.Version)"
          continue
        }

        Write-Host "Installing $($module.Name) $($module.Version) (CurrentUser scope)..."
        Install-Module -Name $module.Name -RequiredVersion $module.Version -Scope CurrentUser -AllowClobber -Force -ErrorAction Stop
      }

      Write-Host "=== [ps] Final module list ==="
      Get-Module -ListAvailable PSScriptAnalyzer, Pester |
        Sort-Object Name, Version -Descending |
        Format-Table Name, Version, ModuleBase
    '

    POSHQC_PATH="$REPO_ROOT/scripts/powershell/PoshQC/PoshQC.psd1"
    if [ ! -f "$POSHQC_PATH" ]; then
      echo "PoshQC module missing; attempting to restore from git..." >&2
      if command -v git >/dev/null 2>&1 && git -C "$REPO_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        git -C "$REPO_ROOT" checkout HEAD -- scripts/powershell/PoshQC >/dev/null 2>&1 || true

        if [ ! -f "$POSHQC_PATH" ]; then
          echo "PoshQC still missing; attempting fetch from origin/development..." >&2
          git -C "$REPO_ROOT" fetch origin development:refs/remotes/origin/development >/dev/null 2>&1 || true
          git -C "$REPO_ROOT" checkout origin/development -- scripts/powershell/PoshQC >/dev/null 2>&1 || true
        fi

        if [ ! -f "$POSHQC_PATH" ]; then
          echo "PoshQC still missing; attempting fetch from origin/master..." >&2
          git -C "$REPO_ROOT" fetch origin master:refs/remotes/origin/master >/dev/null 2>&1 || true
          git -C "$REPO_ROOT" checkout origin/master -- scripts/powershell/PoshQC >/dev/null 2>&1 || true
        fi
      fi
    fi

    if [ -f "$POSHQC_PATH" ]; then
      echo "Importing PoshQC module (required for parity)..."
      # shellcheck disable=SC2016  # PowerShell variables must remain literal inside the single-quoted command string.
      pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass \
        -Command '& { Import-Module "$env:REPO_ROOT/scripts/powershell/PoshQC/PoshQC.psd1" -Force; Get-Command -Module PoshQC | Out-Host }'
    else
      echo "ERROR: PoshQC module not found at $POSHQC_PATH" >&2
      if command -v git >/dev/null 2>&1 && git -C "$REPO_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "ERROR: git tracking info for PoshQC:" >&2
        git -C "$REPO_ROOT" ls-files --stage scripts/powershell/PoshQC/PoshQC.psd1 >&2 || true
      fi
      exit 1
    fi
  else
    echo "pwsh is not available; skipping PowerShell tooling setup."
  fi

  if ! command -v jq >/dev/null 2>&1; then
    echo "Installing jq..."
    apt_update
    apt_install jq
  else
    echo "jq already installed"
  fi

  if ! command -v shfmt >/dev/null 2>&1 || ! command -v shellcheck >/dev/null 2>&1 || ! command -v bats >/dev/null 2>&1; then
    echo "Installing shell QC tools (shfmt, shellcheck, bats)..."
    apt_update
    apt_install shfmt shellcheck bats
  else
    echo "shfmt, shellcheck, and bats already installed"
  fi

  if ! command -v kcov >/dev/null 2>&1; then
    echo "Installing kcov from upstream release..."
    tmp_kcov_dir="$(mktemp -d)"
    wget -qO "$tmp_kcov_dir/kcov.tar.gz" "https://github.com/SimonKagstrom/kcov/releases/download/v43/kcov-amd64.tar.gz"
    tar -xzf "$tmp_kcov_dir/kcov.tar.gz" -C "$tmp_kcov_dir"
    install -m 0755 "$tmp_kcov_dir/usr/local/bin/kcov" /usr/local/bin/kcov
    rm -rf "$tmp_kcov_dir"
  else
    echo "kcov already installed"
  fi

  if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
    echo "Installing node and npm..."
    apt_update
    apt_install nodejs npm
  else
    echo "node and npm already installed"
  fi

  if ! command -v actionlint >/dev/null 2>&1; then
    echo "Installing actionlint..."
    wget -q -O - https://raw.githubusercontent.com/rhysd/actionlint/main/scripts/download-actionlint.bash | bash -s -- latest /usr/local/bin
  else
    echo "actionlint already installed"
  fi

  echo "=== drm-copilot setup: done ==="
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then main "$@"; fi