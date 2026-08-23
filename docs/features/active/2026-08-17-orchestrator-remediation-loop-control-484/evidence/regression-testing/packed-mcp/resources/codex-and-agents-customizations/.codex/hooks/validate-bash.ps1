
<#
.SYNOPSIS
    Codex PreToolUse hook that blocks dangerous shell commands.

.DESCRIPTION
    Reads one Codex hook payload from stdin, validates tool_input.command, and emits the current
    PreToolUse deny envelope for destructive operations. Malformed hook input fails closed with
    exit code 2 and the reason on stderr. Safe commands emit no output and exit 0.

.NOTES
    Compatible with PowerShell 7+. This hook is read-only.
#>
[CmdletBinding()]
param()

function Get-BlockedBashPattern {
    [CmdletBinding()]
    [OutputType([string[]])]
    param()

    return [string[]]@(
        'rm -rf',
        'git push --force',
        'git push origin --force',
        'Remove-Item -Recurse -Force',
        'git reset --hard',
        'git push -f'
    )
}

function Get-BlockedPatternMatch {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $false)]
        [AllowEmptyString()]
        [AllowNull()]
        [string] $Command
    )

    if (-not $Command) {
        return $null
    }

    foreach ($pattern in (Get-BlockedBashPattern)) {
        if ($Command.Contains($pattern)) {
            return $pattern
        }
    }

    return $null
}

function Get-BashBlockReason {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $false)]
        [AllowEmptyString()]
        [AllowNull()]
        [string] $Command
    )

    $pattern = Get-BlockedPatternMatch -Command $Command
    if (-not $pattern) {
        return $null
    }

    return "Blocked dangerous command pattern detected: '$pattern'"
}

function Get-BashDenyDecision {
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory)]
        [string] $Reason
    )

    [ordered]@{
        hookSpecificOutput = [ordered]@{
            hookEventName            = 'PreToolUse'
            permissionDecision       = 'deny'
            permissionDecisionReason = $Reason
        }
    }
}

function Get-BashCommandToCheck {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $false)]
        [AllowEmptyString()]
        [AllowNull()]
        [string] $ToolInputRaw,

        [Parameter(Mandatory = $false)]
        [AllowEmptyString()]
        [AllowNull()]
        [string] $PositionalInput
    )

    if ($ToolInputRaw) {
        try {
            $parsed = $ToolInputRaw | ConvertFrom-Json -ErrorAction Stop
            if ($parsed.command) {
                return [string]$parsed.command
            }
        } catch {
            # If JSON parsing fails, treat the raw input as the command.
            return $ToolInputRaw
        }
    }

    if ($PositionalInput) {
        return $PositionalInput
    }

    return ''
}

function Invoke-ValidateBashDecision {
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $false)]
        [AllowEmptyString()]
        [AllowNull()]
        [string] $ToolInputRaw,

        [Parameter(Mandatory = $false)]
        [AllowEmptyString()]
        [AllowNull()]
        [string] $PositionalInput
    )

    $commandToCheck = Get-BashCommandToCheck -ToolInputRaw $ToolInputRaw -PositionalInput $PositionalInput

    $reason = Get-BashBlockReason -Command $commandToCheck
    if ($reason) {
        return Get-BashDenyDecision -Reason $reason
    }

    return $null
}

function ConvertFrom-CodexBashHookPayload {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string] $PayloadRaw)

    if ([string]::IsNullOrWhiteSpace($PayloadRaw)) {
        throw 'validate-bash hook input is empty.'
    }
    try {
        $payload = $PayloadRaw | ConvertFrom-Json -ErrorAction Stop
    } catch {
        throw "validate-bash hook input is malformed JSON: $_"
    }
    if ($payload.PSObject.Properties.Name -notcontains 'tool_input' -or $null -eq $payload.tool_input) {
        throw 'validate-bash hook input is missing tool_input.'
    }
    if ([string]$payload.hook_event_name -ne 'PreToolUse' -or [string]$payload.tool_name -ne 'Bash') {
        throw 'validate-bash requires a PreToolUse Bash payload.'
    }
    return $payload
}

if ($MyInvocation.InvocationName -eq '.') {
    return
}

try {
    $payload = ConvertFrom-CodexBashHookPayload -PayloadRaw ([Console]::In.ReadToEnd())
    $toolInputRaw = $payload.tool_input | ConvertTo-Json -Compress -Depth 20
    $decision = Invoke-ValidateBashDecision -ToolInputRaw $toolInputRaw
    if ($null -ne $decision -and $decision.hookSpecificOutput.permissionDecision -eq 'deny') {
        $decision | ConvertTo-Json -Compress -Depth 5 | Write-Output
    }
    exit 0
} catch {
    [Console]::Error.WriteLine([string]$_)
    exit 2
}
