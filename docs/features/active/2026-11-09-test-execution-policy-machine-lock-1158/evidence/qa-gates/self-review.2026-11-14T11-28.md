# Self-Review: Test-Execution Policy and Machine Test-Suite Lock (#1158) (P7-T9)

Timestamp: 2026-11-14T11-28
Command: walk of `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, `code-review.yyyy-MM-ddTHH-mm.md`, and `feature-audit.yyyy-MM-ddTHH-mm.md` against `git diff origin/main...HEAD` (331 files at the walk) with `git status --porcelain` (empty); the AC3 search over the six named test files; an AST audit of every changed Python file for docstrings and loop intent comments on changed lines (SCRATCH/issue-1158-docaudit.py and SCRATCH/issue-1158-docfilter.py)
EXIT_CODE: 0
Output Summary: every checklist item has one row, and no row is FAIL. The walk found one defect: a loop on a changed line of `tests/scripts/dev_tools/test_fix_all_branches.py` had no intent comment. It was fixed in a separate commit before this file was written, and the Python loop was re-run (`python-static.2026-11-14T11-27.md`, `pytest-suite.2026-11-14T11-27.md`). Earlier in the final loop, the new-code rule (90% line coverage) found four new PowerShell files below 90%. Tests were added and the loop was re-run from P7-T1; the results are in `pester-suite.2026-11-14T11-16.md`. CI results on the pull-request head are pending; they are listed under CI Cross-check.

## Scope

| Language | Files changed (including mirrors and bundles) | Final gate | Result |
|---|---|---|---|
| Python | 17 | pytest launcher gate | 16927 passed, 0 failed |
| PowerShell | 55 | Pester launcher gate | 26384 tests, 0 failures |
| Bash and bats | 6 | bats launcher gate (WSL copy of HEAD) | 803 tests, 0 failures |
| TypeScript | 0 production files; the extension suite runs as a regression gate | Jest launcher gate | 5616 passed, 0 failed |
| JSON | registries, `config/test-execution-policy.json`, `.vscode/tasks.json`, both `core.json` | parsed by the Registration, RepoConfig, VS Code tasks, and manifest tests | 0 failures |

## Policy Audit Template

### Coverage Evidence Checklist

| Item | Status | Evidence |
|---|---|---|
| TypeScript baseline coverage artifact | N/A | N/A - out of scope: no TypeScript production change (`baseline/jest-extension-suite.2026-11-10T04-26.md`) |
| TypeScript post-change coverage artifact | N/A | N/A - out of scope |
| PowerShell baseline coverage artifact | PASS | `evidence/baseline/pester-suite.2026-11-10T04-17.md` |
| PowerShell post-change coverage artifact | PASS | `evidence/qa-gates/pester-suite.2026-11-14T11-16.md` |
| Per-language comparison summary | PASS | `evidence/qa-gates/coverage-comparison.2026-11-14T11-21.md` |
| Fail-closed rule (no required artifact missing) | PASS | baseline, gate, and comparison artifacts exist for Python, PowerShell, Jest, and bats; the bats baseline is the P0-T7 deviation record |

### 1.1 Core Principles

| Requirement | Status | Evidence |
|---|---|---|
| Independence | PASS | Pester runs in 8 shards and pytest in 24 xdist workers, with 0 failures. Order dependence found in the Phase 5 gate (Issue824 `Reset-EpicStateProbeModuleBinding`, dot-source after the forced PoshQC import) was fixed in both leaker and victim. |
| Isolation | PASS | Each `It` or `test_` targets one behavior. Rows are parameterized per copy (`.claude` and `.codex`) and per suite. |
| Fast Execution | PASS | Pester 730.75 s for 26384 tests in 8 shards; pytest 132.97 s; Jest suites complete in seconds; the new helper suites run in about 1 to 2 s each. |
| Determinism | PASS | Clock, sleep, lock, holder, process, and file seams are injected. The only default-seam rows read the current process start time, the committed config, and platform folder values, and their assertions do not depend on the values read. |
| Readability and Maintainability | PASS | Each test file carries a `.SYNOPSIS` and `.DESCRIPTION` naming its seams. Test names state the scenario and the expected outcome. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|---|---|---|
| Baseline Coverage Documented | PASS | Pester 95.80%; the seven Python modules 72.91% line and 65.44% branch (`evidence/baseline/`) |
| No Coverage Regression | PASS | Pester 95.95%; Python 98.83% line and 96.41% branch; no changed file drops (`coverage-comparison.2026-11-14T11-21.md`) |
| Changed Files Meet Thresholds | PASS | Every changed or new file is at or above 85% line, and every Python module at or above 75% branch. The lowest is `qc_runner.py` at 93.58% line and 81.82% branch. |
| New Code Coverage at least 90% | PASS | New PowerShell files are at 91.07% to 100%. Missed Python lines are outside the changed ranges. `run-test-suite.sh` is 100% (kcov). |
| Comprehensive Coverage | PASS | Every function of the five hook files, the launcher, `Invoke-PesterSuite.ps1`, and the Python classifiers has named cases (spec AC1 to AC4 test lists). |
| Positive Flows | PASS | Free-lock launcher runs, allowed launcher commands, allowed non-runner commands, valid committed config |
| Negative Flows | PASS | Direct runners, wrappers, encoded payloads, invalid config fields, worker-reduction tokens, and lane tokens are denied or refused with the documented prefix. |
| Edge Cases | PASS | The 262144-byte script boundary, mixed-case suffixes, `-m` with `not`, `waitMilliseconds` 0, an empty or unparseable Codex stdin, and a child exit of 75 reported as 1 |
| Error Handling | PASS | Dependency-guard failure, a throwing suite (lock released and record removed), an unreadable holder, an unreadable script, and pytest exit 2 with and without the refusal line |
| Concurrency | PASS | The machine lock state model (`Skip`, `Acquire`, `AcquireReplacingStaleRecord`, `Wait`, `Timeout`), the `run_fix_all` no-overlap case through an injected lock, and the live Linux two-process proof (AC2 item checked) |
| State Transitions | PASS | The lock-decision driver loop under an injected clock: each `Wait` before 90000 ms, then `Timeout` |

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|---|---|---|
| Clear Failure Messages | PASS | `-Because` reasons on registry and parity assertions; exact-text assertions on deny and queue lines |
| Arrange-Act-Assert Pattern | PASS | Every new `It` carries `# Arrange`, `# Act`, and `# Assert` comments; the Python tests follow the same layout. |
| Document Intent | PASS | File headers and test names describe the seam and the scenario, for example `places the group directly after the Bash group, so the hook runs after the Bash hooks`. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|---|---|---|
| Avoid External Dependencies | PASS | No network access. Python tests replace `subprocess.run` and `shutil.which` through `monkeypatch`. The parity suite starts `pwsh` hook processes as #1159 designed; that is a pre-existing pattern. |
| Use Mocks/Stubs | PASS | Recording seams for the lock, holder, process, clock, and sleep; a Pester `Mock` of `Invoke-TestExecutionPolicyDecision` for the entry point; a bats `TEST_SUITE_PWSH_BIN` stub |
| Environment Stability | PASS | No test writes the real lock directory, a holder record, or a temporary file. The leak scan passes (`powershell-static.2026-11-14T11-03.md`). |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|---|---|---|
| Pre-submission Review | PASS | This file. The orchestrator's feature review follows. |

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|---|---|---|
| Clarify the objective | PASS | Issue #1158; `spec.md`; `user-story.md` |
| Read existing change plans | PASS | `plan.2026-11-09T16-31.md` and the sibling statuses recorded in the `pre-gate-sync` records |
| Document the plan | PASS | Plan tasks are checked off on disk, and commits name `(#1158)`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|---|---|---|
| Simplicity first | PASS | One launcher, one lock adapter, and one pure decision module. Under branch B the hook is a single registry group, and the hook files are unchanged apart from the `-Force` removal. |
| Reusability | PASS | The shared helpers (`test-execution-policy.ps1`, `test-execution-lock*.ps1`, `test-execution-command-form.ps1`) serve the hook, the launcher, and the MCP templates. |
| Extensibility | PASS | Repository suites and lanes come from `config/test-execution-policy.json` with validated defaults. |
| Separation of concerns | PASS | The pure decision (`Get-TestExecutionLockDecision`) is separate from the I/O adapter (`test-execution-lock.ps1`) and the entry wiring. |

