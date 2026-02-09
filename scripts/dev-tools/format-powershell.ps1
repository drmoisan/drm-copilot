#!/usr/bin/env pwsh
<#[
.SYNOPSIS
Formats PowerShell files in the repo.

.DESCRIPTION
This is a thin entrypoint wrapper used by repo tooling/docs.
It imports the local PoshQC module and runs Invoke-PoshQCFormat across the repo root.

.EXITCODES
0 on success; non-zero on failure.
#>

$ErrorActionPreference = "Stop"

function Exit-WithCode {
    [CmdletBinding()]
    param(
        [int] $ExitCode,
        [scriptblock] $ExitAction = { param([int] $ExitCode) exit $ExitCode }
    )

    & $ExitAction $ExitCode
}

function Invoke-FormatPowerShell {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [bool] $ExitOnError = $true
    )

    try {
        Import-Module ./scripts/powershell/PoshQC -Force
        Invoke-PoshQCFormat -Root .
        return $true
    }
    catch {
        Write-Error $_
        if ($ExitOnError) {
            Exit-WithCode -ExitCode 1
        }
        return $false
    }
}

if ($MyInvocation.InvocationName -eq '.') {
    return
}

if ($env:POSHQC_SKIP_SCRIPT_EXECUTION) {
    return
}

Invoke-FormatPowerShell
