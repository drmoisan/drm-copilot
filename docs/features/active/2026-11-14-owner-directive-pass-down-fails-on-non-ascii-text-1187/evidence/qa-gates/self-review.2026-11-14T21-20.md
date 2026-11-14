# Self-Review (P3-T5)

Timestamp: 2026-11-14T21-20
Command: walk of docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md, code-review.yyyy-MM-ddTHH-mm.md, and feature-audit.yyyy-MM-ddTHH-mm.md against `git diff $(git merge-base origin/main HEAD) HEAD` (11 non-docs files, 728 insertions, 50 deletions)
EXIT_CODE: 0
Output Summary: every checklist item is PASS or N/A; no FAIL row. Languages in scope: PowerShell (production and tests). No Python, TypeScript, C#, Bash, or JSON file changed.

Scope: .claude/hooks/invoke-pretooluse-dispatch.ps1, .codex/hooks/invoke-pretooluse-dispatch.ps1, their two bundle copies under extensions/drm-copilot/resources/, and seven test files (one new).

## Policy audit template

### Summary table and coverage evidence checklist
| Item | Status | Evidence |
|---|---|---|
| PowerShell summary row | PASS | 4 production files (2 canonical, 2 byte copies), 7 test files; final gate 26567 passed, 0 failed (evidence/qa-gates/final-qc-pester.2026-11-14T21-17.md) |
| Python, Bash, JSON summary rows | N/A | no file of these languages changed |
| Coverage evidence: baseline recorded | PASS | evidence/baseline/pester.2026-11-14T18-59.md: dispatchers 37/37 and 35/35, repo-wide 95.96% |
| Coverage evidence: post-change recorded from the single gate run | PASS | final-qc-pester: dispatchers 42/42 and 40/40, repo-wide 95.96% |
| Coverage evidence: new-code coverage | PASS | every new reader and output line of both dispatchers is covered (100%) |

### 1. General unit test policy
| Item | Status | Evidence |
|---|---|---|
| 1.1 Independence | PASS | rows build their own in-memory streams, seams, and mocks; no row depends on another; the gates run 8 parallel shards |
| 1.1 Isolation | PASS | each It asserts one behavior (one decode case, one output stream, one hook decision) |
| 1.1 Fast execution | PASS | the four changed dispatcher and pass-down suites finished in one 162 s four-shard run including the process-level parity suite; the new rows are in-memory |
| 1.1 Determinism | PASS | fixed byte arrays, fixed clock seam, no wall clock, no console encoding assignment; characters built from code points |
| 1.1 Readability and maintainability | PASS | row names state the case and outcome; -ForEach tables name each character |
| 1.2 Baseline coverage documented | PASS | evidence/baseline/pester.2026-11-14T18-59.md |
| 1.2 No coverage regression | PASS | dispatchers 100% to 100%; repo-wide 43686/45525 to 43696/45535 (95.96% both) |
| 1.2 Changed files meet thresholds | PASS | both changed production files at 100% (threshold 85%) |
| 1.2 New code coverage at least 90% | PASS | 100% of new lines, including the default OpenStream seam line |
| 1.2 Comprehensive coverage | PASS | readers: three characters, BOM, invalid byte, disposal, default seam; outputs: decision, trace, tail emit; defaults: AST rows |
| 1.2 Positive flows | PASS | exact decode of U+2014, U+201C/U+201D, U+1F600; verbatim relay allowed; valid appends and decisions accepted |
| 1.2 Negative flows | PASS | substituted relay denied; edited ledger line denied; altered-digest append denied; mismatched B5 digest rejected; Latin1 decode denied |
| 1.2 Edge cases | PASS | leading BOM, invalid byte 0xFF, non-BMP surrogate pair |
| 1.2 Error handling | PASS | invalid byte maps to U+FFFD without throwing; dependency-failure deny path covered |
| 1.2 Concurrency | N/A | the readers and writers are single-call and hold no shared state |
| 1.2 State transitions | N/A | no stateful component changed |
| 1.3 Clear failure messages | PASS | -Because text on the ASCII assertions and on the parity row |
| 1.3 Arrange-Act-Assert | PASS | multi-step rows carry Arrange, Act, Assert comments; one-line rows are single act-and-assert |
| 1.3 Document intent | PASS | file headers state the seams used; Describe names carry issue #1187 |
| 1.4 Avoid external dependencies | PASS | no network, no file write, no temporary file; the default-seam rows open stdin and dispose it without reading |
| 1.4 Use mocks and stubs | PASS | Read-ClaudeHookRawPayload, Read-CodexPreToolUseDispatchStandardInput, Invoke-HookDispatchRunner, Invoke-CodexHookDispatchRunner, Get-HookDependencyFailureDecision, and the existing pass-down seams |
| 1.4 Environment stability | PASS | no [Console]::SetIn, no InputEncoding or OutputEncoding assignment (evidence/qa-gates/ac-verification.2026-11-14T21-19.md check 3); leak scan 0 failures |
| 1.5 Pre-submission review | PASS | this document |

