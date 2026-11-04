# Feature Audit: Documentation page quality checker (#1021)

**Audit Date:** 2026-11-04
**Feature Folder:** `docs/features/active/2026-10-30-docs-page-quality-checker-1021`
**Base Branch:** `origin/epic/documentation-estate-tooling-integration`
**Head Branch:** `feature/docs-page-quality-checker-1021-r2`
**Work Mode:** `full-feature`
**Audit Type:** Initial feature review

---

## Scope and Baseline

- **Base branch:** `origin/epic/documentation-estate-tooling-integration` (commit `fd6ee4e5a`)
- **Head branch/commit:** `feature/docs-page-quality-checker-1021-r2` (commit `95aa64e64`; no PR yet)
- **Merge base:** `fd6ee4e5a0815fa69b03fc56c0ea82d49b2f5ee3` (single merge base, equal to the epic tip)
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-04 00:20 UTC, head `95aa64e64`, base `fd6ee4e5a`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `evidence/**` in the feature folder (44 files)
  - Additional evidence: reviewer re-runs listed in `policy-audit.2026-11-04T00-25.md` Appendix B; `artifacts/pester/powershell-coverage.xml` (written 00:06Z by the P6-T6 full `tests/scripts` run, confirmed to describe HEAD)
- **Feature folder used:** `docs/features/active/2026-10-30-docs-page-quality-checker-1021`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` line 11 reads `- Work Mode: full-feature`.
- **Scope note:** The item diff is 95 paths (`git diff fd6ee4e5a...HEAD`). Evaluation covers the full branch diff.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `spec.md` `## Acceptance Criteria` - primary (20 checkbox items, lines 782-801, S1 to S20 in order)
- `user-story.md` `## Acceptance Criteria` - secondary (10 checkbox items, lines 77-86, U1 to U10 in order)

The criteria are long; the labels below abbreviate them in source order. The full text is in the source files and was evaluated as written. `spec.md` `## Definition of Done` and `## Seeded Test Conditions (from potential)` are not acceptance-criteria sections and are not counted.

### From spec.md

1. S1 Each failure family produces a distinct `DOCS_PAGE_*` code with the page as `artifact_path`.
2. S2 Every catalog code is produced with its artifact path, pointer and severity `error`; no other `DOCS_PAGE_` code is emitted.
3. S3 `check` exit codes 0, 1 (findings, `DOCS_PROFILE_MISSING`), 2 (`DOCS_CLI_ARGUMENTS`, `result` null), 3 (`DOCS_CLI_RUNTIME`).
4. S4 `-Json` byte-identical across runs and reversed listing order; ordered findings; `result` shape.
5. S5 `-Json` documents validate against the envelope schema.
6. S6 Generated-block markers, HTML comments and fenced code produce no link, anchor or step finding.
7. S7 1024-shape fixture page set produces zero findings and exit 0.
8. S8 Page-metadata schema shape and byte-identical runtime copy.
9. S9 Accepted fixtures pass `Test-Json`; `Dev_Ops` and `2026-02-30` produce the named codes.
10. S10 `check` row under its anchor; `Test-DocsCommandTable` clean; anchor-only diff.
11. S11 Import isolation suite passes, with positive control.
12. S12 Templates suite passes; neutrality suite clean.
13. S13 `init` lists and writes the five base-configuration destinations.
14. S14 Manifest suite passes; bundle copies SHA-256 identical; push-down pytest unmodified and passing.
15. S15 Seeded property-style tests pass.
16. S16 Module convention and no-Python-invocation suites pass; no `DocsPage*.psm1` above 500 lines.
17. S17 No Python or TypeScript file added or modified; classification table complete.
18. S18 No test creates a temporary file; in-memory command contexts.
19. S19 Pester line coverage >= 85% per new module, recorded under evidence.
20. S20 (CI-dependent) `poshqc / PowerShell QC` passes on the PR head.

### From user-story.md

