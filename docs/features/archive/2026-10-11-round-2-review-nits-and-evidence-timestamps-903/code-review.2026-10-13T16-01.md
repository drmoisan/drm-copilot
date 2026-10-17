# Code Review: Round-2 review nits and evidence timestamps (#903)

---

**Review Date:** 2026-10-13
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-11-round-2-review-nits-and-evidence-timestamps-903`
**Base Branch:** `origin/main` (`fd81a43b4`)
**Head Branch:** `bug/round-2-review-nits-and-evidence-timestamps-903` (`1de921a82`)
**Review Type:** Re-review after remediation cycle 1 (prior review: `code-review.2026-10-13T14-41.md`)

**Total blocking findings: 0.**

---

## Executive Summary

Remediation cycle 1 changed two test files and no production file: it added U26 rows to the surface-parameterized `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1` and a new `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1`. The remaining 11 cycle commits change only feature-folder documentation and evidence. The production diff against `origin/main` is unchanged from the prior review, and the prior implementation findings still apply.

Evidence reviewed: `git diff --name-status 75768b8b3 HEAD`, the full text of both remediated test files, the CI coverage XML and junit files of run 38423196404 (the reviewer downloaded the coverage artifact independently and confirmed it is byte-identical to the executor's copy), and the remediation evidence under `evidence/qa-gates/rem1-*.md`, `evidence/other/rem1-ri2-investigation.2026-10-13T15-21.md`, and `evidence/regression-testing/fail-before-exception.rem1-ri1-ri2.2026-10-13T15-54.md`.

**Prior Blocker CR-A:** resolved. Codex targets lines 356 and 370 record `ci` 1 (reviewer awk), and the Codex copy rose from 98.16% to 99.39%.

**Prior Minor CR-B (Codex epic-scope 206-207):** still `ci` 0. The reviewer accepts the documented exemption as Non-blocking: no regression, file at 89.09%, and the deny behavior is asserted by a passing direct test.

**Top 3 risks:**
1. The Pester coverage instrument does not attribute executed lines on `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` (183, 190, 191, 206, 207, 209). Until the cause is known, coverage figures for this file understate execution and cannot detect a real regression on these lines.
2. #565 CR-8 tightens behavior (a renamed cited folder with only a bare `#<n>` now denies as `target-record`); intended and documented.
3. The Decision suite stubs the two gate decision constructors, so it does not verify the real constructor output shape on the Codex surface; that shape is covered by existing gate suites.

**PR readiness recommendation:** **Ready** — open the PR and complete AC-48 from PR CI artifacts.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Resolved (was Blocker CR-A) | `.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` | lines 356, 370 | Now `ci` 1. U26 rows call `Get-OrchestrationEpicTargetDenyReason` with `target-ambiguous` and an unrecognized code on both surface legs and assert the exact reason text. | None. | Changed-line regression closed. | Reviewer awk over run 38423196404 XML: 353, 354, 356, 360, 364, 370 all `ci=1` on both surfaces; junit shows four U26 rows Passed |
| Minor (Non-blocking) | `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | lines 206-207 | Still `ci` 0 although ES-D1 passes in the Windows coverage job and its exact-reason assertion can only be satisfied through line 207 (the stub constructor is called nowhere else). Same file also shows 183, 190, 191, 209 at `ci` 0 while 185-204 are covered. | Accept exemption (d). Open a follow-up to investigate Pester attribution on this file (for example compare a run with `CodeCoverage.UseBreakpoints` toggled, or check whether a later re-dot-source of the file replaces the instrumented function definition). | No regression (replaced statements `ci` 0 at baseline), file 89.09% >= 85%, behavior tested. | `evidence/qa-gates/rem1-ri2-exemption.2026-10-13T15-54.md`; reviewer awk; junit ES-D1/ES-D2 Passed |
| Nit | `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1` | ES-D2 | ES-D2 asserts the allow decision but not `Should -Invoke Resolve-EpicScopeCheckpoint`, unlike ES-D1. | Add the same invocation assertion for symmetry when the file is next edited. | Confirms the allow comes from the in-scope branch, not an early return. | File read |
| Nit | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1` | U26 data rows | The two data rows exceed 120 characters (file total 32 such lines versus 23 at `origin/main`). The 120-column rule in AC-30 binds the production targets copies only, and the analyzer is clean. | No action required. | Readability only. | `awk 'length>120'` |
| Nit (carried) | `.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` (and 3 copies) | `Resolve-OrchestrationEpicTargetOutcome` | `$scope = $evaluation.Scope` assigned, then `$evaluation.Scope` re-read for the predicate call. | Pass `$scope`. | Readability only. | Prior review |
| Nit (carried) | `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` (and 3 copies) | lines 409, 474 | CR-8 edit extends two lines already over 120 characters. | Wrap when the file is next edited (496 lines; split may be needed first). | Consistency. | Prior review |
| Info (carried) | `tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1` and three suites | whole files | #737 F-1/F-2 withheld; F-1 not isolated from F-2. | Evaluate F-1 separately under Operator Follow-up 10. | F-1 may be deliverable independently. | `evidence/qa-gates/f1-f2-decision.2026-10-13T13-44.md` |
| Info | `remediation-plan.2026-10-13T14-46.md` | P6-T1 | Exemption rule (d) is defined in the remediation plan, not in the original P12-T24 text that was then checked off. | No action; the remediation plan explicitly reruns P12-T24 with rule (d). | Traceability. | `plan.2026-10-11T10-39.md` P12-T24; remediation plan P6-T1 |

