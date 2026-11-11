<#
.SYNOPSIS
    Cross-epic external-node functions for Get-EpicProgressReport.ps1 (issue #1162, decision D9).

.DESCRIPTION
    A feature whose manifest entry carries cross_epic_depends_on depends on a feature of
    another epic. The report models each such prerequisite as an external node named
    '<epic slug>#<issue>': it is done when the epic checkpoint hold record shows integrated or
    in_main, otherwise pending; it never counts as blocked; it is priced from the other epic's
    prepared plan (remaining execution tasks at the feature rate, other step types at their
    medians) or, without a readable kickoff and plan, at the per-type defaults with zero
    execution tasks and the label 'external (default)'. An external node carries no step
    records, so it adds no steps to the step totals and enters the time figures only.

    Get-EpicProgressCrossEpicEdge and New-EpicProgressExternalNode are pure.
    Read-EpicProgressCrossEpicPlanText reads only through the Read-EpicProgressText seam.
    Get-EpicProgressReport.Logic.ps1 dot-sources this file after the Schedule file.
#>

function Get-EpicProgressCrossEpicEdge {
    <#
    .SYNOPSIS
        Return one record (Issue, Epic, IntegrationBranch, IssueNum, Status, Node) per cross-epic edge, from checkpoint rows, else from the raw manifest value.
    .DESCRIPTION
        A feature whose epic checkpoint row carries cross_epic_depends_on uses that list, with
        each entry's status; any other feature uses the raw single-line manifest value stored by
        Read-EpicProgressManifestFeature, with an empty status. Entries without an epic and a
        positive issue number are skipped.
    .PARAMETER CheckpointRow
        The epic checkpoint features rows; empty for none.
    .PARAMETER ManifestRow
        The epic.md frontmatter features rows; empty for none.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowEmptyCollection()] [object[]] $CheckpointRow = @(),
        [AllowEmptyCollection()] [object[]] $ManifestRow = @()
    )

    $covered = @{}
    $edge = {
        param([string] $Issue, [string] $Epic, [string] $Branch, [string] $Number, [string] $Status)
        [pscustomobject]@{ Issue = $Issue; Epic = $Epic; IntegrationBranch = $Branch; IssueNum = $Number; Status = $Status; Node = "$Epic#$Number" }
    }
    # Checkpoint rows first: their hold records carry the edge status.
    foreach ($row in @($CheckpointRow | Where-Object { $null -ne $_ -and $null -ne $_.issue_num })) {
        if ($row.PSObject.Properties.Name -notcontains 'cross_epic_depends_on') { continue }
        $issue = [string] $row.issue_num
        $covered[$issue] = $true
        foreach ($entry in @($row.cross_epic_depends_on | Where-Object { $null -ne $_ -and $_ -isnot [string] })) {
            $names = @($entry.PSObject.Properties.Name)
            if ($names -notcontains 'epic' -or $names -notcontains 'issue_num' -or [string] $entry.issue_num -notmatch '^[1-9][0-9]*$') { continue }
            $branch = if ($names -contains 'integration_branch') { [string] $entry.integration_branch } else { '' }
            $status = if ($names -contains 'status') { [string] $entry.status } else { '' }
            & $edge $issue ([string] $entry.epic) $branch ([string] $entry.issue_num) $status
        }
    }
    # Manifest rows for the features no checkpoint row covers: parse the raw flow value.
    foreach ($row in @($ManifestRow | Where-Object { $null -ne $_ })) {
        $issue = [string] $row.issue_num
        if ($covered.ContainsKey($issue) -or $row.PSObject.Properties.Name -notcontains 'cross_epic_depends_on') { continue }
        foreach ($mapping in [regex]::Matches([string] $row.cross_epic_depends_on, '\{([^{}]*)\}')) {
            $fields = @{}
            foreach ($pair in ($mapping.Groups[1].Value -split ',')) {
                if ($pair -match '^\s*([A-Za-z_]+)\s*:\s*(.*?)\s*$') { $fields[$Matches[1]] = $Matches[2].Trim('"', "'") }
            }
            if (-not $fields['epic'] -or [string] $fields['issue_num'] -notmatch '^[1-9][0-9]*$') { continue }
            & $edge $issue ([string] $fields['epic']) ([string] $fields['integration_branch']) ([string] $fields['issue_num']) ''
        }
    }
}

