<#
.SYNOPSIS
    Post-fan-in (issue #1136) and merged-feature follow-up (issue #1141) allowances of the
    preimplementation gate's epic scope.

.DESCRIPTION
    Dot-sourced by enforce-orchestration-preimplementation-gate-epic-scope.ps1 on the Claude
    and the Codex surfaces. After every child feature of an epic has merged into the epic
    integration branch (fan-in complete), the epic-orchestrator commits the updated
    docs/features/epics/<slug>/epic-status.md and pr-author writes the integration pull
    request body and receipt. In epic scope the readiness predicate denies those calls with
    'merge-in-progress', because no merge is in progress. These functions decide the narrow
    allowance that Get-OrchestrationEpicScopeDecision applies only for that exact failure:

    - Test-EpicFanInComplete: the epic checkpoint records route_id epic, an integration
      branch equal (case-sensitive) to the worktree HEAD branch, and a non-empty features
      list whose every merge_status is merged or worktree_removed.
    - Get-EpicFanInStatusDocRelativePath: the status document path derived from the
      checkpoint's plain epic_feature_folder slug, cross-checked with epic_status_doc_path.
    - Test-EpicFanInWriteRelativePath: the Write/Edit allowlist (the pr-author body and
      receipt under artifacts/, and the status document).
    - Test-EpicFanInCommitShape: the git add and git commit shapes the allowance models.
    - Get-EpicFanInAllowance: the decision for one call, given an already-resolved scope
      object and an injected staged-index reader. It is the reuse seam for the follow-up
      findings 3 and 9 of issue #1136.
    - Get-EpicMergedFeatureFollowUpAllowance (issue #1141): before fan-in, admits Write/Edit,
      git add, and git commit calls whose paths all lie under the docs folders of a merged
      feature (Get-EpicMergedFeatureRoots, Test-EpicMergedFeaturePath) or are the status
      document; the epic checkpoint entry is the only evidence.

.NOTES
    PowerShell 7+. Pure: no disk, process, environment, or clock access; the staged index is
    read only through the injected reader. Functions only: no StrictMode and no preference
    assignment, because a dot-sourced file changes its caller's scope. Call-time
    dependencies: Test-OrchestrationCommandTextUnresolvable, Split-OrchestrationCommandLine,
    and ConvertTo-OrchestrationCommandToken (helpers file) and
    Get-HookTargetWorktreeRelativePath (HookTargetWorktree.psm1 on Claude,
    hook-target-worktree.ps1 on Codex). Byte-identical at .claude/hooks/, .codex/hooks/, and
    both bundle mirrors under extensions/drm-copilot/resources/. The allowance is a
    policy-level control, not a security control.
    AUTHORITY: PowerShell-authoritative. This hook file starts no interpreter process.
#>

# The feature merge states that count as integrated. Restated from $script:TerminalMergeStatuses
# in .claude/lib/worktree-resolution/EpicScopeReadiness.psm1 and pinned equal by a test.
$script:EpicFanInTerminalMergeStatuses = @('merged', 'worktree_removed')

# The only route id that describes an epic checkpoint. Compared case-sensitively.
$script:EpicFanInRouteId = 'epic'

# A plain epic slug: one path segment that cannot climb or hide.
$script:EpicFanInSlugPattern = '^[A-Za-z0-9][A-Za-z0-9._-]*$'

# The pr-author body and receipt of a pull request, relative to the worktree root.
$script:EpicFanInWritePatterns = @('^artifacts/pr_body_[0-9]+\.receipt\.json$', '^artifacts/pr_body_[0-9]+\.md$')

# The git commit options the allowance models; each takes the next token as its value.
$script:EpicFanInCommitValueOptions = @('-m', '--message', '-F', '--file', '--trailer')

function Get-EpicFanInPropertyText {
    <#
    .SYNOPSIS
        Return a named property of an object as a string, or $null when absent.
    .PARAMETER InputObject
        The object to read.
    .PARAMETER Name
        The property name.
    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([AllowNull()][object] $InputObject, [Parameter(Mandatory)][string] $Name)

    if ($null -eq $InputObject) { return $null }
    $property = $InputObject.PSObject.Properties[$Name]
    if ($null -eq $property -or $null -eq $property.Value) { return $null }
    return [string]$property.Value
}

function Test-EpicFanInComplete {
    <#
    .SYNOPSIS
        Report whether the epic checkpoint records fan-in complete for a branch.
    .DESCRIPTION
        True only when route_id is exactly epic, integration_branch is non-blank and
        case-sensitively equal to Branch, features is non-empty, and every feature's
        merge_status is merged or worktree_removed.
    .PARAMETER Checkpoint
        The parsed epic checkpoint object, or $null.
    .PARAMETER Branch
        The HEAD branch of the worktree the call targets.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()][object] $Checkpoint,
        [AllowNull()][AllowEmptyString()][string] $Branch
    )

    if ($null -eq $Checkpoint) { return $false }
    if ((Get-EpicFanInPropertyText -InputObject $Checkpoint -Name 'route_id') -cne $script:EpicFanInRouteId) { return $false }
    $integrationBranch = Get-EpicFanInPropertyText -InputObject $Checkpoint -Name 'integration_branch'
    if ([string]::IsNullOrWhiteSpace($integrationBranch) -or $integrationBranch -cne $Branch) { return $false }
    $property = $Checkpoint.PSObject.Properties['features']
    if ($null -eq $property -or $null -eq $property.Value) { return $false }
    $features = @($property.Value)
    if ($features.Count -eq 0) { return $false }
    foreach ($feature in $features) {
        $status = Get-EpicFanInPropertyText -InputObject $feature -Name 'merge_status'
        if ($script:EpicFanInTerminalMergeStatuses -notcontains $status) { return $false }
    }
    return $true
}

