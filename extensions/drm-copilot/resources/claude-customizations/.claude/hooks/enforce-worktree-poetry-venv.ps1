<#
.SYNOPSIS
    Pre-tool-use hook that denies mutating Poetry commands aimed at an outside VIRTUAL_ENV.

.DESCRIPTION
    Invoked by the Claude Code PreToolUse hook on the "Bash" matcher (issue #1127). Poetry
    honors an inherited VIRTUAL_ENV over the in-project poetry.toml, so poetry install,
    sync, add, remove, or update run in an agent worktree writes into the main checkout's
    environment when the session exported VIRTUAL_ENV for that checkout. This hook denies
    such a command before it runs and names the legitimate path: run
    env -u VIRTUAL_ENV poetry install from the worktree root.

    The deny conditions, target-directory resolution, and path comparison live in the
    dot-sourced pure helper worktree-poetry-venv-policy.ps1. The VIRTUAL_ENV value is read
    through the seam Get-WorktreePoetryVenvProcessValue, and the payload cwd through
    Get-ClaudeHookEnvelopeValue.

    This hook is a guard against a known foot-gun, not a security control. An unparseable
    or malformed payload therefore fails open: the hook writes nothing and exits 0. An allow
    writes nothing as well, because an emitted allow decision would bypass the permission
    prompt for every Bash call. A dependency load failure denies through the standard
    hook-dependency guard.

.NOTES
    Compatible with PowerShell 7+. Invokes no Poetry or Python command.
#>
[CmdletBinding()]
param()
$script:HookDependencyGuardLoadFailed = $false; try { . (Join-Path $PSScriptRoot 'hook-dependency-guard.ps1') } catch { $script:HookDependencyGuardLoadFailed = $true }

try { Import-Module (Join-Path $PSScriptRoot '../lib/hook-payload/HookPayload.psm1') -Force -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'HookPayload.psm1' -ErrorRecord $_ }
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

function Invoke-WorktreePoetryVenvDecision {
    <#
    .SYNOPSIS
        Parse the PreToolUse payload and return a deny decision, or $null to allow.
    .PARAMETER ToolInputRaw
        The raw PreToolUse JSON envelope.
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
    $toolInput = Get-ClaudeHookEnvelopeValue -Envelope $payload -Name 'tool_input'
    if ($null -eq $toolInput) { return $null }
    $commandText = [string](Get-ClaudeHookEnvelopeValue -Envelope $toolInput -Name 'command')
    $cwd = [string](Get-ClaudeHookEnvelopeValue -Envelope $payload -Name 'cwd')

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

function Invoke-WorktreePoetryVenvEntryPoint {
    <#
    .SYNOPSIS
        Read the payload and return the deny JSON text, or $null to allow.
    .PARAMETER ReadPayload
        Seam for the payload read. Default is Read-ClaudeHookRawPayload (stdin first).
    .PARAMETER VirtualEnv
        Optional VIRTUAL_ENV value passed to the decision.
    .OUTPUTS
        System.String or $null
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [scriptblock] $ReadPayload = { Read-ClaudeHookRawPayload },
        [AllowNull()][AllowEmptyString()][string] $VirtualEnv
    )

    $decisionArguments = @{ ToolInputRaw = [string](& $ReadPayload) }
    if ($PSBoundParameters.ContainsKey('VirtualEnv')) { $decisionArguments['VirtualEnv'] = $VirtualEnv }
    $decision = Invoke-WorktreePoetryVenvDecision @decisionArguments
    if ($null -eq $decision) { return $null }
    return ($decision | ConvertTo-Json -Compress -Depth 5)
}

# Allow dot-sourcing in tests without executing the entry point.
if ($MyInvocation.InvocationName -eq '.') {
    return
}
if ($script:HookDependencyGuardLoadFailed) { [Console]::Error.WriteLine('WORKTREE_VENV_BLOCKED: hook-dependency-guard.ps1 failed to load; the gate fails closed.'); exit 2 }
$dependencyDecision = Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix 'WORKTREE_VENV_BLOCKED:'
if ($null -ne $dependencyDecision) { $dependencyDecision | ConvertTo-Json -Compress -Depth 5 | Write-Output; exit 0 }

$denyJson = Invoke-WorktreePoetryVenvEntryPoint
if ($null -ne $denyJson) { $denyJson | Write-Output }
exit 0
