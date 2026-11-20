# Feature Audit: Docs surface analyzers for TypeScript and .NET (#1033)

**Audit Date:** 2026-11-04
**Feature Folder:** `docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033`
**Base Branch:** `origin/epic/documentation-estate-tooling-integration`
**Head Branch:** `feature/docs-surface-analyzers-typescript-dotnet-1033-r2`
**Work Mode:** `full-feature`
**Audit Type:** Initial full-branch review

---

## Scope and Baseline

- **Base branch:** `origin/epic/documentation-estate-tooling-integration` (commit `a94dea9a4`)
- **Head branch/commit:** `feature/docs-surface-analyzers-typescript-dotnet-1033-r2` (commit `4bbba7c70a62e8815c10b2efc1a1ebe7d0313692`; no PR yet)
- **Merge base:** `a94dea9a4be0743f00ff78de095c51e14d513b20` (single merge base from `git merge-base --all`, equal to the integration tip because `4bbba7c70` merges that tip)
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-04 14:01:46 UTC at head `4bbba7c70`, range `a94dea9a4..4bbba7c70`)
  - Secondary: `artifacts/pr_context.appendix.txt`, and `git diff a94dea9a4...HEAD` (104 paths)
  - Feature evidence: `evidence/**` in the feature folder, including `evidence/qa-gates/self-review.2026-11-04T03-25.md` and the untracked `evidence/regression-testing/post-integration-merge.2026-11-04T14-05.md`
  - Additional evidence: reviewer re-runs listed in `policy-audit.2026-11-04T14-15.md` Appendix B
- **Feature folder used:** `docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` line 12 reads `- Work Mode: full-feature`.
- **Scope note:** The sibling #1020, #1021, #1022 and #1023 changes brought in by the merge commit are outside the item diff, but the tests at HEAD run against the merged registry; the merged state was evaluated (finding F1).

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `spec.md` `## Acceptance Criteria` - primary (22 checkbox items, lines 733-754, S1 to S22 in order)
- `user-story.md` `## Acceptance Criteria` - secondary (12 checkbox items, lines 111-122, U1 to U12 in order)

The criteria are long; the labels below abbreviate them in source order. The full text was evaluated as written. `spec.md` `## Definition of Done` and `## Seeded Test Conditions (from potential)` are not acceptance-criteria sections and are not counted. Diagnostic code literals in the criteria are lowercase hyphenated; the shipped code emits their uppercase underscore mapping (plan decision C7, `evidence/other/contract-reconciliation.2026-11-03T21-46.md`). The reviewer evaluated each criterion against the mapped spelling, which the spec's `## Contract Dependencies on 1020 and 1022` permits ("A divergent upstream decision is adopted and recorded in the plan"); the stale specification text is finding F2.

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

