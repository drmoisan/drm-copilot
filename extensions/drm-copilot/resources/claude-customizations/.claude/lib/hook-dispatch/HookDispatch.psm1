<#
.SYNOPSIS
    Pure PreToolUse dispatcher logic for Claude Code (issue #1159): matcher evaluation, per-hook
    result normalization, decision combination and registry validation.

.DESCRIPTION
    The Claude dispatcher (.claude/hooks/invoke-pretooluse-dispatch.ps1) runs every hook that the
    registry .claude/hooks/pretooluse-dispatch.json selects for a tool name and emits one combined
    decision. This module holds the host-neutral parts of that work; the hook runner lives in
    HookDispatchRunner.psm1. No function here starts a process, reads the clock or touches the file
    system: the only file-system question (does a hook script exist) is answered by a caller-supplied
    [scriptblock] seam. The module loads no sibling module; any future load-time sibling import
    follows the library convention: the module imports its siblings with -ErrorAction Stop.

    Combination (spec D4): precedence deny > defer > ask > allow > none; deny reasons joined in
    registry order by a line feed; additionalContext values concatenated in registry order with a
    line feed; exit 2 is a deny with the stderr reason (or the JSON reason when stderr is empty);
    exit 0 with a JSON permissionDecision is that decision; exit 0 with empty stdout is no decision;
    any other exit code, invalid JSON or a terminating error is no decision.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:HookDispatchReasonPrefix = 'HOOK_DISPATCH_BLOCKED:'
$script:HookDispatchDecisionRank = @{ deny = 4; defer = 3; ask = 2; allow = 1 }
$script:HookDispatchLeafPattern = '^[a-z0-9][a-z0-9.-]*\.ps1$'

function Test-HookDispatchMatcher {
    <#
    .SYNOPSIS
        Returns $true when a Claude PreToolUse group matcher admits a tool name.
    .DESCRIPTION
        An empty matcher or '*' admits every tool. A matcher made only of letters, digits, '_', '-',
        space, ',' and '|' is an exact name or an exact list of names. Any other matcher is an
        unanchored regular expression.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()] [AllowEmptyString()] [string] $Matcher,
        [Parameter(Mandatory)] [AllowEmptyString()] [string] $ToolName
    )

    if ([string]::IsNullOrEmpty($Matcher) -or $Matcher -eq '*') { return $true }
    if ($Matcher -cmatch '^[A-Za-z0-9_\-, |]+$') {
        $names = @($Matcher -split '[|,]' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
        return ($names -ccontains $ToolName)
    }
    try {
        return [regex]::IsMatch($ToolName, $Matcher)
    } catch {
        return $false
    }
}

function Get-HookDispatchToolName {
    <#
    .SYNOPSIS
        Returns the tool_name of a PreToolUse payload, or an empty string when the payload has none.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([AllowNull()] [AllowEmptyString()] [string] $PayloadText)

    if ([string]::IsNullOrWhiteSpace($PayloadText)) { return '' }
    try {
        $payload = $PayloadText | ConvertFrom-Json -ErrorAction Stop
    } catch {
        return ''
    }
    if ($payload -isnot [System.Management.Automation.PSCustomObject] -or $null -eq $payload.PSObject.Properties['tool_name']) { return '' }
    return [string]$payload.tool_name
}

function Get-HookDispatchProperty {
    # Returns a property value of a parsed JSON object, or $null when the property is absent.
    param([AllowNull()] $Object, [Parameter(Mandatory)] [string] $Name)
    if ($null -eq $Object -or $Object -isnot [System.Management.Automation.PSCustomObject]) { return $null }
    if ($null -eq $Object.PSObject.Properties[$Name]) { return $null }
    return $Object.$Name
}

function ConvertTo-HookDispatchResult {
    <#
    .SYNOPSIS
        Normalizes one hook's exit code, stdout and stderr into a decision record.
    .OUTPUTS
        An object with Decision (deny, defer, ask, allow or $null), Reason, AdditionalContext and
        Error ($null, 'NonBlockingExit', 'InvalidJson' or 'TerminatingError').
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
    $parsed = $null
    $isJson = $false
    if ($outText.Length -gt 0) {
        try { $parsed = $outText | ConvertFrom-Json -ErrorAction Stop; $isJson = $parsed -is [System.Management.Automation.PSCustomObject] } catch { $isJson = $false }
    }
    $specific = Get-HookDispatchProperty -Object $parsed -Name 'hookSpecificOutput'
    $jsonReason = [string](Get-HookDispatchProperty -Object $specific -Name 'permissionDecisionReason')
    if ([string]::IsNullOrEmpty($jsonReason)) { $jsonReason = [string](Get-HookDispatchProperty -Object $parsed -Name 'reason') }

    if ($ExitCode -eq 2) {
        $errText = if ($null -eq $Stderr) { '' } else { $Stderr.Trim() }
        $result.Decision = 'deny'
        $result.Reason = if ($errText.Length -gt 0) { $errText } else { $jsonReason }
        return $result
    }
    if ($ExitCode -ne 0) { $result.Error = 'NonBlockingExit'; return $result }
    if ($outText.Length -eq 0) { return $result }
    if (-not $isJson) { $result.Error = 'InvalidJson'; return $result }

    $context = Get-HookDispatchProperty -Object $specific -Name 'additionalContext'
    if (-not [string]::IsNullOrEmpty([string]$context)) { $result.AdditionalContext = [string]$context }
    $decision = [string](Get-HookDispatchProperty -Object $specific -Name 'permissionDecision')
    if ([string]::IsNullOrEmpty($decision)) {
        $legacy = [string](Get-HookDispatchProperty -Object $parsed -Name 'decision')
        $decision = switch ($legacy) { 'block' { 'deny' } 'approve' { 'allow' } default { '' } }
    }
    if ($script:HookDispatchDecisionRank.ContainsKey($decision)) {
        $result.Decision = $decision
        if (-not [string]::IsNullOrEmpty($jsonReason)) { $result.Reason = $jsonReason }
    }
    return $result
}

