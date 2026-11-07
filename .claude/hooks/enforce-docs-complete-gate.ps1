<#
.SYNOPSIS
    Pre-tool-use hook that gates the epic integration-to-main merge behind a passing
    docs-complete validation receipt, when a documentation profile enables the gate.

.DESCRIPTION
    Invoked by the Claude Code PreToolUse hook on the "Bash" matcher. The gate is opt-in: with
    no profile at docs/documentation-estate/docs-profile.json, or a profile whose
    completion_gates.integration_pr_gate.enabled is not true, every command is allowed and no
    gh call is made.

    Decision order (Invoke-DocsCompleteGateDecision):
      1. A failed guarded import denies (Get-HookDependencyFailureDecision); an envelope anomaly
         denies.
      2. No command, or a command outside the merge and enqueue scope of
         Test-EpicMergeGateCommandInScope, allows with no I/O.
      3. The profile is read through Get-DocsCompleteGateFileText under the root from
         Get-DocsCompleteGateRepositoryRoot. Absent or disabled allows; a profile that cannot be
         read or parsed denies PROFILE_UNREADABLE.
      4. Get-DocsCompleteGateMergeTarget binds the command to one pull request; a target it
         cannot resolve denies PR_UNRESOLVED with no gh call. One bounded gh pr view [<selector>]
         [--repo <value>] --json baseRefName,headRefName,headRefOid then runs through
         Invoke-DocsOnlyGhExe. A failed, throwing or unreadable lookup denies PR_UNRESOLVED; a
         --match-head-commit value other than headRefOid denies MATCH_HEAD_MISMATCH.
      5. A pull request that is not an epic integration branch merging into main allows.
      6. The receipt path (RECEIPT_PATH_INVALID) and the receipt at that path are checked
         against headRefOid with Test-DocsCompleteGateReceipt; a failing reason denies. A receipt
         that exists but cannot be read denies RECEIPT_UNREADABLE.

    Every deny reason reads DOCS_COMPLETE_GATE_BLOCKED: <REASON_CODE>: <reason and remediation>.
    The head revision is always the pull request headRefOid and never the local HEAD, because
    the session worktree may hold a different commit than the pull request head.

    Residual limits: the profile and receipt are read from the local working tree; an ambient
    GH_REPO or GH_HOST and a directory change made by an earlier Bash call are not visible in
    the command text; a gh alias is not visible; Test-EpicMergeGateCommandInScope does not admit
    a mutation supplied from a file, a merge endpoint whose number is a variable, or an unquoted
    {owner} endpoint; a GET on the merge endpoint is treated as a merge; a push after the lookup
    is not observed unless --match-head-commit is passed; a direct git push to main is outside
    gh scope. This is a policy-level control, not a cryptographic one.

.NOTES
    Issue #1034. Compatible with PowerShell 7+. Filesystem reads and the repository root go
    through injectable seams so tests can mock the boundary without temporary files. A failed
    guarded import returns the standard dependency-failure deny.
#>
[CmdletBinding()]
param()
$script:HookDependencyGuardLoadFailed = $false; try { . (Join-Path $PSScriptRoot 'hook-dependency-guard.ps1') } catch { $script:HookDependencyGuardLoadFailed = $true }

