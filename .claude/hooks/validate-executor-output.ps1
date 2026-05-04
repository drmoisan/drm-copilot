<#
.SYNOPSIS
    SubagentStop hook for the atomic-executor subagent.

.DESCRIPTION
    Blocks termination of the atomic-executor subagent unless every plan task
    checkbox in the active plan file has been ticked from `- [ ]` to `- [x]`.

    The atomic-plan-contract skill requires the executor to advertise a
    `plan-path` token in its final output. This hook extracts that path,
    confirms the file exists, reads its contents, and scans for unchecked
    task markers. Any unchecked checkbox blocks termination.

.NOTES
    Reads the hook payload from the CLAUDE_HOOK_INPUT environment variable as
    JSON. Exits 0 to allow termination; exits 1 with an error message to block.
    Plan file contents are read through Get-PlanFileContent so tests can mock
    the filesystem boundary without writing temporary files.
#>

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-PlanFileContent {
    <#
    .SYNOPSIS
        Thin wrapper around the filesystem-read boundary for plan files.
    .DESCRIPTION
        Returns a hashtable with two keys:
          - Exists: $true when the path resolves to a file on disk.
          - Lines:  array of string lines from the file (empty when missing).
        Tests mock this function to inject plan content without temp files.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return @{ Exists = $false; Lines = @() }
    }

    $lines = Get-Content -LiteralPath $Path -ErrorAction Stop
    if ($null -eq $lines) {
        $lines = @()
    } elseif ($lines -isnot [array]) {
        $lines = @($lines)
    }

    return @{ Exists = $true; Lines = $lines }
}

function Get-PlanPathFromOutput {
    <#
    .SYNOPSIS
        Extracts the plan-path token from agent output.
    .DESCRIPTION
        Supports the same forms as the planner hook:
            plan-path: docs/.../plan.md
            plan-path = docs/.../plan.md
            plan-path: "docs/.../plan.md"
            [plan-path](docs/.../plan.md)
        Returns the trimmed path string, or $null when no token is present.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string] $AgentOutput
    )

    $pattern = 'plan-path\s*[:=]\s*["'']?([^\s"''\)`]+)|\[plan-path\]\(([^)]+)\)'
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

function Invoke-ExecutorOutputValidation {
    <#
    .SYNOPSIS
        Parses the hook payload and returns an ok-or-block decision.
    .DESCRIPTION
        Returns a hashtable with keys:
          - Ok:      $true to allow termination, $false to block.
          - Message: error message when blocking; $null on success.
        The entrypoint translates the result into Write-Error + exit codes.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [string] $RawPayload
    )

    if ([string]::IsNullOrWhiteSpace($RawPayload)) {
        return @{ Ok = $false; Message = 'atomic-executor hook: CLAUDE_HOOK_INPUT is empty; cannot validate executor output.' }
    }

    try {
        $payload = $RawPayload | ConvertFrom-Json -ErrorAction Stop
    } catch {
        return @{ Ok = $false; Message = "atomic-executor hook: failed to parse CLAUDE_HOOK_INPUT as JSON: $($_.Exception.Message)" }
    }

    $agentOutput = $null
    if ($payload.PSObject.Properties.Name -contains 'output') {
        $agentOutput = $payload.output
    }
    if ([string]::IsNullOrWhiteSpace($agentOutput)) {
        return @{ Ok = $false; Message = 'atomic-executor hook: agent output is empty; executor must return plan-path and final completion summary.' }
    }

    $planPath = Get-PlanPathFromOutput -AgentOutput $agentOutput
    if ($null -eq $planPath) {
        return @{ Ok = $false; Message = 'atomic-executor hook: agent output does not advertise a plan-path. Executor must report `plan-path: <path>` per atomic-plan-contract.' }
    }

    $file = Get-PlanFileContent -Path $planPath
    if (-not $file.Exists) {
        return @{ Ok = $false; Message = "atomic-executor hook: executor advertised plan-path '$planPath' but no file exists at that location." }
    }

    $checkboxLineCount = 0
    $uncheckedLineNumbers = New-Object System.Collections.Generic.List[int]
    $uncheckedPattern = '^\s*-\s\[\s\]\s'
    $checkedPattern = '^\s*-\s\[[xX]\]\s'

    for ($i = 0; $i -lt $file.Lines.Count; $i++) {
        $line = $file.Lines[$i]
        if ($line -match $uncheckedPattern) {
            $checkboxLineCount++
            $uncheckedLineNumbers.Add($i + 1)
        } elseif ($line -match $checkedPattern) {
            $checkboxLineCount++
        }
    }

    if ($checkboxLineCount -eq 0) {
        return @{ Ok = $false; Message = "atomic-executor hook: plan file '$planPath' contains no task checkboxes; executor cannot complete against an empty plan." }
    }

    if ($uncheckedLineNumbers.Count -gt 0) {
        $reported = $uncheckedLineNumbers
        $suffix = ''
        if ($uncheckedLineNumbers.Count -gt 5) {
            $reported = $uncheckedLineNumbers.GetRange(0, 5)
            $suffix = ' (showing first 5)'
        }
        $lineList = ($reported -join ', ')
        $message = "atomic-executor hook: plan file '$planPath' has $($uncheckedLineNumbers.Count) unchecked task(s) at line(s) ${lineList}${suffix}. All `- [ ]` items must be ticked to `- [x]` before termination."
        return @{ Ok = $false; Message = $message }
    }

    return @{ Ok = $true; Message = $null }
}

# Guard allows dot-sourcing in tests without executing the entrypoint.
if ($MyInvocation.InvocationName -eq '.') {
    return
}

$result = Invoke-ExecutorOutputValidation -RawPayload $env:CLAUDE_HOOK_INPUT
if (-not $result.Ok) {
    Write-Error $result.Message
    exit 1
}

exit 0
