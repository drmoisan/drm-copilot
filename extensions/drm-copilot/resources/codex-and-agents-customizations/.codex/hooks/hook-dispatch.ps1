<#
.SYNOPSIS
    Codex PreToolUse dispatcher helpers (issue #1159): matcher, result normalization, decision
    combination, registry validation and the hook runner.

.DESCRIPTION
    Dot-sourced by .codex/hooks/invoke-pretooluse-dispatch.ps1. A destination repository may hold
    .codex without .claude, so these helpers are the Codex counterparts of
    .claude/lib/hook-dispatch/HookDispatch.psm1 and HookDispatchRunner.psm1 rather than imports of them.

    Matchers are regular expressions as written; apply_patch is also admitted by a matcher that
    admits Edit or Write. Combination: deny > defer > ask > allow > none, deny reasons joined in
    registry order by a line feed, additionalContext concatenated in registry order, the combined
    decision emitted as JSON (a deny as JSON too). Exit 2 is a deny with the stderr reason; any other
    non-zero exit code, invalid JSON or terminating error is no decision.

    With isolation 'in-process' each selected hook runs in this process in its own script scope with
    the payload replayed on stdin, [Console]::Out and [Console]::Error redirected to per-hook writers,
    $LASTEXITCODE set to a sentinel, and stdin, both writers and the location restored in 'finally'.
    With isolation 'per-process' (the default for a registry without the field) each hook starts as
    'pwsh -NoProfile -File <hook>' with the payload on stdin. Every selected hook runs.

.NOTES
    Imports no module and dot-sources no file. Writes to no output stream.
#>

$script:CodexHookDispatchReasonPrefix = 'HOOK_DISPATCH_BLOCKED:'
$script:CodexHookDispatchDecisionRank = @{ deny = 4; defer = 3; ask = 2; allow = 1 }
$script:CodexHookDispatchLeafPattern = '^[a-z0-9][a-z0-9.-]*\.ps1$'
$script:CodexHookDispatchExitSentinel = -1073741511

function Test-CodexHookDispatchMatcher {
    <#
    .SYNOPSIS
        Returns $true when a Codex PreToolUse group matcher admits a tool name.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()] [AllowEmptyString()] [string] $Matcher,
        [Parameter(Mandatory)] [AllowEmptyString()] [string] $ToolName
    )

    if ([string]::IsNullOrEmpty($Matcher) -or $Matcher -eq '*') { return $true }
    try {
        if ([regex]::IsMatch($ToolName, $Matcher)) { return $true }
        if ($ToolName -ceq 'apply_patch') { return ([regex]::IsMatch('Edit', $Matcher) -or [regex]::IsMatch('Write', $Matcher)) }
    } catch {
        return $false
    }
    return $false
}

function Get-CodexHookDispatchProperty {
    # Returns a property value of a parsed JSON object, or $null when the property is absent.
    param([AllowNull()] $Object, [Parameter(Mandatory)] [string] $Name)
    if ($null -eq $Object -or $Object -isnot [System.Management.Automation.PSCustomObject]) { return $null }
    if ($null -eq $Object.PSObject.Properties[$Name]) { return $null }
    return $Object.$Name
}

function Get-CodexHookDispatchToolName {
    <#
    .SYNOPSIS
        Returns the tool_name of a PreToolUse payload, or an empty string.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([AllowNull()] [AllowEmptyString()] [string] $PayloadText)

    if ([string]::IsNullOrWhiteSpace($PayloadText)) { return '' }
    try { $payload = $PayloadText | ConvertFrom-Json -ErrorAction Stop } catch { return '' }
    return [string](Get-CodexHookDispatchProperty -Object $payload -Name 'tool_name')
}

