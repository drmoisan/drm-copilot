<#
.SYNOPSIS
    The single Claude Code PreToolUse registration: runs every registry hook that matches the tool
    name and emits one combined decision (issue #1159).

.DESCRIPTION
    Registered once in .claude/settings.json. The payload is read once through
    Read-ClaudeHookRawPayload (stdin, then the existing environment fallback) and no environment
    variable is written. The registry pretooluse-dispatch.json beside this script lists the hook
    groups in the settings shape; the groups whose matcher admits the tool name run in registry
    order through Invoke-HookDispatchRunner, every one of them even after a deny, and their results
    combine by deny > defer > ask > allow > none into one JSON decision at exit 0.

    A missing, unreadable or invalid registry, a payload without a tool name, or a failed module
    load is a deny whose reason starts with HOOK_DISPATCH_BLOCKED:. A failure to load
    hook-dependency-guard.ps1 writes the reason to stderr and exits 2.

.PARAMETER PerHookTrace
    Test aid: writes one JSON line per dispatched hook to stderr (hook, exit code, stdout, stderr,
    normalized decision, reason, additionalContext and the modules loaded or re-loaded while it ran).
#>
[CmdletBinding()]
param(
    [switch] $PerHookTrace
)
$script:HookDependencyGuardLoadFailed = $false; try { . (Join-Path $PSScriptRoot 'hook-dependency-guard.ps1') } catch { $script:HookDependencyGuardLoadFailed = $true }
try { Import-Module (Join-Path $PSScriptRoot '../lib/hook-payload/HookPayload.psm1') -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'HookPayload.psm1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/hook-dispatch/HookDispatch.psm1') -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'HookDispatch.psm1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/hook-dispatch/HookDispatchRunner.psm1') -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'HookDispatchRunner.psm1' -ErrorRecord $_ }

$script:PreToolUseDispatchRegistryPath = Join-Path $PSScriptRoot 'pretooluse-dispatch.json'
# The hooks directory the registry commands resolve against (beside this script).
$ScriptRoot = $PSScriptRoot

function Invoke-PreToolUseDispatchDecision {
    <#
    .SYNOPSIS
        Returns the combined decision object (or $null) for one payload; the per-hook results are
        added to ResultSink when one is supplied.
    .PARAMETER PayloadText
        The raw payload, already read once by the entry point.
    .PARAMETER RegistryText
        The registry JSON text, or $null when the registry could not be read.
    .PARAMETER ResultSink
        Optional list that receives one result object per dispatched hook, in registry order.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [AllowNull()] [AllowEmptyString()] [string] $PayloadText,
        [AllowNull()] [AllowEmptyString()] [string] $RegistryText,
        [AllowNull()] [System.Collections.Generic.List[object]] $ResultSink
    )
    $dependencyDecision = Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix 'HOOK_DISPATCH_BLOCKED:'
    if ($null -ne $dependencyDecision) { return $dependencyDecision }

    $registry = Read-HookDispatchRegistry -RegistryText $RegistryText -HooksDirectory $ScriptRoot
    if (-not $registry.IsValid) { return $registry.Reason }

    $toolName = Get-HookDispatchToolName -PayloadText $PayloadText
    if ([string]::IsNullOrEmpty($toolName)) {
        return (Get-HookDispatchBlockDecision -Detail 'the PreToolUse payload carries no tool_name, so no hook group can be selected')
    }

    $results = @(Invoke-HookDispatchRunner -PayloadText $PayloadText -Registry $registry -ToolName $toolName)
    if ($null -ne $ResultSink) { foreach ($item in $results) { $ResultSink.Add($item) } }
    return (Join-HookDispatchDecision -Result $results)
}

function Invoke-PreToolUseDispatchEntryPoint {
    <#
    .SYNOPSIS
        Reads the payload once, dispatches, and returns the decision JSON lines followed by the exit code.
    .PARAMETER ReadPayload
        Payload seam; the default is one Read-ClaudeHookRawPayload call.
    .PARAMETER ReadRegistry
        Registry reader seam; returns the registry text or $null.
    .PARAMETER WriteTrace
        Trace writer seam used with -PerHookTrace; the default writes to [Console]::Error.
    .OUTPUTS
        The compact decision JSON (when there is a decision) and then the [int] exit code 0.
    #>
    [CmdletBinding()]
    [OutputType([string], [int])]
    param(
        [scriptblock] $ReadPayload = { Read-ClaudeHookRawPayload },
        [scriptblock] $ReadRegistry = { if (Test-Path -LiteralPath $script:PreToolUseDispatchRegistryPath -PathType Leaf) { Get-Content -LiteralPath $script:PreToolUseDispatchRegistryPath -Raw } else { $null } },
        [switch] $PerHookTrace,
        [scriptblock] $WriteTrace = { param([string] $Line) [Console]::Error.WriteLine($Line) }
    )

    $payloadText = [string](& $ReadPayload)
    $registryText = $null
    try { $registryText = & $ReadRegistry } catch { $registryText = $null }
    $results = [System.Collections.Generic.List[object]]::new()
    $decision = Invoke-PreToolUseDispatchDecision -PayloadText $payloadText -RegistryText $registryText -ResultSink $results
    if ($PerHookTrace) {
        foreach ($item in $results) {
            $trace = [ordered]@{ hook = $item.Hook; exitCode = $item.ExitCode; stdout = $item.Stdout; stderr = $item.Stderr; decision = $item.Decision; reason = $item.Reason; additionalContext = $item.AdditionalContext; error = $item.Error; modulesLoaded = @($item.ModulesLoaded) }
            & $WriteTrace ($trace | ConvertTo-Json -Compress -Depth 5)
        }
    }
    if ($null -ne $decision) { $decision | ConvertTo-Json -Compress -Depth 5 }
    return 0
}

# Guard allows dot-sourcing in tests without executing the entrypoint.
if ($MyInvocation.InvocationName -eq '.') {
    return
}
if ($script:HookDependencyGuardLoadFailed) { [Console]::Error.WriteLine('HOOK_DISPATCH_BLOCKED: hook-dependency-guard.ps1 failed to load; the gate fails closed.'); exit 2 }
$dependencyDecision = Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix 'HOOK_DISPATCH_BLOCKED:'
if ($null -ne $dependencyDecision) { $dependencyDecision | ConvertTo-Json -Compress -Depth 5 | Write-Output; exit 0 }

# The entry point returns its [int] exit code as the last pipeline element and the
# decision JSON before it, so the decision is written explicitly before the exit.
$entryPointResult = @(Invoke-PreToolUseDispatchEntryPoint -PerHookTrace:$PerHookTrace)
if ($entryPointResult.Count -gt 1) {
    $entryPointResult[0..($entryPointResult.Count - 2)] | Write-Output
}

exit ([int]$entryPointResult[-1])
