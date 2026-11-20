# Final File-Size Check AC-15 (issue #953, P6-T16) - ACCEPTANCE FAILED

Timestamp: 2026-10-16T08-57
Command: export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; $names = @(git diff --name-only origin/main...HEAD) + @(git status --porcelain --untracked-files=all | ForEach-Object { $_.Substring(3) }); $set = @($names | Sort-Object -Unique | Where-Object { (Test-Path -LiteralPath $_ -PathType Leaf) -and -not $_.EndsWith(".md") }); foreach ($p in $set) { (Get-Content -LiteralPath $p).Count }' (script SCRATCH/issue-953-p6-t16.sh, run with sh)
EXIT_CODE: 0
Output Summary: The command ran (exit 0), but the P6-T16 acceptance condition FAILS. The changed-file set (16 non-Markdown files) includes the three required paths (PoshQC.RunSettings.Tests.ps1 163 lines, PoshQC.ModuleCoverage.Tests.ps1 103 lines, scripts/powershell/PoshQC/PoshQC.Testing.psm1 461 lines), but tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1 has 579 lines, above the 500-line limit. The file was already 579 lines on the base commit 5bc97774b8322e57abb94dfac3cd0a000a136c5b: the branch's only edit to it is P3-T6 (git diff --numstat against the base reports 2 added and 2 deleted lines, so its line count is unchanged). The condition is pre-existing, but the plan's P3-T6 edit places the file in the AC-15 changed-file set. P6-T16 stays unchecked and AC-15 is not checked off.

ALL_COUNTS_LE_500: NO
OVER_LIMIT: tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1 579 (base 579; branch delta +2/-2 from P3-T6)

## Changed-file line counts

| Path | Lines |
|---|---|
| .devcontainer/post-create.sh | 324 |
| .github/codex/codex-web-setup.sh | 332 |
| .github/workflows/_poshqc.yml | 90 |
| extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1 | 149 |
| extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1 | 461 |
| extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 | 37 |
| scripts/host-tools.manifest.json | 28 |
| scripts/powershell/PoshQC/PoshQC.psm1 | 149 |
| scripts/powershell/PoshQC/PoshQC.Testing.psm1 | 461 |
| scripts/powershell/PoshQC/settings/pester.runsettings.psd1 | 37 |
| tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 | 291 |
| tests/scripts/host-tools.manifest.Tests.ps1 | 168 |
| tests/scripts/powershell/PoshQC/PoshQC.EntryPoints.Tests.ps1 | 95 |
| tests/scripts/powershell/PoshQC/PoshQC.ModuleCoverage.Tests.ps1 | 103 |
| tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1 | 163 |
| tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1 | 579 (exceeds 500) |
