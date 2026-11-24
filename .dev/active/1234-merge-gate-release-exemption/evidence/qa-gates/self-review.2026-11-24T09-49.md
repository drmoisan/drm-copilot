# Self-Review: merge-gate release exemption (#1234)

Timestamp: 2026-11-24T09-49
Command: walk of `.dev/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, `code-review.yyyy-MM-ddTHH-mm.md`, and `feature-audit.yyyy-MM-ddTHH-mm.md` against the change set from MB (merge base of origin/main and HEAD) plus the uncommitted working tree (`git status --porcelain`, 52 entries)
EXIT_CODE: 0
Output Summary: 81 rows (74 PASS, 7 N/A, 0 FAIL); N/A rows name their reason. This file is the authoritative self-review; it supersedes self-review.2026-11-24T09-48.md (summary line misstated the row count as 76, and its filename stamp was typed rather than read from the clock) and self-review.2026-11-24T09-47.md (same content as this file, written before the clock passed 09-48). Both are kept unchanged. Languages in scope: PowerShell, JSON (two pack manifests), Markdown (generated docs). No Python, TypeScript, C#, or Bash production file changed.

## Policy Audit

| # | Checklist item | Result | Evidence |
|---|---|---|---|
| 1.1a | Independence | PASS | Every row arranges its own mocks (BeforeEach defaults, per-row Set-* helpers); the suites passed in the 8-worker final gate (evidence/qa-gates/pester.2026-11-24T09-35.md). |
| 1.1b | Isolation | PASS | One `It` per case; unit rows target Get-EpicMergeGateReleaseDecision, decision rows target the gate entry functions. |
| 1.1c | Fast execution | PASS | The new suites ran in roughly 2 minutes of shard time each in single-file selections, including Pester start-up; no row waits. |
| 1.1d | Determinism | PASS | No clock, network, or live process; gh, git, and allowance reads are mocked seams; run timestamps are fixed fixture strings. |
| 1.1e | Readability | PASS | Arrange/Act/Assert comments; `It` names state the code and end with `(#1234)`. |
| 1.2a | Baseline coverage documented | PASS | evidence/baseline/pester.2026-11-24T05-02.md (96.85% repo-wide, per-file values). |
| 1.2b | No coverage regression | PASS | evidence/qa-gates/coverage-delta.2026-11-24T09-38.md: no file and no repo-wide drop. |
| 1.2c | Changed files meet thresholds | PASS | Gates 98.66% and 99.45%; pure file 100% / 96.3%; leg 100% in both trees. |
| 1.2d | New code coverage >= 90% | PASS | Leg 100% (95 of 95) per tree; all executable added gate lines covered (3 of 3 per gate). |
| 1.2e | Comprehensive coverage | PASS | Every function of the leg executed (100% line coverage). |
| 1.2f | Positive flows | PASS | Allow rows for --merge, --squash, --rebase, a 64-character head, and both gates. |
| 1.2g | Negative flows | PASS | One row per RELEASE_MERGE_* code (17 codes) in both trees. |
| 1.2h | Edge cases | PASS | changedFiles 100 versus 101, PrNumber 0 and -1, blank root, 39-character and uppercase head, `open` versus `OPEN`. |
| 1.2i | Error handling | PASS | AC-20 row: a throwing selector returns an empty suffix and a Write-Debug record. |
| 1.2j | Concurrency | N/A | The leg holds no shared state; a head change after lookup is covered by the required --match-head-commit, which gh enforces. |
| 1.2k | State transitions | N/A | The leg is a stateless decision; it writes no state. |
| 1.3a | Clear failure messages | PASS | `-Because` carries the suffix or reason on allow rows; code rows assert the exact code. |
| 1.3b | Arrange-Act-Assert | PASS | Comment-marked sections in every row. |
| 1.3c | Document intent | PASS | Synopsis and description blocks in each suite; descriptive `It` names. |
| 1.4a | Avoid external dependencies | PASS | Invoke-DocsOnlyGhExe and Invoke-DocsOnlyGitExe are mocked with parameter filters; the allowance seams are injected or mocked. |
| 1.4b | Use mocks or stubs | PASS | Wrapper seams only; no executable is mocked directly. |
| 1.4c | Environment stability | PASS | Synthetic `/synthetic-worktrees/...` roots; no temporary file; leak scan 0 failures (evidence/qa-gates/powershell-static.2026-11-24T09-20.md). |
| 1.5 | Pre-submission review | PASS | This artifact. |
| 2.1a | Clarify the objective | PASS | Issue #1234; spec.md D1 to D3. |
| 2.1b | Read existing change plans | PASS | plan.2026-11-23T22-54.md executed in order; one out-of-order source edit during P2-T5 was set aside and re-applied in P3-T1 (evidence/qa-gates/phase-gate.P2.2026-11-24T08-05.md). |
| 2.1c | Document the plan | PASS | Plan checked off on disk; task-check evidence per task. |
| 2.2a | Simplicity first | PASS | One sibling leg file; the gates gain one dot-source, one call line, and one suffix term each. |
| 2.2b | Reusability | PASS | Reuses the #1201 parser, the #1231 pure predicates, the docs-only shape and gh seams, and the child-CI run helpers (release-merge.Parity rows on function set and tokens). |
| 2.2c | Extensibility | PASS | ConfigReader and ContainerProbe are injectable scriptblocks with safe defaults. |
| 2.2d | Separation of concerns | PASS | I/O is limited to Invoke-DocsOnlyGhExe (through the gh seam and the child-CI run list) and the two allowance seams; the checks are pure helpers. |
| 2.3a | Cohesive modules | PASS | The leg holds only the release merge decision and its helpers. |
| 2.3b | At or below the 800-line hard limit | PASS | Largest changed file 500 lines (Claude gate, at its 500 cap); leg 303. |
| 2.3c | Public versus internal | PASS | One entry point Get-EpicMergeGateReleaseDecision; helpers share the EpicMergeGateRelease noun prefix. |
| 2.3d | No circular dependencies | PASS | The leg dot-sources the preimplementation release file and the pure file; neither loads a merge gate. |
| 2.4a | Descriptive names | PASS | Approved verbs; nouns name the step. |
| 2.4b | Docs and docstrings | PASS | Comment-based help on every function; header lists steps, codes, process calls, and dependencies. |
| 2.4c | Comment why | PASS | Comments state why (fail-closed on unreadable output, policy-level disclosure). |
| 2.5a | Formatting | PASS | 0 `Formatted: ` lines over 19 files. |
| 2.5b | Linting | PASS | 0 analyzer findings over 19 files. |
| 2.5c | Type checking | N/A | PowerShell has no type checker stage. |
| 2.5d | Testing | PASS | Final Pester 29483 tests, 0 failures; final pytest 17104 passed, 0 failures. |
| 2.5e | Full toolchain loop | PASS | The first final Pester gate failed 5 tests; the causes were fixed and the loop restarted from format and passed (evidence/other/final-qa-remediation.2026-11-24T09-16.md). |
| 2.5f | Explicit reporting | PASS | Commands and results recorded per evidence artifact. |
| 2.6a | Summarize changes | PASS | Summarized in the executor completion report. |
| 2.6b | Design choices explained | PASS | spec.md D1 to D3; plan D4 to D8. |
| 2.6c | Update supporting documents | PASS | Orchestrator-state rule, execution-environment brief (four copies), pr-author skill, through their sources and the generator. |
| 2.6d | Provide next steps | PASS | Commit, push, and pull request remain with the orchestrator; no commit was made by instruction. |
| 3A | Python code change policy | N/A | No Python file changed. |
| 3B.1a | Formatting with Invoke-Formatter | PASS | Invoke-PoshQCFormat, 0 changed files. |
| 3B.1b | Linting with PSScriptAnalyzer | PASS | 0 findings. |
| 3B.1c | Fix all findings | PASS | PSUseOutputTypeCorrectly (leg), PSReviewUnusedParameter and PSUseShouldProcessForStateChangingFunctions (test helpers) fixed during task checks. |
| 3B.1d | PowerShell 5.1 and 7.6+ compatible | N/A | The repository rule and the hooks target PowerShell 7+; the leg uses `ConvertFrom-Json -NoEnumerate` as the existing child-CI helper does. |
| 3B.2a | Advanced functions | PASS | CmdletBinding and typed parameters on every leg function. |
| 3B.2b | Parameter validation | PASS | Mandatory, AllowNull, AllowEmptyString, and Nullable[int] attributes. |
| 3B.2c | Avoid global state | PASS | The leg defines no script-scope variable. |
| 3B.2d | Error handling | PASS | Whole-body try/catch with Write-Debug; seams fail closed on $null. |
| 3B.3a | Cohesive and at or below 800 lines | PASS | See 2.3b. |
| 3B.3b | Approved verbs | PASS | Get- only in the leg; Get-, Set-, Invoke-, Test-, ConvertTo- in tests. |
| 3B.3c | Comment why | PASS | See 2.4c. |
| 3B.4 | Running the toolchain | PASS | Format, analyze, test in order at each phase gate and the final loop. |
| 3C | Bash script policy | N/A | No committed Bash file changed; SCRATCH launcher scripts are throwaway. |
| 3D | JSON configuration policy | PASS | The two core.json edits keep strict JSON and the existing order; the manifest-completeness and dependency-closure tests pass. |
| 4A | Python unit test policy | N/A | No Python test added. |
| 4B.1a | Use Pester v6 | PASS | Pester 6.2.0 through Invoke-PoshQCParallelTest. |
| 4B.1b | Use PoshQC configuration | PASS | Launcher `pester` suite. |
| 4B.2a | Focused unit tests | PASS | See 1.1b. |
| 4B.2b | Behavior over implementation | PASS | Rows assert decisions, suffixes, and call counts. |
| 4B.2c | Mocking used sparingly | PASS | Only process and file seams are mocked. |
| 4B.2d | Organization mirrors code | PASS | `.claude/hooks` suites under tests/scripts/claude-hooks, `.codex/hooks` under tests/scripts/codex-hooks. |
| 4B.3 | File naming and structure | PASS | `*.Tests.ps1`, Describe/Context/It. |
| 4B.4 | No alternative test runners | PASS | Every run went through the launcher. |
| 6-8 | Execution metrics, quality checks, gaps | PASS | No identified gap; no skipped or removed test. |

## Code Review

| # | Checklist item | Result | Evidence |
|---|---|---|---|
| CR-1 | No secrets in code | PASS | No credential or token text in any changed file. |
| CR-2 | No unsafe subprocess or command construction | PASS | gh runs only through the bounded Invoke-DocsOnlyGhExe with an argument array; no string-built command. |
| CR-3 | Input validation at boundaries | PASS | gh output is parsed with -NoEnumerate and each field type-checked (step 6). |
| CR-4 | Error handling remains explicit | PASS | Every failure returns a named code; an unexpected error is logged with EPIC_MERGE_GATE_RELEASE_LEG_ERROR. |
| CR-5 | Configuration and path handling is safe | PASS | The allowance is read only through the existing seams; no path is built from gh output. |
| CR-6 | Test quality: determinism, isolation, speed, diagnostics | PASS | See 1.1a to 1.1e and 1.3a. |

## Feature Audit

| # | Checklist item | Result | Evidence |
|---|---|---|---|
| FA-1 | Acceptance criteria inventory | PASS | spec.md AC-01 to AC-40; user-story.md US-AC-01 to US-AC-13. |
| FA-2 | Acceptance criteria evaluation | PASS | All 40 spec and 13 user-story criteria checked off after their task verification. |
| FA-3 | AC status summary | PASS | spec.md 40 of 40; user-story.md 13 of 13; none remaining. |