try { Import-Module (Join-Path $PSScriptRoot '../lib/hook-payload/HookPayload.psm1') -Force -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'HookPayload.psm1' -ErrorRecord $_ }
# Pure gate predicates: profile switch, receipt path, integration target, receipt check.
try { Import-Module (Join-Path $PSScriptRoot '../lib/docs/DocsCompleteGate.psm1') -Force -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DocsCompleteGate.psm1' -ErrorRecord $_ }
# Shared command-line parser and structural invocation matcher (issues #545 and #952).
try { . (Join-Path $PSScriptRoot 'hook-command-scanner.ps1') } catch { Add-HookDependencyFailure -Name 'hook-command-scanner.ps1' -ErrorRecord $_ }
try { . (Join-Path $PSScriptRoot 'hook-command-invocation.ps1') } catch { Add-HookDependencyFailure -Name 'hook-command-invocation.ps1' -ErrorRecord $_ }
# Merge and enqueue scope predicate, its two match predicates and the value-flag table (issue #952).
try { . (Join-Path $PSScriptRoot 'enforce-epic-merge-gate-command.ps1') } catch { Add-HookDependencyFailure -Name 'enforce-epic-merge-gate-command.ps1' -ErrorRecord $_ }
# Bounded gh seam Invoke-DocsOnlyGhExe (issue #927).
try { . (Join-Path $PSScriptRoot 'hook-docs-only-diff.ps1') } catch { Add-HookDependencyFailure -Name 'hook-docs-only-diff.ps1' -ErrorRecord $_ }

$script:DocsCompleteGatePrefix = 'DOCS_COMPLETE_GATE_BLOCKED:'
$script:DocsCompleteGateProfilePath = 'docs/documentation-estate/docs-profile.json'

function Get-DocsCompleteGateAllowDecision {
    <#
    .SYNOPSIS
        Returns the PreToolUse allow decision (the shape of the epic merge gate allow decision).
    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param()

    return [ordered]@{
        hookSpecificOutput = [ordered]@{
            hookEventName      = 'PreToolUse'
            permissionDecision = 'allow'
        }
    }
}

function Get-DocsCompleteGateBlockDecision {
    <#
    .SYNOPSIS
        Returns the PreToolUse deny decision whose reason is DOCS_COMPLETE_GATE_BLOCKED: <Code>: <Message>.
    .PARAMETER Code
        The reason code.
    .PARAMETER Message
        The one-sentence reason and remediation.
    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory)] [string] $Code,
        [Parameter(Mandatory)] [string] $Message
    )

    return [ordered]@{
        hookSpecificOutput = [ordered]@{
            hookEventName            = 'PreToolUse'
            permissionDecision       = 'deny'
            permissionDecisionReason = "$($script:DocsCompleteGatePrefix) ${Code}: $Message"
        }
    }
}

function Get-DocsCompleteGateRepositoryRoot {
    <#
    .SYNOPSIS
        Root seam: the repository root that holds this hook (two levels above .claude/hooks).
    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param()

    # The two-level Split-Path chain is the repository-root form that the pack-manifest
    # dependency-closure scanner recognizes as a non-dependency; a Join-Path child of
    # '../..' would be read as a dependency on the bundle root.
    return (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
}

function Get-DocsCompleteGateFileText {
    <#
    .SYNOPSIS
        File seam: returns the UTF-8 text of a file, or $null when the file does not exist.
    .DESCRIPTION
        Only a missing file or a missing parent directory means absent. Every other failure, such
        as a locked file or a directory at the path, propagates so the caller can deny: an
        existing file that cannot be read is never reported as absent.
    .PARAMETER Path
        The full path of the file.
    .OUTPUTS
        System.String or $null
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)] [string] $Path)

    try {
        return [System.IO.File]::ReadAllText($Path, [System.Text.UTF8Encoding]::new($false))
    } catch [System.IO.FileNotFoundException] {
        return $null
    } catch [System.IO.DirectoryNotFoundException] {
        return $null
    }
}

