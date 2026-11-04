# Policy Compliance Audit: Documentation coverage ledger and receipt (#1023)

**Audit Date:** 2026-11-04
**Reviewer:** feature-review agent
**Audit Type:** Initial full-branch review
**Feature Folder:** `docs/features/active/2026-10-30-docs-coverage-ledger-and-receipt-1023`
**Base Branch:** `origin/epic/documentation-estate-tooling-integration` (tip `d24071738`)
**Head Branch:** `feature/docs-coverage-ledger-and-receipt-1023-r2` (head `1b160781a38b622a187dc08a525790d81cd4c48b`; working tree clean apart from this review's artifacts; no pull request exists yet)
**Merge base:** `d2407173898d531a261433a10a3d8a483a1bf593`, as recorded in `artifacts/pr_context.summary.txt` (generated 2026-11-04 02:36:04 UTC for head `1b160781a`). `git merge-base --all` returns this single commit. The item diff is `git diff d24071738...HEAD` (97 paths).

**Code Under Test (branch diff, 97 paths):**

- 10 new PowerShell modules under `.claude/lib/docs/` (`DocsLedger`, `DocsLedgerRules`, `DocsParity`, `DocsEvidencePins`, `DocsStaleness`, `DocsReceipt`, `DocsValidation`, `DocsLedgerMutation`, `DocsCoverageReport`, `DocsLedgerCommands`) and the edited 1020 entry script `Invoke-DocsCommand.ps1` (three dispatch rows).
- Byte-identical bundle copies of all 11 paths under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/`, and the edited `pack-manifests/core.json` (10 lines).
- 25 new Pester suites and `DocsLedger.TestSupport.psm1` under `tests/scripts/claude-lib/docs/`.
- Feature-folder Markdown: spec, user story, plan, and evidence files.

The head commit `1b160781a` merges the integration branch and brings sibling #1021. Its changes are not in the item diff except where they meet 1023's edits: in `Invoke-DocsCommand.ps1` the 1021 `check` row is intact and the three 1023 rows sit directly under the 1023 anchor; in `core.json` the ten 1023 lines and the 1021 `DocsPage*` lines are both present with no duplicate.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 11 production (+11 mirror), 26 test files | 990 (docs folder) plus 44 gate tests | 990 pass, 0 fail; gates 44 pass, 0 fail (reviewer re-run, coverage off) | 92.66% lines (P0-T6, full `tests/scripts` at the merge base, 21914 of 23651) | 92.99% lines executor-recorded (23226 of 24977); not re-derivable from the current artifact, see F1 | 96.84% minimum per new file executor-recorded (96.84% to 100%); not re-derivable from the current artifact, see F1 |
| JSON | 1 modified (`core.json`) | N/A | push-down contract pytest 34 of 34 pass | N/A (pack manifest; no coverage tool) | N/A (pack manifest) | N/A |

Python, TypeScript, C#, and Bash: zero changed files on the branch (verified with `git diff --stat d24071738...HEAD` filtered by `*.py`, `*.ts`, `*.tsx`, `*.js`, `*.mjs`, `*.cjs`, `*.cs`, `*.sh`, `*.bats`: no match), so no coverage row applies.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope (zero TypeScript files changed)
- TypeScript post-change coverage artifact: N/A - out of scope (zero TypeScript files changed)
- PowerShell baseline coverage artifact: `evidence/baseline/baseline-pester-coverage.2026-11-03T22-10.md` (full `tests/scripts` run at the merge base, 92.66%)
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` exists but was rewritten at 2026-11-04T02:06Z by a five-test `FileSizePolicy.RepoGate.Tests.ps1` run (its `pester-junit.xml` lists only that suite); its root LINE counter is 61 of 24977 (0.24%) and every `.claude/lib/docs/` file shows 0 covered lines. The full-run figures are recorded in `evidence/qa-gates/qa-pester-coverage.2026-11-04T01-51.md` and `evidence/qa-gates/coverage-delta.2026-11-04T01-51.md` only.
- Per-language comparison summary: section 1.2.1 of this audit

Artifact consistency check: the denominators in the current artifact match the recorded figures exactly for every new file (for example `DocsLedgerCommands.psm1` 346 lines = 343 covered + 3 missed recorded; `DocsEvidencePins.psm1` 95 = 92 + 3; `DocsLedger.psm1` 169 = 167 + 2) and the root denominator equals the recorded 24977. This shows the recorded figures were computed over the same file set and source text, but the covered counts cannot be read from the current artifact. No production `.claude/lib/docs/` file changed after the recorded run (last 1023 production commit `f34aca8ea` at 2026-11-04T01:06Z; the merge `1b160781a` changes only the 1021 `check` row region of `Invoke-DocsCommand.ps1`).

---

## Executive Summary

The branch adds the documentation correspondence core: the coverage ledger, parity matrix, evidence pins with staleness detection, the `docs-complete` validation receipt and gate decision, the single write boundary, and the `coverage`, `update-ledger` and `validate` subcommands, as ten PowerShell modules with bundle copies, manifest lines and 25 Pester suites.

The reviewer re-ran at head `1b160781a`: the docs Pester folder (990 of 990, of which 215 in the 25 new suites), the module-convention, no-Python-invocation and file-size gate suites (44 of 44), PSScriptAnalyzer and the formatter over the 48 changed `.ps1`/`.psm1` files (0 findings, 0 differences), the push-down contract pytest (34 of 34), the evidence-location validator (exit 0), and blob-id parity of all eleven bundle pairs.

Findings: no autonomous finding. Two blocking findings, both `awaiting_ci`: F1 (the local PowerShell coverage artifact no longer describes the recorded run, so coverage verification is FAIL on local evidence) and F2 (the CI-dependent criteria S32 and U23). Two non-blocking file-size Warnings (`DocsLedgerCommands.psm1` at 785 lines and its bundle copy). Overall verdict: AWAITING_CI.

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md` / `general-code-change.instructions.md`
- ⚠️ `.claude/rules/general-unit-test.md` / `general-unit-test.instructions.md` (coverage verification on local evidence: F1)
- ✅ `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists; `.claude/lib/docs` is classified T3)

