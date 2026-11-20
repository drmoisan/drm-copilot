# Feature Audit: Docs surface analyzers for TypeScript and .NET (#1033)

**Audit Date:** 2026-11-04
**Feature Folder:** `docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033`
**Base Branch:** `origin/epic/documentation-estate-tooling-integration`
**Head Branch:** `feature/docs-surface-analyzers-typescript-dotnet-1033-r2`
**Work Mode:** `full-feature`
**Audit Type:** Re-audit after remediation cycle 1 (prior review `2026-11-04T14-15`)

---

## Scope and Baseline

- **Base branch:** `origin/epic/documentation-estate-tooling-integration` (commit `a94dea9a4`)
- **Head branch/commit:** `feature/docs-surface-analyzers-typescript-dotnet-1033-r2` (commit `f06a626b45da76827da0607e0773f04cb4e8a0b6`; clean worktree; no PR yet)
- **Merge base:** `a94dea9a4be0743f00ff78de095c51e14d513b20` (equal to the integration tip because `4bbba7c70` merged that tip)
- **Evidence sources:**
  - Primary: `git diff a94dea9a4...HEAD` (129 paths). `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` exist but were generated at 14:01 UTC for head `4bbba7c70`, before the cycle; the reviewer used the direct diff for the 25 paths added since (assumption recorded in the policy audit).
  - Feature evidence: `evidence/**`, notably `evidence/remediation-baseline/pester-coverage.2026-11-04T14-36.md`, `evidence/regression-testing/f1-membership.2026-11-04T14-56.md`, `evidence/regression-testing/isolation-shuffled.2026-11-04T15-28.md`, `evidence/qa-gates/qa-pester-coverage.2026-11-04T15-07.md`, `evidence/qa-gates/self-review.2026-11-04T15-32.md`
  - Additional evidence: reviewer re-runs listed in `policy-audit.2026-11-04T15-41.md` Appendix B
- **Feature folder used:** `docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` line 12 reads `- Work Mode: full-feature`.
- **Scope note:** The sibling #1020 to #1023 changes brought in by the merge commit are outside the item diff, but the tests at HEAD run against the merged registry; the merged state was evaluated.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `spec.md` `## Acceptance Criteria` - primary (22 checkbox items, lines 749-770, S1 to S22 in order; the cycle's spec edit moved them down 16 lines)
- `user-story.md` `## Acceptance Criteria` - secondary (12 checkbox items, lines 111-122, U1 to U12 in order)

The criteria are long; the labels below abbreviate them in source order. The full text was evaluated as written. `spec.md` `## Definition of Done` and `## Seeded Test Conditions (from potential)` are not acceptance-criteria sections and are not counted. Diagnostic code literals in the criteria are hyphenated specification names; the spec's new normative `### Diagnostic code spelling (C7)` subsection states that each is emitted uppercased with `-` replaced by `_`, and the reviewer evaluated each criterion under that rule.

### From spec.md

