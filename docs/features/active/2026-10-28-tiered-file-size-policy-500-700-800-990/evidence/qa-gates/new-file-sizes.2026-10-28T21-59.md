# Created File Sizes (Final QA)

Timestamp: 2026-10-28T21-59
Command: Import-Module ./.claude/lib/file-size-policy/FileSizePolicy.psm1; Get-FileSizeLogicalLineCount -Content ([IO.File]::ReadAllText(<file>)) for each created code or test file (sh launcher under SCRATCH)
EXIT_CODE: 0
Output Summary: every created code or test file is below 500 logical lines (largest: the shared module and its bundle copy at 415).

| File | Logical lines |
|---|---|
| `.claude/lib/file-size-policy/FileSizePolicy.psm1` | 415 |
| `.claude/hooks/enforce-file-size-limit.ps1` | 244 |
| `.codex/hooks/file-size-policy.ps1` | 403 |
| `.codex/hooks/enforce-file-size-limit.ps1` | 282 |
| `scripts/ci/FileSizeBaseline.psm1` | 174 |
| `scripts/ci/New-FileSizeBaseline.ps1` | 157 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/file-size-policy/FileSizePolicy.psm1` | 415 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-file-size-limit.ps1` | 244 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/file-size-policy.ps1` | 403 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-file-size-limit.ps1` | 282 |
| `tests/scripts/claude-lib/file-size-policy/FileSizePolicy.Cases.ps1` | 124 |
| `tests/scripts/claude-lib/file-size-policy/FileSizePolicy.Tests.ps1` | 131 |
| `tests/scripts/claude-lib/file-size-policy/FileSizePolicy.HookDecision.Tests.ps1` | 111 |
| `tests/scripts/claude-lib/file-size-policy/FileSizePolicy.Manifest.Tests.ps1` | 82 |
| `tests/scripts/claude-hooks/enforce-file-size-limit.Tests.ps1` | 303 |
| `tests/scripts/codex-hooks/file-size-policy.Tests.ps1` | 117 |
| `tests/scripts/codex-hooks/enforce-file-size-limit.Tests.ps1` | 337 |
| `tests/scripts/ci/FileSizeBaseline.Tests.ps1` | 129 |
| `tests/scripts/ci/New-FileSizeBaseline.Tests.ps1` | 180 |
| `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` | 103 |

`config/file-size-baseline.json` (7 lines) is JSON and outside the covered set.