function Join-HookDispatchDecision {
    <#
    .SYNOPSIS
        Combines normalized per-hook results into one PreToolUse decision object, or $null.
    .DESCRIPTION
        The strongest decision by deny > defer > ask > allow wins. The reasons of the results that
        carry the winning decision are joined in input (registry) order by a line feed, and every
        additionalContext value is concatenated in input order with a line feed. When no result
        carries a decision or a context, the function returns $null (emit nothing).
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([Parameter(Mandatory)] [AllowEmptyCollection()] [object[]] $Result)

    $strongest = $null
    foreach ($item in $Result) {
        if ([string]::IsNullOrEmpty($item.Decision)) { continue }
        if ($null -eq $strongest -or $script:HookDispatchDecisionRank[$item.Decision] -gt $script:HookDispatchDecisionRank[$strongest]) { $strongest = $item.Decision }
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

function Get-HookDispatchBlockDecision {
    <#
    .SYNOPSIS
        Returns the fail-closed dispatcher deny decision with the HOOK_DISPATCH_BLOCKED: prefix.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([Parameter(Mandatory)] [string] $Detail)

    return [ordered]@{
        hookSpecificOutput = [ordered]@{
            hookEventName            = 'PreToolUse'
            permissionDecision       = 'deny'
            permissionDecisionReason = "$($script:HookDispatchReasonPrefix) $Detail; the dispatcher fails closed."
        }
    }
}

function Get-HookDispatchCommandLeaf {
    # Returns the file name of the last .ps1 path named by a hook command, or an empty string.
    param([AllowNull()] [AllowEmptyString()] [string] $Command)
    if ([string]::IsNullOrEmpty($Command)) { return '' }
    $found = [regex]::Matches($Command, '[^\s/\\"'']+\.ps1(?=["''\s]|$)')
    if ($found.Count -eq 0) { return '' }
    return $found[$found.Count - 1].Value
}

function Get-HookDispatchRegistryFailure {
    # The invalid-registry result: IsValid false and the fail-closed deny decision as Reason.
    param([Parameter(Mandatory)] [string] $Detail)
    return [pscustomobject]@{ IsValid = $false; Reason = (Get-HookDispatchBlockDecision -Detail $Detail); Isolation = $null; Notes = @(); Groups = @() }
}

function Read-HookDispatchRegistry {
    <#
    .SYNOPSIS
        Parses and validates a dispatcher registry text.
    .DESCRIPTION
        Schema: { isolation?, notes?, hooks: { PreToolUse: [ { matcher?, hooks: [ { type, command } ] } ] } }.
        An absent isolation means per-process; a present value must be in-process or per-process.
        notes, when present, is an array of strings. Every hook needs type 'command' and a command
        whose script leaf matches ^[a-z0-9][a-z0-9.-]*\.ps1$ and exists in the hooks directory
        (asked through the TestPath seam). Codex fields command_windows and timeout are kept.
    .OUTPUTS
        An object with IsValid, Reason (the HOOK_DISPATCH_BLOCKED: deny decision when invalid),
        Isolation, Notes and Groups (Matcher and Hooks with Type, Command, Leaf, Path, Timeout).
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowNull()] [AllowEmptyString()] [string] $RegistryText,
        [Parameter(Mandatory)] [string] $HooksDirectory,
        [scriptblock] $TestPath = { param([string] $Path) Test-Path -LiteralPath $Path -PathType Leaf }
    )

    if ([string]::IsNullOrWhiteSpace($RegistryText)) { return (Get-HookDispatchRegistryFailure -Detail 'the registry pretooluse-dispatch.json is missing or unreadable') }
    try {
        $document = $RegistryText | ConvertFrom-Json -ErrorAction Stop
    } catch {
        return (Get-HookDispatchRegistryFailure -Detail 'the registry pretooluse-dispatch.json is not valid JSON')
    }
    if ($document -isnot [System.Management.Automation.PSCustomObject]) { return (Get-HookDispatchRegistryFailure -Detail 'the registry root is not an object') }

    $isolation = Get-HookDispatchProperty -Object $document -Name 'isolation'
    if ($null -eq $isolation) { $isolation = 'per-process' }
    if (@('in-process', 'per-process') -cnotcontains [string]$isolation) { return (Get-HookDispatchRegistryFailure -Detail "the registry isolation value '$isolation' is not in-process or per-process") }
    $notes = Get-HookDispatchProperty -Object $document -Name 'notes'
    if ($null -ne $notes -and @($notes | Where-Object { $_ -isnot [string] }).Count -gt 0) { return (Get-HookDispatchRegistryFailure -Detail 'the registry notes value is not an array of strings') }

    $groupsNode = Get-HookDispatchProperty -Object (Get-HookDispatchProperty -Object $document -Name 'hooks') -Name 'PreToolUse'
    if ($null -eq $groupsNode -or @($groupsNode).Count -eq 0) { return (Get-HookDispatchRegistryFailure -Detail 'the registry has no hooks.PreToolUse groups') }

    $groups = [System.Collections.Generic.List[object]]::new()
    foreach ($group in @($groupsNode)) {
        if ($group -isnot [System.Management.Automation.PSCustomObject]) { return (Get-HookDispatchRegistryFailure -Detail 'a registry group is not an object') }
        $matcher = Get-HookDispatchProperty -Object $group -Name 'matcher'
        if ($null -ne $matcher -and $matcher -isnot [string]) { return (Get-HookDispatchRegistryFailure -Detail 'a registry group matcher is not a string') }
        $hookNodes = @(Get-HookDispatchProperty -Object $group -Name 'hooks' | Where-Object { $null -ne $_ })
        if ($hookNodes.Count -eq 0) { return (Get-HookDispatchRegistryFailure -Detail 'a registry group lists no hooks') }
        $hooks = [System.Collections.Generic.List[object]]::new()
        foreach ($hook in $hookNodes) {
            $type = [string](Get-HookDispatchProperty -Object $hook -Name 'type')
            $command = [string](Get-HookDispatchProperty -Object $hook -Name 'command')
            if ($type -cne 'command' -or [string]::IsNullOrWhiteSpace($command)) { return (Get-HookDispatchRegistryFailure -Detail 'a registry hook is not a command hook with a command') }
            $leaf = Get-HookDispatchCommandLeaf -Command $command
            if ($leaf -cnotmatch $script:HookDispatchLeafPattern) { return (Get-HookDispatchRegistryFailure -Detail "the registry hook command '$command' names no hooks-folder script") }
            $path = Join-Path -Path $HooksDirectory -ChildPath $leaf
            if (-not [bool](& $TestPath $path)) { return (Get-HookDispatchRegistryFailure -Detail "the registry hook '$leaf' does not resolve to a file in the hooks folder") }
            $hooks.Add([pscustomobject]@{ Type = $type; Command = $command; Leaf = $leaf; Path = $path; Timeout = (Get-HookDispatchProperty -Object $hook -Name 'timeout') })
        }
        $groups.Add([pscustomobject]@{ Matcher = [string]$matcher; Hooks = $hooks.ToArray() })
    }
    return [pscustomobject]@{ IsValid = $true; Reason = $null; Isolation = [string]$isolation; Notes = @($notes); Groups = $groups.ToArray() }
}

