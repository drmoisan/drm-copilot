# P5-T4 — AC-15 comment corrections (counts and reworded passages)

Timestamp: 2026-09-27T01-41
Task: [P5-T4]
Working directory: repository worktree root (HEAD `7e54e0e1`)

The three phrase searches are recorded in their own artifacts, each with `ExpectedExitCode: 1`:
`ac15-phrase-1.2026-09-27T01-41.md` (`needs no special`), `ac15-phrase-2.2026-09-27T01-41.md`
(`needs no separate protection`), and `ac15-phrase-3.2026-09-27T01-41.md`
(`classify_branch marks it PROTECTED_CURRENT`). Each printed nothing and exited 1.

## Reworded passages (quoted for reviewer inspection)

`scripts/bash/cleanup_worktrees_report_records_lib.sh` lines 391-394 (`classify_all_branches` docstring):

```
	# Restricting the probe to the NOT_MERGED set bounds its cost at k*(k-1) probes for k
	# such branches rather than n*(n-1) for n branches. The base branch `main` never
	# enters the probe set: compute_protected protects it by name (CLEANUP_WT_BASE_BRANCH)
	# in every checkout topology, so classify_branch resolves it PROTECTED_CURRENT at rung 1.
```

`scripts/bash/cleanup_worktrees_report_records_lib.sh` lines 427-429 (Phase 2 comment):

```
	# Phase 2: pairwise ancestry, over the NOT_MERGED set only. A branch that resolved
	# anything else is neither a subject nor a target, so `main`, PROTECTED_CURRENT by the
	# unconditional base-branch protection in compute_protected, is excluded by its verdict.
```

`scripts/bash/cleanup_worktrees_actions_lib.sh` `run_apply` docstring (reworded lines):

```
	# ANCESTRY_ERROR never trigger a destructive action. The main worktree and the base
	# branch CLEANUP_WT_BASE_BRANCH are never candidates: compute_protected protects the
	# base by name in every checkout topology, so classify_branch resolves it to
	# PROTECTED_CURRENT, and delete_candidate refuses it as a backstop. Deletion of the
```

`scripts/bash/cleanup_worktrees_lib.sh` lines 319-320 (`classify_branch` step 1):

```
	#   1. PROTECTED_CURRENT exclusion (branch-name OR worktree-path match; main worktree
	#      and base branch CLEANUP_WT_BASE_BRANCH always protected).
```

## Per-file token counts

Command: `grep -c -F 'CLEANUP_WT_BASE_BRANCH' scripts/bash/cleanup_worktrees_report_records_lib.sh scripts/bash/cleanup_worktrees_actions_lib.sh scripts/bash/cleanup_worktrees_lib.sh`
EXIT_CODE: 0

```
scripts/bash/cleanup_worktrees_report_records_lib.sh:1
scripts/bash/cleanup_worktrees_actions_lib.sh:3
scripts/bash/cleanup_worktrees_lib.sh:1
```

Output Summary:
- Per-file `CLEANUP_WT_BASE_BRANCH` counts: report_records_lib 1, actions_lib 3, lib 1 (each at least 1).
- The three superseded phrases (single-line at BASE_SHA: `report_records_lib.sh:392`, `:429`, `actions_lib.sh:362`) each return no match (see the three phrase artifacts).
- The four reworded passages are quoted above.
- Result: PASS.
