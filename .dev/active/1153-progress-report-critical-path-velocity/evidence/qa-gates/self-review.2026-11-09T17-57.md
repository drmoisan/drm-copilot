# Self-Review, remediation cycle 1 (P2-T5, issue #1153)

Timestamp: 2026-11-09T17-57
Command: walk of docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md, code-review.yyyy-MM-ddTHH-mm.md, and feature-audit.yyyy-MM-ddTHH-mm.md against git diff <merge base of origin/main and HEAD> HEAD (67 files changed, 8430 insertions, 917 deletions; this cycle's share since the cycle entry head: 33 files changed, 1143 insertions, 651 deletions, most of it the move of five functions from the Schedule file to the CriticalPath file)
EXIT_CODE: 0
Output Summary:
- Rows: one PASS, FAIL, or N/A row per checklist item of the three templates, plus one row per review finding CR1 to CR5; FAIL rows: 0.
- spec.md and user-story.md: git diff from the cycle entry head to HEAD is empty for both files, so every box checked before this cycle is still checked (spec.md 57 checked, user-story.md 13 checked).
- Deviations from the plan text: none. Debugging-only focused runs (the skill test folder after P1-T5 and P1-T6, and the four named pytest files after P1-T6) were used to find defects before the gates and are not cited as gate evidence; one PSUseOutputTypeCorrectly finding they surfaced was fixed in P1-T5 before its commit.

## Review findings CR1 to CR5

| Finding | Status | Commit subject | Verifying test |
|---|---|---|---|
| CR1 Schedule.ps1 near the hard limit | PASS | refactor(1153): move the critical-path report functions into Get-EpicProgressReport.CriticalPath.ps1 (P1-T1, CR1) | `lists every skill-folder file exactly once in core.json` and `mirrors every skill-folder file byte-identically in the bundle` (13 files); `confines file writes to Write-EpicProgressState` (12 production paths); `calls no I/O seam and reads no clock in the Velocity and Schedule files` (covers CriticalPath); Schedule 494 and CriticalPath 308 lines (poshqc-static.2026-11-09T17-43.md); moved bodies byte-identical to the removed lines. |
| CR2 0 tasks / hr before any interval | PASS | fix(1153): print the aggregate average as n/a while no interval exists (P1-T4, CR2) | `returns a non-finite average below one interval and a finite one from one interval` (599, 600, 601 s); `returns a non-finite average when every interval overlaps a pause span`; the five entry and item goldens now read `aggregate n/a tasks / hr average`; SKILL.md assertion in `states the calculation rule values`. |
| CR3 resolver differences undocumented | PASS | docs(1153): document where dependency-reference resolution differs from the canonical resolver (P1-T3, CR3) | Help-only change (six lines); every case of Get-EpicProgressReport.Schedule.Tests.ps1 passes unchanged in the P2-T2 gate. |
| CR4 pauses[] never pruned | PASS | feat(1153): prune pause spans that end before the earliest stored instant (P1-T5, CR4) | Describe `Select-EpicProgressRetainedPauseSpan (CR4)` (six cases: 999/1000/1001 boundary, anchor cutoff, sample cutoff, start-is-minimum keep, no instant, order); `drops a pause span ending one second before the earliest stored instant and writes one ending at it (CR4)`; `drops a stored span ending before the start, the samples, and the anchor and prints the same velocity line (CR4)`; SKILL.md assertion in `documents known behaviors, rates, delivery and quota policy`. |
| CR5 stale wave-parallel parenthetical | PASS | docs(1153): drop the retired wave-parallel figure from the Logic hub help (P1-T2, CR5) | No file under the skill scripts folder contains `wave-parallel figure,`; the Metrics retired-figure sentence is unchanged. |

## Policy audit template

### 1. General unit test policy

| Item | Status | Evidence |
|---|---|---|
| Independence | PASS | New cases build their own in-memory data; the CriticalPath case uses the per-test fixture reset in BeforeEach; the parallel gate passed with 0 failures. |
| Isolation | PASS | One behavior per It; the selector cases call Select-EpicProgressRetainedPauseSpan directly, the State.V3 case calls the writer, and the CriticalPath case runs the entry once with and once without the span. |
| Fast execution | PASS | Pure data cases; no wait or sleep. |
| Determinism | PASS | Fixed epoch seconds; Get-EpicProgressUtcNow is mocked in the entry case; no random input. |
| Readability and maintainability | PASS | It names state the rule and boundary; comments state the arithmetic (6 tasks per hour at 600 s, 3.6 over 4000 s). |
| Baseline coverage documented | PASS | evidence/remediation-baseline/poshqc-static.2026-11-09T17-31.md names the Phase 0 baseline and the main final gate references. |
| No coverage regression | PASS | coverage-comparison.2026-11-09T17-52.md: every script at or above the main final gate; repo-wide 95.80% against 95.79%. |
| Changed files meet thresholds | PASS | Lowest changed script 96.40% (entry, help-only edit); Schedule, CriticalPath, Velocity, State, Logic, and Metrics at 100%. |
| New code coverage at least 90% | PASS | CriticalPath 102/102; added executable lines since the merge base 661/661. |
| Comprehensive coverage | PASS | Each new rule has below, at, and above cases (CR2 at 599/600/601 s; CR4 at 999/1000/1001). |
| Positive flows | PASS | Finite average from one interval; spans at or after the cutoff kept. |
| Negative flows | PASS | n/a average with 0 intervals; spans before the cutoff dropped. |
| Edge cases | PASS | All intervals paused; no stored instant; span ending exactly at the cutoff. |
| Error handling | PASS | NaN prints n/a through the existing formatter; null spans and null tick anchors are skipped. |
| Concurrency | N/A | The report is single-threaded. |
| State transitions | PASS | Written state after a normal run omits the pruned span while the printed line is unchanged. |
| Clear failure messages | PASS | -Because on the conditional assertions. |
| Arrange-Act-Assert | PASS | Fixture, call, and assertions separated in each new It. |
| Document intent | PASS | Test-file headers updated to name the CriticalPath file. |
| Avoid external dependencies | PASS | No git, gh, cswap, file read, or file write in the new cases. |
| Use mocks and stubs | PASS | Only the existing seam mocks of the entry suite. |
| Environment stability | PASS | No global function or variable; leak scan 0 failures. |
| Pre-submission review | PASS | This walk. |

### 2. General code change policy

| Item | Status | Evidence |
|---|---|---|
| Clarify the objective | PASS | remediation-inputs.2026-11-09T17-13.md rows CR1 to CR5. |
| Read existing change plans | PASS | remediation-plan.2026-11-09T17-13.md executed task by task. |
| Document the plan | PASS | Every task checked with a per-task commit. |
| Simplicity first | PASS | The split moves functions unchanged; CR2 is one guard; CR4 is one pure selector called once. |
| Reusability | PASS | The selector is shared by any writer of the state through ConvertTo-EpicProgressStateJson. |
| Extensibility | PASS | New parameters are optional with defaults; existing callers unchanged. |
| Separation of concerns | PASS | The new file and the selector are pure; the purity test covers CriticalPath. |
| Cohesive modules | PASS | Schedule holds the graph and schedule; CriticalPath holds the report composition. |
| At or below the 800-line hard limit | PASS | Largest production file 530 (entry, unchanged size class); Schedule 494; largest test file 699; SKILL.md 499 (pinned below 500). |
| Public vs internal | PASS | CLI parameters unchanged. |
| No circular dependencies | PASS | The Logic hub dot-sources CriticalPath once, after Schedule; the files do not dot-source each other. |
| Descriptive names | PASS | Select-EpicProgressRetainedPauseSpan uses an approved verb and the EpicProgress prefix. |
| Docs and docstrings | PASS | Comment-based help on the new function; writer help states the pruning; hub, entry, and Metrics help name the new file. |
| Comment why, not what | PASS | The selector help states why the cutoff is safe (no later calculation reads time before it). |
| Formatting | PASS | poshqc-static.2026-11-09T17-43.md: 0 files would change. |
| Linting | PASS | Same artifact: 0 findings. |
| Type checking | N/A | Not applicable to PowerShell. |
| Testing | PASS | pester.2026-11-09T17-52.md and pytest.2026-11-09T17-56.md. |
| Full toolchain loop | PASS | One clean pass of P2-T1 to P2-T4; no restart was needed. |
| Explicit reporting | PASS | Each gate has an artifact with the four fields. |
| Summarize changes | PASS | Commit messages per task. |
| Design choices explained | PASS | The plan's Design Decisions (CR1 boundary, CR4 cutoff, CR2 rule) and SKILL.md. |
| Update supporting documents | PASS | SKILL.md, bundle copies, and the core.json entry for the new script. |
| Provide next steps | PASS | AC-58 remains pending-CI as before this cycle. |

### 3B. PowerShell code change policy

| Item | Status | Evidence |
|---|---|---|
| Formatting with Invoke-Formatter | PASS | poshqc-static.2026-11-09T17-43.md |
| Linting with PSScriptAnalyzer | PASS | poshqc-static.2026-11-09T17-43.md |
| Fix all findings | PASS | The one PSUseOutputTypeCorrectly finding was fixed in P1-T5; none remain. |
| PowerShell 5.1 and 7.6+ compatible | PASS | The skill requires PowerShell 7 (SKILL.md Prerequisites), unchanged. |
| Advanced functions | PASS | CmdletBinding and OutputType on the new function. |
| Parameter validation | PASS | AllowNull and AllowEmptyCollection where empty input is valid. |
| Avoid global state | PASS | No $global: or mutable script-scope state. |
| Error handling | PASS | No catch-all added. |
| Cohesive and at or below 800 lines | PASS | See section 2. |
| Approved verbs | PASS | Select is an approved verb. |
| Comment why | PASS | See section 2. |
| Step 1 Format / Step 2 Analyze / Step 4 Test | PASS | Static and Pester gate artifacts. |
| Rerun loop if needed | PASS | Not needed; the gates passed on their first run. |

### 3A, 3C, 3D. Python, Bash, JSON policies

| Item | Status | Evidence |
|---|---|---|
| Python code change policy | N/A | No Python file added or changed (pytest artifact: 0 added .py files). |
| Bash script policy | N/A | No bash file changed. |
| JSON configuration policy | PASS | core.json gained one entry in sorted position; the push-down manifest contract tests pass in the pytest gate. |

### 4B. PowerShell unit test policy

| Item | Status | Evidence |
|---|---|---|
| Use Pester v6.x | PASS | Invoke-PoshQCParallelTest with the repository Pester. |
| Use PoshQC configuration | PASS | Branch-current PoshQC module. |
| Focused unit tests | PASS | See section 1. |
| Test behavior over implementation | PASS | Assertions read returned spans, averages, written JSON, and printed lines. |
| Mocking used sparingly | PASS | No new mock. |
| Organization | PASS | New cases in the Velocity, State.V3, and CriticalPath test files that mirror the scripts. |
| File naming *.Tests.ps1 | PASS | No new test file. |
| Describe/Context/It structure | PASS | New Describe for the selector; the entry case sits in Context 'pause spans'. |
| Logical grouping | PASS | Get-EpicProgressReport.Tests.ps1 received pin and golden edits only (699 lines). |
| Docstrings/comments | PASS | Helper comments and arithmetic comments. |
| Use PoshQCTest command | PASS | Parallel gate. |
| No alternative test runners | PASS | Focused runs were debugging only and are not cited as gate evidence. |

## Code review template

| Item | Status | Evidence |
|---|---|---|
| Executive summary and findings table | PASS | CR1 to CR5 closed above; no new finding. |
| PowerShell implementation audit | PASS | Sections 2 and 3B. |
| Python, TypeScript, C# implementation audits | N/A | Not in scope. |
| Test quality audit | PASS | Sections 1 and 4B. |
| No secrets in code | PASS | No credential or token in the diff. |
| No unsafe subprocess or command construction | PASS | No native command added; `confines native commands to their wrappers` passes. |
| Input validation at boundaries | PASS | The selector skips null spans, samples without ts, and null tick anchors. |
| Error handling remains explicit | PASS | No exception is swallowed. |
| Configuration and path handling is safe | PASS | The new dot-source line uses Join-Path with $PSScriptRoot and exact file-name case. |
| Research log | PASS | research/ folder unchanged; this cycle needed no new research. |

## Feature audit template

| Item | Status | Evidence |
|---|---|---|
| Scope and baseline | PASS | evidence/remediation-baseline/poshqc-static.2026-11-09T17-31.md and the main-plan Phase 0 artifacts. |
| Acceptance criteria inventory | PASS | spec.md and user-story.md unchanged in this cycle; the plan adds and unchecks no criterion. |
| Acceptance criteria evaluation | PASS | The CR2 and CR4 behavior changes keep the AC traces of ac-verification.2026-11-09T16-59.md resolvable (AC-50 purity test name unchanged). |
| Acceptance criteria check-off | PASS | Every box checked before this cycle is still checked (empty diff since the cycle entry head). |