function Get-EpicFanInStatusDocRelativePath {
    <#
    .SYNOPSIS
        Return the epic status document path of a checkpoint, or $null.
    .DESCRIPTION
        Derives docs/features/epics/<epic_feature_folder>/epic-status.md. Returns $null when
        the slug is blank or not one plain segment, or when a non-blank epic_status_doc_path
        disagrees with the derived path after backslash normalisation.
    .PARAMETER Checkpoint
        The parsed epic checkpoint object, or $null.
    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([AllowNull()][object] $Checkpoint)

    $slug = Get-EpicFanInPropertyText -InputObject $Checkpoint -Name 'epic_feature_folder'
    if ([string]::IsNullOrWhiteSpace($slug) -or $slug -cnotmatch $script:EpicFanInSlugPattern) { return $null }
    $derived = "docs/features/epics/$slug/epic-status.md"
    $declared = Get-EpicFanInPropertyText -InputObject $Checkpoint -Name 'epic_status_doc_path'
    if (-not [string]::IsNullOrWhiteSpace($declared) -and ($declared -replace '\\', '/') -cne $derived) { return $null }
    return $derived
}

function Test-EpicFanInWriteRelativePath {
    <#
    .SYNOPSIS
        Report whether a worktree-relative path is on the post-fan-in write allowlist.
    .DESCRIPTION
        Admits only artifacts/pr_body_<N>.receipt.json, artifacts/pr_body_<N>.md, and the
        checkpoint's status document. Matching is case-sensitive after backslash normalisation.
    .PARAMETER RelativePath
        The path relative to the integration worktree root.
    .PARAMETER Checkpoint
        The parsed epic checkpoint object, or $null.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()][AllowEmptyString()][string] $RelativePath,
        [AllowNull()][object] $Checkpoint
    )

    if ([string]::IsNullOrWhiteSpace($RelativePath)) { return $false }
    $normalized = $RelativePath -replace '\\', '/'
    foreach ($pattern in $script:EpicFanInWritePatterns) {
        if ($normalized -cmatch $pattern) { return $true }
    }
    $statusDoc = Get-EpicFanInStatusDocRelativePath -Checkpoint $Checkpoint
    return ($null -ne $statusDoc -and $normalized -ceq $statusDoc)
}

