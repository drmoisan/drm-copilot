# Toolchain availability (issue #543)

Timestamp: 2026-10-02T05-01
Task: P0-T4
Command:
1. `poetry run python --version`
2. `ls extensions/drm-copilot/node_modules/jest/package.json extensions/drm-copilot/node_modules/prettier/package.json` (D3 substitute for the two `Test-Path` checks)
3. `npm ci` in `extensions/drm-copilot/` (run because check 2 failed), then check 2 repeated
4. `mcp__drm-copilot__run_poshqc_test` with `workspace_root` = this worktree, `scan_folders: ["tests/scripts/codex-hooks"]`, then `artifacts/pester/pester-junit.xml` read (D3 substitute for `Get-Module -ListAvailable Pester`)
EXIT_CODE: 0
Route: native (D3) for checks 1-3; poshqc-mcp (D3) for check 4. The plan's `Route: sh-pwsh` is replaced under D3.

Output Summary:
- Python: `Python 3.13.12` (exit 0).
- First `ls` check: both files absent (exit 2), equivalent to `False` for both `Test-Path` checks.
- `npm ci`: exit 0; `added 452 packages, and audited 453 packages in 6s`; `found 0 vulnerabilities`.
- Repeated `ls` check: both files present (exit 0), equivalent to `True` for both checks.
- Pester major version: 5. Derivation per `evidence/other/pwsh-task-classification.2026-10-02T05-00.md`: the PoshQC Pester configuration is a Pester 5 hashtable and the run produced a JUnitXml result file (a Pester 5 output format). The MCP run wrote `artifacts/pester/pester-junit.xml` (fresh mtime, root `testsuites` `tests="1231" errors="0" failures="0"`), so a Pester 5 runtime is established. No literal version string is printed by this route.
