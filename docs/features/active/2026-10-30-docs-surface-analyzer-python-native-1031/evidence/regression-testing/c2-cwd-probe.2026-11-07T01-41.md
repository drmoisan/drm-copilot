# [P1-T4] Working-directory probe after the fix

Timestamp: 2026-11-07T01-41
Command: `sh SCRATCH/issue-1031-pwsh.sh issue-1031-cwd-probe.ps1 -Expect fixed`
EXIT_CODE: 0
Output Summary: VERDICT: PASS. From another directory, auto and native each exit 0 with 7 native elements, no fallback diagnostic, and the same element_id set as the run from the repository root.

## Runs

| Run | Method | Location | Exit | Elements | Method counts | PYTHON_NATIVE_UNAVAILABLE diagnostics | Findings |
|---|---|---|---|---|---|---|---|
| A | native | repository root | 0 | 7 | native=7 | 0 | 0 |
| B | auto | SCRATCH/probe/elsewhere with -RepositoryRoot | 0 | 7 | native=7 | 0 | 0 |
| C | native | SCRATCH/probe/elsewhere with -RepositoryRoot | 0 | 7 | native=7 | 0 | 0 |

Element identifier comparison: the sorted `element_id` sets of runs B and C equal that of run A (7 identifiers each).

The probe copied the fixed `.claude/lib` again and started the real interpreter. Its last output line is `VERDICT: PASS`.