function Get-EpicFanInShapeDetail {
    <#
    .SYNOPSIS
        Classify the tokens of one command segment as a modelled add or commit.
    .DESCRIPTION
        Returns Shape ('add', 'commit', or $null) and Pathless (true for a commit without a
        pathspec). Accepted: git [-C <absolute>] add [--] <p...>, and git [-C <absolute>]
        commit whose options are only -m, --message, -F, --file, or --trailer with a value,
        followed by nothing or by -- <p...>, where every operand satisfies PathPredicate
        (default: equal to StatusDocPath, and no shape when StatusDocPath is blank).
    .PARAMETER Token
        The segment tokens.
    .PARAMETER StatusDocPath
        The status document path of the checkpoint.
    .PARAMETER PathPredicate
        Optional operand test called with one path (issue #1141).
    .OUTPUTS
        System.Management.Automation.PSCustomObject
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowNull()][AllowEmptyCollection()][string[]] $Token,
        [AllowNull()][AllowEmptyString()][string] $StatusDocPath,
        [AllowNull()][scriptblock] $PathPredicate
    )

    $none = [pscustomobject]@{ Shape = $null; Pathless = $false }
    $words = @($Token)
    if ($null -eq $PathPredicate) {
        if ([string]::IsNullOrWhiteSpace($StatusDocPath)) { return $none }
        $PathPredicate = { param([string] $Path) $Path -ceq $StatusDocPath }
    }
    if ($words.Count -lt 2 -or $words[0] -cne 'git') { return $none }
    $index = 1
    if ($words[$index] -ceq '-C') {
        if ($words.Count -lt 4 -or ($words[2] -replace '\\', '/') -cnotmatch '^(/|[A-Za-z]:/)') { return $none }
        $index = 3
    }
    $verb = $words[$index]
    $rest = @(if ($words.Count -gt $index + 1) { $words[($index + 1)..($words.Count - 1)] })
    if ($verb -ceq 'add') {
        if ($rest.Count -ge 1 -and $rest[0] -ceq '--') { $rest = @($rest | Select-Object -Skip 1) }
        if ($rest.Count -ge 1 -and @($rest | Where-Object { -not (& $PathPredicate $_) }).Count -eq 0) { return [pscustomobject]@{ Shape = 'add'; Pathless = $false } }
        return $none
    }
    if ($verb -cne 'commit') { return $none }
    $position = 0
    while ($position -lt $rest.Count) {
        $word = $rest[$position]
        if ($word -ceq '--') {
            $operands = @($rest | Select-Object -Skip ($position + 1))
            if ($operands.Count -ge 1 -and @($operands | Where-Object { -not (& $PathPredicate $_) }).Count -eq 0) {
                return [pscustomobject]@{ Shape = 'commit'; Pathless = $false }
            }
            return $none
        }
        if ($script:EpicFanInCommitValueOptions -cnotcontains $word -or $position + 1 -ge $rest.Count) { return $none }
        $position += 2
    }
    return [pscustomobject]@{ Shape = 'commit'; Pathless = $true }
}

function Test-EpicFanInCommitShape {
    <#
    .SYNOPSIS
        Return 'add', 'commit', or $null for the tokens of one command segment.
    .DESCRIPTION
        A thin view of Get-EpicFanInShapeDetail: 'add' for git [-C <absolute>] add [--]
        <p...>, 'commit' for a commit with only -m, --message, -F, --file, or --trailer and
        either no pathspec or -- <p...>, and $null for every other shape, including --amend
        and -a. Operands satisfy PathPredicate, by default equality with StatusDocPath.
    .PARAMETER Token
        The segment tokens.
    .PARAMETER StatusDocPath
        The status document path of the checkpoint.
    .PARAMETER PathPredicate
        Optional operand test called with one path (issue #1141).
    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowNull()][AllowEmptyCollection()][string[]] $Token,
        [AllowNull()][AllowEmptyString()][string] $StatusDocPath,
        [AllowNull()][scriptblock] $PathPredicate
    )

    return (Get-EpicFanInShapeDetail -Token $Token -StatusDocPath $StatusDocPath -PathPredicate $PathPredicate).Shape
}

