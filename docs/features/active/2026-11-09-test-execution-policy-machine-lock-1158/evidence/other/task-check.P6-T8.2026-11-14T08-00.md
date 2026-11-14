# Task Check: P6-T8

Timestamp: 2026-11-14T08-00
Command: sh SCRATCH/issue-1158-psstatic.sh (Invoke-Formatter comparison and Invoke-ScriptAnalyzer on the test file); Pester `Run.Path` = the selection below, `Run.Exit` = `$true`; `wc -l` on the test file
EXIT_CODE: 0
Output Summary: PowerShell format diffs 0, PSSA findings 0; `parallel-gate-wording.Tests.ps1` 88 rows passed, 0 failed, with both ledger test files in the same run (108 passed, 0 failed); a re-run of the three ledger files after the `Rebased over #1158` paragraphs 92 passed, 0 failed; the file has 292 lines (under 500).

## Changed Files

- `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`: `$script:D13Required` (`CI integration and golden lanes are evidence`, `non-blocking deviation`, `machine test-suite lock`); `$script:ExecutorRouteForbidden` (`$script:ExecutorListForbidden` plus `Bash(poetry run pytest` and `Bash(npx jest`), used by `EXEC-CLAUDE`, `EXEC-CLAUDE-BUNDLE`, and `EXEC-CODEX`, which also require `run-test-suite.sh`; `$script:ReviewLauncherForbidden` (`$script:ReviewCommandForbidden` plus `npm run test:unit:coverage`), used by `REVIEW-CLAUDE`, `REVIEW-AGENTS`, `REVIEW-CLAUDE-BUNDLE`, and `REVIEW-AGENTS-BUNDLE`, which also require the D13 tokens and `run-test-suite.sh`; the D13 tokens added to the six `PLAN-` rows and the eight `QA-PS-` and `QA-PY-` rows; 32 new rows: six `BRIEF-` rows (D13 tokens and `run-test-suite.sh`), six `QA-CS-` rows (including the two csharp-legacy variants), fourteen `INVOKE-` rows (including the two csharp-legacy variants), and six `TS-AGENT-` rows (Claude, Codex, and Copilot `typescript-engineer` copies). Other existing rows are unchanged.
- Ledger rule, highest number first: the `0006` hunks on this file were regenerated as the difference between the edited pre-`0006` text and the edited live text (seven hunks), and the `0001` creation hunk now carries the edited pre-`0006` text (295 lines). Both entries gained a `Rebased over #1158` paragraph.

## Selection and Rule

Rule: the changed test file itself, plus the ledger tests for the ledger rule (`## Test Cadence (Mandatory)`).

- Pester: `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`, `tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1`, `tests/scripts/dev-tools/ProcessReductionLedger.Index.Tests.ps1`, `tests/scripts/dev-tools/ProcessReductionLedger.Tests.ps1`.

## Commands and Exit Codes

| Step | Command | EXIT_CODE |
|---|---|---|
| format | Invoke-Formatter comparison | 0 (0 diffs) |
| lint | Invoke-ScriptAnalyzer with the repository settings | 0 (0 findings) |
| tests | Pester, the selection above | 0 |

Type check: not applicable (PowerShell).
