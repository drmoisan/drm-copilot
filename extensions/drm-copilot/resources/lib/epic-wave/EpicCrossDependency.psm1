<#
.SYNOPSIS
    Cross-epic dependency readiness for the epic skills (issue #1162).

.DESCRIPTION
    Validates the optional manifest key cross_epic_depends_on (one line, an inline flow
    sequence of flow mappings with exactly epic, integration_branch, and issue_num) and
    decides whether a feature may launch (feature mode) and whether the epic's
    integration-to-main pull request may be opened and merged (main mode).

    Pure functions: ConvertFrom-EpicCrossDependencyManifest, Get-EpicCrossDependencyManifestError,
    Get-EpicCrossDependencyPrerequisitePr, Get-EpicCrossDependencyFeatureDecision, and
    Get-EpicCrossDependencyMainGateDecision. The only I/O is in Invoke-EpicCrossGhExe and
    Invoke-EpicCrossGitExe (called by Read-EpicCrossManifestText, Get-EpicCrossPrSnapshot, and
    Test-EpicCrossAncestor) and in the seams Wait-EpicCrossInterval and Get-EpicCrossUtcNow.
    Adapter failures never fail open. Invoke-EpicCrossReadinessCommand is the command entry of
    Invoke-EpicCrossReadiness.ps1.

.NOTES
    PowerShell 7+. Mirrored byte-identically under extensions/drm-copilot/resources/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:CrossKey = 'cross_epic_depends_on'
$script:EdgeKeys = @('epic', 'integration_branch', 'issue_num')
$script:PollSeconds = 60
$script:MaxWaitSeconds = 540

# Private: a YAML scalar without one pair of matching surrounding quotes.
function ConvertFrom-EpicCrossScalar {
    [CmdletBinding()] [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Value)

    $trimmed = $Value.Trim()
    if ($trimmed.Length -ge 2 -and (($trimmed[0] -eq '"' -and $trimmed[-1] -eq '"') -or ($trimmed[0] -eq "'" -and $trimmed[-1] -eq "'"))) {
        return $trimmed.Substring(1, $trimmed.Length - 2)
    }
    return $trimmed
}

# Private: the items of an inline list, a block list (Block holds the trimmed lines), or one scalar.
function ConvertFrom-EpicCrossListValue {
    [CmdletBinding()] [OutputType([string[]])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Value, [AllowEmptyCollection()] [string[]] $Block = @())

    if ($Value -match '^\[(.*)\]$') {
        return [string[]] @($Matches[1] -split ',' | ForEach-Object { ConvertFrom-EpicCrossScalar -Value $_ } | Where-Object { $_ })
    }
    if ($Value) { return [string[]] @(ConvertFrom-EpicCrossScalar -Value $Value) }
    return [string[]] @($Block | Where-Object { $_ -match '^-\s*\S' } | ForEach-Object { ConvertFrom-EpicCrossScalar -Value ($_ -replace '^-\s*', '') })
}

# Private: parse a one-line flow sequence of flow mappings into edge hashtables (Epic,
# IntegrationBranch, IssueNum); $null when the value is not that form, an empty array for [].
function ConvertFrom-EpicCrossFlowValue {
    [CmdletBinding()] [OutputType([object[]])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Value)

    $trimmed = $Value.Trim()
    if ($trimmed -notmatch '^\[(.*)\]$') { return $null }
    $inner = $Matches[1].Trim()
    if ($inner -eq '') { return , @() }
    # The sequence holds only flow mappings separated by commas; nested braces are not allowed.
    $shape = [regex]::Replace($inner, '\{[^{}]*\}', '{}')
    if ($shape -notmatch '^\{\}(\s*,\s*\{\})*$') { return $null }
    $edges = [System.Collections.Generic.List[object]]::new()
    # Each mapping needs exactly the three keys, a plain-segment epic, and a positive issue_num.
    foreach ($mapping in [regex]::Matches($inner, '\{([^{}]*)\}')) {
        $fields = @{}
        foreach ($pair in ($mapping.Groups[1].Value -split ',')) {
            if ($pair -notmatch '^\s*([A-Za-z_]+)\s*:\s*(.*?)\s*$') { return $null }
            $key = $Matches[1]
            if ($fields.ContainsKey($key) -or $script:EdgeKeys -cnotcontains $key) { return $null }
            $fields[$key] = ConvertFrom-EpicCrossScalar -Value $Matches[2]
        }
        if ($fields.Count -ne $script:EdgeKeys.Count) { return $null }
        $epic = [string] $fields['epic']
        if ($epic -cnotmatch '^[A-Za-z0-9._-]+$' -or $epic -eq '.' -or $epic -eq '..') { return $null }
        if ([string] $fields['issue_num'] -notmatch '^[1-9][0-9]*$') { return $null }
        if ([string]::IsNullOrWhiteSpace([string] $fields['integration_branch'])) { return $null }
        $edges.Add(@{ Epic = $epic; IntegrationBranch = [string] $fields['integration_branch']; IssueNum = [string] $fields['issue_num'] })
    }
    return , $edges.ToArray()
}

# Private: one feature record from the raw inline values (Raw) and block lines (Block) of a features[] item.
function ConvertTo-EpicCrossFeatureRecord {
    [CmdletBinding()] [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Raw, [Parameter(Mandatory = $true)] [hashtable] $Block)

    $form = 'absent'
    $crossRaw = ''
    $edges = @()
    if ($Raw.Contains($script:CrossKey)) {
        $crossRaw = [string] $Raw[$script:CrossKey]
        # Routing: an empty inline value with indented lines below is the rejected block
        # form; any other value must parse as the inline flow form or it is malformed.
        if ($crossRaw -eq '' -and $Block.ContainsKey($script:CrossKey) -and $Block[$script:CrossKey].Count -gt 0) {
            $form = 'block'
        } else {
            $parsed = ConvertFrom-EpicCrossFlowValue -Value $crossRaw
            if ($null -eq $parsed) { $form = 'malformed' } else { $form = 'inline'; $edges = $parsed }
        }
    }
    $lists = @{}
    # depends_on and early_start_on may be inline, block, or scalar values.
    foreach ($name in @('depends_on', 'early_start_on')) {
        $lists[$name] = [string[]] @()
        if (-not $Raw.Contains($name)) { continue }
        $items = [string[]] @()
        if ($Block.ContainsKey($name)) { $items = [string[]] $Block[$name].ToArray() }
        $lists[$name] = [string[]] @(ConvertFrom-EpicCrossListValue -Value ([string] $Raw[$name]) -Block $items)
    }
    $issue = ''
    $folder = ''
    if ($Raw.Contains('issue_num')) { $issue = ConvertFrom-EpicCrossScalar -Value ([string] $Raw['issue_num']) }
    if ($Raw.Contains('feature_folder')) { $folder = ConvertFrom-EpicCrossScalar -Value ([string] $Raw['feature_folder']) }
    return [pscustomobject]@{
        IssueNum = $issue; FeatureFolder = $folder; DependsOn = $lists['depends_on']; EarlyStartOn = $lists['early_start_on']
        CrossForm = $form; CrossRaw = $crossRaw; CrossEdges = [object[]] $edges
    }
}

function ConvertFrom-EpicCrossDependencyManifest {
    <#
    .SYNOPSIS
        Parse epic.md frontmatter into Epic, IntegrationBranch, Features, and HasCrossEdge; $null without frontmatter.
    .DESCRIPTION
        Each feature carries IssueNum, FeatureFolder, DependsOn, EarlyStartOn, CrossForm
        (absent, inline, block, or malformed), CrossRaw, and CrossEdges. HasCrossEdge is true
        when any feature carries a cross-epic key other than an absent key or [].
    #>
    [CmdletBinding()] [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text)

    $lines = @($Text -split "`r?`n")
    if ($lines.Count -lt 2 -or $lines[0].Trim() -ne '---') { return $null }
    $epic = ''
    $branch = ''
    $records = [System.Collections.Generic.List[hashtable]]::new()
    $inFeatures = $false
    $current = $null
    $blockKey = $null
    $blockIndent = -1
    $closed = $false
    # Walk the frontmatter lines: top-level scalars, then the features list, where a line
    # indented deeper than a key with an empty value belongs to that key's block.
    for ($index = 1; $index -lt $lines.Count; $index++) {
        $line = $lines[$index]
        if ($line.Trim() -eq '---') { $closed = $true; break }
        if ([string]::IsNullOrWhiteSpace($line) -or $line.Trim().StartsWith('#')) { continue }
        $indent = $line.Length - $line.TrimStart().Length
        if ($null -ne $blockKey -and $indent -gt $blockIndent) { $current.Block[$blockKey].Add($line.Trim()); continue }
        $blockKey = $null
        if ($indent -eq 0) {
            $inFeatures = $line -match '^features:\s*$'
            $current = $null
            if ($line -match '^epic:\s*(.*)$') { $epic = ConvertFrom-EpicCrossScalar -Value $Matches[1] }
            elseif ($line -match '^integration_branch:\s*(.*)$') { $branch = ConvertFrom-EpicCrossScalar -Value $Matches[1] }
            continue
        }
        if (-not $inFeatures) { continue }
        $body = $line.TrimStart()
        $keyIndent = $indent
        if ($body -match '^-\s+(.*)$') {
            $keyIndent = $indent + $body.Length - $Matches[1].Length
            $body = $Matches[1]
            $current = @{ Raw = [ordered]@{}; Block = @{} }
            $records.Add($current)
        }
        if ($null -eq $current -or $body -notmatch '^([A-Za-z_][A-Za-z0-9_]*):\s*(.*)$') { continue }
        $key = $Matches[1]
        $current.Raw[$key] = $Matches[2].Trim()
        if ($current.Raw[$key] -eq '') {
            $blockKey = $key
            $blockIndent = $keyIndent
            $current.Block[$key] = [System.Collections.Generic.List[string]]::new()
        }
    }
    if (-not $closed) { return $null }

    $features = [object[]] @($records | ForEach-Object { ConvertTo-EpicCrossFeatureRecord -Raw $_.Raw -Block $_.Block })
    $hasEdge = @($features | Where-Object { $_.CrossForm -ne 'absent' -and -not ($_.CrossForm -eq 'inline' -and $_.CrossEdges.Count -eq 0) }).Count -gt 0
    return [pscustomobject]@{ Epic = $epic; IntegrationBranch = $branch; Features = $features; HasCrossEdge = $hasEdge }
}

# Private: the first node found on a cycle of a node-to-prerequisites graph; '' when acyclic.
function Find-EpicCrossGraphCycle {
    [CmdletBinding()] [OutputType([string])]
    param([Parameter(Mandatory = $true)] [System.Collections.Generic.Dictionary[string, System.Collections.Generic.List[string]]] $Graph)

    $state = [System.Collections.Generic.Dictionary[string, int]]::new([StringComparer]::Ordinal)
    $nodes = [string[]] @($Graph.Keys)
    [Array]::Sort($nodes, [StringComparer]::Ordinal)
    # Iterative depth-first search from every node: state 1 is on the active path and 2 is
    # finished, so reaching a state-1 node again proves a cycle.
    foreach ($start in $nodes) {
        if ($state.ContainsKey($start)) { continue }
        $stack = [System.Collections.Generic.Stack[object]]::new()
        $stack.Push(@($start, 0))
        $state[$start] = 1
        while ($stack.Count -gt 0) {
            $frame = $stack.Pop()
            $node = [string] $frame[0]
            $position = [int] $frame[1]
            $count = 0
            if ($Graph.ContainsKey($node)) { $count = $Graph[$node].Count }
            if ($position -ge $count) { $state[$node] = 2; continue }
            $stack.Push(@($node, ($position + 1)))
            $child = $Graph[$node][$position]
            if (-not $state.ContainsKey($child)) { $state[$child] = 1; $stack.Push(@($child, 0)) }
            elseif ($state[$child] -eq 1) { return $child }
        }
    }
    return ''
}

# Private: add the depends_on and cross-epic edges of one parsed manifest to a cycle graph
# whose nodes are '<epic>#<issue_num>'; a same-epic edge is reported by SAME_EPIC and adds no edge.
function Add-EpicCrossGraphManifest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.Generic.Dictionary[string, System.Collections.Generic.List[string]]] $Graph,
        [Parameter(Mandatory = $true)] [pscustomobject] $Manifest
    )

    foreach ($feature in $Manifest.Features) {
        $node = "$($Manifest.Epic)#$($feature.IssueNum)"
        if (-not $Graph.ContainsKey($node)) { $Graph[$node] = [System.Collections.Generic.List[string]]::new() }
        foreach ($dependency in $feature.DependsOn) { $Graph[$node].Add("$($Manifest.Epic)#$dependency") }
        $crossEdges = @($feature.CrossEdges | Where-Object { $_.Epic -cne $Manifest.Epic })
        foreach ($edge in $crossEdges) { $Graph[$node].Add("$($edge.Epic)#$($edge.IssueNum)") }
    }
}

