# Policy Compliance Audit: Platform-independent Pester fixtures (Issue #1067)

**Audit Date:** 2026-11-04
**Reviewer:** feature-review agent
**Scope:** Entire feature branch `bug/pester-fixtures-platform-independent` versus `main`; merge base 11f188d1b4f3726d854ddc00f8ad4c810138f049; reviewed head 7c31fb1d21431dd8d0961f32c30baae50bc70d74. Re-audit after remediation cycle 1 (findings R1-F1, R1-F2, R1-F4, R1-F5 of `remediation-inputs.2026-11-04T15-31.md`).
**Template provenance:** Structure follows the previous audit `policy-audit.2026-11-04T15-30.md`, which follows the bundled repository policy-audit template. Usage instructions and placeholders removed.
**Evidence roots:** Paths beginning `evidence/` are relative to this feature folder. COV-FINAL=evidence/qa-gates/coverage-final.2026-11-04T14-46.md; COV-DELTA=evidence/qa-gates/coverage-delta.2026-11-04T14-46.md; COV-BASE=evidence/baseline/coverage-baseline.2026-11-04T03-57.md; PAR=evidence/regression-testing/isolation-parallel.2026-11-04T16-10.md; SHUF=evidence/regression-testing/isolation-shuffle.2026-11-04T16-03.md; TWO=evidence/regression-testing/two-trees.2026-11-04T16-03.md; DEV=evidence/other/execution-deviations.2026-11-04T16-02.md.

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---|---|---|---|---|---|
| PowerShell | 5 production (4 sources, 1 bundle mirror); 19 test suites | 953 in the two trees at HEAD (reviewer run); 14,172 in the concurrent-shard run (PAR) | PASS; 0 failures | Four changed files 177/201 = 88.06% line (per file 92.45%, 96.88%, 65.79%, 89.13%) | Four changed files 191/201 = 95.02% line; repo-wide 22,462/23,936 = 93.84% line | 7 of 7 changed executable lines covered = 100% |
| Markdown | Feature-folder documents and evidence only | N/A - documentation | N/A - documentation | N/A - no executable code | N/A - no executable code | N/A - no executable code |
| Python | 0 | N/A - zero changed Python files | N/A - zero changed files | N/A - zero changed files | N/A - zero changed files | N/A - zero changed files |
| TypeScript | 0 | N/A - zero changed TypeScript files | N/A - zero changed files | N/A - zero changed files | N/A - zero changed files | N/A - zero changed files |
| C# | 0 | N/A - zero changed C# files | N/A - zero changed files | N/A - zero changed files | N/A - zero changed files | N/A - zero changed files |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files on the branch.
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files on the branch.
- PowerShell baseline coverage artifact: COV-BASE (per-file LINE counters for the four changed sources, recorded at P0-T6).
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml`, written 2026-11-04T16-10 UTC by the merged `Invoke-PoshQCParallelTest` run recorded in PAR (8 shards, all exit 0); reviewer parsed its root and per-file LINE counters directly.
- PowerShell changed-line coverage: COV-DELTA maps each of the 7 changed executable lines to a covered count of at least 1; the reviewer's parse of the current XML shows the same missed `nr` sets as the previous audit (activate.ps1 434; DrmCopilotPromptSupport.ps1 25, 91, 150, 154, 159; PoshQC.ScanConfig.psm1 39, 40, 47, 79; HostBootstrapWorkspace.psm1 none), none on a changed statement.
- Per-language comparison summary: section 1.2.1 below.

Explicit coverage verdicts: PowerShell PASS. Python, TypeScript, and C# N/A only because zero files of those languages changed on the branch. No language with changed files was waived or narrowed.

Threshold precedence: the root `CLAUDE.md` states no coverage thresholds, so the defaults govern (line >= 85% repo-wide, per new file, and per modified file; no regression on changed lines). Pester measures no branch coverage, so no branch threshold applies to PowerShell.

Assumption (coverage freshness): the coverage XML was written at 16:10 UTC from the working tree that already contained the merge 089e55e5c and the five cycle-1 test edits; the cycle commit 7c31fb1d2 (16:12 UTC) changed only test files and feature-folder documents (`git diff --name-only 089e55e5c HEAD -- scripts extensions` is empty). Test files are excluded from measurement, so the XML describes the HEAD production blobs and the repo-wide figure now reflects the merged tree.

## Executive Summary

The branch converts 17 Pester suites to a per-suite portable fixture root, fixes four host-dependent production defects (D1 to D4), and restores process-wide state in the touched suites. Remediation cycle 1 added test-only edits to five suites: two now restore `$env:POSHQC_SKIP_SCRIPT_EXECUTION` (R1-F1), `link-feature-docs.Tests.ps1` restores or removes its global `gh` stub (R1-F5), and three suites escape fixture paths before interpolating them into script-block source (R1-F2, R1-F4). The reviewer inspected the full branch diff and the cycle diff, reran PSScriptAnalyzer and the formatter over all 24 changed PowerShell files (0 findings, 0 differences), reran Pester over `tests/scripts/dev-tools` and `tests/scripts/powershell/PoshQC` at HEAD (953 tests, 944 passed, 0 failed, 9 skipped; worktree clean afterwards), confirmed the bundle mirror is byte-identical, and parsed the current merged coverage artifact. All PowerShell coverage gates pass. No blocking finding exists. AC2 (Windows CI on the final PR head) remains owned by the S9 CI green gate.

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|---|---|---|
| Independence | PASS | SHUF: three seeded shuffled single-process orders of the five cycle suites (seeds 1067, 2026, 7), 62 of 62 each, both leak probes absent; TWO: both probes absent at the end of the two-tree run, where the baseline `evidence/remediation-baseline/two-trees.2026-11-04T15-45.md` read `=1` and `present`. |
| Isolation | PASS | Each converted test keeps a single behavior; the cycle added only `BeforeAll` saves and `AfterAll` restores plus escaped literals. |
| Fast Execution | PASS | Reviewer two-tree run of 953 tests completed in a few minutes on the Codespace. |
| Determinism | PASS | No wall-clock, random, or temporary-file dependence added; PAR, SHUF, and TWO report 0 failures. |
| Readability & Maintainability | PASS | Each save and escape carries a one-line comment stating why. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|---|---|---|
| Baseline Coverage Documented | PASS | COV-BASE records the four per-file baselines. |
| No Coverage Regression | PASS | Every changed file rose (92.45 to 98.11, 96.88 to 100, 65.79 to 86.84, 89.13 to 91.3); all 7 changed executable lines covered (COV-DELTA). |
| New Code Coverage | PASS | No new production file was added; all changed lines covered. |
| Comprehensive Coverage | PASS | Each defect has a fail-before/pass-after regression test (evidence/regression-testing/fail-before-d1..d4, pass-after-d1..d4); each cycle finding has a fail-before (evidence/remediation-baseline/) and pass-after (evidence/regression-testing/r1f*). |
| Positive Flows | PASS | Absolute-input cases for D2/D3 and workspace-relative D4 entries retained. |
| Negative Flows | PASS | D4 rejects `/absolute/path` and `\absolute\path`; D3 adds the absent-activation-script throw case. |
| Edge Cases | PASS | evidence/regression-testing/r1f1-prior-value.2026-11-04T15-49.md (pre-existing value `prior` survives) and r1f5-prior-gh.2026-11-04T15-49.md (prior `gh` survives); evidence/other/escape-probe.2026-11-04T15-50.md (quote round-trips). |
| Error Handling | PASS | D4 error message keeps the file name and "absolute". |
| Concurrency | PASS | PAR: 504 suites, 14,172 tests, 0 failures, all five cycle suites present. |
| State Transitions | N/A | No stateful component changed. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 88.06% line across the four changed files (177/201) -> Post-change: 95.02% line across the same files (191/201); repo-wide post-change 93.84% line. Change: +6.96 percentage points on the changed files. New/changed-code coverage: 100% (7 of 7 changed executable lines). Disposition: PASS. Evidence: COV-BASE, COV-FINAL, COV-DELTA, and reviewer parse of `artifacts/pester/powershell-coverage.xml` written 2026-11-04T16-10 UTC.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|---|---|---|
| Clear Failure Messages | PASS | Exact expectations retained; the cycle changed no assertion (diff inspection of 7c31fb1d2). |
| Arrange-Act-Assert Pattern | PASS | D2/D3 tests carry explicit Arrange/Act/Assert comments. |
| Document Intent | PASS | Comments explain the portable root, the save/restore purpose, and the unqualified `Function:\gh` removal path. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|---|---|---|
| Avoid External Dependencies | PASS | Real `New-Item` writes replaced with module-scope mocks; the `gh` stub prevents real CLI calls and is now removed after the suite. |
| Use Mocks/Stubs | PASS | `Test-Path` and `New-Item` mocks at file-system seams. |
| Environment Stability | PASS | `git status --porcelain --untracked-files=all` empty after the reviewer's two-tree run; evidence/qa-gates/prohibited-constructs.2026-11-04T16-10.md records 0 TestDrive, temp-path, or `-Skip` matches in the five cycle files. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|---|---|---|
| Pre-submission Review | PASS | evidence/qa-gates/self-review.2026-11-04T16-11.md and this audit. |

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|---|---|---|
| Clarify the objective | PASS | spec.md and remediation-inputs.2026-11-04T15-31.md. |
| Read existing change plans | PASS | evidence/remediation-baseline/phase0-instructions-read.2026-11-04T15-42.md. |
| Document the plan | PASS | remediation-plan.2026-11-04T15-31.md (all tasks checked); deviations in DEV. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|---|---|---|
| Simplicity first | PASS | Cycle edits copy the existing save/restore pattern of `sync-agents-from-instructions.Tests.ps1` and `Enter-DrmCopilotShell.Tests.ps1`. |
| Reusability | PASS | Uses the framework helper `CodeGeneration.EscapeSingleQuotedStringContent` rather than a custom escape. |
| Extensibility | PASS | No public parameter or output type changed. |
| Separation of concerns | PASS | Production fixes stay in the functions that own path resolution and validation. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|---|---|---|
| Cohesive modules | PASS | No file moved or split. |
| At or below the 800-line hard limit | PASS | Largest changed covered file: tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1 at 529 logical lines; no file at or above 700; `config/file-size-baseline.json` unchanged on the branch. |
| Public vs internal | PASS | Function signatures unchanged. |
| No circular dependencies | PASS | No new imports. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|---|---|---|
| Descriptive names | PASS | `$script:PriorSkipScriptExecution`, `$script:PriorGhFunction`, `$escapedNoProbeRoot`. |
| Docs/docstrings | PASS | `Get-RepoRelativePrompt` help updated. |
| Comment why, not what | PASS | See 1.3. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|---|---|---|
| 1. Formatting | PASS | Reviewer `Invoke-Formatter` comparison over 24 changed files: FORMAT-DIFF-COUNT=0. |
| 2. Linting | PASS | Reviewer `Invoke-ScriptAnalyzer` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`: PSSA-FINDINGS=0. |
| 3. Type checking | N/A | Not applicable to PowerShell. |
| 4. Architecture-boundary tests | N/A | No architecture-boundary suite covers these PowerShell paths. |
| 5. Testing | PASS | Reviewer two-tree run: 953 tests, 944 passed, 0 failed, 9 skipped. |
| 6. Contract / schema checks | PASS | evidence/qa-gates/mirror-contracts.2026-11-04T14-47.md: 24 passed; reviewer `cmp` confirms mirror identity at HEAD. |
| Full toolchain loop | PASS | Cycle loop restarted once (DEV item 2, an unrelated shard-8 runtime fault) and finished clean; reviewer reruns match. |
| Explicit reporting | PASS | Each gate has a timestamped evidence file with command and exit code. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|---|---|---|
| Summarize changes | PASS | self-review.2026-11-04T16-11.md and the cycle commit message. |
| Design choices explained | PASS | DEV item 1 explains the unqualified `Function:\gh` removal path with probe output. |
| Update supporting documents | PASS | spec.md Rollout & Follow-up records the Linux-leg owner decision. |
| Provide next steps | PASS | AC2 pending Windows CI at S9; R1-F3 comment correction deferred to the final code-touching commit (code review). |

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|---|---|---|
| Formatting with Invoke-Formatter | PASS | FORMAT-DIFF-COUNT=0 (reviewer run); changed cycle lines inspected by eye for operator spacing. |
| Linting with PSScriptAnalyzer | PASS | PSSA-FINDINGS=0 (reviewer run). |
| Fix all findings | PASS | No open findings. |
| PowerShell 7+ compatible | PASS | Uses only APIs available in PowerShell 7. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|---|---|---|
| Advanced functions | PASS | Existing advanced functions unchanged in shape. |
| Parameter validation | PASS | D4 validation is host-independent: `^(?:[A-Za-z]:|[\\/])`. |
| Avoid global state | PASS | Cycle removes the two remaining leaks (environment variable and global `gh`); TWO probes absent. |
| Error handling | PASS | Existing throw paths and messages retained. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|---|---|---|
| Cohesive and at or below the 800-line hard limit | PASS | Production files 127 to 434 logical lines. |
| Approved verbs | PASS | No new function names. |
| Comment why | PASS | See 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|---|---|---|
| Step 1: Format | PASS | See 2.5. |
| Step 2: Analyze | PASS | See 2.5. |
| Step 3: Type check | N/A | Not applicable. |
| Step 4: Test | PASS | See 2.5. |
| Rerun loop if needed | PASS | One restart recorded in DEV. |

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|---|---|---|
| Use Pester v5.x | PASS | Pester 5.9.1. |
| Use PoshQC Configuration | PASS | Concurrent run through the self-hosted `Invoke-PoshQCParallelTest` (PAR). |
| PowerShell 7+ Compatible | PASS | PowerShell 7.6 on the Codespace; windows-latest at S9. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|---|---|---|
| Focused Unit Tests | PASS | One behavior per `It`. |
| Test Behavior Over Implementation | PASS | Assertions on resolved paths and outputs. |
| Mocking Used Sparingly | PASS | Mocks only at file-system and CLI seams. |
| Organization | PASS | Tests stay in `tests/scripts/` mirroring `scripts/`. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|---|---|---|
| File Naming | PASS | No file renamed. |
| Describe/Context/It Structure | PASS | Cycle added one `AfterAll` per touched scope; no `Describe`, `Context`, or `It` changed. |
| Logical Grouping | PASS | Regression tests placed under the function they cover. |
| Docstrings/Comments | PASS | See 1.3. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|---|---|---|
| Use PoshQCTest Command | PASS | PAR route: `Invoke-PoshQCParallelTest` from the self-hosted module. |
| No Alternative Test Runners | PASS | Pester only. |

