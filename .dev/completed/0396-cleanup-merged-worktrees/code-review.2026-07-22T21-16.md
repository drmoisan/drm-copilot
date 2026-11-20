# Code Review: cleanup-merged-worktrees (#396) — Remediation Cycle 2 Re-review (CR-1)

---

**Review Date:** 2026-07-22
**Reviewer:** feature-review agent (Claude Code)
**Feature Folder:** `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/`
**Base Branch:** `main` (merge base `b2351cbc3fb3916f516d77567a1c9e40457c8981`)
**Head Branch:** `drm-copilot-wt-2026-07-21T21-57` (`921b5c401e5049b69a45544285daeb91d137ea84`)
**Review Type:** Remediation cycle 2 re-review (prior reviews: `code-review.2026-07-22T09-23.md`, `code-review.2026-07-22T10-00.md`). Cycle-2 scope: CR-1 escalated Major-to-Blocking by orchestrator judgment (`remediation-inputs.2026-07-23T00-30.md`). Review scope: full branch diff versus `main`, with a caller-directed generalized check that no hard git failure can resolve to a delete-eligible verdict or a protection-weakened worktree list anywhere in the classification/enumeration/consolidation code paths.

---

## Executive Summary

**CR-1 is genuinely fixed at all three cited call sites and their consuming reads.** Verified by direct code inspection, grep for the fail-open idiom, five new bats tests with genuine fail-before evidence (red CI run 29970355445 at `e09c0e92`: exactly the five new tests failing) and pass-after evidence (green CI run 29970805348 at `8ba4fb79`: 85/85). Specifically:

1. `parse_worktree_list` (enumerate lib line 108): guarded parent-shell capture; a worktree-list hard failure emits zero records and returns the git exit code — an empty worktree list can no longer be fabricated from a failure.
2. `compute_protected` (enumerate lib line 176): propagates a `parse_worktree_list` failure instead of degrading to an empty protected set.
3. `classify_cherry_equivalent` (classification lib line 114): a non-zero `git cherry` exit yields the internal `CHERRY_ERROR` verdict, mapped by `classify_branch` to `ANCESTRY_ERROR` with return 2 — never `MERGED_EQUIVALENT`.
4. `select_cherry_pick_candidates` (classification lib lines 223, 234): defensive `CHERRY_ERROR` re-check plus guarded rev-list capture; a rev-list failure returns non-zero with zero COMMIT lines.
5. `classify_branch` (lines 280, 294) and `run_report` (line 395): guarded captures of the protected set and worktree list; hard failures map to `ANCESTRY_ERROR`/non-zero return before any ladder rung or WORKTREE emission.
6. `reverify_delete_eligible` (actions lib line 185) remains fail-safe under the fix: `classify_branch` always emits a BRANCH line, and any non-eligible state (including `ANCESTRY_ERROR`) maps to BLOCKED-REVERIFY.

**However, the caller's generalized invariant does not hold.** This reviewer deterministically reproduced two residual fail-open paths at call sites CR-1 did not enumerate, using scratchpad-only stub scenarios (no repository mutation):

- **NEW-1 (Blocking).** A hard `git diff-tree` failure (exit 128, empty output) on a residual commit resolves to `MERGED_EQUIVALENT` — a delete-eligible verdict — with status 0. Reproduction: a scenario with `git cherry` emitting one `+` residual and `diff-tree.<sha>.rc = 128` classifies `BRANCH .. MERGED_EQUIVALENT`, status 0. The same wrong verdict repeats in `reverify_delete_eligible` (same failing diff-tree), so apply mode would remove the worktree and run branch deletion, destroying unique content. There is no git-native backstop for a clean, non-checked-out candidate. This is the same defect class the orchestrator escalated to Blocking in cycle 2, and it falsifies the classification lib's own updated header claim ("A hard git failure never resolves to a MERGED_* verdict").
- **NEW-2 (Major).** Hard failures of `git rev-parse --abbrev-ref HEAD` and `--show-toplevel` in `compute_protected` degrade silently to empty values, suppressing the dual current-branch/current-worktree protection. Reproduction: with both rev-parse keys failing (exit 128), the branch checked out in the current worktree classifies `MERGED_CLEAN`, status 0. Bounded by git-native refusals (git will not delete a checked-out branch nor remove the current working tree), hence Major rather than Blocking.

Two further Minor robustness findings (NEW-3, NEW-4) and the carried-forward CR-2/CR-3/CR-4 are listed below. CR-3 (file at 499 of 500 lines) is materially improved by the cycle-2 split (now 411 + 209).

