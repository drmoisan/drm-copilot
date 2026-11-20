# Self-Review (issue #1165)

Timestamp: 2026-11-10T00-59
Command: git diff MB; git status --porcelain (MB = git merge-base origin/main HEAD); walk of docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md, code-review.yyyy-MM-ddTHH-mm.md, and feature-audit.yyyy-MM-ddTHH-mm.md against that diff and the untracked files
EXIT_CODE: 0
Output Summary:
- Rows: one per checklist item of the three templates; 0 FAIL rows.
- Evidence directory below is `docs/features/active/cd-chained-command-recurring-deny-1165/evidence` (written `E/`).

## Coverage Evidence Checklist (policy-audit)

| Item | Status | Evidence |
|---|---|---|
| TypeScript baseline coverage artifact | N/A | No TypeScript file changed. |
| TypeScript post-change coverage artifact | N/A | No TypeScript file changed. |
| PowerShell baseline coverage artifact | PASS | E/baseline/pester-gate.2026-11-10T00-26.md |
| PowerShell post-change coverage artifact | PASS | E/qa-gates/pester-gate.2026-11-10T00-54.md |
| Per-language comparison summary | PASS | Section 1.2.1 rows below. |

## 1. General Unit Test Policy

| Item | Status | Evidence |
|---|---|---|
| Independence | PASS | New Pester files dot-source inside BeforeAll, use literal strings, set no globals; leak scan 0 failures (E/qa-gates/powershell-static.2026-11-10T00-38.md). Python tests read committed text only. Final gates are parallel (8 Pester workers, pytest -n auto). |
| Isolation | PASS | One behavior per It/test: intent per command, guidance per branch, decision per corpus row. |
| Fast Execution | PASS | bash-command-shape-guidance.Tests.ps1 ran in under 1 s and CdChainGuidance in about 2 s in debug runs; the six new pytest tests read small files. |
| Determinism | PASS | Pure string functions over literal fixtures; no clock, network, process, or random input. |
| Readability & Maintainability | PASS | Descriptive It names with table keys; Python AAA comments and docstrings. |
| Baseline Coverage Documented | PASS | PowerShell repo 95.79%, validate-bash.ps1 94.17%, venv policy 100%/100% (E/baseline/pester-gate.2026-11-10T00-26.md). Python: no production file in scope. |
| No Coverage Regression | PASS | Repo 95.80%, validate-bash.ps1 94.23%, venv policy 100%/100% (E/qa-gates/pester-gate.2026-11-10T00-54.md). |
| Changed Files Meet Thresholds | PASS | All changed or new PowerShell production files are at or above 85% line coverage (lowest 94.23%). |
| New Code Coverage >=90% | PASS | New helper 65/65 lines (100%); the two changed executable lines of validate-bash.ps1 are covered (ci=3 each). |
| Comprehensive Coverage | PASS | Get-CdChainedCommandIntent: 12 tests; Get-CdChainedRewriteGuidance: 9 tests; parse check: 1; reason shape: 8; decision corpus: 60. Get-CdChainedToolMention is exercised through both public functions. |
| Positive Flows | PASS | Each intent (plain, git, poetry, npm, npx, multi-step) returns its form. |
| Negative Flows | PASS | Tools before the cd, raw segments without a nested cd, path components and hyphenated words are not tools. |
| Edge Cases | PASS | Empty and null input, null intent, unknown cd target, wrapper-led raw leg. |
| Error Handling | PASS | Helper load failure routes through Add-HookDependencyFailure; hook-dependency-failure.Claude (221) and guard-completeness S1-S6 (731) pass. |
| Concurrency | N/A | Pure synchronous string functions. |
| State Transitions | N/A | No stateful component. |
| Per-Language Coverage Comparison | PASS | PowerShell as above; Python N/A (test-only edits); Bash N/A (no bash file changed); JSON N/A (config). |
| Clear Failure Messages | PASS | -Because messages name the missing token; Python asserts name file and tokens. |
| Arrange-Act-Assert Pattern | PASS | Python tests carry Arrange/Act/Assert; Pester venv additions carry Act/Assert. |
| Document Intent | PASS | File-level synopsis blocks and descriptive test names. |
| Avoid External Dependencies | PASS | None; the parse check reads the helper through the PowerShell parser only. |
| Use Mocks/Stubs | N/A | No dependency needs replacement; the functions are pure. |
| Environment Stability | PASS | No temporary files, no environment variables, no global state. |
| Pre-submission Review | PASS | This self-review. |

## 2. General Code Change Policy