function New-EpicProgressExternalNode {
    <#
    .SYNOPSIS
        Return the external node (Issue, Epic, IssueNum, NodeState, External, Label, ExecutionTasks, OtherSeconds) of one cross-epic edge.
    .DESCRIPTION
        Pure. The node is done when Status is integrated or in_main, otherwise pending. With a
        plan text that holds tasks, the unchecked tasks are the execution tasks and the
        preflight, review, pr, ci, and merge steps are priced at their ledger medians (label
        'external'); otherwise every non-execution item step type is priced at its default with
        zero execution tasks (label 'external (default)'). The node holds no step records.
    .PARAMETER Edge
        The record from Get-EpicProgressCrossEpicEdge.
    .PARAMETER PlanText
        The other epic's prepared plan for the prerequisite; blank when unreadable.
    .PARAMETER Ledger
        The duration ledger.
    .PARAMETER Default
        The default seconds per type.
    .PARAMETER NowUnixSeconds
        The current epoch second.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [pscustomobject] $Edge,
        [AllowEmptyString()] [string] $PlanText = '',
        [AllowNull()] [hashtable] $Ledger = $null,
        [Parameter(Mandatory = $true)] [hashtable] $Default,
        [Parameter(Mandatory = $true)] [long] $NowUnixSeconds
    )

    $tasks = @(Get-EpicProgressPlanTask -PlanText $PlanText)
    $priced = $tasks.Count -gt 0
    # Plan-priced nodes have a prepared plan, so research, spec, and plan are already done.
    $types = @('research', 'spec', 'plan', 'preflight', 'review', 'pr', 'ci', 'merge')
    $ledgerUsed = $null
    if ($priced) {
        $types = @('preflight', 'review', 'pr', 'ci', 'merge')
        $ledgerUsed = $Ledger
    }
    $steps = @($types | ForEach-Object { Get-EpicProgressStepRecord -Issue ([string] $Edge.Node) -Type $_ })
    $other = (Get-EpicProgressTypeEstimate -Step $steps -Ledger $ledgerUsed -Default $Default -NowUnixSeconds $NowUnixSeconds).TotalSeconds
    $label = 'external (default)'
    if ($priced) { $label = 'external' }
    return [pscustomobject]@{
        Issue          = [string] $Edge.Node
        Epic           = [string] $Edge.Epic
        IssueNum       = [string] $Edge.IssueNum
        NodeState      = $(if ([string] $Edge.Status -in @('integrated', 'in_main')) { 'done' } else { 'pending' })
        External       = $true
        Label          = $label
        ExecutionTasks = [int] @($tasks | Where-Object { -not $_.Done }).Count
        OtherSeconds   = [double] $other
    }
}

function Get-EpicProgressExternalSecond {
    <#
    .SYNOPSIS
        Return an external node's remaining seconds at a sequential rate: 0 when done, else OtherSeconds plus each execution task at 3600 / rate.
    .DESCRIPTION
        A rate that is not a finite number above 0 prices each remaining execution task at
        infinity, as Get-EpicProgressFeatureRemainingSecond does for a local feature.
    .PARAMETER Node
        The record from New-EpicProgressExternalNode.
    .PARAMETER Rate
        The sequential rate in tasks per hour.
    #>
    [CmdletBinding()]
    [OutputType([double])]
    param(
        [Parameter(Mandatory = $true)] [pscustomobject] $Node,
        [Parameter(Mandatory = $true)] [double] $Rate
    )

    if ($Node.NodeState -eq 'done') { return 0.0 }
    if ([int] $Node.ExecutionTasks -eq 0) { return [double] $Node.OtherSeconds }
    $perTask = [double]::PositiveInfinity
    if ([double]::IsFinite($Rate) -and $Rate -gt 0) { $perTask = 3600.0 / $Rate }
    return [double] $Node.OtherSeconds + [int] $Node.ExecutionTasks * $perTask
}

function Read-EpicProgressCrossEpicPlanText {
    <#
    .SYNOPSIS
        Return the other epic's prepared plan text for a cross-epic edge, read from its epic-kickoff.md; '' when either is unreadable.
    .DESCRIPTION
        Reads docs/features/epics/<epic>/epic-kickoff.md and then the plan path of the
        prerequisite's kickoff row, both only through Read-EpicProgressText on
        origin/<integration branch>. A kickoff without the row, or a kickoff table that does
        not parse, gives ''.
    .PARAMETER Edge
        The record from Get-EpicProgressCrossEpicEdge.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [pscustomobject] $Edge)

    $branch = [string] $Edge.IntegrationBranch
    if (-not $branch) { $branch = "epic/$($Edge.Epic)-integration" }
    $branch = "origin/$branch"
    $kickoff = Read-EpicProgressText -RelativePath "docs/features/epics/$($Edge.Epic)/epic-kickoff.md" -IntegrationBranch $branch
    if ([string]::IsNullOrWhiteSpace($kickoff)) { return '' }
    try { $rows = @(ConvertFrom-EpicProgressKickoffRow -KickoffText $kickoff) } catch { return '' }
    $row = @($rows | Where-Object { [string] $_.Issue -eq [string] $Edge.IssueNum }) | Select-Object -First 1
    if ($null -eq $row) { return '' }
    return [string] (Read-EpicProgressText -RelativePath ([string] $row.PlanPath) -IntegrationBranch $branch)
}
