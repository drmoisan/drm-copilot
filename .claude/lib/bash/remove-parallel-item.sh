#!/usr/bin/env bash
# remove-parallel-item.sh: destination-portable command-line entry point for
# the parallel-remove skill's decision, recolor, and audit-record steps. It
# exists so a workspace that received the Claude customization payload can run
# those steps with nothing but bash -- no interpreter, no repository checkout.
#
# Usage:
#   bash .claude/lib/bash/remove-parallel-item.sh decide --item <key> \
#       [--state <state>] [--removal-disposition detach|abandon]
#   bash .claude/lib/bash/remove-parallel-item.sh recolor --unstarted "<k> ..." \
#       [--edges "<a>:<b> ..."] --pinned "<k> ..." --generation <g> \
#       --current-cohort <c> --highest-pinned-cohort <h>
#   bash .claude/lib/bash/remove-parallel-item.sh entry --item <key> \
#       --prior-state <state> [--removal-disposition detach|abandon] \
#       --recompute true|false --generation <g> [--at <timestamp>]
#
# `decide` without `--state` means the key resolves to no tracked item.
# `--unstarted`, `--edges`, and `--pinned` accept an empty string. Integer
# tokens match `-?(0|[1-9][0-9]*)`. `--at` defaults to the current UTC time as
# yyyy-MM-ddTHH-mm; the clock is read only when `--at` is omitted.
#
# Exit-code contract:
#   exit 0  success; one compact JSON object on stdout
#   exit 1  rule rejection; the reference implementation's exact message as
#           one stderr line
#   exit 2  usage error; one stderr line beginning
#           "PARALLEL_MUTATION_ERROR: usage error:"
# Argument validation runs first, then rule rejection, then output.
#
# Parity reference: scripts/dev_tools/parallel_mutation_protocol.py
# (decide_removal, recolor_unstarted) and
# scripts/dev_tools/_parallel_mutation_entries.py (build_remove_entry).
#
# Declared divergences (also listed in both parity lanes):
#   1. A `--removal-disposition` value outside `detach abandon` is a usage error
#      (exit 2) instead of the Python `UnknownEnumMemberError` text, which lists
#      merge-status members (`_parallel_mutation_errors.py:192`, spec D5).
#   2. `at` is a caller-supplied string instead of a `datetime`.
#   3. Option abbreviations are rejected.
set -euo pipefail

# Resolve this script's own directory so the library sources regardless of cwd.
RPI_SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=.claude/lib/bash/parallel-mutation.sh
# shellcheck disable=SC1091
source "$RPI_SCRIPT_DIR/parallel-mutation.sh"

pc_enforce_c_locale

# Parsed option values, keyed by option name without the leading dashes.
declare -A RPI_OPTS=()

# The canonical value stored by the most recent validator.
RPI_VALUE=""

rpi_usage_error() {
	# Print one usage-error line on stderr and exit 2.
	#
	# Args: $1 = the specific reason.
	printf 'PARALLEL_MUTATION_ERROR: usage error: %s\n' "$1" >&2
	exit 2
}