## 5. Test Coverage Detail

Reviewer parse of `artifacts/pester/powershell-coverage.xml` (written 2026-11-04T16-10 UTC): root LINE covered 22,462, missed 1,474 (93.84%); INSTRUCTION 34,275/36,840 (93.04%). Per file: scripts/dev-tools/activate.ps1 52/53 (98.11%); scripts/dev-tools/HostBootstrapWorkspace.psm1 64/64 (100%); scripts/dev-tools/DrmCopilotPromptSupport.ps1 33/38 (86.84%); scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1 42/46 (91.3%). The bundle mirror is byte-identical to the measured source. No coverage exclusion was added.

## 6. Test Execution Metrics

- Reviewer run at HEAD (single process, coverage off, `tests/scripts/dev-tools` and `tests/scripts/powershell/PoshQC`): Tests=953 Passed=944 Failed=0 Skipped=9; equal to TWO and to the cycle baseline.
- PAR (concurrent shards, 8 workers): 504 suites, 14,172 tests, 0 failures, 0 errors, 411.95 s. The first cycle run had one failure in `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1` (child-process `System.IO.FileLoadException`, exit 134), outside the change set; that suite passed 3 of 3 alone and the rerun was clean (DEV item 2).
- SHUF: three recorded seeds over the five cycle suites, 62 of 62 each.

