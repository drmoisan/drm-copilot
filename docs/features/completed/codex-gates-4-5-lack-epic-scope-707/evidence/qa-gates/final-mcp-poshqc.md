# Final QC Spec-Named MCP Supplementary Check ([P6-T9], AC-26, RS-7)

Timestamp: 2026-09-27T07-35
Command: sh <SCRATCHPAD>/x707p6-run.sh x707p6-format sums (SHA-256 of the 16 section 7 PowerShell paths, before); MCP tool calls mcp__drm-copilot__run_poshqc_format, mcp__drm-copilot__run_poshqc_analyze, mcp__drm-copilot__run_poshqc_test, each with workspace_root set to the worktree root (<WORKSPACE_ROOT>); sh <SCRATCHPAD>/x707p6-run.sh x707p6-format sums (after, 07-40)
EXIT_CODE: 0
Output Summary: Pass 1. All three ok flags are true. All 16 hash pairs are equal, and git status --porcelain after the calls lists only feature-folder evidence paths. Per rule 4 no count, percentage, or finding is read from the MCP results.

Pass: 1

## Ok flags (rule 4: ok flag only)

| Tool | ok |
| --- | --- |
| `mcp__drm-copilot__run_poshqc_format` | true |
| `mcp__drm-copilot__run_poshqc_analyze` | true |
| `mcp__drm-copilot__run_poshqc_test` | true |

Settings argument: none of the three tools exposes a settings argument (the input schemas carry only `workspace_root` and an optional `scan_folders`), so `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` was not passed. `mcp__drm-copilot__run_poshqc_test` therefore ran with the settings it resolves itself.

## Hash Delta

| Path | SHA-256 before | SHA-256 after | Mark |
| --- | --- | --- | --- |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | `150F3F8466B607AAC12D16F668152DF6E9C6B0BF00E43EF3D86EA2C2F4D7B0D1` | `150F3F8466B607AAC12D16F668152DF6E9C6B0BF00E43EF3D86EA2C2F4D7B0D1` | equal |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | `A064ED683C3798FB6D02792FEEED5FE72CBA46DE81F4539FE4CCD12883BBD9F7` | `A064ED683C3798FB6D02792FEEED5FE72CBA46DE81F4539FE4CCD12883BBD9F7` | equal |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-resolution.ps1` | `89BB099CC73E800603C34DADE4F80E73D1D9CCD4561E8454551F05EAB174B6B5` | `89BB099CC73E800603C34DADE4F80E73D1D9CCD4561E8454551F05EAB174B6B5` | equal |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | `150F3F8466B607AAC12D16F668152DF6E9C6B0BF00E43EF3D86EA2C2F4D7B0D1` | `150F3F8466B607AAC12D16F668152DF6E9C6B0BF00E43EF3D86EA2C2F4D7B0D1` | equal |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | `A064ED683C3798FB6D02792FEEED5FE72CBA46DE81F4539FE4CCD12883BBD9F7` | `A064ED683C3798FB6D02792FEEED5FE72CBA46DE81F4539FE4CCD12883BBD9F7` | equal |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-epic-resolution.ps1` | `89BB099CC73E800603C34DADE4F80E73D1D9CCD4561E8454551F05EAB174B6B5` | `89BB099CC73E800603C34DADE4F80E73D1D9CCD4561E8454551F05EAB174B6B5` | equal |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | `DFCCA8C116853F49B42BBC387669AD385ABF8BE6F4D60F9546FDB8B6581D3A71` | `DFCCA8C116853F49B42BBC387669AD385ABF8BE6F4D60F9546FDB8B6581D3A71` | equal |
| `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` | `DFCCA8C116853F49B42BBC387669AD385ABF8BE6F4D60F9546FDB8B6581D3A71` | `DFCCA8C116853F49B42BBC387669AD385ABF8BE6F4D60F9546FDB8B6581D3A71` | equal |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1` | `E24B39A8C91A095035E96FDC66303D1562FF70D6BAD7857B2B6B4A83E47DECD7` | `E24B39A8C91A095035E96FDC66303D1562FF70D6BAD7857B2B6B4A83E47DECD7` | equal |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1` | `21292C8F1FB77B9C204B71334012A829C0F7E0AAE344F3CE3863CD36BC9BAAB6` | `21292C8F1FB77B9C204B71334012A829C0F7E0AAE344F3CE3863CD36BC9BAAB6` | equal |
| `tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1` | `0E349C2258F1492BF333D5212FF64D7E20863F518708A4E3411B24FE38C2F0E9` | `0E349C2258F1492BF333D5212FF64D7E20863F518708A4E3411B24FE38C2F0E9` | equal |
| `tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1` | `B79AC84F00F483A3FE9ADD4D51B3C99EA0A8B1879F87F7D1BC56D475ED03271B` | `B79AC84F00F483A3FE9ADD4D51B3C99EA0A8B1879F87F7D1BC56D475ED03271B` | equal |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | `77E3FA151809B6DC3EE811C6D9631043CA1C3DE1B6B9A6A4A752E4F295A16507` | `77E3FA151809B6DC3EE811C6D9631043CA1C3DE1B6B9A6A4A752E4F295A16507` | equal |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1` | `8B1F10667961F6A1DAA40D30049430DD5505F8A36ACBC7FD397E67987BD4D901` | `8B1F10667961F6A1DAA40D30049430DD5505F8A36ACBC7FD397E67987BD4D901` | equal |
| `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1` | `5157384270A90D3AA1CFC4803E555941FAC654DF0F5447981C9C95C6EEAB93A0` | `5157384270A90D3AA1CFC4803E555941FAC654DF0F5447981C9C95C6EEAB93A0` | equal |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | `91398F084637930422A8A28495B54B77860710FCD2A5D9F938A730EA14B3D95A` | `91398F084637930422A8A28495B54B77860710FCD2A5D9F938A730EA14B3D95A` | equal |

## Porcelain after the calls

```
 M docs/features/active/codex-gates-4-5-lack-epic-scope-707/evidence/other/commits.md
?? docs/features/active/codex-gates-4-5-lack-epic-scope-707/evidence/qa-gates/final-coverage-delta.md
?? docs/features/active/codex-gates-4-5-lack-epic-scope-707/evidence/qa-gates/final-pester-coverage.md
?? docs/features/active/codex-gates-4-5-lack-epic-scope-707/evidence/qa-gates/final-poshqc-analyze.md
?? docs/features/active/codex-gates-4-5-lack-epic-scope-707/evidence/qa-gates/final-poshqc-format.md
?? docs/features/active/codex-gates-4-5-lack-epic-scope-707/evidence/qa-gates/final-preloop-state.md
?? docs/features/active/codex-gates-4-5-lack-epic-scope-707/evidence/qa-gates/final-pytest-full.md
?? docs/features/active/codex-gates-4-5-lack-epic-scope-707/evidence/qa-gates/final-pytest-guards.md
?? docs/features/active/codex-gates-4-5-lack-epic-scope-707/evidence/qa-gates/final-python-scope.md
```