function Test-EpicFanInStagedIndex {
    <#
    .SYNOPSIS
        Report whether every name of a staged-index read satisfies the path predicate.
    .DESCRIPTION
        The read must carry ExitCode 0 and non-empty NUL-terminated output naming at least
        one path, and every name must satisfy PathPredicate (default: equal to the status
        document, and false when StatusDocPath is blank).
    .PARAMETER Staged
        The reader result with ExitCode and Output.
    .PARAMETER StatusDocPath
        The status document path of the checkpoint.
    .PARAMETER PathPredicate
        Optional name test called with one path (issue #1141).
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()][object] $Staged, [AllowNull()][AllowEmptyString()][string] $StatusDocPath, [AllowNull()][scriptblock] $PathPredicate)

    if ($null -eq $Staged) { return $false }
    if ($null -eq $PathPredicate) {
        if ([string]::IsNullOrWhiteSpace($StatusDocPath)) { return $false }
        $PathPredicate = { param([string] $Path) $Path -ceq $StatusDocPath }
    }
    if ((Get-EpicFanInPropertyText -InputObject $Staged -Name 'ExitCode') -ne '0') { return $false }
    $text = Get-EpicFanInPropertyText -InputObject $Staged -Name 'Output'
    if ([string]::IsNullOrEmpty($text) -or -not $text.EndsWith([char]0)) { return $false }
    $names = $text.Substring(0, $text.Length - 1).Split([char]0)
    return ($names.Count -ge 1 -and @($names | Where-Object { -not (& $PathPredicate $_) }).Count -eq 0)
}

function Get-EpicFanInAllowance {
    <#
    .SYNOPSIS
        Decide whether a call in a fan-in-complete epic scope is a sanctioned post-fan-in write.
    .DESCRIPTION
        Blank FilePath entries are ignored. When a non-blank entry remains, the call is a path
        leg and every entry must be allowlisted; an absolute entry is first made relative to
        Scope.WorktreeRoot and is refused when it lies outside it. Otherwise the call is a
        command leg: the text must be resolvable and split balanced, and every segment must be
        a modelled add or commit. A pathless commit reads the staged index of
        Scope.WorktreeRoot through StagedIndexReader and needs it to name exactly the status
        document. Any error answers not allowed. Reuse seam for the follow-up findings 3 and 9
        of issue #1136: the caller supplies an already-resolved scope object. Issue #1141:
        PathPredicate replaces the path-leg allowlist and OperandPredicate replaces the
        status-document test of command operands and staged names.
    .PARAMETER Scope
        The Resolve-EpicScopeCheckpoint result (Checkpoint, WorktreeRoot, Branch, ...).
    .PARAMETER FilePath
        The path-leg paths; blank entries are ignored.
    .PARAMETER Command
        The command-leg text.
    .PARAMETER StagedIndexReader
        Called with the worktree root; returns an object with ExitCode and Output.
    .PARAMETER PathPredicate
        Optional path-leg test; default Test-EpicFanInWriteRelativePath.
    .PARAMETER OperandPredicate
        Optional operand and staged-name test; default equality with the status document.
    .OUTPUTS
        System.Management.Automation.PSCustomObject with Allowed and Detail.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowNull()][object] $Scope,
        [AllowNull()][AllowEmptyCollection()][AllowEmptyString()][string[]] $FilePath,
        [AllowNull()][AllowEmptyString()][string] $Command,
        [AllowNull()][scriptblock] $StagedIndexReader,
        [AllowNull()][scriptblock] $PathPredicate,
        [AllowNull()][scriptblock] $OperandPredicate
    )

    try {
        if ($null -eq $Scope) { return [pscustomobject]@{ Allowed = $false; Detail = 'no resolved scope' } }
        $checkpoint = $Scope.Checkpoint
        $root = [string]$Scope.WorktreeRoot
        $paths = @($FilePath | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
        if ($paths.Count -gt 0) {
            foreach ($path in $paths) {
                $relative = $path -replace '\\', '/'
                if ($relative -cmatch '^(/|[A-Za-z]:/)') { $relative = Get-HookTargetWorktreeRelativePath -Path $relative -WorktreeRoot $root }
                $admitted = if ($null -eq $relative) { $false } elseif ($null -ne $PathPredicate) { [bool](& $PathPredicate $relative) } else { Test-EpicFanInWriteRelativePath -RelativePath $relative -Checkpoint $checkpoint }
                if (-not $admitted) {
                    return [pscustomobject]@{ Allowed = $false; Detail = "path not allowlisted: $path" }
                }
            }
            return [pscustomobject]@{ Allowed = $true; Detail = 'path leg allowlisted' }
        }
        if ([string]::IsNullOrWhiteSpace($Command) -or (Test-OrchestrationCommandTextUnresolvable -CommandText $Command)) {
            return [pscustomobject]@{ Allowed = $false; Detail = 'command text is blank or unresolvable' }
        }
        $split = Split-OrchestrationCommandLine -CommandText $Command
        if (-not $split.Balanced -or @($split.Segments).Count -eq 0) {
            return [pscustomobject]@{ Allowed = $false; Detail = 'command text is unbalanced' }
        }
        $statusDoc = Get-EpicFanInStatusDocRelativePath -Checkpoint $checkpoint
        $needsIndex = $false
        foreach ($segment in @($split.Segments)) {
            $detail = Get-EpicFanInShapeDetail -Token @(ConvertTo-OrchestrationCommandToken -Segment $segment.Trim()) -StatusDocPath $statusDoc -PathPredicate $OperandPredicate
            if ($null -eq $detail.Shape) {
                return [pscustomobject]@{ Allowed = $false; Detail = "segment not modelled: $($segment.Trim())" }
            }
            if ($detail.Pathless) { $needsIndex = $true }
        }
        if ($needsIndex -and -not (Test-EpicFanInStagedIndex -Staged (& $StagedIndexReader $root) -StatusDocPath $statusDoc -PathPredicate $OperandPredicate)) {
            return [pscustomobject]@{ Allowed = $false; Detail = 'staged index is not exactly the status document' }
        }
        return [pscustomobject]@{ Allowed = $true; Detail = 'command leg modelled' }
    } catch {
        return [pscustomobject]@{ Allowed = $false; Detail = "allowance error: $($_.Exception.Message)" }
    }
}