Reviewer command R1 is the Pester run at head `4bbba7c70`: `Invoke-Pester` over `tests/scripts/claude-lib/docs`, coverage off (result in `policy-audit.2026-11-04T14-15.md` section 6; the only failures are the two sibling 1022 assertions of F1, outside every 1033 suite). R2 is the reviewer PSScriptAnalyzer and formatter pass over the 38 changed `.ps1`/`.psm1` source files (0 findings, 0 differences) with logical line counts. R3 is the push-down contract pytest (34 of 34). R4 is the reviewer parse of `artifacts/pester/powershell-coverage.xml`. R5 is the gate run of `ClaudeLibModuleConvention.Tests.ps1` and `enforcement-hooks-no-python-invocation.Tests.ps1`. A suite named in a row passed inside R1 unless stated otherwise. Phase evidence named `pN-*` is under `evidence/regression-testing/`.

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | S1 | PASS | `DocsTypeScriptTokens.Tests.ps1`, `DocsCSharpTokens.Tests.ps1`; `p2-ts-tokens`, `p2-ts-jsx`, `p2-cs-tokens` | R1 | Codes `TS_LEXICAL_INVALID`, `CSHARP_LEXICAL_INVALID`, `TOKEN_LIMIT` (C7). |
| 2 | S2 | PASS | `DocsAnalyzerTypeScriptCli.Tests.ps1`, `DocsTypeScriptCliSupport.Tests.ps1`; `p3-ts-cli` | R1 | |
| 3 | S3 | PASS | `DocsAnalyzerTypeScriptHttp.Tests.ps1`, `DocsTypeScriptHttpSupport.Tests.ps1`, `DocsTypeScriptHttpDeclaration.Tests.ps1`; `p3-ts-http` | R1 | |
| 4 | S4 | PASS | `DocsAnalyzerTypeScriptExports.Tests.ps1`; `p3-ts-exports` | R1 | |
| 5 | S5 | PASS | `DocsAnalyzerDotnetHttp.Tests.ps1`; `p4-dotnet-http` | R1 | Case-insensitive verb lookup noted as Info in the code review. |
| 6 | S6 | PASS | `DocsAnalyzerDotnetConfig.Tests.ps1` value-absence assertion over canonical JSON; `p4-dotnet-config` | R1 | |
| 7 | S7 | PASS | `DocsAnalyzerDotnetApi.Tests.ps1`, `DocsCSharpMember.Tests.ps1`, `DocsCSharpSyntax.Tests.ps1`; `p4-dotnet-api` | R1 | |
| 8 | S8 | PASS | `DocsAnalyzerExtensionImport.Tests.ps1`; `p5-ext-merge` | R1 | |
| 9 | S9 | PASS | `DocsAnalyzerExtensionImport.Tests.ps1`, `DocsExtensionShape.Tests.ps1`; `p5-ext-validation` | R1 | |
| 10 | S10 | PASS | `DocsScannerContract.Tests.ps1` determinism test (seeds 1033, 20261030, 7, seed in the failure text); `p6-contract-determinism` | R1 | |
| 11 | S11 | PASS | `DocsScannerContract.Tests.ps1` bounds tests; `p6-contract-elements` | R1 | |
| 12 | S12 | PASS | `DocsScannerContract.Tests.ps1` precision-limit tests | R1 | |
| 13 | S13 | PASS | `DocsScannerContract.Tests.ps1` element and seam tests; `p6-contract-elements` | R1 | |
| 14 | S14 | PASS | `DocsAnalyzerRegistry.TypeScriptDotnet.Tests.ps1` (anchor, no `900NNN` anchor, one row per `Id` and `AnalysisMethod`, registration check returns no finding; no row count); `p6-registry-suite` | R1; source inspection | |
| 15 | S15 | PASS | `git diff a94dea9a4...HEAD -- tests/scripts/claude-lib/docs/DocsAnalyzerRegistry.Tests.ps1` is empty; the suite passes in R1 | R1; git diff | |
| 16 | S16 | PASS | `spec.md` `## Scanner Precision Limit`; `DocsScannerCommon.Tests.ps1`; `p1-scanner-common` | R1 | Code column uses C7 spellings. |
| 17 | S17 | PASS | Equal git blob ids for all 18 source/bundle pairs; 17 added `core.json` entries, no duplicate path; `Docs.Manifest.Tests.ps1` in R1; R3 | R1; R3; `git rev-parse HEAD:<path>` | |
| 18 | S18 | PASS | R5; `DocsNeutrality.Tests.ps1` in R1; largest new production module 498 logical lines (`DocsScannerCommon.psm1`) | R1; R2; R5 | |
| 19 | S19 | PASS | `git diff --name-only a94dea9a4...HEAD` lists no `.py`, `.ts`, `.tsx`, `.js`, `.mjs` or `.cjs` path; plan `## Artifact Classification` present | git diff; plan inspection | |
| 20 | S20 | PASS | Reviewer token scan over the added and edited files under `tests/scripts/claude-lib/docs/`: no match; `evidence/qa-gates/qa-hygiene-and-size.2026-11-04T03-23.md` | grep | |
| 21 | S21 | PASS | R4: every new module 92.43% (`DocsCSharpTokens.psm1`) to 100%; `config/poshqc-coverage.json` not in the diff; recorded in `evidence/qa-gates/qa-pester-coverage.2026-11-04T03-01.md` and `coverage-delta.2026-11-04T03-22.md` | R4 | The criterion names `evidence/coverage/`; the plan's `## Execution Context` records the canonical-location override to `evidence/qa-gates/`. |
| 22 | S22 | UNVERIFIED | No PR and no CI run exist for head `4bbba7c70`; F1 will fail `poshqc / PowerShell QC` until fixed | none possible before the PR | CI-dependent; pending-CI at S9 (`awaiting_ci`, F3). |
| 23 | U1 | PASS | As S2 to S7 | R1 | |
| 24 | U2 | PASS | As S8, S9 | R1 | |
| 25 | U3 | PASS | As S10 | R1 | |
| 26 | U4 | PASS | As S11, S12 | R1 | |
| 27 | U5 | PASS | As S13 | R1 | |
| 28 | U6 | PASS | As S6, S8; `config-key` digest assertion in `DocsAnalyzerDotnetConfig.Tests.ps1` | R1 | |
| 29 | U7 | PASS | As S14, S15 | R1 | The 1033 suites meet the membership-only rule; the sibling 1022 suites do not (F1), which is outside this criterion's named suites. |
| 30 | U8 | PASS | As S12, S16 | R1 | |
| 31 | U9 | PASS | As S17 | R1; R3 | |
| 32 | U10 | PASS | As S19 | git diff | |
| 33 | U11 | PASS | As S20, S21; no process, timer or PATH token in the added test files | R4; grep | |
| 34 | U12 | UNVERIFIED | As S22 | none possible before the PR | CI-dependent; pending-CI at S9 (`awaiting_ci`, F3). |

---

## Summary

**Overall Feature Readiness:** NOT READY (two autonomous findings, F1 and F2; S22 and U12 wait on CI)

**Criteria summary:**
- **PASS:** 32 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 2 criteria (S22, U12; CI-dependent, pending-CI)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. F1: two sibling 1022 assertions pin the full registry list and fail at HEAD after the integration merge; the required check would fail on the PR head.
2. F2: `spec.md` still publishes lowercase hyphenated diagnostic codes as the contract later children must honor, while the code emits the C7 uppercase spellings.
3. F3: S22 and U12 require CI on the PR head.

**Recommended follow-up verification steps:**

1. Fix F1 and F2 in a remediation cycle, commit `evidence/regression-testing/post-integration-merge.2026-11-04T14-05.md` and a new docs-folder run record, and re-run the toolchain loop.
2. Open the PR into `epic/documentation-estate-tooling-integration`; because `ci.yml` triggers only on PRs into `main` or `development`, dispatch it for the PR head if no checks appear.
3. At S9, confirm `poshqc / PowerShell QC` and the three existing `quality-checks7` entries (3.11, 3.12, 3.13) conclude `success`, check off S22 and U12, and re-run the CI gate on the new head.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as PASS are checked off in the source files.
- Criteria evaluated as PARTIAL, FAIL, or UNVERIFIED remain unchecked.

All 32 PASS criteria were already checked (`- [x]`) in the source files by the executor (reviewer count at head `4bbba7c70`: 21 checked in the `spec.md` Acceptance Criteria section, 11 in `user-story.md`); the re-evaluation confirms each, so no source-file change was needed. S22 and U12 remain unchecked as CI-dependent; the item's own orchestrator run checks them off at S9.

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
