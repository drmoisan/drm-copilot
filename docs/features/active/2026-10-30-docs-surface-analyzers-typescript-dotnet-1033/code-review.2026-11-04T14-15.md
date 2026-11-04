# Code Review: Docs surface analyzers for TypeScript and .NET (#1033)

**Review Date:** 2026-11-04
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033`
**Base Branch:** `origin/epic/documentation-estate-tooling-integration` (tip and merge base `a94dea9a4`)
**Head Branch:** `feature/docs-surface-analyzers-typescript-dotnet-1033-r2` (head `4bbba7c70`; one untracked evidence file, `evidence/regression-testing/post-integration-merge.2026-11-04T14-05.md`; no pull request yet)
**Review Type:** Initial full-branch review

---

## Executive Summary

The review covers the full branch diff against the epic integration branch (`git diff a94dea9a4...HEAD`, 104 paths, matching `artifacts/pr_context.summary.txt` refreshed at head `4bbba7c70`). `git merge-base --all` returns the single commit `a94dea9a4`, equal to the integration tip, because the head commit `4bbba7c70` merges that tip (siblings #1020, #1021, #1022 and #1023). The item diff therefore excludes the siblings' own changes, but the code at HEAD runs together with them, and the review evaluated the merged state.

The branch adds seventeen PowerShell modules under `.claude/lib/docs/` (the ten specified modules plus seven split helper modules kept under the spec's 500-line ceiling), seven registry rows in `DocsAnalyzerRegistry.psm1` under the 1033 anchor, byte-identical bundle copies of the eighteen changed files (equal git blob ids for all 18 pairs), 17 new `core.json` entries (one per added module; the edited registry was already listed), 19 new Pester suites and one test support module under `tests/scripts/claude-lib/docs/`, and feature-folder documentation. No `.py`, `.ts`, `.tsx`, `.js`, `.mjs`, `.cjs`, `.cs`, `.sh` or `.bats` file is in the diff.

The reviewer re-ran PSScriptAnalyzer and the formatter over the 38 changed `.ps1`/`.psm1` source files (0 findings, 0 differences), the docs Pester folder at HEAD without coverage, the push-down contract pytest (34 of 34), the evidence-location validator (exit 0), bundle blob parity, and a per-file parse of `artifacts/pester/powershell-coverage.xml`. Counts are in `policy-audit.2026-11-04T14-15.md` section 6.

**What changed well:**
- Strict purity: no new module reads a file, the clock or the environment, starts a process, calls `Invoke-Expression` or uses `$global:` (reviewer search over the seventeen added modules). Module-scope `$script:` variables are constants (identifiers, bounds, precompiled `\G`-anchored regexes).
- Every element is built through 1020 `New-DocsSurfaceElement -SourceText`; no 1033 module computes a digest, so `Invoke-DocsAnalyzer` can recompute it and the later native analyzer will agree byte for byte.
- The precision-limit contract is machine-readable (`Get-DocsScannerPrecisionLimit`) and enforced by one fixture per row in `DocsScannerContract.Tests.ps1`, including the absence of the marker on non-precision-limit codes.
- The extension importer validates in the specified step order and copies findings as inert data; the registry import inside `Invoke-DocsAnalyzerExtensionImport` is literal and without `-Force`, which avoids a load-time cycle with the registry seam.

**Top 3 risks:**
1. The integration merge makes two sibling 1022 tests fail at HEAD (F1): they pin the full registry analyzer list to the five 1022 identifiers, and the merged registry also carries the seven 1033 rows. The required `poshqc / PowerShell QC` check will fail on the PR head until they are changed to membership assertions.
2. The spec's published contract for later children still states lowercase hyphenated diagnostic codes (F2), while the shipped code emits the uppercase underscore spellings that the merged 1020 grammar requires (plan decision C7). Downstream children (1023 ledger, 1024 reference generator, 1031 native analyzers) read `spec.md` `## Decisions Later Children Must Honor` as binding.
3. Per-file coverage on the PR head is CI-dependent (S22, U12). The local JaCoCo file reproduces the recorded figures exactly but predates the integration merge.

