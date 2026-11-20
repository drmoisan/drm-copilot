# Task check — [P6-T8] self-review fix (new-code coverage row)

Timestamp: 2026-11-14T03-53
Command: sh SCRATCH/issue-1156-tc-p6t2.sh (Invoke-Formatter drift comparison and Invoke-ScriptAnalyzer with pssa.settings.psd1 on the two changed test files); TC_PATHS="tests/scripts/claude-lib/regeneration;tests/scripts/claude-hooks/enforce-epic-merge-gate.Regeneration.Tests.ps1;tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1" sh SCRATCH/issue-1156-tc-pester.sh (Run.Path = selection, exit = FailedCount)
EXIT_CODE: 0
Output Summary: format drift 0 files, PSSA findings 0; Pester selection 861 passed, 0 failed, 0 skipped. Not a gate; no coverage measured.

## Reason

While walking the policy-audit template for [P6-T8], the row "New Code Coverage ≥90%" would be FAIL per file: the [P6-T2] gate (`evidence/qa-gates/pester-final.2026-11-14T03-37.md`) read `.claude/lib/regeneration/Invoke-RegenerationPath.ps1` at 89.37% and `.claude/hooks/enforce-epic-merge-gate-regeneration.ps1` at 88.64% line coverage. Each is above the plan's 85% threshold, but below 90%. Per [P6-T8], a FAIL row is fixed and the QA loop re-run from [P6-T1] before the self-review is written.

The uncovered lines were read from `artifacts/pester/powershell-coverage.xml`:

- `Invoke-RegenerationPath.ps1`: the seam defaults (`-TestPath`, `-ReadText`, the git and process `-Invoker` defaults, `-UtcNow`) and the guarded script body, which no test may execute because they touch the file system, git, a process, or the clock, or need the script to run as a process; and four testable behaviors with no test: the git invoker result missing `ExitCode` or `Lines`, the empty `-ConfigPath` fallback in `Invoke-RegenerationPathCommand`, and the catch path of `Invoke-RegenerationGitStep`.
- `.claude/hooks/enforce-epic-merge-gate-regeneration.ps1`: the dictionary branch of `Get-EpicMergeGateRegenerationMember`, the missing-`head_sha` denial, and the non-list `regeneration_events` denial. The byte-identical Codex copy covers these through `tests/scripts/codex-hooks/enforce-epic-merge-gate-regeneration.Tests.ps1`, but the Claude suite reached the Claude copy only through the gate with PSCustomObject checkpoints.

## Changed files

- `tests/scripts/claude-lib/regeneration/Invoke-RegenerationPath.Tests.ps1` (585 lines): added `treats an empty -ConfigPath as omitted, reading the default path with the same exit code, in <Id>` (R19, R43), `Describe 'Invoke-RegenerationGitStep'` with `returns the wrapper result unchanged when the wrapper succeeds` and `reports a throwing wrapper as exit code -1 with empty output`, and `throws for an invoker result without <Missing>` (Lines, ExitCode).
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.Regeneration.Tests.ps1` (359 lines): added `Context 'direct decision cases on the Claude copy of the helper'` with four cases (hashtable checkpoint allowed, hashtable checkpoint without `regeneration_events` denied, delta outcome without `head_sha` denied, non-list `regeneration_events` denied), and one sentence in the help block.

No production file changed. No existing assertion was changed or removed.

## Selection and rule

Rule: the changed test files, the rest of the regeneration test folder they share helpers with, and the closure-isolation discovery guard, which scans the merge-gate suites for baseline mocks and probes.

## Commands and exit codes

| Step | Command | Exit | Result |
|---|---|---|---|
| format + analyze | sh SCRATCH/issue-1156-tc-p6t2.sh | 0 | drift 0 files, PSSA 0 findings |
| test | Invoke-Pester, Run.Path = selection | 0 | 861 passed, 0 failed |
