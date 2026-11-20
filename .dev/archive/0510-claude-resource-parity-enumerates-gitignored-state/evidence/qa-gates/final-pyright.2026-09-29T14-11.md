# Final QC Pyright (P5-T4)

Timestamp: 2026-10-07T11-19
Command: poetry run pyright
EXIT_CODE: 0
Output Summary: `0 errors, 0 warnings, 0 informations`. Auxiliary output: a `venv .venv subdirectory not found in venv path` notice (worktree has no local .venv; Pyright used the Poetry-resolved interpreter) and an upstream new-version notice. Neither is a diagnostic.

Deviation note: the Bash tool does not expose the process exit code; EXIT_CODE 0 is inferred from the zero-diagnostic summary line.