rpi_parse_options() {
	# Parse `--name value` pairs into RPI_OPTS against an allowed-name list.
	#
	# Args: $1 = space-separated allowed option names, then the arguments.
	# Every option takes exactly one value. An unknown name, an abbreviation, a
	# `--name=value` form, a repeated option, or a missing value is a usage
	# error; a value beginning with `--` counts as missing.
	local allowed="$1" name
	shift
	RPI_OPTS=()
	while (($# > 0)); do
		name="${1#--}"
		if [[ $1 != --* ]] || ! pc_contains_word "$allowed" "$name"; then
			rpi_usage_error "unknown option: $1"
		fi
		if [[ -n ${RPI_OPTS["$name"]+set} ]]; then
			rpi_usage_error "option given more than once: $1"
		fi
		if (($# < 2)) || [[ $2 == --* ]]; then
			rpi_usage_error "option $1 requires a value"
		fi
		RPI_OPTS["$name"]="$2"
		shift 2
	done
}

rpi_require() {
	# Exit with a usage error unless every named option was supplied.
	#
	# Args: the option names that are required.
	local name
	for name in "$@"; do
		[[ -n ${RPI_OPTS["$name"]+set} ]] || rpi_usage_error "missing required option: --$name"
	done
}

rpi_integer() {
	# Validate one integer token and store it in canonical form in RPI_VALUE.
	#
	# Args: $1 = the token, $2 = a label naming where it came from. The
	# validators store their result in a global instead of echoing it, because
	# a usage error raised inside a command substitution would exit only the
	# subshell.
	if [[ ! $1 =~ ^-?(0|[1-9][0-9]*)$ ]]; then
		rpi_usage_error "$2 must be a decimal integer matching -?(0|[1-9][0-9]*); found: $1"
	fi
	RPI_VALUE=$(($1))
}

rpi_integer_list() {
	# Validate a whitespace-separated key list; store it space separated.
	#
	# Args: $1 = the list, $2 = a label naming the option.
	local token canonical=""
	pcoh_split_words "$1"
	local -a tokens=("${PCOH_WORDS[@]}")
	for token in "${tokens[@]}"; do
		rpi_integer "$token" "$2 key"
		canonical="$canonical $RPI_VALUE"
	done
	RPI_VALUE="${canonical# }"
}

rpi_edge_list() {
	# Validate a whitespace-separated `a:b` edge list; store it canonical.
	#
	# Args: $1 = the edge list.
	local token first canonical=""
	pcoh_split_words "$1"
	local -a tokens=("${PCOH_WORDS[@]}")
	for token in "${tokens[@]}"; do
		if [[ $token != *:* || $token == *:*:* ]]; then
			rpi_usage_error "edge must be <a>:<b>; found: $token"
		fi
		rpi_integer "${token%%:*}" "edge endpoint"
		first="$RPI_VALUE"
		rpi_integer "${token#*:}" "edge endpoint"
		canonical="$canonical $first:$RPI_VALUE"
	done
	RPI_VALUE="${canonical# }"
}

rpi_disposition() {
	# Validate the optional disposition; store it, or empty when absent.
	RPI_VALUE="${RPI_OPTS["removal-disposition"]-}"
	if [[ -n ${RPI_OPTS["removal-disposition"]+set} ]] && ! pc_contains_word "detach abandon" "$RPI_VALUE"; then
		rpi_usage_error "--removal-disposition must be one of detach, abandon; found: $RPI_VALUE"
	fi
}

rpi_emit() {
	# Print the library outcome and return the matching exit code.
	#
	# Args: $1 = the library function's return code.
	if (($1 != 0)); then
		printf '%s\n' "$PM_ERROR" >&2
		return 1
	fi
	printf '%s\n' "$PM_RESULT"
	return 0
}

rpi_decide() {
	# Run the decide subcommand.
	local item state="" disposition rc=0
	rpi_parse_options "item state removal-disposition" "$@"
	rpi_require item
	rpi_integer "${RPI_OPTS[item]}" "--item"
	item="$RPI_VALUE"
	if [[ -n ${RPI_OPTS[state]+set} ]]; then
		state="${RPI_OPTS[state]}"
		pc_enum_members_contains "$PC_VALID_ITEM_STATES" "$state" ||
			rpi_usage_error "--state must be one of $PC_VALID_ITEM_STATES; found: $state"
	fi
	rpi_disposition
	disposition="$RPI_VALUE"
	pm_decide_removal "$item" "$state" "$disposition" || rc=$?
	rpi_emit "$rc"
}

rpi_recolor() {
	# Run the recolor subcommand.
	local unstarted edges pinned generation current highest rc=0
	rpi_parse_options "unstarted edges pinned generation current-cohort highest-pinned-cohort" "$@"
	rpi_require unstarted pinned generation current-cohort highest-pinned-cohort
	rpi_integer_list "${RPI_OPTS[unstarted]}" "--unstarted"
	unstarted="$RPI_VALUE"
	rpi_edge_list "${RPI_OPTS[edges]-}"
	edges="$RPI_VALUE"
	rpi_integer_list "${RPI_OPTS[pinned]}" "--pinned"
	pinned="$RPI_VALUE"
	rpi_integer "${RPI_OPTS[generation]}" "--generation"
	generation="$RPI_VALUE"
	rpi_integer "${RPI_OPTS["current-cohort"]}" "--current-cohort"
	current="$RPI_VALUE"
	rpi_integer "${RPI_OPTS["highest-pinned-cohort"]}" "--highest-pinned-cohort"
	highest="$RPI_VALUE"
	pm_recolor_unstarted "$unstarted" "$edges" "$pinned" "$generation" "$current" "$highest" || rc=$?
	rpi_emit "$rc"
}

rpi_entry() {
	# Run the entry subcommand.
	local item prior disposition recompute generation at rc=0
	rpi_parse_options "item prior-state removal-disposition recompute generation at" "$@"
	rpi_require item prior-state recompute generation
	rpi_integer "${RPI_OPTS[item]}" "--item"
	item="$RPI_VALUE"
	prior="${RPI_OPTS["prior-state"]}"
	[[ $prior =~ ^[A-Za-z_]+$ ]] || rpi_usage_error "--prior-state must match [A-Za-z_]+; found: $prior"
	rpi_disposition
	disposition="$RPI_VALUE"
	recompute="${RPI_OPTS[recompute]}"
	[[ $recompute == true || $recompute == false ]] ||
		rpi_usage_error "--recompute must be true or false; found: $recompute"
	rpi_integer "${RPI_OPTS[generation]}" "--generation"
	generation="$RPI_VALUE"
	if [[ -n ${RPI_OPTS[at]+set} ]]; then
		at="${RPI_OPTS[at]}"
		[[ $at =~ ^[0-9A-Za-z:.+-]+$ ]] || rpi_usage_error "--at must match [0-9A-Za-z:.+-]+; found: $at"
	else
		# The only clock read in this script, taken only when --at is omitted.
		at=$(date -u +%Y-%m-%dT%H-%M)
	fi
	pm_build_remove_entry "$item" "$prior" "$disposition" "$recompute" "$generation" "$at" || rc=$?
	rpi_emit "$rc"
}

rpi_main() {
	# Dispatch on the subcommand.
	(($# > 0)) || rpi_usage_error "missing subcommand; expected one of decide, recolor, entry"
	local subcommand="$1"
	shift
	case "$subcommand" in
	decide) rpi_decide "$@" ;;
	recolor) rpi_recolor "$@" ;;
	entry) rpi_entry "$@" ;;
	*) rpi_usage_error "unknown subcommand: $subcommand" ;;
	esac
}

# Guard so the file can be sourced without executing main. main's return code
# is captured and re-exited explicitly as the final statement.
if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
	rpi_rc=0
	rpi_main "$@" || rpi_rc=$?
	exit "$rpi_rc"
fi
