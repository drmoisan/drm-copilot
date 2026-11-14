# Code Review: documentation-estate template and onboarding (#1038)

---

**Review Date:** 2026-11-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038`
**Feature Folder Selection Rule:** the only active feature folder in the branch diff; its suffix matches issue 1038 in the branch name.
**Base Branch:** `origin/epic/documentation-estate-tooling-integration` (merge base `d395d5140f3822eeef453f2055d4ac539656d629`)
**Head Branch:** `feature/documentation-estate-template-and-onboarding-1038-r2` (`f668e4254135715cce4901e9b6f6d152cacb8d35`)
**Review Type:** Initial review

---

## Executive Summary

The branch adds an epic manifest template for a documentation estate, five onboarding pages for the docs tooling, three Pester suites and two Pester test-support modules. It changes no production code. The review covered the full diff (47 paths: 12 deliverable files, 3 modified feature documents, 32 evidence files), the PR context artifacts generated at head `f668e4254`, the merged JUnit and JaCoCo reports, and a reviewer re-run of the formatter and analyzer.

The test code is well-structured. The end-to-end suite drives the real dispatch table through `Invoke-DocsCommandCli` with one stateful in-memory context per test and asserts finding codes, `related_ids`, `related_paths`, receipt fields and `analysis_method` values. The onboarding contract suite derives its expected names from the merged dispatch table and the merged tool-definitions file, so an undocumented new subcommand or tool fails the suite. The manifest suite's positive controls show that each check can fail.

**What changed:**
- `extensions/drm-copilot/resources/feature-templates/epic/documentation-estate/epic.md` (216 lines) and `README.md`: an 11-child manifest (5 foundation children in wave 0, 5 page-family children in wave 1, one exit-gate child in wave 2) and manual-copy instructions.
- `docs/engineering/documentation-estate/{README,architecture,consumer-onboarding,command-reference,workflow}.md`: onboarding documentation.
- `tests/scripts/claude-lib/docs/EndToEndDocumentationEstate.Tests.ps1` (271), `DocumentationEstateEpicTemplate.Tests.ps1` (218), `DocumentationEstateOnboarding.Tests.ps1` (251), `DocumentationEstateFixture.TestSupport.psm1` (163), `EpicManifest.TestSupport.psm1` (302).
- `spec.md`, `user-story.md`, `plan.2026-10-30T18-59.md`: D-1 erratum, AC check-off, task check-off.

**Top 3 risks:**
1. The spec states a Python floor (3.10) that the merged code rejects. SAC-12 is checked off even though its text is not met, and no erratum records the change (blocking row 1).
2. The end-to-end suite runs for 211 s, because 10 tests each replay the scenario from the start. This adds measurably to the shard that runs it.
3. The CI clause of SAC-24 (`poshqc / PowerShell QC`) has not run yet. It is pending the orchestrator's S9 gate.

**PR readiness recommendation:** **Needs Revision** — one blocking documentation-governance row (spec erratum for the Python floor); the code and tests are ready.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038/spec.md` | SAC-12 (line 393); `### Onboarding documentation` (line 149); contract table (line 324); plan [P2-T3] (line 119 of `plan.2026-10-30T18-59.md`) | Blocking. SAC-12 is checked off, but its text ("with Python 3.10 or later") does not match the delivered page, which states 3.11 or later. 3.11 is correct for the merged code. The spec has no erratum for the Python floor, and lines 149 and 324 and plan task [P2-T3] still say 3.10. The D-1 finding-code divergence on this branch was handled with an erratum; this one was not. | Add `- Python floor (erratum, 2026-11-07): ...` to `## Corrections to the Research`, citing the 1031 owner decision of 2026-11-04 and `FLOOR = (3, 11)` in `.claude/lib/docs/python/run_docs_python_native.py`. In the same commit, change 3.10 to 3.11 in SAC-12, line 149, line 324 and [P2-T3]. Do not change the page or the tests. | The spec's own rule routes a divergence found in delivery through a recorded revision. `acceptance-criteria-tracking` leaves a criterion unchecked when its text is not met. As it stands, the requirements document would ship stating a floor the code rejects. | `consumer-onboarding.md` lines 15-19; `run_docs_python_native.py:18`; `evidence/qa-gates/ac-verification.2026-11-07T22-00.md` SAC-12 row; commit `53ce763d4` (D-1 precedent) |
| Minor | `tests/scripts/claude-lib/docs/EndToEndDocumentationEstate.Tests.ps1` | lines 98-150, 163-271 | The suite takes 211.119 s for 10 tests. Each `It` calls `Invoke-EstateScenario` and replays every step from R1: 5 tests replay through `Fixed`, 4 through `Defects`. | Optional: group the tests by step in `Context` blocks and build each step's scenario once in that `Context`'s `BeforeAll`. Tests in different `Context` blocks would still share no state. Keep D-3 if the owner prefers per-test replay. | Fast execution is a core unit-test property. A 211 s file can dominate the shard that runs it. | `artifacts/pester/pester-junit.xml` testsuite `time="211.119"` |
| Minor | `docs/engineering/documentation-estate/consumer-onboarding.md` | line 4 | Says "Examples run from a PowerShell 7 session", while line 8 requires 7.4 and `command-reference.md` line 4 says "a PowerShell 7.4 session". | Change "PowerShell 7 session" to "PowerShell 7.4 session". | The page should state its own prerequisite consistently. | Reviewer grep for `PowerShell 7[^.]` over the pages |
| Minor | `tests/scripts/claude-lib/docs/EpicManifest.TestSupport.psm1` | line 196 | A non-integer `issue_num` is reported under the code `EPIC_MANIFEST_KEY_MISSING`, although the key is present. No positive control covers this branch. | Report it under a distinct code (for example `EPIC_MANIFEST_ISSUE_NUM_INVALID`, added to the `.NOTES` code list) and add one positive control that mutates `issue_num: 900002` to a non-integer value. | A misleading code makes a failure harder to diagnose, and an untested branch can regress unnoticed. | Inspection; `DocumentationEstateEpicTemplate.Tests.ps1` positive controls cover cycle, unresolved, duplicate, self-edge and unsupported only |
| Nit | `tests/scripts/claude-lib/docs/EndToEndDocumentationEstate.Tests.ps1` | lines 86-96, 144 | `Invoke-EstateDocumentElement` without a switch (disposition, pin and dimension in one call) is never used. Line 144 repeats the `set-dimension` call inline. | Either call `Invoke-EstateDocumentElement -ElementId $idB` without a switch, or remove the unused path. | This removes duplicated argument lists from the test helper. | Inspection |
| Info | `tests/scripts/claude-lib/docs/*.Tests.ps1` | line 1 | The suites declare `#Requires -Version 7.0`, while the support modules' `.NOTES` state 7.4 and the entry script enforces 7.4. | None required. The entry script's own 7.4 check governs. | Recorded for consistency only. | Inspection |
| Info | `tests/scripts/claude-lib/docs/DocumentationEstateOnboarding.Tests.ps1` | line 129 | Tool names are extracted from the declaration form `definition("<name>"` bound in Phase 0 (`TOOL-FORM`). If the declaration form changes, extraction yields an empty set, and the suite fails closed through `Should -Contain` for each of the six names. | None. | Confirms that the derivation cannot pass vacuously. | `evidence/baseline/upstream-surfaces.2026-11-07T20-41.md` |
| Info | `docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038/spec.md` | SAC-24 | The CI clause is pending S9. The seeded-shuffle and single-process clauses are waived by owner directive (decision 1). The coverage clause is met (0.00 delta on 72 files). | The orchestrator checks it off at S9 after `poshqc / PowerShell QC` succeeds on the final head. | CI-dependent criterion under `acceptance-criteria-tracking`. | `evidence/qa-gates/ci-pending.2026-11-07T22-00.md` |