## 7. Code Quality Checks

- Formatting: 0 formatter differences over 24 changed PowerShell files.
- File size: all 24 changed covered files below 700 logical lines (counted with `@(Get-Content -LiteralPath <path>).Count`).
- Tier classification: `quality-tiers.yml` exists; `check_quality_tiers.py --repo-root <worktree>` (poetry environment) reports `quality-tiers: OK (29 entries, 29 discovered projects)`. Changed paths fall under T3/T4 projects; no T1/T2 obligation applies.
- Workflow rule `modified-workflow-needs-green-run`: not triggered; no path under `.github/` is in the branch diff.

## Evidence Location Compliance

`validate_evidence_locations.py --root <worktree>` exited 0. The branch diff contains no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All cycle evidence is under `evidence/remediation-baseline/`, `evidence/regression-testing/`, `evidence/other/`, and `evidence/qa-gates/` in this feature folder. No violations.

## 8. Gaps and Exceptions

### Identified Gaps

- AC2 (Windows CI shards on the final PR head) cannot be verified before the pull request exists; the S9 CI green gate owns it.

### Approved Exceptions

- None.

### Removed/Skipped Tests

- No test removed. The 9 skipped tests are pre-existing and outside the change set; no `-Skip` was added.

## 9. Summary of Changes