function Get-EpicCrossDependencyManifestError {
    <#
    .SYNOPSIS
        Return the manifest validation errors; each begins with its EPIC_CROSS_DEPENDENCY_ code and a colon.
    .DESCRIPTION
        The local rules (MALFORMED, UNSUPPORTED_FORM, BRANCH_MISMATCH, SAME_EPIC, DUPLICATE,
        and EARLY_START_CROSS) always run. When OtherManifest is supplied, the rules that read
        the referenced manifests (MANIFEST_UNREADABLE, UNRESOLVED, and the one-hop CYCLE) run
        too. A manifest without a cross-epic key gives no error.
    #>
    [CmdletBinding()] [OutputType([string[]])]
    param([Parameter(Mandatory = $true)] [pscustomobject] $Manifest, [AllowNull()] [hashtable] $OtherManifest = $null)

    $errors = [System.Collections.Generic.List[string]]::new()
    $ownIssues = [string[]] @($Manifest.Features | ForEach-Object { $_.IssueNum })
    $crossIssues = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    # Per feature: a rejected form stops that feature's checks; otherwise each edge is
    # checked locally and, with the referenced manifests supplied, against them.
    foreach ($feature in $Manifest.Features) {
        $name = "feature $($feature.IssueNum)"
        if ($feature.CrossForm -eq 'block') {
            $errors.Add("EPIC_CROSS_DEPENDENCY_UNSUPPORTED_FORM: $name gives $($script:CrossKey) in block style; write it on one line as an inline flow sequence of flow mappings.")
            continue
        }
        if ($feature.CrossForm -eq 'malformed') {
            $errors.Add("EPIC_CROSS_DEPENDENCY_MALFORMED: $name $($script:CrossKey) is not an inline flow sequence of flow mappings with exactly the keys epic, integration_branch, and issue_num, a plain-segment epic, and a positive integer issue_num.")
            continue
        }
        $seen = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
        foreach ($edge in $feature.CrossEdges) {
            $label = "$($edge.Epic)#$($edge.IssueNum)"
            [void] $crossIssues.Add($edge.IssueNum)
            if ($edge.Epic -ceq $Manifest.Epic) {
                $errors.Add("EPIC_CROSS_DEPENDENCY_SAME_EPIC: $name names its own epic $($edge.Epic); use depends_on for an edge inside the epic.")
            }
            if ($edge.IntegrationBranch -cne "epic/$($edge.Epic)-integration") {
                $errors.Add("EPIC_CROSS_DEPENDENCY_BRANCH_MISMATCH: $name gives integration_branch $($edge.IntegrationBranch) for epic $($edge.Epic); expected epic/$($edge.Epic)-integration.")
            }
            if (-not $seen.Add($label)) { $errors.Add("EPIC_CROSS_DEPENDENCY_DUPLICATE: $name names $label more than once.") }
            if ($null -eq $OtherManifest -or $edge.Epic -ceq $Manifest.Epic) { continue }
            $other = $null
            if ($OtherManifest.ContainsKey($edge.Epic)) { $other = $OtherManifest[$edge.Epic] }
            if ($null -eq $other) {
                $errors.Add("EPIC_CROSS_DEPENDENCY_MANIFEST_UNREADABLE: $name names epic $($edge.Epic), whose manifest is absent on $($edge.IntegrationBranch) and on main.")
            } elseif (@($other.Features | Where-Object { $_.IssueNum -ceq $edge.IssueNum }).Count -eq 0) {
                $errors.Add("EPIC_CROSS_DEPENDENCY_UNRESOLVED: $name names $label, which is not a feature of the $($edge.Epic) manifest.")
            }
        }
    }
    # Early start applies only inside the epic, so it may not name an issue that appears
    # only as a cross-epic prerequisite.
    foreach ($feature in $Manifest.Features) {
        foreach ($upstream in $feature.EarlyStartOn) {
            if ($ownIssues -cnotcontains $upstream -and $crossIssues.Contains($upstream)) {
                $errors.Add("EPIC_CROSS_DEPENDENCY_EARLY_START_CROSS: feature $($feature.IssueNum) gives early_start_on $upstream, which names a cross-epic dependency; early start applies only inside the epic.")
            }
        }
    }
    if ($null -ne $OtherManifest -and $Manifest.HasCrossEdge) {
        $graph = [System.Collections.Generic.Dictionary[string, System.Collections.Generic.List[string]]]::new([StringComparer]::Ordinal)
        Add-EpicCrossGraphManifest -Graph $graph -Manifest $Manifest
        foreach ($slug in @($OtherManifest.Keys | Sort-Object)) {
            if ($null -ne $OtherManifest[$slug]) { Add-EpicCrossGraphManifest -Graph $graph -Manifest $OtherManifest[$slug] }
        }
        $cycleNode = Find-EpicCrossGraphCycle -Graph $graph
        if ($cycleNode) { $errors.Add("EPIC_CROSS_DEPENDENCY_CYCLE: the features of this manifest and the manifests it references form a cycle through $cycleNode.") }
    }
    return [string[]] $errors.ToArray()
}

