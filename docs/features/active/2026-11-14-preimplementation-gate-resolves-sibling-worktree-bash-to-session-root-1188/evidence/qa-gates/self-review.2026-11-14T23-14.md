# Self-review (P4-T6)

Timestamp: 2026-11-14T23-14
Command: walk of docs/features/templates/policy_audit/policy-audit, code-review, and feature-audit templates against git diff <merge-base> HEAD (merge base = git merge-base origin/main HEAD) and spec.md AC-1..AC-15
EXIT_CODE: 0
Output Summary: no FAIL row. All policy-audit, code-review, and feature-audit checklist items are PASS or N/A. AC-1..AC-5 and AC-7..AC-15 PASS; AC-6 is recorded as DEVIATION (spec conflict): four of its five commands deny as specified, and the fifth (`npm --prefix $(pwd) run lint`, unquoted) is not classified by either gate, so it is allowed before target resolution; changing that requires a classification change, which the spec lists as a non-goal. AC-6 stays unchecked in spec.md and is escalated in the completion report.

Inputs: evidence/qa-gates/final-qc-powershell-static.2026-11-14T22-58.md, final-qc-pester.2026-11-14T23-10.md, final-qc-pytest.2026-11-14T23-11.md, coverage-comparison.2026-11-14T23-12.md, non-goal-diff-check.2026-11-14T23-12.md, the phase gates P1-P3, and evidence/regression-testing/fail-before.2026-11-14T21-26.md and fail-before-v3.2026-11-14T22-09.md.

## Policy audit template