**PR readiness recommendation:** **Needs revision.** Two autonomous findings (F1, F2) and one `awaiting_ci` finding (F3) are listed in `remediation-inputs.2026-11-04T14-15.md`.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `tests/scripts/claude-lib/docs/DocsInventory.Tests.ps1`, `tests/scripts/claude-lib/docs/DocsInventorySnapshot.Tests.ps1` | `DocsInventory.Tests.ps1` line 110; `DocsInventorySnapshot.Tests.ps1` line 132 | F1. At HEAD `4bbba7c70` the docs Pester folder has two failures. Both assertions compare the snapshot's full analyzer list to exactly the five 1022 identifiers (`config-files`, `python-architecture`, `python-cli`, `python-http`, `python-public-api`); after the integration merge the registry also returns the seven 1033 rows. | Change both assertions to membership: assert that each of the five 1022 entries is present in the analyzer list (optionally that the list is sorted ordinally), without pinning the complete list. Commit the post-merge evidence file, re-run the docs folder and record the run under `evidence/regression-testing/`. | The epic contract (spec `## Decisions Later Children Must Honor`, C6) is that registry-dependent suites assert membership only, never the committed table. The failing suites run in the required check `poshqc / PowerShell QC`, so the PR cannot pass CI as merged. The tests are sibling files, but the failure exists only on this branch, so the fix belongs here. | Reviewer docs-folder run (policy audit section 6); executor `evidence/regression-testing/post-integration-merge.2026-11-04T14-05.md` (1666 of 1668, same two failures) |
| Major | `docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/spec.md` | `## Contract Dependencies on 1020 and 1022` row C7 (line 613); `## Decisions Later Children Must Honor` second bullet (lines 627-630); code literals throughout `## Recognition Rules`, `## Scanner Precision Limit` and `## Extension-Result Manifest Import` | F2. The spec states that "Diagnostic codes are lowercase words joined by `-`" and lists codes such as `ts-lexical-invalid` and `http-dynamic-route`. The shipped modules emit `TS_LEXICAL_INVALID`, `HTTP_DYNAMIC_ROUTE` and so on, because the merged 1020 `New-DocsDiagnostic` enforces `^[A-Z][A-Z0-9_]*$` (adopted as C7 in `evidence/other/contract-reconciliation.2026-11-03T21-46.md`). The divergence is recorded only in evidence and the plan, not in the specification that later children are told to honor. | Amend `spec.md` outside the acceptance-criteria checkboxes: replace the C7 row's default with the adopted grammar, rewrite the `## Decisions Later Children Must Honor` code bullet to state the uppercase underscore form and the mechanical mapping, and add one normative sentence in `## Scanner Precision Limit` that each listed code is emitted in its mapped form (or replace the literals, as #1022 did under decision D-1022-exec-1). Record the edit in the plan. | The user story's fourth persona asks for fixed diagnostic codes so that the ledger, the reference generator and a later native analyzer agree byte for byte. A consumer reading the spec would match the wrong spelling. The self-review (`evidence/qa-gates/self-review.2026-11-04T03-25.md`, Output Summary) recorded this as a documentation follow-up; under the repository's related-follow-up rule it is fixed in the item. | `grep -n` of `spec.md` lines 613 and 627; `Get-DocsScannerPrecisionLimit` `code` column and `DocsScannerContract.Tests.ps1` assertions use the uppercase spellings |
| Minor | `docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/plan.2026-10-30T18-39.md` | `[P7-T11]` acceptance (line 230) | The acceptance names `quality-checks7 / Code Quality & Tests (3.10)`; `.github/workflows/_quality-checks.yml` line 25 carries the matrix `["3.11", "3.12", "3.13"]` only, so that check context never exists. | At S9, record in `evidence/qa-gates/qa-ci-checks.<timestamp>.md` that the 3.10 entry does not exist and read the three existing entries; optionally correct the plan text. | The task cannot be satisfied literally; recording the deviation prevents a false wait at S9. Not blocking: it is a plan task, not an acceptance criterion. | `_quality-checks.yml` line 25 |
| Info | `.claude/lib/docs/DocsAnalyzerDotnetHttp.psm1` | lines 39-40, 108, 239 | `$script:DocsDotnetVerbAttribute` and `$script:DocsDotnetMapMethod` are default (case-insensitive) hashtables queried with `.ContainsKey`, so `[httpget]` or `app.mapget(...)` would be classified, although C# identifiers are case-sensitive. The other lookups in the module use `-ccontains` or ordinal-comparer hashtables. | Optional: build both tables with `[System.StringComparer]::Ordinal`, as the module does elsewhere. | Such spellings do not compile against ASP.NET Core, so the false-positive risk is low; no test or criterion is affected. | Source inspection |
| Info | `.claude/lib/docs/*.psm1` (seventeen added modules) | module headers | The spec's `## API / CLI Surface` says each sibling import is `Import-Module (Join-Path ...) -Force -ErrorAction Stop`; the modules import without `-Force`, matching 1020 and 1022 modules and `ClaudeLibModuleConvention.Tests.ps1`. | None required; a later spec revision could align the text with the convention. | Importing without `-Force` avoids reloading shared 1020 modules and is what the plan's import-cycle constraint relies on. | Source inspection; plan `## Design Constraints From Existing Tests` |
| Info | `.claude/lib/docs/DocsExtensionShape.psm1`, `.claude/lib/docs/DocsAnalyzerExtensionImport.psm1` | lines 26-27 and 40-41 | The schema URN and artifact-kind constants are declared in both modules. | Optional: export them from `DocsExtensionShape.psm1` or pass them in, so a schema change is made once. | Small duplication of two literals; no behavioral effect. | Source inspection |

