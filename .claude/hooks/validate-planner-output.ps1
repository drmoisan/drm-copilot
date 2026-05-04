<#
.SYNOPSIS
    SubagentStop hook for the atomic-planner subagent.

.DESCRIPTION
    Blocks termination of the atomic-planner subagent unless the agent's final
    output advertises a plan file path AND that file exists on disk.

    The atomic-plan-contract skill requires the planner to return a `plan-path`
    token followed by the path it wrote. This hook extracts that path and
    confirms the file is present, preventing the planner from claiming
    completion without producing the artifact.

.NOTES
    Reads the hook payload from the CLAUDE_HOOK_INPUT environment variable as
    JSON. Exits 0 to allow termination; exits 1 with an error message to block.
#>

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Parse the hook payload supplied by Claude Code in CLAUDE_HOOK_INPUT.
$rawPayload = $env:CLAUDE_HOOK_INPUT
if ([string]::IsNullOrWhiteSpace($rawPayload)) {
    Write-Error 'atomic-planner hook: CLAUDE_HOOK_INPUT is empty; cannot validate planner output.'
    exit 1
}

try {
    $payload = $rawPayload | ConvertFrom-Json -ErrorAction Stop
} catch {
    Write-Error "atomic-planner hook: failed to parse CLAUDE_HOOK_INPUT as JSON: $($_.Exception.Message)"
    exit 1
}

$agentOutput = $payload.output
if ([string]::IsNullOrWhiteSpace($agentOutput)) {
    Write-Error 'atomic-planner hook: agent output is empty; planner must return plan-path and final preflight signal.'
    exit 1
}

# Extract the plan path from the agent output. Supported forms:
#   plan-path: docs/features/.../plan.md
#   plan-path = docs/features/.../plan.md
#   plan-path: "docs/features/.../plan.md"
#   [plan-path](docs/features/.../plan.md)
$planPathPattern = 'plan-path\s*[:=]\s*["'']?([^\s"''\)`]+)|\[plan-path\]\(([^)]+)\)'
$match = [regex]::Match($agentOutput, $planPathPattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
if (-not $match.Success) {
    Write-Error 'atomic-planner hook: agent output does not advertise a plan-path. Planner must report `plan-path: <path>` per atomic-plan-contract.'
    exit 1
}

# Pick whichever capture group matched (key:value form or markdown-link form).
$planPath = if ($match.Groups[1].Success) { $match.Groups[1].Value } else { $match.Groups[2].Value }
$planPath = $planPath.Trim()

if ([string]::IsNullOrWhiteSpace($planPath)) {
    Write-Error 'atomic-planner hook: extracted plan-path was empty.'
    exit 1
}

# Verify the file exists on disk relative to the working directory.
if (-not (Test-Path -LiteralPath $planPath -PathType Leaf)) {
    Write-Error "atomic-planner hook: planner advertised plan-path '$planPath' but no file exists at that location."
    exit 1
}

# All checks passed; allow the subagent to terminate.
exit 0
