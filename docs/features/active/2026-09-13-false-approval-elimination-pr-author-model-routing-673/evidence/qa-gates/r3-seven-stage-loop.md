# Seven-Stage Toolchain Record: AC-33 (issue #673)

Timestamp: 2026-09-19T19-27

Command: this artifact maps the seven stages onto the tasks that ran them; each cited task records its own command and exit code. The one measurement taken here is `Select-String -SimpleMatch -Pattern 'dependency-cruiser','NetArchTest'` over `tests/scripts`, run recursively.

EXIT_CODE: 0

## The seven stages

| # | Stage | Task or reason | Result |
| --- | --- | --- | --- |
| 1 | Formatting | `[P11-T1]` (`Invoke-PoshQCFormat`) and the black step of `[P11-T3]` | `Formatted: 0`, `Already formatted: 506`, porcelain identical; black reports one file unchanged |
| 2 | Linting | `[P11-T2]` (`Invoke-PoshQCAnalyze`) and the ruff step of `[P11-T3]` | zero analyzer findings at Error, Warning, and Information severity; `All checks passed!` |
| 3 | Type checking | the pyright step of `[P11-T3]` | `0 errors, 0 warnings, 0 informations`. Not applicable for PowerShell per `.claude/rules/powershell.md`, which states type checking is skipped for that language |
| 4 | Architecture-boundary tests | **not applicable.** `Select-String -SimpleMatch -Pattern 'dependency-cruiser','NetArchTest'` over `tests/scripts` returns a count of **0**, so this repository has no architecture-boundary tooling for the languages in scope. This task text authorizes this one not-applicable entry and no other | count 0 |
| 5 | Unit tests | `[P11-T4]` (full Pester with coverage) and `[P11-T6]` (full Python suite) | 4954 passed, 0 failed, 0 errored, 9 pre-existing skips; 4419 passed, 5 pre-existing skips |
| 6 | Contract and schema checks | `[P11-T7]` (bundled-payload parity plus eleven SHA-256 pairs), the `WorktreeResolution.Manifest.Tests.ps1` result in `[P11-T4]`, and the frozen-pin result in `[P11-T4]` | parity test `1 passed`; eleven pairs equal; manifest testsuite 10 of 10 passed; the frozen-surface pin passes with the epic-skill digest re-baselined and the agent digest unchanged |
| 7 | Integration tests | the fixture rows and the end-to-end child-process row inside `[P11-T4]` | the pr-author and model-routing matrices run against committed fixture bytes with real checkpoint reads, 18 and 20 rows passing; the end-to-end row `blocks gh pr create --body-file end-to-end in a real pwsh process (exit 0, deny, TARGET_WORKTREE_NOT_DERIVABLE)` spawns a real child process and passes |

## Single-Pass Statement:

`[P11-T1]`, `[P11-T2]`, and `[P11-T4]` completed in **one pass** with no file rewritten and no failure. The pass number is **2**.

Pass 1 is recorded rather than hidden. It reached `[P11-T2]`, which failed with `PSScriptAnalyzer reported 15 issue(s).` All fifteen were Warning-severity findings in test files this plan authored — eleven on the `New-` and `Set-` verbs of test-local factory and mock-registration helpers, four on mock-body parameters declared but not read. Each was fixed at its cause: the eleven took the suppression attribute with a justification that the repository already applies to two pre-existing helpers in the same situation, and the four unused parameter declarations were removed, since a Pester mock body binds by name and need only declare what it reads. Those fixes changed six test files, so the loop restarted from `[P11-T1]` as the plan requires.

In pass 2, `[P11-T1]` rewrote no file and left the porcelain output identical, `[P11-T2]` reported zero findings, and `[P11-T4]` recorded zero failures and zero errors. No step of pass 2 failed and no step changed a file, so pass 2 is the clean pass the gate requires.

One condition of the loop is **not met** and is recorded here as well as in its own artifact: `[P11-T5]`'s no-regression sub-condition holds for four of the six hooks and fails for two, `.claude/hooks/enforce-prd-feature-before-planner.ps1` (90.72% to 90.32%) and `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` (96.77% to 96.61%). In both files the count of uncovered lines is unchanged and the ratio fell only because the plan requires deleting code that was covered. Changed-line coverage for both is 100%. That shortfall is a coverage-delta condition rather than a toolchain stage, so it does not make any of the seven stages fail, and it is escalated rather than waived.

Output Summary: Seven stage rows recorded, each naming its task or its reason. Stage 4 is the single authorized not-applicable entry, supported by a measured count of 0 architecture-boundary tooling references under `tests/scripts`. The `Single-Pass Statement:` section names pass 2 as the clean pass and records pass 1's fifteen analyzer findings and their at-cause fixes. One coverage-delta sub-condition outside the seven stages is not met and is escalated.
