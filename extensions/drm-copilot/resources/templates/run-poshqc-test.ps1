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

$poshQcModulePath = Join-Path -Path $PSScriptRoot -ChildPath "..\powershell\PoshQC\PoshQC.psd1"
Import-Module $poshQcModulePath -Force

Invoke-PoshQCTest -Root $WorkspaceRoot -ScanFolders $ScanFolders -DisableKoverageCopy:$DisableKoverageCopy -KoverageOutputPath $KoverageOutputPath
