# Timestamp Rows Scan Before (Issue #543)

Timestamp: 2026-10-07T09-24
Command: poetry run python artifacts/scratch/rows_543.py af7a236790073729264cef9b7332a8f5550d27f3 (run from the worktree root; verbatim rows_543.py of the plan, placed in the git-ignored artifacts/scratch/ directory; output redirected to artifacts/scratch/rows_before.txt)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: the scan reports exactly one LATE row, for the R1 target row; the last commit minute 05-19 is not earlier than the corrected value 05-18.
- `SUMMARY old_files=78 old_rows=79 late=1 bad=0 new_files=6 new_rows=6`
- `ROW docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/other/python-batch-budget.2026-10-02T05-01.md:31 value=2026-10-02T05-30 last_commit=2026-10-02T05-19 LATE`
