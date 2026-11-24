# Feature Audit: docs-family-gate-and-ia (#1221)

**Audit Date:** 2026-11-24
**Feature Folder:** `.dev/active/1221-docs-family-gate-and-ia`
**Base Branch:** `origin/epic/documentation-estate-families-integration`
**Head Branch:** `feature/docs-family-gate-and-ia-1221`
**Work Mode:** `full-feature`
**Audit Type:** Re-audit at the exit of remediation cycle 1 (S7), epic child of #1217

---

## Scope and Baseline

- **Base branch:** `origin/epic/documentation-estate-families-integration` (resolved `7a84f85cdea1f1aef83613952277af31566bfcd5`; `git merge-base` after `git fetch`)
- **Head branch/commit:** `feature/docs-family-gate-and-ia-1221` (commit `e5e96e58dcb6fca9fe37820fcd95a9e290a6fd89`, pushed)
- **Merge base:** `7a84f85cdea1f1aef83613952277af31566bfcd5`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-24 10:42:02 UTC for head `e5e96e58d`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Prior review at `40b69e354` (verdict PASS): `policy-audit.2026-11-24T07-55.md`, `code-review.2026-11-24T07-55.md`, `feature-audit.2026-11-24T07-55.md`, with `evidence/qa-gates/review-pester-gate.2026-11-24T08-29.md` and `review-jest-root.2026-11-24T07-56.md`
  - Cycle 1: `remediation-inputs.2026-11-24T08-32.md` (R-1), `remediation-plan.2026-11-24T08-32.md`, `evidence/remediation-baseline/*`, `evidence/other/task-check.P1-T*.2026-11-24T09-43..10-05.md`, `evidence/regression-testing/fail-before.2026-11-24T09-47.md`, `evidence/qa-gates/final-static-powershell.2026-11-24T10-06.md`, `final-pester-targeted.2026-11-24T10-19.md`, `final-push-down-contracts.2026-11-24T10-36.md`, `self-review.2026-11-24T10-37.md`, `evidence/other/decisions.2026-11-24T10-37.md`
  - Review evidence: `evidence/qa-gates/review-pester-targeted.2026-11-24T11-01.md` (targeted run of `tests/scripts/claude-lib/docs` at head)
  - Additional evidence: direct inspection of the cycle diff `40b69e354..e5e96e58d`; a real-process probe of the root-file rule with the production context on this Windows host; byte comparison of the bundle copies; generator `-Check`; `git diff --exit-code` of the unedited gate and hook files
- **Feature folder used:** `.dev/active/1221-docs-family-gate-and-ia`
- **Requirements source:** `spec.md` (`## Acceptance Criteria`, 26 items) and `user-story.md` (`## Acceptance Criteria`, 13 items)
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-feature`, so `spec.md` and `user-story.md` are the AC sources.
- **Scope note:** The audit scope is the full diff `7a84f85c..e5e96e58` (87 paths, of which 23 were added after the prior review: the prior review records, the cycle records and evidence, and the cycle's code, test, and spec edits). Changes that #1218 and #1219 brought in through the integration tip are in the merge base and are not attributed to this item.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `.dev/active/1221-docs-family-gate-and-ia/spec.md` — primary
- `.dev/active/1221-docs-family-gate-and-ia/user-story.md` — secondary

### From spec.md

AC-1. Missing required family fails docs-complete with `DOCS_FAMILY_PAGE_MISSING` (error, pointer, related ids and paths); command exits non-zero.
AC-2. Adding a `.md` page removes the finding and yields `pass`.
AC-3. An `exclusion` yields `DOCS_FAMILY_NOT_APPLICABLE` (info) and `pass`.
AC-4. Security root files: one `DOCS_FAMILY_ROOT_FILE_MISSING` per absent root file; `.github/CODEOWNERS` does not satisfy; excluded security family skips.
AC-5. One `DOCS_LEGACY_EXCLUSIONS_REPORTED` per run with every path in ordinal order and each reason; none for an empty list.
AC-6. A page with `surface_refs: []` counts and produces no page finding.
AC-7. Optional family, legacy-excluded page, prefix overlap, non-`.md` files, nested directories, duplicate directories.
AC-8. Runs in docs-complete mode without snapshot or ledger; not in other modes.
AC-9. `-FamilyEvidence $null` fails closed.
AC-10. No-family profile identical to pre-change behavior; no seam call.
AC-11. Failing receipt denied as `RECEIPT_FAILING`; gate module and schemas byte-identical.
AC-12. Coverage `families` key; `Get-DocsCoverageReport` keeps six keys.
AC-13. Entry and legacy item shapes, status values, order.
AC-14. Coverage line formats.
AC-15. `DocsLedgerCommands.Tests.ps1` sorted key list and pass.
AC-16. `New-DocsLedgerTestProfile` defaults and opt-in parameters; suites unchanged.
AC-17. End-to-end docs-complete fixtures listed with disposition; pass assertions kept.
AC-18. Four `docs-plan-ia` copies with step and `## Result` lines.
AC-19. Workflow-text token rows over four roots; no runtime-specific path.
AC-20. Jest pass-through cases.
AC-21. Description Jest case; no new TypeScript file; Jest thresholds.
AC-22. Generator `-Check` and `HarnessGeneration.RepoGate.Tests.ps1`.
AC-23. Bundle identity, `core.json` entry, convention, neutrality, file-size, push-down suites.
AC-24. `DocsFamilyCheck.psm1` at least 85% line coverage; no changed-line regression.
AC-25. Files at or below 800 lines; `DocsLedgerCommands.psm1` growth about three lines at most; no temporary file in tests.
AC-26. Full toolchain loop clean, integration in CI; architecture bullet.

