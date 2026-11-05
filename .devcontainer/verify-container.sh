#!/usr/bin/env bash
# Verify the complete selected baseline in either development container.

CONTAINER_VERIFIER_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(dirname -- "$CONTAINER_VERIFIER_DIR")
# shellcheck source=scripts/bash/container_versions.sh
# shellcheck disable=SC1091
source "$REPO_ROOT/scripts/bash/container_versions.sh"

read_container_tool_version() {
	# Capture native output completely, then normalize it without spawning a parser.
	local tool=$1 output version remainder module_name
	case "$tool" in
	pester | pssa)
		if [[ $tool == pester ]]; then module_name=Pester; else module_name=PSScriptAnalyzer; fi
		if ! output=$(pwsh -NoLogo -NoProfile -Command "\$module = Get-Module -ListAvailable -Name '$module_name' | Sort-Object Version -Descending | Select-Object -First 1; if (-not \$module) { exit 1 }; \$module.Version.ToString()" 2>&1); then
			return 1
		fi
		;;
	*)
		if ! output=$("$tool" --version 2>&1); then return 1; fi
		;;
	esac
	case "$tool" in
	python | pwsh | uv | cswap | kcov) read -r remainder version remainder <<<"$output" ;;
	codex)
		# Codex can emit nonfatal setup diagnostics before its native version line.
		while IFS= read -r remainder; do
			if [[ $remainder =~ ^codex-cli[[:space:]]+([0-9A-Za-z.+-]+)$ ]]; then
				printf '%s\n' "${BASH_REMATCH[1]}"
				return 0
			fi
		done <<<"$output"
		return 1
		;;
	git | gh) read -r remainder remainder version remainder <<<"$output" ;;
	poetry)
		if [[ $output =~ version[[:space:]]+([0-9A-Za-z.+-]+) ]]; then
			version=${BASH_REMATCH[1]}
		else
			return 1
		fi
		;;
	shellcheck)
		while IFS= read -r remainder; do
			if [[ $remainder =~ ^version:[[:space:]]*([0-9A-Za-z.+-]+) ]]; then
				printf '%s\n' "${BASH_REMATCH[1]}"
				return 0
			fi
		done <<<"$output"
		return 1
		;;
	*) read -r version remainder <<<"$output" ;;
	esac
	printf '%s\n' "$version"
}

check_container_tool_version() {
	# Module checks require PowerShell; every other selected tool is a native command.
	local tool=$1 version command_name
	command_name=$tool
	if [[ $tool == pester || $tool == pssa ]]; then command_name=pwsh; fi
	if ! command -v "$command_name" >/dev/null 2>&1; then
		printf '[FAIL] %s is not installed (required command: %s)\n' "$tool" "$command_name"
		return 1
	fi
	if ! version=$(read_container_tool_version "$tool"); then
		printf '[FAIL] %s version query failed or module is missing\n' "$tool"
		return 1
	fi
	if container_tool_version_supported "$tool" "$version"; then
		printf '[OK] %s %s\n' "$tool" "$version"
		return 0
	fi
	printf '[FAIL] %s reports unsupported version %s\n' "$tool" "${version:-unreadable}"
	return 1
}

check_container_operating_system() {
	# Read the distribution boundary only here so tests can replace it in memory.
	local ID='' VERSION_ID='' PRETTY_NAME=''
	if ! test -f /etc/os-release; then
		printf '[FAIL] Cannot determine operating system\n'
		return 1
	fi
	# shellcheck source=/dev/null
	if ! source /etc/os-release; then
		printf '[FAIL] Cannot read operating system information\n'
		return 1
	fi
	if [[ $ID == debian && $VERSION_ID == 12 ]]; then
		printf '[OK] %s\n' "$PRETTY_NAME"
		return 0
	fi
	printf '[FAIL] Expected Debian 12 Bookworm\n'
	return 1
}

read_workspace_python_version() {
	# Keep workspace execution separate from version decisions for isolated tests.
	"$REPO_ROOT/.venv/bin/python" --version
}

check_container_workspace() {
	# A complete workspace needs the selected config and a working Linux interpreter.
	local config=$1 status=0 output venv_version
	if test -f "$REPO_ROOT/.devcontainer/$config/devcontainer.json"; then
		printf '[OK] .devcontainer/%s/devcontainer.json\n' "$config"
	else
		printf '[FAIL] Missing .devcontainer/%s/devcontainer.json\n' "$config"
		status=1
	fi
	if ! test -x "$REPO_ROOT/.venv/bin/python"; then
		printf '[FAIL] Workspace Linux virtual environment is missing\n'
		return 1
	fi
	if ! output=$(read_workspace_python_version 2>&1); then
		printf '[FAIL] Workspace Python version query failed\n'
		return 1
	fi
	read -r venv_version venv_version <<<"$output"
	if container_tool_version_supported python "$venv_version"; then
		printf '[OK] Workspace virtual environment Python %s\n' "$venv_version"
	else
		printf '[FAIL] Workspace virtual environment uses unsupported Python %s\n' "${venv_version:-unreadable}"
		status=1
	fi
	return "$status"
}

verify_container() {
	# Report all failed requirements together; setup succeeds only when every check passes.
	local status=0 config=local tool
	if [[ ${CODESPACES:-} == true ]]; then config=codespaces; fi
	printf 'Devcontainer verification: %s\n' "$config"
	check_container_operating_system || status=1
	for tool in python git node npm pwsh poetry gh dotnet uv claude cswap codex shfmt shellcheck actionlint gt copilot kcov pester pssa; do
		check_container_tool_version "$tool" || status=1
	done
	# These supporting distro-built tools have no independent repository version pin.
	for tool in bats bashdb; do
		if command -v "$tool" >/dev/null 2>&1; then
			printf '[OK] %s is installed\n' "$tool"
		else
			printf '[FAIL] %s is not installed\n' "$tool"
			status=1
		fi
	done
	check_container_workspace "$config" || status=1
	if ((status == 0)); then
		printf 'All devcontainer checks passed.\n'
	else
		printf 'Devcontainer verification failed. Rebuild using .devcontainer/%s/devcontainer.json.\n' "$config"
		printf 'See .devcontainer/TROUBLESHOOTING.md for setup guidance.\n'
	fi
	return "$status"
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
	set -euo pipefail
	verify_container
fi
