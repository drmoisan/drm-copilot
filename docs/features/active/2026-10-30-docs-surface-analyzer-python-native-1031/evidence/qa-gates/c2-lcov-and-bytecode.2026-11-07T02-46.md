# [P3-T14] Repo-wide LCOV and bytecode

Timestamp: 2026-11-07T02-46
Command: grep -c on artifacts/python/lcov.info; date -r for its modification time; find for __pycache__ and *.pyc under PYLIB and MIRROR/python
EXIT_CODE: 0
Output Summary: artifacts/python/lcov.info holds 384 SF records, 226 under scripts/dev_tools/, written after the full run started; both bytecode listings are empty.

## Checks

| Check | Result |
|---|---|
| Modification time of `artifacts/python/lcov.info` | 2026-11-07T02:45:59 UTC, later than the [P3-T13] start 2026-11-07T02:36:58 UTC |
| `SF:` records | 384 |
| `SF:` records under `scripts/dev_tools/` | 226 (the file uses Windows path separators on this host) |
| `__pycache__` listing under `PYLIB` and `MIRROR/python` | empty |
| `.pyc` listing under `PYLIB` and `MIRROR/python` | empty |

`artifacts/python/lcov.info` is the repo-wide file (M4, S15).