function Get-EpicMergedFeatureRoots {
    <#
    .SYNOPSIS
        Return the follow-up roots of the merged features of an epic checkpoint (issue #1141).
    .DESCRIPTION
        For each features entry with a terminal merge_status, a plain feature_folder basename
        after one optional docs/features/active/ or docs/features/completed/ prefix, a
        merge_commit_sha of 40 or 64 lowercase hex characters, and an integer pr_number above
        0: docs/features/active/<basename>/ and docs/features/completed/<basename>/. The status
        document is added when at least one feature qualifies.
    .OUTPUTS
        System.String
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'The issue #1141 specification fixes this name; it returns a set of roots.')]
    [CmdletBinding()]
    [OutputType([string])]
    param([AllowNull()][object] $Checkpoint)

    $roots = [System.Collections.Generic.List[string]]::new()
    $property = if ($null -ne $Checkpoint) { $Checkpoint.PSObject.Properties['features'] }
    $features = @(if ($null -ne $property -and $null -ne $property.Value) { $property.Value })
    foreach ($feature in $features) {
        if ($null -eq $feature) { continue }
        $status = Get-EpicFanInPropertyText -InputObject $feature -Name 'merge_status'
        $basename = [string](Get-EpicFanInPropertyText -InputObject $feature -Name 'feature_folder') -creplace '^docs/features/(active|completed)/', ''
        $sha = $feature.PSObject.Properties['merge_commit_sha']
        $pr = $feature.PSObject.Properties['pr_number']
        if ($script:EpicFanInTerminalMergeStatuses -cnotcontains $status -or $basename -cnotmatch $script:EpicFanInSlugPattern) { continue }
        if ($null -eq $sha -or $sha.Value -isnot [string] -or $sha.Value -cnotmatch '^([0-9a-f]{40}|[0-9a-f]{64})\z') { continue }
        if ($null -eq $pr -or -not ($pr.Value -is [int] -or $pr.Value -is [long]) -or $pr.Value -le 0) { continue }
        $roots.Add("docs/features/active/$basename/")
        $roots.Add("docs/features/completed/$basename/")
    }
    $statusDoc = Get-EpicFanInStatusDocRelativePath -Checkpoint $Checkpoint
    if ($roots.Count -gt 0 -and $null -ne $statusDoc) { $roots.Add($statusDoc) }
    return $roots.ToArray()
}

