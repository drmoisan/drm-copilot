# Code Review: cleanup-merged-worktrees (#396)

---

**Review Date:** 2026-07-22
**Reviewer:** feature-review agent (Claude Code)
**Feature Folder:** `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/`
**Feature Folder Selection Rule:** Single active folder whose suffix matches the canonical issue number (396) and whose scoping docs are the branch's primary doc changes.
**Base Branch:** `main` (merge base `b2351cbc3fb3916f516d77567a1c9e40457c8981`)
**Head Branch:** `drm-copilot-wt-2026-07-21T21-57` (`691883474ef76e89f94551f5bbdcbe3436514893`)
**Review Type:** Initial review

---

## Executive Summary

The branch adds a deterministic bash cleanup tool for merged git worktrees/branches: a thin CLI wrapper (`scripts/bash/cleanup-worktrees.sh`, 86 lines), a read-only classification library (`cleanup_worktrees_lib.sh`, 499 lines), a mutating actions library (`cleanup_worktrees_actions_lib.sh`, 300 lines), a Claude Code skill documenting the end-to-end workflow with pr-author delegation, 36 bats tests in five suites driven through a checked-in recording git stub, and full feature-folder documentation and evidence. The diff is additive only (123 files, +2800/-0) and touches no existing production code.

**What changed:**
Implementation follows the spec's four-rung classification ladder (ancestry, content-neutral diff, cherry patch-id equivalence, rename-aware blob-OID comparison) with a dual current-worktree/branch exclusion, a report-default/apply-explicit CLI contract, consolidation onto a `documentationandmemories` branch in a dedicated worktree, and fixed-order deletion mechanics with same-process re-verification and a no-force dirty-worktree block. Test verification ran via CI dispatch (`ubuntu-latest` run 29922832766, green, 80/80, 89.0% line coverage) because the bash toolchain cannot run in this Windows environment; this reviewer independently re-ran shfmt and shellcheck check-only locally (both exit 0) and re-parsed the downloaded Cobertura artifact.

**Top 3 risks:**
1. Latent fail-open on anomalous git failure: or-capture (`rc=$?`) assignments inside process substitutions never propagate to the parent shell, so a hard `git cherry` failure with empty output could classify a branch `MERGED_EQUIVALENT` (delete-eligible) instead of failing fast (CR-1, Major).
2. Production code contains a stub-aware branch (re-surfacing `stub-git:` lines to stderr) inside `cherry_pick_candidates` — test infrastructure awareness in production logic (CR-2, Minor).
3. `cleanup_worktrees_lib.sh` is at 499 of 500 lines; any future change to that file forces a split (CR-3, Nit).

