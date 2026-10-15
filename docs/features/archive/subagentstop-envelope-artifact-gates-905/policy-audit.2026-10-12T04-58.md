# Policy Audit: subagentstop-envelope-artifact-gates (Issue #905)

- Timestamp: 2026-10-12T04-58
- Reviewer: feature-review agent
- Branch: `bug/subagentstop-envelope-artifact-gates-exec-905` (reviewed at local `exec905-r3`, HEAD `642050f82`)
- Base: `origin/epic/subagentstop-envelope-integration` (tip `3fd6958d9`; merge-base `ebf4504ae6f881c5b34b91082b3df474c04d13f2`)
- Diff command: `git diff origin/epic/subagentstop-envelope-integration...HEAD` (95 files; 18 commits in `git log origin/epic/subagentstop-envelope-integration..HEAD`)
- Work mode: `full-bug` (AC source: `spec.md` only)
- Policy reading order applied: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/powershell.md`, `.claude/rules/tonality.md`

## Executive Summary

The branch converts four SubagentStop validators (`validate-discovery-artifact-gate.ps1`, `validate-pr-author-output.ps1`, `validate-prd-feature-output.ps1`, `validate-task-researcher-output.ps1`) from the undocumented `CLAUDE_HOOK_INPUT`/`.output`/exit-1 transport to the E1 stdin envelope helper with exit-2 blocking, applies rule changes R1-R4, adds the #786 dependency guard to the task-researcher hook, syncs the four bundled mirrors byte-for-byte, and updates seven Pester suites plus one new suite.

The only changed code language is PowerShell. Every PowerShell policy gate verified in this audit passes: format clean, PSScriptAnalyzer zero findings, all targeted and registration suites pass (190 E3 suite tests, 786 registration-suite tests, 47 settings/allowlist tests, rerun by the reviewer), per-file line coverage 98.06% to 100.00%, changed-line coverage 100.00%, no file over 500 lines, no temporary files in tests, no policy file edited, no evidence written outside the canonical feature evidence tree.

Overall verdict: **PASS**. No Blocking finding. Non-blocking observations are listed in section 8 and in the code review.

## Rejected Scope Narrowing

No scope narrowing was detected in the caller prompt. The caller instruction to evaluate the file-scope half of AC-30 "against the integration branch diff" matches the authoritative base. The audit scope is the full three-dot diff against `origin/epic/subagentstop-envelope-integration`.

## Evidence Location Compliance

- Command: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` returned exit code 0 with no output.
- Branch-diff scan: `git diff --name-only origin/epic/subagentstop-envelope-integration...HEAD` lists no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All 78 evidence files are under `docs/features/active/subagentstop-envelope-artifact-gates-905/evidence/{baseline,other,qa-gates,regression-testing}/`.
- Verdict: PASS. No FAIL-level occurrence.

## 1. General Unit Test Policy Compliance

### 1.1 Core principles

| Principle | Verdict | Evidence |
|---|---|---|
| Independence | PASS | Each stdin-entry helper saves and restores `[Console]::In`, `[Console]::Error` and `$env:CLAUDE_HOOK_INPUT` in `finally` (for example `validate-task-researcher-output.Coverage.Tests.ps1:38-53`, `:87-93`). |
| Isolation | PASS | Rule tests target single functions (`Test-IsValidResearchFileName`, `Test-SpecNumericCriterion`, `Test-NumericDerivationEvidence`, `Find-DiscoveryArtifactReference`); entry tests mock `Test-Path`/`Get-Content` with exact-path filters. |
| Fast execution | PASS | 190 E3 suite tests ran in one Pester invocation; one subprocess case per hook only. |
| Determinism | PASS | No `Start-Sleep`, `Thread.Sleep`, or `Task.Delay` in the changed suites (reviewer grep, zero matches). |
| Readability | PASS | Arrange/Act/Assert comments in every new case; descriptive `It` names. |

### 1.2 Coverage requirements