21. U1 Distinct `DOCS_PAGE_*` codes naming the failing page.
22. U2 Exit 0 and 1; byte-identical `-Json` across runs and reversed listing.
23. U3 `-Json` validates against the envelope schema.
24. U4 Masked regions produce no finding; 1024-shape fixture produces zero findings.
25. U5 Page-metadata schema fields and audience pattern; runtime copy identical.
26. U6 Import isolation with positive control.
27. U7 No consumer vocabulary or repository name in templates; empty vocabulary; `init -Write` bytes.
28. U8 Manifest listing and byte-identical push-down copies.
29. U9 No Python or TypeScript file added or modified.
30. U10 Coverage >= 85% per new module and (CI-dependent) `poshqc / PowerShell QC` passes on the PR head.

---

## Acceptance Criteria Evaluation

Reviewer command R1 is the Pester run at head `95aa64e64`: `Invoke-Pester` over `tests/scripts/claude-lib/docs`, `ClaudeLibModuleConvention.Tests.ps1` and `enforcement-hooks-no-python-invocation.Tests.ps1` (800 of 800 passed). A suite named in a row passed inside R1.

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | S1 | PASS | `DocsPageCheck.Tests.ps1` (77 tests) | R1 | |
| 2 | S2 | PASS | `DocsPageFrontMatter`, `DocsPageLinks`, `DocsPageDiataxis`, `DocsPageOrphans`, `DocsPageCheck` suites | R1 | |
| 3 | S3 | PASS | `DocsPageCheck.Tests.ps1` through `Invoke-DocsCommandCli` with in-memory contexts | R1 | |
| 4 | S4 | PASS | `DocsPageCheck.Tests.ps1` | R1 | |
| 5 | S5 | PASS | `DocsPageCheck.Tests.ps1` (clean, findings and usage-error documents) | R1 | |
| 6 | S6 | PASS | `DocsPageMarkdown` (31), `DocsPageLinks` (45), `DocsPageDiataxis` (28) | R1 | |
| 7 | S7 | PASS | `DocsPageCheck.Tests.ps1` 1024-shape fixture | R1 | |
| 8 | S8 | PASS | `DocsPageMetadataSchema.Tests.ps1` (15), `DocsSchemaContract.Tests.ps1` (49); reviewer `cmp` of schema and runtime copy: identical | R1; `cmp` | |
| 9 | S9 | PASS | `DocsPageFrontMatter.Tests.ps1`, `DocsPageMetadataSchema.Tests.ps1` | R1 | F1 concerns a value form outside the committed fixtures; it does not contradict this criterion. |
| 10 | S10 | PASS | `Invoke-DocsCommand.Tests.ps1` (47); reviewer diff shows one added line under `# --- 1021: check ---` | R1; `git diff fd6ee4e5a...HEAD -- .claude/lib/docs/Invoke-DocsCommand.ps1` | |
| 11 | S11 | PASS | `DocsPageImportIsolation.Tests.ps1` (12) | R1 | |
| 12 | S12 | PASS | `DocsPageTemplates.Tests.ps1` (9), `DocsNeutrality.Tests.ps1` (49); `accept.txt` is the empty blob `e69de29bb` | R1; `git diff` | |
| 13 | S13 | PASS | `DocsProfileCommands.Tests.ps1` (22), `DocsPageTemplates.Tests.ps1` | R1 | |
| 14 | S14 | PASS | `Docs.Manifest.Tests.ps1` (7); reviewer `sha256sum` of 16 pairs: identical; pytest 34 passed; the three pytest files are not in the diff | R1; `sha256sum`; pytest | |
| 15 | S15 | PASS | Seeded tests in `DocsPageLinks`, `DocsPageOrphans`, `DocsPageFrontMatter`, `DocsPageCheck`, `DocsPageDiataxis` suites; seed printed through `-Because` | R1 | |
| 16 | S16 | PASS | Module convention 6 of 6, no-Python-invocation 33 of 33; largest `DocsPage*.psm1` 428 logical lines | R1; logical line count | |
| 17 | S17 | PASS | No `.py/.ts/.tsx/.js/.mjs/.cjs` path in the diff; `evidence/qa-gates/qa-no-python-typescript.2026-11-04T00-16.md` | `git diff --name-only` filtered by extension | |
| 18 | S18 | PASS | Reviewer token search over the changed suites: no match | `grep -n -E` for the five tokens | |
| 19 | S19 | PASS | Reviewer parse of `artifacts/pester/powershell-coverage.xml`: 100% for each of the seven new modules; none excluded | Python XML parse of sourcefile LINE counters | Figures recorded under `evidence/qa-gates/` and `evidence/regression-testing/` instead of `evidence/coverage/`; the canonical evidence kinds have no `coverage` kind, so this placement is required by the evidence convention. |
| 20 | S20 | UNVERIFIED | No PR and no CI run for head `95aa64e64` | n/a | CI-dependent; pending S9 (`awaiting_ci`, F2). |
| 21 | U1 | PASS | As S1 | R1 | |
| 22 | U2 | PASS | As S3, S4 | R1 | |
| 23 | U3 | PASS | As S5 | R1 | |
| 24 | U4 | PASS | As S6, S7 | R1 | |
| 25 | U5 | PASS | As S8 | R1; `cmp` | |
| 26 | U6 | PASS | As S11 | R1 | |
| 27 | U7 | PASS | As S12, S13 | R1 | |
| 28 | U8 | PASS | As S14 | R1; `sha256sum` | |
| 29 | U9 | PASS | As S17 | diff filter | |
| 30 | U10 | UNVERIFIED | Coverage part verified (as S19); CI part has no run for the PR head | XML parse | CI-dependent; pending S9 (`awaiting_ci`, F2). |

