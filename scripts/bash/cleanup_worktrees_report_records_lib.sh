#!/usr/bin/env bash
# cleanup_worktrees_report_records_lib.sh: sourceable report-record function group for
# the cleanup-worktrees tool. It adds the report-mode visibility records that the
# classification ladder cannot see on its own: filesystem directories that are no
# longer registered worktrees, remote-tracking refs whose remote is gone, worktrees
# whose gitdir pointer no longer resolves, and the ancestor relationship between two
# branches that both resolve NOT_MERGED. The enumeration/protection seam
# (cleanup_wt_git, enumerate_branches, parse_worktree_list, normalize_wt_path,
# compute_protected, check_main_freshness) lives in cleanup_worktrees_enumerate_lib.sh
# and the classification ladder (classify_branch) lives in cleanup_worktrees_lib.sh;
# both MUST be sourced before this file. Keeping these records in a sibling file keeps
# every file within the 500-line cap.
#
# Sourcing contract: this library defines functions only; it never runs work at source
# time, so the wrapper and the bats suites can source it without side effects.
#
# Report line contract added by this library (pipe-delimited, LC_ALL=C ordered, one
# record per line; all four are advisory/read-only and never unlock a destructive
# action):
#   ORPHAN_DIR|<path>|<size>                 a directory under a worktree-tracking root
#                                            with no `.git` file and no registration.
#                                            <size> is best-effort and may be the
#                                            literal `unknown`.
#   STALE_REF|<refname>                      a refs/remotes/<name>/* ref whose <name> is
#                                            not a configured remote. <refname> is the
#                                            full ref form (refs/remotes/...).
#   CHILD_OF|<branch>|<ancestor>             <branch> is a git ancestor of <ancestor>,
#                                            which itself resolved exactly NOT_MERGED.
#                                            Emitted alongside, never instead of, the
#                                            branch's own BRANCH| line.
#   WARN|registration-lost|<path>            a worktree directory whose `.git` gitdir
#                                            pointer names a target that does not exist.
#
# Filesystem-scan seam: every filesystem read goes through cleanup_wt_scan_bin so the
# bats suites can stub the scan deterministically via CLEANUP_WT_SCAN_BIN, mirroring
# the CLEANUP_WT_GIT_BIN seam in cleanup_worktrees_enumerate_lib.sh. Unlike that seam,
# the fallback target is the bundled real implementation
# scripts/bash/cleanup_worktrees_scan_helper.sh rather than a PATH lookup, because no
# single standard system binary emits the combined
# `path|has_gitfile|gitdir_target_exists|size` tuple these records need.

cleanup_wt_scan_bin() {
	# Resolve the filesystem-scan helper honoring the CLEANUP_WT_SCAN_BIN override seam
	# and echo its path; the caller invokes it.
	#
	# When CLEANUP_WT_SCAN_BIN is set to a non-empty value it must point to an existing
	# executable; an empty or nonexistent value is treated as missing and falls back to
	# the bundled cleanup_worktrees_scan_helper.sh alongside this library.
	#
	# Args: none. Always returns 0 and echoes exactly one path.
	local override=${CLEANUP_WT_SCAN_BIN:-}
	if [[ -n $override && -x $override ]]; then
		printf '%s\n' "$override"
		return 0
	fi
	local here
	here=$(dirname "${BASH_SOURCE[0]}")
	printf '%s\n' "$here/cleanup_worktrees_scan_helper.sh"
}

