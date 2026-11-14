<#
.SYNOPSIS
    Pre-tool-use hook that denies mutating Poetry commands aimed at an outside VIRTUAL_ENV.

.DESCRIPTION
    Codex twin of .claude/hooks/enforce-worktree-poetry-venv.ps1 (issue #1127), invoked by
    the Codex PreToolUse hook on the ^Bash$ matcher. Poetry honors an inherited VIRTUAL_ENV
    over the in-project poetry.toml, so poetry install, sync, add, remove, or update run in
    an agent worktree writes into the main checkout's environment when the session exported
    VIRTUAL_ENV for that checkout. This hook denies such a command before it runs and names
    the legitimate path: run env -u VIRTUAL_ENV poetry install from the worktree root.

    The decision is the Claude hook's: the same dot-sourced pure helper
    worktree-poetry-venv-policy.ps1 and the same deny reason. The payload cwd is read from
    payload.cwd. This hook is a guard against a known foot-gun, not a security control.
    A parsed payload with no tool_input or no command allows. Empty or unparseable stdin
    follows the Codex convention for every registered PreToolUse handler: one stderr line
    beginning WORKTREE_VENV_BLOCKED: and exit 2. An allow writes nothing.

.NOTES
    Compatible with PowerShell 7+. Invokes no Poetry or Python command.
#>
[CmdletBinding()]
param()
$script:HookDependencyGuardLoadFailed = $false; try { . (Join-Path $PSScriptRoot 'hook-dependency-guard.ps1') } catch { $script:HookDependencyGuardLoadFailed = $true }

# Shared command-line segmenter (Read-CommandLineInvocationSegment), consumed by the helper.
try { . (Join-Path $PSScriptRoot 'hook-command-scanner.ps1') } catch { Add-HookDependencyFailure -Name 'hook-command-scanner.ps1' -ErrorRecord $_ }
try { . (Join-Path $PSScriptRoot 'hook-command-invocation.ps1') } catch { Add-HookDependencyFailure -Name 'hook-command-invocation.ps1' -ErrorRecord $_ }
try { . (Join-Path $PSScriptRoot 'worktree-poetry-venv-policy.ps1') } catch { Add-HookDependencyFailure -Name 'worktree-poetry-venv-policy.ps1' -ErrorRecord $_ }

function Get-WorktreePoetryVenvProcessValue {
    <#
    .SYNOPSIS
        Read VIRTUAL_ENV of the hook process. Tests inject the value instead (read seam).
    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param()

    return [string]$env:VIRTUAL_ENV
}

function Get-WorktreePoetryVenvPayloadValue {
    <#
    .SYNOPSIS
        Read a named property off a parsed JSON object, or $null when it is absent.
    .PARAMETER InputObject
        The parsed JSON value.
    .PARAMETER Name
        The property name.
    .OUTPUTS
        System.Object or $null
    #>
    [CmdletBinding()]
    param(
        [AllowNull()][object] $InputObject,
        [Parameter(Mandatory)][string] $Name
    )

    if ($InputObject -isnot [System.Management.Automation.PSCustomObject]) { return $null }
    $property = $InputObject.PSObject.Properties[$Name]
    if ($null -eq $property) { return $null }
    return $property.Value
}

function Invoke-WorktreePoetryVenvDecision {
    <#
    .SYNOPSIS
        Parse the Codex PreToolUse payload and return a deny decision, or $null to allow.
    .PARAMETER ToolInputRaw
        The raw Codex PreToolUse JSON payload.
    .PARAMETER VirtualEnv
        The VIRTUAL_ENV value. When omitted, the process value is read through the seam.
    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary or $null
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [AllowNull()][AllowEmptyString()][string] $ToolInputRaw,
        [AllowNull()][AllowEmptyString()][string] $VirtualEnv
    )
    $dependencyDecision = Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix 'WORKTREE_VENV_BLOCKED:'
    if ($null -ne $dependencyDecision) { return $dependencyDecision }

    if (-not $PSBoundParameters.ContainsKey('VirtualEnv')) { $VirtualEnv = Get-WorktreePoetryVenvProcessValue }
    if ([string]::IsNullOrWhiteSpace($ToolInputRaw)) { return $null }
    try { $payload = $ToolInputRaw | ConvertFrom-Json -ErrorAction Stop } catch { return $null }
    $toolInput = Get-WorktreePoetryVenvPayloadValue -InputObject $payload -Name 'tool_input'
    if ($null -eq $toolInput) { return $null }
    $commandText = [string](Get-WorktreePoetryVenvPayloadValue -InputObject $toolInput -Name 'command')
    $cwd = [string](Get-WorktreePoetryVenvPayloadValue -InputObject $payload -Name 'cwd')

    $reason = Get-WorktreePoetryVenvDenyReason -CommandText $commandText -Cwd $cwd -VirtualEnv $VirtualEnv
    if ($null -eq $reason) { return $null }
    return [ordered]@{
        hookSpecificOutput = [ordered]@{
            hookEventName            = 'PreToolUse'
            permissionDecision       = 'deny'
            permissionDecisionReason = $reason
        }
    }
}

function Assert-WorktreePoetryVenvPayloadText {
    <#
    .SYNOPSIS
        Throw when the Codex stdin text is empty or not JSON.
    .PARAMETER PayloadRaw
        The stdin text.
    #>
    [CmdletBinding()]
    param([AllowNull()][AllowEmptyString()][string] $PayloadRaw)

    if ([string]::IsNullOrWhiteSpace($PayloadRaw)) { throw 'enforce-worktree-poetry-venv hook input is empty.' }
    try { $null = $PayloadRaw | ConvertFrom-Json -ErrorAction Stop } catch { throw "enforce-worktree-poetry-venv hook input is malformed JSON: $_" }
}

# Allow dot-sourcing in tests without executing the entry point.
if ($MyInvocation.InvocationName -eq '.') {
    return
}
if ($script:HookDependencyGuardLoadFailed) { [Console]::Error.WriteLine('WORKTREE_VENV_BLOCKED: hook-dependency-guard.ps1 failed to load; the gate fails closed.'); exit 2 }
$dependencyDecision = Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix 'WORKTREE_VENV_BLOCKED:'
if ($null -ne $dependencyDecision) { $dependencyDecision | ConvertTo-Json -Compress -Depth 5 | Write-Output; exit 0 }

try {
    $payloadRaw = [Console]::In.ReadToEnd()
    Assert-WorktreePoetryVenvPayloadText -PayloadRaw $payloadRaw
    $decision = Invoke-WorktreePoetryVenvDecision -ToolInputRaw $payloadRaw
    if ($null -ne $decision) { $decision | ConvertTo-Json -Compress -Depth 5 | Write-Output }
    exit 0
} catch {
    [Console]::Error.WriteLine("WORKTREE_VENV_BLOCKED: $_")
    exit 2
}
