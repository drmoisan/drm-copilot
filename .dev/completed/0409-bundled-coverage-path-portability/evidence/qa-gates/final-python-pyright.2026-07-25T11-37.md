# Final QC — Python Type Check (Pyright) (issue #409)

Timestamp: 2026-07-25T11-37

Command: `poetry run pyright` (run from the repository root)

EXIT_CODE: 0

Output Summary:
- `0 errors, 0 warnings, 0 informations`
- Error count: **0** under `typeCheckingMode = "strict"`. No `# type: ignore` was added anywhere by this change.
- Pyright emitted an informational notice that a newer version is available (v1.1.409 -> v1.1.411). This is not a diagnostic, does not affect the exit code, and no version change was made (out of scope).
