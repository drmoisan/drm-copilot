<#
.SYNOPSIS
    Validates a parallel child binding through the shared state validator.

.DESCRIPTION
    PreToolUse adapter for an externally launched parallel child. The hook owns
    only native payload transport, launch-context activation, and invocation of
    the public parallel-orchestrator-state validator. Item, repository, branch,
    worktree, launch, and receipt binding remain shared-validator decisions.
#>
[CmdletBinding()]
param()

. (Join-Path $PSScriptRoot 'parallel-hook-common.ps1')

$script:ParallelChildCheckpointPath =
'artifacts/orchestration/parallel-orchestrator-state.json'

function Test-CodexParallelChildBindingCall {
    <#
    .SYNOPSIS
        Identifies a tool call from a sealed parallel child launch.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)] $Payload,
        [Parameter()][AllowEmptyString()][string] $LaunchId = ''
    )

    return -not [string]::IsNullOrWhiteSpace($LaunchId) -and
    -not [string]::IsNullOrWhiteSpace([string]$Payload.tool_name)
}

function Invoke-CodexParallelChildBindingSharedValidator {
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

function Invoke-CodexParallelChildWorktreeBinding {
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
        [AllowEmptyString()]
        [string] $LaunchId = '',

        [Parameter()]
        [scriptblock] $SharedValidatorRunner = {
            param($root, $checkpoint)
            Invoke-CodexParallelChildBindingSharedValidator `
                -RepositoryRoot $root `
                -CheckpointPath $checkpoint
        }
    )

    $checkpointPath = $script:ParallelChildCheckpointPath
    $validatorRoot = $RepositoryRoot
    $validatorRunner = $SharedValidatorRunner
    $boundLaunchId = $LaunchId
    return Invoke-CodexParallelHookValidation `
        -HookName 'enforce-parallel-child-worktree-binding' `
        -ReasonCode 'PARALLEL_CHILD_WORKTREE_BINDING_BLOCKED' `
        -PayloadRaw $PayloadRaw `
        -Validator {
        param($toolInput, $payload)
        $null = $toolInput
        if (-not (Test-CodexParallelChildBindingCall `
                    -Payload $payload `
                    -LaunchId $boundLaunchId)) {
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
    $result = Invoke-CodexParallelChildWorktreeBinding `
        -PayloadRaw ([Console]::In.ReadToEnd()) `
        -RepositoryRoot $repositoryRoot `
        -LaunchId ([string]$env:CODEX_PARALLEL_CHILD_LAUNCH_ID)
    exit (Write-CodexParallelHookResult -Result $result)
} catch {
    [Console]::Error.WriteLine([string]$_)
    exit 2
}
