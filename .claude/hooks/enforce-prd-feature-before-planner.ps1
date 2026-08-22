<#
.SYNOPSIS
    Pre-tool-use hook that blocks atomic-planner delegations when the target
    feature folder does not yet contain spec.md and user-story.md.

.DESCRIPTION
    Invoked by the Claude Code PreToolUse hook on the Agent (Task) tool. Reads
    tool input JSON from the the envelope's nested tool_input environment variable. Activates
    only when subagent_type is 'atomic-planner'.

    Feature folder resolution order:
      1. Scan the prompt text for any path matching
         docs/features/active/<token>, accepting both forward-slash and
         backslash separators. The longest match wins; when it points at a
         file (ends with .md), use its parent directory.
      2. If no candidate was found in the prompt, read the feature-folder field
         from artifacts/orchestration/orchestrator-state.json.
      3. If neither yields a folder, block with a reason instructing the caller
         to reference a feature folder explicitly.

    Once the folder is resolved, the hook verifies that both spec.md and
    user-story.md exist in that folder. If either is missing, the script emits a
    PreToolUse JSON response with hookSpecificOutput.permissionDecision='deny'
    and a reason naming the missing file(s) and instructing the orchestrator to
    invoke prd-feature first. Allowed delegations emit
    hookSpecificOutput.permissionDecision='allow'.

    Filesystem reads and orchestrator-state lookups go through wrapper functions
    so tests can inject fakes without touching disk.

.NOTES
    Compatible with PowerShell 7+. Read-only validation gate.
#>
[CmdletBinding()]
param()


Import-Module (Join-Path $PSScriptRoot '../lib/hook-payload/HookPayload.psm1') -Force
function Get-PrdFeatureFileExistence {
    <#
    .SYNOPSIS
        Wrapper around Test-Path for sibling-file existence checks. Tests mock this.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [string] $Path
    )

    return [bool](Test-Path -LiteralPath $Path -PathType Leaf)
}

function Get-PrdFeatureCheckpointFolder {
    <#
    .SYNOPSIS
        Returns the feature-folder field from the orchestrator checkpoint, or
        $null when the file or field is absent.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [string] $CheckpointPath = 'artifacts/orchestration/orchestrator-state.json'
    )

    if (-not (Test-Path -LiteralPath $CheckpointPath -PathType Leaf)) {
        return $null
    }

    try {
        $raw = Get-Content -LiteralPath $CheckpointPath -Raw -ErrorAction Stop
        $obj = $raw | ConvertFrom-Json -ErrorAction Stop
    }
    catch {
        return $null
    }

    if ($obj.PSObject.Properties.Name -contains 'feature-folder' -and $obj.'feature-folder') {
        return [string]$obj.'feature-folder'
    }
    return $null
}

function Find-PrdFeatureFolderFromPrompt {
    <#
    .SYNOPSIS
        Scans a prompt string for docs/features/active/<...> path tokens and
        returns the longest unique match resolved to a folder path. Returns
        $null when no match is found.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $Prompt
    )

    if (-not $Prompt) {
        return $null
    }

    # Allow forward or backslash separators inside the matched path token.
    $pattern = 'docs[\\/]+features[\\/]+active[\\/]+[^\s"''`]+'
    $matchList = [regex]::Matches($Prompt, $pattern)
    if ($matchList.Count -eq 0) {
        return $null
    }

    $unique = @{}
    foreach ($m in $matchList) {
        $normalized = ($m.Value -replace '\\', '/').TrimEnd('/')
        $unique[$normalized] = $true
    }

    $candidates = @(@($unique.Keys) | Sort-Object -Property Length -Descending)
    $best = $candidates[0]

    # If the longest match ends in .md, treat it as a file and use its parent.
    if ($best -match '\.md$') {
        $parent = $best -replace '/[^/]+\.md$', ''
        return $parent
    }

    return $best
}

function Get-PrdFeatureMissingFile {
    <#
    .SYNOPSIS
        Returns the list of required files (spec.md, user-story.md) missing in
        the target folder.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory)]
        [string] $FeatureFolder
    )

    $required = @('spec.md', 'user-story.md')
    [System.Collections.Generic.List[string]] $missing = [System.Collections.Generic.List[string]]::new()
    foreach ($name in $required) {
        $candidate = "$FeatureFolder/$name"
        if (-not (Get-PrdFeatureFileExistence -Path $candidate)) {
            $missing.Add($name)
        }
    }
    return [string[]] $missing.ToArray()
}

function Invoke-PrdFeatureBeforePlannerDecision {
    <#
    .SYNOPSIS
        Parses the envelope's nested tool_input and returns an allow-or-block decision.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [string] $ToolInputRaw
    )

    $envelope = Resolve-ClaudeHookToolInput -Raw $ToolInputRaw
    if (-not $envelope.IsValid) {
        return [ordered]@{
            hookSpecificOutput = [ordered]@{
                hookEventName            = 'PreToolUse'
                permissionDecision       = 'deny'
                permissionDecisionReason = 'PRD_FEATURE_BLOCKED: payload anomaly - ' +
                (Get-ClaudeHookPayloadAnomalyReason -Anomaly $envelope.Anomaly) +
                '. The gate fails closed on an envelope it cannot read.'
            }
        }
    }

    $subagent = Get-ClaudeHookToolInputString -ToolInput $envelope.Value -Name 'subagent_type'
    if (-not $subagent -or $subagent -ne 'atomic-planner') {
        return [ordered]@{ hookSpecificOutput = [ordered]@{ hookEventName = 'PreToolUse'; permissionDecision = 'allow' } }
    }

    $prompt = Get-ClaudeHookToolInputString -ToolInput $envelope.Value -Name 'prompt'
    $folder = Find-PrdFeatureFolderFromPrompt -Prompt $prompt
    if (-not $folder) {
        $folder = Get-PrdFeatureCheckpointFolder
    }

    if (-not $folder) {
        return [ordered]@{
            hookSpecificOutput = [ordered]@{
                hookEventName            = 'PreToolUse'
                permissionDecision       = 'deny'
                permissionDecisionReason = "PRD_FEATURE_BLOCKED: atomic-planner delegation must reference a feature folder (either in the prompt or via orchestrator-state.json) so spec.md and user-story.md prerequisites can be verified."
            }
        }
    }

    $folderNormalized = ($folder -replace '\\', '/').TrimEnd('/')
    $missing = Get-PrdFeatureMissingFile -FeatureFolder $folderNormalized
    if ($missing.Count -eq 0) {
        return [ordered]@{ hookSpecificOutput = [ordered]@{ hookEventName = 'PreToolUse'; permissionDecision = 'allow' } }
    }

    $list = ($missing -join ', ')
    return [ordered]@{
        hookSpecificOutput = [ordered]@{
            hookEventName            = 'PreToolUse'
            permissionDecision       = 'deny'
            permissionDecisionReason = "PRD_FEATURE_BLOCKED: cannot delegate to atomic-planner before prd-feature outputs are present in '$folderNormalized'. Missing: $list. Invoke the prd-feature subagent first."
        }
    }
}

# Guard allows dot-sourcing in tests without executing the entrypoint.
if ($MyInvocation.InvocationName -eq '.') {
    return
}

$decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw (Read-ClaudeHookRawPayload)

$decision | ConvertTo-Json -Compress -Depth 5 | Write-Output

exit 0
