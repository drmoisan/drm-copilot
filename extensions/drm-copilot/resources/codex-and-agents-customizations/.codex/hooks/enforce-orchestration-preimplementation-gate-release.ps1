<#
.SYNOPSIS
    Release-commit allowance leg of the preimplementation gate (issue #1201).

.DESCRIPTION
    Dot-sourced, guarded, by .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 and
    .codex/hooks/enforce-orchestration-preimplementation-gate.ps1. The gate calls
    Get-OrchestrationReleaseAllowanceResult in its single-feature branch after every other leg
    and immediately before the final deny, so the leg can only turn a deny into an allow, and
    appends its DenySuffix as the last term of the final deny text.

    The leg admits a checkpoint-free git add and git commit of the paths that the destination
    repository lists in .claude/release-commit-allowance.json beneath the target worktree root R,
    on a branch that matches one of its patterns. Push-down never writes that file, and this
    repository commits none, so the leg is inert until a destination opts in.

    Evaluation order (the first failure decides and exactly one code is reported):
      1 a blank command or apply_patch text declines (no suffix, no I/O);
      2 a line with no git add or git commit segment declines (no suffix, no I/O);
      3 R comes from the gate's checkpoint read path; no root declines (no suffix);
      4 the allowance file beneath R is read; an absent file declines (no suffix, no further I/O),
        and a read failure reports RELEASE_ALLOWANCE_CONFIG_INVALID;
      5 the file is parsed, and each allowed_paths entry is probed with the container seam; a
        failure reports RELEASE_ALLOWANCE_CONFIG_INVALID;
      6 to 10 Get-ReleaseAllowanceCommandDecision (hook-release-allowance-context.ps1).
    A denial adds the suffix ' Release allowance not applied: <CODE>: <detail>'.

.NOTES
    PowerShell 7+. Never throws: an unexpected error answers Allowed $false with an empty
    DenySuffix and a Write-Debug record carrying PREIMPL_RELEASE_LEG_ERROR. Only the two seams below
    touch the file system; the HEAD branch and the staged index are read through
    Get-EpicScopeWorktreeHeadBranch (EpicScopeResolution.psm1 on Claude, the epic-resolution sibling
    on Codex) and Get-OrchestrationGateStagedIndex (cleanup sibling). The checkpoint suffix comes from
    $script:CheckpointPaths (gate file) and the root derivation from
    Get-OrchestrationGateBookkeepingWorktreeRoot (bookkeeping sibling). Byte-identical at
    .claude/hooks, .codex/hooks, and both bundle mirrors under extensions/drm-copilot/resources/.
    Script-scope names use the prefix ReleaseAllowance. This hook file starts no interpreter process.
    A policy-level control, not a security control.
#>

try { . (Join-Path $PSScriptRoot 'hook-release-allowance-context.ps1') } catch { Add-HookDependencyFailure -Name 'hook-release-allowance-context.ps1' -ErrorRecord $_ }

$script:ReleaseAllowanceFileRelativePath = '.claude/release-commit-allowance.json'

function Get-OrchestrationGateReleaseAllowanceConfigText {
    <#
    .SYNOPSIS
        Return the text of .claude/release-commit-allowance.json beneath a worktree root, or $null (seam).
    .DESCRIPTION
        Returns $null only when no item exists at the path. Throws when the item is not a file or
        the read fails.
    .PARAMETER WorktreeRoot
        The target worktree root R.
    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][string] $WorktreeRoot)

    $path = Join-Path -Path $WorktreeRoot -ChildPath $script:ReleaseAllowanceFileRelativePath
    if (-not (Test-Path -LiteralPath $path)) { return $null }
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "The release-commit allowance path is not a file: $path" }
    return [string](Get-Content -LiteralPath $path -Raw -ErrorAction Stop)
}

function Test-OrchestrationGateReleaseAllowancePathIsContainer {
    <#
    .SYNOPSIS
        Report whether an allowed_paths entry names a directory beneath a worktree root (seam).
    .PARAMETER WorktreeRoot
        The target worktree root R.
    .PARAMETER RelativePath
        The allowed_paths entry.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory)][string] $WorktreeRoot, [Parameter(Mandatory)][string] $RelativePath)

    return [bool](Test-Path -LiteralPath (Join-Path -Path $WorktreeRoot -ChildPath $RelativePath) -PathType Container)
}

function Get-OrchestrationReleaseAllowanceNotAppliedResult {
    <#
    .SYNOPSIS
        Return a declined leg result whose DenySuffix names the code and the detail.
    .PARAMETER Code
        The RELEASE_ALLOWANCE_* code.
    .PARAMETER Detail
        The detail of the failure.
    .OUTPUTS
        System.Management.Automation.PSCustomObject
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory)][string] $Code, [Parameter(Mandatory)][string] $Detail)

    return [pscustomobject]@{ Allowed = $false; DenySuffix = " Release allowance not applied: ${Code}: $Detail" }
}