**PR readiness recommendation:** **Go** — zero Blockers; the one Major finding is a low-likelihood robustness hardening item that does not violate a policy gate and is recommended as a follow-up issue.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `scripts/bash/cleanup_worktrees_lib.sh` | lines 117, 270, 375 (CR-1) | The or-capture idiom (`rc=$?`) placed inside process substitutions — `done < <(cleanup_wt_git worktree list --porcelain ...)`, `done < <(cleanup_wt_git cherry main "$branch" ...)`, `done < <(cleanup_wt_git rev-list ...)` — assigns `rc` in a subshell, so the parent function's `rc` stays 0 and the failure is silently ignored. In `classify_cherry_equivalent`, a hard `git cherry` failure (non-zero exit, empty output) yields an empty residual set and the function prints `MERGED_EQUIVALENT`, a delete-eligible verdict (fail-open). In `parse_worktree_list`, a failed `git worktree list` yields an empty worktree list, which weakens path-based protection for the main worktree. | Capture output before iterating, e.g. `out=$(cleanup_wt_git cherry main "$branch") \|\| return 2` (or set a sentinel file/variable via a non-subshell mechanism), and propagate a hard-error verdict analogous to `ANCESTRY_ERROR` so an anomalous git failure is never delete-eligible. | This is a destructive tool whose entire value is fail-safe classification; the spec's Outputs contract requires non-zero exit on error conditions. Risk is bounded: the failure mode requires git to fail on `cherry` while succeeding on `merge-base`/`diff` in the same process, report mode is the no-mutation default, apply-mode re-verification exists (though it re-runs the same fail-open path), and git refuses to delete a checked-out branch. | Inspected `cleanup_worktrees_lib.sh` lines 101-120, 255-279, 356-377; bash semantics of process substitution (assignments in `<(...)` run in a subshell). No fixture simulates a cherry hard-failure, so the suite does not cover this path. |
| Minor | `scripts/bash/cleanup_worktrees_actions_lib.sh` | lines 96-102 (CR-2) | `cherry_pick_candidates` contains stub-aware production logic: it detects `stub-git: ` marker lines in captured cherry-pick output and re-emits them to stderr so tests can observe argv. Production behavior branches on a test-infrastructure marker. | Move argv observation into the stub/test layer (e.g., have the stub tee its log to a scenario-side channel the test reads), or document the marker as a supported diagnostic contract. No functional harm today: the branch is a no-op under real git. | Test-awareness in production code couples the tool to its test harness and can mask real output-parsing differences between stub and real git. | Inspected `cleanup_worktrees_actions_lib.sh` lines 96-102 and the stub's stderr-logging contract (`tests/fixtures/cleanup_worktrees/stub-bin/git` header). |
| Minor | `scripts/bash/cleanup_worktrees_lib.sh` | `classify_branch` / `select_cherry_pick_candidates` (CR-4) | Redundant subprocess work: `classify_cherry_equivalent` runs `git cherry` once in `classify_branch` and again inside `select_cherry_pick_candidates`; `classify_residual_commit` runs twice per unique residual (once for counting, once for record emission); `compute_protected` and `parse_worktree_list` re-run per branch inside `run_report`, giving O(branches x worktrees) git invocations. | Acceptable at current repo scale (2-5 stale branches per epic per user-story). If runtime grows, hoist protection/worktree parsing to the driver and thread verdicts through. | Determinism is unaffected; this is a performance and duplication observation only. | Inspected call graph: `run_report` -> `classify_branch` -> (`compute_protected`, `parse_worktree_list`, `classify_cherry_equivalent`, `classify_residual_commit`, `select_cherry_pick_candidates` -> `classify_cherry_equivalent` again). |
| Nit | `scripts/bash/cleanup_worktrees_lib.sh` | whole file (CR-3) | 499 lines against the 500-line cap. | On the next change to this file, split (e.g., move the ladder rungs or the report driver out) rather than trimming comments to fit. | Any future addition breaks the cap; planning the split now avoids a rushed one later. | `wc -l` = 499 (`evidence/qa-gates/file-size-caps.2026-07-22T09-01.md`, spot-checked). |
| Info | `tests/shell/test_cleanup_worktrees_enumeration.bats` | fallback tests (lines 58-70) | Two seam-fallback tests execute the real `git --version` from PATH. | None required. Read-only, repo-independent invocation; acceptable in a repo whose toolchain already requires git. | Documents the only real-binary touchpoint in the suite. | Inspected test file; the stub is used for every other invocation. |
| Info | `scripts/bash/cleanup_worktrees_actions_lib.sh` | `cherry_pick_candidates` | Cherry-pick ordering (LC_ALL=C by branch, oldest-first per branch) is inherited from the caller's fed order rather than enforced by sorting inside the function; the function comment documents this contract. | None required; the consolidation test asserts fed-order preservation and `run_report` guarantees the feed order. | The ordering guarantee is real but distributed across two functions; the comments make the contract explicit. | Inspected `run_report` emission order and the consolidation suite's ordering assertion (a1 before b1). |

No Blockers. One Major finding (CR-1), recommended as a follow-up hardening issue; it does not gate this merge under the remediation-trigger rules (no policy FAIL, no toolchain failure, no Blocker).

---

## Implementation Audit

### Bash implementation audit

#### What changed well