function ConvertTo-CodexHookDispatchResult {
    <#
    .SYNOPSIS
        Normalizes one hook's exit code, stdout and stderr into Decision, Reason, AdditionalContext and Error.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [int] $ExitCode,
        [AllowNull()] [AllowEmptyString()] [string] $Stdout,
        [AllowNull()] [AllowEmptyString()] [string] $Stderr,
        [switch] $TerminatingError
    )

    $result = [pscustomobject]@{ Decision = $null; Reason = $null; AdditionalContext = $null; Error = $null }
    if ($TerminatingError) { $result.Error = 'TerminatingError'; return $result }
    $outText = if ($null -eq $Stdout) { '' } else { $Stdout.Trim() }
    $parsed = $null; $isJson = $false
    if ($outText.Length -gt 0) {
        try { $parsed = $outText | ConvertFrom-Json -ErrorAction Stop; $isJson = $parsed -is [System.Management.Automation.PSCustomObject] } catch { $isJson = $false }
    }
    $specific = Get-CodexHookDispatchProperty -Object $parsed -Name 'hookSpecificOutput'
    $jsonReason = [string](Get-CodexHookDispatchProperty -Object $specific -Name 'permissionDecisionReason')
    if ([string]::IsNullOrEmpty($jsonReason)) { $jsonReason = [string](Get-CodexHookDispatchProperty -Object $parsed -Name 'reason') }

    if ($ExitCode -eq 2) {
        $errText = if ($null -eq $Stderr) { '' } else { $Stderr.Trim() }
        $result.Decision = 'deny'
        $result.Reason = if ($errText.Length -gt 0) { $errText } else { $jsonReason }
        return $result
    }
    if ($ExitCode -ne 0) { $result.Error = 'NonBlockingExit'; return $result }
    if ($outText.Length -eq 0) { return $result }
    if (-not $isJson) { $result.Error = 'InvalidJson'; return $result }

    $context = Get-CodexHookDispatchProperty -Object $specific -Name 'additionalContext'
    if (-not [string]::IsNullOrEmpty([string]$context)) { $result.AdditionalContext = [string]$context }
    $decision = [string](Get-CodexHookDispatchProperty -Object $specific -Name 'permissionDecision')
    if ([string]::IsNullOrEmpty($decision)) {
        $legacy = [string](Get-CodexHookDispatchProperty -Object $parsed -Name 'decision')
        $decision = switch ($legacy) { 'block' { 'deny' } 'approve' { 'allow' } default { '' } }
    }
    if ($script:CodexHookDispatchDecisionRank.ContainsKey($decision)) {
        $result.Decision = $decision
        if (-not [string]::IsNullOrEmpty($jsonReason)) { $result.Reason = $jsonReason }
    }
    return $result
}

function Join-CodexHookDispatchDecision {
    <#
    .SYNOPSIS
        Combines normalized per-hook results into one PreToolUse decision object, or $null.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([Parameter(Mandatory)] [AllowEmptyCollection()] [object[]] $Result)

    $strongest = $null
    foreach ($item in $Result) {
        if ([string]::IsNullOrEmpty($item.Decision)) { continue }
        if ($null -eq $strongest -or $script:CodexHookDispatchDecisionRank[$item.Decision] -gt $script:CodexHookDispatchDecisionRank[$strongest]) { $strongest = $item.Decision }
    }
    $contexts = @($Result | Where-Object { -not [string]::IsNullOrEmpty($_.AdditionalContext) } | ForEach-Object { $_.AdditionalContext })
    if ($null -eq $strongest -and $contexts.Count -eq 0) { return $null }

    $output = [ordered]@{ hookEventName = 'PreToolUse' }
    if ($null -ne $strongest) {
        $output['permissionDecision'] = $strongest
        $reasons = @($Result | Where-Object { $_.Decision -eq $strongest -and -not [string]::IsNullOrEmpty($_.Reason) } | ForEach-Object { $_.Reason })
        if ($reasons.Count -gt 0) { $output['permissionDecisionReason'] = $reasons -join "`n" }
    }
    if ($contexts.Count -gt 0) { $output['additionalContext'] = $contexts -join "`n" }
    return [ordered]@{ hookSpecificOutput = $output }
}

function Get-CodexHookDispatchBlockDecision {
    <#
    .SYNOPSIS
        Returns the fail-closed dispatcher deny decision with the HOOK_DISPATCH_BLOCKED: prefix.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([Parameter(Mandatory)] [string] $Detail)

    return [ordered]@{ hookSpecificOutput = [ordered]@{ hookEventName = 'PreToolUse'; permissionDecision = 'deny'; permissionDecisionReason = "$($script:CodexHookDispatchReasonPrefix) $Detail; the dispatcher fails closed." } }
}

