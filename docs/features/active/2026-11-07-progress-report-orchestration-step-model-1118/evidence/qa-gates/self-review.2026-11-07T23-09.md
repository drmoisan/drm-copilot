# Self-Review (P7-T10, issue #1118)

Timestamp: 2026-11-07T23-09
Command: walk of docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md, code-review.yyyy-MM-ddTHH-mm.md, and feature-audit.yyyy-MM-ddTHH-mm.md against git diff --stat <merge-base of origin/main and HEAD> HEAD (32 non-feature-folder files changed, 5599 insertions, 1328 deletions at the time of the walk)
EXIT_CODE: 0
Output Summary:
- Rows: one PASS, FAIL, or N/A row per checklist item of the three templates below; FAIL rows: 0.
- Deviations from the plan text, each recorded: (1) P2-T3 names Get-EpicProgressWaveParallelSeconds; the function is Get-EpicProgressWaveParallelSecond because PSScriptAnalyzer PSUseSingularNouns flags the plural noun; (2) the QA loop restarted once at P7-T1 after the P7-T8 fixture draft exposed an open re-audit attempt without its start and a blank band rendered as '(wave 1, )'; the fix added one Steps test ('marks an open re-audit attempt in progress on the cycle review step') and one Render assertion; (3) the QA loop restarted a second time at P7-T1 after the first green P7-T3 run showed the entry script at 90.00% against its 90.82% baseline; the test 'runs the entry point and restores the location when the run throws' raised it to 95.56%; (4) the Gather file holds one helper beyond the plan list, Read-EpicProgressText (live worktree first, then git show), shared by the plan and cycle-plan reads.

## Policy audit template

### 1. General unit test policy

| Item | Status | Evidence |
|---|---|---|
| Independence | PASS | Each It builds its own in-memory fixture; BeforeEach resets the mock state in the entry, Gather, and ItemMode files; the parallel gate runs the files in separate shards. |
| Isolation | PASS | One behavior per It; the eleven test files mirror the nine scripts plus the entry and contract surfaces. |
| Fast execution | PASS | The largest case merges 1002 samples through a keyed index; the focused debug runs of the folder completed in seconds. |
| Determinism | PASS | Fixed epoch seconds and fixed DateTime values; Get-EpicProgressUtcNow is mocked; no random input. |
| Readability and maintainability | PASS | It names follow the plan; golden comments state the arithmetic. |
| Baseline coverage documented | PASS | evidence/baseline/pester-parallel-baseline.2026-11-07T22-04.md records repo-wide and per-file line coverage. |
| No coverage regression | PASS | evidence/qa-gates/coverage-delta.2026-11-07T23-06.md |
| Changed files meet thresholds | PASS | evidence/qa-gates/coverage-delta.2026-11-07T23-06.md |
| New code coverage at least 90% | PASS | New files Stages, Steps, Durations, Gather: see the coverage-delta artifact. |
| Comprehensive coverage | PASS | Every new public function has a direct It (Stages 14, Steps 14, Durations 21, Metrics estimate 9, Gather 8, ItemMode 12). |
| Positive flows | PASS | Goldens for TL;DR and Full in epic and item mode; per-type table, ledger, tick split. |
| Negative flows | PASS | Unknown and non-positive -StepDefaultMinutes, malformed stage entries, unparseable checkpoint and state text, -EpicFolder with -Issue. |
| Edge cases | PASS | Even and odd medians, empty samples (NaN), 1000-sample ceiling, first-observation seeding, blank band, version 3 state. |
| Error handling | PASS | Throw paths asserted with -ExpectedMessage (Resolve-EpicProgressStepDefault, Find-EpicProgressItemWorktree, parameter-set binding). |
| Concurrency | N/A | The report is single-threaded and runs once per scheduled job. |
| State transitions | PASS | Blocked span opened and cleared, anchors seeded then advanced, version 1 to version 2 migration, reset keeps ledger and anchors. |
| Clear failure messages | PASS | Assertions compare joined strings and use -Because in the contract and constraint tests. |
| Arrange-Act-Assert | PASS | Fixture, call, and assertions are separated by blank lines in each It. |
| Document intent | PASS | Each file header states scope and isolation; arithmetic comments on every golden. |
| Avoid external dependencies | PASS | No git, gh, cswap, file read, or file write in any test; seams are mocked. |
| Use mocks and stubs | PASS | Mocks target the wrapper seams with matching parameter signatures. |
| Environment stability | PASS | /fixture-repo roots and example-epic names; no $global: writes; leak scan finds 0 findings in the folder. |
| Pre-submission review | PASS | This walk. |

