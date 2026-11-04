#!/usr/bin/env bash

# Validate a parsed version against the shared container development baseline.
# Arguments: tool identifier and dotted version, optionally prefixed with v.
# Returns 0 for supported versions and 1 otherwise, without output or side effects.
container_tool_version_supported() {
	local tool=${1:-} version=${2:-} expected
	version=${version#v}
	# Python permits later patches within its selected minor; other tools are pinned.
	case "$tool" in
	python)
		if [[ ! $version =~ ^3\.13\.([0-9]+)$ ]]; then
			return 1
		fi
		((10#${BASH_REMATCH[1]} >= 17))
		return
		;;
	node) expected=26.13.0 ;;
	npm) expected=11.20.0 ;;
	pwsh) expected=7.6.9 ;;
	poetry) expected=2.3.2 ;;
	shfmt) expected=3.14.1 ;;
	shellcheck) expected=0.11.0 ;;
	actionlint) expected=1.7.12 ;;
	*) return 1 ;;
	esac
	[[ $version == "$expected" ]]
}