**Language-specific policies evaluated:**
- N/A `python-code-change.instructions.md` + `python-unit-test.instructions.md` (no Python file changed)
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md`
- N/A Bash: no shell file changed
- ✅ JSON: `core.json` parsed by the manifest suite and the push-down pytest

**Temporary artifacts cleanup:**
- ✅ No temporary or one-time script is committed; executor helper scripts are referenced as `SCRATCH/...` and live outside the repository
- ✅ The reviewer runs left the worktree clean apart from this review's four artifacts; the reviewer ran Pester with coverage off, so `artifacts/pester/` was not modified

---

## Rejected Scope Narrowing

No scope narrowing was detected in the caller prompt. The prompt names the full branch against the merge base of `origin/epic/documentation-estate-tooling-integration` and HEAD. Its statement that the sibling #1021 changes are out of scope except where they meet 1023's edits describes the merge-base diff itself: because `1b160781a` merges the integration tip, `d24071738...HEAD` excludes those changes. It does not exclude any 1023 file or language. The instruction to record S32 and U23 as pending-CI matches the acceptance-criteria tracking rule for CI-dependent criteria and does not narrow the coverage audit, which is performed in section 1.2.1.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | ✅ PASS | Three seeded shuffled file-order runs and one single-process run pass (`evidence/regression-testing/isolation-shuffled-pester.2026-11-04T02-02.md`, `evidence/qa-gates/qa-pester-coverage.2026-11-04T01-51.md`); every new suite removes the `Docs*` modules in `AfterAll`. |
| **Isolation** | ✅ PASS | One suite per module (the command module has three suites); the recording in-memory context replaces every I/O seam. |
| **Fast Execution** | ✅ PASS | Reviewer docs-folder run: 990 tests in 3 min 48 s in one process on the shared host. |
| **Determinism** | ✅ PASS | Fixed `UtcNow` of `Kind` `Utc`; seeded `[System.Random]` with the seed in each `-Because`; no clock, sleep, network or process. |
| **Readability & Maintainability** | ✅ PASS | Arrange/Act/Assert comments, descriptive `It` names, suite `.SYNOPSIS`/`.DESCRIPTION`. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Baseline coverage documented | ✅ PASS | `evidence/baseline/baseline-pester-coverage.2026-11-03T22-10.md` (92.66%). |
| Coverage artifact describes the change | ❌ FAIL | F1: `artifacts/pester/powershell-coverage.xml` was rewritten by a five-test run after the recorded full run. |
| No coverage regression on changed lines | ❌ FAIL (local evidence) | Executor-recorded: the three added lines of `Invoke-DocsCommand.ps1` are covered (hit counts 7, 21, 10); not re-derivable from the current artifact (F1). |
| New-file line coverage >= 85% | ❌ FAIL (local evidence) | Executor-recorded 96.84% to 100% per new file; not re-derivable from the current artifact (F1). |
| Repo-wide line coverage >= 85% | ❌ FAIL (local evidence) | Executor-recorded 92.99%; the current artifact root counter reads 0.24% because only one suite ran (F1). |
| Branch coverage | N/A | Pester measures no branch coverage; no branch threshold applies to PowerShell. |
| Coverage exclusions | ✅ PASS | `config/poshqc-coverage.json` is not in the branch diff; all ten new modules appear as sourcefiles in the artifact (279 files). |
| Positive, negative, edge, error flows | ✅ PASS | Exit 0/1/2/3 cases per command; empty ledger, absent artifacts, zero-denominator score, letter-case revision, `max_stale_pages` boundaries, digest conflict, injected read and write failures, non-UTC clock. |
| Concurrency / state transitions | ✅ PASS | No concurrency; state transitions covered by `DocsCompleteIntegration.Tests.ps1` (fail, update, pass) and the write-plan statuses. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 92.66% (P0-T6, full `tests/scripts` at the merge base). Post-change: 92.99% (executor-recorded in `qa-pester-coverage.2026-11-04T01-51.md`; not re-derivable from the current artifact). Change: +0.33 points (recorded). Disposition: FAIL. New/changed-code coverage: 96.84% minimum per new file (recorded range 96.84% to 100%; `Invoke-DocsCommand.ps1` 87.58%, three added lines covered). Evidence: `artifacts/pester/powershell-coverage.xml` parsed per sourcefile by the reviewer (0 covered lines in every `.claude/lib/docs/` file; root 61 of 24977), `evidence/qa-gates/qa-pester-coverage.2026-11-04T01-51.md`, `evidence/qa-gates/coverage-delta.2026-11-04T01-51.md`. The disposition is FAIL because the verification model requires the figures to be read from the existing coverage artifact, and the artifact present does not contain them; the recorded figures themselves exceed every threshold. Remediability: `awaiting_ci` (F1).
- JSON: N/A - no coverage tool applies to the pack manifest.

Executor-recorded per-file line coverage (from `qa-pester-coverage.2026-11-04T01-51.md`; denominators confirmed against the current artifact):

| File | Covered / Total | Line % |
|---|---|---|
| `.claude/lib/docs/DocsLedger.psm1` | 167 / 169 | 98.82% |
| `.claude/lib/docs/DocsLedgerRules.psm1` | 93 / 94 | 98.94% |
| `.claude/lib/docs/DocsEvidencePins.psm1` | 92 / 95 | 96.84% |
| `.claude/lib/docs/DocsStaleness.psm1` | 46 / 46 | 100% |
| `.claude/lib/docs/DocsParity.psm1` | 183 / 185 | 98.92% |
| `.claude/lib/docs/DocsReceipt.psm1` | 95 / 95 | 100% |
| `.claude/lib/docs/DocsLedgerMutation.psm1` | 59 / 60 | 98.33% |
| `.claude/lib/docs/DocsValidation.psm1` | 154 / 156 | 98.72% |
| `.claude/lib/docs/DocsCoverageReport.psm1` | 77 / 77 | 100% |
| `.claude/lib/docs/DocsLedgerCommands.psm1` | 343 / 346 | 99.13% |
| `.claude/lib/docs/Invoke-DocsCommand.ps1` (edited) | 134 / 153 | 87.58% |

Full-tree run status: the executor's single-process `tests/scripts` run on this Linux host reports 409 failures and 6 errors, a set identical to the merge-base baseline (25 suites, 97 test names, `diff` empty), none under `tests/scripts/claude-lib/docs`. These are Linux-host defects outside this item; `windows-latest` CI on the PR head is authoritative and is covered by F2.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| Arrange-Act-Assert | ✅ PASS | Section comments in each `It` of the new suites. |
| Clear failure messages | ✅ PASS | `-Because` names the seed, code, pointer or path; assertions compare codes and canonical JSON, not message text. |
| Clean test output | ✅ PASS | Reviewer run reported 0 failures and no stray console output from the new suites. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| No external services | ✅ PASS | No network or process in the new suites or modules. |
| No temporary files | ✅ PASS | Reviewer token scan of the new suites: no `New-TemporaryFile`, `GetTempFileName`, `GetTempPath`, `$env:TEMP`, `$env:TMP`, `Start-Process`, `Start-Sleep` or `TestDrive`; `evidence/qa-gates/qa-test-purity.2026-11-04T02-03.md`. |
| No mutable global state | ✅ PASS | Modules hold only read-only `$script:` constants; no `$global:`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Simplicity first | ✅ PASS | Pure functions over dictionaries; one dispatcher per command; no framework. |
| Reusability | ✅ PASS | 1020 helpers consumed (`Get-DocsOrderedFinding`, `Test-DocsArtifactText`, `ConvertFrom-DocsJsonText`, `Get-DocsStableId`); shared `Read-DocsLedgerInputSet`. |
| Extensibility | ✅ PASS | Modes, operations and artifact kinds are tables; keyword parameters. |
| Separation of concerns | ✅ PASS | Pure modules separate from the write boundary (`DocsLedgerMutation.psm1`) and the command layer; I/O only through the 1020 context. |

### 2.2 Module and File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| At or below the 800-line hard limit | ✅ PASS | Largest covered file 785 logical lines (`DocsLedgerCommands.psm1` and its bundle copy); `config/file-size-baseline.json` not in the diff; `FileSizePolicy.RepoGate.Tests.ps1` 5 of 5. |
| 700-line advisory tier | ⚠️ Warning | `DocsLedgerCommands.psm1` 785 and its bundle copy 785 (non-blocking; recorded in the code review). |
| Explicit exports | ✅ PASS | `Export-ModuleMember -Function` list per module. |
| No circular dependencies | ✅ PASS | `DocsLedgerMutation.psm1` imports no 1023 module; only `DocsLedgerCommands.psm1` imports it. |

### 2.3 Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| Fail fast, no silent catch | ✅ PASS | Strict mode and `Stop` at module scope; typed catch for absent artifacts; command-level catches return one `DOCS_CLI_RUNTIME` finding with the exception message; the pin-identity catch in `Get-DocsPinFinding` yields an explicit `DOCS_PIN_INCONSISTENT` error (Info in the code review). |

### 2.4 Toolchain Execution

| Step | Status | Evidence |
|------|--------|----------|
| 1. Formatting | ✅ PASS | Reviewer `Invoke-Formatter` with `pssa.settings.psd1` over 48 files: 0 differences; executor `qa-format.2026-11-04T01-16.md`. |
| 2. Linting | ✅ PASS | Reviewer `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` over 48 files: 0 findings; executor `qa-pssa.2026-11-04T01-22.md`. |
| 3. Type checking | N/A | PowerShell. |
| 4. Architecture-boundary tests | ✅ PASS | `ClaudeLibModuleConvention.Tests.ps1` 6 of 6, `enforcement-hooks-no-python-invocation.Tests.ps1` 33 of 33, `DocsWriteBoundary.Tests.ps1` 6 of 6 (reviewer). |
| 5. Unit tests | ✅ PASS (docs scope) | Reviewer docs-folder run 990 of 990. |
| 6. Contract / schema checks | ✅ PASS | `Docs.Manifest.Tests.ps1` and `DocsSchemaContract.Tests.ps1` in the reviewer run; push-down contract pytest 34 of 34 (reviewer). |
| 7. Integration tests | ✅ PASS | `DocsCompleteIntegration.Tests.ps1` 3 of 3 (reviewer). |

---

## 3. Language-Specific Code Change Policy Compliance

### 3B PowerShell

| Requirement | Status | Evidence |
|------------|--------|----------|
| Formatting / PSScriptAnalyzer | ✅ PASS | See 2.4. |
| Advanced functions (`[CmdletBinding()]`) | ✅ PASS | Every function in the new modules. |
| Parameter validation | ✅ PASS | `Mandatory`, `AllowNull`, `AllowEmptyCollection`, typed parameters; enumerations checked with `-cnotcontains`. |
| Approved verbs | ✅ PASS | `ConvertTo-`, `Copy-`, `Get-`, `Invoke-`, `Measure-`, `Merge-`, `New-`, `Read-`, `Test-`. |
| No global state | ✅ PASS | Read-only `$script:` constants only. |
| Suppressions justified | ✅ PASS | `PSUseShouldProcessForStateChangingFunctions` on `New-` factories with the spec's justification; `PSUseLiteralInitializerForHashtable` where an ordinal-comparer hashtable is required, with justification. |
| ShouldProcess for state-changing actions | ✅ PASS | Inspected by hand (PSScriptAnalyzer does not flag the `Invoke` verb). The new functions perform no I/O themselves; every write goes through the context member `WriteText`, which is the 1020 `Write-DocsContextText`/`Write-DocsFileText` pair declaring `SupportsShouldProcess` and gating the write with `$PSCmdlet.ShouldProcess` (`Invoke-DocsCommand.ps1` lines 240-249 and 330). |
| PowerShell 7 built-ins only (spec) | ✅ PASS | No new module dependency; no `ConvertFrom-Json` for artifacts in the new modules. |

### 3D JSON

| Requirement | Status | Evidence |
|------------|--------|----------|
| Strict JSON | ✅ PASS | `core.json` parsed by `Docs.Manifest.Tests.ps1` and the push-down pytest. |
| Manifest completeness | ✅ PASS | Ten lines, one per new module; no duplicate after the merge with 1021. |

Python, TypeScript, C#, Bash sections: N/A, zero changed files of those languages.

---

## 4. Language-Specific Unit Test Policy Compliance

### 4B PowerShell Unit Tests

| Requirement | Status | Evidence |
|------------|--------|----------|
| Pester v5 | ✅ PASS | `#Requires -Modules` Pester 5 in the new suites. |
| Location mirrors source | ✅ PASS | `tests/scripts/claude-lib/docs/` mirrors `.claude/lib/docs/`. |
| File naming `*.Tests.ps1` | ✅ PASS | 25 suites; support module `.psm1`. |
| Mocking used sparingly | ✅ PASS | No `Mock`; the recording context is the only seam. |
| PoshQC test command | ✅ PASS | Executor coverage runs used `Invoke-PoshQCTest`; the reviewer used `Invoke-Pester` with coverage off so the artifact was not modified further. |