### 2. General code change policy

| Item | Status | Evidence |
|---|---|---|
| Clarify the objective | PASS | spec.md and issue #1118. |
| Read existing change plans | PASS | plan.2026-11-07T15-48.md executed task by task. |
| Document the plan | PASS | Plan file with every task checked and per-task commits. |
| Simplicity first | PASS | Pure functions per concern; composition in Get-EpicProgressStepReport. |
| Reusability | PASS | Get-EpicProgressTaskCount and Get-EpicProgressPlanTask reused; Read-EpicProgressText shared by plan and cycle reads. |
| Extensibility | PASS | Step types come from one catalog; defaults overridable by -StepDefaultMinutes. |
| Separation of concerns | PASS | I/O only in the entry seams and the Gather reading functions; everything else is pure. |
| Cohesive modules | PASS | Stages, Steps, Durations, State, Metrics, Render, Gather each hold one concern. |
| At or below the 800-line hard limit | PASS | evidence/qa-gates/file-size.2026-11-07T23-06.md: largest production file 495, largest test file 646. |
| Public vs internal | PASS | Functions are dot-sourced into the skill only; the CLI surface is the entry param block. |
| No circular dependencies | PASS | The hub dot-sources the seven files once; the files do not dot-source each other. |
| Descriptive names | PASS | Approved verbs and EpicProgress noun prefix throughout. |
| Docs and docstrings | PASS | Comment-based help on every function; 17 parameters documented in the entry help. |
| Comment why, not what | PASS | Comments state rule sources (decisions D1 to D13) and arithmetic. |
| Formatting | PASS | evidence/qa-gates/format-final.2026-11-07T22-42.md: 0 formatted. |
| Linting | PASS | evidence/qa-gates/pssa-final.2026-11-07T22-42.md: 0 findings. |
| Type checking | N/A | Not applicable to PowerShell. |
| Testing | PASS | evidence/qa-gates/pester-parallel-final.2026-11-07T22-59.md |
| Full toolchain loop | PASS | Two restarts (the sample-driven fix and the entry-point coverage test); format, analyze, and test then passed in one pass. |
| Explicit reporting | PASS | Every gate has an evidence artifact with the four fields. |
| Summarize changes | PASS | Commit messages per task; CHANGELOG [Unreleased] entry. |
| Design choices explained | PASS | SKILL.md Decisions section; plan Execution Terms. |
| Update supporting documents | PASS | SKILL.md, bundle copy, core.json, CHANGELOG.md. |
| Provide next steps | PASS | CI-dependent criteria are listed as pending-CI in the AC check-off artifact. |

### 3B. PowerShell code change policy

