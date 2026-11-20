# Code Review: cleanup-merged-worktrees (#396) — Remediation Cycle 3 Re-review (Final Pass)

---

**Review Date:** 2026-07-22
**Reviewer:** feature-review agent (Claude Code)
**Feature Folder:** `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/`
**Base Branch:** `main` (merge base `b2351cbc3fb3916f516d77567a1c9e40457c8981`)
**Head Branch:** `drm-copilot-wt-2026-07-21T21-57` (`6c891b7375712e81fd431289685b325e755ab9ba`)
**Review Type:** Remediation cycle 3 re-review — final pass of the 3-pass remediation cap (prior reviews: `code-review.2026-07-22T09-23.md`, `code-review.2026-07-22T10-00.md`, `code-review.2026-07-22T21-16.md`). Review scope: full branch diff versus `main`, with a caller-directed independent line-by-line sweep of every git invocation in the three shell libraries and the CLI wrapper for discarded, subshell-lost, or unchecked exit statuses feeding classification or protection decisions.

---

## Executive Summary

**All cycle-3 findings are genuinely fixed, and the caller's generalized invariant now holds.** This reviewer performed an independent, line-by-line enumeration of every `cleanup_wt_git` invocation and every consumer of a git-backed producer in `cleanup_worktrees_lib.sh` (476 lines), `cleanup_worktrees_enumerate_lib.sh` (236 lines), `cleanup_worktrees_actions_lib.sh` (382 lines), and `cleanup-worktrees.sh` (92 lines) at head, without reference to the remediation plan's own audit table. The sweep classification for every site is recorded in the Implementation Audit below. Conclusion: **zero git invocations remain whose exit status is discarded, captured in an unreachable subshell, or otherwise unchecked before their output is treated as authoritative for a classification or protection decision.** Every remaining discarded-status site is a documented best-effort site whose every failure direction was individually re-assessed as fail-closed in this sweep.

Verification evidence:

1. **Fail-before/pass-after CI pairing is genuine.** Red run 29972970639 at `556749f8` shows exactly the 13 constructible fail-before tests failing with the pre-fix fail-open verdicts recorded per site (MERGED_EQUIVALENT under diff-tree and ls-tree failures; MERGED_CLEAN under rev-parse protection failure; status-0 clean runs under enumeration/worktree-list failures; the malformed consolidation path). Green run 29973982957 at `a1b39a4d` is 102/102. The three structurally-unfailable sites carry a documented impossibility dossier (`fail-before-exception.2026-07-22T21-16.md`) with alternative proofs.
2. **Reviewer reproductions at head.** Eight checked-in-scenario invocations under the stub (diff_tree_error, ls_tree_error, rev_parse_error_protection, enumerate_error via run_report and run_apply, consolidation_path_error, plus both D-rung guards) all produce the required fail-closed verdicts (`ANCESTRY_ERROR`/rc 2, rc 128 with no output, or preserved legitimate verdicts).
3. **Novel probe of an accepted-safe site.** A reviewer-built scratchpad scenario injecting a hard `git rev-parse <branch>:<path>` failure (rc 128) into `_blob_equal` on an A-status residual produces `UNIQUE|docs/x.md` -> `BRANCH|feature-bfail|NOT_MERGED`, rc 0 — fail-closed, as the sweep predicted; no delete-eligible verdict is reachable from that failure. Worst-case consequence is a false cherry-pick candidate whose pick resolves "now empty" and is skipped: content-preserving.
4. **Idiom grep.** Zero `< <(...)`/`mapfile`/`readarray` reads over git-backed producers; zero `|| true` on authoritative git captures. Survivors: one `< <(printf ...)` over a local variable, one arithmetic `|| true`, one grep-on-variable `|| true`, and the four Design-Decision-9 best-effort sites.
5. **Toolchain and coverage.** shfmt/shellcheck clean (executor evidence + reviewer-local corroboration + `bash -n`); coverage re-parsed from the downloaded Cobertura artifact: overall 91.5% (baseline 90.4%, no regression), per-file 100.0 / 93.2 / 92.1 / 92.8.

