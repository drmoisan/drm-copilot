Timestamp: 2026-08-12T09:39:33.5940276-04:00
Command: mcp__drm-copilot__run_poshqc_format with the three B8 production owners and three B8 test owners; mcp__drm-copilot__run_poshqc_analyze with the same owners; pwsh -NoProfile -Command "Import-Module './scripts/powershell/PoshQC/PoshQC.psd1' -Force; Invoke-PoshQCTest -Root (Get-Location).Path -ScanFolders @('tests/scripts/codex-hooks/powershell-attribution-batch-8.Tests.ps1','tests/scripts/codex-hooks/parallel-child-worktree-launcher.Tests.ps1','tests/scripts/codex-hooks/parallel-child-resume-live-truth.Tests.ps1') -SettingsPath './scripts/powershell/PoshQC/settings/pester.runsettings.psd1' -DisableKoverageCopy"
EXIT_CODE: 0
Output Summary: Formatting passed, PSScriptAnalyzer passed, and Pester discovered and passed 35 tests with 0 failures and 0 skips. Per-owner coverage passed the >=90% threshold: launch-parallel-child-batch.ps1 217/241 (90.0415%), parallel-child-launch-contract.ps1 104/108 (96.2963%), resume-parallel-child.ps1 238/264 (90.1515%). Coverage artifact SHA-256: C34EAEFCE60CC582079C0F89DB4B25815C74B4F7332C8B3B52E246195954CD10.

Pre/post line-coverage deltas:
- launch-parallel-child-batch.ps1: 62/240 (25.8333%) -> 217/241 (90.0415%); +155 covered lines.
- parallel-child-launch-contract.ps1: focused red 94/108 (87.0370%; authoritative full-suite pre-value 96/108) -> 104/108 (96.2963%); +10 focused-run covered lines.
- resume-parallel-child.ps1: 127/264 (48.1061%) -> 238/264 (90.1515%); +111 covered lines.

Line-count gate:
- .codex/scripts/launch-parallel-child-batch.ps1: 493
- .codex/scripts/parallel-child-launch-contract.ps1: 233
- .codex/scripts/resume-parallel-child.ps1: 475
- tests/scripts/codex-hooks/powershell-attribution-batch-8.Tests.ps1: 189
- tests/scripts/codex-hooks/parallel-child-worktree-launcher.Tests.ps1: 497
- tests/scripts/codex-hooks/parallel-child-resume-live-truth.Tests.ps1: 448

Production seam: Complete-CodexParallelChildProcess accepts a narrowly scoped WriteText callback with the existing System.IO.File.WriteAllText behavior as its default. Expected-red proof is recorded in evidence/regression-testing/powershell-correction-batch-8-write-text-red.2026-08-12T09-20.md.