| Item | Status | Evidence |
|---|---|---|
| Formatting with Invoke-Formatter | PASS | format-final.2026-11-07T22-42.md |
| Linting with PSScriptAnalyzer | PASS | pssa-final.2026-11-07T22-42.md |
| Fix all findings | PASS | One PSUseSingularNouns and one PSReviewUnusedParameter finding were fixed during implementation; none remain. |
| PowerShell 5.1 and 7.6+ compatible | PASS | The skill requires PowerShell 7 (SKILL.md Prerequisites); ValidateRange('Positive') and Join-Path -AdditionalChildPath are PowerShell 7 constructs, as the existing script already used. |
| Advanced functions | PASS | CmdletBinding and OutputType on every function. |
| Parameter validation | PASS | -Issue ValidateRange('Positive'); -StepDefaultMinutes validated before any I/O; existing validation unchanged (ItemMode AST test). |
| Avoid global state | PASS | No $global: or script-scope mutable state in production files. |
| Error handling | PASS | throw with messages naming the parameter or issue; no catch-all. |
| Cohesive and at or below 800 lines | PASS | file-size artifact. |
| Approved verbs | PASS | Get, ConvertTo, ConvertFrom, Resolve, Merge, Read, Find, Test, Invoke, Write, Format, Select. |
| Comment why | PASS | See section 2. |
| Step 1 Format / Step 2 Analyze / Step 4 Test | PASS | Format and analyze PASS; test per the Pester gate artifact. |
| Rerun loop if needed | PASS | Two restarts, recorded above. |

### 3A, 3C, 3D. Python, Bash, JSON policies

| Item | Status | Evidence |
|---|---|---|
| Python code change policy | N/A | No Python file changed. |
| Bash script policy | N/A | No bash file changed. |
| JSON configuration policy | N/A | core.json is a pack manifest edited by insertion of four paths; it is validated by the push-down manifest contract tests in the pytest gate. |

### 4B. PowerShell unit test policy

| Item | Status | Evidence |
|---|---|---|
| Use Pester v6.x | PASS | Invoke-PoshQCParallelTest with the repository Pester. |
| Use PoshQC configuration | PASS | Gate run through Invoke-PoshQCParallelTest. |
| Focused unit tests | PASS | See section 1. |
| Test behavior over implementation | PASS | Assertions read returned records and printed lines. |
| Mocking used sparingly | PASS | Only the I/O seams are mocked. |
| Organization | PASS | tests/scripts/claude-skills/epic-progress-report mirrors .claude/skills/epic-progress-report/scripts. |
| File naming *.Tests.ps1 | PASS | All eleven files. |
| Describe/Context/It structure | PASS | Describe per function group, Context for the n/a cases. |
| Logical grouping | PASS | One test file per production file. |
| Docstrings/comments | PASS | File headers and arithmetic comments. |
| Use PoshQCTest command | PASS | Parallel gate. |
| No alternative test runners | PASS | Focused runs were debugging only and are not evidence. |

## Code review template

| Item | Status | Evidence |
|---|---|---|
| Executive summary and findings table | PASS | No open finding after the sample-driven fix. |
| PowerShell implementation audit | PASS | Sections 2 and 3B. |
| Python, TypeScript, C# implementation audits | N/A | Not in scope. |
| Test quality audit | PASS | Sections 1 and 4B. |
| No secrets in code | PASS | No credential or token in the diff. |
| No unsafe subprocess or command construction | PASS | Native calls stay in Invoke-GitExe, Invoke-GhExe, Invoke-CswapExe with argument arrays (constraint test 'confines native commands to their wrappers'). |
| Input validation at boundaries | PASS | Parameter validation and JSON guards (Test-EpicProgressJsonText) on every parsed text. |
| Error handling remains explicit | PASS | Terminating errors with named causes. |
| Configuration and path handling is safe | PASS | Join-Path for filesystem paths; '/' git object paths; writes only in Write-EpicProgressState. |
| Research log | PASS | research/research.2026-11-07T20-56.md; no external research needed. |

## Feature audit template

| Item | Status | Evidence |
|---|---|---|
| Scope and baseline | PASS | Phase 0 artifacts under evidence/baseline/. |
| Acceptance criteria inventory | PASS | 18 criteria in spec.md and user-story.md. |
| Acceptance criteria evaluation | PASS | evidence/qa-gates/ac-checkoff.2026-11-07T23-08.md |
| Acceptance criteria check-off | PASS | Checked items carry a mapped artifact; pending-CI items listed. |
