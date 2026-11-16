# Self-review (P2-T4, remediation cycle 1)

Timestamp: 2026-11-15T20-08
Plan: remediation-plan.2026-11-14T23-56.md
Command: walk of docs/features/templates/policy_audit/policy-audit, code-review, and feature-audit templates against git diff <merge-base> HEAD (merge base = git merge-base origin/main HEAD), spec.md AC-1..AC-15 (version 0.3), and remediation-inputs.2026-11-14T23-52.md
EXIT_CODE: 0
Output Summary: no FAIL row. Every policy-audit, code-review, and feature-audit checklist item is PASS or N/A; AC-1..AC-15 PASS (AC-2, AC-6, and AC-14 checked in spec.md by this task); R1 and every non-remediation note are dispositioned; the boundary row passes.

Inputs: evidence/remediation-baseline/powershell-static.2026-11-15T18-01.md, evidence/regression-testing/fail-before-r1.2026-11-15T18-51.md and fail-before-v3-correction.2026-11-15T18-51.md, evidence/qa-gates/phase-gate.P1.2026-11-15T19-40.md, final-qc-powershell-static.2026-11-15T19-42.md, final-qc-pester.2026-11-15T20-04.md, final-qc-pytest.2026-11-15T20-06.md, and the task checks P0-T1 through P1-T7 of this cycle.

## Policy audit template