- TypeScript baseline coverage artifact: N/A - no TypeScript file changed on the branch.
- TypeScript post-change coverage artifact: N/A - no TypeScript file changed on the branch.
- PowerShell baseline coverage artifact: `evidence/baseline/baseline-coverage-per-file.2026-10-11T15-01.md` and `evidence/baseline/baseline-full-pester.2026-10-11T15-00.md` (per-file 92.65%, 100.00%, 98.15%, 90.00%; repo command headline 88.67%).
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` from the executor worktree, preserved as a scratchpad copy whose SHA256 `C76CEB4E2F09054AD3E0A33A00369FCB2877C61A870E49B8203765C503421C58` equals the value recorded in `evidence/qa-gates/final-full-pester.2026-10-11T23-57.md`; parsed independently by the reviewer (JaCoCo LINE counters).
- Per-language comparison summary: PowerShell is the only coverage language with changed files; every changed hook is at or above 85% line coverage, no file regressed, and changed lines are 100.00% covered. Python, TypeScript and C# have zero changed files.

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---|---|---|---|---|---|
| PowerShell | 4 hooks, 4 mirrors, 7 suites (1 new) | 190 E3 suite tests | 190 passed, 0 failed | 88.67% repo command headline; hooks 92.65%, 100.00%, 98.15%, 90.00% | 89.35% repo line (88.28% command); hooks 100.00%, 100.00%, 100.00%, 98.06% | 100.00% changed lines (61/61) |
| Python | 0 | 0 | N/A | N/A | N/A | N/A |
| TypeScript | 0 | 0 | N/A | N/A | N/A | N/A |
| C# | 0 | 0 | N/A | N/A | N/A | N/A |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 92.65% discovery, 100.00% pr-author, 98.15% prd-feature, 90.00% task-researcher (repo command headline 88.67%). Post-change: 100.00% discovery, 100.00% pr-author, 100.00% prd-feature, 98.06% task-researcher (repo line 89.35%). Change: every hook equal or higher; no regression on any file or on changed lines. New/changed-code coverage: 100.00% (discovery 12/12, pr-author 10/10, prd-feature 23/23, task-researcher 16/16). Disposition: PASS. Evidence: `evidence/qa-gates/final-coverage-per-file.2026-10-12T00-10.md`, `evidence/qa-gates/final-changed-line-coverage.2026-10-12T00-10.md`, `evidence/qa-gates/coverage-delta.2026-10-12T00-11.md`, reviewer parse of the hash-verified XML copy.

### 1.2.2 Coverage Verdict per Language

Coverage verdict per language with changed files:

- PowerShell: **PASS**. Repo-wide line 89.35% (>= 85%). New file (none among production files; the new file is a test suite). Modified hooks all >= 85% and none regressed. Branch threshold does not apply to PowerShell (Pester measures line and command coverage only, per `.claude/rules/powershell.md`).
- Python, TypeScript, C#: no changed files; no verdict required.

### 1.3 Coverage exclusion policy

PASS. The branch adds no coverage `exclude` entry. All four hooks appear in the coverage XML (`SOURCEFILE_MATCHES: 1` each).

### 1.4 Test location and temporary files

- Location: PASS. All suites are under `tests/scripts/claude-hooks/`, mirroring `.claude/hooks/`.
- Temporary files: PASS. Reviewer grep for `New-TemporaryFile|GetTempFileName|TestDrive|GetTempPath|Out-File|Set-Content|New-Item` over the seven changed suites returned no match.

## 2. General Code Change Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Simplicity | PASS | Each hook tail is three statements; rule changes are single-regex or single-condition edits. |
| Reusability | PASS with observation | Envelope parsing reuses the E1 helper. Test builder `New-SubagentStopEnvelopeJson` is duplicated in seven suites (code review NB-4). |
| Separation of concerns | PASS | Pure entry functions take `-InputText`; stdin is read only when the parameter is unbound. |
| Error handling | PASS | `Get-Content` reads in prd-feature and task-researcher are wrapped and mapped to block results; no `Write-Error` or `exit 1` remains on any block path (reviewer grep, zero matches in hooks and mirrors). |
| File size <= 500 lines | PASS | Largest changed file 418 lines (`validate-task-researcher-output.Tests.ps1`); hooks 118-290 lines. |
| Public API compatibility | PASS | Parameter renames (`-RawPayload`/`-HookInputRaw` to `-InputText`) have in-repo callers only in hook tails and suites, all updated. |
| Dependencies | PASS | No new dependency; E1 helper is an in-repo file. |
| I/O boundaries | PASS | Filesystem reads remain behind `Test-ResearchFile`, `Test-Path` and `Get-Content`, mocked in tests. |
| Toolchain loop | PASS | `evidence/qa-gates/final-loop-status.2026-10-12T00-15.md` records two passes; pass 2 clean with hash-stable inputs (15 LOOP-HASH lines, 0 mismatches). |

## 3. Language-Specific Code Change Policy Compliance

PowerShell (`.claude/rules/powershell.md`):

| Requirement | Verdict | Evidence |
|---|---|---|
| PowerShell 7+ compatibility | PASS | PSScriptAnalyzer with repo settings reported zero findings (reviewer run). |
| Advanced functions, `CmdletBinding` | PASS | All changed functions keep `[CmdletBinding()]`; new parameters declare `[AllowNull()] [AllowEmptyString()]`. |
| No `Invoke-Expression`, no hard-coded credentials | PASS | Not present in the diff. |
| Avoid silent catch-alls | PASS | New `try/catch` blocks return explicit block results with the exception message. |
| Under 500 lines | PASS | See section 2. |
| Change budget | PASS | Four production PowerShell files changed through the orchestrated large path (plan `plan.2026-10-11T07-59.md`, 161 of 161 tasks checked). |
| No Python in enforcement hooks | PASS | `enforcement-hooks-no-python-invocation.Tests.ps1` 32/32 passed (reviewer run); no `.py` file in the hooks diff. |

## 4. Language-Specific Unit Test Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Pester v5, `*.Tests.ps1` naming | PASS | All suites follow the naming convention. |
| One behavior per `It` | PASS | Data-driven `-ForEach` cases enumerate one input per case. |
| Mock sparingly, wrapper seams | PASS | `Invoke-DiscoveryValidatorExe` is mocked as the wrapper seam; no executable is mocked directly. |
| Scenario completeness | PASS | Positive, negative, anomaly, re-entry (`stop_hook_active`), read-failure, helper-load-failure, and subprocess cases exist for each hook. |
| Suppressions | PASS with observation | Seven `PSUseShouldProcessForStateChangingFunctions` suppressions on test builders, each with a justification and a cited repository precedent (`deviations.md`, [P12-T3]); code review NB-4 recommends a verb that does not require suppression. |

## 5. Test Coverage Detail

| File | Baseline | Post-change | Changed lines | Uncovered lines (post-change) |
|---|---|---|---|---|
| `.claude/hooks/validate-discovery-artifact-gate.ps1` | 92.65% | 100.00% (63/63) | 12/12 | none |
| `.claude/hooks/validate-pr-author-output.ps1` | 100.00% | 100.00% (32/32) | 10/10 | none |
| `.claude/hooks/validate-prd-feature-output.ps1` | 98.15% | 100.00% (65/65) | 23/23 | none |
| `.claude/hooks/validate-task-researcher-output.ps1` | 90.00% | 98.06% (101/103) | 16/16 | 216, 275 (both unchanged lines) |

## 6. Test Execution Metrics

| Run | Scope | Result | Source |
|---|---|---|---|
| Reviewer Pester run 1 | 8 E3 suites plus guard-completeness and no-python suites | 820 passed, 0 failed | Reviewer run, 2026-10-12 |
| Reviewer Pester run 2 | `hook-dependency-failure.Claude`, `.SpecialCases`, guard-completeness, no-python | 786 passed, 0 failed | Reviewer run, 2026-10-12 |
| Reviewer Pester run 3 | `enforce-pr-author-command-allowlist`, `claude-settings` | 47 passed, 0 failed | Reviewer run, 2026-10-12 |
| Reviewer pytest | planning-integrity, resource contracts, pack manifest completeness | 22 passed | Reviewer run, 2026-10-12 |
| Executor full Pester | whole repository | 9977 passed, 0 failed, 10 skipped | `evidence/qa-gates/final-full-pester.2026-10-11T23-57.md` |

## 7. Code Quality Checks

| Check | Result | Source |
|---|---|---|
| Format (`Invoke-Formatter`, repo settings) | 11 of 11 changed files unchanged by the formatter | Reviewer run |
| Lint (PSScriptAnalyzer, repo settings) | 0 findings | Reviewer run; `evidence/qa-gates/final-lint.2026-10-11T23-41.md` |
| Type check | Not applicable to PowerShell | `.claude/rules/powershell.md` |
| Mirror parity | 4 of 4 source/mirror pairs equal under SHA256 | Reviewer `sha256sum`; `evidence/qa-gates/final-mirror-parity.2026-10-12T00-12.md` |
| Policy files | No path under `.claude/rules/`, `.github/instructions/`, `.github/copilot-instructions.md` in the diff | Reviewer diff scan |

## 8. Gaps and Exceptions

- Coverage artifact locality: the canonical `artifacts/pester/powershell-coverage.xml` is not present in this review worktree (it is gitignored and was produced in the executor worktree). The reviewer located the executor's preserved copy, confirmed its SHA256 equals the value recorded at copy time, and parsed it. This satisfies the inspect-existing-artifacts model; no coverage was regenerated.
- AC-30 PR-body half cannot be evaluated until the child PR exists. The file-scope half passes (see feature audit).
- Non-blocking observations (detailed in `code-review.2026-10-12T04-58.md`): R3 and R4 negative-boundary test depth, R3 residual breadth for whole-worktree scopes that enumerate a narrower covered set, duplicated test builder with suppressions, redundant alias in the task-researcher entry function, uncaught exceptions still exit 1 (fail-open) in all four hooks, and the behavior-preserving `$validatorResult` indexer edit in the discovery hook.

## 9. Summary of Changes

- Four hooks read the SubagentStop envelope from stdin through `Read-SubagentStopEnvelope`, inspect `AssistantText`, and block through `Exit-SubagentStopBlock` (stderr, exit 2).
- R1: task-researcher filename regex widened to the established stamped forms.
- R2: prd-feature numeric-criterion rule narrowed to determiner-led cardinal counts with a policy-citation exclusion.
- R3: `Exhaustive Search Scope` pattern gains `whole` and `worktree` in both hooks.
- R4: `Find-DiscoveryArtifactReference` skips tokens that are empty after trimming.
- Task-researcher hook gains the #786 guard bootstrap, guarded helper edge, dependency tail and leading dependency-decision statement.
- Mirrors synced; seven suites updated; `validate-task-researcher-output.Coverage.Tests.ps1` added.

## 10. Compliance Verdict

**PASS.** Blocking findings: 0. PowerShell coverage: PASS. Evidence locations: PASS. Policy files untouched: PASS. Toolchain: PASS.

## Appendix A: Test Inventory

| Suite | Tests (reviewer run) | Result |
|---|---|---|
| `validate-discovery-artifact-gate.Tests.ps1` | 25 | Passed |
| `validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1` | 4 | Passed (unchanged file) |
| `validate-pr-author-output.Tests.ps1` | 13 | Passed |
| `validate-pr-author-output.Coverage.Tests.ps1` | 8 | Passed |
| `validate-prd-feature-output.Tests.ps1` | 42 | Passed |
| `validate-prd-feature-output.Coverage.Tests.ps1` | 12 | Passed |
| `validate-task-researcher-output.Tests.ps1` | 34 | Passed |
| `validate-task-researcher-output.Coverage.Tests.ps1` (new) | 52 | Passed |
| `hook-dependency-failure.Claude.Tests.ps1` | 143 | Passed |
| `hook-dependency-failure.SpecialCases.Tests.ps1` | 13 | Passed |
| `hook-dependency-guard-completeness.Tests.ps1` | 598 | Passed |
| `enforcement-hooks-no-python-invocation.Tests.ps1` | 32 | Passed |
| `enforce-pr-author-command-allowlist.Tests.ps1` | 38 | Passed |
| `claude-settings.Tests.ps1` | 9 | Passed |

## Appendix B: Toolchain Commands Reference

- Pester (no coverage, no result files): `Invoke-Pester -Configuration $config` with `Run.Path` set to the suites above, run through `pwsh -NoProfile -File <scratchpad>/rev905_pester.ps1`.
- Lint and format check: `Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` and `Invoke-Formatter -ScriptDefinition <text> -Settings <same>` compared to the file text, through `<scratchpad>/rev905_lint.ps1`.
- Coverage parse: `poetry run python -I <scratchpad>/rev905_cov.py <scratchpad>/final-powershell-coverage.xml` (JaCoCo LINE and INSTRUCTION counters).
- Static scans: `<scratchpad>/rev905_checks.sh` (mirror SHA256, AC-20/21/22/23 greps, out-of-scope path scan, `.py` scan).
- Gate ordering: `<scratchpad>/order.sh` (`git show <commit>:<path>` for each conversion, parent-of-switch, and switch commit).
- pytest: `poetry run pytest tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py -q`.
- Evidence locations: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`.
