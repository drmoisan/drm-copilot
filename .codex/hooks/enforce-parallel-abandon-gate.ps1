<#
.SYNOPSIS
    Validates parallel detach or abandon admission through the shared validator.

.DESCRIPTION
    PreToolUse adapter for the deterministic parallel removal CLI. The hook owns
    native payload transport, command activation, and invocation of the public
    parallel-orchestrator-state validator. Exact operation, item, worktree, and
    confirmation binding remain shared mutation/checkpoint decisions.
#>
[CmdletBinding()]
param()

. (Join-Path $PSScriptRoot 'parallel-hook-common.ps1')

$script:ParallelAbandonCheckpointPath =
'artifacts/orchestration/parallel-orchestrator-state.json'

function Test-CodexParallelAbandonCall {
    <#
    .SYNOPSIS
        Identifies the deterministic parallel removal CLI invocation.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)] $Payload,
        [Parameter(Mandatory)] $ToolInput
    )

    if ([string]$Payload.tool_name -notin @('Bash', 'shell_command')) {
        return $false
    }
    return [string]$ToolInput.command -match
    '(?i)\bpython(?:\.exe)?\s+-m\s+scripts\.dev_tools\.parallel_mutation_abandon_cli\b'
}

function Invoke-CodexParallelAbandonSharedValidator {
    <#
    .SYNOPSIS
        Invokes the canonical public parallel-orchestrator-state CLI.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $RepositoryRoot,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $CheckpointPath
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

function Invoke-CodexParallelAbandonGate {
    <#
    .SYNOPSIS
        Returns the native allow, deny, or malformed-input hook result.
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $PayloadRaw,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $RepositoryRoot,
        [Parameter()]
        [scriptblock] $SharedValidatorRunner = {
            param($root, $checkpoint)
            Invoke-CodexParallelAbandonSharedValidator `
                -RepositoryRoot $root `
                -CheckpointPath $checkpoint
        }
    )

    $checkpointPath = $script:ParallelAbandonCheckpointPath
    $validatorRoot = $RepositoryRoot
    $validatorRunner = $SharedValidatorRunner
    return Invoke-CodexParallelHookValidation `
        -HookName 'enforce-parallel-abandon-gate' `
        -ReasonCode 'PARALLEL_ABANDON_BLOCKED' `
        -PayloadRaw $PayloadRaw `
        -Validator {
        param($toolInput, $payload)
        if (-not (Test-CodexParallelAbandonCall `
                    -Payload $payload `
                    -ToolInput $toolInput)) {
            return
        }
        & $validatorRunner $validatorRoot $checkpointPath
    }
}

if ($MyInvocation.InvocationName -eq '.') {
    return
}

try {
    $repositoryRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
    $result = Invoke-CodexParallelAbandonGate `
        -PayloadRaw ([Console]::In.ReadToEnd()) `
        -RepositoryRoot $repositoryRoot
    exit (Write-CodexParallelHookResult -Result $result)
} catch {
    [Console]::Error.WriteLine([string]$_)
    exit 2
}
