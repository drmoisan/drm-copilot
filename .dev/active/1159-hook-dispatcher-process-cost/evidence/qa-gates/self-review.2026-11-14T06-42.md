# Self-review against the policy-audit, code-review and feature-audit templates ([P7-T9])

Timestamp: 2026-11-14T06-42
Command: walk of docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md, code-review.yyyy-MM-ddTHH-mm.md and feature-audit.yyyy-MM-ddTHH-mm.md against git diff 063504dc4b2ea08a2c5bd39b57d70ce5963815ed HEAD (merge base recomputed after [P7-T1]; 200 paths); figures read from the final-QC records listed below
EXIT_CODE: 0
Output Summary: 0 FAIL rows. Every checklist item is PASS or N/A. Two criteria remain open by design and are not FAIL rows: the pull-request cost quotation (one spec criterion and one user-story criterion; PR authoring uses evidence/other/pr-cost-summary.2026-11-14T06-36.md) and the Linux hook-suite CI result (CI-dependent).

Records read: evidence/qa-gates/powershell-static.2026-11-14T06-12.md, python-static.2026-11-14T06-12.md, pester.2026-11-14T06-25.md, pytest.2026-11-14T06-32.md, leak-scan.2026-11-14T06-33.md, consistency.2026-11-14T06-38.md; evidence/regression-testing/hook-process-cost.2026-11-14T06-35.md; evidence/other/pr-cost-summary.2026-11-14T06-36.md, main-integration.2026-11-14T06-37.md, d6-module-audit.2026-11-14T04-58.md; baselines evidence/baseline/pester.2026-11-10T04-30.md, pytest.2026-11-11T04-11.md, leak-scan.2026-11-10T04-33.md, hook-process-cost.2026-11-11T04-27.md.

## Policy audit: coverage summary and evidence checklist
| Item | Result | Evidence |
|---|---|---|
| PowerShell row (files, tests, result, baseline, post-change, new code) | PASS | 126 .ps1/.psm1 changed; Pester 23977 tests, 0 failed; repo line 95.80% -> 95.96%; new production files aggregate 631/640 = 98.6% |
| Python row | PASS | 3 test files changed, no production Python; pytest 16723 passed, 0 failed; line 97.11% -> 97.13%, branch 94.37% -> 94.42% |
| Bash row | N/A | no shell script changed |
| JSON row | PASS | 2 registries, settings.json and 2 core.json files are parsed by the parity, settings and manifest tests, all passing |
| TypeScript baseline and post-change artifacts | N/A | N/A - out of scope (no TypeScript change) |
| PowerShell baseline coverage artifact | PASS | evidence/baseline/pester.2026-11-10T04-30.md |
| PowerShell post-change coverage artifact | PASS | evidence/qa-gates/pester.2026-11-14T06-25.md |
| Per-language comparison summary | PASS | per-file table in pester.2026-11-14T06-25.md; totals in pytest.2026-11-14T06-32.md |