No covered file is at or above the 700-line advisory tier. The largest covered files are `tests/scripts/claude-lib/docs/DocsScannerContract.Tests.ps1` at 525 logical lines, `.claude/lib/docs/DocsScannerCommon.psm1` at 498, `DocsCSharpSyntax.psm1` at 495, and `DocsTypeScriptSyntax.psm1` and `DocsAnalyzerExtensionImport.psm1` at 491 (`@(Get-Content -LiteralPath <path>).Count`). `config/file-size-baseline.json` is not in the branch diff.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- Module headers follow the 1020 convention: `Set-StrictMode -Version Latest`, `$ErrorActionPreference = 'Stop'`, literal `Join-Path -Path $PSScriptRoot -ChildPath '<literal>'` imports with `-ErrorAction Stop`, comment-based help with `.NOTES` naming `Get-DocsScannerPrecisionLimit`, and explicit `Export-ModuleMember` lists.
- Tokenizers advance with one precompiled `\G`-anchored regex per lexical state (`CultureInvariant`), so the loop runs once per token and is bounded by `-MaxTokens` and `-MaxDepth`.
- Suppressions are scoped and justified: `PSUseShouldProcessForStateChangingFunctions` on pure `New-` factories, `PSUseLiteralInitializerForHashtable` where an ordinal-comparer hashtable is required, `PSReviewUnusedParameter` for the contract-fixed `-Selection`, and `PSUseSingularNouns` for the contract-fixed `Invoke-DocsAnalyzerTypeScriptExports`.
- The registry edit is seven data rows directly under `# --- 1033: TypeScript and .NET analyzers ---`; after the merge the five 1022 rows sit under the 1022 anchor above it, and no other registry line changed.

#### API and safety notes

- Analyzers throw only for contract violations in their own arguments; content problems become diagnostics, and a blocking diagnostic for one file leaves other files' elements intact (`DocsScannerContract.Tests.ps1` `bounds`).
- The extension importer checks every declared digest against the captured inputs and rejects the whole manifest on the first failed step; accepted findings are copied as data with recomputed element identifiers and digests.

#### Error handling and logging

- No empty `catch` block exists in the added modules (reviewer search). Bound overflows, lexical errors and JSON failures are explicit blocking diagnostics with fixed codes.

---

## Test Quality Audit

### Reviewed test and QA artifacts

- 19 new suites and `Docs.ScannerTestSupport.psm1` under `tests/scripts/claude-lib/docs/`, one suite per added module (17) plus `DocsScannerContract.Tests.ps1` and `DocsAnalyzerRegistry.TypeScriptDotnet.Tests.ps1`.
- Executor evidence: `evidence/regression-testing/isolation-shuffled.2026-11-04T03-01.md` (three seeds), `evidence/regression-testing/isolation-single-process.2026-11-04T03-22.md`, `evidence/qa-gates/qa-pester-coverage.2026-11-04T03-01.md`, `evidence/qa-gates/coverage-delta.2026-11-04T03-22.md`, `evidence/qa-gates/qa-hygiene-and-size.2026-11-04T03-23.md`, `evidence/qa-gates/self-review.2026-11-04T03-25.md`, `evidence/regression-testing/post-integration-merge.2026-11-04T14-05.md` (untracked).

### Quality assessment prompts

- **Determinism:** seeded `[System.Random]` only in the shuffle helper, with the seed in the failure text; no clock, environment or process access in the new suites.
- **Isolation:** inputs are captured in-memory records; every suite removes its modules in `AfterAll`.
- **Temporary files:** no `New-TemporaryFile`, `TestDrive`, `GetTempPath`, `GetTempFileName`, `$env:TEMP`, `Start-Process`, `Start-Sleep`, `Get-Date` or `Get-Command` in any added or edited test file (reviewer token scan).
- **Post-merge interaction:** the new 1033 suites assert registry membership only, as specified; the two sibling 1022 suites do not, which is F1.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credential or host path in the diff; `evidence/qa-gates/qa-token-scan.2026-11-04T03-23.md`; `dotnet-config` emits keys and shapes only (S6 value-absence test). |
| No unsafe subprocess or command construction | ✅ PASS | No process start, `Invoke-Expression` or `&` on a variable in the added modules (reviewer search); `enforcement-hooks-no-python-invocation.Tests.ps1` passes (executor `evidence/regression-testing/p6-existing-suites.2026-11-04T02-17.md`). |
| Input validation at boundaries | ✅ PASS | Size, token, depth, key and JSON-depth bounds; strict 1020 JSON reader for manifests; digest checks for every declared input. |
| Error handling remains explicit | ✅ PASS | Strict mode, `Stop` preference, no empty catch. |
| Imported data treated as inert | ✅ PASS | Manifest values are copied as data; adapter identifiers equal to a registered analyzer are rejected (`EXTENSION_ADAPTER_INVALID`). |

---

## Research Log

No external research was required. Repository sources consulted: `spec.md` (version 0.4), `user-story.md`, `plan.2026-10-30T18-39.md`, the evidence records under `evidence/`, `.claude/rules/powershell.md`, `.claude/rules/general-code-change.md`, `.github/workflows/ci.yml` and `_quality-checks.yml`, and the sibling #1022 review artifacts for the merged-registry precedent.

---

## Verdict

Two Major findings (F1, F2) require changes in this item; both are autonomous. One Minor and three Info items are recorded and do not block. No file-size Warning applies. The CI-dependent criteria S22 and U12 remain open as F3 (`awaiting_ci`). See `remediation-inputs.2026-11-04T14-15.md`.
