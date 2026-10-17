# CheckClassification Suite Size (Issue #931)

Timestamp: 2026-10-16T01-37
Command: wc -l tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckClassification.Tests.ps1
EXIT_CODE: 0
Output Summary: 151 lines (limit 500). The Grep tool count for `New-TemporaryFile|Set-Content|Out-File` is 0. The file has 17 lines matching `^\s+It "` (10 + 7) and 2 lines matching `^\s*BeforeAll`.

| Check (Grep tool, count mode) | Result |
|---|---|
| `New-TemporaryFile\|Set-Content\|Out-File` | 0 |
| `^\s+It "` | 17 |
| `^\s*BeforeAll` | 2 |

Describe blocks: `Invoke-FullReleaseFlow.ps1 - Get-CheckSetVerdict` (10 tests) and `Invoke-FullReleaseFlow.ps1 - ConvertFrom-CheckPollOutput` (7 tests). Each block has its own `BeforeAll` that resolves the script and dot-sources it with `-ConfirmToken 'no'`.
