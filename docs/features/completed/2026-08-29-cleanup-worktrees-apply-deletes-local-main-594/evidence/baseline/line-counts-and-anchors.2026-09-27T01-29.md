# P0-T13 — Baseline line counts and citation anchors

Timestamp: 2026-09-27T01-29
Task: [P0-T13]
Working directory: repository worktree root (HEAD `b5f98be268c8c9e0752027486f6500f0a6fa26ce`)

## Line counts

Command: `wc -l scripts/bash/cleanup_worktrees_enumerate_lib.sh scripts/bash/cleanup_worktrees_actions_lib.sh scripts/bash/cleanup_worktrees_lib.sh scripts/bash/cleanup_worktrees_report_records_lib.sh scripts/bash/cleanup-worktrees.sh tests/shell/test_cleanup_worktrees_enumeration.bats tests/shell/test_cleanup_worktrees_classification.bats tests/shell/test_cleanup_worktrees_deletion.bats`
EXIT_CODE: 0

```
   236 scripts/bash/cleanup_worktrees_enumerate_lib.sh
   437 scripts/bash/cleanup_worktrees_actions_lib.sh
   496 scripts/bash/cleanup_worktrees_lib.sh
   476 scripts/bash/cleanup_worktrees_report_records_lib.sh
   229 scripts/bash/cleanup-worktrees.sh
   113 tests/shell/test_cleanup_worktrees_enumeration.bats
   259 tests/shell/test_cleanup_worktrees_classification.bats
   153 tests/shell/test_cleanup_worktrees_deletion.bats
  2399 total
```

## Actions-library anchors (lines 19, 35, 103, 147, 157, 164, 191, 198, 292, 317 in order)

Command: `sed -n '19p;35p;103p;147p;157p;164p;191p;198p;292p;317p' scripts/bash/cleanup_worktrees_actions_lib.sh`
EXIT_CODE: 0

```
# Guarded-read invariant: every git-backed read whose output or exit code is
# MERGED_CLEAN unlocks deletion).
	cleanup_wt_git worktree add "$path" -b "$CLEANUP_WT_CONSOLIDATION_BRANCH" main || rc=$?
		cp_out=$(cleanup_wt_git -C "$wt" cherry-pick -x "$sha" 2>&1) || prc=$?
			cleanup_wt_git -C "$wt" cherry-pick --skip >/dev/null || true
			cleanup_wt_git -C "$wt" cherry-pick --abort >/dev/null || true
		cleanup_wt_git worktree remove "$path" >/dev/null || wrc=$?
	cleanup_wt_git branch -D "$CLEANUP_WT_CONSOLIDATION_BRANCH" >/dev/null || brc=$?
	cleanup_wt_git worktree remove "$path" >/dev/null || rc=$?
	cleanup_wt_git branch -D "$name" >/dev/null || rc=$?
```

## Enumerate-library anchors (lines 34, 115, 116)

Command: `sed -n '34p;115,116p' scripts/bash/cleanup_worktrees_enumerate_lib.sh`
EXIT_CODE: 0

```
cleanup_wt_git() {
		local branch_field="DETACHED"
		[[ -n $branch ]] && branch_field=$branch
```

## Classification-library anchors (lines 54, 55)

Command: `sed -n '54,55p' scripts/bash/cleanup_worktrees_lib.sh`
EXIT_CODE: 0

```
# Branch states: NOT_MERGED | MERGED_CLEAN | MERGED_CONTENT_NEUTRAL |
#   MERGED_EQUIVALENT | HAS_UNIQUE_RESIDUALS | PROTECTED_CURRENT; ANCESTRY_ERROR is a
```

Output Summary:
- Eight line counts: 236, 437, 496, 476, 229, 113, 259, 153 (all equal the plan's authoring values; all under 500).
- Ten actions-library anchor lines, three enumerate-library anchor lines, and two classification-library anchor lines recorded verbatim (leading tabs preserved) for the P5-T10 comparison.
- All four commands exit 0.
