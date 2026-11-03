# Policy Compliance Audit: Documentation profile and artifact schemas (#1020)

**Audit Date:** 2026-11-03
**Reviewer:** feature-review agent
**Audit Type:** Re-audit after remediation cycle 1 (prior review `policy-audit.2026-11-03T20-22.md`, verdict REMEDIATION_REQUIRED)
**Feature Folder:** `docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020`
**Base Branch:** `origin/epic/documentation-estate-tooling-integration` (tip `5e535f7a6`, unchanged since the prior review)
**Head Branch:** `feature/docs-profile-and-artifact-schemas-1020-r2` (head `a3ae4c51d`, equal to the remote branch head; working tree clean; no pull request exists yet)
**Merge bases:** `git merge-base --all` returns `01706c697` and `340627583`. As in the prior review, the item diff is the two-dot diff from the epic tip to HEAD.

**Code Under Test (item change set, 128 paths in `git diff origin/epic/documentation-estate-tooling-integration HEAD`):**

- The 108 paths of the prior review, plus 20 feature-folder Markdown files added by the cycle (prior review artifacts, remediation inputs and plan, and 15 evidence files).
- Cycle code changes (`git diff --name-only 71217a14e HEAD`, excluding `docs/`): `.claude/lib/docs/Invoke-DocsCommand.ps1`, its bundle mirror `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/Invoke-DocsCommand.ps1`, `tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1`, `tests/scripts/claude-lib/docs/DocsSchema.Tests.ps1`.
- Branch totals outside the feature folder by extension: 18 `.psm1`, 14 `.ps1`, 32 `.json`, 1 `.yml`, 1 `.md` (`epic-status.md`, present on the epic tip and never touched by HEAD).

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 9 production (+9 mirror), 14 test files | 385 docs tests | 385 pass, 0 fail (reviewer re-run); claude-lib run 3786, 0 fail (executor, JUnit confirmed) | 93.62% lines (P0-T6, other host) | 92.66% lines (derived: P6-T6 full-tree 21911 of 23650 plus the cycle delta of +3 covered, +1 line) | 87.33% minimum per file (Invoke-DocsCommand.ps1, 131 of 150); 97.80% aggregate (932 of 953) |
| JSON | 32 new, 1 modified | N/A | contract pytest 34 of 34 pass | N/A (config and schema files; no coverage tool) | N/A (config and schema files) | N/A |
| YAML | 1 modified | N/A | unchanged by the cycle; check_quality_tiers exit 0 in the prior review | N/A (config file) | N/A (config file) | N/A |

Python, TypeScript, C#, and Bash: zero changed files on the branch (verified against the diff list), so no coverage row applies.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope (zero TypeScript files changed)
- TypeScript post-change coverage artifact: N/A - out of scope (zero TypeScript files changed)
- PowerShell baseline coverage artifact: `evidence/baseline/baseline-pester-coverage.2026-11-03T12-09.md` (branch baseline, 93.62%); cycle baseline `evidence/remediation-baseline/baseline-pester-coverage.2026-11-03T20-39.md` (Invoke-DocsCommand.ps1 85.91%)
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (JaCoCo, written 2026-11-03T20:49Z by the cycle P2-T3 `Invoke-PoshQCTest -ScanFolders tests/scripts/claude-lib` run), summarized in `evidence/qa-gates/qa-pester-coverage.2026-11-03T20-49.md`
- Per-language comparison summary: section 1.2.1 of this audit

Assumption on the repo-wide figure: the present artifact records a claude-lib-scoped run, so its root LINE counter (7796 covered of 23651, 32.96%) counts every production file under the coverage roots but executes only the claude-lib suites. It is not a repo-wide measurement. The last full-tree measurement is the P6-T6 artifact parsed in the prior review (21911 of 23650, 92.65%). The cycle changed one production file, adding one line and three covered lines (the denominator 23651 in the present artifact confirms the +1), and changed no test outside the docs suites, so the repo-wide figure is derived as 21914 of 23651, 92.66%. The full-tree run itself is the CI-dependent item F2.

---

## Executive Summary