function Read-DocsCompleteGateMergeOperand {
    <#
    .SYNOPSIS
        Reads the selector, repository values and head pin of one gh pr merge record.
    .DESCRIPTION
        Walks the tokens with a closed flag table and returns @{ Readable; Selector; Repository;
        MatchHeadCommit }. A flag outside the table, a value flag with no value, more than one
        selector, and a dash-led or non-literal selector are unreadable. Redirection tokens are
        not operands. A short cluster is read letter by letter; a value letter takes the rest
        of the token, without one leading '=', or the next token.
    .PARAMETER Token
        The record tokens.
    .PARAMETER StartIndex
        The position just past the subcommand path.
    .OUTPUTS
        System.Collections.Hashtable
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)] [AllowEmptyCollection()] [AllowEmptyString()] [string[]] $Token,
        [Parameter(Mandatory)] [int] $StartIndex
    )

    $standalone = @('--merge', '-m', '--squash', '-s', '--rebase', '-r', '-d', '--delete-branch', '--auto', '--admin', '--disable-auto', '--help', '-h')
    $unreadable = @{ Readable = $false; Selector = $null; Repository = @(); MatchHeadCommit = $null }
    $positional = [System.Collections.Generic.List[string]]::new()
    $repository = [System.Collections.Generic.List[string]]::new()
    $pin = $null
    $afterSeparator = $false
    $index = $StartIndex
    while ($index -lt $Token.Count) {
        $current = $Token[$index]
        if ($current -match '^(<|>|\d*>|&>)') {
            $index += if ($current -match '^(\d*[<>]{1,2}&?|&>{1,2})$') { 2 } else { 1 }
            continue
        }
        $index++
        if ($afterSeparator -or -not $current.StartsWith('-') -or $current -ceq '-') { $positional.Add($current); continue }
        if ($current -ceq '--') { $afterSeparator = $true; continue }

        $name = Get-EpicMergeGateFlagName -Token $current
        $value = if ($name.Length -lt $current.Length) { $current.Substring($name.Length + 1) } else { $null }
        if (-not $current.StartsWith('--')) {
            $name = $null
            $value = $null
            for ($position = 1; $position -lt $current.Length -and $null -eq $name; $position++) {
                $letter = "-$($current[$position])"
                if ($script:EpicMergeGateValueFlags -ccontains $letter) {
                    $name = $letter
                    if ($position + 1 -lt $current.Length) { $value = $current.Substring($position + 1) -replace '^=', '' }
                } elseif ($standalone -cnotcontains $letter) {
                    return $unreadable
                }
            }
            if ($null -eq $name) { continue }
        }
        if ($standalone -ccontains $name) {
            if ($name -ceq '--merge' -and $null -ne (ConvertFrom-EpicMergeGateSelector -Selector ([string] $value))) { $positional.Add($value) }
            continue
        }
        if ($script:EpicMergeGateValueFlags -cnotcontains $name) { return $unreadable }
        if ($null -eq $value) {
            if ($index -ge $Token.Count) { return $unreadable }
            $value = $Token[$index]
            $index++
        }
        if ($name -ceq '-R' -or $name -ceq '--repo') { $repository.Add($value) }
        if ($name -ceq '--match-head-commit') { $pin = $value }
    }

    if ($positional.Count -gt 1) { return $unreadable }
    $selector = if ($positional.Count -eq 1) { $positional[0] } else { $null }
    if ($null -ne $selector -and ($selector.Length -eq 0 -or $selector.StartsWith('-') -or -not (Test-CommandLineTokenLiteral -Token $selector))) { return $unreadable }
    return @{ Readable = $true; Selector = $selector; Repository = $repository.ToArray(); MatchHeadCommit = $pin }
}

function Read-DocsCompleteGateApiTarget {
    <#
    .SYNOPSIS
        Reads the pull request and repository of one gated gh api record.
    .DESCRIPTION
        Readable only for exactly one anchored repos/<owner>/<repo>/pulls/<n>/merge token, with an
        optional leading slash; {owner} and {repo} placeholders mean the local repository. A
        GraphQL mutation names a node identifier with no selector, so it is unreadable, as are
        --hostname and any other token that names a merge path.
    .PARAMETER Token
        The record tokens.
    .PARAMETER StartIndex
        The position just past the api subcommand.
    .OUTPUTS
        System.Collections.Hashtable
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)] [AllowEmptyCollection()] [AllowEmptyString()] [string[]] $Token,
        [Parameter(Mandatory)] [int] $StartIndex
    )

    $unreadable = @{ Readable = $false; Selector = $null; Repository = @(); MatchHeadCommit = $null }
    $endpoints = [System.Collections.Generic.List[string]]::new()
    for ($index = $StartIndex; $index -lt $Token.Count; $index++) {
        $current = $Token[$index]
        if ($current -ceq 'graphql' -or (Get-EpicMergeGateFlagName -Token $current) -ceq '--hostname') { return $unreadable }
        if ($current -match $script:EpicMergeGateRestMergePattern) { $endpoints.Add($current) }
    }
    if ($endpoints.Count -ne 1) { return $unreadable }
    $endpoint = [regex]::Match($endpoints[0], '^/?repos/([^/]+)/([^/]+)/pulls/(\d+)/merge$')
    if (-not $endpoint.Success) { return $unreadable }
    $owner = $endpoint.Groups[1].Value
    $name = $endpoint.Groups[2].Value
    $repository = if ($owner -ceq '{owner}' -and $name -ceq '{repo}') { @() } else { @("$owner/$name") }
    return @{ Readable = $true; Selector = $endpoint.Groups[3].Value; Repository = $repository; MatchHeadCommit = $null }
}