function Get-CodexHookDispatchRegistryFailure {
    # The invalid-registry result: IsValid false and the fail-closed deny decision as Reason.
    param([Parameter(Mandatory)] [string] $Detail)
    return [pscustomobject]@{ IsValid = $false; Reason = (Get-CodexHookDispatchBlockDecision -Detail $Detail); Isolation = $null; Notes = @(); Groups = @() }
}

function Read-CodexHookDispatchRegistry {
    <#
    .SYNOPSIS
        Parses and validates the Codex dispatcher registry; see Read-HookDispatchRegistry for the schema.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowNull()] [AllowEmptyString()] [string] $RegistryText,
        [Parameter(Mandatory)] [string] $HooksDirectory,
        [scriptblock] $TestPath = { param([string] $Path) Test-Path -LiteralPath $Path -PathType Leaf }
    )

    if ([string]::IsNullOrWhiteSpace($RegistryText)) { return (Get-CodexHookDispatchRegistryFailure -Detail 'the registry pretooluse-dispatch.json is missing or unreadable') }
    try { $document = $RegistryText | ConvertFrom-Json -ErrorAction Stop } catch { return (Get-CodexHookDispatchRegistryFailure -Detail 'the registry pretooluse-dispatch.json is not valid JSON') }
    if ($document -isnot [System.Management.Automation.PSCustomObject]) { return (Get-CodexHookDispatchRegistryFailure -Detail 'the registry root is not an object') }
    $isolation = Get-CodexHookDispatchProperty -Object $document -Name 'isolation'
    if ($null -eq $isolation) { $isolation = 'per-process' }
    if (@('in-process', 'per-process') -cnotcontains [string]$isolation) { return (Get-CodexHookDispatchRegistryFailure -Detail "the registry isolation value '$isolation' is not in-process or per-process") }
    $notes = Get-CodexHookDispatchProperty -Object $document -Name 'notes'
    if ($null -ne $notes -and @($notes | Where-Object { $_ -isnot [string] }).Count -gt 0) { return (Get-CodexHookDispatchRegistryFailure -Detail 'the registry notes value is not an array of strings') }
    $groupsNode = Get-CodexHookDispatchProperty -Object (Get-CodexHookDispatchProperty -Object $document -Name 'hooks') -Name 'PreToolUse'
    if ($null -eq $groupsNode -or @($groupsNode).Count -eq 0) { return (Get-CodexHookDispatchRegistryFailure -Detail 'the registry has no hooks.PreToolUse groups') }

    $groups = [System.Collections.Generic.List[object]]::new()
    foreach ($group in @($groupsNode)) {
        if ($group -isnot [System.Management.Automation.PSCustomObject]) { return (Get-CodexHookDispatchRegistryFailure -Detail 'a registry group is not an object') }
        $matcher = Get-CodexHookDispatchProperty -Object $group -Name 'matcher'
        if ($null -ne $matcher -and $matcher -isnot [string]) { return (Get-CodexHookDispatchRegistryFailure -Detail 'a registry group matcher is not a string') }
        $hookNodes = @(Get-CodexHookDispatchProperty -Object $group -Name 'hooks' | Where-Object { $null -ne $_ })
        if ($hookNodes.Count -eq 0) { return (Get-CodexHookDispatchRegistryFailure -Detail 'a registry group lists no hooks') }
        $hooks = [System.Collections.Generic.List[object]]::new()
        foreach ($hook in $hookNodes) {
            $type = [string](Get-CodexHookDispatchProperty -Object $hook -Name 'type')
            $command = [string](Get-CodexHookDispatchProperty -Object $hook -Name 'command')
            if ($type -cne 'command' -or [string]::IsNullOrWhiteSpace($command)) { return (Get-CodexHookDispatchRegistryFailure -Detail 'a registry hook is not a command hook with a command') }
            $found = [regex]::Matches($command, '[^\s/\\"'']+\.ps1(?=["''\s]|$)')
            $leaf = if ($found.Count -gt 0) { $found[$found.Count - 1].Value } else { '' }
            if ($leaf -cnotmatch $script:CodexHookDispatchLeafPattern) { return (Get-CodexHookDispatchRegistryFailure -Detail "the registry hook command '$command' names no hooks-folder script") }
            $path = Join-Path -Path $HooksDirectory -ChildPath $leaf
            if (-not [bool](& $TestPath $path)) { return (Get-CodexHookDispatchRegistryFailure -Detail "the registry hook '$leaf' does not resolve to a file in the hooks folder") }
            $hooks.Add([pscustomobject]@{ Type = $type; Command = $command; Leaf = $leaf; Path = $path; Timeout = (Get-CodexHookDispatchProperty -Object $hook -Name 'timeout') })
        }
        $groups.Add([pscustomobject]@{ Matcher = [string]$matcher; Hooks = $hooks.ToArray() })
    }
    return [pscustomobject]@{ IsValid = $true; Reason = $null; Isolation = [string]$isolation; Notes = @($notes); Groups = $groups.ToArray() }
}