### 2.3 Module and File Structure

| Requirement | Status | Evidence |
|---|---|---|
| Cohesive modules | PASS | Each helper file holds one concern: policy, command form, lock decision, lock I/O, or hook entry. |
| At or below the 800-line hard limit | PASS | The largest covered files are `test-execution-command-form.ps1` (632 lines), `qc_runner.py` (586), `PoshQC.Testing.psm1` (554), and `Invoke-TestSuite.Tests.ps1` (516). `.vscode/tasks.json` (1438) is JSON, which the size policy does not cover. |
| Public vs internal | PASS | Python helpers are `_prefixed` where internal. Only the documented functions are dot-sourced by consumers. |
| No circular dependencies | PASS | The helpers load in the fixed order the launcher and hook use; there are no back-references. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|---|---|---|
| Descriptive names | PASS | `Invoke-TestSuiteLauncher`, `classify_launcher_exit`, `LauncherRefusedError`, `run_launcher_test_step` |
| Docs/docstrings | PASS | The AST audit finds no function or class without a docstring on a changed line. PowerShell functions carry comment-based help. |
| Comment why, not what | PASS | The one missing loop intent comment on a changed line was added (commit `test(fix-all): add the loop intent comment ...`). |

### 2.5 After Making Changes: Toolchain Execution

