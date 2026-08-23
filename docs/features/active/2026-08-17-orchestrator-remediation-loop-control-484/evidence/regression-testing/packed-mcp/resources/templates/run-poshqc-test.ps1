[CmdletBinding()]
param(
    [Parameter()]
    [string] $WorkspaceRoot = ".",

    [Parameter()]
    [string[]] $ScanFolders,

    [Parameter()]
    [string] $ScanFoldersJson,

    [Parameter()]
    [switch] $DisableKoverageCopy,

    [Parameter()]
    [string] $KoverageOutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$poshQcModulePath = Join-Path -Path $PSScriptRoot -ChildPath "..\powershell\PoshQC\PoshQC.psd1"
Import-Module $poshQcModulePath -Force

$resolvedScanFolders = $ScanFolders
if (-not [string]::IsNullOrWhiteSpace($ScanFoldersJson)) {
    $resolvedScanFolders = @(
        ConvertFrom-Json -InputObject $ScanFoldersJson
    ) | ForEach-Object { [string] $_ }
}

Invoke-PoshQCTest -Root $WorkspaceRoot -ScanFolders $resolvedScanFolders -DisableKoverageCopy:$DisableKoverageCopy -KoverageOutputPath $KoverageOutputPath
