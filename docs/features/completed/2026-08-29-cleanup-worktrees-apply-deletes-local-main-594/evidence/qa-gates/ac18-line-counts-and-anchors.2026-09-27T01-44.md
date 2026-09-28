# P5-T10 — AC-18 line counts and citation-invariant anchors after the change

Timestamp: 2026-09-27T01-44
Task: [P5-T10]
Working directory: repository worktree root (HEAD `7e54e0e1`)
Comparison record: `evidence/baseline/line-counts-and-anchors.2026-09-27T01-29.md` (P0-T13).

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

## Byte-level comparison (supplementary)

The three `sed -n` outputs above were also written to session-scratchpad files and compared with `cmp` against the same `sed -n` commands applied to `git show 92d78897371cc5c4f301c8cc2238adeb3fff2fea:<file>` (effective BASE_SHA, DEV-1 substitute for `0658f6945aa833c6960dc5bf8a43635fc346991f`; the P0-T13 record was taken at a HEAD whose code paths equal that commit). All three `cmp` runs exited 0 (actions, enumerate, lib), so every anchor line, including leading tabs, is byte-identical to the P0-T13 record.

## Line counts

Command: `wc -l scripts/bash/cleanup_worktrees_enumerate_lib.sh scripts/bash/cleanup_worktrees_actions_lib.sh scripts/bash/cleanup_worktrees_lib.sh scripts/bash/cleanup_worktrees_report_records_lib.sh scripts/bash/cleanup-worktrees.sh tests/shell/test_cleanup_worktrees_enumeration.bats tests/shell/test_cleanup_worktrees_classification.bats tests/shell/test_cleanup_worktrees_deletion.bats`
EXIT_CODE: 0

```
   252 scripts/bash/cleanup_worktrees_enumerate_lib.sh
   451 scripts/bash/cleanup_worktrees_actions_lib.sh
   496 scripts/bash/cleanup_worktrees_lib.sh
   476 scripts/bash/cleanup_worktrees_report_records_lib.sh
   234 scripts/bash/cleanup-worktrees.sh
   142 tests/shell/test_cleanup_worktrees_enumeration.bats
   273 tests/shell/test_cleanup_worktrees_classification.bats
   199 tests/shell/test_cleanup_worktrees_deletion.bats
  2523 total
```

| File | Baseline (P0-T13) | After | Delta |
|---|---|---|---|
| `scripts/bash/cleanup_worktrees_enumerate_lib.sh` | 236 | 252 | +16 |
| `scripts/bash/cleanup_worktrees_actions_lib.sh` | 437 | 451 | +14 |
| `scripts/bash/cleanup_worktrees_lib.sh` | 496 | 496 | 0 |
| `scripts/bash/cleanup_worktrees_report_records_lib.sh` | 476 | 476 | 0 |
| `scripts/bash/cleanup-worktrees.sh` | 229 | 234 | +5 |
| `tests/shell/test_cleanup_worktrees_enumeration.bats` | 113 | 142 | +29 |
| `tests/shell/test_cleanup_worktrees_classification.bats` | 259 | 273 | +14 |
| `tests/shell/test_cleanup_worktrees_deletion.bats` | 153 | 199 | +46 |

Output Summary:
- All fifteen anchor lines (actions 19, 35, 103, 147, 157, 164, 191, 198, 292, 317; enumerate 34, 115, 116; lib 54-55) are byte-identical to the P0-T13 record (visual match plus three `cmp` exit 0 results).
- Every line count is at most 500 (maximum 496); `scripts/bash/cleanup_worktrees_lib.sh` is exactly 496.
- All four commands exit 0.
- Result: PASS.