# Private: parse a gh pr list JSON array into Number, MergeCommitSha, HeadRefName, and Files
# records; $null when the text is not valid JSON or an element lacks a required field. The
# feature snapshot (RequireFiles) also needs a string headRefName and a files list of paths.
function ConvertFrom-EpicCrossSnapshot {
    [CmdletBinding()] [OutputType([object[]])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $SnapshotJson, [switch] $RequireFiles)

    try { $parsed = ConvertFrom-Json -InputObject $SnapshotJson -AsHashtable -NoEnumerate -ErrorAction Stop } catch { return $null }
    if ($parsed -isnot [System.Collections.IList]) { return $null }
    $prs = [System.Collections.Generic.List[object]]::new()
    # Every element must carry an integer number and a mergeCommit object with a string oid.
    foreach ($item in $parsed) {
        if ($item -isnot [System.Collections.IDictionary]) { return $null }
        $number = $item['number']
        $merge = $item['mergeCommit']
        if ($number -isnot [long] -and $number -isnot [int]) { return $null }
        if ($merge -isnot [System.Collections.IDictionary] -or $merge['oid'] -isnot [string]) { return $null }
        $record = @{ Number = [long] $number; MergeCommitSha = [string] $merge['oid']; HeadRefName = ''; Files = [string[]] @() }
        if ($RequireFiles) {
            $files = $item['files']
            if ($item['headRefName'] -isnot [string] -or $files -isnot [System.Collections.IList]) { return $null }
            $paths = [System.Collections.Generic.List[string]]::new()
            foreach ($file in $files) {
                if ($file -isnot [System.Collections.IDictionary] -or $file['path'] -isnot [string]) { return $null }
                $paths.Add([string] $file['path'])
            }
            $record.HeadRefName = [string] $item['headRefName']
            $record.Files = [string[]] $paths.ToArray()
        }
        $prs.Add([pscustomobject] $record)
    }
    return , $prs.ToArray()
}