### 2. General code change policy
| Item | Status | Evidence |
|---|---|---|
| 2.1 Clarify the objective | PASS | issue #1187, spec.md AC-1 to AC-20 |
| 2.1 Read existing change plans | PASS | plan.2026-11-14T13-12.md executed in order |
| 2.1 Document the plan | PASS | plan file, task-check and gate evidence, commit messages |
| 2.2 Simplicity first | PASS | one StreamReader with an explicit UTF8Encoding; one parameter added to three ConvertTo-Json calls per dispatcher |
| 2.2 Reusability | PASS | the Claude reader plugs into the existing Read-ClaudeHookRawPayload seam, keeping its probe and fallbacks |
| 2.2 Extensibility | PASS | OpenStream seam allows any stream |
| 2.2 Separation of concerns | PASS | byte decode isolated in the reader; dispatch logic unchanged |
| 2.3 Cohesive modules | PASS | readers live in the dispatcher that uses them; the Codex copy is required because Codex hooks do not dot-source .claude files (help text states this) |
| 2.3 At or below the 800-line hard limit | PASS | largest changed file 423 lines; dispatchers 160 and 147 (ac-verification check 1) |
| 2.3 Public vs internal | PASS | no exported module surface changed |
| 2.3 No circular dependencies | PASS | no new dot-source or import edge |
| 2.4 Descriptive names | PASS | Read-PreToolUseDispatchStandardInput, Read-CodexPreToolUseDispatchStandardInput |
| 2.4 Docs | PASS | comment-based help on both readers; script help states UTF-8, ASCII, and per-process scope |
| 2.4 Comment why, not what | PASS | test comments explain why the mock builds its reason inline and why the default seam is not read |
| 2.5 Formatting | PASS | evidence/qa-gates/final-qc-static-powershell.2026-11-14T21-05.md: 0 files rewritten |
| 2.5 Linting | PASS | 0 PSScriptAnalyzer findings |
| 2.5 Type checking | N/A | PowerShell |
| 2.5 Testing | PASS | final Pester gate 0 failed; final pytest gate 0 failed |
| 2.5 Full toolchain loop | PASS | final loop clean in one pass; the Phase 1 gate needed two passes (discovery-guard probe row), recorded in evidence/qa-gates/phase-gate.P1.2026-11-14T20-19.md |
| 2.5 Explicit reporting | PASS | every command and exit code is recorded under evidence/ |
| 2.6 Summarize changes | PASS | commit messages of the three phase commits |
| 2.6 Design choices explained | PASS | spec D-1 to D-11; reader help |
| 2.6 Update supporting documents | PASS | dispatcher help; spec AC check-off; no brief fact changed (AC-18) |
| 2.6 Provide next steps | PASS | AC-20 CI part pending at S9 |

### 3. Language-specific code change policy
| Item | Status | Evidence |
|---|---|---|
| 3A Python items (Black, Ruff, Pyright, Pytest tooling; typing; dataclasses; protocols; utility classes; exceptions; logging; invariants) | N/A | no Python file changed; the pytest gate still ran and passed |
| 3B.1 Formatting with Invoke-Formatter | PASS | Invoke-PoshQCFormat check mode over the repository: 0 to format, 1753 already formatted (phase-gate.P2) |
| 3B.1 Linting with PSScriptAnalyzer | PASS | Invoke-PoshQCAnalyze: no findings |
| 3B.1 Fix all findings | PASS | none open |
| 3B.1 PowerShell 5.1 and 7.6+ compatible | N/A | the hooks are registered to run under pwsh 7 and .claude/rules/powershell.md requires PowerShell 7+; -EscapeHandling exists in PowerShell 7 |
| 3B.2 Advanced functions | PASS | both readers carry CmdletBinding and OutputType([string]) |
| 3B.2 Parameter validation | PASS | single scriptblock parameter with a safe default |
| 3B.2 Avoid global state | PASS | no global or script-scoped state added |
| 3B.2 Error handling | PASS | try/finally disposes the reader; decode errors replaced, not thrown, by design (D-2 in spec) |
| 3B.3 Cohesive and at or below the 800-line hard limit | PASS | see 2.3 |
| 3B.3 Approved verbs | PASS | Read |
| 3B.3 Comment why | PASS | see 2.4 |
| 3B.4 Step 1 format | PASS | 0 rewritten |
| 3B.4 Step 2 analyze | PASS | 0 findings |
| 3B.4 Step 3 type check | N/A | PowerShell |
| 3B.4 Step 4 test | PASS | 26567 passed, 0 failed |
| 3B.4 Rerun loop if needed | PASS | final loop one pass |
| 3C Bash items (shfmt, shellcheck, bats, shebang, error handling, size) | N/A | no Bash file changed |
| 3D JSON items (formatting, schema, $schema, strict JSON, key order) | N/A | no JSON file changed |