Remediation cycle 1 addressed F1 (ShouldProcess) and N2 (console noise from a mock). The reviewer verified both against the source and by re-running checks: `Write-DocsFileText` and `Write-DocsContextText` now declare `SupportsShouldProcess`, the directory creation and stream write are gated by `$PSCmdlet.ShouldProcess`, the inert suppression is removed, and two new tests drive the real primitive and the real `WriteText` member under `-WhatIf`. The bundle mirror is byte-identical (`cmp` and `diff -r`). `Invoke-DocsCommand.ps1` line coverage is 87.33% (131 of 150), parsed directly from the coverage artifact, with the 19 missed lines attributed to `Invoke-DocsProcess` (16) and the guarded body of `Write-DocsFileText` (3). Reviewer re-runs: docs Pester 385 of 385 with no `The value does not match` console output, PSScriptAnalyzer 0 findings and Invoke-Formatter 0 differences over 23 files, gate suites 52 of 52, push-down contract pytest 34 of 34, `validate_evidence_locations.py` exit 0.

Findings: no autonomous blocking finding remains. Two blocking items carry forward unchanged as `awaiting_ci`: the P6-T6 full-tree run on this host (F2) and the CI-dependent acceptance criteria S26 and U14 (F3). Overall verdict: AWAITING_CI.

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md` / `general-code-change.instructions.md`
- ✅ `.claude/rules/general-unit-test.md` / `general-unit-test.instructions.md`
- ✅ `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists, so tiers are adopted)

**Language-specific policies evaluated:**
- N/A `python-code-change.instructions.md` + `python-unit-test.instructions.md` (no Python file changed)
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (ShouldProcess now PASS)
- N/A Bash: no shell file changed
- ✅ JSON: unchanged by the cycle; the non-blocking key-order observation (N1) stands and was not adopted by the orchestrator

**Temporary artifacts cleanup:**
- ✅ No temporary or one-time script is committed; the executor's helper scripts and shuffle files lived under its scratch directory
- ✅ The `-WhatIf` tests left no directory behind: `artifacts/docs-whatif-never-created` does not exist after the reviewer run

---

## Rejected Scope Narrowing

No scope narrowing was detected in the caller prompt. The prompt directs the reviewer to use the same diff scope as the prior review (the two-dot diff from the epic tip to HEAD), which is the full item diff, and lists items to verify without excluding any language or file. The audit covers all 128 paths.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | ✅ PASS | Cycle: three seeded shuffled file-order runs of the four touched suites (seeds 101, 202, 303), 112 of 112 each (`evidence/regression-testing/isolation-shuffled-remediation.2026-11-03T20-51.md`). Branch: seeds 1020, 20261030, 7 in `isolation-shuffled.2026-11-03T18-50.md`. The new tests set `$WhatIfPreference` only inside their own scriptblock. |
| **Isolation** | ✅ PASS | Each new `It` exercises one behavior (direct primitive call, context member call). |
| **Fast Execution** | ✅ PASS | Reviewer docs run: 385 tests in 23.4 s. |
| **Determinism** | ✅ PASS | New tests use fixed path strings and no clock, RNG, timer, or process. |
| **Readability & Maintainability** | ✅ PASS | Arrange/Act/Assert comments and `-Because` messages; the file header describes the `-WhatIf` coverage. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Baseline coverage documented | ✅ PASS | Branch baseline 93.62% (P0-T6); cycle baseline 85.91% for Invoke-DocsCommand.ps1 (`remediation-baseline/baseline-pester-coverage.2026-11-03T20-39.md`). |
| No coverage regression on changed lines | ✅ PASS | Cycle changed lines: line 245 (gate) covered; lines 246-248 are the three body statements that were uncovered at baseline (re-indented, not newly uncovered). No other production line changed. |
| New-file line coverage >= 85% | ✅ PASS | Nine files 87.33% to 100% (reviewer parse of the artifact). |
| Repo-wide line coverage >= 85% | ✅ PASS | 92.66% derived (see the assumption under the Coverage Evidence Checklist). |
| Branch coverage | N/A | Pester measures no branch coverage; no branch threshold applies to PowerShell. |
| Coverage exclusions | ✅ PASS | `config/poshqc-coverage.json` is not in the branch diff; no docs file excluded. |
| Positive, negative, edge, error flows | ✅ PASS | The new tests add the `-WhatIf` negative-write path; existing create-refusal and path-rejection tests unchanged and passing. |
| Concurrency / state transitions | N/A | No concurrent or stateful component. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 93.62% (P0-T6, earlier host). Post-change: 92.66% (derived from the P6-T6 full-tree artifact plus the cycle delta). Change: -0.96 points overall; the decrease is in pre-existing scripts whose suites fail on this host on the unchanged merge base (F2), and the cycle itself raised Invoke-DocsCommand.ps1 from 85.91% to 87.33%. Disposition: PASS. New/changed-code coverage: 87.33% minimum per file (Invoke-DocsCommand.ps1 131 of 150), 97.80% aggregate. Evidence: `artifacts/pester/powershell-coverage.xml` parsed per sourcefile by the reviewer; `evidence/qa-gates/qa-pester-coverage.2026-11-03T20-49.md`; `evidence/qa-gates/coverage-delta.2026-11-03T20-06.md`.

