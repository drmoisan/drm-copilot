# [P0-T7] Remediation baseline: comment audit

Timestamp: 2026-11-06T13-23
Command: pwsh -File SCRATCH/issue-1031-comment-audit.ps1 -Mode production -Path .claude/lib/docs/python; pwsh -File SCRATCH/issue-1031-comment-audit.ps1 -Mode test -Path tests/scripts/claude-lib/docs/python (both launched by `sh SCRATCH/issue-1031-audit.sh` from the worktree root)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Both runs print `VERDICT: FAIL` (exit 1, the expected baseline outcome). Production (12 PYLIB files): 284 findings, R-DOC 61, R-ARGS 57, R-RET 61, R-ATTR 14, R-LOOP 91, R-NOTE 0. Test (15 PYTESTS files): 203 findings, R-DOC 190, R-LOOP 13, R-NOTE 0. R-DOC 61, R-LOOP 91 (production) and R-LOOP 13 (test) equal the reviewer's counts, so the audit discriminates.

## AUDIT_BASELINE_COUNTS

| Mode | R-DOC | R-ARGS | R-RET | R-ATTR | R-LOOP | R-NOTE | Total |
|---|---|---|---|---|---|---|---|
| production | 61 | 57 | 61 | 14 | 91 | 0 | 284 |
| test | 190 | n/a | n/a | n/a | 13 | 0 | 203 |

## Per-file lines (production)

| File | lines= | findings |
|---|---|---|
| `PKG/__init__.py` | 8 | 0 |
| `PKG/architecture.py` | 124 | 13 |
| `PKG/cli_argparse.py` | 333 | 33 |
| `PKG/cli_click.py` | 343 | 34 |
| `PKG/cli_typer.py` | 321 | 18 |
| `PKG/cli.py` | 174 | 18 |
| `PKG/imports.py` | 370 | 33 |
| `PKG/protocol.py` | 257 | 25 |
| `PKG/public_api.py` | 234 | 24 |
| `PKG/routes.py` | 467 | 39 |
| `PKG/source.py` | 268 | 43 |
| `PYLIB/run_docs_python_native.py` | 47 | 4 |

## Per-file lines (test)

| File | lines= | findings |
|---|---|---|
| `conftest.py` | 10 | 0 |
| `test_docs_python_native_architecture.py` | 110 | 7 |
| `test_docs_python_native_cli_argparse.py` | 148 | 13 |
| `test_docs_python_native_cli_click.py` | 191 | 14 |
| `test_docs_python_native_cli_typer.py` | 206 | 14 |
| `test_docs_python_native_cli.py` | 111 | 10 |
| `test_docs_python_native_corpus.py` | 148 | 13 |
| `test_docs_python_native_determinism.py` | 70 | 5 |
| `test_docs_python_native_entry.py` | 57 | 8 |
| `test_docs_python_native_imports.py` | 196 | 23 |
| `test_docs_python_native_protocol.py` | 187 | 14 |
| `test_docs_python_native_public_api.py` | 175 | 15 |
| `test_docs_python_native_routes.py` | 211 | 15 |
| `test_docs_python_native_safety.py` | 105 | 15 |
| `test_docs_python_native_source.py` | 221 | 37 |
