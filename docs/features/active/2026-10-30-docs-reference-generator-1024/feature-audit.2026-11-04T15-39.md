# Feature Audit: Documentation reference generator (#1024)

**Audit Date:** 2026-11-04
**Feature Folder:** `docs/features/active/2026-10-30-docs-reference-generator-1024`
**Base Branch:** `origin/epic/documentation-estate-tooling-integration`
**Head Branch:** `feature/docs-reference-generator-1024-r2`
**Work Mode:** `full-feature`
**Audit Type:** Re-audit at the exit of remediation cycle 1

---

## Scope and Baseline

- **Base branch:** `origin/epic/documentation-estate-tooling-integration` (tip `a94dea9a4`)
- **Head branch/commit:** `feature/docs-reference-generator-1024-r2` (commit `e273e2adbb3d15ba93e485047c03c7a4f168b4b8`; no PR yet)
- **Merge base:** `a94dea9a4be0743f00ff78de095c51e14d513b20` (equal to the integration tip, merged into the branch by `0eed552e7`, which brought in issue 1022)
- **Evidence sources:**
  - Primary: direct `git diff a94dea9a4..HEAD` (78 paths). `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` are absent in the worktree and no collector tool is exposed to this agent, so the direct diff is the scope source (assumption).
  - Secondary baseline diff: `git diff 0eed552e7..HEAD` for the cycle-1 change, and `git diff a94dea9a4..HEAD -- <path>` for the shared files `Invoke-DocsCommand.ps1`, `core.json` and `DocsWriteBoundary.Tests.ps1`
  - Feature evidence: `evidence/**`, including the cycle-1 files `evidence/remediation-baseline/*.2026-11-04T14-48.md`, `evidence/regression-testing/fail-before.2026-11-04T14-51.md`, `evidence/regression-testing/pester-shuffle.2026-11-04T15-28.md`, `evidence/qa-gates/pester-docs.2026-11-04T15-25.md`, `evidence/qa-gates/coverage-delta.2026-11-04T15-25.md` and `evidence/qa-gates/self-review.2026-11-04T15-29.md`
  - Additional evidence: reviewer re-runs listed in `policy-audit.2026-11-04T15-39.md` Appendix B (R1 = reviewer Pester run, 1705 of 1705; R2 = reviewer PSScriptAnalyzer and formatter, 0 findings over 21 files; R3 = reviewer push-down pytest, 34 of 34; R4 = reviewer size, parity and manifest script; R5 = reviewer per-file parse of `artifacts/pester/powershell-coverage.xml`)
- **Feature folder used:** `docs/features/active/2026-10-30-docs-reference-generator-1024`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` line 11 reads `- Work Mode: full-feature`.
- **Scope note:** Cycle 1 changed `DocsReferenceFrontMatter.psm1`, its bundle copy and `DocsReferenceFrontMatter.Tests.ps1`; every criterion was re-evaluated at HEAD through R1 to R5.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `spec.md` `## Acceptance Criteria` - primary (27 checkbox items, lines 802-828, AC-1 to AC-27 in order)
- `user-story.md` `## Acceptance Criteria` - secondary (17 checkbox items, lines 89-105, US-1 to US-17 in order)

The criteria are long; the labels below abbreviate them in source order. The full text is in the source files and was evaluated as written. `spec.md` `## Definition of Done` and `## Seeded Test Conditions (from potential)` are not acceptance-criteria sections and are not counted.

### From spec.md

