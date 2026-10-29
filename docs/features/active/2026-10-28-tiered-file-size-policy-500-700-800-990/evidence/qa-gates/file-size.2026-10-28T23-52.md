# File sizes (cycle 2, [P5-T6])

Timestamp: 2026-10-28T23-52
Command: `@(Get-Content -LiteralPath <path>).Count` per inventory file, from a PowerShell 7 script under `SCRATCH`.
EXIT_CODE: 0
Output Summary: every production, test, and script file in the inventory is at most 500 lines (baseline value in parentheses).
- `.claude/lib/file-size-policy/FileSizePolicy.psm1`: 434 (415)
- `.codex/hooks/file-size-policy.ps1`: 421 (403)
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/file-size-policy/FileSizePolicy.psm1`: 434 (byte copy of the module)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/file-size-policy.ps1`: 421 (byte copy of the twin)
- `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1`: 118 (103)
- `tests/scripts/claude-lib/file-size-policy/FileSizePolicy.Tests.ps1`: 164 (131)
- `tests/scripts/codex-hooks/file-size-policy.Tests.ps1`: 125 (117)
