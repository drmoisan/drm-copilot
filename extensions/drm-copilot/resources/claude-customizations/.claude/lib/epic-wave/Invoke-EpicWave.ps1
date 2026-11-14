<#
.SYNOPSIS
    Prints the epic wave map for a dependency manifest (issue #1129).

.DESCRIPTION
    Thin command entry over EpicWave.psm1. Reads the JSON manifest at -ManifestPath,
    writes the compressed JSON wave map to stdout, and writes any error message to
    stderr. Exit codes: 0 success, 1 invalid manifest (cycle, self-loop, or
    unresolved reference), 2 usage error or unreadable input.

.PARAMETER ManifestPath
    Path to a JSON file holding { "<feature>": ["<dependency>", ...] }.

.EXAMPLE
    pwsh -NoProfile -File .claude/lib/epic-wave/Invoke-EpicWave.ps1 -ManifestPath manifest.json
#>
[CmdletBinding()]
param(
    [string] $ManifestPath
)

Import-Module (Join-Path $PSScriptRoot 'EpicWave.psm1') -Force -ErrorAction Stop
$result = Invoke-EpicWaveCommand -ManifestPath $ManifestPath
if ($result.Stdout) { Write-Output $result.Stdout }
if ($result.Stderr) { [Console]::Error.WriteLine($result.Stderr) }
exit $result.ExitCode
