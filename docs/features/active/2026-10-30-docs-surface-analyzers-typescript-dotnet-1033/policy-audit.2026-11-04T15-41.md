# Policy Compliance Audit: Docs surface analyzers for TypeScript and .NET (#1033)

**Audit Date:** 2026-11-04
**Reviewer:** feature-review agent
**Audit Type:** Re-audit after remediation cycle 1 (prior review `2026-11-04T14-15`)
**Feature Folder:** `docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033`
**Base Branch:** `origin/epic/documentation-estate-tooling-integration` (tip `a94dea9a4`)
**Head Branch:** `feature/docs-surface-analyzers-typescript-dotnet-1033-r2` (head `f06a626b45da76827da0607e0773f04cb4e8a0b6`; clean worktree before this review's four artifacts; no pull request exists yet)
**Merge base:** `a94dea9a4be0743f00ff78de095c51e14d513b20`. `git merge-base origin/epic/documentation-estate-tooling-integration HEAD` returns this commit, equal to the integration tip because `4bbba7c70` merged that tip. The item diff is `git diff a94dea9a4...HEAD` (129 paths). `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` were generated at 14:01 UTC for head `4bbba7c70` (104 paths); assumption: the 25 paths added since (`git diff --name-only 4bbba7c70 HEAD`) were read from the direct diff, and the scope is the full 129-path diff.

**Code Under Test (branch diff, 129 paths):**

- 17 new PowerShell modules under `.claude/lib/docs/` and the edited `DocsAnalyzerRegistry.psm1` (seven rows under the 1033 anchor). Cycle 1 edited `DocsAnalyzerDotnetHttp.psm1`, `DocsExtensionShape.psm1` and `DocsAnalyzerExtensionImport.psm1`.
- Byte-identical bundle copies of those 18 files under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/`, and the edited `pack-manifests/core.json` (17 added entries).
- 19 new Pester suites and `Docs.ScannerTestSupport.psm1`, plus two edited sibling 1022 suites (`DocsInventory.Tests.ps1`, `DocsInventorySnapshot.Tests.ps1`), under `tests/scripts/claude-lib/docs/`.
- Feature-folder Markdown: spec, user story, plans, prior review artifacts and evidence files.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 18 production (+18 bundle copies), 21 test files and 1 test support module | 1671 (docs folder) plus 39 gate tests | ✅ docs folder 1671 pass, 0 fail (86 suites, reviewer re-run at HEAD, coverage off); gates 39 pass, 0 fail | 92.64% lines (P0-T8, full `tests/scripts` at the then merge base, 21910 of 23651) | 93.22% lines (derived: prior full-run root 24523 of 26308 plus the cycle's per-file delta, 24531 of 26316; see assumption below) | 98.19% over the 17 new modules (2605 of 2653), minimum per file 92.43%; cycle-changed lines all covered |
| JSON | 1 modified (`core.json`) | N/A | ✅ push-down contract pytest 96 of 96 pass | N/A (pack manifest; no coverage tool) | N/A (pack manifest) | N/A |

Python, TypeScript, C#, and Bash: zero changed files on the branch (verified with `git diff --name-only a94dea9a4...HEAD` filtered by `*.py`, `*.ts`, `*.tsx`, `*.js`, `*.mjs`, `*.cjs`, `*.cs`, `*.sh`, `*.bats`: no match), so no coverage row applies.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope (zero TypeScript files changed)
- TypeScript post-change coverage artifact: N/A - out of scope (zero TypeScript files changed)
- PowerShell baseline coverage artifact: `evidence/baseline/baseline-pester-coverage.2026-11-03T22-12.md` (full `tests/scripts` run, 92.64%); cycle baseline `evidence/remediation-baseline/pester-coverage.2026-11-04T14-36.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (written 2026-11-04T15:28Z by the executor's `[P5-T3]` `Invoke-PoshQCTest -ScanFolders tests/scripts/claude-lib/docs` run; `pester-junit.xml` from the same run lists 1671 tests, 0 failures)
- Per-language comparison summary: section 1.2.1 of this audit

Artifact freshness check: the last commit touching `.claude/lib` is `58445bd67` (15:05Z), and the newest `.claude/lib/docs/*.psm1` modification time is 15:04Z; the coverage file was written at 15:28Z and the worktree is clean, so the per-file figures describe the code at HEAD. The uncovered line of `DocsAnalyzerDotnetHttp.psm1` is line 346, the unchanged `DECLARATION_INVALID` `catch` line (line 342 before the cycle's four added lines).

Repository-wide figure assumption: the artifact's root LINE counter (8083 of 30831, 26.22%) keeps the full denominator but only the docs-folder tests ran, so it is not a repository-wide figure. The last full-tree figure is 93.21% (24523 of 26308, prior review, pre-merge tree). The item's later changes add 8 covered of 8 lines (registry +5 rows from the merge at 131 of 131, `DocsAnalyzerDotnetHttp.psm1` +2, `DocsExtensionShape.psm1` +1), giving 24531 of 26316 (93.22%). Sibling modules brought in by the merge were measured in their own reviews; the `windows-latest` report on the PR head (S22) gives the authoritative post-merge figure.

---

## Executive Summary

The branch adds read-only, lexical PowerShell scanners for TypeScript and .NET surfaces and an extension-result manifest importer, with registry rows, bundle copies, manifest entries and Pester suites. Remediation cycle 1 (29 of 29 plan tasks checked) fixed the two prior autonomous findings and the two related Info items.

The reviewer re-ran at head `f06a626b4`: the docs Pester folder (1671 of 1671, 86 suites, 0 failed containers), the module-convention and no-Python-invocation suites (39 of 39), PSScriptAnalyzer and the formatter over the 40 changed `.ps1`/`.psm1` source files (0 findings, 0 differences), the push-down contract pytest (96 of 96), the evidence-location validator (exit 0), blob parity of all 18 bundle pairs, logical line counts, a per-file parse of the coverage artifact, and a row-by-row comparison of the spec precision-limit table with `Get-DocsScannerPrecisionLimit` (21 of 21 rows match under the C7 mapping).

Findings: prior F1 and F2 are resolved. One blocking finding remains, F3 (CI-dependent criteria S22 and U12, `awaiting_ci`). No new finding. No file-size Warning. Overall verdict: AWAITING_CI.

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md` / `general-code-change.instructions.md`
- ✅ `.claude/rules/general-unit-test.md` / `general-unit-test.instructions.md`
- ✅ `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists; `.claude/lib/docs` is classified T3)

**Language-specific policies evaluated:**
- N/A `python-code-change.instructions.md` + `python-unit-test.instructions.md` (no Python file changed)
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md`
- N/A Bash: no shell file changed
- ✅ JSON: `core.json` parsed by the manifest suite and the push-down pytest

**Temporary artifacts cleanup:**
- ✅ No temporary or one-time script is committed; executor helper scripts are referenced as `SCRATCH/...` and live outside the repository
- ✅ The reviewer ran Pester with coverage off, so `artifacts/pester/` was not modified; the reviewer added only this review's four artifacts to the worktree

---

## Rejected Scope Narrowing

No scope narrowing was detected in the caller prompt. The prompt asks for the full feature-review workflow over the whole branch diff with no scope narrowing. The instruction to classify S22, U12 and `[P7-T11]` as `awaiting_ci` matches the acceptance-criteria tracking rule for CI-dependent criteria and does not narrow the coverage audit, which is performed in section 1.2.1.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | ✅ PASS | Three seeded shuffled file-order runs of the five cycle-touched suites (`evidence/regression-testing/isolation-shuffled.2026-11-04T15-28.md`, seeds 1033, 4242, 7, 133 of 133 each) and the earlier three-seed runs of the 1033 suites; every suite removes its modules in `AfterAll`. |
| **Isolation** | ✅ PASS | One suite per added module plus contract and registry membership suites; each new cycle test targets one function. |
| **Fast Execution** | ✅ PASS | The five cycle-touched suites run 133 tests per shuffled run; the 19 new suites ran in 33 s in the prior review. |
| **Determinism** | ✅ PASS | No clock, environment, process or random source in the cycle's added test lines (reviewer token scan). |
| **Readability & Maintainability** | ✅ PASS | Descriptive `It` names, Arrange/Act/Assert comments, `-Because` on each new assertion. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Baseline coverage documented | ✅ PASS | `evidence/baseline/baseline-pester-coverage.2026-11-03T22-12.md` (92.64%); cycle baseline `evidence/remediation-baseline/pester-coverage.2026-11-04T14-36.md`. |
| Coverage artifact describes the change | ✅ PASS | Freshness check above. |
| No coverage regression on changed lines | ✅ PASS | `DocsAnalyzerDotnetHttp.psm1` 173 of 174 before, 175 of 176 after (same unchanged line uncovered); `DocsExtensionShape.psm1` 103 of 103 to 104 of 104; `DocsAnalyzerExtensionImport.psm1` 195 of 195 both; registry 131 of 131. |
| New-file line coverage >= 85% | ✅ PASS | Seventeen new modules 92.43% to 100% (table in 1.2.1). |
| Repo-wide line coverage >= 85% | ✅ PASS | 93.22% derived (assumption above); the root counter of the docs-only run is not repository-wide. |
| Branch coverage | N/A | Pester measures no branch coverage; no branch threshold applies to PowerShell. |
| Coverage exclusions | ✅ PASS | `config/poshqc-coverage.json` is not in the branch diff; all seventeen new modules appear as sourcefiles in the artifact. |
| Positive, negative, edge, error flows | ✅ PASS | Prior evidence unchanged; the cycle adds a negative wrong-case test, a single-source test and an identity accessor test with a mutation-isolation check. |
| Concurrency / state transitions | N/A | Pure in-memory functions with no shared mutable state. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 92.64% (P0-T8, full `tests/scripts`). Post-change: 93.22% (derived from the last full-tree root counter plus the item's later per-file delta; assumption in the freshness note). Change: +0.58 points. Disposition: PASS. New/changed-code coverage: 98.19% over the 17 new modules (2605 of 2653), minimum per file 92.43%; every cycle-changed line covered. Evidence: `artifacts/pester/powershell-coverage.xml` parsed per sourcefile by the reviewer, `evidence/qa-gates/qa-pester-coverage.2026-11-04T15-07.md`, `evidence/qa-gates/coverage-delta.2026-11-04T03-22.md`. The CI-dependent criteria S22 and U12 remain open as F3 (`awaiting_ci`).
- JSON: N/A - no coverage tool applies to the pack manifest.

Per-file line coverage from the artifact (reviewer parse at HEAD):

| File | Covered / Total | Line % |
|---|---|---|
| `.claude/lib/docs/DocsScannerCommon.psm1` | 176 / 179 | 98.32% |
| `.claude/lib/docs/DocsTypeScriptTokens.psm1` | 222 / 229 | 96.94% |
| `.claude/lib/docs/DocsTypeScriptSyntax.psm1` | 209 / 210 | 99.52% |
| `.claude/lib/docs/DocsTypeScriptCliSupport.psm1` | 114 / 114 | 100% |
| `.claude/lib/docs/DocsTypeScriptHttpSupport.psm1` | 152 / 152 | 100% |
| `.claude/lib/docs/DocsTypeScriptHttpDeclaration.psm1` | 84 / 84 | 100% |
| `.claude/lib/docs/DocsAnalyzerTypeScriptCli.psm1` | 151 / 158 | 95.57% |
| `.claude/lib/docs/DocsAnalyzerTypeScriptHttp.psm1` | 77 / 80 | 96.25% |
| `.claude/lib/docs/DocsAnalyzerTypeScriptExports.psm1` | 224 / 232 | 96.55% |
| `.claude/lib/docs/DocsCSharpTokens.psm1` | 171 / 185 | 92.43% |
| `.claude/lib/docs/DocsCSharpSyntax.psm1` | 225 / 225 | 100% |
| `.claude/lib/docs/DocsCSharpMember.psm1` | 114 / 115 | 99.13% |
| `.claude/lib/docs/DocsAnalyzerDotnetHttp.psm1` (cycle-edited) | 175 / 176 | 99.43% |
| `.claude/lib/docs/DocsAnalyzerDotnetConfig.psm1` | 104 / 105 | 99.05% |
| `.claude/lib/docs/DocsAnalyzerDotnetApi.psm1` | 108 / 110 | 98.18% |
| `.claude/lib/docs/DocsExtensionShape.psm1` (cycle-edited) | 104 / 104 | 100% |
| `.claude/lib/docs/DocsAnalyzerExtensionImport.psm1` (cycle-edited) | 195 / 195 | 100% |
| `.claude/lib/docs/DocsAnalyzerRegistry.psm1` (edited, merged state) | 131 / 131 | 100% |

Full-tree run status: the executor's pre-merge single-process `tests/scripts` run on this Linux host reported 409 failures identical to the baseline set, none under `tests/scripts/claude-lib/docs` (`evidence/regression-testing/isolation-single-process.2026-11-04T03-22.md`). These are Linux-host defects outside this item; the cycle changed no file outside `tests/scripts/claude-lib/docs` and `.claude/lib/docs`, and `windows-latest` CI on the PR head is authoritative (F3).

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| Arrange-Act-Assert | ✅ PASS | The cycle's new tests carry Arrange / Act / Assert comments. |
| Clear failure messages | ✅ PASS | Each new membership and identity assertion has a `-Because` naming the entry or reason. |
| Clean test output | ✅ PASS | Reviewer docs-folder run: 0 failures, 0 failed containers. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| No external services | ✅ PASS | No network, process or git call added. |
| No temporary files | ✅ PASS | Reviewer token scan of the cycle's added lines and the prior scan of all added test files: no `TestDrive`, `New-TemporaryFile`, `GetTempPath`, `GetTempFileName` or `$env:TEMP`. The source-text test reads the committed module file and writes nothing. |
| No mutable global state | ✅ PASS | Module-scope dictionaries are populated once at load and only read afterwards; no `$global:`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Simplicity first | ✅ PASS | The cycle's code changes are two table constructions and one accessor. |
| Reusability | ✅ PASS | Schema URN and artifact kind now have one source (`Get-DocsExtensionManifestIdentity`). |
| Extensibility | ✅ PASS | The accessor is additive; no existing signature changed. |
| Separation of concerns | ✅ PASS | No I/O added to any module. |

### 2.2 Module and File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| At or below the 800-line hard limit | ✅ PASS | Largest covered file 525 logical lines (`DocsScannerContract.Tests.ps1`); largest new module 498 (`DocsScannerCommon.psm1`); `config/file-size-baseline.json` not in the diff. |
| 700-line advisory tier | ✅ PASS | No covered file at or above 700 lines. |
| Explicit exports | ✅ PASS | `Get-DocsExtensionManifestIdentity` added to the `Export-ModuleMember` list. |
| No circular dependencies | ✅ PASS | `DocsAnalyzerExtensionImport.psm1` already imported `DocsExtensionShape.psm1`; no new import edge. |

### 2.3 Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| Fail fast, no silent catch | ✅ PASS | Strict mode and `Stop` at module scope; `Dictionary.Add` throws on a duplicate key at load; no empty `catch` added. |

### 2.4 Toolchain Execution

| Step | Status | Evidence |
|------|--------|----------|
| 1. Formatting | ✅ PASS | Reviewer `Invoke-Formatter` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` over 40 files: 0 differences; executor `qa-poshqc-format.2026-11-04T15-05.md`. |
| 2. Linting | ✅ PASS | Reviewer per-file `Invoke-ScriptAnalyzer` with the same settings over 40 files: 0 findings; executor `qa-pssa.2026-11-04T15-06.md`. |
| 3. Type checking | N/A | PowerShell. |
| 4. Architecture-boundary tests | ✅ PASS | `ClaudeLibModuleConvention.Tests.ps1` 6 of 6, `enforcement-hooks-no-python-invocation.Tests.ps1` 33 of 33 (reviewer). |
| 5. Unit tests | ✅ PASS | Reviewer docs-folder run at HEAD: 1671 of 1671 (prior F1 failures resolved). |
| 6. Contract / schema checks | ✅ PASS | `Docs.Manifest.Tests.ps1` and the registry suites in the reviewer run; push-down contract pytest 96 of 96 (reviewer). |
| 7. Integration tests | ✅ PASS | `DocsInventory.Tests.ps1` (command integration through the merged registry) 13 of 13 in the reviewer run. |

---

## 3. Language-Specific Code Change Policy Compliance

### 3B PowerShell

| Requirement | Status | Evidence |
|------------|--------|----------|
| Formatting / PSScriptAnalyzer | ✅ PASS | See 2.4. |
| Advanced functions (`[CmdletBinding()]`) | ✅ PASS | Including the new `Get-DocsExtensionManifestIdentity`, which also declares `[OutputType([hashtable])]`. |
| Parameter validation | ✅ PASS | Unchanged; the accessor takes no parameter. |
| Approved verbs | ✅ PASS | `Get-` for the accessor. |
| No global state | ✅ PASS | Read-only `$script:` state only. |
| Suppressions justified | ✅ PASS | No suppression added in the cycle. |
| ShouldProcess for state-changing actions | ✅ PASS | Inspected by hand: no new function writes files or changes system state. |

### 3D JSON

| Requirement | Status | Evidence |
|------------|--------|----------|
| Strict JSON | ✅ PASS | `core.json` parsed by `Docs.Manifest.Tests.ps1` and the push-down pytest. |
| Manifest completeness | ✅ PASS | Unchanged by the cycle; the three edited modules are each listed once. |

Python, TypeScript, C#, Bash sections: N/A, zero changed files of those languages.

---

## 4. Language-Specific Unit Test Policy Compliance

### 4B PowerShell Unit Tests

| Requirement | Status | Evidence |
|------------|--------|----------|
| Pester v5 | ✅ PASS | `Describe`/`Context`/`It`. |
| Location mirrors source | ✅ PASS | `tests/scripts/claude-lib/docs/<Module>.Tests.ps1`. |
| File naming `*.Tests.ps1` | ✅ PASS | All suites. |
| Mocking used sparingly | ✅ PASS | No mock added in the cycle. |
| PoshQC test command | ✅ PASS | Executor coverage runs used `Invoke-PoshQCTest`; the reviewer used `Invoke-Pester` with coverage off so the artifact was not modified. |

---

## 5. Test Coverage Detail

See section 1.2.1 for per-file figures. The lowest module, `DocsCSharpTokens.psm1` (171 of 185), is above the 85% floor and unchanged by the cycle. Spec criterion S22 names the `poshqc / PowerShell QC` report on the PR head, which resolves F3.

---

## 6. Test Execution Metrics

| Run | Tests | Passed | Failed | Source |
|---|---|---|---|---|
| Reviewer, `tests/scripts/claude-lib/docs` (HEAD, coverage off) | 1671 | 1671 | 0 | this review |
| Reviewer, module-convention and no-Python-invocation suites | 39 | 39 | 0 | this review |
| Reviewer, push-down contract pytest (four files) | 96 | 96 | 0 | this review |
| Executor `[P5-T3]`, docs folder with coverage | 1671 | 1671 | 0 | `evidence/qa-gates/qa-pester-coverage.2026-11-04T15-07.md`; `artifacts/pester/pester-junit.xml` |
| Executor `[P0-T3]`, docs folder (fail-before) | 1668 | 1666 | 2 (prior F1) | `evidence/remediation-baseline/pester-coverage.2026-11-04T14-36.md` |
| Executor `[P5-T5]`, five touched suites, three seeds | 133 each | 133 each | 0 | `evidence/regression-testing/isolation-shuffled.2026-11-04T15-28.md` |

---

## 7. Code Quality Checks

- PSScriptAnalyzer: 0 findings over 40 files (reviewer).
- Formatter: 0 differences over 40 files (reviewer).
- File size: maximum 525 logical lines; no Warning row; no file above 800; no baseline entry added.
- Bundle mirror: `git rev-parse HEAD:<path>` returns equal blob ids for all 18 source/bundle pairs.
- Spec contract: 21 of 21 `## Scanner Precision Limit` rows equal `Get-DocsScannerPrecisionLimit` under the C7 mapping (reviewer).
- Tier: `.claude/lib/docs` is T3; no property-test density, mutation or golden-test obligation applies at T3.

---

## Evidence Location Compliance

`validate_evidence_locations.py --root <worktree>` (repository script `scripts/dev_tools/validate_evidence_locations.py`) exited 0 with no output. The branch diff contains no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All evidence is under `<FEATURE>/evidence/{baseline,other,qa-gates,regression-testing,remediation-baseline}/`. The plan's `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <FEATURE>/evidence/coverage/ replaced with <FEATURE>/evidence/qa-gates/` record stands. No violation.

---

## 8. Gaps and Exceptions

1. **Prior F1 resolved.** `DocsInventory.Tests.ps1` and `DocsInventorySnapshot.Tests.ps1` assert membership and ordinal order; the reviewer docs-folder run at HEAD has 0 failures (1671 of 1671).
2. **Prior F2 resolved.** `spec.md` states the uppercase underscore spelling normatively and maps every hyphenated name.
3. **F3 CI-dependent acceptance criteria S22 and U12 (blocking, awaiting_ci).** No pull request and no CI run exist for head `f06a626b4`; plan `[P7-T11]` is CI-dependent and unchecked.
4. **Warnings.** None.

No approved policy exception is claimed.

---

## 9. Summary of Changes

Cycle commits since the prior review (`git log 4bbba7c70..HEAD`): `2da1c71f3` (prior review artifacts and post-merge run), `e74802a41` (remediation plan), `0bd854498` (cycle preflight and Phase 0 baselines), `be0c07bc2` (1022 membership assertions, F1), `bd9db79c2` (spec code spelling, F2), `3c9872364` (exact-case `dotnet-http` tables), `58445bd67` (single-source manifest identity), `f06a626b4` (final QA loop). Earlier item commits are listed in `policy-audit.2026-11-04T14-15.md` section 9.

---

## 10. Compliance Verdict

**AWAITING_CI.** No autonomous finding remains; F3 resolves through CI on the PR head at S9.

---

## Appendix A: Test Inventory

Reviewer run of `tests/scripts/claude-lib/docs` at head `f06a626b4` (`Invoke-Pester`, coverage off), cycle-touched suites:

| Suite | Tests |
|---|---|
| `DocsInventory.Tests.ps1` (edited, F1) | 13 |
| `DocsInventorySnapshot.Tests.ps1` (edited, F1) | 11 |
| `DocsAnalyzerDotnetHttp.Tests.ps1` (one test added) | 11 |
| `DocsExtensionShape.Tests.ps1` (one test added) | 38 |
| `DocsAnalyzerExtensionImport.Tests.ps1` (one test added) | 60 |
| Total (cycle-touched) | 133 |

The 19 suites added by the item total 339 tests at HEAD (336 in the prior review plus the three cycle tests); all 86 containers passed.

The other suites of the docs folder contributed the rest of the 1671 tests.

## Appendix B: Toolchain Commands Reference

- `pwsh -NoProfile -File <scratch>/r1033c1-docs.ps1 -Root <worktree>` (`Invoke-Pester` over `tests/scripts/claude-lib/docs`, coverage off, per-container counts and failed-test names)
- `pwsh -NoProfile -File <scratch>/r1033c1-qa.ps1 -Root <worktree> -ListFile <list>` (`@(Get-Content -LiteralPath <path>).Count`, per-file `Invoke-ScriptAnalyzer` and `Invoke-Formatter` comparison with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` over the 40 changed `.ps1`/`.psm1` source files)
- `pwsh -NoProfile -File <scratch>/r1033c1-gates.ps1 -Root <worktree>` (`ClaudeLibModuleConvention.Tests.ps1`, `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`)
- `pwsh -NoProfile -File <scratch>/r1033c1-cov.ps1 -Path artifacts/pester/powershell-coverage.xml` (JaCoCo root and sourcefile LINE counters with missed line numbers)
- `pwsh -NoProfile -Command "Import-Module .claude/lib/docs/DocsScannerCommon.psm1; Get-DocsScannerPrecisionLimit"` compared with the spec table
- `python -m pytest --rootdir <worktree> -c <worktree>/pyproject.toml -o addopts="" -p no:cacheprovider -q` over `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, `test_push_down_issue_824_follow_ups.py`
- `git rev-parse HEAD:<path>` for each source/bundle pair; `git merge-base origin/epic/documentation-estate-tooling-integration HEAD`
- `python scripts/dev_tools/validate_evidence_locations.py --root <worktree>`
