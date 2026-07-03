# Phase 0 — Policy Instructions Read (Remediation Cycle 1, Issue #275)

- **Timestamp:** 2026-07-02T23-05
- **Task:** [P0-T1]

## Policy Order

Files read in this exact order, per the plan's Phase 0 task text:

1. `.github/copilot-instructions.md`
2. `.github/instructions/general-code-change.instructions.md`
3. `.github/instructions/general-unit-test.instructions.md`
4. `.github/instructions/powershell-code-change.instructions.md`
5. `.github/instructions/powershell-unit-test.instructions.md`
6. `.github/instructions/python-code-change.instructions.md`
7. `.github/instructions/python-unit-test.instructions.md`
8. `.github/instructions/typescript-code-change.instructions.md`
9. `.github/instructions/typescript-unit-test.instructions.md`

## Output Summary

All 9 files were read in full, in the order listed above. No conflicting instructions were
encountered. Key constraints reaffirmed for this remediation cycle: 500-line file size limit
(general-code-change), no temporary files in tests, mandatory format → lint → type-check → test
toolchain loop restarted on any failure or auto-fix, PowerShell toolchain must use the
`mcp__drm-copilot__run_poshqc_*` MCP functions (not VS Code task wrappers), Python toolchain uses
Black/Ruff/Pyright/Pytest via `poetry run`, TypeScript toolchain uses Prettier/ESLint/TSC/Jest via
`npm run` scripts.