### Commits in This PR/Branch

20 commits from 8b337df4e to 7c31fb1d2 (`git log 11f188d1b..7c31fb1d2`): documentation and evidence commits, four production-fix commits (795129a4e D1, ca04a0eb7 D2, 8916ed737 D3, 293f3af51 D4), four test commits (f76ce569c, 5e521434b, faf708b01, 7c31fb1d2 cycle 1), the previous review record edfad2011, and two merges of `origin/main`.

### Files Modified

Production: `scripts/dev-tools/activate.ps1`, `scripts/dev-tools/HostBootstrapWorkspace.psm1`, `scripts/dev-tools/DrmCopilotPromptSupport.ps1`, `scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1`, `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.ScanConfig.psm1`. Tests: the 17 suites listed in spec.md Scope plus `tests/scripts/dev-tools/link-feature-docs.Tests.ps1` and `tests/scripts/dev-tools/link-parent-child.Tests.ps1` (cycle 1). Documentation: this feature folder.

## 10. Compliance Verdict

### Overall Status: FULLY COMPLIANT

### Policy-by-Policy Summary

- General Code Change Policy (Section 2): PASS.
- Language-Specific Code Change Policy (Section 3): PASS.
- General Unit Test Policy (Section 1): PASS.
- Language-Specific Unit Test Policy (Section 4): PASS.