function Resolve-CodexHookDispatchScriptPath {
    <#
    .SYNOPSIS
        Returns the hooks-folder script path of one validated registry hook; the runner invokes only these paths.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)] [pscustomobject] $Hook)

    if ([string]$Hook.Leaf -cnotmatch $script:CodexHookDispatchLeafPattern) { throw "$($script:CodexHookDispatchReasonPrefix) the hook leaf '$($Hook.Leaf)' is not a hooks-folder script name." }
    return [string]$Hook.Path
}

function Invoke-CodexHookDispatchChildProcess {
    <#
    .SYNOPSIS
        Default process-starter seam: runs one hook as 'pwsh -NoProfile -File <path>' with the payload on stdin.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory)] [string] $Path, [Parameter(Mandatory)] [AllowEmptyString()] [string] $PayloadText)

    $info = [System.Diagnostics.ProcessStartInfo]::new('pwsh')
    foreach ($argument in @('-NoProfile', '-File', $Path)) { $info.ArgumentList.Add($argument) }
    $info.UseShellExecute = $false
    $info.RedirectStandardInput = $true; $info.RedirectStandardOutput = $true; $info.RedirectStandardError = $true
    $process = [System.Diagnostics.Process]::Start($info)
    try {
        $stdout = $process.StandardOutput.ReadToEndAsync(); $stderr = $process.StandardError.ReadToEndAsync()
        $process.StandardInput.Write($PayloadText); $process.StandardInput.Close()
        $process.WaitForExit()
        return [pscustomobject]@{ ExitCode = $process.ExitCode; Stdout = $stdout.Result; Stderr = $stderr.Result }
    } finally {
        $process.Dispose()
    }
}

function ConvertTo-CodexHookDispatchStreamText {
    # Splits captured stream records into stdout text (success, warning, information) and error text.
    param([AllowNull()] [object[]] $Record)
    $out = [System.Text.StringBuilder]::new(); $err = [System.Text.StringBuilder]::new()
    foreach ($item in @($Record)) {
        if ($null -eq $item) { continue }
        if ($item -is [System.Management.Automation.ErrorRecord]) { [void]$err.AppendLine([string]$item); continue }
        if ($item -is [System.Management.Automation.VerboseRecord] -or $item -is [System.Management.Automation.DebugRecord]) { continue }
        if ($item -is [System.Management.Automation.WarningRecord]) { [void]$out.AppendLine($item.Message); continue }
        if ($item -is [System.Management.Automation.InformationRecord]) { [void]$out.AppendLine([string]$item.MessageData); continue }
        [void]$out.AppendLine([string]$item)
    }
    return [pscustomobject]@{ Stdout = $out.ToString(); Stderr = $err.ToString() }
}

function Get-CodexHookDispatchModuleSnapshot {
    # Loaded module instances keyed by path and instance; a re-import yields a new key for the same path.
    $snapshot = @{}
    foreach ($module in @(Get-Module -All)) {
        if (-not [string]::IsNullOrEmpty($module.Path)) { $snapshot["$($module.Path)|$([System.Runtime.CompilerServices.RuntimeHelpers]::GetHashCode($module))"] = $module.Path }
    }
    return $snapshot
}