function Get-EpicCrossDependencyPrerequisitePr {
    <#
    .SYNOPSIS
        Match the prerequisite's merged pull request in a gh pr list snapshot (D3 as amended by D11).
    .DESCRIPTION
        Main-sync chore PRs (head chore/epic-...-main-sync-...) are excluded. A PR matches when a
        listed file lies under docs/features/active/<folder>/ or docs/features/completed/<folder>/,
        or when a hyphen-delimited token of the last segment of its head branch equals the
        issue number; a PR matching both rules counts once. Returns Status (match,
        PREREQ_PR_NOT_FOUND, PREREQ_PR_AMBIGUOUS, or PREREQ_SNAPSHOT_INVALID), Number,
        MergeCommitSha, and MatchCount.
    #>
    [CmdletBinding()] [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $SnapshotJson,
        [Parameter(Mandatory = $true)] [string] $IssueNum,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $FeatureFolder
    )

    $prs = ConvertFrom-EpicCrossSnapshot -SnapshotJson $SnapshotJson -RequireFiles
    if ($null -eq $prs) { return [pscustomobject]@{ Status = 'PREREQ_SNAPSHOT_INVALID'; Number = $null; MergeCommitSha = ''; MatchCount = 0 } }
    $prefixes = @()
    if ($FeatureFolder) { $prefixes = @("docs/features/active/$FeatureFolder/", "docs/features/completed/$FeatureFolder/") }
    $matched = [System.Collections.Generic.List[object]]::new()
    # Apply the main-sync exclusion first, then the file rule or the token rule; a PR is kept once.
    foreach ($pr in $prs) {
        if ($pr.HeadRefName.StartsWith('chore/epic-', [StringComparison]::Ordinal) -and $pr.HeadRefName.Contains('-main-sync-')) { continue }
        $fileHit = @($pr.Files | Where-Object { $path = $_; @($prefixes | Where-Object { $path.StartsWith($_, [StringComparison]::Ordinal) }).Count -gt 0 }).Count -gt 0
        $tokenHit = ((($pr.HeadRefName -split '/')[-1]) -split '-') -ccontains $IssueNum
        if (($fileHit -or $tokenHit) -and @($matched | Where-Object { $_.Number -eq $pr.Number }).Count -eq 0) { $matched.Add($pr) }
    }
    if ($matched.Count -eq 0) { return [pscustomobject]@{ Status = 'PREREQ_PR_NOT_FOUND'; Number = $null; MergeCommitSha = ''; MatchCount = 0 } }
    if ($matched.Count -gt 1) { return [pscustomobject]@{ Status = 'PREREQ_PR_AMBIGUOUS'; Number = $null; MergeCommitSha = ''; MatchCount = $matched.Count } }
    return [pscustomobject]@{ Status = 'match'; Number = $matched[0].Number; MergeCommitSha = $matched[0].MergeCommitSha; MatchCount = 1 }
}

