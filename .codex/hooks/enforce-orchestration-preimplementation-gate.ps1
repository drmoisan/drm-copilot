
<#
.SYNOPSIS
    Blocks implementation operations before orchestration readiness exists.
#>
[CmdletBinding()]
param()

# Shared Codex PreToolUse transport: stdin payload parsing and tool_input-to-file
# mapping for every tool name the ^(apply_patch|Edit|Write)$ matcher admits.
. (Join-Path $PSScriptRoot 'codex-pretooluse-file-mapping.ps1')

# The readiness checkpoint this gate reads and names in its block message.
$script:CheckpointPath = 'artifacts/orchestration/orchestrator-state.json'

# Every orchestration checkpoint a planner or orchestrator surface writes. Writing one
# of these is orchestration bookkeeping, not implementation, so the gate must not
# require a ready checkpoint before the checkpoint itself can be created. The set is a
# list of repo-relative literals behind a single membership check: no directory prefix,
# no glob, and no absolute-path entry.
$script:CheckpointPaths = @(
    'artifacts/orchestration/orchestrator-state.json'
    'artifacts/orchestration/parallel-planner-state.json'
    'artifacts/orchestration/parallel-orchestrator-state.json'
    'artifacts/orchestration/epic-planner-state.json'
    'artifacts/orchestration/epic-orchestrator-state.json'
    'artifacts/orchestration/powershell-orchestrator-state.json'
    'artifacts/orchestration/csharp-orchestrator-state.json'
)

# Both markers must appear in the field-scoped prompt for a delegation to qualify as a
# preparation-mode kickoff. The literals are reused verbatim from
# .claude/skills/parallel-plan/SKILL.md and .claude/skills/epic-plan/SKILL.md.
$script:PreparationModeMarkers = @(
    'Preparation mode: true.'
    'route_id: preparation.'
)

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

function ConvertTo-WorkspaceRelativePath {
    <#
    .SYNOPSIS
        Reduces a tool file path to its repo-relative form when it can be confidently
        resolved under the supplied workspace root.
    .DESCRIPTION
        Pure string operation: no filesystem access, no subprocess, no environment read.
        The exemption checks downstream compare against repo-relative forms, so an
        absolute spelling of an exempt path must be reduced before they run.

        The function is deliberately conservative. Any spelling it cannot confidently
        resolve is returned separator-normalized but otherwise unchanged, so the
        unchanged classifier keeps failing closed on it. In particular a path carrying a
        '..' segment is never resolved textually, and the root-prefix test is
        segment-aligned so that root 'C:/repo' does not match 'C:/repository/...'.

        Only the root-prefix comparison ignores case. The returned tail keeps its
        original case so the downstream checks retain their existing semantics.
    .PARAMETER FilePath
        The raw tool path to reduce.
    .PARAMETER WorkspaceRoot
        The workspace root to strip. An empty root strips nothing.
    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $FilePath,
        [Parameter(Mandatory)][AllowEmptyString()][AllowNull()][string] $WorkspaceRoot
    )

    # Step 1: unify separators on both operands.
    $path = ([string]$FilePath) -replace '\\', '/'
    $root = ([string]$WorkspaceRoot) -replace '\\', '/'

    # Step 2: collapse duplicate separators, preserving a leading '//' UNC server prefix.
    $path = $path -replace '(?<!^)/{2,}', '/'
    $root = $root -replace '(?<!^)/{2,}', '/'

    # Step 3: remove identity dot segments.
    while ($path.StartsWith('./')) {
        $path = $path.Substring(2)
    }
    while ($path -match '/\./') {
        $path = $path -replace '/\./', '/'
    }
    if ($path.EndsWith('/.')) {
        $path = $path.Substring(0, $path.Length - 2)
    }

    # Step 4: fail-closed guard. A remaining parent-directory segment is never resolved.
    if ($path -match '^\.\./' -or $path -match '/\.\./' -or $path -match '/\.\.$') {
        return $path
    }

    # Step 5: trim trailing separators from the root.
    $root = $root -replace '/+$', ''

    # Step 6: segment-aligned, case-insensitive root-prefix strip.
    if ($root) {
        $prefix = $root + '/'
        if ($path.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
            $tail = $path.Substring($prefix.Length)
            if ($tail) {
                return $tail
            }
        }
    }

    # Step 7: everything else passes through unchanged.
    return $path
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
    if ($script:CheckpointPaths -contains $NormalizedPath) {
        return $false
    }
    return $NormalizedPath -match '\.(py|ps1|psm1|ts|tsx|js|jsx|cs|json|yml|yaml)$'
}

