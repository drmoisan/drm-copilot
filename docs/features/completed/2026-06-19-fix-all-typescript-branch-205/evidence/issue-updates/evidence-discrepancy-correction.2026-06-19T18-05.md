# Evidence Discrepancy Correction (Issue #205)

Timestamp: 2026-06-19T18-05

## Discrepancy

The prior coverage evidence (`evidence/qa-gates/coverage-delta.md` and
`evidence/qa-gates/pytest-final.md`, both dated 2026-06-19T17-36) documented a
pytest coverage command that referenced only one test file
(`tests/scripts/dev_tools/test_fix_all.py`), while the fix-all coverage actually
depends on multiple test files.

## Correction

Both evidence files were updated so the recorded coverage command references all
three fix-all test files. The corrected, authoritative command is:

`poetry run pytest --cov=scripts/dev_tools --cov-branch --cov-report=term-missing tests/scripts/dev_tools/test_fix_all.py tests/scripts/dev_tools/test_fix_all_branches.py tests/scripts/dev_tools/test_fix_all_failure_paths.py`

Files corrected:
- `docs/features/active/2026-06-19-fix-all-typescript-branch-205/evidence/qa-gates/coverage-delta.md`
- `docs/features/active/2026-06-19-fix-all-typescript-branch-205/evidence/qa-gates/pytest-final.md`

PostedAs: unknown (local evidence mirror; not posted to GitHub as part of this
remediation execution).