# Private: apply the Feature hold rows to one edge's evidence (AdapterError, Match,
# OtherBranchPresent, and the three ancestry exit codes, $null when not evaluated); the
# first matching row wins.
function Get-EpicCrossDependencyEdgeDecision {
    [CmdletBinding()] [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)] [hashtable] $Evidence)

    $match = $Evidence['Match']
    $status = ''
    if ($null -ne $match) { $status = [string] $match.Status }
    $exits = @(@($Evidence['OtherAncestorExit'], $Evidence['MainAncestorExit'], $Evidence['OwnAncestorExit']) | Where-Object { $null -ne $_ })
    $badExit = @($exits | Where-Object { $_ -ne 0 -and $_ -ne 1 }).Count -gt 0
    $present = [bool] $Evidence['OtherBranchPresent']
    # Rows in table order; the first one whose condition holds decides the edge.
    $decision = switch ($true) {
        { [bool] $Evidence['AdapterError'] -or $null -eq $match -or $status -eq 'PREREQ_SNAPSHOT_INVALID' -or $badExit } { @('hold', 'PREREQ_UNVERIFIABLE'); break }
        { $status -eq 'match' -and -not $present -and $Evidence['MainAncestorExit'] -eq 0 } { @('release', 'PREREQ_IN_MAIN'); break }
        { $status -eq 'PREREQ_PR_NOT_FOUND' } { @('hold', 'PREREQ_PR_NOT_FOUND'); break }
        { $status -eq 'PREREQ_PR_AMBIGUOUS' } { @('hold', 'PREREQ_PR_AMBIGUOUS'); break }
        { -not $present -or $Evidence['OtherAncestorExit'] -ne 0 } { @('hold', 'PREREQ_NOT_ANCESTOR'); break }
        { $Evidence['OwnAncestorExit'] -eq 0 } { @('release', 'PREREQ_ALREADY_INTEGRATED'); break }
        default { @('merge_required', 'PREREQ_MERGED_INTEGRATION_MERGE_REQUIRED') }
    }
    return [pscustomobject]@{ Decision = $decision[0]; Reason = $decision[1] }
}

function Get-EpicCrossDependencyFeatureDecision {
    <#
    .SYNOPSIS
        Decide hold, merge_required, or release for one feature from its edge evidence.
    .DESCRIPTION
        Every edge release gives release; any hold gives hold (the reason of the first held
        edge); otherwise merge_required with the distinct integration branches to merge. A
        feature without cross-epic edges gives release with NO_CROSS_EPIC_EDGE.
    #>
    [CmdletBinding()] [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [string] $Issue,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [hashtable[]] $Evidence,
        [AllowEmptyString()] [string] $EvaluatedAt = ''
    )

    # One record per edge: its row decision plus the matched PR evidence when there is one.
    $edges = [object[]] @(foreach ($item in $Evidence) {
            $decision = Get-EpicCrossDependencyEdgeDecision -Evidence $item
            $match = $item['Match']
            $matched = $null -ne $match -and $match.Status -eq 'match'
            [pscustomobject]@{
                Epic = [string] $item['Epic']; IntegrationBranch = [string] $item['IntegrationBranch']; IssueNum = [string] $item['IssueNum']
                Decision = $decision.Decision; Reason = $decision.Reason
                PrNumber = $(if ($matched) { $match.Number } else { $null }); MergeCommitSha = $(if ($matched) { [string] $match.MergeCommitSha } else { '' })
                EvaluatedAt = $EvaluatedAt
            }
        })
    $held = @($edges | Where-Object { $_.Decision -eq 'hold' })
    $merge = @($edges | Where-Object { $_.Decision -eq 'merge_required' })
    $branches = [string[]] @()
    # Aggregation: no edge releases with NO_CROSS_EPIC_EDGE; any hold holds; otherwise any
    # merge_required lists the distinct branches to merge; otherwise every edge released.
    if ($edges.Count -eq 0) { $decision = 'release'; $reason = 'NO_CROSS_EPIC_EDGE' }
    elseif ($held.Count -gt 0) { $decision = 'hold'; $reason = $held[0].Reason }
    elseif ($merge.Count -gt 0) {
        $decision = 'merge_required'
        $reason = 'PREREQ_MERGED_INTEGRATION_MERGE_REQUIRED'
        $branches = [string[]] @($merge | ForEach-Object { $_.IntegrationBranch } | Select-Object -Unique)
    } else { $decision = 'release'; $reason = $edges[0].Reason }
    return [pscustomobject]@{ Issue = $Issue; Decision = $decision; Reason = $reason; MergeBranches = $branches; Edges = $edges }
}

function Get-EpicCrossDependencyMainGateDecision {
    <#
    .SYNOPSIS
        Decide whether the integration-to-main pull request may be opened and merged.
    .DESCRIPTION
        Rows per prerequisite epic, first match wins: an adapter error, an ancestry exit other
        than 0 or 1, or an invalid snapshot gives MAIN_PREREQ_UNVERIFIABLE; no merged PR gives
        MAIN_PREREQ_PR_NOT_MERGED; more than one gives MAIN_PREREQ_PR_AMBIGUOUS; a merge commit
        that is not an ancestor of origin/main gives MAIN_PREREQ_NOT_ANCESTOR; otherwise
        MAIN_PREREQ_RELEASED. No prerequisite epic gives not_applicable; every epic released
        gives release; otherwise hold with the reason of the first held epic.
    #>
    [CmdletBinding()] [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [hashtable[]] $Evidence, [AllowEmptyString()] [string] $EvaluatedAt = '')

    # One record per epic, its rows evaluated in table order.
    $epics = [object[]] @(foreach ($item in $Evidence) {
            $prs = $null
            if (-not $item['AdapterError']) { $prs = ConvertFrom-EpicCrossSnapshot -SnapshotJson ([string] $item['SnapshotJson']) }
            $exit = $item['AncestorExit']
            $pr = $null
            if ($null -eq $prs) { $reason = 'MAIN_PREREQ_UNVERIFIABLE' }
            elseif ($prs.Count -eq 0) { $reason = 'MAIN_PREREQ_PR_NOT_MERGED' }
            elseif ($prs.Count -gt 1) { $reason = 'MAIN_PREREQ_PR_AMBIGUOUS' }
            else {
                $pr = $prs[0]
                $reason = 'MAIN_PREREQ_UNVERIFIABLE'
                if ($exit -eq 0) { $reason = 'MAIN_PREREQ_RELEASED' } elseif ($exit -eq 1) { $reason = 'MAIN_PREREQ_NOT_ANCESTOR' }
            }
            [pscustomobject]@{
                Epic = [string] $item['Epic']; IntegrationBranch = [string] $item['IntegrationBranch']
                Decision = $(if ($reason -eq 'MAIN_PREREQ_RELEASED') { 'release' } else { 'hold' }); Reason = $reason
                PrNumber = $(if ($null -ne $pr) { $pr.Number } else { $null }); MergeCommitSha = $(if ($null -ne $pr) { $pr.MergeCommitSha } else { '' })
                EvaluatedAt = $EvaluatedAt
            }
        })
    if ($epics.Count -eq 0) { return [pscustomobject]@{ Decision = 'not_applicable'; Reason = 'NO_CROSS_EPIC_EDGE'; Epics = [object[]] @() } }
    $held = @($epics | Where-Object { $_.Decision -eq 'hold' })
    if ($held.Count -gt 0) { return [pscustomobject]@{ Decision = 'hold'; Reason = $held[0].Reason; Epics = $epics } }
    return [pscustomobject]@{ Decision = 'release'; Reason = 'MAIN_PREREQ_RELEASED'; Epics = $epics }
}