### Metrics Summary

- PSSA findings: 0. Formatter differences: 0.
- Tests at HEAD (two trees): 953 total, 0 failed.
- PowerShell repo-wide line coverage: 93.84%; changed files 95.02%; changed lines 100%.

### Recommendation

Proceed to PR authoring. The S9 CI green gate remains responsible for `ci_gate.conclusion == "success"` with `ci_gate.head_sha` equal to the final PR head, which also verifies AC2.

## Appendix A: Test Inventory

Changed suites (19): tests/scripts/dev-tools/activate.Tests.ps1, Enter-DrmCopilotShell.Tests.ps1, HostBootstrap.Invoke.Tests.ps1, HostBootstrap.Tests.ps1, HostBootstrapWorkspace.Tests.ps1, HostTooling.Tests.ps1, link-feature-docs.Tests.ps1, link-parent-child.Tests.ps1, new-potential-entry.TemplateRoot.Tests.ps1, post-codex-worktree-session.Tests.ps1, publish-sideloaded-extension.Tests.ps1, SideloadedExtensionPublish.Invoke.Tests.ps1, SideloadedExtensionPublish.Tests.ps1, sync-agents-from-instructions.Tests.ps1, Test-DiscoveryHostCapability.Entry.Tests.ps1, Test-DiscoveryHostCapability.Tests.ps1; tests/scripts/powershell/PoshQC/PoshQC.ScanConfig.Tests.ps1, PoshQC.ScanFolders.Tests.ps1, PoshQC.TestingCommands.Tests.ps1. New regression tests: D1 descendant-separator `It`; D2 relative-path `It` blocks; D3 `Context` blocks `Get-DrmCopilotNormalizedPath` and `Resolve-DrmCopilotActivationScriptPath`; D4 `/absolute/path` and `\absolute\path` cases. Cycle 1 added no `It`; test counts per suite are unchanged (evidence/regression-testing/r1f*).

## Appendix B: Toolchain Commands Reference

Reviewer commands (scratch scripts run against the worktree):

- `git -C <worktree> diff --name-only 11f188d1b HEAD`; `git -C <worktree> diff 089e55e5c 7c31fb1d2 -- tests scripts extensions`; `git -C <worktree> diff --name-only 089e55e5c HEAD -- scripts extensions` (empty)
- `cmp scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1 extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.ScanConfig.psm1`
- `pwsh -NoProfile -NonInteractive -File <scratch>/fr1067-qa.ps1 -Root <worktree>` (per-file `Invoke-ScriptAnalyzer`, `Invoke-Formatter` comparison, `@(Get-Content -LiteralPath <path>).Count`)
- `pwsh -NoProfile -NonInteractive -File <scratch>/fr1067-pester.ps1 -Root <worktree>` (Invoke-Pester over the two trees, PassThru, coverage off)
- `python3 -I <scratch>/cov1067.py artifacts/pester/powershell-coverage.xml`
- `python3 scripts/dev_tools/validate_evidence_locations.py --root <worktree>`; `poetry run python scripts/dev_tools/check_quality_tiers.py --repo-root <worktree>`

Executor commands are recorded verbatim in each evidence file under `evidence/`.

## Rejected Scope Narrowing

None. The caller supplied the base branch, merge base, head, feature folder, PR-context paths, acceptance-criteria source, and the cycle inputs; the review covered the entire branch diff, not only the cycle change set.