| Item | Status | Evidence |
|---|---|---|
| Clarify the objective | PASS | Issue #1165 and spec.md: same deny decision, intent-specific guidance, launch-loaded rule. |
| Read existing change plans | PASS | plan.2026-11-09T17-40.md and research.2026-11-09T22-58.md were read before editing. |
| Document the plan | PASS | plan.2026-11-09T17-40.md, all tasks checked with evidence. |
| Simplicity first | PASS | Two public functions and one private helper; validate-bash.ps1 changes only the dependency load and the last sentence of one reason. |
| Reusability | PASS | Reuses Read-CommandLineSegment and Test-CommandLineSegmentRawScan from hook-command-scanner.ps1; the rule body text is shared by the rule, skill, and instruction. |
| Extensibility | PASS | A new tool needs one entry in $script:CdChainedIntentToolNames, the tool regex, and one form string. |
| Separation of concerns | PASS | Detection stays in validate-bash.ps1; message text lives in the new helper. |
| Cohesive modules | PASS | The helper holds only cd-chained intent and guidance logic. |
| At or below the 800-line hard limit | PASS | validate-bash.ps1 450, helper 178, venv policy 361 (E/qa-gates/scope-check.2026-11-10T00-57.md); largest touched test file test_execution_environment_brief_contracts.py 630 lines; none at or above 700. |
| Public vs internal | PASS | validate-bash.ps1 calls only the two documented functions; Get-CdChainedToolMention is an internal helper. |
| No circular dependencies | PASS | The helper dot-sources nothing (parse-check test); guard-completeness S4 passes. |
| Descriptive names | PASS | Get-CdChainedCommandIntent, Get-CdChainedRewriteGuidance, LAUNCH_LOADED_RULES. |
| Docs/docstrings | PASS | Comment-based help on every new function; docstrings on every new Python function. |
| Comment why, not what | PASS | Constant comments state why a path component is not a tool and why raw text is scanned; validate-bash.ps1 adds one comment naming the issue. |
| 1. Formatting | PASS | Invoke-Formatter difference 0 for 12 files; Black "3 files would be left unchanged." (E/qa-gates/powershell-static.2026-11-10T00-38.md, E/qa-gates/python-static.2026-11-10T00-40.md). |
| 2. Linting | PASS | PSScriptAnalyzer 0 findings; Ruff "All checks passed!" in pass 2 after two E501 fixes (pass 1 recorded in E/qa-gates/python-static.2026-11-10T00-39.md). |
| 3. Type checking | PASS | Pyright 0 errors; N/A for PowerShell. |
| 4. Testing | PASS | Pester 21301 passed, 0 failed; pytest 8852 passed, 0 failed (E/qa-gates/pester-gate.2026-11-10T00-54.md, E/qa-gates/pytest-gate.2026-11-10T00-56.md). |
| Full toolchain loop | PASS | PowerShell loop clean in one pass; Python loop clean in pass 2 after a lint restart. |
| Explicit reporting | PASS | Every step recorded in E/qa-gates/. |
| Summarize changes | PASS | See Section 9 row below. |
| Design choices explained | PASS | Claude-only helper (Codex hook has no cd-chained leg, #545); rule without paths: so it loads at launch. |
| Update supporting documents | PASS | Six brief copies, parallel-orchestrate step (c) in both copies, rule on three surfaces. |
| Provide next steps | PASS | Orchestrator pre-review commit; CI including the Linux hook-suite job; push-down refresh after the next extension release. |

## 3A. Python Code Change Policy

| Item | Status | Evidence |
|---|---|---|
| Formatting with Black | PASS | E/qa-gates/python-static.2026-11-10T00-40.md |
| Linting with Ruff | PASS | E/qa-gates/python-static.2026-11-10T00-40.md |
| Type checking with Pyright | PASS | E/qa-gates/python-static.2026-11-10T00-40.md |
| Testing with Pytest | PASS | E/qa-gates/pytest-gate.2026-11-10T00-56.md |
| Strong typing | PASS | All new Python functions are annotated; yaml.safe_load boundary isolated behind a cast. |
| Dataclasses for value objects | N/A | No value objects introduced. |
| Protocols/ABCs for interfaces | N/A | No interfaces introduced. |
| Avoid utility classes | PASS | Module-level functions only. |
| Specific exceptions | N/A | Test code; assertion failures only. |
| Logging over print | PASS | No print calls. |
| Invariants at construction | N/A | No classes introduced. |

## 3B. PowerShell Code Change Policy

| Item | Status | Evidence |
|---|---|---|
| Formatting with Invoke-Formatter | PASS | E/qa-gates/powershell-static.2026-11-10T00-38.md |
| Linting with PSScriptAnalyzer | PASS | E/qa-gates/powershell-static.2026-11-10T00-38.md |
| Fix all findings | PASS | 0 findings, none suppressed. |
| PowerShell 5.1 & 7.6+ compatible | PASS | The helper uses .NET Framework-available APIs (regex, List, String.IsNullOrWhiteSpace) and runs under the hook's PowerShell 7 host; the test files declare #Requires -Version 7.0, as the sibling hook suites do. |
| Advanced functions | PASS | CmdletBinding and OutputType on all three new functions. |
| Parameter validation | PASS | AllowNull/AllowEmptyString on optional inputs; Mandatory on internal inputs. |
| Avoid global state | PASS | Script-scope constants only, as in hook-command-scanner.ps1. |
| Error handling | PASS | Load failure through Add-HookDependencyFailure (fail-closed HOOK_DEPENDENCY_LOAD_FAILED deny). |
| Cohesive and at or below the 800-line hard limit | PASS | Helper 178 lines. |
| Approved verbs | PASS | Get- only; PSScriptAnalyzer reports no verb finding. |
| Comment why | PASS | See Section 2. |
| Step 1: Format | PASS | as above |
| Step 2: Analyze | PASS | as above |
| Step 3: Type check | N/A | Not applicable to PowerShell. |
| Step 4: Test | PASS | E/qa-gates/pester-gate.2026-11-10T00-54.md |
| Rerun loop if needed | PASS | Not needed for PowerShell; Python loop rerun once. |

## 3C. Bash Script Policy

| Item | Status | Evidence |
|---|---|---|
| Formatting with shfmt | N/A | No bash file changed in the repository. |
| Linting with shellcheck | N/A | No bash file changed. |
| Testing with bats | N/A | No bash file changed. |
| Portable shebang | N/A | No bash file changed. |
| Error handling | N/A | No bash file changed. |
| At or below the 800-line hard limit | N/A | No bash file changed. |

## 3D. JSON Configuration Policy

| Item | Status | Evidence |
|---|---|---|
| Formatting with jq | PASS | jq is not installed on this host; both edited pack manifests keep their existing two-space form, parse as JSON, and the Codex generator --check passes (E/qa-gates/python-static.2026-11-10T00-40.md). |
| Schema validation | N/A | The pack manifests carry no schema; the push-down contract tests validate membership (E/qa-gates/pytest-gate.2026-11-10T00-56.md). |
| Required $schema | N/A | The manifests have no $schema key before or after the change. |
| Strict JSON only | PASS | No comments or trailing commas; JSON parse succeeds. |
| Deterministic key order | PASS | Keys unchanged; array entries inserted at fixed positions. |

## 4A. Python Unit Test Policy

| Item | Status | Evidence |
|---|---|---|
| Use Pytest | PASS | pytest functions only. |
| Coverage expectation | N/A | Test-only Python edits; no production module in scope. |
| Focused unit tests | PASS | Each new test asserts one surface property. |
| Mocking sparingly | PASS | No mocks. |
| Organization | PASS | tests/scripts/dev_tools/, mirroring the existing contract-test layout. |
| Naming conventions | PASS | test_<surface>_<property> names. |
| Docstrings/comments | PASS | Every test has a docstring. |
| Use Pytest (runner) | PASS | One pytest -n auto gate run. |
| No Alternative Test Runners | PASS | None used. |

## 4B. PowerShell Unit Test Policy

| Item | Status | Evidence |
|---|---|---|
| Use Pester v6.x | PASS | Pester 6.2.0 through PoshQC. |
| Use PoshQC Configuration | PASS | Gate ran through Invoke-PoshQCParallelTest. |
| PowerShell 5.1 & 7.6+ Compatible | PASS | Test files require 7.0, matching the sibling hook suites that run under the PowerShell 7 hook host. |
| Focused Unit Tests | PASS | One behavior per It. |
| Test Behavior Over Implementation | PASS | Assertions on returned intent and reason text; the one structural test (no dot-source) is an AC-1 requirement. |
| Mocking Used Sparingly | PASS | No mocks added. |
| Organization | PASS | Describe/Context per function and per concern. |
| File Naming | PASS | <name>.Tests.ps1 under tests/scripts/claude-hooks and codex-hooks, mirroring .claude/hooks and .codex/hooks. |
| Describe/Context/It Structure | PASS | as above |
| Logical Grouping | PASS | Decision corpus, reason shape, intent, guidance, file shape. |
| Docstrings/Comments | PASS | Synopsis and description blocks in each new file. |
| Use PoshQCTest Command | PASS | Invoke-PoshQCParallelTest. |
| No Alternative Test Runners (PowerShell) | PASS | Focused Invoke-Pester runs were debugging only and are not cited as evidence. |

## 5-8. Coverage Detail, Execution Metrics, Code Quality, CI Cross-check, Gaps

| Item | Status | Evidence |
|---|---|---|
| Test Coverage Detail | PASS | Section 1 Comprehensive Coverage row. |
| Test Execution Metrics | PASS | Pester wall-clock 720.3 s, 21311 tests; pytest 24.81 s, 8858 collected. |
| Code Quality Checks | PASS | Format, lint, type-check rows above. |
| CI Cross-check | N/A | No pull request exists yet; CI runs after the orchestrator commit. The new claude-hooks and codex-hooks files use Join-Path, forward-slash relative paths, exact case, and no gitignored state, so the Linux hook-suite job is expected to pass; not yet observed. |
| Identified Gaps | PASS | None. |
| Approved Exceptions | N/A | None requested. |
| Removed/Skipped Tests | PASS | None removed; the 10 Pester and 6 pytest skips match the Phase 0 baseline. |
| Summary of Changes | PASS | Helper and hook wiring; venv reason in four copies; rule on three surfaces with bundle copies and manifest entries; brief table and Python-environment sentence in six copies; parallel-orchestrate step (c) in two copies; tests. |
| Compliance Verdict | PASS | Fully compliant on the evidence above. |
| Test Inventory | PASS | Section 1 Comprehensive Coverage row. |
| Toolchain Commands Reference | PASS | Command fields of each E/qa-gates artifact. |

## Code Review Template

| Item | Status | Evidence |
|---|---|---|
| Executive Summary | PASS | Deny decision unchanged (60/60 corpus rows); reason text now names the form for the detected intent. |
| Findings Table | PASS | No Blocking or Warning finding; no file at or above 700 lines. |
| Python implementation audit | N/A | No Python production code. |
| TypeScript implementation audit | N/A | No TypeScript change. |
| PowerShell implementation audit: what changed well | PASS | Guidance isolated in a leaf helper; detection functions byte-unchanged (E/qa-gates/scope-check.2026-11-10T00-57.md, CHECK 7). |
| PowerShell implementation audit: API and safety notes | PASS | Advanced functions, null-tolerant inputs, no ShouldProcess needed (no state change), 0 analyzer findings. |
| PowerShell implementation audit: error handling and logging | PASS | Guarded load with Add-HookDependencyFailure; no logging added (spec non-goal). |
| C# implementation audit | N/A | No C# change. |
| Reviewed test and QA artifacts | PASS | E/baseline/*, E/qa-gates/*, E/other/copilot-instruction-parity.2026-11-10T00-32.md. |
| Determinism | PASS | Pure string tests. |
| Isolation | PASS | One behavior per test. |
| Speed | PASS | Sub-second to two-second files. |
| Diagnostics | PASS | Failure messages name the token and intent. |
| No secrets in code | PASS | Diff holds no credentials or tokens. |
| No unsafe subprocess or command construction | PASS | The helper builds text only; nothing is executed. |
| Input validation at boundaries | PASS | Empty, null, and unknown inputs return a defined result (tests). |
| Error handling remains explicit | PASS | Dependency-failure deny path covered by existing suites. |
| Configuration / path handling is safe | PASS | Join-Path from PSScriptRoot; no absolute or drive-letter paths in tests. |
| Research Log | PASS | research.2026-11-09T22-58.md; no new external research. |
| Verdict | PASS | Ready for the orchestrator commit and CI. |

## Feature Audit Template

| Item | Status | Evidence |
|---|---|---|
| Scope and Baseline | PASS | MB = merge base of origin/main and HEAD; working tree compared with MB (E/qa-gates/scope-check.2026-11-10T00-57.md). |
| Requirements source | PASS | spec.md (Work Mode full-bug; no user-story.md). |
| Acceptance Criteria Inventory | PASS | 26 checkbox criteria under spec.md Acceptance Criteria. |
| Acceptance Criteria Evaluation | PASS | 26 PASS, 0 PARTIAL, 0 UNVERIFIED, 0 FAIL; per-criterion evidence in the spec check-off. |
| Acceptance Criteria Check-Off | PASS | 26 of 26 checked in spec.md. |
| AC Status Summary | PASS | Source spec.md; total 26; checked 26; remaining 0. |