| Requirement | Status | Evidence |
|---|---|---|
| 1. Formatting | PASS | black, Invoke-PoshQCFormat, shfmt (in `shell-qc.sh check`), and root and extension Prettier: 0 findings |
| 2. Linting | PASS | ruff, PSScriptAnalyzer (1741 files), shellcheck, and ESLint: 0 findings |
| 3. Type checking | PASS | pyright 0 errors; `tsc` exit 0 |
| 4. Testing | PASS | the launcher gates for Pester, pytest, Jest, and bats, each with 0 failures |
| Full toolchain loop | PASS | The final loop restarted three times: after the #1159 and #1179 merges, after the #1162 merge together with the coverage tests, and after the comment fix (Python only). The final pass is clean. |
| Explicit reporting | PASS | `evidence/qa-gates/` final-QC records for each language and gate |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|---|---|---|
| Summarize changes | PASS | The commit messages, plus the final report to the orchestrator |
| Design choices explained | PASS | Branch B single-group registration (`pre-gate-sync.2026-11-14T10-11.md`); the WSL copy for bats (`bats-worktree-host-deviation.2026-11-14T10-03.md`) |
| Update supporting documents | PASS | The SKILL.md copies, the six brief copies, the plan-contract, QA-gate, invoke, and agent copies, and ledger entry `0012` with its README row |
| Provide next steps | PASS | The PR is opened by the orchestrator; the CI cross-check and the pending CI AC items are listed below. |

### 3A Python Code Change Policy

| Requirement | Status | Evidence |
|---|---|---|
| Formatting with Black | PASS | `1070 files would be left unchanged.` |
| Linting with Ruff | PASS | `All checks passed!`; no new suppression |
| Type checking with Pyright | PASS | `0 errors, 0 warnings, 0 informations` |
| Testing with Pytest | PASS | 16927 passed through the launcher (`-n auto`) |
| Strong typing | PASS | Full annotations on `classify_launcher_exit`, `launcher_refusal_message`, and `PreflightQCResult.launcher_outcome`; pyright clean; no `Any` added |
| Dataclasses for value objects | PASS | `PreflightQCResult` is a frozen dataclass carrying `launcher_outcome`; `LauncherOutcome` is an `Enum` of the classified launcher results. |
| Protocols/ABCs for interfaces | N/A | No new interface with multiple implementations |
| Avoid utility classes | PASS | Module-level functions only |
| Specific exceptions | PASS | `LauncherRefusedError` is raised for a launcher refusal; no broad handler was added. |
| Logging over print | PASS | The existing logger callbacks are used; no `print` was added. |
| Invariants at construction | PASS | The outcome is classified once, at the classifier, before early returns (D28). |

