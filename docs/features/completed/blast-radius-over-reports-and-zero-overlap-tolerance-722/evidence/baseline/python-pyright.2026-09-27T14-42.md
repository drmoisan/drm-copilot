# Python Type Baseline (P0-T17)

Timestamp: 2026-09-27T14-42
Command: poetry run pyright
EXIT_CODE: 0
Output Summary: Pyright exited 0 and printed "0 errors, 0 warnings, 0 informations". Error count: 0. Pyright also printed an informational note that the configured venv subdirectory is not present in the worktree root and a newer-version notice; neither affects the result.

## Printed output

```text
venv .venv subdirectory not found in venv path <worktree root>.
0 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
```

The worktree root path in the first line is replaced by a placeholder so that no host path is recorded.
