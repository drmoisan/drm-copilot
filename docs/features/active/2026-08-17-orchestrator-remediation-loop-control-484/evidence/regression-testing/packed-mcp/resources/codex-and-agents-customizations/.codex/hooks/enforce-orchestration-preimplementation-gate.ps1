
<#
.SYNOPSIS
    Blocks implementation operations before orchestration readiness exists.
#>
[CmdletBinding()]
param()

# Shared Codex PreToolUse transport: stdin payload parsing and tool_input-to-file
# mapping for every tool name the ^(apply_patch|Edit|Write)$ matcher admits.
. (Join-Path $PSScriptRoot 'codex-pretooluse-file-mapping.ps1')

$script:CheckpointPath = 'artifacts/orchestration/orchestrator-state.json'

function ConvertFrom-CheckpointJson {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string] $Json)

    return $Json | ConvertFrom-Json -ErrorAction Stop
}

function Get-StringProperty {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][AllowNull()] $Value,
        [Parameter(Mandatory)][string] $Name
    )

    if ($null -eq $Value -or -not ($Value.PSObject.Properties.Name -contains $Name)) {
        return ''
    }
    return ([string]$Value.$Name).Trim()
}

function Test-FeatureDocumentationOrEvidencePath {
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory)][string] $NormalizedPath)

    return $NormalizedPath.StartsWith('docs/features/active/')
}

function Test-ImplementationPath {
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory)][string] $NormalizedPath)

    if (Test-FeatureDocumentationOrEvidencePath -NormalizedPath $NormalizedPath) {
        return $false
    }
    if ($NormalizedPath -eq $script:CheckpointPath) {
        return $false
    }
    return $NormalizedPath -match '\.(py|ps1|psm1|ts|tsx|js|jsx|cs|json|yml|yaml)$'
}

function Test-ImplementationCommand {
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory)][string] $Command)

    $normalizedCommand = $Command.Trim()
    if (-not $normalizedCommand) {
        return $false
    }

    foreach ($match in [regex]::Matches($normalizedCommand, '(?m)^\*\*\* (?:Add|Update|Delete) File:\s*(?<path>.+?)\s*$')) {
        $path = (([string]$match.Groups['path'].Value).Trim()) -replace '\\', '/'
        if (Test-ImplementationPath -NormalizedPath $path) {
            return $true
        }
    }
    foreach ($match in [regex]::Matches($normalizedCommand, '(?m)^\*\*\* Move to:\s*(?<path>.+?)\s*$')) {
        $path = (([string]$match.Groups['path'].Value).Trim()) -replace '\\', '/'
        if (Test-ImplementationPath -NormalizedPath $path) {
            return $true
        }
    }

    $implementationCommandPatterns = @(
        '(^|\s)git\s+(add|commit)\b',
        '(^|\s)(poetry\s+run\s+)?(black|ruff|pyright|pytest)\b',
        '(^|\s)npm\s+.*\s+(prettier|lint|typecheck|test:unit)\b',
        '(^|\s)npx\s+(prettier|eslint|tsc|jest)\b',
        '(^|\s)pwsh\s+.*(Invoke-Pester|tests/scripts/)'
    )

    foreach ($pattern in $implementationCommandPatterns) {
        if ($normalizedCommand -match $pattern) {
            return $true
        }
    }
    return $false
}

function Test-ImplementationDelegation {
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory)][AllowNull()] $ToolInput)

    if ($null -eq $ToolInput) {
        return $false
    }

    $payloadText = ($ToolInput | ConvertTo-Json -Depth 20 -Compress)
    return $payloadText -match '(python-typed-engineer|powershell-typed-engineer|typescript-engineer|csharp-typed-engineer|atomic-executor|implementation|execute)'
}

function Test-OrchestrationReady {
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory)][AllowNull()] $Payload)

    if ($null -eq $Payload) {
        return $false
    }
    $issueNum = Get-StringProperty -Value $Payload -Name 'issue-num'
    $featureFolder = Get-StringProperty -Value $Payload -Name 'feature-folder'
    $routeId = Get-StringProperty -Value $Payload -Name 'route_id'
    if (-not $routeId) {
        $routeId = Get-StringProperty -Value $Payload -Name 'path_selected'
    }
    $lifecycleReady = $false
    if ($Payload.PSObject.Properties.Name -contains 'lifecycle_ready') {
        $lifecycleReady = [bool]$Payload.lifecycle_ready
    }

    if (-not $issueNum -or -not $featureFolder -or -not $routeId -or -not $lifecycleReady) {
        return $false
    }

    return (
        $featureFolder.StartsWith('docs/features/active/') -and
        $routeId -and
        $lifecycleReady
    )
}

