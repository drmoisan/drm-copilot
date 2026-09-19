<#
.SYNOPSIS
    Shared helpers for the worktree-resolution matrix suites (issue #673).

.DESCRIPTION
    Dot-sourced by the pr-author and model-routing matrix suites. Supplies the fixture
    path resolver, the in-process working-directory wrapper every matrix row runs inside,
    and a thin wrapper over the target-result constructor.

    This file carries no Import-Module statement and calls New-WorktreeResolutionTargetResult
    directly. That resolves because the file is dot-sourced rather than imported, so it runs
    in the importing suite's session state, where the suite's own module imports have already
    placed the constructor. Adding an import here would duplicate that binding.

.NOTES
    No function here creates, writes, or deletes a file, reads a wall clock, spawns a
    process, or touches the network. The working-directory wrapper is the only code in the
    matrix suites that changes a directory, and it restores both location values in a
    finally block so a failing row cannot leak the change into the next one.
#>

function Get-WorktreeResolutionFixturePath {
    <#
    .SYNOPSIS
        Return the absolute, forward-slashed path of a committed fixture location.
    .DESCRIPTION
        Resolves three levels up from this file (claude-hooks -> scripts -> tests -> repo
        root) and appends the fixture subtree, so the result is absolute without any host
        path being written into a suite.
    .PARAMETER RelativePath
        The path below tests/fixtures/worktree-resolution/, such as a root name or a file
        beneath one.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [string] $RelativePath
    )

    $repoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
    $combined = Join-Path $repoRoot (Join-Path 'tests/fixtures/worktree-resolution' $RelativePath)
    return $combined.Replace([string][char]92, '/')
}

function Invoke-WorktreeResolutionFixtureCall {
    <#
    .SYNOPSIS
        Run a script block with the process directory set to a fixture root.
    .DESCRIPTION
        Sets both the PowerShell location and the .NET current directory, because the two
        are independent: the gate's Test-Path calls follow the PowerShell location while
        [System.IO.File]::ReadAllBytes follows the .NET one, and a row that set only the
        first would read body bytes from the wrong directory. Both are restored in a
        finally block whether the block succeeds or throws.
    .PARAMETER WorkingDirectory
        The absolute fixture directory the block runs inside.
    .PARAMETER ScriptBlock
        The block to invoke. Its output is returned unchanged.
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter(Mandatory = $true)] [string] $WorkingDirectory,
        [Parameter(Mandatory = $true)] [scriptblock] $ScriptBlock
    )

    $previousLocation = (Get-Location).Path
    $previousCurrentDirectory = [System.Environment]::CurrentDirectory
    try {
        Set-Location -LiteralPath $WorkingDirectory
        [System.Environment]::CurrentDirectory = $WorkingDirectory
        return (& $ScriptBlock)
    }
    finally {
        Set-Location -LiteralPath $previousLocation
        [System.Environment]::CurrentDirectory = $previousCurrentDirectory
    }
}

function New-WorktreeResolutionFixtureTarget {
    <#
    .SYNOPSIS
        Build a target result for a matrix row that injects one through a hook seam.
    .DESCRIPTION
        A thin wrapper over New-WorktreeResolutionTargetResult, and deliberately thin: it
        exists only so a row states the status and root it is exercising without repeating
        the constructor's mandatory SessionRoot and Detail arguments. Every field invariant,
        including the reason code, is still set by the constructor.
    .PARAMETER Status
        One of the four target states.
    .PARAMETER WorktreeRoot
        The resolved root, required for the two resolved states and ignored otherwise.
    .PARAMETER Candidate
        Optional. The candidate roots an ambiguous result carries.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory wrapper over the shipped target-result constructor; it changes no system state.')]
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('SessionRoot', 'OtherWorktree', 'NoTarget', 'Ambiguous')]
        [string] $Status,
        [string] $WorktreeRoot,
        [string[]] $Candidate = @()
    )

    # SessionRoot is supplied from the resolved root rather than from a live location read,
    # so the wrapper stays independent of the process directory. For an unresolved status
    # the constructor forbids an empty SessionRoot, so a synthetic literal stands in.
    $sessionRoot = if ([string]::IsNullOrWhiteSpace($WorktreeRoot)) { '/synthetic-worktrees/fixture-session' } else { $WorktreeRoot }
    return (New-WorktreeResolutionTargetResult -Status $Status -SessionRoot $sessionRoot `
            -WorktreeRoot $WorktreeRoot -Candidate $Candidate `
            -Detail ('modelled {0} target for a worktree-resolution matrix row' -f $Status))
}
