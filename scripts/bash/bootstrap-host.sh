#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST_PATH="${SCRIPT_DIR}/../powershell/BootstrapPC/host-tools.manifest.json"

APPLY=false
if [[ "${1:-}" == "--apply" ]]; then
  APPLY=true
fi

if [[ ! -f "${MANIFEST_PATH}" ]]; then
  echo "❌ Manifest not found: ${MANIFEST_PATH}"
  exit 1
fi

manifest_powershell_modules() {
  python3 - "$MANIFEST_PATH" <<'PY'
import json
import sys
from pathlib import Path

manifest_path = Path(sys.argv[1])
manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
for item in manifest["powershellModules"]:
    print(f"{item['name']}|{item['minimumVersion']}")
PY
}

manifest_packages() {
  local os_key="$1"
  local manager_key="$2"
  python3 - "$MANIFEST_PATH" "$os_key" "$manager_key" <<'PY'
import json
import sys
from pathlib import Path

manifest_path = Path(sys.argv[1])
os_key = sys.argv[2]
manager_key = sys.argv[3]

manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
packages = (
    manifest.get("installPackages", {})
    .get(os_key, {})
    .get(manager_key, [])
)
for item in packages:
    package = item.get("package", "")
    command = item.get("command", package)
    print(f"{package}|{command}")
PY
}

echo "========================================="
echo "Host Bootstrap (Linux/macOS)"
echo "========================================="

install_with_apt() {
  local package="$1"
  local command_name="${2:-$1}"
  if command -v "$command_name" >/dev/null 2>&1; then
    echo "✓ ${command_name} already installed"
    return
  fi

  if [[ "$APPLY" == "true" ]]; then
    sudo apt-get update
    sudo apt-get install -y "$package"
  else
    echo "- Would install via apt: $package"
  fi
}

install_with_brew() {
  local package="$1"
  local command_name="${2:-$1}"
  if command -v "$command_name" >/dev/null 2>&1; then
    echo "✓ ${command_name} already installed"
    return
  fi

  if [[ "$APPLY" == "true" ]]; then
    brew install "$package"
  else
    echo "- Would install via brew: $package"
  fi
}

if command -v apt-get >/dev/null 2>&1; then
  echo "Using apt package manager"
  while IFS='|' read -r package command_name; do
    [[ -z "$package" ]] && continue
    install_with_apt "$package" "$command_name"
  done < <(manifest_packages "linux" "apt")
elif command -v brew >/dev/null 2>&1; then
  echo "Using Homebrew package manager"
  while IFS='|' read -r package command_name; do
    [[ -z "$package" ]] && continue
    install_with_brew "$package" "$command_name"
  done < <(manifest_packages "macos" "brew")
else
  echo "No supported package manager found. Install tools manually."
  exit 1
fi

if command -v pipx >/dev/null 2>&1; then
  if [[ "$APPLY" == "true" ]]; then
    pipx install poetry || pipx upgrade poetry
  else
    echo "- Would install Poetry via pipx"
  fi
else
  if [[ "$APPLY" == "true" ]]; then
    python3 -m pip install --user poetry
  else
    echo "- Would install Poetry via python3 -m pip --user"
  fi
fi

if command -v npm >/dev/null 2>&1; then
  if [[ "$APPLY" == "true" ]]; then
    npm install -g @withgraphite/graphite-cli@1.7.14
  else
    echo "- Would install Graphite CLI via npm"
  fi
fi

if [[ "$APPLY" == "true" ]]; then
  while IFS='|' read -r module_name module_version; do
    [[ -z "$module_name" ]] && continue
    pwsh -NoLogo -NoProfile -Command "Install-Module -Name '${module_name}' -RequiredVersion '${module_version}' -Scope CurrentUser -AllowClobber -Force"
  done < <(manifest_powershell_modules)

  if command -v curl >/dev/null 2>&1; then
    curl -sSfL https://gh.io/copilot-install | bash
  elif command -v wget >/dev/null 2>&1; then
    wget -qO- https://gh.io/copilot-install | bash
  else
    echo "⚠️  curl/wget missing; install Copilot CLI manually: https://gh.io/copilot-install"
  fi

  bash "$(dirname "$0")/verify-host.sh"
else
  module_preview="$(manifest_powershell_modules | sed 's/|/ /g' | paste -sd ', ' -)"
  echo "- Would install PowerShell modules: ${module_preview}"
  echo ""
  echo "Dry run complete. Re-run with --apply to install tools."
fi