function Get-CheckpointContent {
    [CmdletBinding()]
    [OutputType([string])]
    param()

    if (-not (Test-Path -LiteralPath $script:CheckpointPath)) {
        return ''
    }
    return Get-Content -Raw -LiteralPath $script:CheckpointPath
}

function Get-OrchestrationPreimplementationGateAllowDecision {
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param()

    return [ordered]@{
        hookSpecificOutput = [ordered]@{
            hookEventName      = 'PreToolUse'
            permissionDecision = 'allow'
        }
    }
}

function Get-OrchestrationPreimplementationGateBlockDecision {
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory)]
        [string] $Reason
    )

    return [ordered]@{
        hookSpecificOutput = [ordered]@{
            hookEventName            = 'PreToolUse'
            permissionDecision       = 'deny'
            permissionDecisionReason = $Reason
        }
    }
}

function Invoke-OrchestrationPreimplementationGateDecision {
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [string] $ToolInputRaw,
        [string] $CheckpointRaw
    )

    if (-not $ToolInputRaw) {
        return Get-OrchestrationPreimplementationGateAllowDecision
    }
    try {
        $toolInput = $ToolInputRaw | ConvertFrom-Json -ErrorAction Stop
    } catch {
        throw "enforce-orchestration-preimplementation-gate received malformed mapped tool_input JSON: $_"
    }

    $requiresReadyCheckpoint = $false
    $filePath = Get-StringProperty -Value $toolInput -Name 'file_path'
    if ($filePath) {
        $normalized = ([string]$filePath) -replace '\\', '/'
        $requiresReadyCheckpoint = Test-ImplementationPath -NormalizedPath $normalized
    } else {
        $command = Get-StringProperty -Value $toolInput -Name 'command'
        if ($command) {
            $requiresReadyCheckpoint = Test-ImplementationCommand -Command $command
        } else {
            $requiresReadyCheckpoint = Test-ImplementationDelegation -ToolInput $toolInput
        }
    }

    if (-not $requiresReadyCheckpoint) {
        return Get-OrchestrationPreimplementationGateAllowDecision
    }

    if (-not $CheckpointRaw) {
        $CheckpointRaw = Get-CheckpointContent
    }
    try {
        $checkpoint = ConvertFrom-CheckpointJson -Json $CheckpointRaw
    } catch {
        $checkpoint = $null
    }

    if (Test-OrchestrationReady -Payload $checkpoint) {
        return Get-OrchestrationPreimplementationGateAllowDecision
    }
    return Get-OrchestrationPreimplementationGateBlockDecision -Reason 'PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require artifacts/orchestration/orchestrator-state.json to contain issue number, feature folder, route metadata, lifecycle readiness, and checkpoint state before implementation begins.'
}

if ($MyInvocation.InvocationName -eq '.') {
    return
}

try {
    $payload = ConvertFrom-CodexPreToolUsePayload -PayloadRaw ([Console]::In.ReadToEnd()) -HookName 'enforce-orchestration-preimplementation-gate'
    $toolName = [string]$payload.tool_name

    # Bash and apply_patch take the pre-fix path unchanged: the raw tool_input is
    # serialized and evaluated by the untouched decision function, so every
    # allow/deny outcome those two tool names produce today is preserved exactly.
    if (@('Bash', 'apply_patch') -contains $toolName) {
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw ($payload.tool_input | ConvertTo-Json -Compress -Depth 20)
        if ($decision.hookSpecificOutput.permissionDecision -eq 'deny') {
            $decision | ConvertTo-Json -Compress -Depth 5 | Write-Output
        }
        exit 0
    }

    # Edit and Write map to file paths through the shared module; each mapped
    # path enters the same untouched Test-ImplementationPath decision flow. Any
    # other well-formed tool name maps to no records, so the hook allows.
    foreach ($toolInput in @(ConvertTo-CodexFileEditInput -Payload $payload)) {
        $mappedRaw = @{ file_path = [string]$toolInput.file_path } | ConvertTo-Json -Compress
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $mappedRaw
        if ($decision.hookSpecificOutput.permissionDecision -eq 'deny') {
            $decision | ConvertTo-Json -Compress -Depth 5 | Write-Output
            exit 0
        }
    }
    exit 0
} catch {
    [Console]::Error.WriteLine([string]$_)
    exit 2
}
