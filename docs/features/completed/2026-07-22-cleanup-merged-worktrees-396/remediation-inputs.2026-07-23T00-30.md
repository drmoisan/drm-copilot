# Remediation Inputs — 2026-07-23T00:30 (cycle 2)

Canonical issue number for this feature is 396.

## Source

Orchestrator escalation (user-directed) of finding CR-1 from `code-review.2026-07-22T09-23.md` (carried forward unchanged into `code-review.2026-07-22T10-00.md`). The feature-review agent classified CR-1 as Major/non-blocking and recommended deferring it as a follow-up hardening issue. The orchestrator overrides that recommendation for this branch: given the tool is destructive (it deletes git worktrees and branches) and its entire purpose is fail-safe classification, a known fail-open path in the classification ladder is treated as Blocking for this feature, not deferred.

## Finding

**Severity: Blocking (escalated from Major by orchestrator judgment)**

In `scripts/bash/cleanup_worktrees_lib.sh`, lines 117, 270, and 375 use the `rc=$?` or-capture idiom inside `<(...)` process substitutions:

```
done < <(cleanup_wt_git worktree list --porcelain ... || rc=$?)   # line ~117 area
done < <(cleanup_wt_git cherry main "$branch" ... || rc=$?)        # line ~270 area
done < <(cleanup_wt_git rev-list ... || rc=$?)                     # line ~375 area
```

Bash runs process substitutions in a subshell, so `rc=$?` assigned there never reaches the parent function's `rc`. Consequences:

1. `classify_cherry_equivalent` — a hard `git cherry` failure (non-zero exit, empty output) is indistinguishable from "no residual commits," so the function prints `MERGED_EQUIVALENT`, a delete-eligible verdict, instead of failing hard.
2. `parse_worktree_list` — a hard `git worktree list` failure yields an empty worktree list, weakening the dual current-worktree/branch protection this tool depends on to never delete the active worktree.

No fixture exercises either hard-failure path today, so this is an unverified safety property in a tool whose only job is safe classification for destructive operations.

## Required Fix

1. Refactor all three call sites in `cleanup_worktrees_lib.sh` to capture command output via ordinary command substitution first (e.g. `out=$(cleanup_wt_git cherry main "$branch" 2>&1); rc=$?`), check `rc` in the parent shell, and on a hard failure (any exit code other than the ladder's expected 0/1 or documented "no output" case) return/print a hard-error verdict analogous to the existing `ANCESTRY_ERROR` state — never a delete-eligible or "protection satisfied" result.
2. Add bats fixtures/tests simulating a `git cherry` hard failure and a `git worktree list` hard failure (via the existing `CLEANUP_WT_GIT_BIN` stub seam), asserting the hard-error verdict is produced and no delete-eligible or protection-weakened outcome results.
3. Re-run the full bash toolchain (shfmt, shellcheck, bats via CI dispatch since bats/kcov are unavailable locally) to confirm no regression, and confirm coverage stays >= the uniform 85%/75% gate.

Do not touch CR-2, CR-3, or CR-4 (already-accepted Minor/Nit findings) — this cycle is scoped to CR-1 only.