Remaining findings: the two accepted Minors carried since cycle 1 (CR-2, CR-4) and one new Info-level, spec-inherent observation (merge-commit-only residual ranges; see IN-1 below). None is a remediation trigger.

**PR readiness recommendation: Go** — zero Blocking or Major findings; the 3-pass remediation cap is satisfied without requiring a further cycle.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Resolved (was Blocking) | `scripts/bash/cleanup_worktrees_lib.sh` | `classify_cherry_equivalent` (line 149), `classify_residual_commit` (line 212) (NEW-1) | Hard `git diff-tree` failures previously resolved to the delete-eligible MERGED_EQUIVALENT verdict. | None — fix verified. | Guarded parent-shell captures emit DIFF_TREE_ERROR / RESIDUAL_ERROR, mapped by `classify_branch` to ANCESTRY_ERROR with return 2; the pre-deletion re-verification inherits the same fail-closed path. | Fail-before run 29972970639 (tests 1-2 red with MERGED_EQUIVALENT / CONTENT_ON_MAIN recorded); pass-after run 29973982957; reviewer reproduction at head: ANCESTRY_ERROR, rc 2. |
| Resolved (was Major) | `scripts/bash/cleanup_worktrees_enumerate_lib.sh` | `compute_protected` lines 185-194 (NEW-2) | Rev-parse hard failures previously degraded silently to an empty (weakened) protection set. | None — fix verified. | Non-zero `rev-parse --abbrev-ref HEAD` / `--show-toplevel` is now fatal with a stderr diagnostic; the detached-HEAD case (successful rev-parse printing HEAD) keeps its branch-name omission. | Fail-before tests 4-5 red pre-fix (MERGED_CLEAN recorded); reviewer reproduction at head: `BRANCH\curbranch\ANCESTRY_ERROR` (pipes elided), rc 2. |
| Resolved (was Minor) | `scripts/bash/cleanup_worktrees_lib.sh`, `scripts/bash/cleanup_worktrees_actions_lib.sh` | `run_report` lines 455-462, `run_apply` lines 333-340, `enumerate_branches` lines 73-83 (NEW-3) | Enumeration hard failures previously yielded status-0 "clean" reports; the for-each-ref pipeline attributed only sort's exit to rc. | None — fix verified. | Both drivers capture `parse_worktree_list` and `enumerate_branches` up front and return the git exit code before emitting any line; `enumerate_branches` captures for-each-ref before sorting. | Fail-before tests 6-9 red pre-fix; reviewer reproductions at head: rc 128, no output, for both run_report and run_apply. |
| Resolved (was Minor) | `scripts/bash/cleanup_worktrees_actions_lib.sh` | `consolidation_worktree_path` lines 53-67 and consumers at lines 84, 178 (NEW-4) | A worktree-list hard failure or empty main-worktree path previously derived the malformed `-wt/documentationandmemories` path. | None — fix verified. | Guarded capture plus an explicit empty-path check; both consumers guard the derivation (create aborts before mutation; abort-cleanup reports the skipped removal and still deletes the branch). | Fail-before tests 10-13 red pre-fix; reviewer reproduction at head: rc 128, empty stdout. |
| Resolved (was Info) | `scripts/bash/cleanup_worktrees_lib.sh` | `classify_residual_commit` D-rung lines 225-236 | The `rev-parse main:<path>` exit-only probe could not distinguish a hard failure from a legitimately absent path (both read as droppable). | None — fix verified. | Replaced by a guarded `ls-tree main -- <path>` capture: non-zero exit is RESIDUAL_ERROR; exit 0 non-empty means present (unique deletion); exit 0 empty means absent (droppable). Guards 14-15 pin both legitimate directions. | Reviewer reproductions at head: ls_tree_error -> ANCESTRY_ERROR rc 2; deleted_path_absent -> MERGED_EQUIVALENT rc 0; deleted_path_on_main -> NOT_MERGED. |
| Resolved (structural) | `scripts/bash/cleanup_worktrees_lib.sh` | `classify_branch` lines 423-426 | The second `git cherry ... \ grep -q` invocation whose exit was discarded in a pipeline is removed; the MINUS_PRESENT token is read from the already-captured cherry verdict. | None — the fail-open instance is structurally impossible. | Exactly one `cleanup_wt_git cherry` invocation remains in the file (reviewer grep); the token is emitted only when residuals remain and cannot collide with sha text. | Exception dossier entry (a); reviewer grep at head. |
| Minor (accepted) | `scripts/bash/cleanup_worktrees_actions_lib.sh` | lines 137-141 (CR-2, carried forward, unchanged) | Stub-aware production logic re-surfaces `stub-git:` marker lines to stderr. | Accepted since cycle 1; optional future cleanup: move argv observation into the test layer. | No behavioral impact under real git (the marker never matches); documented in the function comment. | `code-review.2026-07-22T09-23.md`. |
| Minor (accepted) | `scripts/bash/cleanup_worktrees_lib.sh` | call graph (CR-4, carried forward) | Redundant subprocess work, O(branches x worktrees) git invocations. | Acceptable at current scale; hoist if runtime grows. Note the cycle-3 minus-present refactor removed one duplicate cherry call. | Unchanged accepted Minor. | `code-review.2026-07-22T09-23.md`. |
| Info | `scripts/bash/cleanup_worktrees_lib.sh` | `classify_cherry_equivalent` (ladder rung 3) (IN-1, new) | A branch whose `main..branch` range contains only merge commits (e.g. a conflict-resolution "evil merge" whose non-merge commits are all patch-equivalent on main) yields empty `git cherry` output — git cherry skips merge commits — and classifies MERGED_EQUIVALENT despite the non-empty tree diff that rung 2 detected. | Consider a follow-up issue: when rung 2 reported NOT_NEUTRAL and cherry reports zero residual lines, treat the branch as HAS_UNIQUE_RESIDUALS or add a tree-level re-check before MERGED_EQUIVALENT. Not a cycle-3 remediation trigger. | Every git exit code on this path is checked; the verdict follows truthfully-reported git outputs. This is a semantic property of the AC2-prescribed cherry/patch-id ladder (which never inspects merge commits), not an exit-status defect, and requires an unusual history shape (all non-merge commits equivalent, unique content only in a merge commit). | Code inspection of the rung-2/rung-3 interaction; `git cherry` merge-commit exclusion is upstream git behavior. |
| Info | `scripts/bash/cleanup_worktrees_actions_lib.sh` | `verify_consolidation_merged` line 205 | `fetch origin main \ true` (best-effort) means a stale local `main` is possible during the post-merge gate; ancestry against a force-rewound remote could in principle diverge from remote reality. | None required — the gate compares against local `main`, and a stale main can only misreport in scenarios requiring a remote force-push, which is outside this tool's threat model. | Accepted best-effort site (Design Decision 9); the failure direction under normal (non-force-push) operation only blocks deletion. | Code inspection. |