---

## 5. Test Coverage Detail

See section 1.2.1. Spec criterion S32 names the `windows-latest` `poshqc / PowerShell QC` report as the source of the per-file figures, so the CI report on the PR head resolves both F1 and F2.

---

## 6. Test Execution Metrics

| Run | Tests | Passed | Failed | Source |
|---|---|---|---|---|
| Reviewer, `tests/scripts/claude-lib/docs` (48 suites) | 990 | 990 | 0 | this review |
| Reviewer, the 25 new 1023 suites (subset of the above) | 215 | 215 | 0 | this review |
| Reviewer, module-convention, no-Python-invocation and file-size gate suites | 44 | 44 | 0 | this review |
| Reviewer, push-down contract pytest | 34 | 34 | 0 | this review |
| Executor P7-T3, `tests/scripts` single process (Linux host) | 14333 | 13914 | 409 (6 errors), identical to baseline | `qa-pester-coverage.2026-11-04T01-51.md` |
| Executor shuffled runs, three seeds | per evidence | all | 0 | `isolation-shuffled-pester.2026-11-04T02-02.md` |

---

## 7. Code Quality Checks

- PSScriptAnalyzer: 0 findings over 48 files (reviewer).
- Formatter: 0 differences over 48 files (reviewer).
- File size: maximum 785 logical lines (two Warning rows); no file above 800; no baseline entry added.
- Bundle mirror: `git rev-parse HEAD:<path>` returns equal blob ids for all eleven source/bundle pairs.
- Tier: `.claude/lib/docs` is T3; no property-test density, mutation or golden-test obligation applies at T3, and the spec's own property-test requirement (S28) is met.