## Policy audit: 1 General unit test policy
| Item | Result | Evidence |
|---|---|---|
| Independence | PASS | one parallel Invoke-PoshQCParallelTest and one pytest -n auto run green; leak scan 0 failures with no allowlist change |
| Isolation | PASS | one behavior per It in the new suites (dispatcher modules, runner, entry scripts, one parity row per envelope) |
| Fast execution | PASS | parity suite about 2 minutes for 26 envelopes with concurrent processes; unit suites run in milliseconds |
| Determinism | PASS | in-memory payloads and registries; no clock value asserted; parity compares two runs of the same envelope |
| Readability and maintainability | PASS | Arrange/Act/Assert comments, descriptive It names, synopsis headers |
| Baseline coverage documented | PASS | pester.2026-11-10T04-30.md, pytest.2026-11-11T04-11.md |
| No coverage regression | PASS | none of the 47 changed production PowerShell files is below its baseline in run 3; repo-wide figures rose for both languages |
| Changed files meet thresholds | PASS | every changed production file at or above 85%; lowest .claude/hooks/enforce-evidence-locations.ps1 89.13% (unchanged since baseline) |
| New code coverage >= 90% | PASS | HookDispatch.psm1 107/107 100%; HookDispatchRunner.psm1 84/85 98.82%; .codex/hooks/hook-dispatch.ps1 154/155 99.35%; .claude/hooks/invoke-pretooluse-dispatch.ps1 37/37 100%; .codex/hooks/invoke-pretooluse-dispatch.ps1 35/35 100%; HookProcessCost.psm1 176/177 99.44%; Measure-HookProcessCost.ps1 38/44 86.36%; aggregate 631/640 = 98.6%. The six uncovered lines of Measure-HookProcessCost.ps1 are its default process-start and file-write seams and the script tail of a thin host entry point, kept in the denominator per the Coverage Exclusion Policy |
| Comprehensive coverage | PASS | matcher classes, combiner rules, registry failures, isolation modes, payload anomalies, script tails |
| Positive flows | PASS | allow envelopes and allow/none combination rows |
| Negative flows | PASS | missing or invalid registry, missing hook file, missing tool_name, missing tool_input envelopes |
| Edge cases | PASS | empty and '*' matchers, apply_patch alias, even and odd medians, exit-sentinel mapping |
| Error handling | PASS | terminating error gives no decision and later hooks still run; dependency-failure decisions for both entry scripts |
| Concurrency | PASS | parity starts hook processes concurrently with asynchronous stream reads; the runner holds no shared mutable state |
| State transitions | N/A | no stateful component |
| Clear failure messages | PASS | parity collects one mismatch line per hook and field; registration rows use -Because |
| Arrange-Act-Assert pattern | PASS | new rows carry Arrange/Act/Assert comments |
| Document intent | PASS | suite headers state purpose; It names state behavior |
| Avoid external dependencies | PASS | no network; no envelope reaches gh (probe with a recording gh stand-in found no call) |
| Use mocks or stubs | PASS | runner, process starter, readers and trace writer are seams stubbed in the unit suites |
| Environment stability | PASS | envelope environment variables are set only on child ProcessStartInfo; [Console] streams restored in finally |
| Pre-submission review | PASS | this record |

## Policy audit: 2 General code change policy
| Item | Result | Evidence |
|---|---|---|
| Clarify the objective | PASS | spec.md and the plan |
| Read existing change plans | PASS | plan.2026-11-09T16-31.md executed in order |
| Document the plan | PASS | plan checked off on disk with a task-check record per task |
| Simplicity first | PASS | registry in the settings shape; one runner; branchless script tails |
| Reusability | PASS | dispatch logic in HookDispatch.psm1 shared by the entry script and the tests |
| Extensibility | PASS | isolation knob with a per-process default; new hooks register in the registry |
| Separation of concerns | PASS | pure module (HookDispatch), runner with I/O seams, thin entry scripts |
| Cohesive modules | PASS | module split per [P2-T1] and [P2-T2] |
| At or below the 800-line hard limit | PASS | largest changed code file 593 lines; the stored ledger patch (3492 lines, data) keeps its merge-base line count |
| Public versus internal | PASS | Export-ModuleMember lists only the public functions |
| No circular dependencies | PASS | HookDispatchRunner imports HookDispatch only |
| Descriptive names | PASS | Verb-Noun names; registry keys follow the settings shape |
| Docs and docstrings | PASS | comment-based help on every function |
| Comment why, not what | PASS | comments state the rationale (decision numbers, issue references) |
| 1. Formatting | PASS | powershell-static.2026-11-14T06-12.md 0 files changed; python-static.2026-11-14T06-12.md files unchanged |
| 2. Linting | PASS | PSScriptAnalyzer 0 findings; Ruff 0 findings |
| 3. Type checking | PASS | Pyright 0 errors; not applicable to PowerShell |
| 4. Testing | PASS | Pester run 3 and the pytest gate green |
| Full toolchain loop | PASS | the loop restarted after runs 1 and 2 (both recorded) and closed on a clean pass |
| Explicit reporting | PASS | each gate record carries Timestamp, Command, EXIT_CODE and Output Summary |
| Summarize changes | PASS | one commit message per phase; integration record |
| Design choices explained | PASS | architecture document paragraph and brief bullet |
| Update supporting documents | PASS | README.md, docs/engineering/claude-code-architecture.md, six brief copies |
| Provide next steps | PASS | PR cost summary and open items below |

