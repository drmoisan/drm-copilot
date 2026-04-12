[CmdletBinding()]
param(
    [Parameter()]
    [string] $WorkspaceRoot = ".",

    [Parameter()]
    [string[]] $ScanFolders,

    [Parameter()]
    [switch] $DisableKoverageCopy,

    [Parameter()]
    [string] $KoverageOutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Keep the local entrypoint and the packaged extension wrapper identical so both
# surfaces execute the same bundled PoshQC suite.
$poshQcModulePath = Join-Path -Path $PSScriptRoot -ChildPath "..\powershell\PoshQC\PoshQC.psd1"
Import-Module $poshQcModulePath -Force

Invoke-PoshQCSuite -Root $WorkspaceRoot -ScanFolders $ScanFolders -DisableKoverageCopy:$DisableKoverageCopy -KoverageOutputPath $KoverageOutputPath