- Clean three-file architecture: read-only classification, mutating actions, and a dispatch-only wrapper — matching the house `shell-qc.sh` + `shell_qc_lib.sh` pattern and keeping every file under the 500-line cap.
- The git-binary seam (`CLEANUP_WT_GIT_BIN`, empty/nonexistent treated as missing) exactly mirrors the established `SHELL_QC_<TOOL>_BIN` convention, making the stub strategy consistent repo-wide.
- Exit-code semantics are handled precisely where the spec demands it: `merge-base --is-ancestor` 0/1/>1 maps to MERGED_CLEAN / continue / ANCESTRY_ERROR, and ANCESTRY_ERROR is a hard failure that propagates a non-zero `run_report` exit — never misread as "not merged".
- Safety layering in apply mode is genuinely defense-in-depth: explicit delete-eligible allowlist, per-candidate same-process re-verification, no-force worktree removal with DIRTY reporting, worktree-remove-before-branch-delete ordering, and a consolidation-merge ancestry gate before the consolidation branch can be deleted.
- No commit-message text matching anywhere in classification (grep-verified: no `git log`/`--grep` in either library), honoring the spec's prohibited-inputs list.
- Comments are rationale-focused and unusually complete: every function documents purpose, args, returns, and the report-line contract is stated in both library headers.

#### Determinism and contract notes

- Report lines are pipe-delimited, one record per line, `LC_ALL=C` ordered via `enumerate_branches`; states are closed enums matching the spec's contract (`NOT_MERGED | MERGED_CLEAN | MERGED_CONTENT_NEUTRAL | MERGED_EQUIVALENT | HAS_UNIQUE_RESIDUALS | PROTECTED_CURRENT`; per-commit `EQUIVALENT | CONTENT_ON_MAIN | EMPTY | UNIQUE | CONFLICT`).
- Path normalization (`normalize_wt_path`: backslash conversion, lowercasing, trailing-slash strip) makes the Windows/WSL path comparison practical for the dual exclusion.
- The wrapper's usage/exit-code contract (0 help, 2 usage error) matches the `shell-qc.sh` house pattern as the spec requires.

#### Error handling and logging

- `set -euo pipefail` in the wrapper with a source-guard and an explicit final `exit "$rc"`; errors go to stderr with specific messages (e.g., the pre-existing consolidation-branch refusal names the ref and the remedy).
- The expected-non-zero or-capture idiom is applied consistently — but three captures sit inside process substitutions where the assignment cannot reach the parent shell (finding CR-1 above). `_blob_equal` correctly treats rev-parse failure as "not equal" (safe direction), and `check_main_freshness` is correctly advisory-only.

---

## Test Quality Audit

The 36 new tests verify behavior through the report-line contract and the stub's argv log, which makes assertions behavioral (what git commands ran, what records were emitted) rather than implementation-detail-bound. The six AC8 scenarios are covered one-to-one by named fixtures. Negative destructive-path assertions (`!= *"branch -D"*`, `!= *"--force"*`) verify the tool's central safety property: eligible states produce destructive argv, non-eligible states produce none.

### Reviewed test and QA artifacts

- `tests/shell/test_cleanup_worktrees_enumeration.bats` — enumeration, porcelain parsing (branch/detached/locked/prunable), seam override/fallback, dual protection, freshness WARN. Exact-line assertions on the record contract.
- `tests/shell/test_cleanup_worktrees_classification.bats` — all four ladder rungs plus ancestry_error hard-fail and the PROTECTED_CURRENT exclusion (including the main worktree branch).
- `tests/shell/test_cleanup_worktrees_consolidation.bats` — pre-existing-branch refusal, dedicated worktree creation off main, `-x` on every pick, ordering, conflict abort-and-surface with intra-branch skip, empty-pick reclassification, abort cleanup.
- `tests/shell/test_cleanup_worktrees_deletion.bats` — dirty-worktree block with DIRTY lines and no `--force` token, reverify flip block, remove-before-delete ordering, branch-only path, non-eligible no-op, consolidation-merge gate both ways.
- `tests/shell/test_cleanup_worktrees_cli.bats` — help/usage exit codes, report-mode no-mutation, apply-mode eligible-only argv, source-guard.
- `tests/fixtures/cleanup_worktrees/stub-bin/git` — recording stub with a documented KEY scheme; writes nothing to disk; sanitizes ref/path characters deterministically.
- `evidence/qa-gates/*.2026-07-22T09-01.md` — format/check/coverage/file-size gates, all exit 0, with the one red-then-green remediation cycle documented (test-only fix `4851f3c9`).

