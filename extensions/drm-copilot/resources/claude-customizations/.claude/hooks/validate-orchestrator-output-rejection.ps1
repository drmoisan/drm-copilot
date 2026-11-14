<#
.SYNOPSIS
    Parallel mutation rejection helpers for validate-orchestrator-output.ps1 (issue #1012).

.DESCRIPTION
    Dot-sourced by validate-orchestrator-output.ps1. A parallel skill that rejects a mutation before
    any run checkpoint exists stops without writing state and ends its final output with the line
    PARALLEL_MUTATION_REJECTED: <code>. These helpers parse that signal, scan the live worktrees for
    parallel checkpoint text that would contradict the claim that no state was written, decide
    whether the unresolved parallel stop may be allowed, and compose the hint appended to the block
    message when it may not.

    The signal grammar, the closed code set, and the hook behavior are defined once in the section
    `## Mutation Rejection Signal (issue #1012)` of .claude/rules/parallel-orchestration.md.

    Imports no module, invokes no Python, and starts no process. Relies on
    Find-WorktreeRunIdentitySignal, Get-WorktreeItemLiveRoot, Get-WorktreeRunCheckpointText, and
    Get-WorktreeRunCheckpointPath, which the hook imports before it dot-sources this file. Reads no
    file except through Get-WorktreeRunCheckpointText.
#>

# The closed rejection code set, in rule order. It mirrors the table of
# `## Mutation Rejection Signal (issue #1012)` in .claude/rules/parallel-orchestration.md, which owns
# the set; a Pester parity row pins this array to that table.
$script:ParallelMutationRejectionCodes = @('kickoff_artifact_missing', 'run_not_started', 'items_in_flight', 'unknown_item')
$script:ParallelMutationRejectionPrefix = 'PARALLEL_MUTATION_REJECTED:'
$script:ParallelMutationRejectionPattern = '^PARALLEL_MUTATION_REJECTED: (?<code>[a-z_]+)$'
$script:ParallelMutationRejectionHeading = '## Mutation Rejection Signal (issue #1012)'
$script:ParallelMutationRejectionArtifactType = 'parallel-orchestrator-state'

function Get-ParallelMutationRejectionCode {
    <#
    .SYNOPSIS
        Return the code of a valid final-line rejection signal, or $null.
    .DESCRIPTION
        Pure. Only the last non-blank line of the output is considered, after trailing whitespace
        (including a carriage return) is trimmed. The line must match
        ^PARALLEL_MUTATION_REJECTED: (?<code>[a-z_]+)$ case-sensitively, and the code must be an
        ordinal member of the closed code set. Any other form, including formatting or trailing
        text, returns $null.
    .PARAMETER AgentOutput
        The agent's final output text.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyString()] [string] $AgentOutput
    )

    $trimmed = ([string]$AgentOutput).TrimEnd()
    if ($trimmed.Length -eq 0) { return $null }
    $lastLine = $trimmed.Substring($trimmed.LastIndexOf("`n") + 1)
    $match = [regex]::Match($lastLine, $script:ParallelMutationRejectionPattern)
    if (-not $match.Success) { return $null }
    $code = $match.Groups['code'].Value
    foreach ($member in $script:ParallelMutationRejectionCodes) {
        if ([string]::Equals($member, $code, [System.StringComparison]::Ordinal)) { return $member }
    }
    return $null
}

function Test-ParallelRunStateAbsent {
    <#
    .SYNOPSIS
        Return $true when no live worktree holds parallel checkpoint text that contradicts a no-state stop.
    .DESCRIPTION
        For every live root, the text at the canonical parallel checkpoint path must be null or blank,
        or parse as a JSON object with route_id 'parallel' and a non-blank string parallel_slug that
        differs (ordinally) from the parallel_slug: value the output names, when it names one. Any
        other non-blank text (unparseable, a non-object root, off-route, or without a slug) and a
        checkpoint recording the named slug return $false.
    .PARAMETER AgentOutput
        The agent's final output text, scanned for a parallel_slug: literal.
    .PARAMETER SessionRoot
        The calling process's path, used only to find the repository.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyString()] [string] $AgentOutput,
        [Parameter(Mandatory = $true)] [string] $SessionRoot
    )

    $namedSlug = (Find-WorktreeRunIdentitySignal -Text ([string]$AgentOutput)).ParallelSlug
    # The seam returns its array as one object, so it is assigned before it is iterated.
    $liveRoots = Get-WorktreeItemLiveRoot -SessionRoot $SessionRoot
    foreach ($root in $liveRoots) {
        if ([string]::IsNullOrWhiteSpace($root)) { continue }
        $text = Get-WorktreeRunCheckpointText -Path (Get-WorktreeRunCheckpointPath -Kind 'parallel' -WorktreeRoot $root)
        if ([string]::IsNullOrWhiteSpace($text)) { continue }
        try { $parsed = ConvertFrom-Json -InputObject $text -NoEnumerate -ErrorAction Stop } catch { return $false }
        if ($parsed -isnot [System.Management.Automation.PSCustomObject]) { return $false }
        $names = @($parsed.PSObject.Properties.Name)
        if (-not ($names -ccontains 'route_id') -or ([string]$parsed.route_id -cne 'parallel')) { return $false }
        if (-not ($names -ccontains 'parallel_slug')) { return $false }
        $slug = $parsed.parallel_slug
        if ($slug -isnot [string] -or [string]::IsNullOrWhiteSpace($slug)) { return $false }
        if (-not [string]::IsNullOrWhiteSpace($namedSlug) -and ($slug -ceq $namedSlug)) { return $false }
    }
    return $true
}