1. AC-1 Byte-identical rendering across two runs and a shuffled element order (property and command level).
2. AC-2 Prose preservation, idempotence and edit-record reproduction in `Merge-DocsReferenceBlock`.
3. AC-3 Removed element's block removed and reported with `REFERENCE_BLOCK_REMOVED`.
4. AC-4 Generated pages pass the 1021 `check` subcommand with zero findings, new and with author prose.
5. AC-5 Front matter conforms to page-metadata; no pattern constants; valid existing values preserved.
6. AC-6 `-Json` envelope validation and key sets for five exit cases.
7. AC-7 Dry run writes nothing and prints page lines, hunks and the mode line.
8. AC-8 Write mode through `WriteText` in ordinal order; second run writes nothing.
9. AC-9 Write conflict and write exception behavior.
10. AC-10 Exit codes 0/1/2/3.
11. AC-11 Finding-code catalog triggers; marker errors block only their page.
12. AC-12 Seeded property tests for the six halted-preflight functions.
13. AC-13 Seeded property tests for every other public pure function plus a test-side inventory.
14. AC-14 Generation rules (families, unrendered count, output directory, path matching, roots).
15. AC-15 Marker layout and heading restrictions.
16. AC-16 Determinism and clock-free command tests; `analysis_method` change gives `none`.
17. AC-17 Module-boundary AST test.
18. AC-18 Dispatch row under the 1024 anchor; `Test-DocsCommandTable` clean.
19. AC-19 Push-down copies byte-identical; `core.json` entries; manifest and push-down contract tests.
20. AC-20 No Python or TypeScript file; classification table complete.
21. AC-21 Tests create no temporary files; in-memory contexts.
22. AC-22 Module-convention, no-Python-invocation and neutrality suites pass unmodified.
23. AC-23 New modules at most 500 lines; test files at most 800.
24. AC-24 Pester line coverage at least 85% per new module from the PoshQC report; no exclusions.
25. AC-25 Upstream-symbol confirmation record.
26. AC-26 Test isolation: three seeded shuffled runs and one fresh single-process run.
27. AC-27 (CI-dependent) `poshqc / PowerShell QC`, `poshqc / PowerShell QC static` and `quality-checks7 / Code Quality & Tests` pass on the PR head.

### From user-story.md