1. S1 Tokenizer suites assert token kinds, `Value`, `Dynamic`, `Line`, `Depth` per lexical state; lexical error and overflow yield one blocking diagnostic.
2. S2 `DocsAnalyzerTypeScriptCli.Tests.ps1`: Commander and yargs elements, declarations, `parent_id`, properties, `line_range`.
3. S3 `DocsAnalyzerTypeScriptHttp.Tests.ps1`: Express and Fastify routes, arrays, `route()` chains, `ANY`, cross-file mount, `mounted: false`, `route({...})`, `register` prefixes.
4. S4 `DocsAnalyzerTypeScriptExports.Tests.ps1`: each export form, `export *` expansion, cycle diagnostic, overload merge.
5. S5 `DocsAnalyzerDotnetHttp.Tests.ps1`: attribute routing and minimal APIs.
6. S6 `DocsAnalyzerDotnetConfig.Tests.ps1`: JSONC keys, quoting and `[]`, properties, values absent from output.
7. S7 `DocsAnalyzerDotnetApi.Tests.ps1`: public types and members, partial type across two paths, exclusions.
8. S8 `DocsAnalyzerExtensionImport.Tests.ps1`: valid manifest merged as inert data; `extension-finding-skipped` without the marker.
9. S9 `DocsAnalyzerExtensionImport.Tests.ps1`: one rejection code per validation step; unverified repository and revision diagnostics.
10. S10 `DocsScannerContract.Tests.ps1`: byte-identical output over identical and seeded shuffled inputs.
11. S11 `DocsScannerContract.Tests.ps1`: `input-over-bound`, `input-undecodable`, lexical error isolation.
12. S12 `DocsScannerContract.Tests.ps1`: every precision-limit row emitted with the marker; non-precision codes carry none.
13. S13 `DocsScannerContract.Tests.ps1`: `analysis_method` `scanner`, declaration-lines digest properties, `ConvertFrom-DocsSurfaceElement`, `Invoke-DocsAnalyzer` seam.
14. S14 `DocsAnalyzerRegistry.TypeScriptDotnet.Tests.ps1` membership-only assertions.
15. S15 1020's `DocsAnalyzerRegistry.Tests.ps1` unmodified and passing.
16. S16 `## Scanner Precision Limit` table and `DocsScannerCommon.Tests.ps1` precision-limit assertions.
17. S17 Byte-identical push-down copies listed once in `core.json`; manifest and push-down tests pass.
18. S18 Convention, no-Python-invocation and neutrality suites pass; no new production file above 500 logical lines.
19. S19 No Python or TypeScript file added or modified; artifact classification table in the plan.
20. S20 No temporary-file token in added or edited test files.
21. S21 Pester line coverage at least 85% for each new production module, no exclusion, recorded as evidence.
22. S22 (CI-dependent) `poshqc / PowerShell QC` and `quality-checks7 / Code Quality & Tests` pass on the PR head.

### From user-story.md

23. U1 Six built-in analyzers emit the expected elements for the `## Recognition Rules` fixtures.
24. U2 Digest-mismatched manifest rejected; one code per step; matching manifest merged as inert data.
25. U3 Byte-identical output in any input order.
26. U4 Oversize, undecodable and unclassifiable inputs yield diagnostics; lexical error isolation.
27. U5 `analysis_method: scanner` and declaration-lines digest properties.
28. U6 No configuration value in output; `config-key` digest over the raw key line.
29. U7 Distinct identifiers registered under the 1033 anchor only; membership-only registry suites.
30. U8 Precision limit documented, returned by `Get-DocsScannerPrecisionLimit`, emitted with the marker.
31. U9 Byte-identical push-down copies listed in `core.json`.
32. U10 No new Python or TypeScript file; artifact classification table.
33. U11 Line coverage at least 85% per new module; no temporary file, process, timer or PATH lookup in tests.
34. U12 (CI-dependent) `poshqc / PowerShell QC` passes on the PR head.

---

## Acceptance Criteria Evaluation

