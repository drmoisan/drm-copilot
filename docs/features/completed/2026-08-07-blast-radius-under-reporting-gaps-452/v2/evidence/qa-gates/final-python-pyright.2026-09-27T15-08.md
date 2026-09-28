# Final QA — Repository-Wide Pyright (P6-T4)

Timestamp: 2026-09-27T15-08

Iteration: 1

Command: poetry run pyright

EXIT_CODE: 0

Output (tail):

```
venv .venv subdirectory not found in venv path <worktree root>.
0 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
```

Output Summary: "0 errors, 0 warnings, 0 informations". The error set is empty, a subset of the empty P0-T22 baseline, with no diagnostic in the consumer file.
