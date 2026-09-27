# Final Python Type Check (P15-T3)

Timestamp: 2026-09-27T18-01
Command: poetry run pyright
EXIT_CODE: 0
Output Summary: PASS. Pyright exited 0 and printed "0 errors, 0 warnings, 0 informations". It also printed the same informational venv note and newer-version notice recorded at baseline (P0-T17); neither affects the result.

## Printed output

```text
venv .venv subdirectory not found in venv path <worktree root>.
0 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
```

The worktree root path in the first line is replaced by a placeholder so that no host path is recorded.