Reviewer command R1 is the Pester run at head `f06a626b4`: `Invoke-Pester` over `tests/scripts/claude-lib/docs`, coverage off (result in `policy-audit.2026-11-04T15-41.md` section 6: 1671 of 1671, 86 suites, 0 failures). R2 is the reviewer PSScriptAnalyzer and formatter pass over the 40 changed `.ps1`/`.psm1` source files (0 findings, 0 differences) with logical line counts. R3 is the push-down contract pytest (96 of 96). R4 is the reviewer parse of `artifacts/pester/powershell-coverage.xml` (written by the cycle's final docs-folder run after the last production commit). R5 is the gate run of `ClaudeLibModuleConvention.Tests.ps1` and `enforcement-hooks-no-python-invocation.Tests.ps1` (39 of 39). R6 is the reviewer comparison of the 21 `## Scanner Precision Limit` rows with `Get-DocsScannerPrecisionLimit`. A suite named in a row passed inside R1 unless stated otherwise. Phase evidence named `pN-*` is under `evidence/regression-testing/`.

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | S1 | PASS | `DocsTypeScriptTokens.Tests.ps1`, `DocsCSharpTokens.Tests.ps1`; `p2-ts-tokens`, `p2-ts-jsx`, `p2-cs-tokens` | R1 | Codes `TS_LEXICAL_INVALID`, `CSHARP_LEXICAL_INVALID`, `TOKEN_LIMIT` (C7 mapping, now normative in the spec). |
| 2 | S2 | PASS | `DocsAnalyzerTypeScriptCli.Tests.ps1`, `DocsTypeScriptCliSupport.Tests.ps1`; `p3-ts-cli` | R1 | |
| 3 | S3 | PASS | `DocsAnalyzerTypeScriptHttp.Tests.ps1`, `DocsTypeScriptHttpSupport.Tests.ps1`, `DocsTypeScriptHttpDeclaration.Tests.ps1`; `p3-ts-http` | R1 | |
| 4 | S4 | PASS | `DocsAnalyzerTypeScriptExports.Tests.ps1`; `p3-ts-exports` | R1 | |
| 5 | S5 | PASS | `DocsAnalyzerDotnetHttp.Tests.ps1` (11 tests, including the new exact-case test); `p4-dotnet-http`; `dotnet-case-fail-before.2026-11-04T15-00.md` | R1 | Lookups now ordinal. |
| 6 | S6 | PASS | `DocsAnalyzerDotnetConfig.Tests.ps1` value-absence assertion; `p4-dotnet-config` | R1 | |
| 7 | S7 | PASS | `DocsAnalyzerDotnetApi.Tests.ps1`, `DocsCSharpMember.Tests.ps1`, `DocsCSharpSyntax.Tests.ps1`; `p4-dotnet-api` | R1 | |
| 8 | S8 | PASS | `DocsAnalyzerExtensionImport.Tests.ps1`; `p5-ext-merge` | R1 | |
| 9 | S9 | PASS | `DocsAnalyzerExtensionImport.Tests.ps1`, `DocsExtensionShape.Tests.ps1` (including `Get-DocsExtensionManifestIdentity`); `p5-ext-validation` | R1 | |
| 10 | S10 | PASS | `DocsScannerContract.Tests.ps1` determinism test; `p6-contract-determinism` | R1 | |
| 11 | S11 | PASS | `DocsScannerContract.Tests.ps1` bounds tests; `p6-contract-elements` | R1 | |
| 12 | S12 | PASS | `DocsScannerContract.Tests.ps1` precision-limit tests | R1 | |
| 13 | S13 | PASS | `DocsScannerContract.Tests.ps1` element and seam tests; `p6-contract-elements` | R1 | |
| 14 | S14 | PASS | `DocsAnalyzerRegistry.TypeScriptDotnet.Tests.ps1` (membership only, no row count); `p6-registry-suite` | R1; source inspection | |
| 15 | S15 | PASS | `git diff a94dea9a4...HEAD -- tests/scripts/claude-lib/docs/DocsAnalyzerRegistry.Tests.ps1` is empty; the suite passes in R1 | R1; git diff | |
| 16 | S16 | PASS | `spec.md` `## Scanner Precision Limit` (21 rows); `DocsScannerCommon.Tests.ps1`; `p1-scanner-common` | R1; R6 | R6: same `(analyzer_id, code)` pairs and element kinds; codes equal under the C7 mapping. |
| 17 | S17 | PASS | Equal git blob ids for all 18 source/bundle pairs at HEAD; 17 added `core.json` entries, no duplicate; `Docs.Manifest.Tests.ps1` in R1; R3 | R1; R3; `git rev-parse HEAD:<path>` | Cycle re-mirror recorded in `evidence/other/bundle-mirror.2026-11-04T15-02.md`. |
| 18 | S18 | PASS | R5; `DocsNeutrality.Tests.ps1` in R1; largest new production module 498 logical lines (`DocsScannerCommon.psm1`) | R1; R2; R5 | |
| 19 | S19 | PASS | `git diff --name-only a94dea9a4...HEAD` lists no `.py`, `.ts`, `.tsx`, `.js`, `.mjs` or `.cjs` path; plan `## Artifact Classification` present | git diff; plan inspection | |
| 20 | S20 | PASS | Reviewer token scan over the added and edited test files, including the cycle's added lines: no match | grep | |
| 21 | S21 | PASS | R4: every new module 92.43% (`DocsCSharpTokens.psm1`) to 100%; the three cycle-edited modules 99.43%, 100%, 100%; `config/poshqc-coverage.json` not in the diff; `evidence/qa-gates/qa-pester-coverage.2026-11-04T15-07.md` | R4 | Canonical-location override to `evidence/qa-gates/` recorded in the plan. |
| 22 | S22 | UNVERIFIED | No PR and no CI run exist for head `f06a626b4` | none possible before the PR | CI-dependent; pending-CI at S9 (`awaiting_ci`, F3). |
| 23 | U1 | PASS | As S2 to S7 | R1 | |
| 24 | U2 | PASS | As S8, S9 | R1 | |
| 25 | U3 | PASS | As S10 | R1 | |
| 26 | U4 | PASS | As S11, S12 | R1 | |
| 27 | U5 | PASS | As S13 | R1 | |
| 28 | U6 | PASS | As S6, S8; `config-key` digest assertion | R1 | |
| 29 | U7 | PASS | As S14, S15; the sibling 1022 suites now assert membership as well (prior F1 resolved) | R1 | |
| 30 | U8 | PASS | As S12, S16 | R1; R6 | |
| 31 | U9 | PASS | As S17 | R1; R3 | |
| 32 | U10 | PASS | As S19 | git diff | |
| 33 | U11 | PASS | As S20, S21; no process, timer or PATH token in the added test lines | R4; grep | |
| 34 | U12 | UNVERIFIED | As S22 | none possible before the PR | CI-dependent; pending-CI at S9 (`awaiting_ci`, F3). |

---

## Summary

**Overall Feature Readiness:** READY FOR PR, PENDING CI (no autonomous finding; S22 and U12 wait on CI)

**Criteria summary:**
- **PASS:** 32 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 2 criteria (S22, U12; CI-dependent, pending-CI)
- **FAIL:** 0 criteria

**Prior findings:**

1. F1 resolved: the docs folder passes at HEAD with the sibling 1022 assertions changed to membership.
2. F2 resolved: the spec states the emitted uppercase underscore spelling normatively.
3. F3 open: S22 and U12 require CI on the PR head.

**Recommended follow-up verification steps:**

1. Open the PR into `epic/documentation-estate-tooling-integration`; because `ci.yml` triggers only on PRs into `main` or `development`, dispatch it for the PR head if no checks appear.
2. At S9, confirm `poshqc / PowerShell QC` and the three existing `quality-checks7` entries (3.11, 3.12, 3.13) conclude `success`, record the absent 3.10 entry, check off S22 and U12 and `[P7-T11]`, and re-run the CI gate on the new head.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as PASS are checked off in the source files.
- Criteria evaluated as PARTIAL, FAIL, or UNVERIFIED remain unchecked.

All 32 PASS criteria were already checked (`- [x]`) in the source files (reviewer count at head `f06a626b4`: 21 checked in the `spec.md` Acceptance Criteria section, 11 in `user-story.md`); the re-evaluation confirms each, so no source-file change was needed and no item was newly checked off. S22 and U12 remain unchecked as CI-dependent; the item's own orchestrator run checks them off at S9.

### AC Status Summary

- Source: `docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/spec.md`, `docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/user-story.md`
- Total AC items: 34
- Checked off (delivered): 32
- Remaining (unchecked): 2
- Items remaining: spec S22 "(CI-dependent) The required check `poshqc / PowerShell QC` (Windows shards, coverage) and the `quality-checks7 / Code Quality & Tests` jobs pass on the pull request head."; user-story U12 "(CI-dependent) The required check `poshqc / PowerShell QC` (Windows shards, coverage) passes on the pull request head."

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 22 | 21 | 1 | Checkbox-backed; S22 CI-dependent |
| `user-story.md` | 12 | 11 | 1 | Checkbox-backed; U12 CI-dependent |