### 3B PowerShell Code Change Policy

| Requirement | Status | Evidence |
|---|---|---|
| Formatting with Invoke-Formatter | PASS | 0 `Formatted:` lines over 1741 files |
| Linting with PSScriptAnalyzer | PASS | 0 findings. One tool fault on the first call on an unrelated file was retried and returned 0 findings. |
| Fix all findings | PASS | none open |
| PowerShell 5.1 and 7.6+ compatible | N/A | The repository targets PowerShell 7+ (`#Requires -Version 7.0`, rule `.claude/rules/powershell.md`). |
| Advanced functions | PASS | `[CmdletBinding()]` and `[OutputType()]` on every new function; `SupportsShouldProcess` on the lock and holder writes (WhatIf rows) |
| Parameter validation | PASS | `Mandatory`, `AllowEmptyString`, and `AllowNull` attributes on the seams and inputs |
| Avoid global state | PASS | Script-scope constants only; seams are passed as parameters. |
| Error handling | PASS | `TEST_EXECUTION_POLICY_BLOCKED:` throws and fail-closed dependency guards; `finally` releases the lock. |
| Cohesive and at or below the 800-line hard limit | PASS | at most 632 lines |
| Approved verbs | PASS | Get, Invoke, Open, Read, Write, Remove, New, Test, and Assert; PSScriptAnalyzer `PSUseApprovedVerbs` is clean. |
| Comment why | PASS | Comments explain the seam rationale, for example the helper import that is not a closure. |
| Step 1: Format | PASS | as above |
| Step 2: Analyze | PASS | as above |
| Step 3: Type check | N/A | Not applicable for PowerShell. |
| Step 4: Test | PASS | Pester launcher gate: 0 failures |
| Rerun loop if needed | PASS | three restarts, recorded above |

### 3C Bash Script Policy

| Requirement | Status | Evidence |
|---|---|---|
| Formatting with shfmt | PASS | `shell-qc.sh check` exit 0 |
| Linting with shellcheck | PASS | `shell-qc.sh check` exit 0 |
| Testing with bats | PASS | 803 tests, 0 failures; kcov 95.0%; `run-test-suite.sh` 100% |
| Portable shebang | PASS | `run-test-suite.sh` is a POSIX shim with `#!/bin/sh`, so it runs under `sh` as the launcher command requires. |
| Error handling | PASS | `set -eu` (POSIX `sh` has no `pipefail`, and the shim has no pipeline); `exec` hands the `pwsh` exit status through unchanged, which the bats cases prove for 0, 1, and 75. |
| At or below the 800-line hard limit | PASS | 11 lines (shim) and 59 lines (`tests/shell/test_run_test_suite.bats`) |

### 3D JSON Configuration Policy

| Requirement | Status | Evidence |
|---|---|---|
| Formatting with jq | N/A | No changed JSON file is governed by `scripts/dev_tools/json_config.py` (`scripts/**`, `docs/**` excluding `docs/features/**`, `examples/**`). |
| Schema validation | N/A | as above. The registries, the config, and the manifests are validated by their contract tests instead. |
| Required `$schema` | N/A | as above |
| Strict JSON only | PASS | Every changed JSON file parses with `ConvertFrom-Json` in its tests. `.vscode/tasks.json` keeps its existing JSONC form. |
| Deterministic key order | N/A | Registry and manifest order is semantic (group and hook order). |

### 4A Python Unit Test Policy