| Item | Status | Evidence |
|---|---|---|
| Language summary: PowerShell | PASS | 27 changed .ps1 files against the merge base; Pester 27268 tests, 0 failed; repo line coverage 95.96% (Phase 0) -> 96.05%; classify copies 100% |
| Language summary: Python | N/A | no Python file changed; no `.py` file added |
| Language summary: Bash | N/A | no tracked shell file changed (helpers are untracked under artifacts/) |
| Language summary: JSON | PASS | two core.json files gain one entry each; manifest completeness and dependency-closure suites pass |
| 1.1 Independence | PASS | classify rows are pure; gate rows register mocks per row; I2 resets `$script:HookDependencyFailures` in `finally`; parallel gate green |
| 1.1 Isolation | PASS | one function row or classification row per command; one gate row per ID and form |
| 1.1 Fast execution | PASS | classify rows are in-memory string checks |
| 1.1 Determinism | PASS | no clock, file, process, or network access; the P1 gate and the final gate report identical counts |
| 1.1 Readability and maintainability | PASS | data-only `enforce-orchestration-preimplementation-gate-classify.Cases.ps1` with Kind labels; It names carry the command |
| 1.2 Baseline coverage documented | PASS | evidence/baseline/pester-gate.2026-11-14T21-02.md, recorded by derivation in the remediation baseline |
| 1.2 No coverage regression | PASS | final-qc-pester: epic-scope 97.73% -> 97.79% and 98.01% -> 98.09%; repo-wide 95.96% -> 96.05% |
| 1.2 Changed files meet thresholds | PASS | classify 100%, operands 100%, gates 96.57% and 100%, epic-scope 97.79% and 98.09% |
| 1.2 New code coverage at least 90% | PASS | classify copies 51/51; every changed executable line of the five named files has `ci` above 0 (ZERO_TOTAL=0) |
| 1.2 Comprehensive coverage | PASS | 29 function rows and 27 classification rows per surface, plus V3, N3, and two bash G-rows |
| 1.2 Positive flows | PASS | 14 Positive classification rows; N3 ready; 15 positive function rows |
| 1.2 Negative flows | PASS | 10 Negative classification rows; 14 near-miss function rows; N3 not ready; V3 deny rows |
| 1.2 Edge cases | PASS | nested and chained substitutions, unclosed substitution, backtick and `${` forms, `which` mention host, empty command |
| 1.2 Error handling | PASS | I2 (classify dot-source failure denies naming the file); I1 unchanged |
| 1.2 Concurrency | N/A | no concurrent code |
| 1.2 State transitions | N/A | stateless classification |
| 1.3 Clear failure messages | PASS | `-Because` on classification and function assertions |
| 1.3 Arrange-Act-Assert | PASS | Act/Assert comments on every row; Arrange on I2 |
| 1.3 Document intent | PASS | suite and Cases headers describe each table and Kind |
| 1.4 Avoid external dependencies | PASS | no seam beyond the gate's existing mocks |
| 1.4 Use mocks and stubs | PASS | epic-state baseline mocks as the operands suites |
| 1.4 Environment stability | PASS | `/synthetic-worktrees/...` roots; no drive letter; Linux-safe |
| 1.5 Pre-submission review | PASS | this file |
| 2.1 Clarify the objective | PASS | remediation-inputs finding R1 and spec v0.3 |
| 2.1 Read existing change plans | PASS | remediation-plan executed in order |
| 2.1 Document the plan | PASS | every task checked off with a task check |
| 2.2 Simplicity first | PASS | two pure functions in one sibling; each gate gains one dot-source, one statement, and one disjunct |
| 2.2 Reusability | PASS | reuses Read-CommandLineSegment, Test-CommandLineWordPresent, and the unchanged stage-1 pattern texts |
| 2.2 Extensibility | PASS | accepted npx options are one pattern; the join set is one pattern |
| 2.2 Separation of concerns | PASS | the classify sibling is pure; stage 2 and bookkeeping stay in the gate |
| 2.3 Cohesive modules | PASS | one sibling for the classification supplement |
| 2.3 At or below the 800-line hard limit | PASS | classify 116, operands 296, Claude gate 493, Codex gate 485, Codex epic-scope 491; tests 82/85/83/77 |
| 2.3 Public vs internal | PASS | one entry function plus one file-internal helper |
| 2.3 No circular dependencies | PASS | the classify sibling dot-sources nothing |
| 2.4 Descriptive names | PASS | Orchestration-Gate-prefixed names |
| 2.4 Docs and docstrings | PASS | comment-based help on both functions; file header names #1188, both forms, and the narrowed non-goal |
| 2.4 Comment why, not what | PASS | header states why the scanner split defeats stage 1 |
| 2.5 Formatting | PASS | final static: 0 drift on 27 files |
| 2.5 Linting | PASS | 0 PSScriptAnalyzer findings; leak scan 0 failures |
| 2.5 Type checking | N/A | PowerShell |
| 2.5 Testing | PASS | final Pester and pytest gates green |
| 2.5 Full toolchain loop | PASS | P1 gate and the final loop each clean in one pass |
| 2.5 Explicit reporting | PASS | one evidence file per step |
| 2.6 Summarize changes | PASS | phase commit messages |
| 2.6 Design choices explained | PASS | spec `### Remediation Decision R1 (cycle 1)`; task-check P1-T5 design note on segment joining |
| 2.6 Update supporting documents | PASS | execution-environment brief, six byte-identical copies |
| 2.6 Provide next steps | PASS | completion report notes the main advance that touches the brief |
| 3B.1 Formatting with Invoke-Formatter | PASS | settings file scripts/powershell/PoshQC/settings/pssa.settings.psd1 |
| 3B.1 Linting with PSScriptAnalyzer | PASS | 0 findings |
| 3B.1 Fix all findings | PASS | none open |
| 3B.2 PowerShell 5.1 and 7.6+ compatible | N/A | repository rule is PowerShell 7+; hooks run under pwsh 7 |
| 3B.2 Advanced functions | PASS | `[CmdletBinding()]` and `[OutputType()]` on both functions |
| 3B.2 Parameter validation | PASS | Mandatory with AllowEmptyString and AllowEmptyCollection |
| 3B.2 Avoid global state | PASS | script-scope pattern strings are read-only data |
| 3B.2 Error handling | PASS | a failed dot-source is recorded through Add-HookDependencyFailure and denies (I2) |
| 3B.3 Cohesive and at or below the 800-line hard limit | PASS | see 2.3 |
| 3B.3 Approved verbs | PASS | Get; PSUseApprovedVerbs clean |
| 3B.3 Comment why | PASS | see 2.4 |
| 3B.4 Step 1 Format | PASS | final static |
| 3B.4 Step 2 Analyze | PASS | final static |
| 3B.4 Step 3 Type check | N/A | PowerShell |
| 3B.4 Step 4 Test | PASS | final Pester gate |
| 3B.4 Rerun loop if needed | PASS | no rerun needed |
| 3D.1 Formatting with jq | N/A | entries inserted in the existing two-space style |
| 3D.1 Schema validation | N/A | pack manifests have no schema; completeness suites pass |
| 3D.2 Required $schema | N/A | not used by pack manifests |
| 3D.2 Strict JSON only | PASS | completeness suites parse both files |
| 3D.2 Deterministic key order | PASS | classify entry placed directly after the operands entry |
| 4B.1 Use Pester v6.x | PASS | Invoke-PoshQCParallelTest through the launcher |
| 4B.1 Use PoshQC configuration | PASS | launcher pester suite |
| 4B.1 PowerShell 5.1 and 7.6+ compatible | N/A | `#Requires -Version 7.0`, as the sibling suites |
| 4B.1 Focused unit tests | PASS | function rows target the classify function alone |
| 4B.1 Test behavior over implementation | PASS | classification rows assert `Test-ImplementationCommand` results; gate rows assert decisions and seam counts |
| 4B.1 Mocking used sparingly | PASS | classify rows need no mock beyond the shared baseline |
| 4B.2 Organization | PASS | suites under tests/scripts/claude-hooks and tests/scripts/codex-hooks mirror the hook folders |
| 4B.2 File naming *.Tests.ps1 | PASS | Cases file is data only |
| 4B.2 Describe/Context/It structure | PASS | one Describe, one Context for the function rows |
| 4B.3 Logical grouping | PASS | classification rows, function rows, and I2 separated |
| 4B.3 Docstrings and comments | PASS | suite and Cases headers |
| 4B.4 Use PoshQCTest command | PASS | Invoke-PoshQCParallelTest via the launcher |
| 4B.4 No alternative test runners | PASS | launcher only |
| 6 Test execution metrics | PASS | 27268 tests, 0 failed, 706.99 s wall clock over 8 workers |