| Item | Status | Evidence |
|---|---|---|
| Language summary: PowerShell | PASS | 13 changed .ps1 files; Pester 26807 tests, 0 failed; repo line coverage 95.96% -> 95.99%; new code 100% |
| Language summary: Python | N/A | no Python file changed |
| Language summary: Bash | N/A | no tracked shell file changed (the pytest helper is untracked under artifacts/) |
| Language summary: JSON | PASS | two core.json files; parsed by ConvertFrom-Json; manifest completeness suites pass |
| 1.1 Independence | PASS | rows register mocks per row and reset `$script:OrchestrationGateWorktreeListFailed` and `$script:HookDependencyFailures`; parallel gate green |
| 1.1 Isolation | PASS | one G row per form, one gate row per ID and form |
| 1.1 Fast execution | PASS | each operands suite runs in about 100 s including PoshQC startup; per-row cost is in-memory |
| 1.1 Determinism | PASS | no clock, file, process, or network access; three identical full gates |
| 1.1 Readability and maintainability | PASS | shared data-only Cases table; It names carry the row ID and label |
| 1.2 Baseline coverage documented | PASS | evidence/baseline/pester-gate.2026-11-14T21-02.md |
| 1.2 No coverage regression | PASS | coverage-comparison: no drop on either epic-scope file or repo-wide |
| 1.2 Changed files meet thresholds | PASS | operands copies 100%, epic-scope 97.79% and 98.06% |
| 1.2 New code coverage at least 90% | PASS | 308 new lines and 10 changed executable lines, all covered |
| 1.2 Comprehensive coverage | PASS | 90 G rows and 44 gate rows per surface |
| 1.2 Positive flows | PASS | P1, N1, N2, L1, W1, W2, A1 allow rows |
| 1.2 Negative flows | PASS | P2, P3, N4, L2, V1-V5, U1-U5 |
| 1.2 Edge cases | PASS | drive-letter strings, duplicates, redirections, attached and inline option forms, empty command |
| 1.2 Error handling | PASS | F1, F2 (listing failure, empty listing), I1 (dependency failure) |
| 1.2 Concurrency | N/A | no concurrent code |
| 1.2 State transitions | N/A | stateless extraction |
| 1.3 Clear failure messages | PASS | `-Because` on the Paths assertion; row ID in each It name |
| 1.3 Arrange-Act-Assert | PASS | gate rows and I1 follow Arrange/Act/Assert comments |
| 1.3 Document intent | PASS | suite headers and Cases header describe each table |
| 1.4 Avoid external dependencies | PASS | listing and checkpoint seams mocked; no git start |
| 1.4 Use mocks and stubs | PASS | Get-OrchestrationGateWorktreeList, Get-CheckpointContent, Find-WorktreeResolutionRoot |
| 1.4 Environment stability | PASS | `/synthetic-worktrees/...` roots; forward slashes; Linux-safe |
| 1.5 Pre-submission review | PASS | this file |
| 2.1 Clarify the objective | PASS | spec.md and plan |
| 2.1 Read existing change plans | PASS | plan.2026-11-14T13-12.md executed in order |
| 2.1 Document the plan | PASS | plan checked off per task |
| 2.2 Simplicity first | PASS | one pure function plus four small helpers; gate files untouched |
| 2.2 Reusability | PASS | reuses Get-OrchestrationGateCommandOperandPath, Read-CommandLineInvocationSegment, Test-CommandLineWordPresent, Test-CommandLineTokenLiteral, Get-CommandLineGlobalOption |
| 2.2 Extensibility | PASS | option tables are data; a new host is one branch |
| 2.2 Separation of concerns | PASS | extraction is pure string logic; I/O stays in the two existing seams |
| 2.3 Cohesive modules | PASS | one sibling for operand extraction |
| 2.3 At or below the 800-line hard limit | PASS | sibling 295, Claude epic-scope 418, Codex epic-scope 474, tests 176/140/137/74 |
| 2.3 Public vs internal | PASS | one entry function; helpers are file-internal by naming |
| 2.3 No circular dependencies | PASS | the sibling dot-sources nothing |
| 2.4 Descriptive names | PASS | Orchestration-Gate-prefixed names |
| 2.4 Docs and docstrings | PASS | comment-based help on every function |
| 2.4 Comment why, not what | PASS | table comments state rule numbers and the scanner split |
| 2.5 Formatting | PASS | final-qc-powershell-static: 0 changes |
| 2.5 Linting | PASS | 0 PSScriptAnalyzer findings |
| 2.5 Type checking | N/A | PowerShell |
| 2.5 Testing | PASS | final Pester and pytest gates green |
| 2.5 Full toolchain loop | PASS | three phase gates and the final loop each clean in one pass |
| 2.5 Explicit reporting | PASS | evidence files per step |
| 2.6 Summarize changes | PASS | commit messages per phase |
| 2.6 Design choices explained | PASS | sibling header; fail-before-v3 and task-check P3-T1 deviations |
| 2.6 Update supporting documents | PASS | execution-environment brief, six copies |
| 2.6 Provide next steps | PASS | completion report lists the classifier finding and the main sync |
| 3B.1 Formatting with Invoke-Formatter | PASS | settings file scripts/powershell/PoshQC/settings/pssa.settings.psd1 |
| 3B.1 Linting with PSScriptAnalyzer | PASS | 0 findings |
| 3B.1 Fix all findings | PASS | none open |
| 3B.2 PowerShell 5.1 and 7.6+ compatible | N/A | repository rule is PowerShell 7+ (.claude/rules/powershell.md); hooks run under pwsh 7 |
| 3B.2 Advanced functions | PASS | `[CmdletBinding()]` on every function |
| 3B.2 Parameter validation | PASS | Mandatory and AllowEmpty attributes |
| 3B.2 Avoid global state | PASS | script-scope tables are read-only data; state passes through `-State` |
| 3B.2 Error handling | PASS | unresolvable input becomes an explicit Unresolved result that the gate denies |
| 3B.3 Cohesive and at or below the 800-line hard limit | PASS | see 2.3 |
| 3B.3 Approved verbs | PASS | Get, Add, Read; PSUseApprovedVerbs clean |
| 3B.3 Comment why | PASS | see 2.4 |
| 3B.4 Step 1 Format | PASS | final static |
| 3B.4 Step 2 Analyze | PASS | final static |
| 3B.4 Step 3 Type check | N/A | PowerShell |
| 3B.4 Step 4 Test | PASS | final Pester gate |
| 3B.4 Rerun loop if needed | PASS | no rerun needed in the final loop |
| 3D.1 Formatting with jq | N/A | entries inserted in the existing two-space style; parsed with ConvertFrom-Json |
| 3D.1 Schema validation | N/A | pack manifests have no schema; completeness suites pass |
| 3D.2 Required $schema | N/A | not used by pack manifests |
| 3D.2 Strict JSON only | PASS | ConvertFrom-Json parse |
| 3D.2 Deterministic key order | PASS | array entry placed beside its -commands.ps1 sibling, outside the 0010 ledger hunk |
| 4B.1 Use Pester v6.x | PASS | repository Pester through Invoke-PoshQCParallelTest |
| 4B.1 Use PoshQC configuration | PASS | launcher pester suite |
| 4B.1 PowerShell 5.1 and 7.6+ compatible | N/A | `#Requires -Version 7.0`, as the sibling suites |
| 4B.1 Focused unit tests | PASS | G rows target the function alone |
| 4B.1 Test behavior over implementation | PASS | gate rows assert decisions, reason codes, and seam call counts |
| 4B.1 Mocking used sparingly | PASS | only the listing, checkpoint, and ascent seams |
| 4B.2 Organization | PASS | tests mirror .claude/hooks and .codex/hooks under tests/scripts/claude-hooks and codex-hooks |
| 4B.2 File naming *.Tests.ps1 | PASS | Cases file is data only |
| 4B.2 Describe/Context/It structure | PASS | one Describe, two Contexts per suite |
| 4B.3 Logical grouping | PASS | G rows and gate rows in separate Contexts |
| 4B.3 Docstrings and comments | PASS | suite and Cases headers |
| 4B.4 Use PoshQCTest command | PASS | Invoke-PoshQCParallelTest via the launcher |
| 4B.4 No alternative test runners | PASS | launcher only |
| 6 Test execution metrics | PASS | 26807 tests, 0 failed, 700.91 s wall clock over 8 workers |