One blocking row (the Major row on `spec.md`). No covered file is at or above 700 logical lines, so there is no file-size Warning row.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- `EpicManifest.TestSupport.psm1` is pure and bounded. It parses only the YAML subset the template uses and throws `EPIC_MANIFEST_UNSUPPORTED` with the line number for anything else. It resolves `depends_on` through the union of `issue_num` and `feature_folder` before computing waves, which matches the behavior of `compute_wave_numbers` as the spec describes. Cycle detection uses a per-root visiting set with memoization.
- `DocumentationEstateFixture.TestSupport.psm1` reuses `New-DocsTestContext` (D-2) instead of building a second in-memory context. The R2 edit changes the help line inside A's declaration range without changing A's declaration, which exercises the declaration-lines digest precisely.
- `EndToEndDocumentationEstate.Tests.ps1` pins `-AnalysisMethod scanner` and asserts an empty `ProcessCallLog`, so the result does not depend on a Python interpreter.
- The neutrality test applies the 1020 tokenization and digest list, read from `DocsNeutrality.Tests.ps1`, and a synthetic-identifier positive control shows the scan can fail.

#### API and safety notes

- Support-module functions are advanced functions with `[CmdletBinding()]`, `[OutputType()]` and mandatory parameters; `Export-ModuleMember` limits the surface. The single analyzer suppression (`PSUseShouldProcessForStateChangingFunctions` on an in-memory factory) carries a justification.
- Reviewer re-run under PowerShell 7.6.9: `Invoke-Formatter` 0 differences, `Invoke-ScriptAnalyzer` 0 findings across the five files.

