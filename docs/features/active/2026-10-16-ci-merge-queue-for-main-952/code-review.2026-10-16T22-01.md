# Code Review: CI merge queue for `main` (#952) - re-review with the scoped coverage run (ORCH-R5)

---

**Review Date:** 2026-10-16
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-16-ci-merge-queue-for-main-952`
**Feature Folder Selection Rule:** the only active feature folder changed on the branch; its `-952` suffix matches the branch name.
**Base Branch:** `main`, merge base `fa27cd5edcb39a5d5f63054c3e38cefef18ab316` (`origin/main` has since advanced to `cdc7bbc99`; no file overlap)
**Head Branch:** `bug/ci-merge-queue-for-main-952` @ `76d654eec7a3607a9782aa0876d5b60093631bb8` (no PR yet)
**Review Type:** Re-review after the scoped `codex-hooks` coverage run; no tracked source change since the previous review (`git diff --name-only b844048d9 HEAD`: five feature-folder files)

---

## Executive Summary

Reviewed evidence: the full branch diff (293 files), `artifacts/pr_context.summary.txt` and appendix (regenerated 22:00 UTC at head `76d654eec`), `evidence/regression-testing/codex-helper-scoped-coverage.2026-10-16T21-56.md`, a reviewer parse of the scoped `artifacts/pester/powershell-coverage.xml` and `artifacts/pester/pester-junit.xml`, the issue #936 and issue #935 coverage-attribution records, and gh CLI behavior for mixed-case pull-request URLs.

**Previous-review verification:**

| Prior ID | State | Evidence |
|---|---|---|
| CR-1 (Codex helper coverage) | Open; evidence complete; decision pending | Scoped run: `.codex/hooks/enforce-epic-merge-gate-command.ps1` 54/54 credited, the fourteen full-run-uncredited lines at `ci` 1 to 3; the `.claude/hooks` copy 0/54 in the same file (not in scope), so the credit is from the Codex suites; 1806 passed, 0 failed. Full run R_final_3 still 74.07%. |
| CR-15 (stated reason the scoped run was unavailable) | Resolved | Run performed through `mcp__drm-copilot__run_poshqc_test`; the new evidence file records the correction. |
| CR-16 (case-sensitive `/pull/` check) | Closed, no action | gh 2.87.3 treats `/PULL/` and `/Pull/` URLs as branch names (`no pull requests found for branch ...`, exit 1); `git check-ref-format --branch` rejects such a string, so no merge can result. |

**Top 3 risks:**
1. The canonical full-run measurement of the Codex helper stays at 74.07% and will be reported again on the PR head; acceptance against AC-27 needs a recorded decision (CR-1).
2. `origin/main` has advanced; the branch must be updated before the PR so that S9 measures the merged head (CR-18).
3. `hook-docs-only-diff.ps1` is at 497 lines; the next edit needs an extraction (CR-17).

**PR readiness recommendation:** **Not ready** - one Blocker awaiting a recorded decision on complete evidence (CR-1); AC-28 pending CI.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `.codex/hooks/enforce-epic-merge-gate-command.ps1` | lines 67, 68, 72, 165, 166, 171, 172, 179, 182-186, 189 | CR-1: 74.07% (40/54) in the full CI run; 100.00% (54/54) in the scoped `codex-hooks` run at the same blob `94d2145cd`. The shortfall is an attribution effect of the combined run (issue #936 mechanism), not untested code. | Record option (A) as issue #935 did: a decision record under `evidence/other/`, an amendment line beneath AC-27 that leaves the criterion text unchanged, then the qualified check-off. No code change. | AC-27 is verified from the full-run coverage-comparison artifact; issue #935 (merged at `cdc7bbc99`) resolved the same evidence class by coordinator decision with "not met as written"; issue #936's exception was pre-authorized in its AC text. | Reviewer parse of the scoped artifacts; `codex-helper-scoped-coverage.2026-10-16T21-56.md`; `cov1-decision-option1.2026-10-16T20-38.md` (#935) |
| Info | `.claude/hooks/hook-docs-only-diff.ps1` (four copies) | line 372 | CR-16 (closed): `$text.Contains('/pull/')` is ordinal while `ConvertFrom-EpicMergeGateSelector` matches `/pull/(\d+)` case-insensitively. gh 2.87.3 resolves only lowercase `/pull/` as a PR URL; a mixed-case token becomes a head-branch selector that cannot be a valid git branch name, so `gh pr merge` merges nothing. | No action. | The mismatch has no merge outcome; a change would add a fifth edit to a 497-line file for no behavioral effect. | `gh pr view .../pull/963` (resolves 963) versus `.../PULL/963` and `.../Pull/963` (exit 1); `git check-ref-format --branch` exit 128 |
| Info | `.claude/hooks/hook-docs-only-diff.ps1` (four copies) | whole file | CR-17 (carried): 497 lines, 3 below the limit. | No change in this item. | Visibility for later work. | Earlier `wc -l`; file unchanged |
| Info | branch | - | CR-18: `origin/main` advanced from `fa27cd5ed` to `cdc7bbc99` (#956, issue #935); 168 changed files on `main`, none shared with this branch. | Orchestrator merges `origin/main` before opening the PR; S9 runs on the merged head. No code change. | The PR must be up to date with `main`, and AC-28 must be measured on the final head. | `git fetch`; `grep -Fxf` over the two name lists: no match |
| Info | `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/policy-followups.md` | Record 4 | CR-19: Record 4 says the mechanism is "likely, not experimentally verified" and does not mention issue #953 / PR #959 (open), which implements its proposed `UseBreakpoints = $false` change. | Optional: add one sentence citing the scoped-run evidence and #953 in the R1 decision commit. The Codex test headers' "likely cause" remains accurate and needs no change. | Traceability only. | Record 4 text; `gh pr view 959` `state OPEN` |
| Info | `tests/scripts/workflows/CiWorkflow.Tests.ps1` | lines 212-239 | CR-10 (carried): the call-graph test follows direct callees only; no nested reusable workflow exists today. | No change required. | Future-proofing only. | Initial review |
| Info | `.claude/settings.json` | permissions | CR-11 (carried, pre-existing): no project-level allow rule exists for the merge-confirmation parser, as none exists for `Invoke-CiGateParser.ps1`. | No change in this item. | Parity with the existing parser. | Initial review |

---

## Detailed Review Notes

### Correctness

- No tracked source or test file changed since the previous review; the cycle-2 correctness notes in `code-review.2026-10-16T21-30.md` stand (URL rule placement, N1 to N4 discrimination, credited lines 372-374 in both docs-only copies).
- Scoped-run validity: the scoped report contains one `.codex/hooks` package entry for the helper and a separate `.claude/hooks` entry at 0/54, which excludes cross-attribution between the byte-identical twins as the source of the credit. The Codex gate measures 152/153 and the Codex `hook-docs-only-diff.ps1` 124/127 in the same run, consistent with full-suite figures for files that the scope exercises.

### CR-16 analysis

- For a token such as `https://github.com/o/r/PULL/5`, M1 does not refuse it and the selector reader returns 5, so the merge gate may evaluate an authorization or docs-only decision for PR 5 of the session repository. The subsequent `gh pr merge` fails to resolve a pull request (branch-selector lookup on a string that cannot be a branch name), so no merge occurs. The outcome is fail-safe.
- `gh pr merge` was not executed (state-changing). The conclusion relies on `gh pr merge` sharing the PR finder used by `gh pr view`; this is the gh CLI design and was not verified by execution.

### Mirrors and manifests

- `git ls-files -s`: four helper copies `94d2145cd`; four `hook-docs-only-diff.ps1` copies `62e0d3529`.

### Policy constraints

- No edit under `.claude/rules/`, `.github/instructions/`, `_poshqc.yml`, `hook-command-invocation.ps1`, the PoshQC module or settings, or `config/poshqc-coverage.json`; no coverage exclusion; the ruleset is not applied.

---

## Typed-Python Review

The four Python files are test code and are unchanged since the cycle-1 review; Black, Ruff, and Pyright were clean then, and `quality-checks7` succeeds for 3.10 to 3.13 on R_final_3.

---

## Summary

| Severity | Count | IDs |
|---|---|---|
| Blocker | 1 | CR-1 |
| Major | 0 | - |
| Minor | 0 | - |
| Nit | 0 | - |
| Info | 6 | CR-10, CR-11, CR-16, CR-17, CR-18, CR-19 |

CR-1 is blocking and requires a recorded decision; the evidence is complete and supports option (A). CR-15 is resolved. CR-16 is closed with no action. CR-18 is an orchestrator step before the PR. CR-10, CR-11, CR-17, and CR-19 require no in-item code change.
