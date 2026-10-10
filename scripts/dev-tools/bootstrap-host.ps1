#!/usr/bin/env pwsh
[CmdletBinding()]
param(
    [Parameter()]
    [switch]$Apply,

    [Parameter()]
    [switch]$EnableAutoResumeAfterReboot,

    [Parameter()]
    [string]$WorkspaceRoot,

    [Parameter()]
    [string]$RepoRoot,

    [Parameter()]
    [switch]$SkipProjectPoetryInstall
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'HostBootstrap.psm1')

if ($MyInvocation.InvocationName -ne '.') {
    try {
        Invoke-BootstrapHost -Apply:$Apply -EnableAutoResumeAfterReboot:$EnableAutoResumeAfterReboot -WorkspaceRoot $WorkspaceRoot -RepoRoot $RepoRoot -SkipProjectPoetryInstall:$SkipProjectPoetryInstall
    }
    catch {
        $global:LASTEXITCODE = 1
        throw
    }

    exit 0
}
