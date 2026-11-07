# [P0-T7] Working-directory probe before the fix

Timestamp: 2026-11-07T01-33
Command: `sh SCRATCH/issue-1031-pwsh.sh issue-1031-cwd-probe.ps1 -Expect defect`
EXIT_CODE: 0
Output Summary: VERDICT: PASS. F6 reproduced: run A native exit 0; run B auto falls back to the scanner with exit-nonzero; run C native exits 3 with DOCS_PYTHON_NATIVE_UNAVAILABLE.

## Runs

| Run | Method | Location | Exit | Elements | Method counts | Reason token |
|---|---|---|---|---|---|---|
| A | native | repository root | 0 | 7 | native=7 |  |
| B | auto | SCRATCH/probe/elsewhere with -RepositoryRoot | 0 | 7 | scanner=7 | exit-nonzero |
| C | native | SCRATCH/probe/elsewhere with -RepositoryRoot | 3 | 0 |  | exit-nonzero |

Probe output: `VERDICT: PASS` under `-Expect defect`, which reproduces F6: from another directory the same repository falls back under `auto` and fails under `native`.
