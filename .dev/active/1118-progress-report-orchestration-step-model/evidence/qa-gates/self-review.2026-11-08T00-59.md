# Self-Review (remediation cycle 2, P2-T5, issue #1118)

Timestamp: 2026-11-08T00-59
Command: walk of docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md, code-review.yyyy-MM-ddTHH-mm.md, and feature-audit.yyyy-MM-ddTHH-mm.md against git diff --shortstat <merge-base of origin/main and HEAD> HEAD (33 files outside docs/features/active changed, 6172 insertions, 1337 deletions; 16 of them changed in this cycle: the Metrics, Render, Stages, and Gather scripts, SKILL.md, their five bundle copies, CHANGELOG.md, and five test files)
EXIT_CODE: 0
Output Summary:
- Rows: one PASS, FAIL, or N/A row per checklist item of the three templates below; FAIL rows: 0.
- First walk (after loop pass 1) found one FAIL: 'No coverage regression on changed lines'. P1-T3 split the removal for an unmerged item with no anchor and no blocked span into its own `elseif` line in Get-EpicProgressStepReport, and no test reached it (pester-parallel-final.2026-11-08T00-42.md, Gather 144/146). Fix: the Gather case 'keeps no entry for an unmerged item with no anchor and no blocked span' (no production change). The QA loop was re-run from P2-T1: format-final, pssa-final, leak-scan-final, and file-size at 2026-11-08T00-49, pester-parallel-final.2026-11-08T00-55.md (16098 tests, 0 failed, Gather 145/146 with every line changed in this cycle covered), pytest-parallel-final.2026-11-08T00-58.md (0 failed), and a P2-T4 sample re-run whose checks and real-run Now line equal sample-report.2026-11-08T00-48.md (production code unchanged between the passes).
- NB1, NB3, and NB4 re-verified (table at the end of this file).
- Acceptance criteria: 18 of 18 checked in spec.md and 18 of 18 in user-story.md; no criterion line is in the cycle diff (the spec.md hunks are the normalization paragraph, the output-formats paragraph, and the version 2 state paragraph).
- Deviations from the plan text: the P2-T5 FAIL fix adds one It not named in P1-T3, as P2-T5 directs; the pass 2 pytest JSON report is named issue-1118-pytest-remediation-2b.json so that the pass 1 report is kept. The entry script Get-EpicProgressReport.ps1 was not edited (495 lines).

## Policy audit template

### 1. General unit test policy

| Item | Status | Evidence |
|---|---|---|
| Independence | PASS | Each new It builds its own steps, items, and state; the Gather Context helper returns a fresh item per call. |
| Isolation | PASS | One behavior per It; each case sits in the test file of the function it exercises. |
| Fast execution | PASS | Pass 2 gate: 16098 tests in 305.63 s over 8 shards; the new cases are pure-function calls. |
| Determinism | PASS | Fixed epoch seconds (4700, 5000, 1767610800, 1767614400) and the default medians. |
| Readability and maintainability | PASS | It names match the plan; comments state the arithmetic of each golden. |
| Baseline coverage documented | PASS | evidence/remediation-baseline/baseline-reference.2026-11-08T00-27.md. |
| No coverage regression | PASS | Repo-wide 94.1% to 94.23%; Render 100% to 100%; Metrics 100% to 100%; every line changed in this cycle is covered after the fix (pester-parallel-final.2026-11-08T00-55.md). |
| Changed files meet thresholds | PASS | Metrics 100%, Render 100%, Stages 100%, Gather 99.32% against the 85% line threshold. |
| New code coverage at least 90% | PASS | Every added line is covered. |
| Comprehensive coverage | PASS | Get-EpicProgressTypeEstimate (1 new), Get-EpicProgressTldrLine (1 new), ConvertTo-EpicProgressStepType (1 updated), Get-EpicProgressStepReport (3 new), skill contract (1 new, 1 updated). |
| Positive flows | PASS | A step with a start keeps the elapsed form; the alias maps to spec; an unmerged item keeps its anchor. |
| Negative flows | PASS | A step without a start prints no elapsed figure; a merged item with no stored entry leaves ItemsChanged false. |
| Edge cases | PASS | Mixed start and no-start rows in one estimate; an unmerged item with no plan text and no stored entry. |
| Error handling | N/A | No new error path. |
| Concurrency | N/A | Single-threaded report. |
| State transitions | PASS | Stored anchor present to removed for a merged item; ItemsChanged follows the stored state. |
| Clear failure messages | PASS | Joined-string goldens and -Because in the contract tests. |
| Arrange-Act-Assert | PASS | Fixture, call, and assertions separated in each new It. |
| Document intent | PASS | Comments name the start values and the stored state. |
| Avoid external dependencies | PASS | No git, gh, cswap, file read, or file write in any new test. |
| Use mocks and stubs | PASS | No new mock; the Gather cases call the pure composition function. |
| Environment stability | PASS | example-epic and in-memory state; no $global: write; leak scan finds no TESTDIR finding (leak-scan-final.2026-11-08T00-49.md). |
| Pre-submission review | PASS | This walk. |