## Policy audit: 3A Python (test files only)
| Item | Result | Evidence |
|---|---|---|
| Formatting with Black | PASS | 3 files unchanged |
| Linting with Ruff | PASS | all checks passed |
| Type checking with Pyright | PASS | 0 errors |
| Testing with Pytest | PASS | 16723 passed |
| Strong typing | PASS | registry_hook_paths and the new test are fully annotated |
| Dataclasses for value objects | N/A | no value object added |
| Protocols or ABCs for interfaces | N/A | none needed |
| Avoid utility classes | PASS | functions only |
| Specific exceptions | N/A | no exception handling added |
| Logging over print | N/A | no output added |
| Invariants at construction | N/A | no class added |

## Policy audit: 3B PowerShell
| Item | Result | Evidence |
|---|---|---|
| Formatting with Invoke-Formatter | PASS | 0 files changed |
| Linting with PSScriptAnalyzer | PASS | 0 findings |
| Fix all findings | PASS | task-check findings fixed (unused variable, indentation, ShouldProcess verb, assignment alignment) |
| PowerShell 5.1 and 7.6+ compatible | PASS | the repository targets PowerShell 7; no construct beyond the repository baseline |
| Advanced functions | PASS | CmdletBinding on the module functions |
| Parameter validation | PASS | Mandatory, ValidateSet and AllowNull attributes |
| Avoid global state | PASS | the runner restores the exit sentinel, the console streams and the location; no global variable |
| Error handling | PASS | registry failures and guard load failures fail closed (HOOK_DISPATCH_BLOCKED or exit 2) |
| Cohesive and at or below the 800-line hard limit | PASS | largest new module 299 lines |
| Approved verbs | PASS | analyzer clean (Start-ParityProcess renamed Invoke-ParityProcess) |
| Comment why | PASS | tail and seam comments state the rationale |
| Step 1: Format | PASS | as above |
| Step 2: Analyze | PASS | as above |
| Step 3: Type check | N/A | not applicable to PowerShell |
| Step 4: Test | PASS | Pester run 3 |
| Rerun loop if needed | PASS | runs 1 and 2 did not meet acceptance; the loop reran to run 3 |

## Policy audit: 3C Bash and 3D JSON
| Item | Result | Evidence |
|---|---|---|
| Formatting with shfmt | N/A | no bash file |
| Linting with shellcheck | N/A | no bash file |
| Testing with bats | N/A | no bash file |
| Portable shebang | N/A | no bash file |
| Error handling (bash) | N/A | no bash file |
| At or below the 800-line hard limit (bash) | N/A | no bash file |
| Formatting with jq | PASS | registries are generator output in the ConvertTo-Json two-space layout, reproduced byte for byte |
| Schema validation | PASS | registry schema enforced by Read-HookDispatchRegistry and the parity settings-shape row |
| Required $schema | N/A | the registry follows the settings shape, which has no $schema key |
| Strict JSON only | PASS | parsed by ConvertFrom-Json in the tests |
| Deterministic key order | PASS | the generator emits isolation, notes and hooks in a fixed order |

