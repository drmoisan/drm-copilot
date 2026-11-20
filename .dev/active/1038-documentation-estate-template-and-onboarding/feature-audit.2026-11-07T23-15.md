# Feature Audit: documentation-estate template and onboarding (#1038)

---

**Audit Date:** 2026-11-07
**Feature Folder:** `docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038`
**Base Branch:** `origin/epic/documentation-estate-tooling-integration`
**Head Branch:** `feature/documentation-estate-template-and-onboarding-1038-r2`
**Work Mode:** `full-feature`
**Audit Type:** Re-audit after remediation cycle 1

---

## Scope and Baseline

- **Base branch:** `origin/epic/documentation-estate-tooling-integration` (commit `d395d5140f3822eeef453f2055d4ac539656d629`)
- **Head branch/commit:** `feature/documentation-estate-template-and-onboarding-1038-r2` (commit `c3b44cbb2f06d783798946a19e94fca5273c14a6`)
- **Merge base:** `d395d5140f3822eeef453f2055d4ac539656d629`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-07 23:12:52 UTC, head `c3b44cbb2`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038/evidence/**`
  - Additional evidence: `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml` (gate run after the last code commit `3457c9d04`); reviewer re-run of `Invoke-Formatter`, `Invoke-ScriptAnalyzer` and logical line counts; direct inspection of the deliverables
- **Feature folder used:** `docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** the explicit marker `- Work Mode: full-feature` is in `issue.md`. Acceptance criteria come from `spec.md` `## Acceptance Criteria` and `user-story.md` `## Acceptance Criteria`.
- **Scope note:** the scope is the full branch diff against the PR base. Owner decisions of 2026-11-07 apply. Decision 1 waives the seeded-shuffle and single-process clauses of SAC-24, and decision 2 governs the test-baseline comparison. The remediation cycle 1 erratum moved the SAC-12 Python floor from 3.10 to 3.11. The CI clause of SAC-24 is CI-dependent, and the orchestrator checks it off at S9.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038/spec.md` — primary source (25 items)
- `docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038/user-story.md` — secondary source (11 items)

### From spec.md

The criterion texts of SAC-1 to SAC-25 are listed in `feature-audit.2026-11-07T22-11.md` `### From spec.md` and are unchanged except SAC-12, which now reads:

12. (SAC-12) `consumer-onboarding.md` states that the optional python pack, with Python 3.11 or later, enables the native Python analyzer (D3), that without it `inventory` falls back to the scanner and records `analysis_method: scanner`, the `-AnalysisMethod` choices, and that a push-down without a pack selection ships the inert helper; the documentation contract suite asserts the python pack statement is present.

### From user-story.md

The criterion texts of USE-1 to USE-11 are listed in `feature-audit.2026-11-07T22-11.md` `### From user-story.md`, and `user-story.md` is unchanged in cycle 1.

---

## Acceptance Criteria Evaluation

Test results below are read from `artifacts/pester/pester-junit.xml`. The gate run was `Invoke-PoshQCParallelTest`, with 19342 tests and 0 failures. Per suite: `DocumentationEstateEpicTemplate.Tests.ps1` 19/19, `DocumentationEstateOnboarding.Tests.ps1` 13/13, `EndToEndDocumentationEstate.Tests.ps1` 10/10.

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| SAC-1 | Template pair exists; no `epic-status.md` | PASS | Test `ships epic.md and README.md and no epic-status.md` passed | Gate run | Unchanged in cycle 1 |
| SAC-2 | Manifest schema conformance | PASS | Template suite conformance tests passed; 0 schema findings for the committed template | Gate run | OQ-B provisional default |
| SAC-3 | Cycle-free graph; waves equal `## Planned Waves` | PASS | Wave tests passed | Gate run | |
| SAC-4 | Positive controls: cycle, unresolved, duplicate, unsupported | PASS | All four controls passed. Self-edge and the new non-integer `issue_num` control also pass. | Gate run | Strengthened in cycle 1 (R-2) |
| SAC-5 | Template README statements | PASS | Test `states placement, paired fields, ...` passed | Gate run | |
| SAC-6 | Five pages exist | PASS | Test `has the five onboarding pages` passed | `git diff --name-only d395d5140 HEAD` | |
| SAC-7 | Subcommand headings and examples from `Get-DocsCommandTable` | PASS | Membership tests passed | Gate run | |
| SAC-8 | MCP tool headings and examples from tool definitions | PASS | Membership test passed | Gate run | |
| SAC-9 | Exit codes, envelope, MCP boundaries | PASS | Tests `documents exit codes, envelope keys ...` and `states the MCP tool boundaries` passed | Gate run | |
| SAC-10 | Option spellings match merged rows and input tables | PASS | `evidence/other/option-spelling.2026-11-07T21-18.md`; `command-reference.md` not changed in cycle 1 | Inspection of evidence | |
| SAC-11 | PowerShell 7.4 prerequisite and exit 3 | PASS | Test `states the PowerShell 7.4 prerequisite` passed; the intro paragraph now also says 7.4 (R-1) | Gate run | |
| SAC-12 | Python pack with Python 3.11 or later; fallback; `-AnalysisMethod`; inert helper | PASS | `consumer-onboarding.md` `## Optional Python Pack` states Python 3.11 or later, the scanner fallback with `analysis_method: scanner`, the `-AnalysisMethod` choices and the inert helper. The test `states that the optional python pack enables the native Python analyzer` passed. The spec erratum `Python floor (erratum, 2026-11-07)` is present, and `3.10` remains only in it. | `grep -n -F "3.10" spec.md` (1 line, erratum); `grep -n -F "3.11" spec.md` (4 lines) | Previous PARTIAL closed; already checked by the executor with citations (`evidence/qa-gates/ac-verification.2026-11-07T23-10.md`) |
| SAC-13 | Lint optional; `init -Write` files; `check` required gate | PASS | Test `states that linting is optional ...` passed | Gate run | |
| SAC-14 | Workflow roles, skills, gate key | PASS | Test `names the workflow roles, skills and the integration gate key` passed | Gate run | |
| SAC-15 | Positive control naming the missing subcommand | PASS | Test `fails naming the subcommand that an in-memory command reference omits` passed | Gate run | |
| SAC-16 | In-process run through `Invoke-DocsCommandCli`; R1 exits 0 | PASS | `baseline at revision R1 › passes docs-complete at revision R1 ...` passed. Each scenario run uses one stateful in-memory context. | Gate run, inspected | D-3a: one replay per `Context` |
| SAC-17 | R2 exits 1 with both findings and `validation_result` `fail` | PASS | The four `defects at revision R2` tests passed, with assertions unchanged (`evidence/other/e2e-assertion-parity.2026-11-07T22-50.md`) | Gate run | |
| SAC-18 | Fixed R2 exits 0 with `pass` | PASS | `fixes at revision R2 › passes docs-complete at revision R2 ...` passed | Gate run | |
| SAC-19 | `analysis_method` `scanner` on every element and entry; no process call | PASS | Three `fixes at revision R2` tests passed | Gate run | |
| SAC-20 | `DOCS_SNAPSHOT_UNPINNED` without `-Revision` | PASS | `inventory without a revision › fails closed with DOCS_SNAPSHOT_UNPINNED ...` passed | Gate run | |
| SAC-21 | No temporary files, no process start | PASS | The cycle edits add no temporary file, file write or process. The leak scan reports 0 failures, and `ProcessCallLog` is asserted empty. | Inspection; `evidence/qa-gates/leak-scan.2026-11-07T22-51.md` | |
| SAC-22 | Neutrality scan, no match | PASS | The test `finds no consumer-identifier digest ...` passed. The CON-1 scan of the cycle paths found 0 matches. | Gate run; `evidence/qa-gates/con1-scan.2026-11-07T23-08.md` | |
| SAC-23 | No Python or TypeScript; no file under the protected roots | PASS | Reviewer filter of `git diff --name-only d395d5140 HEAD` for `.py`, `.ts`, `.claude/`, `extensions/drm-copilot/src/` and `claude-customizations`: no match | `git diff --name-only` | |
| SAC-24 | CI job, shuffle and single-process runs, changed-line coverage | UNVERIFIED | Coverage clause met: 72 files under `.claude/lib/docs/` with 0.00 delta (`evidence/qa-gates/coverage-delta.2026-11-07T23-07.md`). Shuffle and single-process clauses waived by owner decision 1. CI clause pending: no PR exists. | CI at S9 | Pending-CI; non-blocking under `### CI-Dependent Criteria`; the orchestrator checks it off at S9 |
| SAC-25 | Files below 500 lines; single-pass toolchain | PASS | Reviewer counts: 163, 229, 251, 298 and 303 logical lines. Reviewer re-run: format 0 differences, analyzer 0 findings. Toolchain: `evidence/qa-gates/toolchain-loop.2026-11-07T23-08.md`. | `@(Get-Content -LiteralPath <file>).Count`; `Invoke-Formatter`; `Invoke-ScriptAnalyzer` | |
| USE-1 | Template accepted by `/epic-plan`, Pester conformance | PASS | As SAC-2 | Gate run | |
| USE-2 | Cycle-free graph, waves, mutations | PASS | As SAC-3 and SAC-4 | Gate run | |
| USE-3 | Template README instructions | PASS | As SAC-5 | Gate run | |
| USE-4 | Every subcommand and tool documented; names derived from merged sources | PASS | As SAC-7 and SAC-8 | Gate run | |
| USE-5 | PowerShell 7.4 prerequisite | PASS | As SAC-11 | Gate run | |
| USE-6 | Python pack enables native analyzer; scanner fallback | PASS | As SAC-12 | Gate run | |
| USE-7 | Lint optional; `check` required gate | PASS | As SAC-13 | Gate run | |
| USE-8 | End-to-end fail and pass | PASS | As SAC-16 to SAC-18 | Gate run | |
| USE-9 | `analysis_method` `scanner` recorded | PASS | As SAC-19 | Gate run | |
| USE-10 | No temporary files or process | PASS | As SAC-21 | Inspection | |
| USE-11 | No consumer identifier; no Python or TypeScript file | PASS | As SAC-22 and SAC-23 | Gate run; `git diff` | |

---

## Summary

**Overall Feature Readiness:** READY

**Criteria summary:**
- **PASS:** 35 criteria (24 in `spec.md`, 11 in `user-story.md`)
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 1 criterion (SAC-24, pending-CI; non-blocking)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. SAC-24: the CI clause awaits `poshqc / PowerShell QC` on the final head (S9, non-blocking for this review).

**Recommended follow-up verification steps:**

1. At S9, confirm that `ci_gate.conclusion` is `success` for the final head and check off SAC-24.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

Source-file changes made by this review: none. Every PASS criterion is already checked. The executor re-checked SAC-12 in commit `f2b82284c` after the erratum commit `b664e5c55`, and this review confirms it. SAC-24 stays unchecked as pending-CI.

### AC Status Summary

- Source: `docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038/spec.md`, `docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038/user-story.md`
- Total AC items: 36
- Checked off (delivered): 35
- Remaining (unchecked): 1
- Items remaining: SAC-24 (the new suites ... pass in the CI job `poshqc / PowerShell QC` ...), pending CI at S9.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 25 | 24 | 1 | Checkbox-backed; SAC-24 pending-CI |
| `user-story.md` | 11 | 11 | 0 | Checkbox-backed |