### From user-story.md

U1. Missing family fails with `DOCS_FAMILY_PAGE_MISSING` naming the id.
U2. Page removes the finding; exclusion yields `DOCS_FAMILY_NOT_APPLICABLE`.
U3. Security root files, one finding per file; `.github/CODEOWNERS` does not satisfy.
U4. Legacy finding on every run; empty list produces none.
U5. `surface_refs: []` page accepted and counted.
U6. No-family profile behaves as before.
U7. Failing receipt reaches the merge hook; `DocsCompleteGate.psm1` unchanged.
U8. Coverage `families` section and lines.
U9. Existing docs-complete pass fixtures keep passing.
U10. Four skill copies with the family step and `## Result` lines.
U11. MCP tools return the findings and section unchanged; descriptions name them.
U12. Generator `-Check`, parity and push-down contracts, docs manifest test.
U13. `DocsFamilyCheck.psm1` at least 85%; no changed-line regression; Jest thresholds.

---

## Acceptance Criteria Evaluation

Rows not touched by the cycle keep the evidence of the prior review (full gates at `40b69e354`: Pester 29721 passed, 0 failed; root Jest 6727 passed; pytest 17104 passed). The cycle changed only `DocsFamilyCheck.psm1`, `Invoke-DocsCommand.ps1` (`Get-DocsContextFileList` and help), their bundle copies, four test files, and spec text. The re-evaluation of affected rows uses the cycle's targeted union (`final-pester-targeted.2026-11-24T10-19.md`: 2851 passed, 0 failed), the review's targeted run at head (`review-pester-targeted.2026-11-24T11-01.md`), and the review probe.

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| AC-1 | Missing family fails, exit non-zero | PASS | `DocsValidation.Families.Tests.ps1` and `DocsValidateCommands.Families.Tests.ps1` cases; pass at head in the review's targeted run | read tests; targeted run | Unchanged by the cycle. |
| AC-2 | Page added yields pass | PASS | `passes docs-complete once a page exists under the family directory` | read test; targeted run | |
| AC-3 | Exclusion yields info and pass | PASS | Exclusion cases in `DocsValidation.Families.Tests.ps1` and `DocsFamilyCheck.Tests.ps1` | read tests; targeted run | |
| AC-4 | Security root files | PASS | Existing root-file cases plus the four `Read-DocsFamilyEvidence root-file name case` cases; `.github/CODEOWNERS` and `docs/CODEOWNERS` still do not satisfy | read tests; targeted run; review probe | R-1 resolved: the rule now accepts only the exact names, compared ordinally, on every host. The review probe on Windows: `security.md` and `codeowners` gave `RootFile` `False` although `TestFile('SECURITY.md')` was `True`; exact names gave `True`. |
| AC-5 | One legacy info finding | PASS | Legacy cases in `DocsFamilyCheck.Tests.ps1` | read tests; targeted run | |
| AC-6 | `surface_refs: []` page counts | PASS | `counts a page whose front matter has surface_refs: [] as a family page` | read test; targeted run | |
| AC-7 | Edge cases | PASS | Optional, legacy-excluded, `securityx`, non-`.md`, nested, trailing-slash cases | read tests; targeted run | |
| AC-8 | Runs without snapshot or ledger; not in other modes | PASS | Snapshot-absent, ledger-absent, and other-mode cases | read tests; targeted run | |
| AC-9 | `$null` evidence fails closed | PASS | `fails closed with DOCS_FAMILY_PAGE_MISSING when -FamilyEvidence is $null` | read test; targeted run | |
| AC-10 | No-family parity, no seam call | PASS | `makes no context call for a profile without families and legacy entries`; matrix-mode call-log parity | read tests; targeted run | The root listing is made only for a security family with a positive probe, so the no-family call log is unchanged. |
| AC-11 | Failing receipt denied; gate unchanged | PASS | `writes a failing receipt that the docs-complete gate denies as RECEIPT_FAILING` | `git diff --exit-code 7a84f85cd HEAD` over `DocsCompleteGate.psm1` and `enforce-docs-complete-gate.ps1`: exit 0; no change under `.claude/lib/docs/schemas` | |
| AC-12 | `families` key; six report keys | PASS | `DocsCoverageReport.Families.Tests.ps1` | read tests; targeted run | |
| AC-13 | Entry shape, status values, order | PASS | Shape and order case; sorted-legacy case | read tests; targeted run | A wrong-case root file now appears in `missing_root_files` (new case asserts `@('SECURITY.md', 'CODEOWNERS')`). |
| AC-14 | Coverage line formats | PASS | Line-format cases | read tests; targeted run | |
| AC-15 | Sorted key list | PASS | `DocsLedgerCommands.Tests.ps1` line 325 | targeted run | Includes `placeholders` from #1219 (prior review Info row). |
| AC-16 | Test profile defaults | PASS | `DocsLedger.TestSupport.Tests.ps1`; the cycle added the empty-root `ListFile` case without changing profile defaults | read tests; targeted run | |
| AC-17 | End-to-end fixtures | PASS | `r1-fixture-inventory.2026-11-23T13-25.md` and `r1-fixture-inventory.2026-11-24T03-45.md`; `docs-estate-workflow.EndToEnd.Tests.ps1` passed in the cycle's targeted union | read artifacts | `DocsCompleteIntegration.Tests.ps1` runs in CI only. |
| AC-18 | Four skill copies | PASS | Unchanged in the cycle; generator `-Check` no drift at head | `Invoke-HarnessGeneration.ps1 -Check` | |
| AC-19 | Workflow-text token rows | PASS | Unchanged in the cycle; prior full gate | prior review | |
| AC-20 | Jest pass-through | PASS | Unchanged in the cycle; root Jest 6727 passed at `40b69e354` | prior review | No TypeScript file changed after that run. |
| AC-21 | Description Jest case; thresholds | PASS | Unchanged in the cycle; `jest.config.cjs` and `jest.docs-coverage.json` unchanged | prior review | |
| AC-22 | Generator and repo gate | PASS | `harness-generation: no drift` (review run at head, exit 0); `HarnessGeneration.RepoGate.Tests.ps1` passed in the prior full gate | `Invoke-HarnessGeneration.ps1 -Check` | The cycle touched no generated or generator-input file. |
| AC-23 | Bundle identity, manifest, contracts | PASS | Both cycle files byte-identical to their bundle copies (`cmp` exit 0); push-down contracts 43 passed (`final-push-down-contracts.2026-11-24T10-36.md`); `Docs.Manifest.Tests.ps1`, `DocsNeutrality.Tests.ps1`, `FileSizePolicy.RepoGate.Tests.ps1` in the cycle's targeted union | `cmp`; read artifacts | `ClaudeLibModuleConvention.Tests.ps1` passed in the prior full gate; the cycle changed no import, export, strict-mode, or help-convention line of the module. |
| AC-24 | Coverage | PASS | `DocsFamilyCheck.psm1` 100.00% (100/100); `Invoke-DocsCommand.ps1` 91.08% (194/213), up from 90.91%; every changed executable line covered | read the coverage XML at head; `final-pester-targeted.2026-11-24T10-19.md` | Re-read from the review's targeted run at head (policy audit section 1.2.1). |
| AC-25 | File size, growth, no temp files | PASS | `DocsFamilyCheck.psm1` 297, `Invoke-DocsCommand.ps1` 632, test files 528, 512, 596, 250; largest touched file 762; no temporary-file token in added test lines | `awk 'END{print NR}'`; self-review grep | |
| AC-26 | Full loop; integration in CI; architecture bullet | UNVERIFIED (pending-CI) | Local loop clean at the prior head and for the cycle delta (static 0 findings, targeted Pester 0 failed, contracts 43 passed); architecture bullet at `.dev/engineering/documentation-estate/architecture.md` line 72 | read artifacts | The integration stage runs only in CI on the PR head and no PR exists yet. This is a CI-dependent criterion: it stays unchecked, and the item's orchestrator checks it off at S9 after CI succeeds. It is not a defect and carries no blocking finding. |
| U1 | Missing family fails | PASS | AC-1 | as above | |
| U2 | Page or exclusion | PASS | AC-2, AC-3 | as above | |
| U3 | Security root files | PASS | AC-4 | as above | Exact names on every host after cycle 1. |
| U4 | Legacy reporting | PASS | AC-5 | as above | |
| U5 | `surface_refs: []` | PASS | AC-6 | as above | |
| U6 | No-family parity | PASS | AC-10 | as above | |
| U7 | Failing receipt; gate unchanged | PASS | AC-11 | as above | |
| U8 | Coverage section and lines | PASS | AC-12, AC-14 | as above | |
| U9 | Existing fixtures pass | PASS | AC-16, AC-17; 0 failures in the prior full gates and the targeted runs | as above | Integration-lane fixtures run in CI (AC-26). |
| U10 | Four skill copies | PASS | AC-18 | as above | |
| U11 | MCP tools | PASS | AC-20, AC-21 | as above | |
| U12 | Generator, contracts, manifest test | PASS | AC-22, AC-23 | as above | |
| U13 | Coverage and Jest thresholds | PASS | AC-21, AC-24 | as above | |

