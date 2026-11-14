#!/usr/bin/env bash
# cleanup_worktrees_preserve_merge_lib.sh: sourceable staging-decision function group for
# the preserve pass of the cleanup-worktrees tool. For each preserve record whose target
# already exists as a regular file on the consolidation branch, it decides whether the
# source may be copied, whether a three-way union merge may be staged instead, or whether
# the record must be refused with ACTION|preserve-stage|<target-path>|REFUSED-WOULD-REGRESS.
#
# Sourcing contract: this library defines functions only and runs no work at source time.
# It MUST be sourced before cleanup_worktrees_preserve_lib.sh, whose preserve_plan_one calls
# preserve_merge_check_duplicate and preserve_merge_decide. Its own git calls go through
# cleanup_wt_git, defined in cleanup_worktrees_enumerate_lib.sh.
#
# Phase-1 write exception. The preserve planning phase writes no index, ref, or working-tree
# file. The one write it performs is the creation of unreferenced blob objects in the object
# store: `git hash-object -w` hashes the two merge inputs and `git merge-file --object-id`
# records the merged result. Nothing refers to those blobs unless the writing phase stages
# the merged result, and an unreferenced blob is removed by the normal object pruning.
#
# Line-comparison rule. Every guard compares lines. Content is split with the
# `while IFS= read -r line || [[ -n $line ]]` idiom, so an unterminated final line counts as
# a line, and one trailing carriage return is stripped from each line before comparison, so
# a CRLF working-tree file and its LF-normalized blob compare equal.
#
# No git call in this library passes -f or --force, and no process substitution is passed
# to git as a file argument: native git on Windows cannot open an MSYS /dev/fd path.

preserve_merge_split_lines() {
	# Split one content string into the global array PRESERVE_MERGE_LINES under the
	# line-comparison rule stated in the header. An empty string yields no line at all.
	#
	# Args: $1 = the content.
	PRESERVE_MERGE_LINES=()
	# The carriage return is held in a variable: ANSI-C quoting nested inside a
	# double-quoted expansion is not interpreted consistently across bash versions.
	local line cr=$'\r'
	while IFS= read -r line || [[ -n $line ]]; do
		PRESERVE_MERGE_LINES+=("${line%"$cr"}")
	done < <(printf '%s' "${1-}")
}

