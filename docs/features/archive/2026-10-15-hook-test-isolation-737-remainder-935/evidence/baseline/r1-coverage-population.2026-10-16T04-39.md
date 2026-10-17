# R1 Coverage Population Identity (P0-T5)

Timestamp: 2026-10-16T04-39
Command: git diff --quiet adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99 HEAD -- .claude/hooks .claude/lib .codex/hooks .codex/scripts scripts config/poshqc-coverage.json config/poshqc-scan.json; grep -n -F -e 'scanFolders' config/poshqc-scan.json; grep -n -F -e 'Invoke-PoshQCTest -Root' .github/workflows/_poshqc.yml
EXIT_CODE: 0
Output Summary:
- `git diff --quiet ...` exit code: 0 -> `ROOTS-IDENTICAL`
- `grep -n -F -e 'scanFolders' config/poshqc-scan.json` (exit 0): `4:    "scanFolders": ["scripts", "tests/powershell", "tests/scripts"]`
- `grep -n -F -e 'Invoke-PoshQCTest -Root' .github/workflows/_poshqc.yml` (exit 0): `42:          Invoke-PoshQCTest -Root "${{ github.workspace }}"`
- CI baseline population: CI run 38730332356 at `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`, denominator 18116 lines; coverage roots from `config/poshqc-coverage.json`: `.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, `scripts`.
- CI calls `Invoke-PoshQCTest` with no `-ScanFolders`, so the configured `test.scanFolders` set (`scripts`, `tests/powershell`, `tests/scripts`) applies.

ROOTS-RESULT: ROOTS-IDENTICAL
