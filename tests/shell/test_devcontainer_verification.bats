#!/usr/bin/env bats

setup() {
	# Source definitions without native probes, then fake each I/O boundary in memory.
	unset CODESPACES
	VERIFIER="${BATS_TEST_DIRNAME}/../../.devcontainer/verify-container.sh"
	source "$VERIFIER"
	NATIVE_OUTPUT=1.2.3
	NATIVE_STATUS=0
	EXPECTED_MODULE=''
	MISSING_TOOL=''
	OS_FILE_STATUS=0
	CONFIG_FILE_STATUS=0
	VENV_FILE_STATUS=0
	OS_SOURCE_STATUS=0
	OS_ID=debian
	OS_VERSION=12
	WORKSPACE_OUTPUT='Python 3.13.18'
	WORKSPACE_STATUS=0
	native_probe() {
		printf '%s\n' "$NATIVE_OUTPUT"
		return "$NATIVE_STATUS"
	}
	python() { native_probe; }
	node() { native_probe; }
	npm() { native_probe; }
	git() { native_probe; }
	gh() { native_probe; }
	poetry() { native_probe; }
	dotnet() { native_probe; }
	uv() { native_probe; }
	claude() { native_probe; }
	cswap() { native_probe; }
	codex() { native_probe; }
	shfmt() { native_probe; }
	shellcheck() { native_probe; }
	actionlint() { native_probe; }
	gt() { native_probe; }
	copilot() { native_probe; }
	kcov() { native_probe; }
	pwsh() {
		if [[ -n $EXPECTED_MODULE && $* != *"$EXPECTED_MODULE"* ]]; then return 9; fi
		native_probe
	}
	command() {
		if [[ ${1:-} == -v ]]; then
			case "$2" in
			python | node | npm | git | gh | poetry | dotnet | uv | claude | cswap | codex | shfmt | shellcheck | actionlint | gt | copilot | kcov | pwsh | bats | bashdb)
				[[ $2 != "$MISSING_TOOL" ]]
				return
				;;
			esac
		fi
		builtin command "$@"
	}
	test() {
		case "${1:-}:${2:-}" in
		-f:/etc/os-release) return "$OS_FILE_STATUS" ;;
		-f:*/.devcontainer/*/devcontainer.json) return "$CONFIG_FILE_STATUS" ;;
		-x:*/.venv/bin/python) return "$VENV_FILE_STATUS" ;;
		*) builtin test "$@" ;;
		esac
	}
	source() {
		if [[ $1 == /etc/os-release ]]; then
			ID=$OS_ID
			VERSION_ID=$OS_VERSION
			PRETTY_NAME='Debian test release'
			return "$OS_SOURCE_STATUS"
		fi
		builtin source "$@"
	}
	read_workspace_python_version() {
		printf '%s\n' "$WORKSPACE_OUTPUT"
		return "$WORKSPACE_STATUS"
	}
}

teardown() {
	# Prevent fake command names from affecting framework cleanup or later suites.
	unset -f python node npm git gh poetry dotnet uv claude cswap codex shfmt shellcheck actionlint gt copilot kcov pwsh command test source read_workspace_python_version
	unset CODESPACES
}

@test "sourcing the verifier runs no environment checks" {
	run source "$VERIFIER"
	[ "$status" -eq 0 ]
	[ -z "$output" ]
}

@test "native CLI and module formats normalize to independent expected versions" {
	local tool expected raw
	# Cover every selected command family rather than assuming a common output layout.
	while IFS='|' read -r tool expected raw; do
		NATIVE_OUTPUT=${raw//\\n/$'\n'}
		EXPECTED_MODULE=''
		case "$tool" in pester) EXPECTED_MODULE=Pester ;; pssa) EXPECTED_MODULE=PSScriptAnalyzer ;; esac
		run read_container_tool_version "$tool"
		[ "$status" -eq 0 ] && [ "$output" = "$expected" ] || {
			echo "Unexpected $tool parse: $output"
			return 1
		}
	done <<'VERSIONS'
python|3.13.18|Python 3.13.18
git|2.56.0|git version 2.56.0
node|v26.13.0|v26.13.0
npm|11.20.0|11.20.0
pwsh|7.6.9|PowerShell 7.6.9
poetry|2.5.1|Poetry (version 2.5.1)
gh|2.103.3|gh version 2.103.3 (2026-10-28)
dotnet|10.0.403|10.0.403
uv|0.13.7|uv 0.13.7 (build)
claude|2.1.318|2.1.318 (Claude Code)
cswap|0.29.0|cswap 0.29.0
codex|0.166.0|codex-cli 0.166.0
shfmt|v3.14.1|v3.14.1
shellcheck|0.11.0|ShellCheck - shell script analysis tool\nversion: 0.11.0\nlicense: GNU
actionlint|1.7.12|1.7.12\ninstalled from release
gt|1.7.14|1.7.14
copilot|0.0.377|0.0.377\nCommit: abc
kcov|v43|kcov v43
pester|6.2.0|6.2.0
pssa|1.25.0|1.25.0
VERSIONS
}

