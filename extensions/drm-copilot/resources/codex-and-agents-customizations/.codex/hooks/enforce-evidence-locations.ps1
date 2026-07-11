
<#
.SYNOPSIS
    Pre-tool-use hook that blocks writes to non-canonical evidence storage locations.

.DESCRIPTION
    This script is invoked by the Codex PreToolUse hook before any Write or Edit
    operation. It reads the tool input from the Codex tool_input environment variable
    (JSON with a 'file_path' field) and rejects the operation when the target path is
    a non-canonical evidence location.

    Forbidden path prefixes (case-sensitive, normalized to forward-slash):
      - artifacts/baselines/
      - artifacts/baseline/
      - artifacts/qa/
      - artifacts/qa-gates/
      - artifacts/coverage/
      - artifacts/evidence/
      - artifacts/regression-testing/
      - artifacts/post-change/
      - artifacts/research/

    All other paths pass through, including canonical evidence paths of the form
    <FEATURE>/evidence/<kind>/ and permitted artifacts/ sub-paths such as
    artifacts/orchestration/, artifacts/pr_context, artifacts/reviews/,
    artifacts/status/, artifacts/python/, artifacts/pester/, and
    artifacts/csharp/. Research output is no longer an artifacts/ sub-path; it
    is written to the tracked roots docs/features/<feature>/research/
    (feature-associated) or docs/research/ (one-off).

    If the file_path resolves to a forbidden prefix, the script writes a PreToolUse JSON
    response to stdout with hookSpecificOutput.permissionDecision = 'deny' and exits with
    code 0 so Codex surfaces the reason. For allowed paths, a PreToolUse response
    with permissionDecision = 'allow' is written to stdout and the script exits 0. On hard
    failure (malformed JSON input), the script exits 2.

.NOTES
    Compatible with PowerShell 7+.
    This script must not modify any state; it is a read-only validation gate.
#>
[CmdletBinding()]
param()

function Test-EvidenceLocationForbidden {
    <#
    .SYNOPSIS
        Returns $true when the supplied file path targets a forbidden evidence sub-path.
    .PARAMETER FilePath
        The raw file_path value from the Codex tool-input JSON.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [string] $FilePath
    )

    # Normalize separators so both absolute Windows paths and relative POSIX paths match.
    $normalized = $FilePath -replace '\\', '/'

    $forbiddenPrefixes = @(
        'artifacts/baselines/',
        'artifacts/baseline/',
        'artifacts/qa/',
        'artifacts/qa-gates/',
        'artifacts/coverage/',
        'artifacts/evidence/',
        'artifacts/regression-testing/',
        'artifacts/post-change/',
        'artifacts/research/'
    )

    # Match the prefix either at the start of the string or after any directory separator,
    # to handle both relative and absolute path forms.
    foreach ($prefix in $forbiddenPrefixes) {
        $escapedPrefix = [regex]::Escape($prefix)
        if ($normalized -match "(^|/)$escapedPrefix") {
            return $true
        }
    }

    return $false
}

function Get-EvidenceLocationBlockDecision {
    <#
    .SYNOPSIS
        Constructs a deny-decision ordered dictionary for the supplied forbidden path.
    .PARAMETER FilePath
        The file path that triggered the deny decision.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory)]
        [string] $FilePath
    )

    [ordered]@{
        hookSpecificOutput = [ordered]@{
            hookEventName            = 'PreToolUse'
            permissionDecision       = 'deny'
            permissionDecisionReason = "EVIDENCE_LOCATION_BLOCKED: '$FilePath' is not a canonical evidence location. Use <FEATURE>/evidence/<kind>/ instead. See .agents/skills/evidence-and-timestamp-conventions/SKILL.md for the canonical scheme."
        }
    }
}

