# Code Review: documentation-estate template and onboarding (#1038)

---

**Review Date:** 2026-11-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038`
**Feature Folder Selection Rule:** the only active feature folder in the branch diff; its suffix matches issue 1038 in the branch name.
**Base Branch:** `origin/epic/documentation-estate-tooling-integration` (merge base `d395d5140f3822eeef453f2055d4ac539656d629`)
**Head Branch:** `feature/documentation-estate-template-and-onboarding-1038-r2` (`c3b44cbb2f06d783798946a19e94fca5273c14a6`)
**Review Type:** Re-review after remediation cycle 1

---

## Executive Summary

The branch adds an epic manifest template for a documentation estate, five onboarding pages, three Pester suites and two Pester test-support modules. It changes no production code. This re-review covered the following:

- the full branch diff (71 paths);
- the cycle 1 delta from the review commit `610ff1d53` (26 paths: 3 test files, 1 onboarding page, `spec.md`, the 2026-10-30 plan, the remediation plan and evidence);
- the PR context artifacts generated at head `c3b44cbb2`;
- the merged JUnit and JaCoCo reports;
- a reviewer re-run of the formatter, the analyzer and the logical line counts.

Every row of the previous review is closed:

- **F-1 (Major, blocking):** the spec now carries the Python-floor erratum. SAC-12, the design bullet and the contract table state 3.11, and plan task [P2-T3] is aligned.
- **R-1:** `consumer-onboarding.md` now says "PowerShell 7.4 session".
- **R-2:** a non-integer `issue_num` is reported as `EPIC_MANIFEST_ISSUE_NUM_INVALID`, and a positive control covers it.
- **R-3:** `Invoke-EstateDocumentElement` takes a mandatory `-LedgerOperation` set. The inline `set-dimension` duplicate is gone.
- **R-4:** the end-to-end suite builds each step's scenario once per `Context`. Its runtime fell from 211.119 s to 82.588 s, and its `Should` lines are unchanged.

**What changed in cycle 1:**
- `tests/scripts/claude-lib/docs/EndToEndDocumentationEstate.Tests.ps1` (298 lines): 4 `Context` blocks with one `Invoke-EstateScenario` call each; `-LedgerOperation` helper; file-level justified `PSUseDeclaredVarsMoreThanAssignments` suppression.
- `tests/scripts/claude-lib/docs/EpicManifest.TestSupport.psm1` (303 lines): distinct `EPIC_MANIFEST_ISSUE_NUM_INVALID` code, added to `.NOTES`.
- `tests/scripts/claude-lib/docs/DocumentationEstateEpicTemplate.Tests.ps1` (229 lines): one new positive control (19 `It` blocks).
- `docs/engineering/documentation-estate/consumer-onboarding.md`: one word.
- `spec.md`, `plan.2026-10-30T18-59.md`: erratum and 3.11 alignment; SAC-12 re-checked.

**Top 3 risks:**
1. The CI clause of SAC-24 (`poshqc / PowerShell QC`) has not run. It is pending the orchestrator's S9 gate.
2. The four `Context` blocks share one scenario result per block among their `It` blocks. This is safe today because no `It` writes to it. A future `It` that mutates `$scenario` would couple tests within that `Context` (Info row).
3. The file-level suppression of `PSUseDeclaredVarsMoreThanAssignments` also covers any future unused variable elsewhere in the file (Info row).

**PR readiness recommendation:** **Ready** — no blocking row; the remaining rows are Info and Nit.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038/spec.md` | `## Corrections to the Research`; SAC-12; `### Onboarding documentation`; `## Cross-Child Contract Dependencies` | Closed: previous blocking row F-1. The erratum entry is present; `3.10` remains only inside it; SAC-12 states 3.11 and is checked with citations. | None. | Confirms the previous blocking row is resolved. | Reviewer `grep -n -F "3.10"` (1 line, erratum) and `grep -n -F "3.11"` (4 lines) on the spec; `grep -c -F "3.10"` on the plan returns 0; `evidence/qa-gates/ac-verification.2026-11-07T23-10.md` |
| Info | `tests/scripts/claude-lib/docs/EpicManifest.TestSupport.psm1` | `Get-EpicManifestSchemaFinding`; `.NOTES` | Closed: previous Minor row R-2. The non-integer branch emits `EPIC_MANIFEST_ISSUE_NUM_INVALID`; `EPIC_MANIFEST_KEY_MISSING` keeps its missing-key meaning only. | None. | Distinct, accurate diagnostics; the branch is now under test. | Test `fails with EPIC_MANIFEST_ISSUE_NUM_INVALID for a non-integer issue_num` passed (JUnit, 19/19 in the suite) |
| Info | `tests/scripts/claude-lib/docs/EndToEndDocumentationEstate.Tests.ps1` | `Invoke-EstateDocumentElement` | Closed: previous Nit row R-3. The two switches are replaced by a mandatory `ValidateSet` array, every path is used, and the call sequence is unchanged. | None. | Removes duplicated argument lists. | Reviewer inspection; `'set-dimension'` and `'set-disposition'` each occur once in the file |
| Info | `tests/scripts/claude-lib/docs/EndToEndDocumentationEstate.Tests.ps1` | `Describe 'documentation estate end to end'` | Closed: previous Minor row R-4 (D-3a). Four `Context` blocks each replay the scenario once in `BeforeAll` into a block-local `$scenario`; no `It` writes to it. Within one `Context` the `It` blocks share that read-only result; that is the design trade-off of D-3a. | Keep `It` blocks read-only on `$scenario`; an `It` that needs to mutate state should call `Invoke-EstateScenario` itself. | Preserves independence across `Context` blocks while cutting the runtime. | `evidence/qa-gates/e2e-runtime.2026-11-07T23-07.md` (211.119 s to 82.588 s, ratio 0.391); `evidence/other/e2e-assertion-parity.2026-11-07T22-50.md` (25/25, 0 differences) |
| Info | `tests/scripts/claude-lib/docs/EndToEndDocumentationEstate.Tests.ps1` | file-level `param()` block | The `PSUseDeclaredVarsMoreThanAssignments` suppression is file-wide, so it would also hide a future unused variable elsewhere in the file. It is justified and follows the `OrchestratorState.Tests.ps1` precedent. | None required. | Recorded for maintainers. | Reviewer re-run: `Invoke-ScriptAnalyzer` 0 findings; 1 `SuppressMessageAttribute` in the file |
| Nit | `tests/scripts/claude-lib/docs/EndToEndDocumentationEstate.Tests.ps1` | `It 'records no InvokeProcess call under -AnalysisMethod scanner'` | The `# Act` section holds only a comment pointing at the `Context` `BeforeAll`. | None required; the comment states where the act occurs. | Readability only. | Inspection |
| Info | `docs/engineering/documentation-estate/consumer-onboarding.md` | introductory paragraph | Closed: previous Minor row R-1. The page now says "PowerShell 7.4 session". | None. | Consistent prerequisite statement. | Cycle diff from `610ff1d53` |
| Info | `docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038/spec.md` | SAC-24 | The CI clause is pending S9. The shuffle and single-process clauses are waived by owner decision 1. The coverage clause is met (0.00 delta on 72 files). | The orchestrator checks it off at S9 after `poshqc / PowerShell QC` succeeds on the final head. | CI-dependent criterion under `acceptance-criteria-tracking`. | `evidence/qa-gates/ac-verification.2026-11-07T23-10.md` |