## Code review template

| Item | Status | Evidence |
|---|---|---|
| Findings table: blocking findings | PASS | none |
| Findings table: non-blocking finding (classifier) | N/A | outside scope: stage 2 drops the stage-1 hit for `npm --prefix $(pwd) run lint`; reported for follow-up, not changed (classification non-goal) |
| PowerShell: what changed well | PASS | resolver gains one call and one early return per surface; the operand logic lives in one byte-identical sibling |
| PowerShell: API and safety notes | PASS | `Get-OrchestrationGateCommandOperandPath` unchanged; F1 helper parity and AC-18 inventories pass |
| PowerShell: error handling and logging | PASS | Unresolved Detail names the class and token; dependency failure of the sibling denies naming the file (I1) |
| Python, TypeScript, C# implementation audits | N/A | not in scope |
| Test quality: determinism | PASS | in-memory fixtures |
| Test quality: isolation | PASS | per-row mocks; no shared mutable state |
| Test quality: speed | PASS | about 100 s per suite including module load |
| Test quality: diagnostics | PASS | row IDs and `-Because` text |
| Security: no secrets in code | PASS | none |
| Security: no unsafe subprocess or command construction | PASS | the sibling starts no process and evaluates no text |
| Security: input validation at boundaries | PASS | non-literal selectors and operands fail closed |
| Security: error handling remains explicit | PASS | no catch-all; deny reasons carry the reason code |
| Security: configuration and path handling is safe | PASS | relative and outside paths keep the prior session-root behavior; ambiguity and listing failure deny |

## Feature audit template (AC-1..AC-15)

| AC | Status | Test rows and evidence |
|---|---|---|
| AC-1 | PASS | P1, P2, P3 for -C, --directory, --directory=, -P on both surfaces; item read once, session never (final Pester gate); fail-before shows all 12 failing |
| AC-2 | PASS | N1, N2 allow, N4 deny; N3 is unclassified (allowed with zero reads), as the plan's premise correction states |
| AC-3 | PASS | L1 and L2 for both launcher forms on both surfaces |
| AC-4 | PASS | W1 and W2, ready and not ready, both surfaces |
| AC-5 | PASS | A1 ready and not ready, both surfaces |
| AC-6 | DEVIATION (spec conflict) | V1, V2, V4, V5 deny with TARGET_WORKTREE_NOT_DERIVABLE, zero reads, zero listing calls; V3 uses the classified form `npm --prefix "$(pwd)" run lint` (denies, red-proved in fail-before-v3); the unquoted form is unclassified on both surfaces and is pinned by a control row; AC-6 left unchecked |
| AC-7 | PASS | M1, M2 deny TARGET_WORKTREE_AMBIGUOUS, both surfaces |
| AC-8 | PASS | R1, R2, R3 keep the session root, item never read |
| AC-9 | PASS | F1 (listing throws), F2 (empty listing), zero reads |
| AC-10 | PASS | U1 (unbalanced), U2 (selector with no value), U3 (env -S), U4 (unmodelled poetry option), plus U5 and the DecodeFailure and DepthLimit G rows |
| AC-11 | PASS | 90 G rows per surface including redirection and `git commit -F <abs>`; B1-B15 unchanged on both surfaces; sibling 100%; changed-lines condition met (coverage-comparison) |
| AC-12 | PASS | parity suite SHA256 rows; epic-scope bundle identity rows; both core.json entries; `$script:SharedModuleNames`; the five push-down suites pass |
| AC-13 | PASS | I1 on both surfaces; hook-dependency-guard-completeness S1-S6 pass |
| AC-14 | PASS | non-goal-diff-check: gate files unchanged; legacy 500-line row, AC-18, and F1 pass |
| AC-15 | PASS | six-copy wording rows in the parity suite; test_brief_copies_are_byte_identical passes |

### AC Status Summary

- Source: docs/features/active/2026-11-14-preimplementation-gate-resolves-sibling-worktree-bash-to-session-root-1188/spec.md
- Total AC items: 15
- Checked off (delivered): 14
- Remaining (unchecked): 1 (AC-6, spec conflict with the classification non-goal)
