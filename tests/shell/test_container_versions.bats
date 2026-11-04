#!/usr/bin/env bats

setup() {
	# Resolve the committed pure predicate independently of the caller's directory.
	source "${BATS_TEST_DIRNAME}/../../scripts/bash/container_versions.sh"
}

@test "container versions accept every pinned tool and optional v prefixes" {
	local pair tool version
	# Each configured tool must accept its exact baseline with no emitted output.
	for pair in node=26.13.0 npm=11.20.0 pwsh=7.6.9 poetry=2.3.2 shfmt=3.14.1 shellcheck=0.11.0 actionlint=1.7.12; do
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
	for version in 3.13.17 3.13.18 3.13.99; do
		run container_tool_version_supported python "$version"
		[ "$status" -eq 0 ]
	done
}

@test "container Python rejects stale patches wrong minors and malformed versions" {
	local version
	# Invalid version text must fail closed instead of implying compatibility.
	for version in '' 3.13.16 3.12.17 3.14.17 3.13 3.13.17rc1 unknown; do
		run container_tool_version_supported python "$version"
		[ "$status" -eq 1 ]
	done
}

@test "container versions reject stale or different pinned tool releases" {
	local pair tool version
	# Exact pins prevent a different runtime or formatter from silently passing verification.
	for pair in node=24.14.0 npm=11.19.0 pwsh=7.6.6 poetry=2.2.1 shfmt=3.8.0 shellcheck=0.10.0 actionlint=1.7.11 node=27.0.0; do
		IFS='=' read -r tool version <<<"$pair"
		run container_tool_version_supported "$tool" "$version"
		[ "$status" -eq 1 ] || {
			echo "Accepted unsupported $pair"
			return 1
		}
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