function Invoke-EpicCrossGhExe {
    <#
    .SYNOPSIS
        Run gh with the given arguments and return ExitCode and Output; the only gh process this module starts.
    #>
    [CmdletBinding()] [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)] [string[]] $GhArgs)

    $output = & gh @GhArgs 2>$null
    return [pscustomobject]@{ ExitCode = Get-EpicCrossLastExitCode; Output = (@($output) -join "`n") }
}

function Invoke-EpicCrossGitExe {
    <#
    .SYNOPSIS
        Run git with the given arguments and return ExitCode and Output; the only git process this module starts.
    #>
    [CmdletBinding()] [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)] [string[]] $GitArgs)

    $output = & git @GitArgs 2>$null
    return [pscustomobject]@{ ExitCode = Get-EpicCrossLastExitCode; Output = (@($output) -join "`n") }
}

function Get-EpicCrossLastExitCode {
    <#
    .SYNOPSIS
        Return the exit code of the most recent native command ($LASTEXITCODE).
    #>
    [CmdletBinding()] [OutputType([int])]
    param()

    return [int] $LASTEXITCODE
}

function Read-EpicCrossManifestText {
    <#
    .SYNOPSIS
        Read another epic's epic.md from origin/<integration branch>, else origin/main; returns Text and Source (branch, main, or '').
    #>
    [CmdletBinding()] [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)] [string] $Epic, [Parameter(Mandatory = $true)] [string] $IntegrationBranch)

    $path = "docs/features/epics/$Epic/epic.md"
    # A branch that no longer exists means the epic reached main, so origin/main is the fallback.
    foreach ($candidate in @(@('branch', "origin/$IntegrationBranch"), @('main', 'origin/main'))) {
        $result = Invoke-EpicCrossGitExe -GitArgs @('show', "$($candidate[1]):$path")
        if ($result.ExitCode -eq 0) { return [pscustomobject]@{ Text = [string] $result.Output; Source = $candidate[0] } }
    }
    return [pscustomobject]@{ Text = ''; Source = '' }
}

function Get-EpicCrossPrSnapshot {
    <#
    .SYNOPSIS
        List merged PRs into another integration branch (feature) or from it into main (main); returns ExitCode and Output.
    #>
    [CmdletBinding()] [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)] [string] $IntegrationBranch, [Parameter(Mandatory = $true)] [ValidateSet('feature', 'main')] [string] $Mode)

    if ($Mode -eq 'feature') {
        return Invoke-EpicCrossGhExe -GhArgs @('pr', 'list', '--base', $IntegrationBranch, '--state', 'merged', '--limit', '200', '--json', 'number,headRefName,mergeCommit,files')
    }
    return Invoke-EpicCrossGhExe -GhArgs @('pr', 'list', '--head', $IntegrationBranch, '--base', 'main', '--state', 'merged', '--json', 'number,mergeCommit')
}

function Test-EpicCrossAncestor {
    <#
    .SYNOPSIS
        Return the exit code of git merge-base --is-ancestor: 0 ancestor, 1 not an ancestor, any other value an error.
    #>
    [CmdletBinding()] [OutputType([int])]
    param([Parameter(Mandatory = $true)] [string] $Commit, [Parameter(Mandatory = $true)] [string] $Ref)

    return [int] (Invoke-EpicCrossGitExe -GitArgs @('merge-base', '--is-ancestor', $Commit, $Ref)).ExitCode
}

function Wait-EpicCrossInterval {
    <#
    .SYNOPSIS
        Sleep between readiness polls; the only wait this module performs.
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)] [int] $Seconds)

    Start-Sleep -Seconds $Seconds
}

function Get-EpicCrossUtcNow {
    <#
    .SYNOPSIS
        Return the current UTC instant.
    #>
    [CmdletBinding()] [OutputType([datetime])]
    param()

    return [datetime]::UtcNow
}

