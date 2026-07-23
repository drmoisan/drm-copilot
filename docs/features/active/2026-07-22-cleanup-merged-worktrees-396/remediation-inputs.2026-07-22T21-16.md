# Remediation Inputs — 2026-07-22T21-16 (cycle 3)

Canonical issue number for this feature is 396.

## Source

Feature-review cycle-2 re-audit (`policy-audit.2026-07-22T21-16.md`, `code-review.2026-07-22T21-16.md`, `feature-audit.2026-07-22T21-16.md`). CR-1 is verified resolved at all three cited call sites with genuine fail-before/pass-after CI evidence (runs 29970355445 red at `e09c0e92`, 29970805348 green at `8ba4fb79`). The caller additionally directed a generalized check that no hard git failure can resolve to a delete-eligible verdict or a protection-weakened worktree list anywhere in the classification/enumeration/consolidation code paths. That check failed: the reviewer deterministically reproduced two residual fail-open paths at call sites CR-1 did not enumerate. Severity for NEW-1 follows the orchestrator's cycle-2 escalation standard recorded in `remediation-inputs.2026-07-23T00-30.md`: a known fail-open path in the classification ladder of a destructive tool is Blocking for this feature.

## Findings

### NEW-1 — Blocking: hard `git diff-tree` failure resolves to a delete-eligible verdict

Two call sites in `scripts/bash/cleanup_worktrees_lib.sh`:

1. Line 127, `classify_cherry_equivalent` — the empty-diff residual check swallows the exit code:

```
dt=$(cleanup_wt_git diff-tree --no-commit-id -r "$sha" 2>/dev/null) || true
[[ -z $dt ]] && continue   # empty output treated as a droppable empty commit
```

A hard diff-tree failure (non-zero exit, empty stdout) is indistinguishable from a genuinely empty commit, so the residual is dropped; when every residual hits this path the function prints `MERGED_EQUIVALENT` (delete-eligible).

2. Line 197, `classify_residual_commit` — the name-status read loses the exit code inside a process substitution:

```
done < <(cleanup_wt_git diff-tree --no-commit-id --name-status -r -M "$sha" 2>/dev/null)
```

A hard failure yields an empty stream, an empty unique-path list, and the verdict `CONTENT_ON_MAIN`; when every residual resolves that way, `classify_branch` prints `MERGED_EQUIVALENT`.

**Reviewer reproduction (deterministic, stub seam, scratchpad-only fixtures):** scenario with `cherry.<branch>.out` containing one `+ <sha>` residual and `diff-tree.<sha>.rc` containing `128` (no `.out`):

```
classify_branch feature-dtfail   ->  BRANCH|feature-dtfail|MERGED_EQUIVALENT   (status 0)
```

The same failing diff-tree repeats identically in `reverify_delete_eligible`, so the same-process re-verification does not catch it; in apply mode the worktree is removed (no-force succeeds on a clean tree) and `git branch -D` succeeds on a non-checked-out branch — unique content is destroyed. There is no git-native backstop. This also falsifies the classification lib's updated header claim (lines 24-28: "A hard git failure never resolves to a MERGED_* verdict").

### NEW-2 — Major: rev-parse hard failures silently weaken the protected set

`scripts/bash/cleanup_worktrees_enumerate_lib.sh` lines 166-167, `compute_protected`:

```
current_branch=$(cleanup_wt_git rev-parse --abbrev-ref HEAD 2>/dev/null) || current_branch=""
current_top=$(cleanup_wt_git rev-parse --show-toplevel 2>/dev/null) || current_top=""
```

A hard rev-parse failure degrades silently to "no current branch, no current path", leaving only the main worktree protected. **Reviewer reproduction:** with `rev-parse.abbrev-ref-HEAD.rc` and `rev-parse.show-toplevel.rc` both `128`, the branch checked out in the current worktree classifies `MERGED_CLEAN` (status 0). Impact is bounded by git-native refusals (git will not delete a checked-out branch nor remove the current working tree), hence Major, not Blocking — but the silent degrade contradicts the user story's "structurally incapable" protection requirement and should be fixed alongside NEW-1 given the shared pattern.

### NEW-3 / NEW-4 — Minor (fix optional this cycle)

- NEW-3: `enumerate_branches` hard failure lost in `run_report` (lib line 409) and `run_apply` (actions lib line 298) process substitutions — empty branch list, status-0 "clean" report (silent false success; destructively fail-closed).
- NEW-4: `consolidation_worktree_path` (actions lib line 31) loses a `parse_worktree_list` failure in `mapfile < <(...)`, deriving the malformed path `-wt/documentationandmemories` from an empty main-worktree value.

## Required Fix

1. **NEW-1 (mandatory).** Apply the cycle-2 guarded-capture pattern to both diff-tree call sites: capture stdout via ordinary command substitution with rc observed in the parent shell (`out=$(cleanup_wt_git diff-tree ...) || rc=$?`); on non-zero rc surface a hard-error verdict that `classify_branch` maps to `BRANCH|<name>|ANCESTRY_ERROR` with return 2 (reuse the `CHERRY_ERROR`-style internal-token mechanism; never an equivalence verdict). An empty diff-tree output with exit 0 remains the legitimate empty-commit case.
2. **NEW-2 (mandatory).** In `compute_protected`, treat a non-zero exit from either rev-parse as a hard failure (return non-zero) rather than falling back to empty values. The detached-HEAD case is unaffected (rev-parse succeeds and prints `HEAD`).
3. **Tests (mandatory, fail-before ordering).** Add checked-in fixtures/tests via the existing `CLEANUP_WT_GIT_BIN` stub seam: (a) a residual `+` commit whose `diff-tree.<sha>.rc` is 128 with no output — assert `classify_branch` emits `ANCESTRY_ERROR` and returns 2, never `MERGED_EQUIVALENT`; (b) a scenario reaching `classify_residual_commit` with a failing name-status diff-tree — assert no `CONTENT_ON_MAIN`-derived equivalence; (c) rev-parse hard failures — assert `compute_protected` returns non-zero and `classify_branch` emits `ANCESTRY_ERROR`, never `MERGED_CLEAN`. Capture fail-before evidence (red CI dispatch) before the production fix, per the cycle-2 precedent.
4. **Header accuracy (mandatory).** After the fix, the classification lib header's invariant statement becomes true; verify it, and extend it to name diff-tree among the guarded reads.
5. **Toolchain (mandatory).** Re-run `bash scripts/bash/shell-qc.sh format` and `check` locally, then the bats/kcov stage via CI dispatch of `_shell-coverage.yml`; confirm coverage stays at or above the 85% uniform gate and does not regress below the 90.4% cycle-2 result; verify all files stay within the 500-line cap (the classification lib is at 411 lines; headroom exists).
6. **NEW-3/NEW-4 (optional).** May be fixed in this cycle if the executor judges the incremental cost low; otherwise record them as accepted Minors.

Do not touch CR-2 or CR-4 (accepted Minors). CR-1 and CR-3 are resolved; do not reopen them.

## Artifact Paths

- Policy audit: `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/policy-audit.2026-07-22T21-16.md`
- Code review (full reproduction detail and call-site sweep table): `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/code-review.2026-07-22T21-16.md`
- Feature audit: `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/feature-audit.2026-07-22T21-16.md`
- Cycle-2 fix evidence (for pattern reference): `evidence/regression-testing/cr1-hard-failure.{fail-before,pass-after}.2026-07-23T00-30.md`, `evidence/qa-gates/*.2026-07-23T00-30.md`