function Invoke-CodexHookDispatchRunner {
    <#
    .SYNOPSIS
        Runs every registry hook selected for the tool name and returns one result per hook.
    .PARAMETER InvokeScript
        Script-invoker seam (in-process); when omitted the runner invokes the resolved path with '&'.
    .PARAMETER ReplayInput
        Stdin-replayer seam (in-process).
    .PARAMETER StartProcess
        Process-starter seam (per-process); receives -Path and -PayloadText.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)] [AllowEmptyString()] [string] $PayloadText,
        [Parameter(Mandatory)] [pscustomobject] $Registry,
        [Parameter(Mandatory)] [AllowEmptyString()] [string] $ToolName,
        [scriptblock] $InvokeScript,
        [scriptblock] $ReplayInput = { param([string] $Text) [Console]::SetIn([System.IO.StringReader]::new($Text)) },
        [scriptblock] $StartProcess = { param([string] $Path, [string] $PayloadText) Invoke-CodexHookDispatchChildProcess -Path $Path -PayloadText $PayloadText }
    )

    $selected = foreach ($group in @($Registry.Groups)) {
        if (Test-CodexHookDispatchMatcher -Matcher $group.Matcher -ToolName $ToolName) { @($group.Hooks) }
    }
    foreach ($hook in @($selected)) {
        $hookScriptPath = Resolve-CodexHookDispatchScriptPath -Hook $hook
        $exitCode = 0; $stdout = ''; $stderr = ''; $terminating = $false; $loaded = @()
        if ($Registry.Isolation -ne 'in-process') {
            $child = & $StartProcess -Path $hookScriptPath -PayloadText $PayloadText
            $exitCode = [int]$child.ExitCode; $stdout = [string]$child.Stdout; $stderr = [string]$child.Stderr
        } else {
            $location = Get-Location
            $originalIn = [Console]::In; $originalOut = [Console]::Out; $originalError = [Console]::Error
            $outWriter = [System.IO.StringWriter]::new(); $errorWriter = [System.IO.StringWriter]::new()
            $before = Get-CodexHookDispatchModuleSnapshot
            $captured = @()
            try {
                & $ReplayInput $PayloadText
                [Console]::SetOut($outWriter)
                [Console]::SetError($errorWriter)
                Set-Variable -Name LASTEXITCODE -Scope Global -Value $script:CodexHookDispatchExitSentinel
                # A hook script expects the defaults of a fresh pwsh process.
                Set-StrictMode -Off
                $ErrorActionPreference = 'Continue'
                if ($null -ne $InvokeScript) {
                    $captured = @(& $InvokeScript $hookScriptPath *>&1)
                } else {
                    $captured = @(& $hookScriptPath *>&1)
                }
                $lastExit = Get-Variable -Name LASTEXITCODE -Scope Global -ValueOnly -ErrorAction SilentlyContinue
                $exitCode = if ($null -eq $lastExit -or $lastExit -eq $script:CodexHookDispatchExitSentinel) { 0 } else { [int]$lastExit }
            } catch {
                $terminating = $true
                $exitCode = 1
                $captured += $_
            } finally {
                [Console]::SetIn($originalIn)
                [Console]::SetOut($originalOut)
                [Console]::SetError($originalError)
                Set-Location -LiteralPath $location.ProviderPath
            }
            $after = Get-CodexHookDispatchModuleSnapshot
            $loaded = @($after.Keys | Where-Object { -not $before.ContainsKey($_) } | ForEach-Object { $after[$_] } | Sort-Object -Unique)
            $streams = ConvertTo-CodexHookDispatchStreamText -Record $captured
            $stdout = $outWriter.ToString() + $streams.Stdout
            $stderr = $errorWriter.ToString() + $streams.Stderr
        }
        $normalized = ConvertTo-CodexHookDispatchResult -ExitCode $exitCode -Stdout $stdout -Stderr $stderr -TerminatingError:$terminating
        [pscustomobject]@{
            Hook = $hook.Leaf; Command = $hook.Command; Isolation = $Registry.Isolation; ExitCode = $exitCode; Stdout = $stdout; Stderr = $stderr
            Decision = $normalized.Decision; Reason = $normalized.Reason; AdditionalContext = $normalized.AdditionalContext; Error = $normalized.Error; ModulesLoaded = [string[]]$loaded
        }
    }
}
