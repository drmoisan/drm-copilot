# Final coverage remediation (issue #732)

Timestamp: 2026-10-09T04-30
Task: [P7-T7]

COVERAGE_REMEDIATION: pass 2 applied

Trigger: pass-2 [P7-T6] (`final-coverage-delta.md`) recorded `VERDICT: FAIL` for `.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` and `.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` (POST 99.19, `CHANGED_MISSED: 1`). The [P7-T5] `MISSED_LINES` entry for both files is line 52, the trailing-slash removal in `ConvertTo-OrchestrationTargetPath`.

Test file written: `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.C1bCoverage.Tests.ps1` (no temporary file, no child process; rule 14). Rows, each run on `(.claude/hooks)` and `(.codex/hooks)`:

- `removes one trailing slash from a rooted path` - `ConvertTo-OrchestrationTargetPath -Path '/synthetic-worktrees/session/'` returns `/synthetic-worktrees/session` (drives line 52).
- `removes one trailing slash from a backslash-spelled drive path` - `'C:\wt\'` returns `C:/wt` (drives line 52).
- `keeps the bare POSIX root unchanged` - `'/'` returns `/` (line 51 false branch).
- `keeps a bare drive root unchanged` - `'C:/'` returns `C:/` (line 51 false branch).
- `resolves a segment without -C to a session root given with a trailing slash` - `Get-OrchestrationCommandTarget -Command 'git add a.ps1' -SessionRoot '/synthetic-worktrees/session/'` returns the single target `/synthetic-worktrees/session` (drives line 52 through the public resolver).

Smoke run (R-SCOPED over the file): PassedCount 10, FailedCount 0, FailedBlocksCount 0, FailedContainersCount 0 (`evidence/other/c1bcoverage-smoke.md`). The loop restarts at [P7-T2] (pass 3); this task's done condition is evaluated on the pass-3 [P7-T6] and [P7-T8].

Output Summary: Remediation applied in pass 2 for the two targets copies (missed line 52); five rows per surface added in the C1bCoverage suite; the smoke run passed 10 of 10.

COVERAGE_REMEDIATION: pass 3 not-required

Pass 3: [P7-T6] (final-coverage-delta.md) has no FAIL row (both targets copies POST 100.00, CHANGED_MISSED 0); no [P7-T8] run has recorded a POSHQC_LINE_COVERAGE value below 85.00. No test file written in pass 3.

Done-condition evaluation: the remediation branch (pass 2) was followed by pass 3, whose [P7-T6] has no FAIL row and whose [P7-T8] (final-pester-full.md) records all seven POSHQC_LINE_COVERAGE values at or above 85.00 (targets copies 100.00): met.
