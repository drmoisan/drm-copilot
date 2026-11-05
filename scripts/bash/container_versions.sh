#!/usr/bin/env bash

# Validate a parsed version against the shared container development baseline.
# Arguments: tool identifier and dotted version, optionally prefixed with v.
# Returns 0 for supported versions and 1 otherwise, without output or side effects.
container_tool_version_supported() {
	local tool=${1:-} version=${2:-} expected
	version=${version#v}
	# Python permits later selected-minor patches; Git is a minimum; other tools are pinned.
	case "$tool" in
	python)
		if [[ ! $version =~ ^3\.13\.([0-9]{1,6})$ ]]; then
			return 1
		fi
		((10#${BASH_REMATCH[1]} >= 18))
		return
		;;
	git)
		if [[ ! $version =~ ^([0-9]{1,6})\.([0-9]{1,6})\.([0-9]{1,6})$ ]]; then
			return 1
		fi
		((10#${BASH_REMATCH[1]} > 2 || (10#${BASH_REMATCH[1]} == 2 && 10#${BASH_REMATCH[2]} >= 56)))
		return
		;;
	node) expected=26.13.0 ;;
	npm) expected=11.20.0 ;;
	pwsh) expected=7.6.9 ;;
	poetry) expected=2.5.1 ;;
	gh) expected=2.103.3 ;;
	dotnet) expected=10.0.403 ;;
	uv) expected=0.13.7 ;;
	claude) expected=2.1.318 ;;
	cswap) expected=0.29.0 ;;
	codex) expected=0.166.0 ;;
	pester) expected=6.2.0 ;;
	pssa) expected=1.25.0 ;;
	gt) expected=1.7.14 ;;
	copilot) expected=0.0.377 ;;
	kcov) expected=43 ;;
	shfmt) expected=3.14.1 ;;
	shellcheck) expected=0.11.0 ;;
	actionlint) expected=1.7.12 ;;
	*) return 1 ;;
	esac
	[[ $version == "$expected" ]]
}