function Get-OrchestrationReleaseAllowanceResult {
    <#
    .SYNOPSIS
        Decide whether a command that the gate would deny is an allowed release commit (issue #1201).
    .DESCRIPTION
        Applies steps 1 to 10 of the file header. Returns Allowed and DenySuffix.
    .PARAMETER Command
        The Bash command text, or the Codex apply_patch text.
    .PARAMETER CheckpointPath
        The Path of the gate's checkpoint read, or empty when the checkpoint text was injected.
    .PARAMETER ConfigReader
        Called with R; default Get-OrchestrationGateReleaseAllowanceConfigText.
    .PARAMETER ContainerProbe
        Called with R and an allowed_paths entry; default Test-OrchestrationGateReleaseAllowancePathIsContainer.
    .PARAMETER BranchReader
        Called with R; default Get-EpicScopeWorktreeHeadBranch.
    .PARAMETER StagedIndexReader
        Called with R; default Get-OrchestrationGateStagedIndex.
    .OUTPUTS
        System.Management.Automation.PSCustomObject
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowNull()][AllowEmptyString()][string] $Command,
        [AllowNull()][AllowEmptyString()][string] $CheckpointPath,
        [scriptblock] $ConfigReader = { param([string] $WorktreeRoot) Get-OrchestrationGateReleaseAllowanceConfigText -WorktreeRoot $WorktreeRoot },
        [scriptblock] $ContainerProbe = { param([string] $WorktreeRoot, [string] $RelativePath) Test-OrchestrationGateReleaseAllowancePathIsContainer -WorktreeRoot $WorktreeRoot -RelativePath $RelativePath },
        [scriptblock] $BranchReader = { param([string] $WorktreeRoot) Get-EpicScopeWorktreeHeadBranch -WorktreeRoot $WorktreeRoot },
        [scriptblock] $StagedIndexReader = { param([string] $WorktreeRoot) Get-OrchestrationGateStagedIndex -WorktreeRoot $WorktreeRoot }
    )

    $declined = [pscustomobject]@{ Allowed = $false; DenySuffix = '' }
    try {
        if ([string]::IsNullOrWhiteSpace($Command) -or $Command.TrimStart().StartsWith('*** Begin Patch', [System.StringComparison]::Ordinal)) { return $declined }
        if (-not (Test-ReleaseAllowanceCommandRelevant -Command $Command)) { return $declined }
        $root = Get-OrchestrationGateBookkeepingWorktreeRoot -CheckpointPath $CheckpointPath -CheckpointSuffix ([string]@($script:CheckpointPaths)[0])
        if ($null -eq $root) { return $declined }
        try {
            $text = & $ConfigReader $root
        } catch {
            return (Get-OrchestrationReleaseAllowanceNotAppliedResult 'RELEASE_ALLOWANCE_CONFIG_INVALID' 'the file could not be read')
        }
        if ($null -eq $text) { return $declined }
        $config = ConvertFrom-ReleaseAllowanceConfig -Text ([string]$text)
        if (-not $config.Valid) { return (Get-OrchestrationReleaseAllowanceNotAppliedResult 'RELEASE_ALLOWANCE_CONFIG_INVALID' $config.Detail) }
        foreach ($allowance in @($config.Allowances)) {
            foreach ($entry in @($allowance.AllowedPaths)) {
                try {
                    $isContainer = [bool](& $ContainerProbe $root $entry)
                } catch {
                    return (Get-OrchestrationReleaseAllowanceNotAppliedResult 'RELEASE_ALLOWANCE_CONFIG_INVALID' "allowed_paths entry '$entry' could not be checked")
                }
                if ($isContainer) { return (Get-OrchestrationReleaseAllowanceNotAppliedResult 'RELEASE_ALLOWANCE_CONFIG_INVALID' "allowed_paths entry '$entry' is a directory") }
            }
        }
        $decision = Get-ReleaseAllowanceCommandDecision -Command $Command -WorktreeRoot $root -Branch $BranchReader -Allowances @($config.Allowances) -StagedReader $StagedIndexReader
        if ($decision.Allowed) { return [pscustomobject]@{ Allowed = $true; DenySuffix = '' } }
        return (Get-OrchestrationReleaseAllowanceNotAppliedResult $decision.Code $decision.Detail)
    } catch {
        Write-Debug "PREIMPL_RELEASE_LEG_ERROR: $($_.Exception.Message)"
        return $declined
    }
}
