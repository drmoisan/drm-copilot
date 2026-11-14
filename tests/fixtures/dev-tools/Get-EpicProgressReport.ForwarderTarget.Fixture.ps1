<#
.SYNOPSIS
    Committed stub target for the scripts/dev-tools/Get-EpicProgressReport.ps1 forwarder suite (issue #1093).

.DESCRIPTION
    The forwarder suite reaches this file through a Join-Path mock, so the forwarder's exit
    handling can be exercised without git, gh, cswap, or a file write. No file is created at
    test time.

.PARAMETER Behavior
    Normal writes one line and returns. LeftoverNative runs the current PowerShell executable
    with a command that exits 128, then writes one line and returns, leaving a failed native
    exit code behind a successful run. Exit3 runs 'exit 3'.

.PARAMETER Count
    Validated to 1 through 10, so a value outside the range is a parameter-binding failure.
#>
[CmdletBinding()]
param(
    [ValidateSet('Normal', 'LeftoverNative', 'Exit3')]
    [string] $Behavior = 'Normal',

    [ValidateRange(1, 10)]
    [int] $Count = 1
)

switch ($Behavior) {
    'LeftoverNative' {
        $currentExecutable = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
        & $currentExecutable -NoProfile -Command 'exit 128'
        Write-Output "forwarder fixture: $Behavior $Count"
    }
    'Exit3' {
        exit 3
    }
    default {
        Write-Output "forwarder fixture: $Behavior $Count"
    }
}