### 2. General code change policy

| Item | Status | Evidence |
|---|---|---|
| Clarify the objective | PASS | remediation-inputs.2026-11-08T00-16.md NB1, NB3, NB4. |
| Read existing change plans | PASS | remediation-plan.2026-11-08T00-16.md executed in order. |
| Document the plan | PASS | Plan tasks checked, one commit per task. |
| Simplicity first | PASS | One boolean on the InProgress row; one branch on the Now line; one table entry; one removal branch. |
| Reusability | PASS | The median text is formatted once per row and shared by both Now-line forms. |
| Extensibility | PASS | A new alias is one table entry; StartRecorded is available to any later consumer of the row. |
| Separation of concerns | PASS | Estimate rows in Metrics, wording in Render, mapping in Stages, state composition in Gather; all pure. |
| Cohesive modules | PASS | No function moved between files. |
| At or below the 800-line hard limit | PASS | file-size.2026-11-08T00-49.md: largest production file 495 (unchanged entry script), largest test file 656. |
| Public vs internal | PASS | No CLI parameter or version 2 state field changed; StartRecorded is an in-memory row property. |
| No circular dependencies | PASS | No new dot-source. |
| Descriptive names | PASS | StartRecorded, $median. |
| Docs and docstrings | PASS | .DESCRIPTION of Get-EpicProgressTypeEstimate, Get-EpicProgressTldrLine, ConvertTo-EpicProgressStepType, and Get-EpicProgressStepReport updated. |
| Comment why, not what | PASS | The Gather comment states why a merged item keeps no state entry. |
| Formatting | PASS | format-final.2026-11-08T00-49.md: 0 formatted, 29 already formatted. |
| Linting | PASS | pssa-final.2026-11-08T00-49.md: 0 findings. |
| Type checking | N/A | Not applicable to PowerShell. |
| Testing | PASS | pester-parallel-final.2026-11-08T00-55.md (0 failed); pytest-parallel-final.2026-11-08T00-58.md (0 failed). |
| Full toolchain loop | PASS | Pass 2 of format, analyze, and test passed in one pass after the FAIL fix. |
| Explicit reporting | PASS | Each gate has an artifact with the four fields. |
| Summarize changes | PASS | Commit messages per task; CHANGELOG sentence. |
| Design choices explained | PASS | Plan Premise Correction and Execution Terms; SKILL.md Report Formats and State File. |
| Update supporting documents | PASS | spec.md (three paragraphs), SKILL.md, bundle, CHANGELOG.md. |
| Provide next steps | PASS | Re-review of the cycle; CI on the PR head. |

### 3B. PowerShell code change policy

| Item | Status | Evidence |
|---|---|---|
| Formatting with Invoke-Formatter | PASS | format-final.2026-11-08T00-49.md |
| Linting with PSScriptAnalyzer | PASS | pssa-final.2026-11-08T00-49.md |
| Fix all findings | PASS | None raised. |
| PowerShell 7 compatible | PASS | No new construct beyond those the scripts already use. |
| Advanced functions | PASS | CmdletBinding and OutputType unchanged on every edited function. |
| Parameter validation | PASS | No parameter changed. |
| Avoid global state | PASS | No $global: or script-scope mutable state added. |
| Error handling | PASS | No catch-all added. |
| Cohesive and at or below 800 lines | PASS | file-size artifact. |
| Approved verbs | PASS | No new function. |
| Comment why | PASS | See section 2. |
| Step 1 Format / Step 2 Analyze / Step 4 Test | PASS | All three passed in pass 2. |
| Rerun loop if needed | PASS | The loop was re-run from P2-T1 after the FAIL fix. |