function Test-DocsCompleteGateContextChange {
    <#
    .SYNOPSIS
        Reports whether the command visibly changes the directory or the gh repository context.
    .DESCRIPTION
        True for a cd, pushd, chdir, Set-Location, Push-Location or sl command, and for a GH_REPO
        or GH_HOST assignment, in any record of the command.
    .PARAMETER CommandText
        The Bash command text.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory)] [string] $CommandText)

    $changers = @('cd', 'pushd', 'chdir', 'set-location', 'push-location', 'sl')
    foreach ($record in @(Read-CommandLineInvocationSegment -CommandText $CommandText)) {
        $tokens = [string[]]@($record.Tokens)
        if (@($tokens -match '^GH_(?:REPO|HOST)=').Count -gt 0) { return $true }
        $start = (Skip-CommandLineTransparentWrapper -Token $tokens).Index
        if ($start -lt $tokens.Count -and $changers -contains (ConvertTo-CommandLineLeafWord -Word $tokens[$start])) { return $true }
    }
    return $false
}

function Get-DocsCompleteGateMergeTarget {
    <#
    .SYNOPSIS
        Binds a gated command to the pull request it merges.
    .DESCRIPTION
        Collects the gated invocations with the two loops of Test-EpicMergeGateCommandInScope, so
        a --disable-auto-only or ungated sibling does not count. Returns @{ Reason; Message;
        Selector; Repository; MatchHeadCommit }. Reason is $null when exactly one Structural,
        non-injected invocation has readable operands, one OWNER/REPO or HOST/OWNER/REPO value at
        most, and no visible context change (a URL selector names its own repository); every
        other case is PR_UNRESOLVED, and no gh call is made.
    .PARAMETER CommandText
        The Bash command text.
    .OUTPUTS
        System.Collections.Hashtable
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory)] [string] $CommandText)

    $unresolved = @{ Reason = 'PR_UNRESOLVED'; Message = 'The command does not name one pull request the gate can resolve; the gate fails closed. Run one literal gh pr merge with its selector and repository, with no directory or GH_REPO change in the command.'; Selector = $null; Repository = $null; MatchHeadCommit = $null }
    $gated = [System.Collections.Generic.List[pscustomobject]]::new()
    foreach ($match in @(Get-CommandLineInvocation -CommandText $CommandText -CommandWord 'gh' -SubcommandPath @('pr', 'merge'))) {
        if ($match.Status -ne 'Structural' -or -not (Test-EpicMergeGateDisableAutoOnly -Match $match)) { $gated.Add($match) }
    }
    $mergeCount = $gated.Count
    foreach ($match in @(Get-CommandLineInvocation -CommandText $CommandText -CommandWord 'gh' -SubcommandPath @('api'))) {
        if (Test-EpicMergeGateApiMutationText -Text (@($match.Segment.Tokens) -join ' ')) { $gated.Add($match) }
    }
    if ($gated.Count -ne 1 -or $gated[0].Status -ne 'Structural' -or $gated[0].Segment.ArgumentInjected) { return $unresolved }

    $tokens = [string[]]@($gated[0].Segment.Tokens)
    $operand = if ($mergeCount -eq 1) {
        Read-DocsCompleteGateMergeOperand -Token $tokens -StartIndex $gated[0].OperandIndex
    } else {
        Read-DocsCompleteGateApiTarget -Token $tokens -StartIndex $gated[0].OperandIndex
    }
    if (-not $operand.Readable) { return $unresolved }

    $repositories = @(@(@($gated[0].GlobalOptions | ForEach-Object { [string] $_.Value }) + @($operand.Repository)) | Select-Object -Unique)
    if ($repositories.Count -gt 1 -or ($repositories.Count -eq 1 -and $repositories[0] -cnotmatch '^[\w.-]+/[\w.-]+(?:/[\w.-]+)?$')) { return $unresolved }
    if ([string] $operand.Selector -notmatch '^https?://' -and (Test-DocsCompleteGateContextChange -CommandText $CommandText)) { return $unresolved }
    $repository = if ($repositories.Count -eq 1) { $repositories[0] } else { $null }
    return @{ Reason = $null; Message = $null; Selector = $operand.Selector; Repository = $repository; MatchHeadCommit = $operand.MatchHeadCommit }
}