function Resolve-HookDispatchScriptPath {
    <#
    .SYNOPSIS
        Returns the hooks-folder script path of one validated registry hook.
    .DESCRIPTION
        The path is the registry resolver's output: the hooks directory joined with the validated
        script leaf. The dispatcher runner invokes only paths returned by this function.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)] [pscustomobject] $Hook)

    if ([string]$Hook.Leaf -cnotmatch $script:HookDispatchLeafPattern) { throw "$($script:HookDispatchReasonPrefix) the hook leaf '$($Hook.Leaf)' is not a hooks-folder script name." }
    return [string]$Hook.Path
}

function Select-HookDispatchHook {
    <#
    .SYNOPSIS
        Returns the registry hooks whose group matcher admits the tool name, in registry order.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)] [pscustomobject] $Registry,
        [Parameter(Mandatory)] [AllowEmptyString()] [string] $ToolName
    )

    foreach ($group in @($Registry.Groups)) {
        if (-not (Test-HookDispatchMatcher -Matcher $group.Matcher -ToolName $ToolName)) { continue }
        foreach ($hook in @($group.Hooks)) { $hook }
    }
}

Export-ModuleMember -Function Test-HookDispatchMatcher, Get-HookDispatchToolName, ConvertTo-HookDispatchResult, Join-HookDispatchDecision, Get-HookDispatchBlockDecision, Read-HookDispatchRegistry, Resolve-HookDispatchScriptPath, Select-HookDispatchHook
