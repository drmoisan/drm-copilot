# Python Type-Check Baseline — [P0-T5]

Timestamp: 2026-08-28T12-46

Command: `poetry run pyright`

EXIT_CODE: 0

## Recorded Counts

| Category | Count |
| --- | --- |
| errors | 0 |
| warnings | 0 |
| informations | 0 |

Verbatim count line:

```
0 errors, 0 warnings, 0 informations
```

Two incidental lines accompany the run and are recorded for completeness. Neither is a diagnostic
against repository source:

```
venv .venv subdirectory not found in venv path c:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a9456a3f1a21c9952.
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.411).
```

The first is a venv-discovery notice specific to the worktree layout; the second is a tool-version
notice. Neither contributes to the error, warning, or information counts, which are all zero.

Output Summary: `EXIT_CODE: 0` with an error count of 0, a warning count of 0, and an information
count of 0. The Python tree is type-clean at baseline.