## Policy audit: 4A Python and 4B PowerShell unit test policy
| Item | Result | Evidence |
|---|---|---|
| Use Pytest | PASS | |
| Coverage expectation | PASS | repo-wide 97.13% line; the change is test-only |
| Focused unit tests (Python) | PASS | test_guard_reports_registry_hook_absent_from_manifest uses in-memory text |
| Mocking sparingly (Python) | PASS | no mock added |
| Organization (Python) | PASS | tests/scripts/dev_tools |
| Naming conventions | PASS | test_ prefix, descriptive names |
| Docstrings and comments (Python) | PASS | docstrings on the new test and helper |
| Use Pytest (toolchain) | PASS | pytest -n auto |
| No alternative test runners (Python) | PASS | |
| Use Pester v6.x | PASS | Invoke-PoshQCParallelTest |
| Use PoshQC configuration | PASS | branch-current PoshQC.psd1 |
| PowerShell 5.1 and 7.6+ compatible (tests) | PASS | suites declare #Requires -Version 7.0 as the repository does |
| Focused unit tests (PowerShell) | PASS | one behavior per It |
| Test behavior over implementation | PASS | parity compares observable decisions; tail rows assert the emitted JSON |
| Mocking used sparingly | PASS | seams stubbed only at I/O boundaries |
| Organization (PowerShell) | PASS | mirrored paths under tests/scripts/claude-lib/hook-dispatch, claude-hooks, codex-hooks and dev-tools |
| File naming *.Tests.ps1 | PASS | the two corpus files are .ps1 data files invoked by the suite |
| Describe/Context/It structure | PASS | |
| Logical grouping | PASS | registration shape, per-hook parity, module loading |
| Docstrings and comments (PowerShell) | PASS | headers present |
| Use PoshQCTest command | PASS | parallel gate |
| No alternative test runners (PowerShell) | PASS | |

## Policy audit: 6 and 7 metrics and quality checks, 8 gaps
| Item | Result | Evidence |
|---|---|---|
| Total, passed and failed tests | PASS | Pester 23977 with 0 failed; pytest 16723 with 0 failed |
| Execution time | PASS | Pester 627.5 s wall with 8 workers; pytest 248.84 s |
| Test file size | PASS | largest test file 593 lines |
| Black, Ruff, Pyright and Pytest commands | PASS | python-static and pytest records |
| Invoke-Formatter, PSScriptAnalyzer and Pester commands | PASS | powershell-static and pester records |
| CI cross-check | N/A | CI runs on the PR head, which does not exist before PR authoring |
| Identified gaps | PASS | listed below; none blocking |
| Removed or skipped tests | PASS | no test removed; the 6 new skipped rows are the named 'has parity envelopes for <hook leaf>' reports |

## Code review checklist
| Item | Result | Evidence |
|---|---|---|
| No secrets in code | PASS | diff inspected; no credential or token |
| No unsafe subprocess or command construction | PASS | the runner's single & call targets a registry-resolved, leaf-validated (lowercase .ps1 leaf), existing hooks-folder file, admitted by carve-out (c) of the no-Python helper; per-process mode uses ProcessStartInfo.ArgumentList |
| Input validation at boundaries | PASS | payload read once and parsed defensively; a missing tool_name denies |
| Error handling remains explicit | PASS | fail-closed HOOK_DISPATCH_BLOCKED; exit 2 on a guard load failure |
| Configuration and path handling is safe | PASS | registry paths resolved beside the dispatcher; Join-Path throughout |
| PowerShell: what changed well | PASS | in-process dispatch with stream capture and restore |
| PowerShell: API and safety notes | PASS | the decision functions return the decision first (S6) and pass per-hook results through -ResultSink |
| PowerShell: error handling and logging | PASS | per-hook trace with -PerHookTrace |
| Python implementation audit | N/A | no production Python |
| TypeScript and C# implementation audits | N/A | out of scope |
| Determinism, isolation, speed and diagnostics prompts | PASS | see section 1 rows |