Per-file line coverage (reviewer parse of the artifact written at 20:49Z):

| File | Covered / Missed | Line % |
|---|---|---|
| `.claude/lib/docs/DocsAnalyzerRegistry.psm1` | 119 / 0 | 100% |
| `.claude/lib/docs/DocsFinding.psm1` | 88 / 0 | 100% |
| `.claude/lib/docs/DocsJson.psm1` | 102 / 0 | 100% |
| `.claude/lib/docs/DocsProfile.psm1` | 81 / 0 | 100% |
| `.claude/lib/docs/DocsProfileCommands.psm1` | 67 / 2 | 97.1% |
| `.claude/lib/docs/DocsSchema.psm1` | 127 / 0 | 100% |
| `.claude/lib/docs/DocsSchemaWalk.psm1` | 87 / 0 | 100% |
| `.claude/lib/docs/DocsSurface.psm1` | 130 / 0 | 100% |
| `.claude/lib/docs/Invoke-DocsCommand.ps1` | 131 / 19 | 87.33% |

Missed-line attribution for `Invoke-DocsCommand.ps1` (reviewer parse of the `line` elements): lines 207 and 209-223 lie in `Invoke-DocsProcess` (16 lines, budget at most 20); lines 246-248 are the guarded body of `Write-DocsFileText` (3 lines, budget at most 6). This matches the executor's attribution in `qa-pester-coverage.2026-11-03T20-49.md` exactly.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| Arrange-Act-Assert | ✅ PASS | New tests carry the three sections. |
| Clear failure messages | ✅ PASS | `-Because` texts name the gate. |
| Clean test output | ✅ PASS | N2 resolved: the `Test-Json` mock passes `-ErrorAction SilentlyContinue` to `Write-Error`; the reviewer run output contains no `The value does not match` text, and the test still asserts code and pointer. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| No external services | ✅ PASS | No network or process in the new tests. |
| No temporary files | ✅ PASS | The new tests create nothing when the gate is present; the executor's gate-removal check (`whatif-gate-removal-check.2026-11-03T20-41.md`) shows both tests fail when the gate is removed. Token search for temp-file APIs remains clean. |
| No mutable global state | ✅ PASS | `$WhatIfPreference` is assigned inside the asserted scriptblock only and is not visible after it. |

---

## 2. General Code Change Policy Compliance

### 2.1 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Simplicity first | ✅ PASS | One gate in the single write primitive; the context function only declares the capability and forwards. |
| Reusability | ✅ PASS | No duplicated write logic. |
| Extensibility | ✅ PASS | Callers that pass `-WhatIf` or `-Confirm` now get standard behavior. |
| Separation of concerns | ✅ PASS | I/O remains confined to the entry script's context members. |

### 2.2 Module and File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| At or below the 800-line hard limit | ✅ PASS | Largest covered file 465 logical lines (`Invoke-DocsCommand.Tests.ps1`); production maximum 462 (`Invoke-DocsCommand.ps1`); no file at or above 700; `config/file-size-baseline.json` not in the diff. |
| Spec 500-line limit for `.claude/lib/docs/` | ✅ PASS | Maximum 462. |
| Explicit exports | ✅ PASS | Unchanged. |

### 2.3 Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| Fail fast, no silent catch | ✅ PASS | No catch added; under `-WhatIf` the primitive returns without I/O and without error, which is the standard ShouldProcess contract. |

### 2.4 Toolchain Execution