#### Error handling and logging

- `Set-StrictMode -Version Latest` and `$ErrorActionPreference = 'Stop'` in both modules. `Invoke-EstateCommand` throws on an unexpected exit code and includes every finding code and message, which gives an actionable failure.

---

## Test Quality Audit

The three suites passed inside the single parallel Pester gate (19341 tests, 0 failures). No production line changed, and every per-file coverage delta under `.claude/lib/docs/` is 0.00.

### Reviewed test and QA artifacts

- `tests/scripts/claude-lib/docs/DocumentationEstateEpicTemplate.Tests.ps1` — 18 tests, 0.388 s; schema, waves and five positive controls.
- `tests/scripts/claude-lib/docs/DocumentationEstateOnboarding.Tests.ps1` — 13 tests, 0.702 s; membership derived from merged sources, statements, neutrality, two positive controls.
- `tests/scripts/claude-lib/docs/EndToEndDocumentationEstate.Tests.ps1` — 10 tests, 211.119 s; full scenario through the real dispatch.
- `evidence/qa-gates/coverage-delta.2026-11-07T21-55.md` — baseline and final parallel runs; no new failures; coverage unchanged.
- `evidence/other/option-spelling.2026-11-07T21-18.md` — every example option matches the Phase 0 dispatch rows and tool input tables.
- `evidence/regression-testing/pester-shuffle.2026-11-07T21-55.md` — waiver record under owner decision 1.

### Quality assessment prompts

- **Determinism:** fixed revisions and clock, scanner-only inventory, no process, no temporary file (reviewer scan found none).
- **Isolation:** one behavior per `It`; a fresh context per end-to-end test.
- **Speed:** two suites under 1 s; the end-to-end suite is slow (Minor row).
- **Diagnostics:** `-Because` clauses and the exit-code guard name the failing step, element and finding codes.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Inspection of all deliverables; fixture identifiers are synthetic. |
| No unsafe subprocess or command construction | PASS | No process is started; `ProcessCallLog` is asserted empty. |
| Input validation at boundaries | PASS | The manifest parser fails closed on unsupported constructs. |
| Error handling remains explicit | PASS | Coded `throw` messages; strict mode. |
| Configuration / path handling is safe | PASS | Paths are derived from `$PSScriptRoot`; files are read with `-LiteralPath`; nothing is written. |
| Consumer neutrality | PASS | The neutrality test passed with 0 matches over 7 files. |

---

## Research Log

No external research was required. Merged upstream contracts were read from the base branch: `.claude/lib/docs/python/run_docs_python_native.py`, `.claude/lib/docs/DocsAnalyzerPythonNative.psm1`, and the Phase 0 evidence under `evidence/baseline/`.

---

## Verdict

The code and tests are ready for normal PR flow. Formatting and analysis are clean, the suites pass in the parallel gate, coverage is unchanged, and the onboarding pages agree with the merged dispatch rows and tool definitions. One blocking documentation-governance row remains: the spec must carry a Python-floor erratum consistent with the delivered page and the merged code, so that the checked SAC-12 matches its text. The Minor, Nit and Info rows do not block the merge. Under the owner's standing practice, the three Minor rows are related to this item and can be fixed in the same remediation cycle.