@test "Codex version parsing tolerates native setup warnings" {
	NATIVE_OUTPUT=$'WARNING: proceeding, even though we could not create PATH aliases\ncodex-cli 0.166.0'
	run read_container_tool_version codex
	[ "$status" -eq 0 ]
	[ "$output" = '0.166.0' ]
}

@test "unrecognized Poetry ShellCheck and Codex output fails parsing" {
	local tool
	NATIVE_OUTPUT='unreadable output'
	for tool in poetry shellcheck codex; do
		run read_container_tool_version "$tool"
		[ "$status" -eq 1 ]
	done
}

@test "failed native commands and missing modules fail their query" {
	local tool
	NATIVE_STATUS=7
	for tool in node pester; do
		run read_container_tool_version "$tool"
		[ "$status" -eq 1 ]
	done
}

@test "missing native CLI produces a failed requirement" {
	MISSING_TOOL=codex
	run check_container_tool_version codex
	[ "$status" -eq 1 ]
	[[ "$output" == *'codex is not installed'* ]]
}

@test "PowerShell module checks require the PowerShell executable" {
	MISSING_TOOL=pwsh
	run check_container_tool_version pester
	[ "$status" -eq 1 ]
	[[ "$output" == *'pester is not installed (required command: pwsh)'* ]]
}

@test "failed module queries do not report success" {
	NATIVE_STATUS=1
	run check_container_tool_version pssa
	[ "$status" -eq 1 ]
	[[ "$output" == *'pssa version query failed or module is missing'* ]]
}

@test "selected native versions pass while stale versions fail" {
	NATIVE_OUTPUT=v26.13.0
	run check_container_tool_version node
	[ "$status" -eq 0 ]
	[ "$output" = '[OK] node v26.13.0' ]
	NATIVE_OUTPUT=v24.14.0
	run check_container_tool_version node
	[ "$status" -eq 1 ]
	[[ "$output" == *'unsupported version v24.14.0'* ]]
}

@test "empty successful version output is still a failed requirement" {
	NATIVE_OUTPUT=''
	run check_container_tool_version node
	[ "$status" -eq 1 ]
	[[ "$output" == *'unsupported version unreadable'* ]]
}

@test "Debian Bookworm OS information passes verification" {
	run check_container_operating_system
	[ "$status" -eq 0 ]
	[ "$output" = '[OK] Debian test release' ]
}

@test "missing unreadable and unsupported OS information fails verification" {
	OS_FILE_STATUS=1
	run check_container_operating_system
	[ "$status" -eq 1 ]
	[[ "$output" == *'Cannot determine operating system'* ]]
	OS_FILE_STATUS=0
	OS_SOURCE_STATUS=1
	run check_container_operating_system
	[ "$status" -eq 1 ]
	[[ "$output" == *'Cannot read operating system information'* ]]
	OS_SOURCE_STATUS=0
	OS_ID=ubuntu
	run check_container_operating_system
	[ "$status" -eq 1 ]
	[[ "$output" == *'Expected Debian 12 Bookworm'* ]]
}

@test "workspace configuration and supported Linux Python pass" {
	run check_container_workspace local
	[ "$status" -eq 0 ]
	[[ "$output" == *'Workspace virtual environment Python 3.13.18'* ]]
}

@test "missing workspace config or Linux interpreter fails" {
	CONFIG_FILE_STATUS=1
	run check_container_workspace local
	[ "$status" -eq 1 ]
	[[ "$output" == *'Missing .devcontainer/local/devcontainer.json'* ]]
	CONFIG_FILE_STATUS=0
	VENV_FILE_STATUS=1
	run check_container_workspace local
	[ "$status" -eq 1 ]
	[[ "$output" == *'Workspace Linux virtual environment is missing'* ]]
}

@test "failed or unsupported workspace Python probes fail" {
	WORKSPACE_STATUS=1
	run check_container_workspace local
	[ "$status" -eq 1 ]
	[[ "$output" == *'Workspace Python version query failed'* ]]
	WORKSPACE_STATUS=0
	WORKSPACE_OUTPUT='Python 3.12.9'
	run check_container_workspace local
	[ "$status" -eq 1 ]
	[[ "$output" == *'unsupported Python 3.12.9'* ]]
}

@test "main verifier selects local and Codespaces configurations" {
	check_container_tool_version() { printf '[OK] fake %s\n' "$1"; }
	run verify_container
	[ "$status" -eq 0 ]
	[[ "$output" == *'Devcontainer verification: local'* ]]
	[[ "$output" == *'[OK] fake codex'* ]]
	[[ "$output" == *'[OK] fake pester'* ]]
	CODESPACES=true
	run verify_container
	[ "$status" -eq 0 ]
	[[ "$output" == *'Devcontainer verification: codespaces'* ]]
}

@test "main verifier collects failures and never prints the success banner" {
	check_container_tool_version() {
		printf '[FAIL] fake %s\n' "$1"
		return 1
	}
	MISSING_TOOL=bats
	run verify_container
	[ "$status" -eq 1 ]
	[[ "$output" == *'[FAIL] bats is not installed'* ]]
	[[ "$output" == *'Devcontainer verification failed.'* ]]
	[[ "$output" != *'All devcontainer checks passed.'* ]]
}
