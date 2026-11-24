# Feature Audit: docs-family-gate-and-ia (#1221)

**Audit Date:** 2026-11-24
**Feature Folder:** `.dev/active/1221-docs-family-gate-and-ia`
**Base Branch:** `origin/epic/documentation-estate-families-integration`
**Head Branch:** `feature/docs-family-gate-and-ia-1221`
**Work Mode:** `full-feature`
**Audit Type:** Initial review (S7), epic child of #1217

---

## Scope and Baseline

- **Base branch:** `origin/epic/documentation-estate-families-integration` (resolved `7a84f85cdea1f1aef83613952277af31566bfcd5` at PR-context generation)
- **Head branch/commit:** `feature/docs-family-gate-and-ia-1221` (commit `40b69e354ea8bd667c295659be8ecd8143bf474c`)
- **Merge base:** `7a84f85cdea1f1aef83613952277af31566bfcd5` (the integration tip after #1219, merged into the branch in `684e3feca`)
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-24 07:45:56 UTC for head `40b69e354`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `.dev/active/1221-docs-family-gate-and-ia/evidence/{baseline,qa-gates,other}/`, including `final-pester.2026-11-24T06-53.md`, `final-jest.2026-11-24T06-58.md`, `final-pytest.2026-11-24T07-02.md`, `final-static-powershell.2026-11-24T07-40.md`, `final-static-typescript.2026-11-24T05-17.md`, `scope-invariants.2026-11-24T07-06.md`, `self-review.2026-11-24T07-41.md`, and both `r1-fixture-inventory` files
  - Review evidence: `evidence/qa-gates/review-jest-root.2026-11-24T07-56.md` and `evidence/qa-gates/review-pester-gate.2026-11-24T08-29.md`
  - Additional evidence: direct inspection of the branch diff; byte comparison of the module and skill copies; generator `-Check`; `git diff --exit-code` of the unedited gate, schema, hook, and Jest configuration files; a real-filesystem probe of the family evidence path
- **Feature folder used:** `.dev/active/1221-docs-family-gate-and-ia`
- **Requirements source:** `spec.md` (`## Acceptance Criteria`, 26 items) and `user-story.md` (`## Acceptance Criteria`, 13 items)
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-feature`, so `spec.md` and `user-story.md` are the AC sources. The early-draft checkbox list in `issue.md` is not an AC source in this mode.
- **Scope note:** The audit scope is the full diff `7a84f85c..40b69e35` (64 files). Changes that #1218 and #1219 brought in through the integration tip are in the merge base and are not attributed to this item.

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

Test pass status for Pester-backed rows comes from the executor's final full gate (`final-pester.2026-11-24T06-53.md`: 29721 passed, 0 failed) and the review's full gate re-run at head (`review-pester-gate.2026-11-24T08-29.md`). The production modules are unchanged between the executor gate and head; the head commit changed one test assertion and Markdown records.

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| AC-1 | Missing family fails, exit non-zero | PASS | `DocsValidation.Families.Tests.ps1` missing-family case (code, severity, pointer, `related_ids`, `related_paths`); `DocsValidateCommands.Families.Tests.ps1` exit 1 case | read tests; gate run | Real-filesystem probe also emitted `DOCS_FAMILY_PAGE_MISSING` at `/required_families/<i>/directory`. |
| AC-2 | Page added yields pass | PASS | `passes docs-complete once a page exists under the family directory` | read test | |
| AC-3 | Exclusion yields info and pass | PASS | `passes docs-complete with DOCS_FAMILY_NOT_APPLICABLE for an excluded family`; finding-level pointer test | read tests | |
| AC-4 | Security root files | PASS | Root-file cases in `DocsFamilyCheck.Tests.ps1` and `DocsValidation.Families.Tests.ps1`; excluded-security case | read tests; review probe | The probe confirmed `.github/CODEOWNERS` does not satisfy the rule. Case handling of `SECURITY.md` is platform-dependent (Minor row in the code review); the AC does not specify case. |
| AC-5 | One legacy info finding | PASS | `reports one DOCS_LEGACY_EXCLUSIONS_REPORTED naming every legacy path with its reason and the count`; empty-list case | read tests | |
| AC-6 | `surface_refs: []` page counts | PASS | `counts a page whose front matter has surface_refs: [] as a family page` | read test | |
| AC-7 | Edge cases | PASS | Optional, legacy-excluded, `securityx`, `.png`, `.txt`, `.MD`, nested, and trailing-slash duplicate cases in `DocsFamilyCheck.Tests.ps1` | read tests; review probe | The probe reproduced the nested, prefix, non-`.md`, and legacy cases with the production listing seam. |
| AC-8 | Runs without snapshot or ledger; not in other modes | PASS | `runs the family check in docs-complete mode with the snapshot or the ledger absent`; `-ForEach profile, ledger, matrix` case; command-level `reads no family evidence outside docs-complete mode` | read tests | Code places the call outside the guard (`DocsValidation.psm1` lines 359-361). |
| AC-9 | `$null` evidence fails closed | PASS | `fails closed with DOCS_FAMILY_PAGE_MISSING when -FamilyEvidence is $null` | read test | |
| AC-10 | No-family parity, no seam call | PASS | No-call case; equal-findings case; equal context call log with matrix mode | read tests | |
| AC-11 | Failing receipt denied; gate unchanged | PASS | `writes a failing receipt that the docs-complete gate denies as RECEIPT_FAILING` (calls `Test-DocsCompleteGateReceipt`) | `git diff --exit-code 7a84f85cd HEAD` over `DocsCompleteGate.psm1`, both schemas, and `enforce-docs-complete-gate.ps1`: exit 0 | |
| AC-12 | `families` key; six report keys | PASS | `DocsCoverageReport.Families.Tests.ps1` (`still returns exactly its six keys`); coverage command case | read tests | |
| AC-13 | Entry shape, status values, order | PASS | `returns one entry per family in profile order with the documented shape and status values`; sorted-legacy case | read tests | |
| AC-14 | Coverage line formats | PASS | Line-format cases including the mixed summary case | read tests | |
| AC-15 | Sorted key list | PASS | `DocsLedgerCommands.Tests.ps1` line 325 asserts the seven AC keys plus `placeholders` from the merged sibling #1219; passes in both gates | test diff | The eighth key comes from #1219, which entered through the merge base; spec Risk "coexistence with docs-prose-markdown-lint" anticipated this. |
| AC-16 | Test profile defaults | PASS | `DocsLedger.TestSupport.psm1` diff (empty arrays unless supplied); `DocsLedger.TestSupport.Tests.ps1`; `task-check.P1-T1.2026-11-23T14-21.md` | test diff | No assertion of an existing suite changed. |
| AC-17 | End-to-end fixtures | PASS | `r1-fixture-inventory.2026-11-23T13-25.md` (36 files) and `r1-fixture-inventory.2026-11-24T03-45.md` (48 paths) with disposition per file | read artifacts | `DocsCompleteIntegration.Tests.ps1` runs in CI only; its only profile source is the helper, which now declares no families. |
| AC-18 | Four skill copies | PASS | Step 7 and `## Result` lines in the source; source and codex bundle share one SHA-256, and generated and claude bundle share another | `sha256sum` of the four copies; generator `-Check` | |
| AC-19 | Workflow-text token rows | PASS | `docs-authoring-roles.WorkflowText.Tests.ps1` diff (46 lines added); passes in both gates | test diff | Step text contains no runtime-specific path. |
| AC-20 | Jest pass-through | PASS | Two cases in `docs-handlers.test.ts`; root Jest 6727 passed | review root Jest run | |
| AC-21 | Description Jest case; thresholds | PASS | Case in `mcp-docs-tool-definitions.test.ts`; `jest.config.cjs` and `jest.docs-coverage.json` unchanged; per-file 100% lines, 93.33% and 100% branches | `git diff --exit-code`; lcov | |
| AC-22 | Generator and repo gate | PASS | `harness-generation: no drift` (review run, exit 0); `HarnessGeneration.RepoGate.Tests.ps1` in the full gates | `Invoke-HarnessGeneration.ps1 -Check` | |
| AC-23 | Bundle identity, manifest, contracts | PASS | Five module pairs byte-identical (review `sha256sum`); `core.json` line 435; `final-pytest.2026-11-24T07-02.md` (43 contract cases passed); convention, neutrality, and file-size suites in the gates | `sha256sum` loop | |
| AC-24 | Coverage | PASS | `DocsFamilyCheck.psm1` 100% (95/95); `DocsValidation.psm1` 98.74%, `DocsValidateCommands.psm1` 100%, `DocsCoverageReport.psm1` 100%, `DocsLedgerCommands.psm1` 99.70%, all at or above the Phase 0 baseline | read `final-pester` record and the coverage XML | Figures re-read by the review from the gate XML. |
| AC-25 | File size, growth, no temp files | PASS | Largest touched file 762 lines; `DocsLedgerCommands.psm1` +2 from this item; scope-invariants check 7 | `awk 'END{print NR}'`; grep record | |
| AC-26 | Full loop; integration in CI; architecture bullet | UNVERIFIED (pending-CI) | Local loop clean (format, analyzer, tsc, ESLint, Pester, Jest, pytest); architecture bullet at `.dev/engineering/documentation-estate/architecture.md` line 72 | read artifacts | The integration stage runs only in CI on the PR head and no PR exists yet. This is a CI-dependent criterion: it stays unchecked, and the item's orchestrator checks it off at S9 after CI succeeds. It is not a defect and carries no blocking finding. |
| U1 | Missing family fails | PASS | AC-1 | as above | |
| U2 | Page or exclusion | PASS | AC-2, AC-3 | as above | |
| U3 | Security root files | PASS | AC-4 | as above | |
| U4 | Legacy reporting | PASS | AC-5 | as above | |
| U5 | `surface_refs: []` | PASS | AC-6 | as above | |
| U6 | No-family parity | PASS | AC-10 | as above | |
| U7 | Failing receipt; gate unchanged | PASS | AC-11 | as above | |
| U8 | Coverage section and lines | PASS | AC-12, AC-14 | as above | |
| U9 | Existing fixtures pass | PASS | AC-16, AC-17; 0 failures in both full gates | as above | Integration-lane fixtures run in CI. The CI confirmation is covered by AC-26. |
| U10 | Four skill copies | PASS | AC-18 | as above | |
| U11 | MCP tools | PASS | AC-20, AC-21 | as above | |
| U12 | Generator, contracts, manifest test | PASS | AC-22, AC-23 | as above | |
| U13 | Coverage and Jest thresholds | PASS | AC-21, AC-24 | as above | |

---

## Summary

**Overall Feature Readiness:** READY (pending CI at the PR head)

38 of 39 acceptance criteria are met with inspected evidence. AC-26 depends on the integration stage, which runs only in CI on the PR head; its local part (the clean local loop and the architecture bullet) is met.

**Criteria summary:**
- **PASS:** 38 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 1 criterion (AC-26, pending-CI)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. AC-26 integration stage: CI has not run because no PR exists yet.

**Recommended follow-up verification steps:**

1. Open the PR to `epic/documentation-estate-families-integration`, confirm CI at the PR head against the `## CI Cross-check` rows of `policy-audit.2026-11-24T07-55.md` (including the CI-only `DocsCompleteIntegration.Tests.ps1` and `DocsReferenceIntegration.Tests.ps1`), and check off AC-26 at S9.

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
| `.dev/active/1221-docs-family-gate-and-ia/spec.md` | 26 | 25 | 1 | AC-1 to AC-25 already checked by the executor and confirmed PASS at `40b69e354`; AC-26 left unchecked (pending-CI). |
| `.dev/active/1221-docs-family-gate-and-ia/user-story.md` | 13 | 13 | 0 | All already checked and confirmed PASS at `40b69e354`. |

No source-file checkbox change was made. Every PASS criterion was already checked, and the one non-PASS criterion was already unchecked. Counts were taken from the `## Acceptance Criteria` sections only. The `## Definition of Done` and `## Seeded Test Conditions` checkboxes in `spec.md` are not acceptance criteria and were not counted.