function Get-DocsCompleteGatePullRequest {
    <#
    .SYNOPSIS
        Looks up the pull request base, head branch and head revision through the gh seam.
    .DESCRIPTION
        Returns @{ Reason; Message; BaseRefName; HeadRefName; HeadRefOid }. Reason is $null on
        success, PR_UNRESOLVED when gh fails or returns no readable pull request with a full
        lowercase head revision, and MATCH_HEAD_MISMATCH when the target --match-head-commit
        value differs from headRefOid.
    .PARAMETER Target
        The resolved target from Get-DocsCompleteGateMergeTarget.
    .PARAMETER RepositoryRoot
        The directory gh runs in.
    .OUTPUTS
        System.Collections.Hashtable
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)] [hashtable] $Target,
        [Parameter(Mandatory)] [string] $RepositoryRoot
    )

    $ghArgs = [System.Collections.Generic.List[string]]::new()
    $ghArgs.AddRange([string[]]@('pr', 'view'))
    if ($null -ne $Target.Selector) { $ghArgs.Add([string] $Target.Selector) }
    if ($null -ne $Target.Repository) { $ghArgs.AddRange([string[]]@('--repo', [string] $Target.Repository)) }
    $ghArgs.AddRange([string[]]@('--json', 'baseRefName,headRefName,headRefOid'))
    $unresolved = @{ Reason = 'PR_UNRESOLVED'; Message = 'gh pr view did not return a readable pull request with a full head revision; the gate fails closed. Check gh authentication and the pull request selector.'; BaseRefName = $null; HeadRefName = $null; HeadRefOid = $null }
    try { $lookup = Invoke-DocsOnlyGhExe -WorkingRoot $RepositoryRoot -GhArgs $ghArgs.ToArray() } catch { return $unresolved }
    $pr = $null
    if ($null -ne $lookup -and $lookup.ExitCode -eq 0) {
        try { $pr = ConvertFrom-Json -InputObject ([string] $lookup.Output) -ErrorAction Stop } catch { $pr = $null }
    }
    if ($pr -isnot [System.Management.Automation.PSCustomObject]) { return $unresolved }
    $names = @($pr.PSObject.Properties.Name)
    if ($names -notcontains 'headRefOid' -or $names -notcontains 'baseRefName' -or $names -notcontains 'headRefName') { return $unresolved }
    $head = [string] $pr.headRefOid
    if ($head -cnotmatch '^(?:[0-9a-f]{40}|[0-9a-f]{64})$') { return $unresolved }
    $pinned = $Target.MatchHeadCommit
    if ($null -ne $pinned -and -not [string]::Equals([string] $pinned, $head, [System.StringComparison]::Ordinal)) {
        return @{ Reason = 'MATCH_HEAD_MISMATCH'; Message = "--match-head-commit '$pinned' does not equal the pull request head revision '$head'; pass the current head revision."; BaseRefName = $null; HeadRefName = $null; HeadRefOid = $null }
    }
    return @{ Reason = $null; Message = $null; BaseRefName = [string] $pr.baseRefName; HeadRefName = [string] $pr.headRefName; HeadRefOid = $head }
}