Zero Blocking, zero Major, zero unaccepted Minor findings.

---

## Implementation Audit

### Independent line-by-line call-site sweep (caller-directed; performed without reference to the plan's audit table)

Every git-backed invocation or consumer at head `6c891b73`, with the reviewer's independent assessment:

| Call site | Exit-status handling | Assessment |
|---|---|---|
| `cleanup_wt_git` (enumerate lib 34-57) | `command -v` fallback, explicit 127, git exit propagated | fail-safe |
| `enumerate_branches` (74-82) | for-each-ref captured before sort; rc returned with no stdout | fail-safe (fixed) |
| `parse_worktree_list` (124-127) | guarded capture; rc returned before any record | fail-safe (cycle 2) |
| `compute_protected` rev-parse pair (185-194) | guarded; fatal with diagnostic | fail-safe (fixed) |
| `compute_protected` worktree read (203-206) | guarded; propagates | fail-safe (cycle 2) |
| `check_main_freshness` (230-231) | `\ return 0` skip | accepted-safe: advisory warn only; classification never consumes it |
| `classify_ancestry` (63) | rc-mapped 0/1/>1 with ANCESTRY_ERROR | fail-safe |
| `classify_content_neutral` (88) | rc-mapped 0/1/>1 with CONTENT_NEUTRAL_ERROR | fail-safe |
| `classify_cherry_equivalent` cherry (130) | guarded; CHERRY_ERROR | fail-safe (cycle 2) |
| `classify_cherry_equivalent` diff-tree (149) | guarded; DIFF_TREE_ERROR | fail-safe (fixed) |
| `_blob_equal` rev-parse pair (179-180) | `\ return 1` = not-equal = unique | accepted-safe: fail-closed toward non-eligibility (reviewer-probed; see Executive Summary item 3) |
| `classify_residual_commit` name-status diff-tree (212) | guarded; RESIDUAL_ERROR | fail-safe (fixed) |
| `classify_residual_commit` ls-tree D-rung (231) | guarded; RESIDUAL_ERROR vs empty-output absence | fail-safe (fixed) |
| `select_cherry_pick_candidates` cherry re-check (269-272) | guarded + token check, return 2 | fail-safe |
| `select_cherry_pick_candidates` rev-list (280) | guarded; rc returned, no COMMIT lines | fail-safe (cycle 2) |
| `select_cherry_pick_candidates` residual verdict (293-298) | callee returns 0 by contract; RESIDUAL_ERROR token aborts with 2 | fail-safe |
| `classify_branch` protected/worktree/ladder/token reads (333-436) | all guarded or token-mapped; every hard token maps to ANCESTRY_ERROR return 2 | fail-safe |
| `classify_branch` MINUS_PRESENT derivation (426) | substring of captured verdict; no git call | fail-safe (structural removal) |
| `run_report` up-front captures (455-462) | guarded; abort before any line | fail-safe (fixed) |
| `consolidation_worktree_path` (56-66) | guarded + empty-path check | fail-safe (fixed) |
| `create_consolidation_worktree` (84-98) | path guarded; ref probe if-checked; `worktree add` guarded | fail-safe (probe failure direction: proceed -> guarded add fails -> FAILED) |
| `cherry_pick_candidates` (138-160) | cherry-pick guarded; `--skip`/`--abort` best-effort inside an already-failing path; CHERRY_PICK_HEAD if-checked | accepted-safe: a failed skip/abort surfaces on the next pick (rc 1); consolidation-side only |
| `cleanup_consolidation_on_abort` (178-194) | path guarded (FAILED report on unknown path); remove/delete guarded with reported ACTION lines | fail-safe |
| `verify_consolidation_merged` (205-206) | fetch best-effort; merge-base rc-mapped 0/1/>1 | accepted-safe (see IN-2 Info row); only exit 0 unlocks |
| `reverify_delete_eligible` (231-234) | classify_branch guarded; rc -> BLOCKED-REVERIFY; state allowlist | fail-safe (converted) |
| `remove_worktree_safe` (263-278) | removal guarded; status read guarded diagnostic-only; still returns 1 | fail-safe (converted) |
| `delete_branch` (288) | guarded; ACTION reported; rc returned | fail-safe |
| `run_apply` (333-380) | up-front guarded captures; consolidation probe if-checked (failure keeps deletion blocked); vout token-allowlisted; per-branch classify captured with crc -> rc 1, allowlist unchanged | fail-safe (fixed) |
| Wrapper `cleanup-worktrees.sh` | no direct git; `main "$@" \ rc=$?` with explicit final `exit "$rc"` | fail-safe |