# Private: gather one cross-epic edge's evidence through the adapters; any failure sets AdapterError.
function Get-EpicCrossFeatureEvidence {
    [CmdletBinding()] [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [hashtable] $Edge, [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $OwnIntegrationBranch)

    $evidence = @{
        Epic = $Edge.Epic; IntegrationBranch = $Edge.IntegrationBranch; IssueNum = $Edge.IssueNum; AdapterError = $false
        Match = $null; OtherBranchPresent = $false; OtherAncestorExit = $null; MainAncestorExit = $null; OwnAncestorExit = $null
    }
    try {
        # Resolve the prerequisite's feature folder from the other manifest, match its merged
        # PR, then test ancestry against the other branch (or main) and the own branch.
        $manifestText = Read-EpicCrossManifestText -Epic $Edge.Epic -IntegrationBranch $Edge.IntegrationBranch
        $feature = @()
        if ($manifestText.Source) {
            $other = ConvertFrom-EpicCrossDependencyManifest -Text $manifestText.Text
            if ($null -ne $other) { $feature = @($other.Features | Where-Object { $_.IssueNum -ceq $Edge.IssueNum }) }
        }
        if ($feature.Count -ne 1) { $evidence.AdapterError = $true; return $evidence }
        $snapshot = Get-EpicCrossPrSnapshot -IntegrationBranch $Edge.IntegrationBranch -Mode feature
        if ($snapshot.ExitCode -ne 0) { $evidence.AdapterError = $true; return $evidence }
        $folder = ($feature[0].FeatureFolder -split '/')[-1]
        $evidence.Match = Get-EpicCrossDependencyPrerequisitePr -SnapshotJson $snapshot.Output -IssueNum $Edge.IssueNum -FeatureFolder $folder
        $evidence.OtherBranchPresent = $manifestText.Source -eq 'branch'
        if ($evidence.Match.Status -ne 'match') { return $evidence }
        $sha = $evidence.Match.MergeCommitSha
        if (-not $evidence.OtherBranchPresent) {
            $evidence.MainAncestorExit = Test-EpicCrossAncestor -Commit $sha -Ref 'origin/main'
            return $evidence
        }
        $evidence.OtherAncestorExit = Test-EpicCrossAncestor -Commit $sha -Ref "origin/$($Edge.IntegrationBranch)"
        if ($evidence.OtherAncestorExit -eq 0) { $evidence.OwnAncestorExit = Test-EpicCrossAncestor -Commit $sha -Ref "origin/$OwnIntegrationBranch" }
    } catch {
        $evidence.AdapterError = $true
    }
    return $evidence
}

# Private: gather one prerequisite epic's main-gate evidence through the adapters.
function Get-EpicCrossMainEvidence {
    [CmdletBinding()] [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [string] $Epic, [Parameter(Mandatory = $true)] [string] $IntegrationBranch)

    $evidence = @{ Epic = $Epic; IntegrationBranch = $IntegrationBranch; AdapterError = $false; SnapshotJson = ''; AncestorExit = $null }
    try {
        $snapshot = Get-EpicCrossPrSnapshot -IntegrationBranch $IntegrationBranch -Mode main
        if ($snapshot.ExitCode -ne 0) { $evidence.AdapterError = $true; return $evidence }
        $evidence.SnapshotJson = [string] $snapshot.Output
        $prs = ConvertFrom-EpicCrossSnapshot -SnapshotJson $evidence.SnapshotJson
        if ($null -ne $prs -and $prs.Count -eq 1) { $evidence.AncestorExit = Test-EpicCrossAncestor -Commit $prs[0].MergeCommitSha -Ref 'origin/main' }
    } catch {
        $evidence.AdapterError = $true
    }
    return $evidence
}

# Private: fetch origin once and evaluate the feature or main decision of a parsed manifest;
# a blank Issue in feature mode evaluates every edge-bearing feature.
function Get-EpicCrossReadinessResult {
    [CmdletBinding()] [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)] [pscustomobject] $Manifest, [Parameter(Mandatory = $true)] [string] $Mode, [AllowEmptyString()] [string] $Issue = '')

    $fetchFailed = $false
    if ($Manifest.HasCrossEdge) {
        try { $fetchFailed = (Invoke-EpicCrossGitExe -GitArgs @('fetch', '-q', 'origin')).ExitCode -ne 0 } catch { $fetchFailed = $true }
    }
    $evaluatedAt = (Get-EpicCrossUtcNow).ToUniversalTime().ToString("yyyy-MM-dd'T'HH:mm:ss'Z'", [Globalization.CultureInfo]::InvariantCulture)
    $allEdges = @($Manifest.Features | ForEach-Object { $_.CrossEdges })
    if ($Mode -eq 'main') {
        $seen = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
        # One evidence record per distinct prerequisite epic, in manifest order.
        $evidence = foreach ($edge in $allEdges) {
            if (-not $seen.Add($edge.Epic)) { continue }
            if ($fetchFailed) { @{ Epic = $edge.Epic; IntegrationBranch = $edge.IntegrationBranch; AdapterError = $true } }
            else { Get-EpicCrossMainEvidence -Epic $edge.Epic -IntegrationBranch $edge.IntegrationBranch }
        }
        $gate = Get-EpicCrossDependencyMainGateDecision -Evidence ([hashtable[]] @($evidence)) -EvaluatedAt $evaluatedAt
        return [pscustomobject]@{ Mode = 'main'; Decision = $gate.Decision; Reason = $gate.Reason; Epics = $gate.Epics }
    }
    $selected = @($Manifest.Features | Where-Object { $_.CrossEdges.Count -gt 0 })
    if ($Issue) { $selected = @($Manifest.Features | Where-Object { $_.IssueNum -ceq $Issue }) }
    # One decision per selected feature from the evidence of each of its edges.
    $decisions = [object[]] @(foreach ($feature in $selected) {
            $evidence = foreach ($edge in $feature.CrossEdges) {
                if ($fetchFailed) { @{ Epic = $edge.Epic; IntegrationBranch = $edge.IntegrationBranch; IssueNum = $edge.IssueNum; AdapterError = $true } }
                else { Get-EpicCrossFeatureEvidence -Edge $edge -OwnIntegrationBranch $Manifest.IntegrationBranch }
            }
            Get-EpicCrossDependencyFeatureDecision -Issue $feature.IssueNum -Evidence ([hashtable[]] @($evidence)) -EvaluatedAt $evaluatedAt
        })
    # The aggregate is the first hold, else the first merge_required, else the first release.
    $aggregate = [pscustomobject]@{ Decision = 'release'; Reason = 'NO_CROSS_EPIC_EDGE' }
    foreach ($candidate in @('hold', 'merge_required', 'release')) {
        $first = @($decisions | Where-Object { $_.Decision -eq $candidate })
        if ($first.Count -gt 0) { $aggregate = $first[0]; break }
    }
    return [pscustomobject]@{ Mode = 'feature'; Decision = $aggregate.Decision; Reason = $aggregate.Reason; Features = $decisions }
}