function Test-ImplementationCommand {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)][string] $Command,

        # Optional so every existing caller binds unchanged. Apply-patch hunk paths are
        # handed to the same exemption classifier as a tool file_path, so they take the
        # same workspace-root normalization.
        [string] $WorkspaceRoot = (Get-Location).Path
    )

    $normalizedCommand = $Command.Trim()
    if (-not $normalizedCommand) {
        return $false
    }

    foreach ($match in [regex]::Matches($normalizedCommand, '(?m)^\*\*\* (?:Add|Update|Delete) File:\s*(?<path>.+?)\s*$')) {
        $path = ConvertTo-WorkspaceRelativePath -FilePath (([string]$match.Groups['path'].Value).Trim()) -WorkspaceRoot $WorkspaceRoot
        if (Test-ImplementationPath -NormalizedPath $path) {
            return $true
        }
    }
    foreach ($match in [regex]::Matches($normalizedCommand, '(?m)^\*\*\* Move to:\s*(?<path>.+?)\s*$')) {
        $path = ConvertTo-WorkspaceRelativePath -FilePath (([string]$match.Groups['path'].Value).Trim()) -WorkspaceRoot $WorkspaceRoot
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

function Test-PreparationModeDelegation {
    <#
    .SYNOPSIS
        Identifies an orchestrator delegation that is a preparation-mode kickoff.
    .DESCRIPTION
        Returns true only when all three conjuncts hold: the payload is present, the
        delegated agent is exactly 'orchestrator', and the field-scoped prompt carries
        both preparation markers. The prompt is read as a named field via this file's
        own Get-StringProperty helper rather than from the serialized payload, so that
        marker text planted in an unrelated field cannot exempt an implementation
        delegation.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory)][AllowNull()] $ToolInput)

    if ($null -eq $ToolInput) {
        return $false
    }

    $subagentType = Get-StringProperty -Value $ToolInput -Name 'subagent_type'
    if ($subagentType -ne 'orchestrator') {
        return $false
    }

    $prompt = Get-StringProperty -Value $ToolInput -Name 'prompt'
    foreach ($marker in $script:PreparationModeMarkers) {
        if (-not $prompt.Contains($marker)) {
            return $false
        }
    }
    return $true
}

function Test-ImplementationDelegation {
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory)][AllowNull()] $ToolInput)

    if ($null -eq $ToolInput) {
        return $false
    }

    try {
        if (Test-PreparationModeDelegation -ToolInput $ToolInput) {
            return $false
        }
    } catch {
        # An envelope the field reader cannot probe falls through to the unchanged
        # whole-payload regex below. An extraction failure must never become an
        # exemption, so the gate stays closed on the stricter classifier.
        Write-Debug "Preparation-mode probe failed: $($_.Exception.Message)"
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
        [string] $CheckpointRaw,

        # Injection seam for the workspace root. The default relies on the existing
        # runtime guarantee that hook processes start in the project root, which the
        # cwd-relative checkpoint read already depends on. Tests supply a synthetic
        # root so no assertion depends on the current directory. The mapped Edit/Write
        # loop in the entry point needs no edit: it calls this function, so the default
        # supplies the root on that path too.
        [string] $WorkspaceRoot = (Get-Location).Path
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
        $normalized = ConvertTo-WorkspaceRelativePath -FilePath $filePath -WorkspaceRoot $WorkspaceRoot
        $requiresReadyCheckpoint = Test-ImplementationPath -NormalizedPath $normalized
    } else {
        $command = Get-StringProperty -Value $toolInput -Name 'command'
        if ($command) {
            $requiresReadyCheckpoint = Test-ImplementationCommand -Command $command -WorkspaceRoot $WorkspaceRoot
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