function Get-OrchestratorOutputRejectionDecision {
    <#
    .SYNOPSIS
        Return the allow decision for an unresolved parallel stop that carries a valid rejection signal, or $null.
    .DESCRIPTION
        Returns @{ Ok = $true; Message = $null } only when every gate holds: the artifact type is
        parallel-orchestrator-state, the resolution status is NoTarget, the final line is a valid
        rejection signal, and the state-absence scan passes. Otherwise returns $null, and the caller
        applies its existing block.
    .PARAMETER ArtifactType
        The artifact type the hook validates.
    .PARAMETER Resolution
        The unresolved result of Resolve-OrchestratorOutputCheckpointPath.
    .PARAMETER AgentOutput
        The agent's final output text.
    .PARAMETER SessionRoot
        The calling process's path, used only to find the repository.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $ArtifactType,
        [Parameter(Mandatory = $true)] [AllowNull()] [object] $Resolution,
        [Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyString()] [string] $AgentOutput,
        [Parameter(Mandatory = $true)] [string] $SessionRoot
    )

    if ($ArtifactType -cne $script:ParallelMutationRejectionArtifactType) { return $null }
    if ($null -eq $Resolution -or [string]$Resolution.Status -cne 'NoTarget') { return $null }
    if ($null -eq (Get-ParallelMutationRejectionCode -AgentOutput $AgentOutput)) { return $null }
    if (-not (Test-ParallelRunStateAbsent -AgentOutput $AgentOutput -SessionRoot $SessionRoot)) { return $null }
    return @{ Ok = $true; Message = $null }
}

function Get-ParallelMutationRejectionHint {
    <#
    .SYNOPSIS
        Return the text appended to an unresolved block message.
    .DESCRIPTION
        Pure. Returns an empty string unless the artifact type is parallel-orchestrator-state and the
        status is NoTarget. Otherwise returns one newline-prefixed hint line naming the signal form
        and the rule heading and, when the last non-blank line begins with the signal prefix but
        carries no valid code, a second line listing the allowed codes.
    .PARAMETER ArtifactType
        The artifact type the hook validates.
    .PARAMETER Status
        The resolution status of the block.
    .PARAMETER AgentOutput
        The agent's final output text.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $ArtifactType,
        [Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyString()] [string] $Status,
        [Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyString()] [string] $AgentOutput
    )

    if ($ArtifactType -cne $script:ParallelMutationRejectionArtifactType -or $Status -cne 'NoTarget') { return '' }
    $hint = ("`norchestrator hook: a parallel skill that stopped without writing state ends its final output with the line 'PARALLEL_MUTATION_REJECTED: <code>' as the last line, with no formatting; see '{0}' in .claude/rules/parallel-orchestration.md." -f
        $script:ParallelMutationRejectionHeading)
    $trimmed = ([string]$AgentOutput).TrimEnd()
    $lastLine = $trimmed.Substring($trimmed.LastIndexOf("`n") + 1)
    if ($lastLine.StartsWith($script:ParallelMutationRejectionPrefix, [System.StringComparison]::Ordinal) -and
        $null -eq (Get-ParallelMutationRejectionCode -AgentOutput $AgentOutput)) {
        $hint += ("`norchestrator hook: the final line carries the {0} prefix with an invalid code; allowed codes: {1}." -f
            $script:ParallelMutationRejectionPrefix, ($script:ParallelMutationRejectionCodes -join ', '))
    }
    return $hint
}
