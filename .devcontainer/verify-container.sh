#!/usr/bin/env bash
# Verify the development baseline and mounted workspace in either devcontainer.
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(dirname -- "$SCRIPT_DIR")
# The source path is derived from this entrypoint rather than the caller's directory.
# shellcheck source=scripts/bash/container_versions.sh
# shellcheck disable=SC1091
source "$REPO_ROOT/scripts/bash/container_versions.sh"

# Read a tool's native version output and normalize it for the pure predicate.
# Argument: required tool name. Prints its parsed version; returns 1 on native failure.
read_container_tool_version() {
	local tool=$1 output
	if ! output=$("$tool" --version 2>&1); then
		return 1
	fi
	# Native version formats differ; consume complete output to avoid pipefail/SIGPIPE.
	case "$tool" in
	python | pwsh) printf '%s\n' "$output" | awk 'NR == 1 { print $2 }' ;;
	poetry) printf '%s\n' "$output" | sed -nE 's/.*version ([0-9.]+).*/\1/p' ;;
	shellcheck) printf '%s\n' "$output" | awk '/^version:/ { print $2 }' ;;
	*) printf '%s\n' "$output" | awk 'NR == 1 { print $1 }' ;;
	esac
}

# Verify presence and supported version; diagnostics explain any failed requirement.
# Argument: managed tool name. Returns 0 when supported and 1 otherwise.
check_container_tool_version() {
	local tool=$1 version
	if ! command -v "$tool" >/dev/null 2>&1; then
		printf '[FAIL] %s is not installed\n' "$tool"
		return 1
	fi
	if ! version=$(read_container_tool_version "$tool"); then
		printf '[FAIL] %s version command failed\n' "$tool"
		return 1
	fi
	if container_tool_version_supported "$tool" "$version"; then
		printf '[OK] %s %s\n' "$tool" "$version"
		return 0
	fi
	printf '[FAIL] %s reports unsupported version %s\n' "$tool" "${version:-unreadable}"
	return 1
}

status=0
if [[ ${CODESPACES:-} == true ]]; then
	config=codespaces
else
	config=local
fi
printf 'Devcontainer verification: %s\n' "$config"

if [[ -f /etc/os-release ]]; then
	# The system supplies this file; its contents are outside repository static analysis.
	# shellcheck source=/dev/null
	source /etc/os-release
	if [[ $ID == debian && $VERSION_ID == 12 ]]; then
		printf '[OK] %s\n' "$PRETTY_NAME"
	else
		printf '[FAIL] Expected Debian 12 Bookworm\n'
		status=1
	fi
else
	printf '[FAIL] Cannot determine operating system\n'
	status=1
fi

# All managed runtime, formatter and lint versions use the same pure contract.
for tool in python node npm pwsh poetry shfmt shellcheck actionlint; do
	if ! check_container_tool_version "$tool"; then
		status=1
	fi
done

# Preserve required supporting CLI presence independently of the managed version pins.
for tool in git gh kcov bats bashdb claude cswap; do
	if command -v "$tool" >/dev/null 2>&1; then
		printf '[OK] %s is installed\n' "$tool"
	else
		printf '[FAIL] %s is not installed\n' "$tool"
		status=1
	fi
done

if [[ -f "$REPO_ROOT/.devcontainer/$config/devcontainer.json" ]]; then
	printf '[OK] .devcontainer/%s/devcontainer.json\n' "$config"
else
	printf '[FAIL] Missing .devcontainer/%s/devcontainer.json\n' "$config"
	status=1
fi

if [[ -f "$REPO_ROOT/.venv/bin/python" ]]; then
	venv_version=$("$REPO_ROOT/.venv/bin/python" --version 2>&1 | awk '{ print $2 }')
	if container_tool_version_supported python "$venv_version"; then
		printf '[OK] Workspace virtual environment Python %s\n' "$venv_version"
	else
		printf '[FAIL] Workspace virtual environment uses unsupported Python %s\n' "$venv_version"
		status=1
	fi
else
	printf '[FAIL] Workspace Linux virtual environment is missing\n'
	status=1
fi

if ((status == 0)); then
	printf 'All devcontainer checks passed.\n'
else
	printf 'Devcontainer verification failed. Rebuild using .devcontainer/%s/devcontainer.json.\n' "$config"
	printf 'See .devcontainer/TROUBLESHOOTING.md for setup guidance.\n'
fi
exit "$status"
