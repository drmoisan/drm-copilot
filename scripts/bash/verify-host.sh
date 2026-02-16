#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST_PATH="${SCRIPT_DIR}/../host-tools.manifest.json"

failure_count=0

if [[ ! -f "${MANIFEST_PATH}" ]]; then
  echo "❌ Manifest not found: ${MANIFEST_PATH}"
  exit 1
fi

manifest_python() {
  python3 - "$MANIFEST_PATH" "$@" <<'PY'
import json
import sys
from pathlib import Path

manifest_path = Path(sys.argv[1])
mode = sys.argv[2]

manifest = json.loads(manifest_path.read_text(encoding="utf-8"))

if mode == "minimum":
    print(manifest["minimumVersions"][sys.argv[3]])
elif mode == "array":
    for item in manifest[sys.argv[3]]:
        print(item)
elif mode == "powershellModules":
    for item in manifest["powershellModules"]:
        print(f"{item['name']}|{item['minimumVersion']}")
else:
    raise SystemExit(f"Unsupported mode: {mode}")
PY
}

require_command() {
  local name="$1"
  if command -v "$name" >/dev/null 2>&1; then
    echo "  ✅ $name: $(command -v "$name")"
  else
    echo "  ❌ $name: not found"
    failure_count=$((failure_count + 1))
  fi
}

version_at_least() {
  local actual="$1"
  local minimum="$2"
  python3 - "$actual" "$minimum" <<'PY'
import re
import sys

actual = sys.argv[1]
minimum = sys.argv[2]

def parse(value: str) -> tuple[int, ...]:
    match = re.search(r"(\d+\.\d+(?:\.\d+)?)", value)
    if not match:
        return tuple()
    return tuple(int(part) for part in match.group(1).split("."))

act = parse(actual)
req = parse(minimum)
sys.exit(0 if act >= req else 1)
PY
}

check_version() {
  local name="$1"
  local command="$2"
  local min_version="$3"

  if ! command -v "$command" >/dev/null 2>&1; then
    echo "  ❌ $name: not found"
    failure_count=$((failure_count + 1))
    return
  fi

  local output
  output="$($command --version 2>&1 | head -n1)"
  if version_at_least "$output" "$min_version"; then
    echo "  ✅ $name: $output (>= $min_version)"
  else
    echo "  ❌ $name: $output (requires >= $min_version)"
    failure_count=$((failure_count + 1))
  fi
}

check_powershell_module() {
  local module_name="$1"
  local min_version="$2"

  if ! command -v pwsh >/dev/null 2>&1; then
    echo "  ❌ ${module_name}: pwsh not found"
    failure_count=$((failure_count + 1))
    return
  fi

  local module_version
  module_version="$({
    pwsh -NoLogo -NoProfile -Command "\
      \$module = Get-Module -ListAvailable -Name '${module_name}' | Sort-Object Version -Descending | Select-Object -First 1;\
      if (\$null -eq \$module) { exit 1 };\
      Write-Output \$module.Version" 2>/dev/null
  } || true)"

  module_version="$(echo "$module_version" | head -n1 | tr -d '\r')"
  if [[ -z "$module_version" ]]; then
    echo "  ❌ ${module_name}: not found"
    failure_count=$((failure_count + 1))
    return
  fi

  if version_at_least "$module_version" "$min_version"; then
    echo "  ✅ ${module_name}: ${module_version} (>= ${min_version})"
  else
    echo "  ❌ ${module_name}: ${module_version} (requires >= ${min_version})"
    failure_count=$((failure_count + 1))
  fi
}

echo "========================================="
echo "Host Environment Verification"
echo "========================================="
echo ""

echo "Core versions:"
check_version "python" "python3" "$(manifest_python minimum python)"
check_version "poetry" "poetry" "$(manifest_python minimum poetry)"
check_version "pwsh" "pwsh" "$(manifest_python minimum pwsh)"
check_version "node" "node" "$(manifest_python minimum node)"

echo ""
echo "Required commands:"
while IFS= read -r cmd; do
  [[ -z "$cmd" ]] && continue
  require_command "$cmd"
done < <(manifest_python array requiredCommands)

echo ""
echo "Optional commands:"
while IFS= read -r cmd; do
  [[ -z "$cmd" ]] && continue
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "  ✅ $cmd: $(command -v "$cmd")"
  else
    echo "  ⚠️  $cmd: not found (optional)"
  fi
done < <(manifest_python array optionalCommands)

echo ""
echo "PowerShell modules:"
while IFS='|' read -r module_name module_min; do
  [[ -z "$module_name" ]] && continue
  check_powershell_module "$module_name" "$module_min"
done < <(manifest_python powershellModules)

echo ""
echo "Poetry quality tools:"
if command -v poetry >/dev/null 2>&1; then
  while IFS= read -r tool; do
    [[ -z "$tool" ]] && continue
    if poetry run "$tool" --version >/dev/null 2>&1; then
      echo "  ✅ $tool"
    else
      echo "  ❌ $tool: not available via poetry"
      failure_count=$((failure_count + 1))
    fi
  done < <(manifest_python array pythonTools)
else
  echo "  ❌ poetry: not found (cannot verify Python tooling)"
  failure_count=$((failure_count + 1))
fi

echo ""
echo "========================================="
if [[ "$failure_count" -eq 0 ]]; then
  echo "✅ Host verification passed"
  exit 0
fi

echo "⚠️  Host verification failed with $failure_count issue(s)"
echo "Run: ./scripts/bash/bootstrap-host.sh --apply"
exit 1