function Invoke-EvidenceLocationDecision {
    <#
    .SYNOPSIS
        Parses the Codex tool-input JSON and returns an allow-or-block decision.
    .PARAMETER ToolInputRaw
        The raw JSON string from $env:Codex tool_input. An empty or null value
        results in an allow decision (non-file tool calls have no file_path).
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [string] $ToolInputRaw
    )

    if (-not $ToolInputRaw) {
        return [ordered]@{ hookSpecificOutput = [ordered]@{ hookEventName = 'PreToolUse'; permissionDecision = 'allow' } }
    }

    try {
        $toolInput = $ToolInputRaw | ConvertFrom-Json -ErrorAction Stop
    } catch {
        # Malformed JSON is a hard failure; caller exits 1 to surface the issue.
        throw "enforce-evidence-locations hook received malformed JSON in Codex tool_input: $_"
    }

    $filePath = $toolInput.file_path
    if (-not $filePath) {
        return [ordered]@{ hookSpecificOutput = [ordered]@{ hookEventName = 'PreToolUse'; permissionDecision = 'allow' } }
    }

    if (Test-EvidenceLocationForbidden -FilePath $filePath) {
        return Get-EvidenceLocationBlockDecision -FilePath $filePath
    }

    return [ordered]@{ hookSpecificOutput = [ordered]@{ hookEventName = 'PreToolUse'; permissionDecision = 'allow' } }
}

function ConvertFrom-CodexEvidenceLocationPayload {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string] $PayloadRaw)

    if ([string]::IsNullOrWhiteSpace($PayloadRaw)) {
        throw 'enforce-evidence-locations hook input is empty.'
    }
    try {
        $payload = $PayloadRaw | ConvertFrom-Json -ErrorAction Stop
    } catch {
        throw "enforce-evidence-locations hook input is malformed JSON: $_"
    }
    if ($payload.PSObject.Properties.Name -notcontains 'tool_input' -or $null -eq $payload.tool_input) {
        throw 'enforce-evidence-locations hook input is missing tool_input.'
    }
    if ([string]$payload.hook_event_name -ne 'PreToolUse' -or [string]$payload.tool_name -ne 'apply_patch') {
        throw 'enforce-evidence-locations requires a PreToolUse apply_patch payload.'
    }
    return $payload
}

function Get-CodexEvidenceLocationPath {
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)] $Payload)

    if ($Payload.tool_input.PSObject.Properties.Name -contains 'file_path') {
        return [string]$Payload.tool_input.file_path
    }
    $command = [string]$Payload.tool_input.command
    if ([string]::IsNullOrWhiteSpace($command)) {
        throw 'enforce-evidence-locations cannot map tool_input to a file edit.'
    }
    [string[]] $paths = @(
        [regex]::Matches($command, '(?m)^\*\*\* (?:(?:Add|Update|Delete) File|Move to):\s*(?<path>.+?)\s*$') |
            ForEach-Object { ([string]$_.Groups['path'].Value).Trim() }
    )
    $paths = @($paths | Select-Object -Unique)
    if ($paths.Count -eq 0) {
        throw 'enforce-evidence-locations received an unrecognized apply_patch command.'
    }
    foreach ($path in $paths) {
        Write-Output ([string]$path)
    }
}

function Invoke-EvidenceLocationEntryPoint {
    [CmdletBinding()]
    [OutputType([int])]
    param([Parameter(Mandatory)][string] $PayloadRaw)

    try {
        $payload = ConvertFrom-CodexEvidenceLocationPayload -PayloadRaw $PayloadRaw
        foreach ($path in @(Get-CodexEvidenceLocationPath -Payload $payload)) {
            $toolInputRaw = @{ file_path = $path } | ConvertTo-Json -Compress
            $decision = Invoke-EvidenceLocationDecision -ToolInputRaw $toolInputRaw
            if ($decision.hookSpecificOutput.permissionDecision -eq 'deny') {
                [Console]::Out.WriteLine(($decision | ConvertTo-Json -Compress -Depth 5))
                return 0
            }
        }
        return 0
    } catch {
        [Console]::Error.WriteLine([string]$_)
        return 2
    }
}

# Guard allows dot-sourcing in tests without executing the entrypoint.
if ($MyInvocation.InvocationName -eq '.') {
    return
}

exit (Invoke-EvidenceLocationEntryPoint -PayloadRaw ([Console]::In.ReadToEnd()))