No blocking row. No covered file is at or above 700 logical lines (maximum 303), so there is no file-size Warning row. `config/file-size-baseline.json` is not in the branch diff.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- D-3a keeps `Invoke-EstateScenario` as the only scenario builder, so each `Context` still gets a fresh in-memory fixture context. The four builds per file run replace the previous ten.
- The `-LedgerOperation` parameter runs operations in a fixed order (disposition, pin, dimension), whatever order the caller lists them in. The scenario's `update-ledger` call sequence therefore matches the previous version.
- The new positive control uses the same mutation helper (`Get-MutatedTemplateText`) and the same exact-set assertion style as the existing controls.

#### API and safety notes

- Reviewer re-run under PowerShell 7.6.9: `Invoke-Formatter` found 0 differences and `Invoke-ScriptAnalyzer` 0 findings across all five PowerShell files on the branch.
- No `$script:` assignment was added. The scenario result is block-local to each `Context`.

#### Error handling and logging

- Unchanged. `Invoke-EstateCommand` still throws with the command, the exit code and every finding when an exit code differs. A failure inside a `Context` `BeforeAll` therefore fails every `It` in that `Context` with that message.

---

## Test Quality Audit

The three suites passed inside the single parallel Pester gate (19342 tests, 0 failures). No production line changed, and every per-file coverage delta under `.claude/lib/docs/` is 0.00.

### Reviewed test and QA artifacts

- `tests/scripts/claude-lib/docs/DocumentationEstateEpicTemplate.Tests.ps1` — 19 tests, 0.795 s.
- `tests/scripts/claude-lib/docs/DocumentationEstateOnboarding.Tests.ps1` — 13 tests, 1.172 s.
- `tests/scripts/claude-lib/docs/EndToEndDocumentationEstate.Tests.ps1` — 10 tests, 82.588 s, 4 `Context` blocks.
- `evidence/regression-testing/pester-coverage.2026-11-07T23-06.md` — final parallel gate.
- `evidence/qa-gates/coverage-delta.2026-11-07T23-07.md` — comparison with PHASE0-PESTER; 0 negative deltas, 0 missing figures, no new failures.
- `evidence/qa-gates/e2e-runtime.2026-11-07T23-07.md` — runtime comparison.
- `evidence/other/e2e-assertion-parity.2026-11-07T22-50.md` — assertion multiset parity.
- `evidence/qa-gates/leak-scan.2026-11-07T22-51.md` — 0 failures.

### Quality assessment prompts

- **Determinism:** unchanged; scanner-only, fixed revisions, no process, no temporary file.
- **Isolation:** one behavior per `It`; a fresh context per `Context`; read-only sharing within a `Context`.
- **Speed:** improved; the end-to-end suite now takes 39.1 percent of its previous time.
- **Diagnostics:** unchanged `-Because` clauses; JUnit names now include the `Context` segment.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Inspection; fixture identifiers are synthetic. |
| No unsafe subprocess or command construction | PASS | No process is started; `ProcessCallLog` is asserted empty. |
| Input validation at boundaries | PASS | `ValidateSet` on `-LedgerOperation`; the manifest parser fails closed. |
| Error handling remains explicit | PASS | Coded `throw` messages; strict mode. |
| Configuration / path handling is safe | PASS | Paths come from `$PSScriptRoot`, and nothing is written. |
| Consumer neutrality | PASS | The neutrality test passed in the gate. The CON-1 scan of the 20 cycle paths found 0 matches. |

---

## Research Log

No external research was required. The merged upstream contracts were already bound in the Phase 0 evidence, and the Python floor was confirmed against the merged base in the initial review.

---

## Verdict

The branch is ready for normal PR flow. Every row of the previous review is closed with evidence. Formatting and analysis are clean, the suites pass in the parallel gate, coverage is unchanged, and the end-to-end runtime fell by 61 percent with no change to the assertions. The CI clause of SAC-24 remains for the orchestrator at S9.
