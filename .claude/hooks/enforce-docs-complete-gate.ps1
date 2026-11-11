<#
.SYNOPSIS
    Pre-tool-use hook that gates a gh merge it reads of the epic integration branch into main
    behind a passing docs-complete validation receipt, when a documentation profile enables the
    gate.

.DESCRIPTION
    Invoked by the Claude Code PreToolUse hook on the "Bash" matcher. The gate is opt-in: with
    no profile at docs/documentation-estate/docs-profile.json, or a profile whose
    completion_gates.integration_pr_gate.enabled is not true, every command in a readable
    envelope is allowed and no gh call is made; a failed guarded import and an envelope anomaly
    still deny.

    Decision order (Invoke-DocsCompleteGateDecision):
      1. A failed guarded import denies (Get-HookDependencyFailureDecision); an envelope anomaly
         denies.
      2. No command, or a command that Test-DocsCompleteGateMergeCandidate does not classify as a
         merge candidate, allows with no I/O.
      3. The profile is read through Get-DocsCompleteGateFileText under the root from
         Get-DocsCompleteGateRepositoryRoot. Absent or disabled allows; a profile that cannot be
         read or parsed denies PROFILE_UNREADABLE.
      4. Get-DocsCompleteGateMergeTarget admits only a command proven to be one plain gh pr merge
         with readable operands; every other candidate denies PR_UNRESOLVED with no gh call. One
         bounded gh pr view [<selector>] [--repo <value>] --json
         baseRefName,headRefName,headRefOid then runs through Invoke-DocsOnlyGhExe. A failed,
         throwing or unreadable lookup denies PR_UNRESOLVED; a --match-head-commit value other
         than headRefOid denies MATCH_HEAD_MISMATCH.
      5. A pull request that is not an epic integration branch merging into main allows.
      6. The receipt path (RECEIPT_PATH_INVALID) and the receipt at that path are checked
         against headRefOid with Test-DocsCompleteGateReceipt; a failing reason denies. A receipt
         that exists but cannot be read denies RECEIPT_UNREADABLE.

    Every deny reason reads DOCS_COMPLETE_GATE_BLOCKED: <REASON_CODE>: <reason and remediation>.
    The head revision is always the pull request headRefOid and never the local HEAD, because
    the session worktree may hold a different commit than the pull request head.

    Residual limits. This hook reads command text and is not a shell parser. It is a policy-level
    control, not a security boundary and not a cryptographic one.

    What it establishes, and nothing beyond this: it looks up the selector of a command it reads
    as one plain gh pr merge, and with the gate enabled it denies PR_UNRESOLVED for these groups
    whichever pull request they name: the words gh pr merge or a gh api merge endpoint or
    mutation in the text the shared scanner reads as unquoted, including a compound command, a
    wrapper payload the shared predicate reads, a word split by a backslash or a
    backslash-newline, and a comment joined to a later command by a backslash-newline; and quoted
    or heredoc text holding those words beside an unquoted evaluator word (sh, bash, zsh, dash,
    ksh, pwsh, powershell, eval, source). The shared scanner keeps no comment state, reads << as
    a heredoc opener wherever it appears, and does not nest double quotes inside a command
    substitution inside double quotes, so a merge line that bash runs can read as quoted or
    heredoc text and allow. The forms named are: a quote character in a # comment before and
    after the merge line (# it's); a heredoc opener << in a # comment (# a<<b); a shift in
    arithmetic (x=$((1<<4))); and double quotes nested in a command substitution inside double
    quotes (echo "$(git log -1 --format="%h"; gh pr merge 12)").

    Outside what it can observe: any other way of causing a merge is not visible to it, and such
    a command allows. Known forms: other interpreters such as python -c and node -e; curl to the
    API; scripts on disk; computed command words ($a$b pr merge 12, $(echo 'gh pr merge 12')); a
    quoted command word outside the leading position; evaluators outside the named words (trap,
    fish, .); a gh alias; a mutation supplied from a file; a merge endpoint whose number is a
    variable; a direct git push to main; an ANSI-C quoted command word ($'g\x68' pr merge 12);
    arguments piped to gh through xargs gh (printf 'pr\nmerge\n12\n' | xargs gh); a shell alias
    holding the merge (alias m='gh pr merge 12', then m); an encoded payload decoded with
    base64 -d and piped to sh; a branch merge through gh api repos/o/r/merges, which merges
    branches with no pull request; and forms not modelled. This list is not complete: the class
    is every form the text tests do not recognize, and a form missing from this list is not
    thereby denied.

    Ambient state: the profile and receipt are read from the local working tree. An ambient
    GH_REPO or GH_HOST, and any directory or environment change made by an earlier Bash call, are
    not visible (cd, builtin cd, env --chdir, GIT_DIR=, read GH_REPO, bare export GH_REPO); the
    same forms inside the merge command are not plain and deny. A push after the lookup is not
    observed unless --match-head-commit is passed.

    Accepted false denies, which do not occur with the gate disabled or the profile absent: an
    unquoted mention (echo gh pr merge 12, gh pr view 12 && git merge main); a quoted mention
    beside an evaluator word, including a path ending in .sh; a compound or gh api merge of a
    non-integration pull request; a comment or a split word together with a backslash-newline in
    an otherwise plain merge; a GET on the merge endpoint; any =value spelling of --disable-auto.

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
# The receipt root is the live worktree that has the pull request head branch checked out (issue #1163).
try { Import-Module (Join-Path $PSScriptRoot '../lib/worktree-resolution/AgentTargetWorktree.psm1') -Force -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'AgentTargetWorktree.psm1' -ErrorRecord $_ }
# Shared command-line parser and structural invocation matcher (issues #545 and #952).
try { . (Join-Path $PSScriptRoot 'hook-command-scanner.ps1') } catch { Add-HookDependencyFailure -Name 'hook-command-scanner.ps1' -ErrorRecord $_ }
try { . (Join-Path $PSScriptRoot 'hook-command-invocation.ps1') } catch { Add-HookDependencyFailure -Name 'hook-command-invocation.ps1' -ErrorRecord $_ }
# Merge and enqueue scope predicate, API mutation test, flag and selector readers, and the action
# and value flag tables, all consumed by enforce-docs-complete-gate-target.ps1 (issue #952).
try { . (Join-Path $PSScriptRoot 'enforce-epic-merge-gate-command.ps1') } catch { Add-HookDependencyFailure -Name 'enforce-epic-merge-gate-command.ps1' -ErrorRecord $_ }
# Bounded gh seam Invoke-DocsOnlyGhExe (issue #927).
try { . (Join-Path $PSScriptRoot 'hook-docs-only-diff.ps1') } catch { Add-HookDependencyFailure -Name 'hook-docs-only-diff.ps1' -ErrorRecord $_ }
# Merge candidate test and merge target reader (issue #1034).
try { . (Join-Path $PSScriptRoot 'enforce-docs-complete-gate-target.ps1') } catch { Add-HookDependencyFailure -Name 'enforce-docs-complete-gate-target.ps1' -ErrorRecord $_ }

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

function Get-DocsCompleteGateReceiptRoot {
    <#
    .SYNOPSIS
        Returns the root the validation receipt is read beneath (issue #1163).
    .DESCRIPTION
        The worktree that Resolve-AgentTargetWorktree -CommandBranch resolves for the pull request
        head branch when exactly one live (non-prunable) registration has it checked out; the
        repository root when no registration, several registrations, or only a prunable one has
        it, when the branch is blank, or when resolution throws.
    .PARAMETER HeadRefName
        The pull request head branch from gh pr view.
    .PARAMETER RepositoryRoot
        The root the profile is read beneath; the fallback.
    .PARAMETER WorktreeListInvoker
        Optional worktree-list seam; the resolver's default runs git worktree list --porcelain.
    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowNull()] [AllowEmptyString()] [string] $HeadRefName,
        [Parameter(Mandatory)] [string] $RepositoryRoot,
        [scriptblock] $WorktreeListInvoker
    )

    if ([string]::IsNullOrWhiteSpace($HeadRefName)) { return $RepositoryRoot }
    $resolverArguments = @{ SessionRoot = $RepositoryRoot; CommandBranch = $HeadRefName; Policy = 'FailClosedOnIdentity' }
    if ($null -ne $WorktreeListInvoker) { $resolverArguments['WorktreeListInvoker'] = $WorktreeListInvoker }
    try { $resolved = Resolve-AgentTargetWorktree @resolverArguments } catch { return $RepositoryRoot }
    if ($null -ne $resolved.ReasonCode -or [string]::IsNullOrWhiteSpace([string] $resolved.WorktreeRoot)) { return $RepositoryRoot }
    return [string] $resolved.WorktreeRoot
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
    .PARAMETER WorktreeListInvoker
        Optional worktree-list seam forwarded to Get-DocsCompleteGateReceiptRoot (issue #1163).
    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        [string] $ToolInputRaw,

        [scriptblock] $WorktreeListInvoker = $null
    )

    $dependencyDecision = Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix 'DOCS_COMPLETE_GATE_BLOCKED:'
    if ($null -ne $dependencyDecision) { return $dependencyDecision }

    $payload = Resolve-ClaudeHookToolInput -Raw $ToolInputRaw
    if (-not $payload.IsValid) {
        return Get-DocsCompleteGateBlockDecision -Code 'PAYLOAD_ANOMALY' -Message ((Get-ClaudeHookPayloadAnomalyReason -Anomaly $payload.Anomaly) + '. The gate fails closed on an envelope it cannot read.')
    }

    $commandText = Get-ClaudeHookToolInputString -ToolInput $payload.Value -Name 'command'
    if (-not $commandText) { return Get-DocsCompleteGateAllowDecision }
    if (-not (Test-DocsCompleteGateMergeCandidate -CommandText $commandText)) { return Get-DocsCompleteGateAllowDecision }

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
    $receiptRootArguments = @{ HeadRefName = $pr.HeadRefName; RepositoryRoot = $root }
    if ($PSBoundParameters.ContainsKey('WorktreeListInvoker')) { $receiptRootArguments['WorktreeListInvoker'] = $WorktreeListInvoker }
    $receiptRoot = Get-DocsCompleteGateReceiptRoot @receiptRootArguments
    try {
        $receiptText = Get-DocsCompleteGateFileText -Path (Join-Path -Path $receiptRoot -ChildPath $receiptPath.Path)
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