### Remediation cycle 1 verification

| Item | Status | Evidence |
|---|---|---|
| R-1: wrong-case root `security.md` or `codeowners` does not satisfy the rule on any host | PASS | Code at `DocsFamilyCheck.psm1` lines 132-140; new cases pass; review real-process probe on Windows. |
| R-1: exact names satisfy it; `.github/CODEOWNERS` and `docs/CODEOWNERS` do not | PASS | `accepts the exact root names ...`; `makes no root listing when both root probes are negative`. |
| R-1: fake seam models a case-insensitive file system and the tests failed before the fix | PASS | `fail-before.2026-11-24T09-47.md`: the four expected failures, with `RootFile` `$true` before the fix. |
| R-1: existing root-file tests named with their disposition | PASS | Remediation plan P1-T1, P1-T3, P1-T4; one call-log assertion updated, no assertion removed. |
| R-1: bundle copies refreshed; spec D7 sentence added | PASS | `cmp` exit 0; spec D7 sentence present; no AC line changed. |
| No regression from the cycle | PASS | Non-empty `ListFile` paths unchanged (`tests existence and lists files sorted`, `rejects a non-relative path` pass); context member set unchanged; targeted runs 0 failed; static 0 findings. |

---

## Summary

**Overall Feature Readiness:** READY (pending CI at the PR head)