---

## Evidence Location Compliance

`poetry -C <worktree> run python scripts/dev_tools/validate_evidence_locations.py --root <worktree>` exited 0 with no output. The branch diff contains no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All evidence is under `<FEATURE>/evidence/{baseline,other,qa-gates,regression-testing}/`. No violation.

---

## 8. Gaps and Exceptions

1. **F1 Local coverage artifact does not describe the recorded run (blocking, awaiting_ci).** `artifacts/pester/powershell-coverage.xml` was rewritten at 2026-11-04T02:06Z by the five-test file-size gate run (P7 `qa-file-size`), after the full run recorded at 01:51Z. The coverage figures can only be read from evidence prose. Resolved by the per-file report of `poshqc / PowerShell QC` on `windows-latest` for the PR head.
2. **F2 CI-dependent acceptance criteria S32 and U23 (blocking, awaiting_ci).** No pull request and no CI run exist for head `1b160781a`.
3. **Warnings.** `DocsLedgerCommands.psm1` and its bundle copy at 785 logical lines (non-blocking).

No approved policy exception is claimed.

---

## 9. Summary of Changes

The branch adds the ledger, rules, parity, evidence-pin, staleness, receipt, validation, write-boundary, coverage-report and command modules, the three dispatch rows, the bundle copies and manifest lines, and 25 Pester suites with seeded property tests, an AST write-boundary proof and an end-to-end `docs-complete` integration suite.

