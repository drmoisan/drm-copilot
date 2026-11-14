#!/usr/bin/env bats

setup() {
	# Resolve the committed pure predicate independently of the caller's directory.
	source "${BATS_TEST_DIRNAME}/../../scripts/bash/container_versions.sh"
}

@test "container versions accept every pinned tool and optional v prefixes" {
	local pair tool version
	# Each configured tool must accept its exact baseline with no emitted output.
	for pair in node=26.13.0 npm=11.20.0 pwsh=7.6.9 poetry=2.5.1 gh=2.103.3 dotnet=10.0.403 uv=0.13.7 claude=2.1.318 cswap=0.29.0 codex=0.166.0 pester=6.2.0 pssa=1.25.0 gt=1.7.14 copilot=0.0.377 kcov=43 shfmt=3.14.1 shellcheck=0.11.0 actionlint=1.7.12; do
		IFS='=' read -r tool version <<<"$pair"
		run container_tool_version_supported "$tool" "v$version"
		[ "$status" -eq 0 ] || {
			echo "Rejected supported $pair"
			return 1
		}
		[ -z "$output" ]
	done
}

@test "container Python accepts its minimum and later patches within 3.13" {
	local version
	# Patch updates remain supported without admitting another Python minor.
	for version in 3.13.18 3.13.19 3.13.99; do
		run container_tool_version_supported python "$version"
		[ "$status" -eq 0 ]
	done
}

@test "container Python rejects stale patches wrong minors and malformed versions" {
	local version
	# Invalid version text must fail closed instead of implying compatibility.
	for version in '' 3.13.17 3.12.18 3.14.18 3.13 3.13.18rc1 3.13.9999999999999999999999 unknown; do
		run container_tool_version_supported python "$version"
		[ "$status" -eq 1 ]
	done
}

@test "container versions reject stale or different pinned tool releases" {
	local pair tool version
	# Exact pins prevent a different runtime or formatter from silently passing verification.
	for pair in node=24.14.0 npm=11.19.0 pwsh=7.6.6 poetry=2.3.2 gh=2.103.2 dotnet=10.0.402 uv=0.13.6 claude=2.1.316 cswap=0.28.0 codex=0.165.0 pester=5.9.1 pssa=1.24.0 gt=1.7.13 copilot=0.0.376 kcov=42 shfmt=3.8.0 shellcheck=0.10.0 actionlint=1.7.11 node=27.0.0 poetry=2.5.2; do
		IFS='=' read -r tool version <<<"$pair"
		run container_tool_version_supported "$tool" "$version"
		[ "$status" -eq 1 ] || {
			echo "Accepted unsupported $pair"
			return 1
		}
	done
}

@test "container Git accepts its minimum and newer installed releases" {
	local version
	# Minimum-aware Git must preserve later compliant patch, minor, and major versions.
	for version in 2.56.0 2.56.1 2.57.0 3.0.0 v2.56.0; do
		run container_tool_version_supported git "$version"
		[ "$status" -eq 0 ]
		[ -z "$output" ]
	done
}

@test "container Git rejects stale incomplete and malformed versions" {
	local version
	# Invalid components cannot reach arithmetic or accidentally satisfy the minimum.
	for version in '' 1.999.999 2.55.999 2.56 2.56.0rc1 2.56.x 999999999999999999999.0.0; do
		run container_tool_version_supported git "$version"
		[ "$status" -eq 1 ]
		[ -z "$output" ]
	done
}

@test "container versions reject unknown missing and malformed tool inputs" {
	run container_tool_version_supported unknown 1.2.3
	[ "$status" -eq 1 ]
	run container_tool_version_supported
	[ "$status" -eq 1 ]
	run container_tool_version_supported node
	[ "$status" -eq 1 ]
	run container_tool_version_supported node vv26.13.0
	[ "$status" -eq 1 ]
}
