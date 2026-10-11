<#
.SYNOPSIS
    Shared SubagentStop envelope reader and exit-2 block helper (issue #897, epic subagentstop-envelope).

.DESCRIPTION
    Dot-sourced by the SubagentStop validators under .claude/hooks. It is not registered as a hook in
    either settings.json copy. It imports nothing (no Import-Module, no using module, no dot-source),
    reads no environment variable, and writes nothing to the success or warning streams; the only
    stream it ever writes is standard error, from Exit-SubagentStopBlock.

    The governing contract is the section "## Authoritative Helper Contract" of
    docs/features/active/subagentstop-envelope-core-897/spec.md (issue #897). Where this file and any
    other document differ, that section governs.

.NOTES
    PowerShell 7.5 or later (ConvertFrom-Json -DateKind). Byte-identical bundled mirror at
    extensions/drm-copilot/resources/claude-customizations/.claude/hooks/subagentstop-envelope.ps1.
#>

function Exit-SubagentStopBlock {
    <#
    .SYNOPSIS
        Blocks a SubagentStop by writing the reason to standard error and exiting with code 2.
    .DESCRIPTION
        Exit code 2 is the only exit code that blocks a SubagentStop; the stderr text is delivered to the
        subagent as its next instruction. A null or empty Message fails parameter binding before the
        body runs, so no exit occurs in that case.
    .PARAMETER Message
        The block reason written to standard error.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Message
    )

    [Console]::Error.WriteLine($Message)
    exit 2
}
