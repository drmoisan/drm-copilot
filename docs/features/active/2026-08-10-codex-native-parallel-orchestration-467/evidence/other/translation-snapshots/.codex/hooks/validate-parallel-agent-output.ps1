<#
.SYNOPSIS
    Validates parallel agent output before allowing SubagentStop completion.

.DESCRIPTION
    Applies only to the forced parallel planner and orchestrator personas. The
    hook delegates checkpoint, child, launch, routing, and completion evidence
    validation to the public Python orchestration validator. Invalid output
    requests one continuation. A repeated stop emits continue=false so the hook
    cannot create an unbounded continuation loop.

.NOTES
    Compatible with PowerShell 7+. Validation-only; this hook mutates no state.
#>
[CmdletBinding()]
param()

$script:LoadingCodexParallelAgentOutputHook = $true
try {
    $hasStopParser = $null -ne (Get-Command `
            -Name ConvertFrom-CodexStopJson `
            -CommandType Function `
            -ErrorAction SilentlyContinue)
    $hasContinuationFactory = $null -ne (Get-Command `
            -Name Get-CodexStopContinuation `
            -CommandType Function `
            -ErrorAction SilentlyContinue)
    if (-not $hasStopParser -or -not $hasContinuationFactory) {
        . (Join-Path $PSScriptRoot 'validate-codex-subagent-routing.ps1')
    }
} finally {
    Remove-Variable `
        -Name LoadingCodexParallelAgentOutputHook `
        -Scope Script `
        -ErrorAction SilentlyContinue
}

$script:ParallelPlannerCheckpointPath =
'artifacts/orchestration/parallel-planner-state.json'
$script:ParallelOrchestratorCheckpointPath =
'artifacts/orchestration/parallel-orchestrator-state.json'

function Invoke-CodexParallelAgentOutputSharedValidator {
    <#
    .SYNOPSIS
        Runs the public checkpoint validator for one parallel persona.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('parallel-planner', 'parallel-orchestrator')]
        [string] $AgentType,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $WorkspaceRoot
    )

    $artifactType = 'parallel-planner-state'
    $checkpointPath = $script:ParallelPlannerCheckpointPath
    $completionFlag = '--require-ready-for-execution'
    if ($AgentType -eq 'parallel-orchestrator') {
        $artifactType = 'parallel-orchestrator-state'
        $checkpointPath = $script:ParallelOrchestratorCheckpointPath
        $completionFlag = '--require-complete'
    }

    $arguments = @(
        'run', 'python', '-m',
        'scripts.dev_tools.validate_orchestration_artifacts',
        $artifactType, $checkpointPath,
        '--workspace-root', $WorkspaceRoot,
        $completionFlag
    )
    $output = @(& poetry @arguments 2>&1) |
        ForEach-Object { ([string]$_).Trim() } |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    $validatorExitCode = $LASTEXITCODE

    if ($validatorExitCode -eq 0) {
        return [string[]]@()
    }
    if ($output.Count -eq 0) {
        return [string[]]@(
            "the shared $artifactType validator exited $validatorExitCode without a diagnostic"
        )
    }
    return [string[]]$output
}

function Invoke-CodexParallelAgentOutputDecision {
    <#
    .SYNOPSIS
        Returns no decision for valid output or one bounded continuation result.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $PayloadRaw,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $WorkspaceRoot,

        [Parameter()]
        [scriptblock] $Validator = {
            param($AgentType, $RepositoryRoot)
            Invoke-CodexParallelAgentOutputSharedValidator `
                -AgentType $AgentType `
                -WorkspaceRoot $RepositoryRoot
        }
    )

    $payload = ConvertFrom-CodexStopJson `
        -Raw $PayloadRaw `
        -Name 'parallel SubagentStop input'
    if ([string]$payload.hook_event_name -cne 'SubagentStop') {
        throw 'PARALLEL_AGENT_OUTPUT_BLOCKED: hook_event_name must be SubagentStop.'
    }

    $agentType = [string]$payload.agent_type
    if ($agentType -notin $script:CodexParallelStopPersonas) {
        return $null
    }
    if ($payload.PSObject.Properties.Name -notcontains 'stop_hook_active' -or
        $payload.stop_hook_active -isnot [bool]) {
        throw 'PARALLEL_AGENT_OUTPUT_BLOCKED: stop_hook_active must be boolean.'
    }

    $errors = @(& $Validator $agentType $WorkspaceRoot) |
        ForEach-Object { ([string]$_).Trim() } |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    if ($errors.Count -eq 0) {
        return $null
    }

    $reason = 'PARALLEL_AGENT_OUTPUT_BLOCKED: {0}' -f ($errors -join '; ')
    return Get-CodexStopContinuation `
        -Reason $reason `
        -AlreadyContinued ([bool]$payload.stop_hook_active)
}

if ($MyInvocation.InvocationName -eq '.') {
    return
}

$stopHookActive = $null
try {
    $payloadRaw = [Console]::In.ReadToEnd()
    $payload = ConvertFrom-CodexStopJson `
        -Raw $payloadRaw `
        -Name 'parallel SubagentStop input'
    if ($payload.PSObject.Properties.Name -contains 'stop_hook_active' -and
        $payload.stop_hook_active -is [bool]) {
        $stopHookActive = [bool]$payload.stop_hook_active
    }

    $repositoryRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
    $decision = Invoke-CodexParallelAgentOutputDecision `
        -PayloadRaw $payloadRaw `
        -WorkspaceRoot $repositoryRoot
    if ($null -ne $decision) {
        $decision | ConvertTo-Json -Compress -Depth 5 | Write-Output
    }
    exit 0
} catch {
    $reason = 'PARALLEL_AGENT_OUTPUT_BLOCKED: {0}' -f ([string]$_).Trim()
    if ($stopHookActive -is [bool] -and $stopHookActive) {
        Get-CodexStopContinuation -Reason $reason -AlreadyContinued $true |
            ConvertTo-Json -Compress -Depth 5 |
                Write-Output
        exit 0
    }
    [Console]::Error.WriteLine($reason)
    exit 2
}