Non-git survivors of the idiom grep: `done < <(printf '%s\n' "$ce")` (local variable), `((crc > rc)) && rc=$crc \ true` (arithmetic), `grep '^stub-git: ' >&2 \ true` (grep over a captured variable). None consumes a git exit status.

### set -e interaction

The wrapper invokes `main "$@"` in an or-list, suspending errexit through the call tree; all fixes correctly rely on explicit rc observation rather than errexit, so behavior is identical in sourced (bats) and wrapper execution contexts. The guarded pattern (`local rc=0 out; out=$(cmd) || rc=$?`) never combines declaration and capture, so no exit code is masked by `local`.

### Deletion path

`delete_candidate` order is unchanged and correct: re-verify (now doubly fail-closed: rc guard + state allowlist), no-force worktree removal (dirty trees block; status-read failure still blocks), then `git branch -D` with reported result. The consolidation branch's own deletion remains gated on the exact `MERGED_CLEAN` token.

---

## Test Quality Audit

- The 13 fail-before tests assert status, exact report lines, and the explicit absence of every delete-eligible verdict — strong behavior-level assertions in the established harness (fresh `bash -c` per test, scenario isolation, stderr discarded, no temp files).
- The 4 pass-before guards pin behavior preservation across the D-rung conversion and the two fail-closed idiom conversions — exactly the regression risk of this cycle.
- Fail-before evidence is genuine and precise: run 29972970639 fails exactly the 13 expected tests with the pre-fix verdicts tabulated per site; the exception dossier covers the 3 structurally-unfailable sites with impossibility rationale and alternative proofs.
- Fixture and stub extensions (`ls-tree` KEY) follow the documented KEY scheme; all 8 new scenario directories are checked in.
- Gap (non-blocking): no bats test covers the `_blob_equal` hard-failure direction; the reviewer's novel probe demonstrates it is constructible and fail-closed. Optional future hardening only.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Cycle-3 delta inspected: shell libraries, fixtures (canned git plumbing output), tests, docs. |
| Destructive-action gating | PASS | Allowlist gate, no-force removal, doubly fail-closed re-verification; no reproduction produces a delete-eligible verdict from any hard git failure. |
| Current-worktree protection | PASS | Dual check fails closed on worktree-list and rev-parse hard failures; detached-HEAD legitimate case preserved. |
| No prohibited PR shortcuts | PASS | No `gh pr create` in skill or scripts; consolidation PR delegated to Agent(pr-author) per AC7 (unchanged). |
| Header/contract accuracy | PASS | All three library headers now state invariants that hold under every attempted reproduction; the stub header documents the new KEY. |