function Test-EpicMergedFeaturePath {
    <#
    .SYNOPSIS
        Report whether a worktree-relative path lies under a merged-feature follow-up root.
    .DESCRIPTION
        False for a blank path, a backslash, a glob character, a leading slash, or a . or ..
        segment. A root ending in / admits a path that starts with it and has a non-empty
        remainder; any other root admits only an equal path. Matching is case-sensitive.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()][AllowEmptyString()][string] $RelativePath,
        [AllowNull()][AllowEmptyCollection()][string[]] $Root
    )

    if ([string]::IsNullOrWhiteSpace($RelativePath) -or $RelativePath.StartsWith('/', [StringComparison]::Ordinal)) { return $false }
    if ($RelativePath.IndexOfAny([char[]]@([char]92, '*', '?', '[')) -ge 0) { return $false }
    if (@($RelativePath.Split('/') | Where-Object { $_ -ceq '.' -or $_ -ceq '..' }).Count -gt 0) { return $false }
    foreach ($candidate in @($Root)) {
        if ([string]::IsNullOrEmpty($candidate)) { continue }
        if (-not $candidate.EndsWith('/', [StringComparison]::Ordinal)) {
            if ($RelativePath -ceq $candidate) { return $true }
        } elseif ($RelativePath.Length -gt $candidate.Length -and $RelativePath.StartsWith($candidate, [StringComparison]::Ordinal)) {
            return $true
        }
    }
    return $false
}

function Get-EpicMergedFeatureFollowUpAllowance {
    <#
    .SYNOPSIS
        Decide whether a call is a follow-up on a merged epic feature (issue #1141).
    .DESCRIPTION
        Allowed only when route_id is epic, integration_branch equals Scope.Branch, the
        checkpoint yields merged-feature roots, and Get-EpicFanInAllowance admits the call with
        both predicates bound to Test-EpicMergedFeaturePath over those roots. Fan-in
        completeness is not required; only the scope object is read. Any error answers not
        allowed.
    .OUTPUTS
        System.Management.Automation.PSCustomObject with Allowed and Detail.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowNull()][object] $Scope,
        [AllowNull()][AllowEmptyCollection()][AllowEmptyString()][string[]] $FilePath,
        [AllowNull()][AllowEmptyString()][string] $Command,
        [AllowNull()][scriptblock] $StagedIndexReader
    )

    try {
        if ($null -eq $Scope) { return [pscustomobject]@{ Allowed = $false; Detail = 'no resolved scope' } }
        $checkpoint = $Scope.Checkpoint
        $integrationBranch = Get-EpicFanInPropertyText -InputObject $checkpoint -Name 'integration_branch'
        if ((Get-EpicFanInPropertyText -InputObject $checkpoint -Name 'route_id') -cne $script:EpicFanInRouteId -or
            [string]::IsNullOrWhiteSpace($integrationBranch) -or $integrationBranch -cne [string]$Scope.Branch) {
            return [pscustomobject]@{ Allowed = $false; Detail = 'not the epic integration branch' }
        }
        # The predicate reads $mergedFeatureRoots through the caller scope chain when Get-EpicFanInAllowance invokes it.
        $mergedFeatureRoots = @(Get-EpicMergedFeatureRoots -Checkpoint $checkpoint)
        if ($mergedFeatureRoots.Count -eq 0) { return [pscustomobject]@{ Allowed = $false; Detail = 'no merged feature qualifies' } }
        $predicate = { param([string] $Path) Test-EpicMergedFeaturePath -RelativePath $Path -Root $mergedFeatureRoots }
        return (Get-EpicFanInAllowance -Scope $Scope -FilePath $FilePath -Command $Command -StagedIndexReader $StagedIndexReader -PathPredicate $predicate -OperandPredicate $predicate)
    } catch {
        return [pscustomobject]@{ Allowed = $false; Detail = "allowance error: $($_.Exception.Message)" }
    }
}
