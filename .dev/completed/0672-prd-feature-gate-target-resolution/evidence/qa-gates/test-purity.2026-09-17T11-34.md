# Test Purity of the New Companion Suite

Timestamp: 2026-09-17T11-34

Command: `Select-String -SimpleMatch -Pattern '<token>' -Path '<path>'`, once per token against `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` and once per token against its named control file (`sh runps.sh p4verify.ps1`); and a direct invocation of the PreToolUse hook `.claude/hooks/check-powershell-test-purity.ps1` with a `Write` payload carrying the new suite's path and content (`sh runps.sh purityhook.ps1`).

EXIT_CODE: 0

Output Summary — all fourteen results, recorded individually:

| token | new suite | control file | control count |
| --- | --- | --- | --- |
| `New-Item` | **0** | `.claude/hooks/persist-session-id.ps1` | 1 (line 96) |
| `Set-Location` | **0** | `docs/features/completed/2026-06-16-pre-claude-session-script-189/spec.md` | 2 (lines 12, 28) |
| `Push-Location` | **0** | `scripts/powershell/Publish-DrmCopilotExtension.ps1` | 3 (lines 259, 281, 309) |
| `Get-Location` | **0** | `.claude/hooks/persist-session-id.ps1` | 1 (line 161) |
| `$PWD` | **0** | `scripts/powershell/PoshQC/PoshQC.Testing.psm1` | 2 (lines 75, 291) |
| `GetTempPath` | **0** | `.claude/hooks/check-powershell-test-purity.ps1` | 2 (lines 17, 107) |
| `$env:TEMP` | **0** | `.claude/hooks/check-powershell-test-purity.ps1` | 2 (lines 17, 108) |

All seven searches return zero matches on the new suite and all seven control counts are non-zero, so each zero is evidence of absence rather than of an unmatchable search. The `Set-Location` control is drawn from a tracked Markdown file because no PowerShell file in this tree contains that token; the control's only purpose is to prove the search mechanism matches when the token is present, and the file type is immaterial to that.

`check-powershell-test-purity.ps1` outcome: **pass** (exit 0, no deny output) for a `Write` payload carrying the new suite's full content. That pass is a partial and not a complete substitute for the seven searches: the hook's forbidden-pattern list at lines 99-117 covers `GetTempPath` and `$env:TEMP` of these seven and none of the other five, so the five zero-match results above are established by the searches alone.

The suite models the current directory as data on the `SessionRoot` member of an injected target result, declares both worktree roots as bare string literals, creates no temporary file or directory, and changes no process state.
