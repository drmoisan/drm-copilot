[CmdletBinding()]
param(
    [Parameter()]
    [string] $WorkspaceRoot = ".",

    [Parameter()]
    [string[]] $ScanFolders
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$poshQcModulePath = Join-Path -Path $PSScriptRoot -ChildPath "..\powershell\PoshQC\PoshQC.psd1"
Import-Module $poshQcModulePath -Force

Invoke-PoshQCFormat -Root $WorkspaceRoot -ScanFolders $ScanFolders