---

## Research Log

Evidence sources: full branch diff (`git diff b2351cbc..6c891b73`), remediation plan/inputs and cycle-3 evidence artifacts, direct line-by-line reading of all four production shell files, the hard-failure suite, and the stub; `gh run view` for runs 29972970639 (red, fail-before) and 29973982957 (green, pass-after); reviewer re-parse of the downloaded `cov.xml`; local shfmt/shellcheck/`bash -n` corroboration; eight checked-in-scenario reproductions and one novel scratchpad-scenario probe executed read-only against head. Upstream git behavior consulted for IN-1 (git cherry skips merge commits). No external research required.

---

## Verdict

The cycle-3 remediation is complete and well-executed: the uniform guarded-capture pattern is applied at every previously unguarded site, the structural removal eliminates rather than guards the pipelined cherry re-invocation, the D-rung conversion fixes an ambiguity while preserving both legitimate directions under pinned guards, and the drivers now abort before emitting anything on enumeration failures. The caller's generalized invariant — no git invocation whose unchecked result feeds a classification or protection decision — holds at head under an independent sweep and nine reproductions. Remaining items are two accepted Minors and one spec-inherent Info observation suitable for a follow-up issue.

**Recommendation: Go.** No remediation cycle 4 is required; the 3-pass cap is not exceeded.