| Requirement | Status | Evidence |
|---|---|---|
| Use Pytest | PASS | |
| Coverage expectation | PASS | All seven modules are at or above the thresholds. |
| Focused unit tests | PASS | `test_qc_runner_expectations.py`, `test_qc_runner_launcher.py`, `test_fix_all_launcher_steps.py`, `test_cli_preflight.py`, and `test_cli_task_runtime.py` each cover one module. |
| Mocking sparingly | PASS | `monkeypatch` for `subprocess.run` and `shutil.which` only |
| Organization | PASS | Test files mirror `scripts/dev_tools/` under `tests/scripts/dev_tools/`. |
| Naming conventions | PASS | `test_<behavior>` names |
| Docstrings/comments | PASS | The AST audit is clean on changed lines. |
| Use Pytest (toolchain) | PASS | |
| No Alternative Test Runners | PASS | Only the launcher `pytest` suite |

### 4B PowerShell Unit Test Policy

| Requirement | Status | Evidence |
|---|---|---|
| Use Pester v6.x | PASS | The repository Pester through `Invoke-PoshQCParallelTest` |
| Use PoshQC Configuration | PASS | The launcher `pester` suite uses `Invoke-PesterSuite.ps1`, which calls `Invoke-PoshQCParallelTest` with the repository settings. |
| PowerShell 5.1 and 7.6+ Compatible | N/A | PowerShell 7+ only, as in the repository rule |
| Focused Unit Tests | PASS | One behavior per `It` |
| Test Behavior Over Implementation | PASS | Assertions are on returned decisions, exit codes, stderr lines, and recorded seam events. |
| Mocking Used Sparingly | PASS | Seams instead of mocks; `Mock` is used only for the entry-point decision and the template commands. |
| Organization | PASS | `tests/scripts/claude-hooks/`, `codex-hooks/`, `claude-skills/test-execution-policy/`, `powershell/PoshQC/` |
| File Naming | PASS | `*.Tests.ps1` |
| Describe/Context/It Structure | PASS | |
| Logical Grouping | PASS | Describe blocks per surface: lock, discovery, refusals, argument reach, and registry membership |
| Docstrings/Comments | PASS | File help headers |
| Use PoshQCTest Command | PASS | the launcher `pester` suite, which calls the PoshQC parallel runner |
| No Alternative Test Runners | PASS | Debugging selections used Pester `Run.Path`. Every gate ran through the launcher. |

### 5 to 10 Report Sections

| Section | Status | Evidence |
|---|---|---|
| 5 Test Coverage Detail | PASS | `pester-suite.2026-11-14T11-16.md` and `pytest-suite.2026-11-14T11-20.md` per-file tables |
| 6 Test Execution Metrics | PASS | Counts and wall clock times in each gate record |
| 7 Code Quality Checks | PASS | the static records at 11-03 and 11-27 |
| CI Cross-check | N/A | The pull-request head CI is pending. The jobs to compare are `poshqc / PowerShell QC`, `poshqc / PowerShell hook suites (Linux)`, `quality-checks7 / Code Quality & Tests (3.13)`, `drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)`, `shell-coverage / Shell Coverage (Bats + kcov)`, and the root TypeScript job `Check root formatting`. |
| 8 Gaps and Exceptions | PASS | Gaps: integration and golden lanes run in CI only (`lane-deviation.2026-11-14T11-21.md`); bats runs on a WSL copy (`bats-worktree-host-deviation.2026-11-14T10-03.md`). No test was removed or skipped by this item. |
| 9 Summary of Changes | PASS | See the commit log. |
| 10 Compliance Verdict | PASS | Compliant locally; CI pending |

## Code Review Template