**PR readiness recommendation: No-Go** — one Blocking finding (NEW-1) requires remediation cycle 3.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Resolved (was Blocking) | `scripts/bash/cleanup_worktrees_enumerate_lib.sh`, `scripts/bash/cleanup_worktrees_lib.sh` | enumerate lib lines 108, 176; classification lib lines 114, 234, 280, 294, 395 (CR-1) | Dead or-capture (`rc=$?`) inside process substitutions previously lost hard git failures, resolving to delete-eligible verdicts or a weakened protected set. | None — fix verified. | Guarded parent-shell capture applied at every cited site and consuming read; hard failures map to ANCESTRY_ERROR / non-zero returns. | Fail-before run 29970355445 (5 new tests red, 80 pre-existing green); pass-after run 29970805348 (85/85); reviewer grep confirms no residual or-capture-in-process-substitution at these sites. |
| Blocking | `scripts/bash/cleanup_worktrees_lib.sh` | line 127 (`classify_cherry_equivalent`) and line 197 (`classify_residual_commit`) (NEW-1) | Hard `git diff-tree` failure resolves to a delete-eligible verdict: line 127 swallows the exit code with an or-true and treats the resulting empty output as a droppable empty commit; line 197 loses the exit code in a process substitution and treats the empty stream as all-paths-on-main (CONTENT_ON_MAIN). Either way the branch reaches MERGED_EQUIVALENT, and the same failure repeats identically during the pre-deletion re-verification. | Apply the cycle-2 guarded-capture pattern: capture diff-tree stdout with explicit rc in the parent shell; on non-zero rc return a hard-error verdict (map to ANCESTRY_ERROR via the CHERRY_ERROR-style mechanism), never an equivalence verdict. Add fixtures/tests: a residual whose diff-tree rc is 128 (empty-output case for line 127; and, for line 197, a scenario reaching classify_residual_commit). Correct the header only by making its invariant true. | The tool's sole safety property is that classification never fabricates delete-eligibility; a hard git failure here destroys unique content in apply mode with no git-native backstop. Same class as the escalated CR-1. | Reviewer reproduction (stub scenario, cherry emits one `+` residual, diff-tree rc 128, no output): `classify_branch feature-dtfail` printed `BRANCH .. MERGED_EQUIVALENT`, exit status 0. Commands recorded in `policy-audit.2026-07-22T21-16.md` Appendix B. |
| Major | `scripts/bash/cleanup_worktrees_enumerate_lib.sh` | lines 166-167 (`compute_protected`) (NEW-2) | Or-fallbacks to empty strings on `git rev-parse --abbrev-ref HEAD` / `--show-toplevel` hard failures silently weaken the dual current-branch/current-path protection (only the main worktree remains protected). | Distinguish hard failure from the legitimate detached-HEAD case: on a non-zero rev-parse exit (other than detached HEAD, which succeeds and prints HEAD), return non-zero so classify_branch maps to ANCESTRY_ERROR. Add a fixture/test. | The user story requires the tool to be "structurally incapable" of targeting the current worktree/branch; a silent degrade contradicts that. Impact bounded: git refuses to delete a checked-out branch and refuses to remove the current working tree, so actual destruction requires additional failures. | Reviewer reproduction (rev-parse keys rc 128): `classify_branch curbranch` (checked out in the current worktree) printed `BRANCH ..MERGED_CLEAN`, status 0. |
| Minor | `scripts/bash/cleanup_worktrees_lib.sh`, `scripts/bash/cleanup_worktrees_actions_lib.sh` | lib line 409 (`run_report`), actions lib line 298 (`run_apply`) (NEW-3) | `enumerate_branches` hard failure is lost in the process substitution: an empty branch list yields a status-0 report with no BRANCH lines — silent false success. | Capture enumerate_branches output/rc with the guarded pattern and propagate non-zero. | Fail-closed destructively (nothing is deleted), but a "clean" report from a failed enumeration misleads the caller. | Code inspection; same idiom class as CR-1 but with a non-destructive failure direction. |
| Minor | `scripts/bash/cleanup_worktrees_actions_lib.sh` | line 31 (`consolidation_worktree_path`) (NEW-4) | `mapfile < <(parse_worktree_list)` loses a hard failure; an empty main-worktree value derives the malformed consolidation path `-wt/documentationandmemories` (leading dash risks option parsing in `git worktree add`). | Capture parse_worktree_list output/rc; abort consolidation on failure or on an empty main-worktree path. | Consolidation-side robustness; no delete-eligibility impact. Actions lib was explicitly out of cycle-2 scope. | Code inspection. |
| Minor | `scripts/bash/cleanup_worktrees_actions_lib.sh` | lines 96-102 (CR-2, carried forward, unchanged) | Stub-aware production logic re-emits `stub-git:` marker lines to stderr. | Move argv observation into the stub/test layer or document the marker as a supported diagnostic contract. | Unchanged since prior review; cycle 2 did not touch this file per plan. | `code-review.2026-07-22T09-23.md`. |
| Minor | `scripts/bash/cleanup_worktrees_lib.sh` | call graph (CR-4, carried forward, unchanged) | Redundant subprocess work, O(branches x worktrees) git invocations. | Acceptable at current scale; hoist if runtime grows. | Unchanged since prior review. | `code-review.2026-07-22T09-23.md`. |
| Resolved (was Nit) | `scripts/bash/cleanup_worktrees_lib.sh` | whole file (CR-3) | File was at 499 of 500 lines. | None — the cycle-2 pure-move split reduced it to 411 lines (enumerate lib 209). | Headroom restored without behavior change; split verified by passing pre-existing suite in the fail-before run. | Reviewer `wc -l`; `evidence/qa-gates/file-size-caps.2026-07-23T00-30.md`. |
| Info | `scripts/bash/cleanup_worktrees_lib.sh` | lines 186-191 (`classify_residual_commit`, D-status rung) | For a deleted path, a `git rev-parse main:<path>` non-zero exit is read as "absent on main -> droppable"; the exit code cannot distinguish a missing path from a repository error. | When hardening NEW-1, consider `--verify` semantics or treating repeated rev-parse failures as hard errors. | Inherent exit-code ambiguity; risk is narrow (requires a D-status residual plus a targeted failure). | Code inspection. |