| Step | Status | Evidence |
|------|--------|----------|
| 1. Formatting | ✅ PASS | Reviewer `Invoke-Formatter` over 23 files: 0 differences. |
| 2. Linting | ✅ PASS | Reviewer `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1`: 23 files, 0 findings. |
| 3. Type checking | N/A | PowerShell. |
| 4. Architecture-boundary tests | ✅ PASS | Reviewer run: `ClaudeLibModuleConvention`, `enforcement-hooks-no-python-invocation`, `enforcement-hooks-checkpoint-path-explicit`, `FileSizePolicy.RepoGate`: 52 of 52. |
| 5. Unit tests | ✅ PASS (docs and claude-lib scope) | Reviewer docs run 385 of 385; executor claude-lib run 3786, 0 failures (JUnit header on disk confirms `tests="3786" failures="0" errors="0"`); full-tree status is F2. |
| 6. Contract / schema checks | ✅ PASS | `DocsSchemaContract.Tests.ps1` passes in the docs run; push-down contract pytest (resource contracts, pack-manifest completeness, dependency closure) 34 passed. |
| 7. Integration tests | N/A | No integration suite applies to this library. |

---

## 3. Language-Specific Code Change Policy Compliance

### 3B PowerShell

| Requirement | Status | Evidence |
|------------|--------|----------|
| Formatting / PSScriptAnalyzer | ✅ PASS | See 2.4. |
| Advanced functions (`[CmdletBinding()]`) | ✅ PASS | Present on every function. |
| Parameter validation | ✅ PASS | Unchanged. |
| Approved verbs | ✅ PASS | No function added or renamed. |
| No global state | ✅ PASS | Unchanged. |
| Suppressions justified | ✅ PASS | The inert `PSUseShouldProcessForStateChangingFunctions` suppression on `Write-DocsContextText` is removed; the token now appears once in the file, on `New-DocsCommandContext` (in-memory factory). |
| **ShouldProcess for state-changing actions** | ✅ PASS | F1 resolved. `.claude/rules/powershell.md` line 30 requires ShouldProcess/SupportsShouldProcess for state-changing actions. `Invoke-DocsCommand.ps1` line 236: `Write-DocsFileText` declares `[CmdletBinding(SupportsShouldProcess = $true)]`; line 245 gates the directory creation (line 246) and the stream write (lines 247-248) with `$PSCmdlet.ShouldProcess($FullPath, "Write file ($Mode)")`. Line 326: `Write-DocsContextText` declares `SupportsShouldProcess = $true`, so `-WhatIf`/`-Confirm` set its preference variables and reach the primitive by inheritance. The `init` dry-run default and the `-Write`/`-Force` opt-ins are unchanged (`DocsProfileCommands.Tests.ps1` 22 of 22). Verified by source inspection, the two new tests, and the executor's gate-removal check (2 failures with the gate replaced by a constant true). |

Python, TypeScript, C#, Bash sections: N/A, zero changed files of those languages.

---

## 4. Language-Specific Unit Test Policy Compliance

### 4B PowerShell Unit Tests

| Requirement | Status | Evidence |
|------------|--------|----------|
| Pester v5 | ✅ PASS | Pester 5 configuration API used by the reviewer run. |
| Location mirrors source | ✅ PASS | New tests are in `tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1`. |
| File naming `*.Tests.ps1` | ✅ PASS | Unchanged. |
| Mocking used sparingly | ✅ PASS | The new tests do not mock the function under test. |
| PoshQC test command | ✅ PASS | Executor runs used `Invoke-PoshQCTest`; the reviewer used `Invoke-Pester` without coverage output so the coverage artifact was not overwritten. |

---

## 5. Test Coverage Detail

See section 1.2.1. The two missed lines of `DocsProfileCommands.psm1` are the defensive `DOCS_CLI_RUNTIME` exit 3 returns in `Invoke-DocsInitCommand`, unchanged from the prior review.

---

## 6. Test Execution Metrics

| Run | Tests | Passed | Failed | Source |
|---|---|---|---|---|
| Reviewer, `tests/scripts/claude-lib/docs` | 385 | 385 | 0 | this review |
| Reviewer, four gate suites | 52 | 52 | 0 | this review |
| Reviewer, push-down contract pytest | 34 | 34 | 0 | this review |
| Executor cycle P2-T3, `tests/scripts/claude-lib` | 3786 | 3785 | 0 (1 disabled) | `qa-pester-coverage.2026-11-03T20-49.md`; JUnit on disk |
| Executor P6-T6, `tests/scripts` (this host, pre-cycle) | 14106 | 13687 | 409 (6 errors) | `isolation-single-process.2026-11-03T20-06.md` (F2) |

---

## 7. Code Quality Checks

- PSScriptAnalyzer: 0 findings over 23 files (reviewer).
- Formatter: 0 differences (reviewer).
- File size: maximum 465 logical lines; no Warning-tier file.
- Bundle mirror: `cmp` of `Invoke-DocsCommand.ps1` against its bundle copy reports identical; `diff -r` of `.claude/lib/docs` against the bundle copy reports no difference.