28. US-1 Byte-identical rendering (seeded property test and command-level test).
29. US-2 Prose preserved across regeneration.
30. US-3 Removed block reported.
31. US-4 Generated pages pass `check` with zero findings.
32. US-5 Front matter form and validation; preservation.
33. US-6 `-Json` envelope validation for five run kinds.
34. US-7 Dry run writes nothing and prints changes.
35. US-8 Write mode through `WriteText`; second run `none`.
36. US-9 Write conflict and write exception.
37. US-10 Usage, absence, read-failure and error-finding exit codes.
38. US-11 Marker anomaly or unclosed fence blocks only the affected page.
39. US-12 Seeded property test per public pure function.
40. US-13 Fixed family pages; architecture counted; no index page.
41. US-14 Heading restriction and standalone markers.
42. US-15 Byte-identical push-down copies; `core.json`; contract tests unmodified.
43. US-16 No Python or TypeScript; no temporary file.
44. US-17 Pester line coverage at least 85% per new module; no exclusion.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1 | PASS | `DocsReferenceWriter.Properties.Tests.ps1` (25), `DocsReferenceIntegration.Tests.ps1` determinism case | R1 | |
| 2 | AC-2 | PASS | `DocsReferenceMarkers.Properties.Tests.ps1` (35) | R1 | |
| 3 | AC-3 | PASS | `DocsReferenceIntegration.Tests.ps1` removal case; `DocsReferenceMarkers.Tests.ps1` (31) | R1 | |
| 4 | AC-4 | PASS | `DocsReferenceIntegration.Tests.ps1` check cases | R1 | Entry page is the root `README.md` per C7. |
| 5 | AC-5 | PASS | `DocsReferenceIntegration.Tests.ps1`, `DocsReferenceFrontMatter.Tests.ps1` (31, including the seven cycle-1 cases); pattern-constant test in `DocsReferenceBoundary.Tests.ps1` | R1 | Cycle 1 changes only the routing of rejected `extensions` numbers; output for previously valid input is unchanged (earlier 24 cases pass). |
| 6 | AC-6 | PASS | `DocsReferenceIntegration.Tests.ps1` envelope cases | R1 | |
| 7 | AC-7 | PASS | `DocsReferenceWriter.Tests.ps1` (12) | R1 | |
| 8 | AC-8 | PASS | `DocsReferenceWriter.Tests.ps1`; source inspection of the write loop | R1 | |
| 9 | AC-9 | PASS | `DocsReferenceWriter.Tests.ps1`, `DocsReferenceWriter.Errors.Tests.ps1` (31) | R1 | |
| 10 | AC-10 | PASS | `DocsReferenceWriter.Errors.Tests.ps1`, `DocsReferenceWriter.Tests.ps1` | R1 | |
| 11 | AC-11 | PASS | `DocsReferenceMarkers.Tests.ps1`, `DocsReferenceFrontMatter.Tests.ps1`, `DocsReferencePlan.Tests.ps1`, writer suites | R1 | |
| 12 | AC-12 | PASS | Property suites; executor seeded listing in `evidence/qa-gates/ac-verification.2026-11-04T04-37.md` | R1 | |
| 13 | AC-13 | PASS | Property suites; inventory test in `DocsReferenceBoundary.Tests.ps1` | R1 | The new predicate is private, so the public-function inventory is unchanged. |
| 14 | AC-14 | PASS | `DocsReferencePlan.Tests.ps1` (43) | R1 | |
| 15 | AC-15 | PASS | `DocsReferenceRender.Tests.ps1` (53), `DocsReferenceWriter.Properties.Tests.ps1` | R1 | |
| 16 | AC-16 | PASS | `DocsReferenceWriter.Tests.ps1`; in-memory context `UtcNow` throws | R1 | |
| 17 | AC-17 | PASS | `DocsReferenceBoundary.Tests.ps1` (24) with positive controls, over the cycle-1 module | R1 | |
| 18 | AC-18 | PASS | `DocsReferenceWriter.Tests.ps1`; one added line under the 1024 anchor | R1; `git diff a94dea9a4..HEAD -- .claude/lib/docs/Invoke-DocsCommand.ps1` | |
| 19 | AC-19 | PASS | SHA-256 equal for all seven pairs, including the cycle-1 `DocsReferenceFrontMatter.psm1` (R4); six `core.json` lines; `Docs.Manifest.Tests.ps1` 7 of 7 (R1); push-down pytest 34 of 34 (R3) | R1; R3; R4 | The CI jobs named in the criterion are covered by AC-27. |
| 20 | AC-20 | PASS | Zero `.py`/`.ts`/`.tsx`/`.js`/`.mjs`/`.cjs` paths in the diff; plan `## Artifact Classification` lists every changed production and test path | `git diff --name-only a94dea9a4..HEAD` | |
| 21 | AC-21 | PASS | Cycle-1 cases use in-memory values only; earlier token scan of the new test files found no temporary-file token | source inspection | |
| 22 | AC-22 | PASS | `ClaudeLibModuleConvention.Tests.ps1` (6), `enforcement-hooks-no-python-invocation.Tests.ps1` (33) and `DocsNeutrality.Tests.ps1` (83) pass in R1; none is in the diff | R1; `git diff --name-only` | |
| 23 | AC-23 | PASS | Reviewer logical line counts: new modules 184 to 411 (`DocsReferenceFrontMatter.psm1` 288); test files 203 to 646 | R4 | |
| 24 | AC-24 | PASS | Current `artifacts/pester/powershell-coverage.xml`, written by `Invoke-PoshQCTest -ScanFolders tests/scripts/claude-lib/docs` after the last production commit: Plan 100% (156/156), Render 100% (49/49), Markers 100% (169/169), FrontMatter 100% (90/90), Writer 100% (178/178), Report 100% (80/80); `config/poshqc-coverage.json` has no exclusion key; figures recorded in `evidence/qa-gates/pester-docs.2026-11-04T15-25.md` and `coverage-delta.2026-11-04T15-25.md` | R5 | Checked off by this review. The `evidence/coverage/` sub-path named in the criterion is not a canonical evidence kind; `evidence/qa-gates/` is used. |
| 25 | AC-25 | PASS | `evidence/other/upstream-symbols.2026-11-04T01-38.md` | file inspection | Cycle 1 consumes no new upstream symbol. |
| 26 | AC-26 | PASS | `evidence/regression-testing/pester-isolation.2026-11-04T04-31.md` (three seeded shuffled runs 390 of 390 each; fresh single-process run with 409 failures outside the diff); cycle-1 `pester-shuffle.2026-11-04T15-28.md` (125 of 125 per seed) | evidence inspection | Assumption carried from the prior review: the single-process failures are pre-existing Linux-host defects (#1066, #1067) outside the item; `windows-latest` CI is authoritative. |
| 27 | AC-27 | UNVERIFIED | `evidence/qa-gates/ci-pending.2026-11-04T04-33.md`; no PR or CI run exists for head `e273e2adb` | `gh pr list --head feature/docs-reference-generator-1024-r2 --state all` (empty) | CI-dependent; pending-CI (`awaiting_ci`, F2). |
| 28 | US-1 | PASS | As AC-1 | R1 | |
| 29 | US-2 | PASS | As AC-2 | R1 | |
| 30 | US-3 | PASS | As AC-3 | R1 | |
| 31 | US-4 | PASS | As AC-4 | R1 | |
| 32 | US-5 | PASS | As AC-5 | R1 | |
| 33 | US-6 | PASS | As AC-6 | R1 | |
| 34 | US-7 | PASS | As AC-7 | R1 | |
| 35 | US-8 | PASS | As AC-8 | R1 | |
| 36 | US-9 | PASS | As AC-9 | R1 | |
| 37 | US-10 | PASS | As AC-10 | R1 | |
| 38 | US-11 | PASS | As AC-11 | R1 | |
| 39 | US-12 | PASS | As AC-12 and AC-13 | R1 | |
| 40 | US-13 | PASS | As AC-14 | R1 | |
| 41 | US-14 | PASS | As AC-15 | R1 | |
| 42 | US-15 | PASS | As AC-19 | R1; R3; R4 | |
| 43 | US-16 | PASS | As AC-20 and AC-21 | `git diff --name-only`; source inspection | |
| 44 | US-17 | PASS | As AC-24 | R5 | Checked off by this review. |

---

## Summary

**Overall Feature Readiness:** BLOCKED (AWAITING_CI; no autonomous remediation required)

**Criteria summary:**
- **PASS:** 43 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 1 criterion (AC-27)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. F2: CI has not run on the PR head (AC-27).
2. F3 (policy audit): the repo-wide PowerShell line figure is produced only by the CI merged coverage report; it is not an acceptance criterion of this feature but is a policy gate.

**Recommended follow-up verification steps:**

1. Open the PR into `epic/documentation-estate-tooling-integration`; dispatch `ci.yml` manually if no checks start, because it triggers only on PRs into `main` or `development`.
2. At S9, confirm `poshqc / PowerShell QC`, `poshqc / PowerShell QC static` and the `quality-checks7 / Code Quality & Tests` contexts succeed and read the repo-wide PowerShell line figure from the merged report, then check off AC-27 and re-run the CI gate on the new head.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** are checked. This review changed AC-24 (`spec.md` line 825) and US-17 (`user-story.md` line 105) from `- [ ]` to `- [x]`, verified from the current local coverage artifact (R5); the criterion text is unchanged. All other PASS items were already checked.
- Criteria evaluated as **UNVERIFIED** remain unchecked: AC-27 (`spec.md` line 828), left unchecked as found.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-10-30-docs-reference-generator-1024/spec.md`, `docs/features/active/2026-10-30-docs-reference-generator-1024/user-story.md`
- Total AC items: 44
- Checked off (delivered): 43
- Remaining (unchecked): 1
- Items remaining: AC-27 "(CI-dependent) The required check `poshqc / PowerShell QC` ... pass on the pull request head."

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 27 | 26 | 1 | Checkbox-backed; AC-24 checked by this review; AC-27 CI-dependent |
| `user-story.md` | 17 | 17 | 0 | Checkbox-backed; US-17 checked by this review |