### Quality assessment prompts

- **Determinism:** git binary fully stubbed with canned fixtures; `LC_ALL=C` ordering asserted; no time, randomness, or network. Two tests touch the real `git --version` only.
- **Isolation:** one function or CLI path per test; scenario selection via env var means zero cross-test state.
- **Speed:** stub subprocesses only; the full 80-test suite completes within the normal CI shell-coverage run.
- **Diagnostics:** exact-string assertions on single records pinpoint the divergent line; the stub's argv log makes "which git command ran" directly assertable.
- **Gap:** no fixture simulates a hard `git cherry`/`worktree list` failure, so the CR-1 fail-open path is untested (consistent with it being unnoticed).

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection: no credentials, tokens, or `.env` content anywhere in the 123 added files. |
| No unsafe subprocess or command construction | PASS | All git invocations pass arguments as discrete argv tokens through `cleanup_wt_git`; no `eval`, no word-splitting of user input; all expansions quoted (shellcheck clean, 0 findings). |
| Input validation at boundaries | PASS | CLI dispatch accepts a closed command set and exits 2 otherwise; `CLEANUP_WT_GIT_BIN` override must be executable or is treated as missing; branch names come from `for-each-ref` plumbing, not user input. |
| Error handling remains explicit | PARTIAL | Specific stderr messages and explicit exit codes throughout; ANCESTRY_ERROR propagates. Exception: the CR-1 dead or-captures leave three anomalous-git-failure paths silent (Major finding, follow-up recommended). |
| Configuration / path handling is safe | PASS | Path comparison normalized (slash/case/trailing-slash); consolidation worktree path derived from the main worktree stanza or an explicit env override; the caller's worktree is never a `git -C` target in consolidation. |
| Destructive-action gating | PASS | Delete-eligible allowlist + same-process re-verification + no-force + dirty block + consolidation ancestry gate; `PROTECTED_CURRENT` dual-check; main worktree always protected. Verified by deletion/CLI suites. |
| No prohibited PR shortcuts | PASS | `grep -rn "gh pr create\|gh pr edit"` over the skill and scripts: only the prohibition text in SKILL.md matches; the skill's `allowed-tools` frontmatter grants only the wrapper and narrow read-only/push git commands. |

---

## Research Log

No external research was required. All review evidence came from the repository: the branch diff, feature-folder docs and evidence, `.claude/rules/shell.md` and `quality-tiers.md`, the #393 audit precedent for the bash coverage gate, local check-only shfmt/shellcheck re-runs, the gh CLI run metadata for CI run 29922832766, and the downloaded Cobertura artifact `artifacts/pester/kcov-ci/cov.xml`.

---

## Verdict

The implementation is ready for normal PR flow. It matches the spec's design decisions rung-for-rung, the safety posture (report-default, dual exclusion, allowlist gating, re-verification, no-force) is implemented and test-verified, the toolchain is clean at CI-canonical versions with 89.0% line coverage, and the diff is purely additive. One Major robustness finding (CR-1: dead or-captures in process substitutions creating a narrow fail-open on anomalous git failure) should be filed as a follow-up hardening issue with a fixture simulating a `git cherry` hard failure; it does not meet the Blocker bar because the trigger requires an anomalous partial git failure, the default mode is non-mutating, and git's own checked-out-branch refusal bounds the worst case. Minor and Nit findings are quality observations that do not affect merge readiness.

**Recommendation: Go.**