38 of 39 acceptance criteria are met with inspected evidence. AC-26 depends on the integration stage, which runs only in CI on the PR head; its local part is met. Finding R-1 of remediation cycle 1 is resolved, and the cycle introduced no regression.

**Criteria summary:**
- **PASS:** 38 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 1 criterion (AC-26, pending-CI)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. AC-26 integration stage: CI has not run because no PR exists yet.

**Recommended follow-up verification steps:**

1. Open the PR to `epic/documentation-estate-families-integration`, confirm CI at the PR head against the `## CI Cross-check` rows of `policy-audit.2026-11-24T10-42.md` (including the CI-only `DocsCompleteIntegration.Tests.ps1` and `DocsReferenceIntegration.Tests.ps1`), and check off AC-26 and the two closing `## Definition of Done` items at S9.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria not evaluated as PASS must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

### Acceptance Criteria Status

- Source: `.dev/active/1221-docs-family-gate-and-ia/spec.md`, `.dev/active/1221-docs-family-gate-and-ia/user-story.md`
- Total AC items: 39
- Checked off (delivered): 38
- Remaining (unchecked): 1
- Items remaining: AC-26 (`The full toolchain loop (format, lint, type check, architecture, unit, contract, integration in CI) passes in one clean pass through the parallel launcher, and the architecture document ... carries one bullet describing the family check.`) — pending-CI; check-off belongs to the item's orchestrator at S9.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `.dev/active/1221-docs-family-gate-and-ia/spec.md` | 26 | 25 | 1 | AC-1 to AC-25 already checked and confirmed PASS at `e5e96e58d`; AC-26 left unchecked (pending-CI). |
| `.dev/active/1221-docs-family-gate-and-ia/user-story.md` | 13 | 13 | 0 | All already checked and confirmed PASS at `e5e96e58d`. |

No source-file checkbox change was made. Every PASS criterion was already checked, and the one non-PASS criterion was already unchecked. The `## Definition of Done` items "All acceptance criteria above checked off" and "Toolchain pass completed" stay unchecked; both depend on AC-26 and are pending-CI. The `## Seeded Test Conditions` checkboxes are not acceptance criteria and were not counted.