preserve_merge_is_subsequence() {
	# Return 0 when every line of the needle appears in the haystack in the same order, not
	# necessarily adjacent, and 1 otherwise. An empty needle is a subsequence of anything.
	#
	# Args: $1 = needle content, $2 = haystack content.
	local -a needle=() hay=()
	preserve_merge_split_lines "${1-}"
	needle=("${PRESERVE_MERGE_LINES[@]}")
	preserve_merge_split_lines "${2-}"
	hay=("${PRESERVE_MERGE_LINES[@]}")
	local n=${#needle[@]} i=0 line
	if ((n == 0)); then
		return 0
	fi
	for line in "${hay[@]}"; do
		if [[ $line == "${needle[$i]}" ]]; then
			i=$((i + 1))
			if ((i == n)); then
				return 0
			fi
		fi
	done
	return 1
}

preserve_merge_extra_within() {
	# Guard G3. Return 0 when multiset(merged) minus multiset(main) is contained in
	# multiset(worktree) minus multiset(base), and 1 otherwise. A merged line that main does
	# not carry is admitted only as one of the worktree's own additions, so a base line that
	# main deleted and the merge re-emitted is refused. Counts are kept per line, so a line
	# the worktree added once may appear at most once beyond main's own copies.
	#
	# Keys carry a fixed prefix because bash refuses an empty associative-array subscript,
	# and a blank line is an ordinary line.
	#
	# Args: $1 = merged content, $2 = main content, $3 = worktree content, $4 = base content.
	local -A extra=() added=()
	local line key
	preserve_merge_split_lines "${1-}"
	for line in "${PRESERVE_MERGE_LINES[@]}"; do
		key="k$line"
		extra["$key"]=$((${extra["$key"]:-0} + 1))
	done
	preserve_merge_split_lines "${2-}"
	for line in "${PRESERVE_MERGE_LINES[@]}"; do
		key="k$line"
		extra["$key"]=$((${extra["$key"]:-0} - 1))
	done
	preserve_merge_split_lines "${3-}"
	for line in "${PRESERVE_MERGE_LINES[@]}"; do
		key="k$line"
		added["$key"]=$((${added["$key"]:-0} + 1))
	done
	preserve_merge_split_lines "${4-}"
	for line in "${PRESERVE_MERGE_LINES[@]}"; do
		key="k$line"
		added["$key"]=$((${added["$key"]:-0} - 1))
	done
	for key in "${!extra[@]}"; do
		if ((${extra["$key"]} > ${added["$key"]:-0} && ${extra["$key"]} > 0)); then
			return 1
		fi
	done
	return 0
}

preserve_merge_refuse() {
	# Refuse one record: emit ACTION|preserve-stage|<target-path>|REFUSED-WOULD-REGRESS on
	# stdout, a `cleanup-worktrees: refused` diagnostic naming the reason on stderr, set
	# PRESERVE_EXIT to 1, and return 1. A refusal is not a hard stop: the remaining records
	# are still planned and the pass exits 1.
	#
	# Args: $1 = target_path, $2 = the reason, which begins with the failed guard's token.
	printf 'ACTION|preserve-stage|%s|REFUSED-WOULD-REGRESS\n' "${1-}"
	printf 'cleanup-worktrees: refused %s: %s\n' "${1-}" "${2-}" >&2
	# Read by preserve_plan and run_preserve across a source boundary shellcheck does not
	# follow, so SC2034 reports it unused here; the suppression is line-scoped.
	# shellcheck disable=SC2034
	PRESERVE_EXIT=1
	return 1
}

preserve_merge_check_duplicate() {
	# Refuse a record whose target_path an earlier record of the same pass already named. A
	# target counts as seen as soon as a record reaches this check, whatever that record's
	# later outcome, so the first record keeps the target and every later one is refused.
	# The seen set is the newline-delimited global PRESERVE_SEEN_TARGETS, which preserve_plan
	# resets at the start of every pass.
	#
	# Args: $1 = target_path. Returns 0 when the target is new, 1 when it was refused.
	local tgt=${1-}
	local seen=${PRESERVE_SEEN_TARGETS:-$'\n'}
	if [[ $seen == *$'\n'"$tgt"$'\n'* ]]; then
		preserve_merge_refuse "$tgt" "duplicate-target: an earlier record in this pass names the same target_path"
		return 1
	fi
	PRESERVE_SEEN_TARGETS="$seen$tgt"$'\n'
	return 0
}

preserve_merge_resolve_base() {
	# Echo the blob id of the source file at the merge base of the worktree HEAD and the
	# consolidation HEAD, or return 1 when no base is available. The base is unavailable
	# when source_path differs from target_path (no git call is made in that case), when
	# the worktree HEAD does not resolve, when the two HEADs have no merge base, or when the
	# file is absent at the merge base. An empty answer from git counts as unavailable.
	#
	# Args: $1 = worktree path, $2 = source_path, $3 = target_path, $4 = consolidation path.
	local wt=${1-} src=${2-} tgt=${3-} cwt=${4-} head="" mb="" oid=""
	if [[ $src != "$tgt" ]]; then
		return 1
	fi
	head=$(cleanup_wt_git -C "$wt" rev-parse --verify --quiet HEAD) || return 1
	[[ -n $head ]] || return 1
	mb=$(cleanup_wt_git -C "$cwt" merge-base "$head" HEAD) || return 1
	[[ -n $mb ]] || return 1
	oid=$(cleanup_wt_git -C "$cwt" rev-parse --verify --quiet "$mb:$src") || return 1
	[[ -n $oid ]] || return 1
	printf '%s\n' "$oid"
}

preserve_merge_guard_b() {
	# Guard (b), the fallback when no merge base is available: admit a whole-file copy only
	# when main's version is a line-subsequence of the source, so no main line is lost.
	#
	# Args: $1 = target_path, $2 = main content, $3 = source content.
	if preserve_merge_is_subsequence "${2-}" "${3-}"; then
		PRESERVE_STAGE_MODE="copy"
		return 0
	fi
	preserve_merge_refuse "${1-}" "guard-b: the target holds lines the source lacks"
	return 1
}

# PRESERVE_STAGE_MODE and PRESERVE_STAGE_OID are read by preserve_plan_one across a source
# boundary shellcheck does not follow, so SC2034 reports them unused; the suppression is
# scoped to this one function.
# shellcheck disable=SC2034
preserve_merge_decide() {
	# Decide how one record is staged. Sets PRESERVE_STAGE_MODE to `copy` or `merge` and
	# PRESERVE_STAGE_OID to the merged blob id (empty for `copy`), or refuses the record.
	#
	#   - target not a regular file: `copy`, with no git call at all;
	#   - `untracked` record, or `modified` record with no merge base: guard (b);
	#   - `modified` record with a merge base: G1 (the worktree change is insertion-only),
	#     then a `git merge-file --union --object-id` merge, then G2 (every main line
	#     survives) and G3 (no line beyond the worktree's own additions); `merge` on success.
	#
	# The source and target are read with plain file I/O. The base and merged contents are
	# read from the object store with `cat-file blob`.
	#
	# Args: $1 = change_class, $2 = worktree path, $3 = source_path, $4 = target_path,
	# $5 = consolidation path. Returns 0 when the record may be staged, 1 when it was refused.
	local cls=${1-} wt=${2-} src=${3-} tgt=${4-} cwt=${5-}
	PRESERVE_STAGE_MODE="copy"
	PRESERVE_STAGE_OID=""
	if [[ ! -f "$cwt/$tgt" ]]; then
		return 0
	fi
	local main_c wt_c base_oid base_c main_oid wt_oid merged_oid merged_c mrc=0
	main_c=$(<"$cwt/$tgt")
	wt_c=$(<"$wt/$src")
	if [[ $cls == "untracked" ]] || ! base_oid=$(preserve_merge_resolve_base "$wt" "$src" "$tgt" "$cwt"); then
		preserve_merge_guard_b "$tgt" "$main_c" "$wt_c"
		return
	fi
	base_c=$(cleanup_wt_git -C "$cwt" cat-file blob "$base_oid") ||
		{ preserve_merge_refuse "$tgt" "G1: the base blob could not be read" || return 1; }
	if ! preserve_merge_is_subsequence "$base_c" "$wt_c"; then
		preserve_merge_refuse "$tgt" "G1: the worktree removed or changed a base line"
		return 1
	fi
	main_oid=$(cleanup_wt_git -C "$cwt" hash-object -w --path="$tgt" -- "$tgt") || main_oid=""
	wt_oid=$(cleanup_wt_git -C "$wt" hash-object -w --path="$tgt" -- "$src") || wt_oid=""
	merged_oid=$(cleanup_wt_git -C "$cwt" merge-file --union --object-id "$main_oid" "$base_oid" "$wt_oid") || mrc=$?
	if ((mrc != 0)) || [[ -z $main_oid || -z $wt_oid || -z $merged_oid ]]; then
		preserve_merge_refuse "$tgt" "merge-file rc=$mrc: no merged blob was produced"
		return 1
	fi
	merged_c=$(cleanup_wt_git -C "$cwt" cat-file blob "$merged_oid") ||
		{ preserve_merge_refuse "$tgt" "G2: the merged blob could not be read" || return 1; }
	if ! preserve_merge_is_subsequence "$main_c" "$merged_c"; then
		preserve_merge_refuse "$tgt" "G2: the merged result lost a main line"
		return 1
	fi
	if ! preserve_merge_extra_within "$merged_c" "$main_c" "$wt_c" "$base_c"; then
		preserve_merge_refuse "$tgt" "G3: the merged result carries a line the worktree did not add"
		return 1
	fi
	PRESERVE_STAGE_MODE="merge"
	PRESERVE_STAGE_OID=$merged_oid
	printf 'cleanup-worktrees: merged %s\n' "$tgt" >&2
	return 0
}