### 4. Language-specific unit test policy
| Item | Status | Evidence |
|---|---|---|
| 4A Python items | N/A | no Python test changed |
| 4B.1 Use Pester v6.x | PASS | Describe, It, -ForEach, BeforeAll, Mock, Should -Invoke |
| 4B.1 Use PoshQC configuration | PASS | Invoke-PoshQCParallelTest through the launcher pester suite |
| 4B.1 PowerShell 5.1 and 7.6+ compatible | N/A | test files declare #Requires -Version 7.0 |
| 4B.2 Focused unit tests | PASS | 61 new rows, each one behavior |
| 4B.2 Test behavior over implementation | PASS | rows assert decoded text, emitted characters, and hook decisions; the AST rows pin the default seam the spec names (AC-2, AC-3) |
| 4B.2 Mocking used sparingly | PASS | only the reader, runner, and dependency seams are mocked |
| 4B.2 Organization | PASS | tests under tests/scripts/claude-hooks, tests/scripts/codex-hooks, and tests/scripts/claude-lib mirror the hook and lib folders |
| 4B.3 File naming | PASS | *.Tests.ps1 |
| 4B.3 Describe/Context/It structure | PASS | new Describe blocks per behavior group |
| 4B.3 Logical grouping | PASS | reader, output, relay, ledger, decision, contrast groups |
| 4B.3 Docstrings/comments | PASS | NonAscii file header and row comments |
| 4B.4 Use PoshQC test command | PASS | launcher pester suite |
| 4B.4 No alternative test runners | PASS | none |

### 5 to 10 and appendices
| Item | Status | Evidence |
|---|---|---|
| 5 Test coverage detail | PASS | per-function rows listed in ac-verification and phase-gate.P2 |
| 6 Test execution metrics | PASS | final gate 665.58 s, 8 workers; pytest 56.20 s |
| 7 Code quality checks | PASS | format, analyze, leak scan clean |
| CI cross-check | N/A | CI runs on the PR head at S9 (AC-20 CI part) |
| 8 Identified gaps | PASS | none open; deviations recorded (default-seam rows, integration-lane suite CI-only) |
| 8 Approved exceptions | N/A | none |
| 8 Removed or skipped tests | PASS | none removed; the two script-tail rows were updated as the plan states; skips unchanged (18) |
| 9 Summary of changes | PASS | commit messages |
| 10 Compliance verdict | PASS | fully compliant for the local scope |

## Code review template
| Item | Status | Evidence |
|---|---|---|
| Findings table | PASS | no Blocker or Major finding; Info: the per-process isolation mode is not covered by the decode fix, stated in the Claude dispatcher help (AC-19) |
| Python implementation audit | N/A | no Python |
| TypeScript implementation audit | N/A | no TypeScript |
| PowerShell: what changed well | PASS | the Claude reader reuses Read-ClaudeHookRawPayload's seam, so probe and fallbacks are unchanged; output escaping removes the console output encoding dependency |
| PowerShell: API and safety notes | PASS | advanced functions, approved verb, no ShouldProcess needed (read-only) |
| PowerShell: error handling and logging | PASS | reader disposal in finally; dependency-failure path unchanged apart from escaping |
| C# implementation audit | N/A | no C# |
| Reviewed test and QA artifacts | PASS | fail-before, task checks, phase gates, final gates |
| Determinism | PASS | see 1.1 |
| Isolation | PASS | see 1.1 |
| Speed | PASS | see 1.1 |
| Diagnostics | PASS | see 1.3 |
| No secrets in code | PASS | none |
| No unsafe subprocess or command construction | PASS | no process start added |
| Input validation at boundaries | PASS | invalid UTF-8 replaced, BOM stripped |
| Error handling remains explicit | PASS | no catch added |
| Configuration and path handling is safe | PASS | no path handling added |
| Research log | PASS | research/research.2026-11-14T18-14.md |
| Verdict | PASS | ready for PR |

## Feature audit template
| Item | Status | Evidence |
|---|---|---|
| Scope and baseline | PASS | evidence/baseline/ (static, Pester, pytest) |
| Acceptance criteria inventory | PASS | spec.md AC-1 to AC-20 |
| AC-1 to AC-19 evaluation | PASS | evidence/qa-gates/ac-verification.2026-11-14T21-19.md |
| AC-20 evaluation | PASS (local part) | CI part pending at S9; not checked off |
| Summary | PASS | 19 of 20 checked |
| Acceptance criteria check-off | PASS | spec.md AC-1 to AC-19 checked; AC-20 unchecked with a note |
| AC status summary | PASS | spec.md: total 20, checked 19, unchecked 1 (AC-20) |

Correction (appended 2026-11-14T21-21): the 3B.2 Error handling row cites "D-2 in spec" for the invalid-byte replacement; that behavior is stated by AC-1 (maps an invalid byte to U+FFFD without throwing), not by D-2, which places the Codex dispatcher in scope. The row status is unchanged.