function Invoke-EpicCrossReadinessCommand {
    <#
    .SYNOPSIS
        Run validate, feature, or main mode for a manifest file and return ExitCode, Stdout, and Stderr.
    .DESCRIPTION
        Exit 0 when a decision or a clean validation is produced (hold is a valid decision), 1
        for manifest validation errors (EPIC_CROSS_DEPENDENCY_ codes on stderr), and 2 for a
        usage error. With a positive -WaitSeconds, feature and main mode re-evaluate every 60
        seconds through Wait-EpicCrossInterval and return at the first decision other than
        hold, or when the bound is reached.
    .PARAMETER Mode
        validate, feature, or main.
    .PARAMETER ManifestPath
        Path of the epic.md being orchestrated.
    .PARAMETER Issue
        Feature issue number for feature mode; omitted for every edge-bearing feature.
    .PARAMETER WaitSeconds
        Wait bound from 0 to 540; 0 is one evaluation.
    .PARAMETER ReadManifestText
        Injectable reader that receives the path and returns the file text.
    #>
    [CmdletBinding()] [OutputType([pscustomobject])]
    param(
        [AllowEmptyString()] [string] $Mode = '',
        [AllowEmptyString()] [string] $ManifestPath = '',
        [AllowEmptyString()] [string] $Issue = '',
        [int] $WaitSeconds = 0,
        [scriptblock] $ReadManifestText = { param([string] $Path) Get-Content -Raw -LiteralPath $Path }
    )

    $usage = { param([string] $Message) [pscustomobject]@{ ExitCode = 2; Stdout = ''; Stderr = "EPIC_CROSS_READINESS_USAGE: $Message" } }
    if (@('validate', 'feature', 'main') -cnotcontains $Mode) { return & $usage '-Mode must be validate, feature, or main.' }
    if ([string]::IsNullOrWhiteSpace($ManifestPath)) { return & $usage '-ManifestPath is required.' }
    if ($WaitSeconds -lt 0 -or $WaitSeconds -gt $script:MaxWaitSeconds) { return & $usage "-WaitSeconds must be between 0 and $($script:MaxWaitSeconds)." }
    try { $text = [string] (& $ReadManifestText $ManifestPath) } catch { return & $usage "Manifest could not be read: $($_.Exception.Message)" }
    $manifest = ConvertFrom-EpicCrossDependencyManifest -Text $text
    if ($null -eq $manifest) { return & $usage 'Manifest has no YAML frontmatter.' }
    if ($Mode -eq 'feature' -and $Issue -and @($manifest.Features | Where-Object { $_.IssueNum -ceq $Issue }).Count -eq 0) {
        return & $usage "-Issue $Issue is not a feature of the manifest."
    }

    # Validate mode also reads every referenced manifest so the cross-manifest rules run.
    $others = $null
    if ($Mode -eq 'validate' -and $manifest.HasCrossEdge) {
        $others = @{}
        foreach ($edge in @($manifest.Features | ForEach-Object { $_.CrossEdges })) {
            if ($others.ContainsKey($edge.Epic) -or $edge.Epic -ceq $manifest.Epic) { continue }
            $read = Read-EpicCrossManifestText -Epic $edge.Epic -IntegrationBranch $edge.IntegrationBranch
            $others[$edge.Epic] = $null
            if ($read.Source) { $others[$edge.Epic] = ConvertFrom-EpicCrossDependencyManifest -Text $read.Text }
        }
    }
    $errors = @(Get-EpicCrossDependencyManifestError -Manifest $manifest -OtherManifest $others)
    if ($errors.Count -gt 0) { return [pscustomobject]@{ ExitCode = 1; Stdout = ''; Stderr = ($errors -join [Environment]::NewLine) } }
    if ($Mode -eq 'validate') {
        return [pscustomobject]@{ ExitCode = 0; Stdout = ([pscustomobject]@{ Mode = 'validate'; Errors = @() } | ConvertTo-Json -Compress -Depth 4); Stderr = '' }
    }

    # Bounded wait: one evaluation, then one injected sleep per further poll until a
    # decision other than hold or until another poll would pass the bound.
    $elapsed = 0
    while ($true) {
        $result = Get-EpicCrossReadinessResult -Manifest $manifest -Mode $Mode -Issue $Issue
        if ($result.Decision -ne 'hold' -or $elapsed + $script:PollSeconds -gt $WaitSeconds) { break }
        Wait-EpicCrossInterval -Seconds $script:PollSeconds
        $elapsed += $script:PollSeconds
    }
    return [pscustomobject]@{ ExitCode = 0; Stdout = ($result | ConvertTo-Json -Compress -Depth 8); Stderr = '' }
}

Export-ModuleMember -Function ConvertFrom-EpicCrossDependencyManifest, Get-EpicCrossDependencyManifestError, Get-EpicCrossDependencyPrerequisitePr, Get-EpicCrossDependencyFeatureDecision, Get-EpicCrossDependencyMainGateDecision, Invoke-EpicCrossGhExe, Invoke-EpicCrossGitExe, Get-EpicCrossLastExitCode, Read-EpicCrossManifestText, Get-EpicCrossPrSnapshot, Test-EpicCrossAncestor, Wait-EpicCrossInterval, Get-EpicCrossUtcNow, Invoke-EpicCrossReadinessCommand