| Check | Status | Evidence |
|---|---|---|
| Findings table: no open Blocking or Major finding | PASS | The two walk findings (the loop comment and new-code coverage) were fixed. |
| Python implementation audit | PASS | Launcher classification before early returns (D28); no change to the handling of non-launcher codes |
| TypeScript implementation audit | N/A | No TypeScript production change |
| PowerShell implementation audit | PASS | Seams have real defaults; the lock is released in `finally`; holder records are written under `ShouldProcess`. |
| C# implementation audit | N/A | No C# change |
| Reviewed test and QA artifacts | PASS | the `evidence/qa-gates/` records listed above |
| Determinism | PASS | Injected clock and sleep; no real waits (AC3 row) |
| Isolation | PASS | One behavior per case |
| Speed | PASS | Gate wall clock times as recorded |
| Diagnostics | PASS | Exact-text and `-Because` assertions |
| No secrets in code | PASS | none |
| No unsafe subprocess or command construction | PASS | `ProcessStartInfo.ArgumentList`, one entry per word, with no shell string (`New-TestSuiteProcessStartInfo` test) |
| Input validation at boundaries | PASS | Config validation rules, payload parsing that fails open for malformed input, and the 262144-byte script cap |
| Error handling remains explicit | PASS | Prefixed refusal and queue lines; fail-closed dependency guard |
| Configuration / path handling is safe | PASS | The lock directory is derived from per-user state roots; the helper discovery order is `.claude/hooks` then `.codex/hooks`. |

## Feature Audit Template

| Item | Status | Evidence |
|---|---|---|
| Scope and baseline | PASS | `evidence/baseline/` Phase 0 records |
| Acceptance criteria inventory | PASS | 34 numbered AC items and 7 definition-of-done items in `spec.md`; 16 numbered AC items in `user-story.md` |
| AC1 items (spec and user story) | PASS | SKILL.md copies; `test-execution-policy.Tests.ps1`; `RepoConfig` tests; markers registered and `--strict-markers` clean (`pytest-suite.2026-11-14T11-27.md`) |
| AC2 items | PASS | lock, launcher, PoshQC lane exclusion, template, `Invoke-PesterSuite`, bats shim, and Python caller tests in the final gates; the live proof was checked earlier |
| AC3 items | PASS | lock-decision and lane-classification tests; the AC3 row below |
| AC4 items (spec) | PASS | hook deny and allow cases (both twins). The registration is proven in its D31 branch B form by `test-execution-policy.Registration.Tests.ps1` (18 rows) and `PreToolUseDispatch.Parity.Tests.ps1`. The manifest, closure, guard-completeness, and no-Python suites pass. |
| AC4 item (user story, registration) | N/A | Its wording names the branch A direct groups in `settings.json` and `config.toml`. After #1159 merged, the hook is registered through the dispatcher registries (spec D31), which spec AC4 states as the alternative. The item is left unchecked for an owner decision on the wording. |
| AC5 items | PASS | wording rows (`parallel-gate-wording.Tests.ps1`), brief contracts, executor tools, review workflow, ledger tests. The ledger entry took number `0012` because #1167 took `0011`; P6-T9 authorizes the renumbering. |
| Definition-of-done items | PASS | All are met, except one CI-dependent item, "Behavior matches acceptance criteria in all documented environments", which waits on Linux CI and stays unchecked. The other exception is the telemetry item, which is N/A because no logging surface was added. |

## AC3 Row

| Check | Status | Evidence |
|---|---|---|
| No temporary file, no real wait, no real filesystem write in the AC3 test files | PASS | A search of `tests/scripts/claude-hooks/test-execution-policy.Tests.ps1`, `test-execution-command-form.Tests.ps1`, `test-execution-lock-decision.Tests.ps1`, `test-execution-lock.Tests.ps1`, and `tests/scripts/claude-skills/test-execution-policy/Invoke-TestSuite.Tests.ps1` matched none of the write and wait tokens: no `New-TemporaryFile`, `TestDrive`, or `Start-Sleep`, and no `Set-Content`, `Out-File`, `Add-Content`, `New-Item`, `Remove-Item`, `Copy-Item`, `Move-Item`, `WriteAllText`, `WriteAllBytes`, or `[System.IO.File]::Create`, `Write`, or `Append`. The same search covers `Invoke-PesterSuite.Tests.ps1`, with 0 matches. A control search for `^Describe` in the same six files matched all six. `Invoke-PoshQCLeakScan` passes in the gate run (`powershell-static.2026-11-14T11-03.md`). |
