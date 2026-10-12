<#
.SYNOPSIS
    Test-only entry point for the Exit-SubagentStopBlock exit route (issue #897).

.DESCRIPTION
    This script is a test-only entry point. It dot-sources the SubagentStop envelope helper
    (.claude/hooks/subagentstop-envelope.ps1) and calls Exit-SubagentStopBlock with the supplied
    message, so a Pester test can invoke it through the call operator (&), capture stderr through
    [Console]::SetError, and read the exit code from $LASTEXITCODE without spawning a process.
    It is not a registered hook and has no production caller.

.PARAMETER Message
    The block reason passed through to Exit-SubagentStopBlock.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $Message
)

. (Join-Path -Path $PSScriptRoot -ChildPath '..' -AdditionalChildPath '..', '..', '.claude', 'hooks', 'subagentstop-envelope.ps1')
Exit-SubagentStopBlock -Message $Message
