# Code Review: Docs surface analyzers for TypeScript and .NET (#1033)

**Review Date:** 2026-11-04
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033`
**Base Branch:** `origin/epic/documentation-estate-tooling-integration` (tip and merge base `a94dea9a4`)
**Head Branch:** `feature/docs-surface-analyzers-typescript-dotnet-1033-r2` (head `f06a626b45da76827da0607e0773f04cb4e8a0b6`; clean worktree; no pull request yet)
**Review Type:** Re-audit after remediation cycle 1 (prior review `2026-11-04T14-15`)

---

## Executive Summary

The review covers the full branch diff against the epic integration branch (`git diff a94dea9a4...HEAD`, 129 paths). `git merge-base origin/epic/documentation-estate-tooling-integration HEAD` returns `a94dea9a4`, equal to the integration tip, because `4bbba7c70` merged that tip. The 25 paths added since the prior review are the cycle's code, test and documentation changes plus the committed review and evidence records.

The branch as a whole adds seventeen PowerShell modules under `.claude/lib/docs/`, seven registry rows in `DocsAnalyzerRegistry.psm1` under the 1033 anchor, byte-identical bundle copies of the eighteen changed `.claude/lib/docs/` files (equal git blob ids for all 18 pairs at HEAD), 17 new `core.json` entries, 19 new Pester suites, one test support module, two edited sibling 1022 suites, and feature-folder documentation. No `.py`, `.ts`, `.tsx`, `.js`, `.mjs`, `.cjs`, `.cs`, `.sh` or `.bats` file is in the diff.

Remediation cycle 1 changed:

- `tests/scripts/claude-lib/docs/DocsInventory.Tests.ps1` and `DocsInventorySnapshot.Tests.ps1`: the exact five-entry analyzer-list assertions are replaced by per-entry `-ccontains` membership checks and an ordinal-order check (F1).
- `spec.md`: a normative `### Diagnostic code spelling (C7)` subsection, a rewritten C7 row, an amended `## Scanner Precision Limit` lead-in and a rewritten code bullet in `## Decisions Later Children Must Honor` (F2).
- `DocsAnalyzerDotnetHttp.psm1`: the verb-attribute and `Map*` tables are now `Dictionary[string,string]` with `StringComparer.Ordinal` (prior Info item), with a new wrong-case test.
- `DocsExtensionShape.psm1`: new exported `Get-DocsExtensionManifestIdentity`; `DocsAnalyzerExtensionImport.psm1` reads the schema URN and artifact kind from it instead of declaring its own copies (prior Info item), with two new tests.

The reviewer re-ran at HEAD: the docs Pester folder without coverage, PSScriptAnalyzer and the formatter over the 40 changed `.ps1`/`.psm1` source files (0 findings, 0 differences), the module-convention and no-Python-invocation suites (39 of 39), the push-down contract pytest (96 of 96), the evidence-location validator (exit 0), bundle blob parity, a per-file parse of `artifacts/pester/powershell-coverage.xml`, and a row-by-row comparison of the spec precision-limit table with `Get-DocsScannerPrecisionLimit` (21 rows each; every hyphenated spec code maps to the emitted uppercase code). Counts are in `policy-audit.2026-11-04T15-41.md` section 6.

**What changed well:**
- The F1 fix asserts exactly what spec C6 requires (membership and order, never the committed table) and leaves every other assertion in both tests unchanged.
- The F2 fix states the mapping rule once, normatively, and points the rewritten bullets at it, so the many hyphenated literals elsewhere in the spec remain valid specification names without a large text rewrite.
- `Get-DocsExtensionManifestIdentity` returns a new hashtable per call, and its test proves that a caller's mutation does not reach a later call and that the returned values satisfy `Get-DocsExtensionShapeProblem`.
- The ordinal dictionaries are populated once at module load from literal pairs; the lookups at lines 112 and 243-247 already used `.ContainsKey`, so the call sites did not change.

**Top 3 risks:**
1. Per-file and repository-wide coverage on the PR head is CI-dependent (S22, U12). The local JaCoCo file is from the executor's docs-folder run at the cycle's final code and reproduces every recorded figure, but it is not the `windows-latest` report the criteria name.
2. The new source-text test in `DocsAnalyzerExtensionImport.Tests.ps1` asserts the absence of two literals in the module text; a future comment that quotes the URN would fail it. The risk is low and the failure message names the reason.
3. Plan `[P7-T11]` still names a `quality-checks7 ... (3.10)` check that `_quality-checks.yml` does not define (carried Minor item); the S9 evidence must record its absence.

