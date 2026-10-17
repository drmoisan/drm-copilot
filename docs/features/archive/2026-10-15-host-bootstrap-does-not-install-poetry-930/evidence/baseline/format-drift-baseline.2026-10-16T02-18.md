# Read-only format-drift baseline (P0-T10)

Timestamp: 2026-10-16T02-18

Command: pwsh -NoProfile -NonInteractive -Command '$ErrorActionPreference = "Stop"; foreach ($f in @("scripts/dev-tools/HostBootstrap.psm1","tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1")) { $o = Get-Content -LiteralPath $f -Raw; $fm = Invoke-Formatter -ScriptDefinition $o -Settings "scripts/powershell/PoshQC/settings/pssa.settings.psd1"; $d = ($o.TrimEnd([char]13,[char]10)) -cne ($fm.TrimEnd([char]13,[char]10)); Write-Output ("FORMAT-DRIFT {0} DRIFT={1}" -f $f, $d) }; exit 0'

EXIT_CODE: 0

Output Summary:
- FORMAT-DRIFT scripts/dev-tools/HostBootstrap.psm1 DRIFT=False
- FORMAT-DRIFT tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 DRIFT=False
- `git status --porcelain` listed neither file (only `M` on the plan file, `?? SCRATCH/`, and untracked evidence under the feature folder).
