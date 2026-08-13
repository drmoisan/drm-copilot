<#
.SYNOPSIS
    Validates parallel drift admission through the shared state validator.

.DESCRIPTION
    PreToolUse adapter for parallel-orchestrator child launches. The hook owns
    only native payload transport and invocation of the public
    parallel-orchestrator-state validator. Drift detection, quiescence,
    pinning, recoloring, and requeue decisions remain in shared validators.
#>
[CmdletBinding()]
param()

. (Join-Path $PSScriptRoot 'parallel-hook-common.ps1')

$script:ParallelDriftCheckpointPath =
'artifacts/orchestration/parallel-orchestrator-state.json'

function Test-CodexParallelDriftGateCall {
    <#
    .SYNOPSIS
        Identifies a parallel-orchestrator child-launch request.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)] $Payload,
        [Parameter(Mandatory)] $ToolInput
    )

    return [string]$Payload.agent_type -ceq 'parallel-orchestrator' -and
    [string]$Payload.tool_name -ceq 'spawn_agent' -and
    @($ToolInput.PSObject.Properties.Name) -contains 'task_name'
}

function Invoke-CodexParallelDriftSharedValidator {
    <#
    .SYNOPSIS
        Invokes the canonical public parallel-orchestrator-state CLI.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $RepositoryRoot,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $CheckpointPath
    )

    $output = @(
        & poetry run python -m scripts.dev_tools.validate_orchestration_artifacts `
            parallel-orchestrator-state $CheckpointPath `
            --workspace-root $RepositoryRoot 2>&1 |
            ForEach-Object { [string]$_ }
    )
    if ($LASTEXITCODE -eq 0) {
        return
    }
    if ($output.Count -eq 0) {
        return 'the shared parallel-orchestrator-state validator exited without a diagnostic'
    }
    return $output -join '; '
}

function Invoke-CodexParallelDriftGate {
    <#
    .SYNOPSIS
        Returns the native allow, deny, or malformed-input hook result.
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $PayloadRaw,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $RepositoryRoot,

        [Parameter()]
        [scriptblock] $SharedValidatorRunner = {
            param($root, $checkpoint)
            Invoke-CodexParallelDriftSharedValidator `
                -RepositoryRoot $root `
                -CheckpointPath $checkpoint
        }
    )

    $checkpointPath = $script:ParallelDriftCheckpointPath
    $validatorRoot = $RepositoryRoot
    $validatorRunner = $SharedValidatorRunner
    return Invoke-CodexParallelHookValidation `
        -HookName 'enforce-parallel-drift-gate' `
        -ReasonCode 'PARALLEL_DRIFT_GATE_BLOCKED' `
        -PayloadRaw $PayloadRaw `
        -Validator {
        param($toolInput, $payload)
        if (-not (Test-CodexParallelDriftGateCall `
                    -Payload $payload `
                    -ToolInput $toolInput)) {
            return
        }
        & $validatorRunner $validatorRoot $checkpointPath
    }
}

function Invoke-CodexParallelDriftHookEntrypoint {
    <#
    .SYNOPSIS
        Runs native hook transport through injectable console boundaries.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $RepositoryRoot,
        [Parameter()][scriptblock] $PayloadReader = { [Console]::In.ReadToEnd() },
        [Parameter()][scriptblock] $ResultWriter = {
            param($result)
            Write-CodexParallelHookResult -Result $result
        }
    )

    try {
        $result = Invoke-CodexParallelDriftGate `
            -PayloadRaw (& $PayloadReader) `
            -RepositoryRoot $RepositoryRoot
        return & $ResultWriter $result
    } catch {
        [Console]::Error.WriteLine([string]$_)
        return 2
    }
}

if ($MyInvocation.InvocationName -eq '.') {
    return
}

$repositoryRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
exit (Invoke-CodexParallelDriftHookEntrypoint -RepositoryRoot $repositoryRoot)
