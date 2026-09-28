# P5-T6 — run_apply docstring capture (P3-T3)

Timestamp: 2026-09-27T01-42
Task: [P5-T6]
Working directory: repository worktree root (HEAD `7e54e0e1`)

Command: `sed -n '/^run_apply() {/,/local rc=0 name record/p' scripts/bash/cleanup_worktrees_actions_lib.sh`
EXIT_CODE: 0

```
run_apply() {
	# Apply-mode driver. Emits the report (WORKTREE and per-branch BRANCH/COMMIT lines)
	# and then performs deletion for delete-eligible states only. The eligible-state
	# gate is a single explicit allowlist: MERGED_CLEAN | MERGED_CONTENT_NEUTRAL |
	# MERGED_EQUIVALENT. NOT_MERGED, HAS_UNIQUE_RESIDUALS, PROTECTED_CURRENT, and
	# ANCESTRY_ERROR never trigger a destructive action. The main worktree and the base
	# branch CLEANUP_WT_BASE_BRANCH are never candidates: compute_protected protects the
	# base by name in every checkout topology, so classify_branch resolves it to
	# PROTECTED_CURRENT, and delete_candidate refuses it as a backstop. Deletion of the
	# consolidation branch (whose unique content was consolidated) is gated on
	# verify_consolidation_merged() returning MERGED_CLEAN. Returns non-zero if any
	# candidate's deletion failed or was blocked, or when the worktree listing, branch
	# enumeration, or any branch classification hard-fails (in which case no mutation is
	# performed for that failure).
	local rc=0 name record wpath wbranch wflags cb_out state
```

Output Summary:
- The printed block starts with `run_apply() {`, ends with the `local rc=0 name record wpath wbranch wflags cb_out state` line, and contains `CLEANUP_WT_BASE_BRANCH` (one occurrence).
- The docstring attributes the base branch's protection to `compute_protected` (by name, every checkout topology) with `delete_candidate` as the backstop, not to worktree position alone.
- Result: PASS.