---

## 10. Compliance Verdict

**AWAITING_CI.** No autonomous finding. F1 and F2 resolve through the `poshqc / PowerShell QC` coverage report on the PR head at S9.

---

## Appendix A: Test Inventory

Reviewer run at head `1b160781a` (`Invoke-Pester`, coverage off). New 1023 suites:

| Suite | Tests |
|---|---|
| `DocsCompleteIntegration.Tests.ps1` | 3 |
| `DocsCoverageReport.Properties.Tests.ps1` | 2 |
| `DocsCoverageReport.Tests.ps1` | 3 |
| `DocsEvidencePins.Properties.Tests.ps1` | 6 |
| `DocsEvidencePins.Tests.ps1` | 8 |
| `DocsLedger.Properties.Tests.ps1` | 9 |
| `DocsLedger.Tests.ps1` | 15 |
| `DocsLedger.TestSupport.Tests.ps1` | 8 |
| `DocsLedgerCommands.Properties.Tests.ps1` | 2 |
| `DocsLedgerCommands.Tests.ps1` | 21 |
| `DocsLedgerCommands.UpdateLedger.Tests.ps1` | 21 |
| `DocsLedgerCommands.Validate.Tests.ps1` | 11 |
| `DocsLedgerMutation.Properties.Tests.ps1` | 1 |
| `DocsLedgerMutation.Tests.ps1` | 8 |
| `DocsLedgerRules.Properties.Tests.ps1` | 2 |
| `DocsLedgerRules.Tests.ps1` | 13 |
| `DocsParity.Properties.Tests.ps1` | 12 |
| `DocsParity.Tests.ps1` | 18 |
| `DocsReceipt.Properties.Tests.ps1` | 6 |
| `DocsReceipt.Tests.ps1` | 12 |
| `DocsStaleness.Properties.Tests.ps1` | 3 |
| `DocsStaleness.Tests.ps1` | 6 |
| `DocsValidation.Properties.Tests.ps1` | 4 |
| `DocsValidation.Tests.ps1` | 15 |
| `DocsWriteBoundary.Tests.ps1` | 6 |
| Total (new) | 215 |