### Cycle evidence field and stamp check

All fifteen evidence files added by `19643663a` carry a `Timestamp:` field equal to their filename stamp. Every command artifact carries `Command:`, `EXIT_CODE:`, and `Output Summary:`; `phase0-instructions-read.2026-11-03T20-31.md` is a reading record and carries `Timestamp:`, `Policy Order:`, and `Output Summary:` as its plan task requires. The stamps are in plan order (20-31 to 20-51), and the 20-49 stamp of the coverage record agrees with the on-disk modification time of `artifacts/pester/powershell-coverage.xml` (20:49:03Z) and `pester-junit.xml` (20:49:07Z). No mismatch was found.

---

## Evidence Location Compliance

`python3 -I scripts/dev_tools/validate_evidence_locations.py --root <worktree>` exited 0 with no output. The branch diff contains no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All cycle evidence is under `<FEATURE>/evidence/{baseline,other,qa-gates,regression-testing,remediation-baseline}/`. No violation.

---

## 8. Gaps and Exceptions

1. **F1 ShouldProcess.** Resolved (section 3B).
2. **N2 console noise.** Resolved (section 1.3).
3. **F2 P6-T6 single-process `tests/scripts` run (blocking, awaiting_ci).** Carried forward. No new evidence: no pull request exists and no CI run has occurred for head `a3ae4c51d`. The cycle touched only the docs files, so the host-dependent failure set recorded at `71217a14e` is not affected. Resolution: `poshqc / PowerShell QC` on `windows-latest` for the PR head.
4. **F3 CI-dependent acceptance criteria S26 and U14 (blocking, awaiting_ci).** Carried forward; no PR and no CI run yet.
5. **N1 example key order (non-blocking, Minor).** Unchanged; not adopted by the orchestrator.

No approved policy exception is claimed.

---

## 9. Summary of Changes

Cycle 1 added ShouldProcess support to the docs write primitive and its context forwarder, removed an inert suppression, added two `-WhatIf` tests, re-synced the bundle mirror, and silenced a test mock's console output.

---

## 10. Compliance Verdict

**AWAITING_CI.** F1 and N2 are resolved and no autonomous finding remains. Two blocking items (F2, F3) resolve only through CI on the PR head.

---

## Appendix A: Test Inventory

| Suite | Tests |
|---|---|
| `Docs.Manifest.Tests.ps1` | 7 |
| `DocsAnalyzerRegistry.Tests.ps1` | 30 |
| `DocsFinding.Tests.ps1` | 30 |
| `DocsJson.Tests.ps1` | 27 |
| `DocsNeutrality.Tests.ps1` | 35 |
| `DocsProfile.Tests.ps1` | 24 |
| `DocsProfileCommands.Tests.ps1` | 22 |
| `DocsSchema.Tests.ps1` | 37 |
| `DocsSchemaContract.Tests.ps1` | 49 |
| `DocsSchemaWalk.Tests.ps1` | 12 |
| `DocsSurface.Tests.ps1` | 66 |
| `Invoke-DocsCommand.Tests.ps1` | 46 (44 before the cycle, plus 2 `-WhatIf` tests) |
| Total | 385 |

## Appendix B: Toolchain Commands Reference

- `pwsh -NoProfile -File <scratch>/review.ps1` (per-file `Invoke-ScriptAnalyzer` and `Invoke-Formatter` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`, logical line counts with `@(Get-Content -LiteralPath <path>).Count`, `Invoke-Pester` over `tests/scripts/claude-lib/docs` without coverage)
- `pwsh -NoProfile -File <scratch>/gates.ps1` (`Invoke-Pester` over the four gate suites)
- `poetry run pytest -q --no-cov -o addopts="" tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py`
- `python3 -I <scratch>/cov.py artifacts/pester/powershell-coverage.xml` (JaCoCo sourcefile LINE counters and missed `line` elements)
- `cmp` and `diff -r` of `.claude/lib/docs` against the bundle copy
- `python3 -I scripts/dev_tools/validate_evidence_locations.py --root <worktree>`
- `python3 -m scripts.dev_tools.pr_context.collector --base origin/epic/documentation-estate-tooling-integration --no-untracked` (regenerated at 20:57Z; head `a3ae4c51d`, base `5e535f7a6`)