---

## Summary

**Overall Feature Readiness:** NOT READY (one autonomous code-review finding; CI pending)

**Criteria summary:**
- **PASS:** 28 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 2 criteria (S20, U10; CI-dependent)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. F1 (outside the AC set): the front-matter flow-sequence fallback rejects a JSON double-quoted item that ends in an escaped backslash, contrary to the spec value-form table. See `code-review.2026-11-04T00-25.md`.
2. S20 and U10 wait on CI for the PR head (F2, `awaiting_ci`).

**Recommended follow-up verification steps:**

1. Fix F1 with a regression test, re-copy the bundle module, and re-run the docs suites, PSScriptAnalyzer, the formatter and `Invoke-PoshQCTest -ScanFolders tests/scripts/claude-lib`.
2. Open the PR, then at S9 read `poshqc / PowerShell QC` (windows-latest) for the PR head and check off S20 and U10 after a green conclusion.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as PASS are checked off in the source files.
- Criteria evaluated as PARTIAL, FAIL, or UNVERIFIED remain unchecked.

All 28 PASS criteria were already checked (`- [x]`) in the source files (reviewer count at head `95aa64e64`: 19 checked in the `spec.md` Acceptance Criteria section, 9 in `user-story.md`); the reviewer's re-evaluation confirms each, so no source-file change was needed. S20 and U10 remain unchecked as CI-dependent; the item's own orchestrator run checks them off at S9.

### AC Status Summary

- Source: `docs/features/active/2026-10-30-docs-page-quality-checker-1021/spec.md`, `docs/features/active/2026-10-30-docs-page-quality-checker-1021/user-story.md`
- Total AC items: 30
- Checked off (delivered): 28
- Remaining (unchecked): 2
- Items remaining: spec S20 "(CI-dependent) The required check `poshqc / PowerShell QC` (Pester shards on `windows-latest`, with coverage) passes on the pull request head."; user-story U10 "Pester line coverage is at least 85% for each new `DocsPage*.psm1` module, recorded under `<FEATURE>/evidence/coverage/`, and the required check `poshqc / PowerShell QC` (Pester shards on `windows-latest`, with coverage) passes on the pull request head (CI-dependent)."

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 20 | 19 | 1 | Checkbox-backed; S20 CI-dependent |
| `user-story.md` | 10 | 9 | 1 | Checkbox-backed; U10 CI-dependent |