The remaining 23 suites of the docs folder (1020 and 1021, including `Docs.Manifest.Tests.ps1`) contributed 775 tests, all passing.

## Appendix B: Toolchain Commands Reference

- `pwsh -NoProfile -File <scratch>/pester-docs.ps1` (`Invoke-Pester` over `tests/scripts/claude-lib/docs`, coverage and JUnit off, per-container counts)
- `pwsh -NoProfile -File <scratch>/pester-gates.ps1` (`ClaudeLibModuleConvention.Tests.ps1`, `enforcement-hooks-no-python-invocation.Tests.ps1`, `FileSizePolicy.RepoGate.Tests.ps1`)
- `pwsh -NoProfile -File <scratch>/static.ps1` (per-file `Invoke-ScriptAnalyzer` and `Invoke-Formatter` comparison with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`, and `@(Get-Content -LiteralPath <path>).Count`, over the 48 changed `.ps1`/`.psm1` files)
- `pwsh -NoProfile -File <scratch>/cov.ps1 -Path artifacts/pester/powershell-coverage.xml` (JaCoCo root and sourcefile LINE counters and missed line numbers)
- `poetry -C <worktree> run pytest -q --no-cov -o addopts="" tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py`
- `git rev-parse HEAD:<path>` for each source/bundle pair
- `poetry -C <worktree> run python scripts/dev_tools/validate_evidence_locations.py --root <worktree>`