scan_stale_refs() {
	# Emit STALE_REF|<refname> for every remote-tracking ref whose remote is gone.
	#
	# A ref under refs/remotes/<name>/ belongs to the configured remote <name>. When
	# <name> is absent from `git remote`'s output the ref is a leftover: the remote was
	# removed (or was never configured in this checkout) but its tracking refs were not
	# pruned. The record is advisory and read-only; nothing here deletes a ref.
	#
	# The refname is emitted in full ref form (refs/remotes/<name>/<branch>) rather than
	# the :short form, so the record names the ref exactly as `git for-each-ref` and
	# `git update-ref` spell it. Output is LC_ALL=C sorted.
	#
	# Both git reads are captured in the PARENT shell (`out=$(...) || rc=$?`) so a
	# non-zero exit is observed here rather than lost inside a process substitution. On a
	# hard failure of either read this emits no STALE_REF line and returns git's non-zero
	# exit code, mirroring parse_worktree_list's hard-failure contract: a git failure must
	# never read as "no stale refs".
	local rc=0 refs_out remotes_out ref name remote
	refs_out=$(cleanup_wt_git for-each-ref --format='%(refname)' refs/remotes/) || rc=$?
	if ((rc != 0)); then
		printf 'cleanup-worktrees: git for-each-ref refs/remotes/ failed (rc=%s)\n' "$rc" >&2
		return "$rc"
	fi
	remotes_out=$(cleanup_wt_git remote) || rc=$?
	if ((rc != 0)); then
		printf 'cleanup-worktrees: git remote failed (rc=%s)\n' "$rc" >&2
		return "$rc"
	fi
	local -A configured=()
	while IFS= read -r remote; do
		[[ -z $remote ]] && continue
		configured[$remote]=1
	done <<<"$remotes_out"
	local -a stale=()
	while IFS= read -r ref; do
		[[ -z $ref ]] && continue
		[[ $ref == refs/remotes/* ]] || continue
		name=${ref#refs/remotes/}
		name=${name%%/*}
		[[ -z $name ]] && continue
		[[ -n ${configured[$name]:-} ]] && continue
		stale+=("STALE_REF|$ref")
	done <<<"$refs_out"
	if ((${#stale[@]} > 0)); then
		printf '%s\n' "${stale[@]}" | LC_ALL=C sort
	fi
	return 0
}

cleanup_wt_scan_roots() {
	# Echo the worktree-tracking roots to scan, one per line.
	#
	# CLEANUP_WT_ORPHAN_ROOTS overrides the derivation with a colon-separated list.
	# Otherwise the roots are `.claude/worktrees` (the agent worktree folder) and
	# `<main-worktree-path>-wt` (the sibling worktree folder), where the main worktree
	# path is the first `git worktree list --porcelain` stanza — the same derivation
	# consolidation_worktree_path uses in cleanup_worktrees_actions_lib.sh.
	#
	# A parse_worktree_list hard failure drops only the derived second root; it is not
	# fatal here, because these records are advisory and the callers' own git reads
	# already fail closed on that condition. Always returns 0.
	local override=${CLEANUP_WT_ORPHAN_ROOTS:-}
	if [[ -n $override ]]; then
		local IFS=:
		local part
		for part in $override; do
			[[ -n $part ]] && printf '%s\n' "$part"
		done
		return 0
	fi
	printf '%s\n' ".claude/worktrees"
	local out rc=0 first_record main_wt=""
	out=$(parse_worktree_list) || rc=$?
	if ((rc != 0)); then
		return 0
	fi
	first_record=${out%%$'\n'*}
	main_wt=${first_record%%|*}
	if [[ -n $main_wt ]]; then
		printf '%s\n' "${main_wt}-wt"
	fi
	return 0
}

cleanup_wt_scan_records() {
	# Echo the raw `<path>|<has_gitfile>|<gitdir_target_exists>|<size>` records for every
	# candidate directory under the resolved scan roots, one per line.
	#
	# Every filesystem read goes through the CLEANUP_WT_SCAN_BIN seam, so the bats suites
	# replay canned records instead of touching the real filesystem. The scan output is
	# captured in the PARENT shell (`out=$(...) || rc=$?`) so a non-zero exit is observed
	# here; on a hard failure this emits no record and returns the scan's exit code
	# rather than letting a failed scan read as "nothing found".
	local -a roots=()
	local root
	while IFS= read -r root; do
		[[ -z $root ]] && continue
		roots+=("$root")
	done < <(cleanup_wt_scan_roots)
	if ((${#roots[@]} == 0)); then
		return 0
	fi
	local bin out rc=0
	bin=$(cleanup_wt_scan_bin)
	# Every script under scripts/bash/ is tracked mode 100644 and is invoked through the
	# interpreter rather than by its exec bit, so the bundled fallback helper is run with
	# `bash` when it is not executable. An override supplied through CLEANUP_WT_SCAN_BIN
	# is always executable (cleanup_wt_scan_bin only accepts it when it is) and is run
	# directly, so an override may be any executable, not only a bash script.
	if [[ -x $bin ]]; then
		out=$("$bin" scan-dirs "${roots[@]}") || rc=$?
	else
		out=$(bash "$bin" scan-dirs "${roots[@]}") || rc=$?
	fi
	if ((rc != 0)); then
		printf 'cleanup-worktrees: filesystem scan failed (rc=%s)\n' "$rc" >&2
		return "$rc"
	fi
	if [[ -n $out ]]; then
		printf '%s\n' "$out"
	fi
	return 0
}

scan_orphan_dirs() {
	# Emit ORPHAN_DIR|<path>|<size> for every scanned directory that is no longer a
	# worktree: it carries no `.git` pointer file and no `git worktree list` entry names
	# it. These are the residue of a `git worktree remove` that partially ran or failed.
	# The record is advisory and read-only; nothing here deletes a directory.
	#
	# Registered paths are compared after normalize_wt_path normalization, so a
	# backslash/case/trailing-slash difference between the porcelain listing and the
	# filesystem scan cannot make a live worktree look orphaned. Output is LC_ALL=C
	# sorted. A record whose size field is the literal `unknown` is emitted verbatim
	# rather than dropped: size is best-effort and its absence is not a reason to hide a
	# real orphan.
	#
	# Returns the scan's exit code on a hard scan failure (no record emitted), else 0.
	local rc=0 recs wlout wlrc=0 record path has_gitfile size norm
	recs=$(cleanup_wt_scan_records) || rc=$?
	if ((rc != 0)); then
		return "$rc"
	fi
	if [[ -z $recs ]]; then
		return 0
	fi
	local -A registered=()
	wlout=$(parse_worktree_list) || wlrc=$?
	if ((wlrc == 0)); then
		while IFS= read -r record; do
			[[ -z $record ]] && continue
			path=${record%%|*}
			norm=$(normalize_wt_path "$path")
			[[ -n $norm ]] && registered[$norm]=1
		done <<<"$wlout"
	fi
	local -a orphans=()
	while IFS= read -r record; do
		[[ -z $record ]] && continue
		IFS='|' read -r path has_gitfile _ size <<<"$record"
		[[ -z $path ]] && continue
		[[ $has_gitfile == "0" ]] || continue
		norm=$(normalize_wt_path "$path")
		[[ -n ${registered[$norm]:-} ]] && continue
		[[ -z $size ]] && size="unknown"
		orphans+=("ORPHAN_DIR|$path|$size")
	done <<<"$recs"
	if ((${#orphans[@]} > 0)); then
		printf '%s\n' "${orphans[@]}" | LC_ALL=C sort
	fi
	return 0
}

scan_registration_loss() {
	# Emit WARN|registration-lost|<path> for every scanned directory that still carries a
	# `.git` pointer file whose gitdir target no longer exists.
	#
	# This is the half-removed shape: the worktree still looks like a worktree from the
	# outside, but the administrative `.git/worktrees/<name>` entry it points at is gone,
	# so git commands run inside it fail in confusing ways. The record is advisory and
	# read-only; nothing here deletes a directory or prunes a registration.
	#
	# It consumes the same scan output and the same root resolution as scan_orphan_dirs,
	# so the two records are always derived from one consistent view of the filesystem.
	# Output is LC_ALL=C sorted. A record whose shape is unexpected (an empty path or a
	# gitdir_target_exists field that is neither 0 nor 1, such as the NA a pointer-less
	# directory carries) is skipped silently rather than reported or raised, mirroring
	# check_main_freshness's never-blocking contract: this warning must never be the
	# reason a report fails.
	#
	# Returns the scan's exit code on a hard scan failure (no record emitted), else 0.
	local rc=0 recs record path has_gitfile target_exists
	recs=$(cleanup_wt_scan_records) || rc=$?
	if ((rc != 0)); then
		return "$rc"
	fi
	if [[ -z $recs ]]; then
		return 0
	fi
	local -a lost=()
	while IFS= read -r record; do
		[[ -z $record ]] && continue
		IFS='|' read -r path has_gitfile target_exists _ <<<"$record"
		[[ -z $path ]] && continue
		[[ $has_gitfile == "1" ]] || continue
		[[ $target_exists == "0" ]] || continue
		lost+=("WARN|registration-lost|$path")
	done <<<"$recs"
	if ((${#lost[@]} > 0)); then
		printf '%s\n' "${lost[@]}" | LC_ALL=C sort
	fi
	return 0
}

cleanup_wt_protected_branches() {
	# Echo the branch names that classify_branch's rung-1 exclusion protects, one per
	# line: the current branch, plus every branch checked out in a protected worktree
	# path (the main worktree, and the current worktree).
	#
	# This mirrors the rung-1 logic in classify_branch rather than reimplementing a
	# policy: classify_all_branches must know which branches classify_branch would
	# resolve to PROTECTED_CURRENT, because a protected branch's verdict is fixed by the
	# exclusion and must never be replaced by an inherited NOT_MERGED. Without this the
	# short-circuit would violate its own outcome-preservation invariant for exactly one
	# case — a protected branch that happens to be a git ancestor of an unmerged branch,
	# which `main` almost always is.
	#
	# Returns the underlying read's exit code on a hard failure, with no names emitted.
	local cpout cprc=0 wlout wlrc=0 pline record wpath wbranch norm
	cpout=$(compute_protected) || cprc=$?
	if ((cprc != 0)); then
		return "$cprc"
	fi
	local -A prot_path=()
	while IFS= read -r pline; do
		case "$pline" in
		protected-branch\|*) printf '%s\n' "${pline#protected-branch|}" ;;
		protected-path\|*) prot_path[${pline#protected-path|}]=1 ;;
		esac
	done <<<"$cpout"
	wlout=$(parse_worktree_list) || wlrc=$?
	if ((wlrc != 0)); then
		return "$wlrc"
	fi
	while IFS= read -r record; do
		[[ -z $record ]] && continue
		IFS='|' read -r wpath _ wbranch _ <<<"$record"
		[[ -z $wbranch || $wbranch == DETACHED ]] && continue
		norm=$(normalize_wt_path "$wpath")
		if [[ -n $norm && -n ${prot_path[$norm]:-} ]]; then
			printf '%s\n' "$wbranch"
		fi
	done <<<"$wlout"
	return 0
}

classify_all_branches() {
	# Shared classification driver: classify every enumerated branch once, emitting the
	# same BRANCH|/COMMIT| lines the per-branch ladder emits plus the CHILD_OF| record,
	# and return the maximum per-branch return code observed.
	#
	# Two-phase contract:
	#
	#   1. Pairwise ancestry. For every ordered pair (X, Y) with X != Y, probe
	#      `git merge-base --is-ancestor <X> <Y>` with the exit code captured via
	#      `|| rc=$?`. Exit 0 records Y as an ancestor-target of X; exit 1 records
	#      nothing; any exit above 1 is a hard git failure, which emits
	#      BRANCH|X|ANCESTRY_ERROR and excludes X from every later phase. There is no
	#      silent "not an ancestor" fallback for a hard failure, matching the
	#      ANCESTRY_ERROR convention documented in cleanup_worktrees_lib.sh.
	#
	#   2a. Independent branches (zero ancestor-targets) are classified by the unchanged
	#       classify_branch, and their resolved state is read back from their BRANCH|
	#       line.
	#   2b. Deferred branches (one or more ancestor-targets) are then processed in
	#       LC_ALL=C order. When X is not protected and any ancestor-target already
	#       resolved to exactly NOT_MERGED, X is emitted as BRANCH|X|NOT_MERGED followed
	#       by CHILD_OF|X|<that-target> and classify_branch is never invoked for X: a
	#       branch contained in a branch that is not merged cannot itself be merged, so
	#       the expensive cherry/diff-tree/ls-tree rungs would only re-derive a verdict
	#       already implied. Otherwise X runs the full ladder normally.
	#
	#       The protection carve-out is required for outcome preservation, not an
	#       optimization detail. classify_branch resolves a protected branch to
	#       PROTECTED_CURRENT at rung 1, before ancestry is ever consulted, and `main`
	#       is both protected and a git ancestor of every unmerged branch — so without
	#       the carve-out `main` would inherit NOT_MERGED from the first unmerged branch
	#       processed and the report would contradict the ladder it is meant to mirror.
	#
	# The short-circuit is one level deep by design: it fires only on a DIRECT
	# ancestor-target whose state is already resolved. A branch whose only
	# ancestor-targets are themselves deferred and unresolved falls through to the full
	# ladder. That forgoes a deeper optimization but can never produce a wrong verdict,
	# because the saving is cost-only: BRANCH|X|NOT_MERGED is exactly what the full
	# ladder would have emitted.
	#
	# Output order is enumerate_branches' original LC_ALL=C order, regardless of the
	# order in which the phases above resolved each branch, so the report is
	# deterministic. An enumerate_branches hard failure aborts before any line is emitted
	# and returns git's exit code.
	local rc=0 crc ebout ebrc=0 cbout
	ebout=$(enumerate_branches) || ebrc=$?
	if ((ebrc != 0)); then
		return "$ebrc"
	fi
	local -a order=()
	local name
	while read -r name _; do
		[[ -z $name ]] && continue
		order+=("$name")
	done <<<"$ebout"
	if ((${#order[@]} == 0)); then
		return 0
	fi
	local -A branch_state=() branch_out=() ancestor_targets=() probe_failed=()
	local x y mrc
	for x in "${order[@]}"; do
		local -a found=()
		for y in "${order[@]}"; do
			[[ $x == "$y" ]] && continue
			mrc=0
			cleanup_wt_git merge-base --is-ancestor "$x" "$y" >/dev/null 2>&1 || mrc=$?
			if ((mrc == 0)); then
				found+=("$y")
			elif ((mrc > 1)); then
				branch_out[$x]="BRANCH|$x|ANCESTRY_ERROR"
				branch_state[$x]="ANCESTRY_ERROR"
				probe_failed[$x]=1
				if ((rc < 2)); then
					rc=2
				fi
				break
			fi
		done
		if [[ -z ${probe_failed[$x]:-} ]]; then
			ancestor_targets[$x]="${found[*]:-}"
		fi
	done
	# Phase 2a: the independent branches, via the unchanged full ladder.
	for x in "${order[@]}"; do
		[[ -n ${probe_failed[$x]:-} ]] && continue
		[[ -n ${ancestor_targets[$x]:-} ]] && continue
		crc=0
		cbout=$(classify_branch "$x") || crc=$?
		branch_out[$x]=$cbout
		branch_state[$x]=$(printf '%s\n' "$cbout" | awk -F'|' '/^BRANCH\|/{print $3; exit}')
		if ((crc > rc)); then
			rc=$crc
		fi
	done
	# Phase 2b: the deferred branches, in LC_ALL=C order.
	local -a deferred=()
	for x in "${order[@]}"; do
		[[ -n ${probe_failed[$x]:-} ]] && continue
		[[ -z ${ancestor_targets[$x]:-} ]] && continue
		deferred+=("$x")
	done
	if ((${#deferred[@]} > 0)); then
		local sorted hit target pname
		local -a target_list=()
		# A protected branch's verdict is fixed by classify_branch's rung-1 exclusion and
		# is never inheritable. On a hard failure of the protection read, leave the set
		# empty so every deferred branch runs the full ladder, which surfaces the same
		# failure as ANCESTRY_ERROR instead of hiding it behind a short-circuit.
		local -A protected=()
		while IFS= read -r pname; do
			[[ -z $pname ]] && continue
			protected[$pname]=1
		done < <(cleanup_wt_protected_branches || true)
		sorted=$(printf '%s\n' "${deferred[@]}" | LC_ALL=C sort)
		while IFS= read -r x; do
			[[ -z $x ]] && continue
			hit=""
			read -r -a target_list <<<"${ancestor_targets[$x]}"
			for target in "${target_list[@]:-}"; do
				[[ -z $target ]] && continue
				[[ -n ${protected[$x]:-} ]] && break
				if [[ ${branch_state[$target]:-} == "NOT_MERGED" ]]; then
					hit=$target
					break
				fi
			done
			if [[ -n $hit ]]; then
				branch_out[$x]="BRANCH|$x|NOT_MERGED"$'\n'"CHILD_OF|$x|$hit"
				branch_state[$x]="NOT_MERGED"
				continue
			fi
			crc=0
			cbout=$(classify_branch "$x") || crc=$?
			branch_out[$x]=$cbout
			branch_state[$x]=$(printf '%s\n' "$cbout" | awk -F'|' '/^BRANCH\|/{print $3; exit}')
			if ((crc > rc)); then
				rc=$crc
			fi
		done <<<"$sorted"
	fi
	for x in "${order[@]}"; do
		if [[ -n ${branch_out[$x]:-} ]]; then
			printf '%s\n' "${branch_out[$x]}"
		fi
	done
	return "$rc"
}