**PR readiness recommendation:** **Ready for PR, pending CI.** No autonomous finding remains. The one blocking item is F3 (`awaiting_ci`), listed in `remediation-inputs.2026-11-04T15-41.md`.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `tests/scripts/claude-lib/docs/DocsInventory.Tests.ps1`, `tests/scripts/claude-lib/docs/DocsInventorySnapshot.Tests.ps1` | analyzer assertions (lines 110-117 and 132-137) | Prior F1 resolved. Both tests now assert that each 1022 entry is present (`-ccontains`) and that the id list is in ordinal order. | None. | Matches spec C6 (membership only). | Reviewer docs-folder run at HEAD (policy audit section 6); `evidence/regression-testing/f1-membership.2026-11-04T14-56.md` |
| Info | `docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/spec.md` | `### Diagnostic code spelling (C7)`; C7 row; `## Scanner Precision Limit` lead-in; `## Decisions Later Children Must Honor` code bullet | Prior F2 resolved. The spec now states that each hyphenated code is emitted uppercased with `-` replaced by `_`, matching `^[A-Z][A-Z0-9_]*$`. The reviewer compared all 21 precision-limit rows with `Get-DocsScannerPrecisionLimit`: same pairs, codes equal under the mapping. The referenced heading `## C7 adopted code spellings` exists in `evidence/other/contract-reconciliation.2026-11-03T21-46.md`. | None. | Later children now read the emitted spelling from the binding section. | `git diff 4bbba7c70 HEAD -- spec.md`; reviewer comparison script |
| Info | `.claude/lib/docs/DocsAnalyzerDotnetHttp.psm1` | lines 40-44 | Prior Info item resolved: both tables use `StringComparer.Ordinal`; a new test shows `Httpget`, `HTTPPOST`, `Mapget` and `MapPOST` are not routes. | None. | C# names are case-sensitive. | `DocsAnalyzerDotnetHttp.Tests.ps1` new `It`; coverage 175 of 176, uncovered line 346 is the unchanged `catch` line (old line 342) |
| Info | `.claude/lib/docs/DocsExtensionShape.psm1`, `.claude/lib/docs/DocsAnalyzerExtensionImport.psm1` | `Get-DocsExtensionManifestIdentity`; lines 40-41 | Prior Info item resolved: one source for the schema URN and artifact kind. | None. | A schema change is now made once. | `DocsExtensionShape.Tests.ps1` `Describe 'Get-DocsExtensionManifestIdentity'` |
| Minor | `docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/plan.2026-10-30T18-39.md` | `[P7-T11]` acceptance (line 230) | Carried from the prior review: the acceptance names `quality-checks7 / Code Quality & Tests (3.10)`, which `_quality-checks.yml` (matrix 3.11, 3.12, 3.13) does not produce. | At S9, record in `evidence/qa-gates/qa-ci-checks.<timestamp>.md` that the 3.10 entry does not exist and read the three existing entries. | Prevents a false wait at S9. Not blocking: a plan task, not an acceptance criterion. | `_quality-checks.yml` matrix |
| Info | `.claude/lib/docs/*.psm1` (seventeen added modules) | module headers | Carried: the spec's import form names `-Force`; the modules follow the 1020 convention without it. | None required. | Importing without `-Force` avoids reloading shared 1020 modules. | Source inspection |

No covered file is at or above the 700-line advisory tier. The largest covered files are `tests/scripts/claude-lib/docs/DocsScannerContract.Tests.ps1` at 525 logical lines, `.claude/lib/docs/DocsScannerCommon.psm1` at 498, `DocsCSharpSyntax.psm1` at 495, and `DocsTypeScriptSyntax.psm1` and `DocsAnalyzerExtensionImport.psm1` at 491 (`@(Get-Content -LiteralPath <path>).Count`, reviewer). `config/file-size-baseline.json` is not in the branch diff.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- Module headers keep the 1020 convention: `Set-StrictMode -Version Latest`, `$ErrorActionPreference = 'Stop'`, literal `Join-Path -Path $PSScriptRoot -ChildPath '<literal>'` imports with `-ErrorAction Stop`, comment-based help and explicit `Export-ModuleMember` lists. The new `Get-DocsExtensionManifestIdentity` has `[CmdletBinding()]`, `[OutputType([hashtable])]` and comment-based help, and is added to the export list.
- `DocsAnalyzerExtensionImport.psm1` already imported `DocsExtensionShape.psm1` before the cycle, so the new read adds no import edge and no cycle.
- Bundle copies of the three cycle-edited modules have equal blob ids with their sources at HEAD; `core.json` needed no change.