One Blocking finding (NEW-1). CR-1 and CR-3 are resolved; CR-2 and CR-4 remain accepted Minors.

---

## Implementation Audit

### CR-1 fix verification (all three cited sites plus consuming reads)

- **Site 1 — worktree list.** `parse_worktree_list` captures `out=$(cleanup_wt_git worktree list --porcelain)` with guarded rc in the parent shell; non-zero returns before any record. `compute_protected`, `classify_branch` (both reads), and `run_report` each capture and propagate. Grep over both libraries confirms no remaining or-capture inside a process substitution.
- **Site 2 — cherry.** `classify_cherry_equivalent` returns the single token `CHERRY_ERROR` on any non-zero cherry exit before residual processing; `classify_branch` maps it to `ANCESTRY_ERROR` return 2; `select_cherry_pick_candidates` re-checks defensively and returns 2.
- **Site 3 — rev-list.** `select_cherry_pick_candidates` captures rev-list output/rc; non-zero returns the git exit code with zero COMMIT lines; `classify_branch` propagates the failure as return 2 (the already-emitted `HAS_UNIQUE_RESIDUALS` line is a non-delete-eligible state).
- **set -e interaction.** The wrapper invokes `main "$@"` in an or-list, which suspends `set -e` throughout the call tree; the fix correctly relies on explicit rc checks rather than errexit, so the guarded pattern is sound in both sourced (bats) and wrapper execution contexts.
- **Deletion path.** `delete_candidate` order is unchanged and correct: re-verify, no-force worktree removal (dirty trees block), then `git branch -D`. `reverify_delete_eligible` treats every non-eligible or unknown state as BLOCKED-REVERIFY — fail-safe against classification hard errors now that classify_branch always emits `ANCESTRY_ERROR` on them.

### Generalized hard-failure sweep (caller-directed)

Every production call site that consumes git output or exit codes was enumerated and assessed:

| Call site | Hard-failure behavior | Assessment |
|---|---|---|
| `classify_ancestry` (merge-base) | exit above 1 -> ANCESTRY_ERROR | fail-safe |
| `classify_content_neutral` (diff --quiet) | exit above 1 -> CONTENT_NEUTRAL_ERROR -> ANCESTRY_ERROR | fail-safe |
| `classify_cherry_equivalent` (cherry) | non-zero -> CHERRY_ERROR -> ANCESTRY_ERROR | fail-safe (fixed) |
| `classify_cherry_equivalent` (diff-tree, line 127) | rc swallowed; empty output = droppable | **fail-open (NEW-1)** |
| `classify_residual_commit` (diff-tree, line 197) | rc lost; empty stream = CONTENT_ON_MAIN | **fail-open (NEW-1)** |
| `_blob_equal` (rev-parse blob OIDs) | failure -> not equal -> UNIQUE | fail-safe |
| `classify_residual_commit` D-rung (rev-parse main:path) | failure = absent = droppable | ambiguous (Info) |
| `compute_protected` (rev-parse HEAD/toplevel) | failure -> empty protection | **fail-open, bounded (NEW-2)** |
| `parse_worktree_list` / consuming reads | non-zero propagates | fail-safe (fixed) |
| `select_cherry_pick_candidates` (rev-list) | non-zero propagates, no COMMIT lines | fail-safe (fixed) |
| `run_report` / `run_apply` (enumerate_branches) | rc lost; empty list, status 0 | silent false success (NEW-3) |
| `run_apply` (classify_branch capture) | ANCESTRY_ERROR state not in delete allowlist | fail-safe |
| `reverify_delete_eligible` | unknown/error states -> BLOCKED-REVERIFY | fail-safe |
| `remove_worktree_safe` (status read) | diagnostic-only after removal already failed | fail-safe |
| `verify_consolidation_merged` | exit above 1 -> ANCESTRY_ERROR return 2; only MERGED_CLEAN unlocks | fail-safe |
| `consolidation_worktree_path` (mapfile) | rc lost; malformed path | robustness (NEW-4) |

---

## Test Quality Audit

- The five new hard-failure tests assert both the report token and the return status, and explicitly assert the absence of every delete-eligible verdict — strong, behavior-level assertions.
- Fail-before evidence is genuine: the red run at `e09c0e92` shows exactly the five new tests failing with the pre-fix fail-open verdicts recorded per scenario (MERGED_EQUIVALENT under worktree-list and cherry failures; status-0 under rev-list failure).
- Fixtures follow the established checked-in scenario convention; no temporary files; the stub writes nothing to disk.
- Gap: no fixture exercises the NEW-1 diff-tree failure or the NEW-2 rev-parse failure. The reviewer's reproductions demonstrate both are constructible with the existing stub seam (a single `.rc` file each), so cycle-3 test cost is low.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Cycle-2 delta inspected: shell libraries, fixtures (canned git plumbing output), tests, docs. |
| Destructive-action gating | PARTIAL | Allowlist gate, no-force removal, and re-verification are correct; NEW-1 can fabricate an allowlisted state from a hard git failure, and re-verification repeats the same failure deterministically. |
| Current-worktree protection | PARTIAL | Dual check correct under normal operation and now fails closed on worktree-list failure; NEW-2 rev-parse degrade remains (git-native backstops bound impact). |
| No prohibited PR shortcuts | PASS | No `gh pr create` in skill or scripts; consolidation PR delegated to Agent(pr-author) per AC7 (unchanged since cycle 1). |
| Header/contract accuracy | FAIL | Classification lib header (lines 24-28) claims hard git failures never resolve to MERGED verdicts; falsified by the NEW-1 reproduction. |

---

## Research Log

Evidence sources: full branch diff (`git diff b2351cbc..921b5c40`), remediation plan/inputs and cycle-2 evidence artifacts, direct reading of all four production shell files and the five bats suites and stub, `gh run view` for runs 29970355445 (red, fail-before) and 29970805348 (green, pass-after), reviewer re-parse of the downloaded `cov.xml`, local shfmt/shellcheck corroboration, and two deterministic stub-scenario reproductions executed against scratchpad fixture directories (documented in `policy-audit.2026-07-22T21-16.md` Appendix B). No external research required.

---

## Verdict

The cycle-2 remediation is well-executed: the fix pattern is correct and consistently applied at every CR-1 site, the pure-move split preserved behavior (80/80 pre-existing tests green in the fail-before run), the regression tests are genuine and precise, and the toolchain/coverage gates all pass with independent verification. The review nevertheless finds the branch not mergeable under the standard the orchestrator set for this feature: the generalized hard-failure invariant fails at the diff-tree rung, where a reproduced hard git failure still yields a delete-eligible verdict that survives re-verification (NEW-1, Blocking), and the protection computation retains a bounded silent-degrade path (NEW-2, Major).

**Recommendation: No-Go.** Route NEW-1 (and NEW-2 with it, given the shared fix pattern and low incremental cost) through remediation cycle 3 via `remediation-inputs.2026-07-22T21-16.md`.