No Blocker or Major findings.

---

## Implementation Audit

### Python implementation audit

No change in this cycle. Prior assessment stands: `is_file_shaped_component` rejects non-ASCII extensions before lower-casing; `npm_token_guard_test_support.py` split keeps both files under 500 lines.

### TypeScript implementation audit

No change in this cycle. Prior assessment stands (test-only edits; `tsc` clean).

### PowerShell implementation audit

#### What changed well (this cycle)

- U26 is a two-row `-ForEach` table inside the existing `Describe ... -ForEach @(<surfaces>)`, so each row runs against both the `.claude/hooks` and `.codex/hooks` copies; this is the mechanism that attributes coverage to the Codex copy. Expected strings are full literals, so any text drift fails the row.
- The fall-through row uses `target-unresolvable`, which no `switch` arm matches, so it exercises the default return at line 370 rather than a named arm.
- The Decision suite loads only the Codex epic-scope file and its siblings, stubs the two gate constructors with comments explaining why, and mocks `Resolve-EpicScopeCheckpoint` through a helper that builds an in-memory ready epic checkpoint. No file, process, or network access.
- The suite follows the Discovery-guard conventions: `Register-EpicStateBaselineMock` on both surfaces, the exact single-clause `if (Get-Command Get-CheckpointContent ...) { Mock ... }` guard, and the `baseline mock interception probe` row. The Discovery suite (334 tests) passes in run 38423196404.

#### API and safety notes

- No production API change in this cycle.
- `Set-DecisionScope` carries a justified `PSUseShouldProcessForStateChangingFunctions` suppression.

#### Error handling and logging

- No change.

---

## Test Quality Audit

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1` (399 lines) — U26 rows: AAA markers present, deterministic, no temp files.
- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1` (97 lines) — ES-D1/ES-D2: AAA markers, exact reason assertion, invocation count assertion on ES-D1.
- `evidence/qa-gates/rem1-ps-rows.2026-10-13T15-54.md` — reviewer re-read junit: four U26 rows and ES-D1/ES-D2 Passed on Windows; the Decision suite also appears in the Linux hook junit.
- `evidence/qa-gates/rem1-ri-lines.2026-10-13T15-54.md` and `ps-coverage.2026-10-13T15-55.md` — values match the reviewer's awk over the independently downloaded XML (per-file LINE counters for all ten files and per-line values for the RI lines).
- `evidence/regression-testing/fail-before-exception.rem1-ri1-ri2.2026-10-13T15-54.md` — fail-before exception is appropriate: the rows characterize unchanged, correct production code.

### Quality assessment prompts

- **Determinism:** No clock, sleep, random, or temporary-file use. `(Get-Location).Path` is the session root, and the relative path leg resolves to it regardless of host.
- **Isolation:** One outcome per row; mocks scoped per It.
- **Speed:** 0.001-0.010s per new row in CI.
- **Diagnostics:** `-Because` text on every assertion; `-BeExactly` on reason strings.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Test-only changes; synthetic paths (`/synthetic-worktrees/...`). |
| No unsafe subprocess or command construction | ✅ PASS | No process invocation in new tests. |
| Input validation at boundaries | ✅ PASS | Unchanged production validation; U26 pins deny reasons. |
| Error handling remains explicit | ✅ PASS | No change. |
| Configuration / path handling is safe | ✅ PASS | No path handling change. |

---

## Research Log

No external research was required. Behavior was verified from the branch diff, the remediated test files, the run 38423196404 artifacts (downloaded independently by the reviewer), and the feature-folder evidence.

---

## Verdict

The remediation is test-only, closes the prior blocking coverage regression, and adds a direct test of the Codex epic-scope decision tail. The residual coverage-attribution gap on Codex epic-scope lines 206-207 is a measurement anomaly on behavior that is tested and was uncovered at baseline; it is Non-blocking with a follow-up. The branch is ready for the PR flow.

**Total blocking findings: 0.**