#### API and safety notes

- `Get-DocsExtensionManifestIdentity` is a new public function of an internal library module; it is additive and changes no existing signature.
- The ordinal dictionaries narrow recognition only for spellings that do not compile against ASP.NET Core; no criterion or fixture depended on case-insensitive matching (all docs suites pass).

#### Error handling and logging

- No empty `catch` block was added. The dictionaries use `.Add`, which throws on a duplicate key at load time, so a duplicated literal would fail fast.

---

## Test Quality Audit

### Reviewed test and QA artifacts

- Cycle-edited suites: `DocsInventory.Tests.ps1`, `DocsInventorySnapshot.Tests.ps1`, `DocsAnalyzerDotnetHttp.Tests.ps1`, `DocsExtensionShape.Tests.ps1`, `DocsAnalyzerExtensionImport.Tests.ps1`.
- Executor evidence: `evidence/remediation-baseline/pester-coverage.2026-11-04T14-36.md` (fail-before, 1666 of 1668), `evidence/regression-testing/f1-membership.2026-11-04T14-56.md`, `evidence/regression-testing/dotnet-case-fail-before.2026-11-04T15-00.md`, `evidence/regression-testing/related-items.2026-11-04T15-04.md`, `evidence/qa-gates/qa-pester-coverage.2026-11-04T15-07.md` (1671 of 1671), `evidence/regression-testing/isolation-shuffled.2026-11-04T15-28.md` (three seeds, 133 of 133 each), `evidence/qa-gates/qa-pssa.2026-11-04T15-06.md`, `evidence/qa-gates/qa-poshqc-format.2026-11-04T15-05.md`, `evidence/qa-gates/qa-pushdown-contracts.2026-11-04T15-28.md`, `evidence/qa-gates/self-review.2026-11-04T15-32.md`, and the now committed `evidence/regression-testing/post-integration-merge.2026-11-04T14-05.md`.

### Quality assessment prompts

- **Determinism:** the new tests use in-memory strings and fixed literals; no clock, environment, process or random source.
- **Isolation:** each new test targets one function; the source-text test reads the module file through `Get-Content` only and writes nothing.
- **Temporary files:** reviewer token scan of the added lines in the cycle diff (`TestDrive`, `New-TemporaryFile`, `GetTempPath`, `GetTempFileName`, `$env:TEMP`, `Start-Process`, `Start-Sleep`, `Get-Date`, `$global:`): no match.
- **Fail-before evidence:** F1 has a recorded failing baseline; the case-sensitivity change has `dotnet-case-fail-before.2026-11-04T15-00.md`.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credential or host path added in the cycle diff; `dotnet-config` still emits keys and shapes only. |
| No unsafe subprocess or command construction | ✅ PASS | No process start or `Invoke-Expression` added; `enforcement-hooks-no-python-invocation.Tests.ps1` 33 of 33 (reviewer). |
| Input validation at boundaries | ✅ PASS | Unchanged bounds; manifest identity values enforced by the same constants as before. |
| Error handling remains explicit | ✅ PASS | Strict mode and `Stop` preference; no empty catch added. |
| Imported data treated as inert | ✅ PASS | Unchanged importer copy semantics; all `DocsAnalyzerExtensionImport.Tests.ps1` tests pass. |

---

## Research Log

No external research was required. Repository sources consulted: `spec.md`, `user-story.md`, `plan.2026-10-30T18-39.md`, `remediation-plan.2026-11-04T14-15.md` (29 of 29 tasks checked), the prior review artifacts with stamp `2026-11-04T14-15`, the cycle evidence records, `evidence/other/contract-reconciliation.2026-11-03T21-46.md`, `.claude/rules/powershell.md`, and `.claude/rules/general-code-change.md`.

---

## Verdict

The two prior Major findings (F1, F2) are resolved, and both prior Info items taken into the cycle are resolved. One Minor and one Info item carry forward and do not block. No file-size Warning applies. The CI-dependent criteria S22 and U12 remain open as F3 (`awaiting_ci`). See `remediation-inputs.2026-11-04T15-41.md`.