function Invoke-DocsCompleteGateDecision {
    <#
    .SYNOPSIS
        Parses the PreToolUse envelope and returns an allow-or-block decision.
    .DESCRIPTION
        Envelope-level anomalies fail closed as a deny. Property-level absence of command inside
        a well-formed tool_input allows, because that is the scope filter. See the script help
        for the full decision order.
    .PARAMETER ToolInputRaw
        The raw JSON hook payload acquired by Read-ClaudeHookRawPayload.
    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        [string] $ToolInputRaw
    )

    $dependencyDecision = Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix 'DOCS_COMPLETE_GATE_BLOCKED:'
    if ($null -ne $dependencyDecision) { return $dependencyDecision }

    $payload = Resolve-ClaudeHookToolInput -Raw $ToolInputRaw
    if (-not $payload.IsValid) {
        return Get-DocsCompleteGateBlockDecision -Code 'PAYLOAD_ANOMALY' -Message ((Get-ClaudeHookPayloadAnomalyReason -Anomaly $payload.Anomaly) + '. The gate fails closed on an envelope it cannot read.')
    }

    $commandText = Get-ClaudeHookToolInputString -ToolInput $payload.Value -Name 'command'
    if (-not $commandText) { return Get-DocsCompleteGateAllowDecision }
    if (-not (Test-EpicMergeGateCommandInScope -CommandText $commandText)) { return Get-DocsCompleteGateAllowDecision }

    $root = Get-DocsCompleteGateRepositoryRoot
    try {
        $profileText = Get-DocsCompleteGateFileText -Path (Join-Path -Path $root -ChildPath $script:DocsCompleteGateProfilePath)
    } catch {
        return Get-DocsCompleteGateBlockDecision -Code 'PROFILE_UNREADABLE' -Message "The documentation profile exists but could not be read ($($_.Exception.GetBaseException().GetType().Name)); the gate fails closed. Make the file readable and retry."
    }
    $enabled = Get-DocsCompleteGateEnabled -ProfileText $profileText
    if ($null -ne $enabled.Reason) { return Get-DocsCompleteGateBlockDecision -Code $enabled.Reason -Message $enabled.Message }
    if (-not $enabled.Enabled) { return Get-DocsCompleteGateAllowDecision }

    $target = Get-DocsCompleteGateMergeTarget -CommandText $commandText
    if ($null -ne $target.Reason) { return Get-DocsCompleteGateBlockDecision -Code $target.Reason -Message $target.Message }
    $pr = Get-DocsCompleteGatePullRequest -Target $target -RepositoryRoot $root
    if ($null -ne $pr.Reason) { return Get-DocsCompleteGateBlockDecision -Code $pr.Reason -Message $pr.Message }
    if (-not (Test-DocsCompleteGateIntegrationTarget -BaseRefName $pr.BaseRefName -HeadRefName $pr.HeadRefName)) { return Get-DocsCompleteGateAllowDecision }

    $receiptPath = Get-DocsCompleteGateReceiptPath -ProfileText $profileText
    if ($null -ne $receiptPath.Reason) { return Get-DocsCompleteGateBlockDecision -Code $receiptPath.Reason -Message $receiptPath.Message }
    try {
        $receiptText = Get-DocsCompleteGateFileText -Path (Join-Path -Path $root -ChildPath $receiptPath.Path)
    } catch {
        return Get-DocsCompleteGateBlockDecision -Code 'RECEIPT_UNREADABLE' -Message "The validation receipt exists but could not be read ($($_.Exception.GetBaseException().GetType().Name)); the gate fails closed. Make the file readable and retry."
    }
    $receipt = Test-DocsCompleteGateReceipt -ReceiptText $receiptText -HeadRevision $pr.HeadRefOid
    if (-not $receipt.Allow) { return Get-DocsCompleteGateBlockDecision -Code $receipt.Reason -Message $receipt.Message }
    return Get-DocsCompleteGateAllowDecision
}

function Invoke-DocsCompleteGateEntryPoint {
    <#
    .SYNOPSIS
        Runs the gate decision and returns the process exit code.
    .DESCRIPTION
        Acquires the payload through the shared reader unless the caller supplies one, emits the
        compact decision JSON, and returns 0. Every anomaly is already a deny decision, so the
        function never returns 1. It does not call exit; the tail converts the returned code.
    .PARAMETER ToolInputRaw
        Optional pre-acquired payload text. When omitted the ReadPayload seam runs.
    .PARAMETER ReadPayload
        Seam for payload acquisition.
    .OUTPUTS
        System.Int32
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        [string] $ToolInputRaw,

        [scriptblock] $ReadPayload = { Read-ClaudeHookRawPayload }
    )

    if (-not $PSBoundParameters.ContainsKey('ToolInputRaw')) {
        # A failed read leaves an empty payload, which the decision denies as PAYLOAD_ANOMALY.
        try { $ToolInputRaw = [string](& $ReadPayload) } catch { $ToolInputRaw = '' }
    }

    $decision = Invoke-DocsCompleteGateDecision -ToolInputRaw $ToolInputRaw
    $decision | ConvertTo-Json -Compress -Depth 5 | Write-Output

    return 0
}

# Guard allows dot-sourcing in tests without executing the entrypoint.
if ($MyInvocation.InvocationName -eq '.') {
    return
}
if ($script:HookDependencyGuardLoadFailed) { [Console]::Error.WriteLine('DOCS_COMPLETE_GATE_BLOCKED: hook-dependency-guard.ps1 failed to load; the gate fails closed.'); exit 2 }
$dependencyDecision = Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix 'DOCS_COMPLETE_GATE_BLOCKED:'
if ($null -ne $dependencyDecision) { $dependencyDecision | ConvertTo-Json -Compress -Depth 5 | Write-Output; exit 0 }

# The entry point returns its [int] exit code as the last pipeline element and the decision
# JSON before it, so the decision is written explicitly here first.
$entryPointResult = @(Invoke-DocsCompleteGateEntryPoint)
if ($entryPointResult.Count -gt 1) {
    $entryPointResult[0..($entryPointResult.Count - 2)] | Write-Output
}

exit ([int]$entryPointResult[-1])