## Code review template

| Item | Status | Evidence |
|---|---|---|
| Findings table: blocking findings | PASS | none open; R1 resolved (below) |
| PowerShell: what changed well | PASS | the supplement lives in one byte-identical sibling; each gate gains three line-level edits; the Codex gate shrinks from 500 to 485 lines |
| PowerShell: API and safety notes | PASS | stage 2, the index-0 bookkeeping rule, and the five stage-1 patterns unchanged; AC-17 and AC-18 rows pass |
| PowerShell: error handling and logging | PASS | I2 deny names the classify file on both surfaces |
| Python, TypeScript, C# implementation audits | N/A | not in scope |
| Test quality: determinism | PASS | pure rows |
| Test quality: isolation | PASS | no shared mutable state; `finally` reset in I2 |
| Test quality: speed | PASS | in-memory |
| Test quality: diagnostics | PASS | command text in each It name; `-Because` text |
| Security: no secrets in code | PASS | none |
| Security: no unsafe subprocess or command construction | PASS | the classify sibling starts no process and evaluates no text |
| Security: input validation at boundaries | PASS | an unclosed substitution run is discarded; only the listed npx options are accepted |
| Security: error handling remains explicit | PASS | no catch-all; a failed dot-source denies |
| Security: configuration and path handling is safe | PASS | the supplement only adds classification; target resolution is unchanged and still fails closed for substitution operands |

## Remediation inputs

| Input | Status | Evidence |
|---|---|---|
| R1 (Blocking): unquoted `npm --prefix $(pwd) run lint` and `npx --prefix <item> jest` unclassified | PASS | classify sibling wired into both gates; unquoted V3 denies `TARGET_WORKTREE_NOT_DERIVABLE` with zero reads and listing calls; N3 allow/deny pair; red in fail-before-r1, green in the final gate; spec non-goal, AC-2, AC-6, and AC-14 revised with `### Remediation Decision R1 (cycle 1)` |
| Note: `bash --rcfile <abs> <script>` takes the rcfile value | PASS | option-value skip in Get-OrchestrationGateHostOperand (four copies); `--rcfile` and `--init-file` G-rows red then green; changed line 179 covered |
| Note: separate-token absolute option values make an item command ambiguous | PASS | brief sentence advising a relative or inline option value (`--junitxml=<path>`) in all six copies; wording row `inline option value` |
| Note: U2 uses the npm missing-value form | N/A | informational; no change required |
| Note: append a corrected V3 root-cause record | PASS | fail-before-v3-correction.2026-11-15T18-51.md; fail-before-v3.2026-11-14T22-09.md unedited |
| Note: OD-1 decision class must repeat the checkpoint class | PASS | this cycle's executor decision file records class `merge_timing` |
| Note: commit the reviewer's review-pester-gate evidence | PASS | evidence/qa-gates/review-pester-gate.2026-11-14T23-52.md is tracked (committed with the review set) |