## Feature audit: acceptance criteria (spec.md and user-story.md)
| Item | Result | Evidence |
|---|---|---|
| Measurement tool and its tests | PASS | HookProcessCost.Tests.ps1 and Measure-HookProcessCost.Tests.ps1 green in run 3 |
| Before and after reports, append-only, four fields | PASS | baseline/hook-process-cost.2026-11-11T04-27.md (one commit, never edited); regression-testing/hook-process-cost.2026-11-14T06-35.md |
| Process counts: before equals the inventory, after equals 1 | PASS | both reports |
| Single Claude registration, union matcher, no timeout | PASS | 'registers a single PreToolUse dispatcher entry without a timeout key'; parity registration rows |
| Single Codex table, command and command_windows, timeout sum | PASS | 'registers one PreToolUse table invoking the dispatcher in command and command_windows' |
| Registries reproduce the merged registrations in the settings shape with existing files | PASS | consistency.2026-11-14T06-38.md; parity settings-shape row |
| Matcher semantics per runtime | PASS | HookDispatch.Tests.ps1 and the Codex hook-dispatch.Tests.ps1 |
| In-process isolation, payload read once, no environment write | PASS | runner and entry-script rows |
| Shared modules load once except recorded stateful modules | PASS | 'loads each stateless shared module once per call' on both runtimes; trace check of Claude Bash, Agent and Write and Codex Bash and apply_patch calls found no module loaded twice; d6-module-audit records 0 stateful modules |
| No short-circuit | PASS | 'runs every later hook when the first hook denies' |
| No decision function, deny code or reason text edited; per-hook suites pass | PASS | hook edits are the D6 -Force removals and the D13 tails (the plan's stated, separately evidenced exception); existing per-hook tests unchanged (tail rows added) and green in run 3 |
| Parity suite enumerates at test time and compares per-hook and combined outcomes | PASS | 26 envelope rows green in run 3 on Windows |
| Corpus has allow and deny envelopes per hook without filesystem mocks; the rest are named | PASS | 6 skipped rows named with reasons |
| Combination rules (D4) | PASS | HookDispatch.Tests.ps1 |
| Isolation absent means per-process; shipped registries are in-process | PASS | 'runs each hook as a child process when isolation is absent'; 'ships both registries with isolation set to in-process' |
| Fail-closed self-failure and guard completeness | PASS | HOOK_DISPATCH_BLOCKED rows; hook-dependency-guard-completeness green |
| D13 baseline record and fail-open report | PASS | baseline/d13-tail-output.2026-11-11T04-37.md; regression-testing/d13-remediation.2026-11-11T04-48.md |
| Python-invocation guard carve-out | PASS | enforcement-hooks-no-python-invocation suite green |
| PR body quotes the cost reports | N/A | the PR is not authored yet; source evidence/other/pr-cost-summary.2026-11-14T06-36.md; criterion left unchecked |
| Bundle copies are byte-identical | PASS | 51 pairs equal |
| Both core.json files list the new files; contract tests pass | PASS | pytest gate; Codex generator --check exit 0 |
| README, architecture document and six brief copies | PASS | brief SHA-256 689652247366b3202d8c589ecbffbfd7ec2347cd90634ce82ac6591d40650e90 |
| Registration-shape tests read the registry; the dependency helper enumerates registries | PASS | Phase 4 suites green; suite counts not lower than at baseline |
| pr-author frontmatter hook and non-PreToolUse registrations unchanged | PASS | settings outside PreToolUse equal at the merge base; config outside PreToolUse equal; .claude/agents/pr-author.md has no diff |
| Gates pass with no new allowlist entry, 85% per file, no file at 801 lines | PASS | run 3, pytest, leak scan, consistency records |
| Linux hook-suite CI job | N/A | CI-dependent; left unchecked for the CI green gate |

## Identified gaps and observations (non-blocking)
- origin/main advanced after [P7-T1] to 2c8dee6dd (issue 1169: preimplementation gate docs helper, docs hooks, DocsCompleteGate.psm1); the plan assigns this to the orchestrator's main sync.
- .claude/hooks/enforce-owner-directive-pass-down.ps1 (issue 1157) ends a missing-tool_input payload in a terminating error (exit 1, non-blocking) in both modes; this is the hook's existing behavior and is reported.
- .claude/hooks/enforce-pr-author-skill-helpers.ps1 and .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 keep unguarded Import-Module -Force lines (outside the D6 set definition); measured per-call traces show no module loaded twice.
