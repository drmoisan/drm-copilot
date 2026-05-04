<#
.SYNOPSIS
    SubagentStop hook for the task-researcher subagent.

.DESCRIPTION
    Blocks termination of the task-researcher subagent unless the agent's
    final output advertises a `research-path` token, the path is rooted
    under artifacts/research/, and the file exists on disk.

    Per the task-researcher agent contract, all research artifacts must be
    written to artifacts/research/ using the convention:
        artifacts/research/<timestamp>-<short-name>-research.md

    This hook confirms that:
      - the hook payload is well-formed JSON,
      - the agent output is non-empty,
      - the output advertises a research-path token in one of the supported
        forms (key:value, key=value, quoted, or markdown-link),
      - the resolved path begins with artifacts/research/,
      - the file exists at that location.

.NOTES
    Reads the hook payload from CLAUDE_HOOK_INPUT as JSON. Exits 0 to allow
    termination; exits 1 with an error message to block. Filesystem reads go
    through Test-ResearchFile so tests can mock the boundary without
    writing temporary files.
#>

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Test-ResearchFile {
    <#
    .SYNOPSIS
        Thin wrapper around the filesystem-existence boundary for research files.
    .DESCRIPTION
        Returns $true when the path resolves to a file on disk, $false otherwise.
        Tests mock this function to inject existence results without temp files.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path
    )

    return [bool](Test-Path -LiteralPath $Path -PathType Leaf)
}

function Get-ResearchPathFromOutput {
    <#
    .SYNOPSIS
        Extracts the research-path token from agent output.
    .DESCRIPTION
        Supports the same forms as the planner and executor hooks:
            research-path: artifacts/research/<file>.md
            research-path = artifacts/research/<file>.md
            research-path: "artifacts/research/<file>.md"
            [research-path](artifacts/research/<file>.md)
        Returns the trimmed path string, or $null when no token is present.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string] $AgentOutput
    )

    $pattern = 'research-path\s*[:=]\s*["'']?([^\s"''\)`]+)|\[research-path\]\(([^)]+)\)'
    $match = [regex]::Match($AgentOutput, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    if (-not $match.Success) {
        return $null
    }

    $value = if ($match.Groups[1].Success) { $match.Groups[1].Value } else { $match.Groups[2].Value }
    $value = $value.Trim()
    if ([string]::IsNullOrWhiteSpace($value)) {
        return $null
    }

    return $value
}

function Test-IsUnderResearchRoot {
    <#
    .SYNOPSIS
        Validates that a path is rooted under artifacts/research/.
    .DESCRIPTION
        Normalizes forward and back slashes, then checks the prefix.
        This is a string check; it does not touch the filesystem.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path
    )

    $normalized = $Path -replace '\\', '/'
    return $normalized.StartsWith('artifacts/research/', [System.StringComparison]::OrdinalIgnoreCase)
}

function Invoke-TaskResearcherOutputValidation {
    <#
    .SYNOPSIS
        Parses the hook payload and returns an ok-or-block decision.
    .DESCRIPTION
        Returns a hashtable with keys:
          - Ok:      $true to allow termination, $false to block.
          - Message: error message when blocking; $null on success.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [string] $RawPayload
    )

    if ([string]::IsNullOrWhiteSpace($RawPayload)) {
        return @{ Ok = $false; Message = 'task-researcher hook: CLAUDE_HOOK_INPUT is empty; cannot validate task-researcher output.' }
    }

    try {
        $payload = $RawPayload | ConvertFrom-Json -ErrorAction Stop
    } catch {
        return @{ Ok = $false; Message = "task-researcher hook: failed to parse CLAUDE_HOOK_INPUT as JSON: $($_.Exception.Message)" }
    }

    $agentOutput = $null
    if ($payload.PSObject.Properties.Name -contains 'output') {
        $agentOutput = $payload.output
    }
    if ([string]::IsNullOrWhiteSpace($agentOutput)) {
        return @{ Ok = $false; Message = 'task-researcher hook: agent output is empty; researcher must return research-path before termination.' }
    }

    $researchPath = Get-ResearchPathFromOutput -AgentOutput $agentOutput
    if ($null -eq $researchPath) {
        return @{ Ok = $false; Message = 'task-researcher hook: agent output does not advertise a research-path. Researcher must report `research-path: <path>` pointing to artifacts/research/.' }
    }

    if (-not (Test-IsUnderResearchRoot -Path $researchPath)) {
        return @{ Ok = $false; Message = "task-researcher hook: research-path '$researchPath' is not under artifacts/research/. All research artifacts must be written to artifacts/research/." }
    }

    if (-not (Test-ResearchFile -Path $researchPath)) {
        return @{ Ok = $false; Message = "task-researcher hook: researcher advertised research-path '$researchPath' but no file exists at that location." }
    }

    return @{ Ok = $true; Message = $null }
}

# Guard allows dot-sourcing in tests without executing the entrypoint.
if ($MyInvocation.InvocationName -eq '.') {
    return
}

$result = Invoke-TaskResearcherOutputValidation -RawPayload $env:CLAUDE_HOOK_INPUT
if (-not $result.Ok) {
    Write-Error $result.Message
    exit 1
}

exit 0