## Boundary row

| Check | Status | Evidence |
|---|---|---|
| Gate diff holds only the AC-14 hunks | PASS | `git diff <merge-base> HEAD -- .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 .codex/hooks/enforce-orchestration-preimplementation-gate.ps1`: per gate, one added classify dot-source, one added supplement statement, one changed stage-1 condition line; in the Codex gate, the removed `Get-OrchestrationModeDenyReason` block (17 lines) |
| No change to the excluded files | PASS | `git diff --name-only <merge-base> HEAD` paired with `git status --porcelain` (empty apart from this cycle's evidence) lists 0 matches for `enforce-orchestration-preimplementation-gate-targets.ps1`, `enforce-orchestration-preimplementation-gate-commands.ps1`, `.claude/lib/worktree-resolution/HookTargetWorktree.psm1`, `.codex/hooks/hook-target-worktree.ps1`, and `enforce-test-execution-policy.ps1` |
| No new `.py` file | PASS | `git diff --name-only --diff-filter=A <merge-base> HEAD` lists 0 `.py` files |

## Feature audit template (AC-1..AC-15)

| AC | Status | Test rows and evidence |
|---|---|---|
| AC-1 | PASS | P1, P2, P3 for -C, --directory, --directory=, -P on both surfaces (final Pester gate) |
| AC-2 | PASS | N1, N2 allow; N4 deny; N3 pair: `npx --prefix /synthetic-worktrees/w-item jest` allowed with one item read and one listing call (ready), denied with one item read (not ready), both surfaces; both N3 rows red in fail-before-r1 |
| AC-3 | PASS | L1 and L2 for both launcher forms on both surfaces |
| AC-4 | PASS | W1 and W2, ready and not ready, both surfaces |
| AC-5 | PASS | A1 ready and not ready, both surfaces |
| AC-6 | PASS | V1, V2, V4, V5, and the unquoted V3 `npm --prefix $(pwd) run lint` deny `TARGET_WORKTREE_NOT_DERIVABLE` with the unresolvable-operand detail, zero checkpoint reads, and zero listing calls, both surfaces; the quoted V3 row denies the same way; unquoted V3 red in fail-before-r1 |
| AC-7 | PASS | M1, M2 deny `TARGET_WORKTREE_AMBIGUOUS`, both surfaces |
| AC-8 | PASS | R1, R2, R3 keep the session root |
| AC-9 | PASS | F1, F2 deny with zero reads |
| AC-10 | PASS | U1-U5 and the malformed-record G rows |
| AC-11 | PASS | G rows (now including the two bash option-value rows) on both surfaces; B1-B15 unchanged; operands sibling 100%; changed lines covered |
| AC-12 | PASS | operands parity rows; epic-scope bundle identity; both core.json entries; `$script:SharedModuleNames`; five push-down suites pass in the final pytest gate |
| AC-13 | PASS | I1 on both surfaces; hook-dependency-guard-completeness S1-S6 pass with the classify edge |
| AC-14 | PASS | boundary row (only the AC-14 hunks); legacy `parse-checks each root and bundled hook and keeps every file within 500 lines` passes (Codex gate 485); AC-18 passes with `$script:CodexOnlyGateFunction` updated; F1 unchanged; classify parity suite (four-copy SHA256, 500-line bound); both core.json entries and `$script:SharedModuleNames`; positive classify rows true and negative rows false on both surfaces |
| AC-15 | PASS | operands parity wording rows still pass; test_brief_copies_are_byte_identical passes |

### AC Status Summary

- Source: docs/features/active/2026-11-14-preimplementation-gate-resolves-sibling-worktree-bash-to-session-root-1188/spec.md
- Total AC items: 15
- Checked off (delivered): 15
- Remaining (unchecked): 0
