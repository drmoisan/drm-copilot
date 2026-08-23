<#
.SYNOPSIS
    Validates parallel worktree removal through the shared state validator.

.DESCRIPTION
    PreToolUse adapter for a parallel-orchestrator `git worktree remove` call.
    The hook owns native payload transport, command activation, and invocation
    of the public parallel-orchestrator-state validator. Exact item, worktree,
    merge, and removal-receipt matching remain shared-validator decisions.
#>
[CmdletBinding()]
param()

. (Join-Path $PSScriptRoot 'parallel-hook-common.ps1')

$script:ParallelRemovalCheckpointPath =
'artifacts/orchestration/parallel-orchestrator-state.json'

function Test-CodexParallelWorktreeRemovalCall {
    <#
    .SYNOPSIS
        Identifies a parallel-orchestrator Git worktree removal command.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)] $Payload,
        [Parameter(Mandatory)] $ToolInput
    )

    if ([string]$Payload.agent_type -cne 'parallel-orchestrator' -or
        [string]$Payload.tool_name -notin @('Bash', 'shell_command')) {
        return $false
    }
    return [string]$ToolInput.command -match
    '(?i)(?:^|[;&|]\s*)git(?:\.exe)?\s+(?:-\S+\s+)*worktree\s+remove(?:\s|$)'
}

function Invoke-CodexParallelRemovalSharedValidator {
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

function Invoke-CodexParallelWorktreeRemovalGate {
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
            Invoke-CodexParallelRemovalSharedValidator `
                -RepositoryRoot $root `
                -CheckpointPath $checkpoint
        }
    )

    $checkpointPath = $script:ParallelRemovalCheckpointPath
    $validatorRoot = $RepositoryRoot
    $validatorRunner = $SharedValidatorRunner
    return Invoke-CodexParallelHookValidation `
        -HookName 'enforce-parallel-worktree-removal-gate' `
        -ReasonCode 'PARALLEL_WORKTREE_REMOVAL_BLOCKED' `
        -PayloadRaw $PayloadRaw `
        -Validator {
        param($toolInput, $payload)
        if (-not (Test-CodexParallelWorktreeRemovalCall `
                    -Payload $payload `
                    -ToolInput $toolInput)) {
            return
        }
        & $validatorRunner $validatorRoot $checkpointPath
    }
}

function Invoke-CodexParallelRemovalHookEntrypoint {
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
        $result = Invoke-CodexParallelWorktreeRemovalGate `
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
exit (Invoke-CodexParallelRemovalHookEntrypoint -RepositoryRoot $repositoryRoot)
