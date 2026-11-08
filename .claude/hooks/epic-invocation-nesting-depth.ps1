<#
.SYNOPSIS
    Nesting-depth preflight helper for enforce-epic-invocation-origin.ps1 (issue #1138).

.DESCRIPTION
    Dot-sourced by .claude/hooks/enforce-epic-invocation-origin.ps1 inside the guarded
    dot-source pattern. It denies a delegation into the epic or parallel chain early when
    the configured subagent spawn-depth limit is below the three levels the chain needs:
    the coordinator runs at depth 1, each per-feature orchestrator at depth 2, and the
    specialists at depth 3.

    The helper sees only the configured value of CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH,
    never the runtime depth. It cannot detect a run that was started inside a subagent,
    so the Agent-tool preflight in the agent files stays the primary control.

    Decision rules:
      - The check applies to a main-thread delegation to epic-planner, epic-orchestrator,
        parallel-planner, or parallel-orchestrator, and to one of those four calling
        orchestrator. Every other delegation is unaffected.
      - An unset, empty, or whitespace-only value allows (the runtime default is 3).
      - A trimmed invariant-culture integer of 3 or more allows.
      - An integer below 3 denies with NESTING_DEPTH_INSUFFICIENT and the remedies.
      - Any other set value denies (fail closed) with a parse message.

.NOTES
    Compatible with PowerShell 7+. Read-only; the environment is read only through
    Get-SubagentSpawnDepthSetting so tests can replace it with a mock.
#>

function Get-SubagentSpawnDepthSetting {
    <#
    .SYNOPSIS
        Returns the raw configured CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH value.
    .DESCRIPTION
        The only reader of the variable in this helper. It returns the configured value,
        never the runtime depth of the calling agent.
    .OUTPUTS
        System.String or $null when the variable is unset.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param()

    return [Environment]::GetEnvironmentVariable('CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH')
}

function Test-EpicInvocationNestingDepthApplies {
    <#
    .SYNOPSIS
        Reports whether the nesting-depth check applies to a delegation.
    .PARAMETER Target
        The delegation target subagent_type.
    .PARAMETER Caller
        The calling agent_type, or $null for a main-thread delegation.
    .OUTPUTS
        System.Boolean
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'The name is fixed by the issue #1138 plan contract; Applies is a verb phrase, not a plural noun.')]
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        [string] $Target,

        [AllowNull()]
        [AllowEmptyString()]
        [string] $Caller
    )

    $coordinatorTypes = @('epic-planner', 'epic-orchestrator', 'parallel-planner', 'parallel-orchestrator')
    if ([string]::IsNullOrWhiteSpace($Caller)) {
        return ($coordinatorTypes -contains $Target)
    }
    return (($coordinatorTypes -contains $Caller) -and $Target -eq 'orchestrator')
}

function Get-EpicInvocationNestingDepthDenyReason {
    <#
    .SYNOPSIS
        Returns the NESTING_DEPTH_INSUFFICIENT deny reason, or $null when the delegation
        may proceed.
    .PARAMETER Target
        The delegation target subagent_type.
    .PARAMETER Caller
        The calling agent_type, or $null for a main-thread delegation.
    .OUTPUTS
        System.String or $null
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        [string] $Target,

        [AllowNull()]
        [AllowEmptyString()]
        [string] $Caller
    )

    if (-not (Test-EpicInvocationNestingDepthApplies -Target $Target -Caller $Caller)) {
        return $null
    }

    $rawValue = Get-SubagentSpawnDepthSetting
    if ([string]::IsNullOrWhiteSpace($rawValue)) {
        return $null
    }

    $remedy = 'Remedy: raise or unset CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH (unset means the default of 3), or use the main-session fallback described under ## Nesting Depth of the coordinating skill, in which the main session launches each per-feature Agent(orchestrator) itself.'
    $trimmedValue = $rawValue.Trim()
    $parsedValue = 0
    $isInteger = [int]::TryParse(
        $trimmedValue,
        [System.Globalization.NumberStyles]::Integer,
        [System.Globalization.CultureInfo]::InvariantCulture,
        [ref] $parsedValue)
    if (-not $isInteger) {
        return "NESTING_DEPTH_INSUFFICIENT: CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH value '$trimmedValue' is not an integer, so the gate cannot confirm the three nesting levels Agent($Target) needs and fails closed. $remedy"
    }
    if ($parsedValue -ge 3) {
        return $null
    }
    return "NESTING_DEPTH_INSUFFICIENT: CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH is $parsedValue, below the three nesting levels Agent($Target) needs (coordinator at depth 1, per-feature orchestrator at depth 2, specialists at depth 3); at a lower limit the per-feature orchestrators run without the Agent tool. $remedy"
}