### 3A, 3C, 3D. Python, Bash, JSON policies

| Item | Status | Evidence |
|---|---|---|
| Python code change policy | N/A | No Python file changed. |
| Bash script policy | N/A | No bash file changed. |
| JSON configuration policy | N/A | No JSON file changed; core.json and config/poshqc-leak-allowlist.json unchanged. |

### 4B. PowerShell unit test policy

| Item | Status | Evidence |
|---|---|---|
| Use Pester v6.x | PASS | Invoke-PoshQCParallelTest. |
| Use PoshQC configuration | PASS | Gate through Invoke-PoshQCParallelTest. |
| Focused unit tests | PASS | See section 1. |
| Test behavior over implementation | PASS | Assertions read returned rows, printed lines, and the returned Items table. |
| Mocking used sparingly | PASS | No new mock. |
| Organization | PASS | Tests stay in tests/scripts/claude-skills/epic-progress-report. |
| File naming *.Tests.ps1 | PASS | No new file. |
| Describe/Context/It structure | PASS | One new Context ('merged item anchors') groups the three Gather cases. |
| Logical grouping | PASS | Each case in the file of its function. |
| Docstrings/comments | PASS | Fixture comments. |
| Use PoshQCTest command | PASS | Parallel gate. |
| No alternative test runners | PASS | Focused runs were debugging only and are not evidence. |

## Code review template

| Item | Status | Evidence |
|---|---|---|
| Executive summary and findings table | PASS | NB1, NB3, and NB4 closed (table below); no open blocking finding. |
| PowerShell implementation audit | PASS | Sections 2 and 3B. |
| Python, TypeScript, C# implementation audits | N/A | Not in scope. |
| Test quality audit | PASS | Sections 1 and 4B. |
| No secrets in code | PASS | No credential or token in the cycle diff. |
| No unsafe subprocess or command construction | PASS | No native call added; the four edited files call no executable. |
| Input validation at boundaries | PASS | The alias is compared on the trimmed lower-case name; a row without StartRecorded keeps the elapsed form. |
| Error handling remains explicit | PASS | Unchanged. |
| Configuration and path handling is safe | PASS | No path handling added; the state key is the item issue string. |
| Research log | N/A | No research needed for this cycle. |

## Feature audit template

| Item | Status | Evidence |
|---|---|---|
| Scope and baseline | PASS | baseline-reference.2026-11-08T00-27.md; changes limited to files already in the branch diff, their tests, the bundle, spec.md, and CHANGELOG.md. |
| Acceptance criteria inventory | PASS | 18 criteria in spec.md and in user-story.md. |
| Acceptance criteria evaluation | PASS | No criterion changed by the cycle; the AC-mapped tests passed in pester-parallel-final.2026-11-08T00-55.md (0 failed). |
| Acceptance criteria check-off | PASS | 18 of 18 checked in each file, unedited. |

## NB1, NB3, NB4 re-verification

| Finding | Status | Evidence |
|---|---|---|
| NB1 start not recorded on the Now line | PASS | Get-EpicProgressTypeEstimate sets StartRecorded; Get-EpicProgressTldrLine prints `(start not recorded; median <m>)`; 'marks an in-progress step without a start as start not recorded' and 'prints start not recorded on the Now line for a step without a start' pass; the elapsed-form goldens pass unchanged; sample-report.2026-11-08T00-48.md shows `#2000 review (start not recorded; median 0 h 14 min)` and the real run `#1118 execution (start not recorded; median 0 h 03 min)`; spec.md and SKILL.md state the form. |
| NB3 S2_feature_documents alias | PASS | ConvertTo-EpicProgressStepType maps it to spec; 'maps each live stage alias to its step type' (twelve names) and 'lists the live stage-name aliases' pass; the sample fixtures record the spec stage under this name and show a measured spec median. |
| NB4 merged-item anchors | PASS | Get-EpicProgressStepReport drops the Items entry of an item whose merge step is done and sets ItemsChanged only for a stored entry; 'drops the stored anchor of a merged item and keeps an unmerged one', 'leaves ItemsChanged false for a merged item with no stored entry', and 'keeps no entry for an unmerged item with no anchor and no blocked span' pass; the durations ledger is unchanged ('keeps the durations ledger and anchors with -ResetBaseline' passes). |
