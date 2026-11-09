<#
.SYNOPSIS
    Gathering and composition functions for Get-EpicProgressReport.ps1: item checkpoints, plan texts, epic rows, and the step report.

.DESCRIPTION
    The reading functions call only the I/O seams of the entry script: Test-EpicProgressPath
    and Read-EpicProgressFile for files in a live worktree, and Invoke-GitExe with 'show' for
    a text on the integration branch. They start no other process and write nothing; no
    'git log' or 'git ls-tree' call is made (decision D3). Get-EpicProgressStepReport is pure:
    it composes the steps, the duration ledger, the tick anchors, and the estimate from the
    gathered records, so the composition lives outside the entry script.
    Get-EpicProgressReport.Logic.ps1 dot-sources this file; the seams it calls are defined by
    the entry script that dot-sources the Logic hub.
#>

function Read-EpicProgressItemCheckpoint {
    <#
    .SYNOPSIS
        Return the parsed artifacts/orchestration/orchestrator-state.json of a worktree; $null when absent or unparseable.
    .PARAMETER WorktreePath
        The worktree root; blank returns $null.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [AllowNull()] [string] $WorktreePath)

    if ([string]::IsNullOrWhiteSpace($WorktreePath)) { return $null }
    $path = Join-Path -Path $WorktreePath -ChildPath 'artifacts/orchestration/orchestrator-state.json'
    if (-not (Test-EpicProgressPath -Path $path)) { return $null }
    $text = Read-EpicProgressFile -Path $path
    if (-not (Test-EpicProgressJsonText -Json $text)) { return $null }
    $parsed = ConvertFrom-Json -InputObject $text
    if ($parsed -isnot [System.Management.Automation.PSCustomObject]) { return $null }
    return $parsed
}

function Read-EpicProgressText {
    <#
    .SYNOPSIS
        Return a repository-relative text from the live worktree when present, else from the integration branch, else ''.
    .PARAMETER RelativePath
        The repository-relative path.
    .PARAMETER WorktreePath
        The live worktree root; blank when none.
    .PARAMETER IntegrationBranch
        The branch for 'git show'; blank to skip the fallback.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $RelativePath,
        [AllowEmptyString()] [string] $WorktreePath = '',
        [AllowEmptyString()] [string] $IntegrationBranch = ''
    )

    if ([string]::IsNullOrWhiteSpace($RelativePath)) { return '' }
    $gitPath = $RelativePath.Replace('\', '/')
    if ($WorktreePath) {
        $livePath = Join-Path -Path $WorktreePath -ChildPath $gitPath
        if (Test-EpicProgressPath -Path $livePath) { return [string] (Read-EpicProgressFile -Path $livePath) }
    }
    if ([string]::IsNullOrWhiteSpace($IntegrationBranch)) { return '' }
    return (@(Invoke-GitExe -GitArgs @('show', "$($IntegrationBranch):$gitPath")) -join "`n")
}

function Get-EpicProgressItemInput {
    <#
    .SYNOPSIS
        Return the item record that Get-EpicProgressItemStep and Get-EpicProgressStepReport read.
    .DESCRIPTION
        The plan text and each remediation-cycle text (keyed by cycles[].plan_path, read in the
        same order: live worktree first, then git show on the integration branch) are read
        through Read-EpicProgressText. spec.md existence is tested under the checkpoint
        feature-folder in the worktree. A plan with tasks and no checkpoint is a prepared plan
        (decision D6). The blockage comes from Get-EpicProgressBlockage.
    .PARAMETER Issue
        The item issue number.
    .PARAMETER PlanPath
        The repository-relative plan path.
    .PARAMETER WorktreePath
        The live worktree root; blank when none.
    .PARAMETER IntegrationBranch
        The branch for git show fallbacks; blank for none.
    .PARAMETER Checkpoint
        The parsed item checkpoint; null when none.
    .PARAMETER EpicRow
        The epic checkpoint features row; null when none.
    .PARAMETER PrState
        The pull-request text from ConvertFrom-EpicProgressPrList; empty when none.
    .PARAMETER Wave
        The kickoff wave.
    .PARAMETER Band
        The kickoff band.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [string] $Issue,
        [AllowEmptyString()] [string] $PlanPath = '',
        [AllowEmptyString()] [string] $WorktreePath = '',
        [AllowEmptyString()] [string] $IntegrationBranch = '',
        [AllowNull()] [object] $Checkpoint = $null,
        [AllowNull()] [object] $EpicRow = $null,
        [AllowEmptyString()] [string] $PrState = '',
        [int] $Wave = 1,
        [AllowEmptyString()] [string] $Band = ''
    )

    $planText = Read-EpicProgressText -RelativePath $PlanPath -WorktreePath $WorktreePath -IntegrationBranch $IntegrationBranch
    $cycleText = @{}
    $specExists = $false
    if ($null -ne $Checkpoint) {
        foreach ($cycle in @(@($Checkpoint.remediation_loop.cycles) | Where-Object { $null -ne $_ -and $_.plan_path })) {
            $cycleText[[string] $cycle.plan_path] = Read-EpicProgressText -RelativePath ([string] $cycle.plan_path) -WorktreePath $WorktreePath -IntegrationBranch $IntegrationBranch
        }
        $folder = [string] $Checkpoint.'feature-folder'
        if ($folder -and $WorktreePath) { $specExists = Test-EpicProgressPath -Path (Join-Path -Path $WorktreePath -ChildPath "$($folder.Replace('\', '/'))/spec.md") }
    }
    $mergeStatus = 'not_started'
    if ($null -ne $EpicRow -and $EpicRow.merge_status) { $mergeStatus = [string] $EpicRow.merge_status }
    return [pscustomobject]@{
        Issue        = $Issue
        Wave         = $Wave
        Band         = $Band
        Checkpoint   = $Checkpoint
        EpicRow      = $EpicRow
        PlanText     = $planText
        PlanFile     = ($PlanPath -split '[\\/]')[-1]
        CycleText    = $cycleText
        SpecExists   = $specExists
        MergeStatus  = $mergeStatus
        PrState      = $PrState
        PreparedPlan = ($null -eq $Checkpoint) -and (Get-EpicProgressTaskCount -PlanText $planText).Total -gt 0
        Blockage     = Get-EpicProgressBlockage -Checkpoint $Checkpoint -MergeStatus $mergeStatus
    }
}

function Find-EpicProgressItemWorktree {
    <#
    .SYNOPSIS
        Return Branch, Path, and Checkpoint of the worktree whose checkpoint issue-num equals the issue.
    .DESCRIPTION
        Reads each worktree of the map (branch to worktree path) through
        Read-EpicProgressItemCheckpoint, in branch order, and raises a terminating error naming
        the issue when no checkpoint carries it.
    .PARAMETER Issue
        The item issue number.
    .PARAMETER WorktreeMap
        The map from ConvertFrom-EpicProgressWorktreeList.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [string] $Issue,
        [Parameter(Mandatory = $true)] [hashtable] $WorktreeMap
    )

    foreach ($branch in @($WorktreeMap.Keys | Sort-Object)) {
        $checkpoint = Read-EpicProgressItemCheckpoint -WorktreePath $WorktreeMap[$branch]
        if ($null -ne $checkpoint -and ([string] $checkpoint.'issue-num').Trim() -eq $Issue) {
            return [pscustomobject]@{ Branch = [string] $branch; Path = [string] $WorktreeMap[$branch]; Checkpoint = $checkpoint }
        }
    }
    throw "No worktree checkpoint (artifacts/orchestration/orchestrator-state.json) carries issue-num $Issue; start the item's orchestration run or pass the epic folder instead."
}

function Get-EpicProgressEpicCheckpointRow {
    <#
    .SYNOPSIS
        Return Checkpoint, Feature (kickoff rows by issue), Sync (rows not in the kickoff), and MergePr of the epic checkpoint.
    .PARAMETER CheckpointPath
        The epic checkpoint path; an absent or unparseable file gives empty rows.
    .PARAMETER KickoffIssue
        The issue numbers of the kickoff feature rows.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [string] $CheckpointPath,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $KickoffIssue
    )

    $checkpoint = $null
    if (Test-EpicProgressPath -Path $CheckpointPath) {
        $text = Read-EpicProgressFile -Path $CheckpointPath
        if (Test-EpicProgressJsonText -Json $text) { $checkpoint = ConvertFrom-Json -InputObject $text }
    }
    $feature = @{}
    $sync = [System.Collections.Generic.List[object]]::new()
    $mergePr = $null
    if ($checkpoint -is [System.Management.Automation.PSCustomObject]) {
        $mergePr = $checkpoint.epic_merge_pr
        foreach ($row in @(@($checkpoint.features) | Where-Object { $null -ne $_ -and $null -ne $_.issue_num })) {
            if ($KickoffIssue -contains [string] $row.issue_num) { $feature[[string] $row.issue_num] = $row } else { $sync.Add($row) }
        }
    } else {
        $checkpoint = $null
    }
    return [pscustomobject]@{ Checkpoint = $checkpoint; Feature = $feature; Sync = [object[]] $sync.ToArray(); MergePr = $mergePr }
}

function Read-EpicProgressManifestFeature {
    <#
    .SYNOPSIS
        Return the epic.md frontmatter feature rows (issue_num, feature_folder, depends_on) when a kickoff feature has no checkpoint depends_on key (decision E5).
    .DESCRIPTION
        When every kickoff issue has an epic checkpoint row that carries a depends_on key, no
        row is returned and no git call is made. Otherwise the manifest is read once through
        Read-EpicProgressText on the integration branch, and the rows of the frontmatter
        features list are returned; a row carries depends_on only when the manifest gives it
        as an inline flow list (for example [12, 13] or []). An unreadable manifest, text
        without frontmatter, and a block-style depends_on list each give no rows, never an
        error, so the schedule falls back to the other sources.
    .PARAMETER KickoffIssue
        The issue numbers of the kickoff feature rows.
    .PARAMETER CheckpointRow
        The epic checkpoint features rows; empty for none.
    .PARAMETER ManifestPath
        The repository-relative path of epic.md.
    .PARAMETER IntegrationBranch
        The branch for 'git show'.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $KickoffIssue,
        [AllowEmptyCollection()] [object[]] $CheckpointRow = @(),
        [Parameter(Mandatory = $true)] [string] $ManifestPath,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $IntegrationBranch
    )

    $keyed = @($CheckpointRow | Where-Object { $null -ne $_ -and $null -ne $_.issue_num -and $_.PSObject.Properties.Name -contains 'depends_on' } | ForEach-Object { [string] $_.issue_num })
    if (@($KickoffIssue | Where-Object { $keyed -notcontains $_ }).Count -eq 0) { return }
    $text = Read-EpicProgressText -RelativePath $ManifestPath -IntegrationBranch $IntegrationBranch
    $lines = @($text -split "`r?`n")
    if ($lines.Count -lt 2 -or $lines[0].Trim() -ne '---') { return }
    $rows = [System.Collections.Generic.List[System.Collections.Specialized.OrderedDictionary]]::new()
    $inFeatures = $false
    $current = $null
    for ($index = 1; $index -lt $lines.Count; $index++) {
        $line = $lines[$index]
        if ($line.Trim() -eq '---') { break }
        if ([string]::IsNullOrWhiteSpace($line) -or $line.Trim().StartsWith('#')) { continue }
        if ($line -match '^\S') {
            $inFeatures = $line -match '^features:\s*$'
            $current = $null
            continue
        }
        if (-not $inFeatures) { continue }
        $pair = $null
        if ($line -match '^\s*-\s+([A-Za-z_]+):\s*(.*)$') {
            $current = [ordered]@{}
            $rows.Add($current)
            $pair = @($Matches[1], $Matches[2])
        } elseif ($line -match '^\s*-') {
            # A block-style list item: this reader parses inline lists only.
            return
        } elseif ($null -ne $current -and $line -match '^\s+([A-Za-z_]+):\s*(.*)$') {
            $pair = @($Matches[1], $Matches[2])
        }
        if ($null -eq $pair) { continue }
        $value = ([string] $pair[1]).Trim()
        if ($pair[0] -ne 'depends_on') {
            $current[$pair[0]] = $value.Trim('"', "'")
            continue
        }
        if ($value -notmatch '^\[(.*)\]$') { return }
        $current['depends_on'] = [string[]] @($Matches[1] -split ',' | ForEach-Object { $_.Trim().Trim('"', "'") } | Where-Object { $_ })
    }
    foreach ($row in $rows) { [pscustomobject] $row }
}

function Read-EpicProgressRoutingCap {
    <#
    .SYNOPSIS
        Return codex_topology_policy.parallelism.default_max_parallel_features of config/orchestration-routing.json; null when the file or key is missing.
    .DESCRIPTION
        Reads the file through Test-EpicProgressPath and Read-EpicProgressFile; unparseable text
        also gives null. The value is returned as parsed, and Resolve-EpicProgressParallelCap
        validates it.
    .PARAMETER RepositoryRoot
        The repository root that holds config/orchestration-routing.json.
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $RepositoryRoot)

    $path = Join-Path -Path $RepositoryRoot -ChildPath 'config/orchestration-routing.json'
    if (-not (Test-EpicProgressPath -Path $path)) { return $null }
    $text = Read-EpicProgressFile -Path $path
    if (-not (Test-EpicProgressJsonText -Json $text)) { return $null }
    $parallelism = (ConvertFrom-Json -InputObject $text).codex_topology_policy.parallelism
    if ($null -eq $parallelism -or -not ($parallelism.PSObject.Properties.Name -contains 'default_max_parallel_features')) { return $null }
    return $parallelism.default_max_parallel_features
}

function Get-EpicProgressStepReport {
    <#
    .SYNOPSIS
        Compose the steps, feature records, duration ledger, tick anchors, and estimate from the gathered item records; pure.
    .DESCRIPTION
        For each item: the steps (Get-EpicProgressItemStep), the stage samples and unmapped
        time, the approximate samples, the blocked span (opened at the first blocked
        observation and cleared at the first unblocked one), and the batched-tick samples of
        the plan and of each cycle plan (skipped for a merged item). After each plan file's tick
        split, an in-progress execution step of that plan file that carries a start takes the
        later of that start and the plan anchor's LastTickUnixSeconds (the anchor as updated by
        this run), so the running task is timed from the last checked task rather than from the
        start of the whole execution stage. An item whose merge step is done has no entry in
        the returned Items table, and ItemsChanged is set for it only when the stored state held
        an entry for it; the duration ledger keeps its samples. ResetBaseline clears every
        blocked span and keeps the ledger and the anchors (decision D10). Unless NoEpicStep is
        set, the epic-level steps and the main-sync samples are added. The ledger is merged
        once, and the estimate is computed over every step. Each tick batch excludes the union
        of the PauseSpan spans and the item's blocked span (Get-EpicProgressExcludedSecond), so
        neither paused nor blocked time enters a per-task sample (decision E11). Each feature
        record also carries its folder basename, blocked flag, steps, and plan task counts, and
        the report returns the epic task counts, the epic checkpoint max_parallel_features
        value, its features rows (the depends_on source), and the blocked spans (decision E5).
    .PARAMETER Item
        The item records from Get-EpicProgressItemInput.
    .PARAMETER EpicCheckpoint
        The parsed epic checkpoint; null when none.
    .PARAMETER SyncRow
        The sync rows from Get-EpicProgressEpicCheckpointRow.
    .PARAMETER EpicIssue
        The epic (or item) issue number.
    .PARAMETER State
        The parsed state from ConvertFrom-EpicProgressStateText.
    .PARAMETER NowUnixSeconds
        The current epoch second.
    .PARAMETER Default
        The default seconds per type from Resolve-EpicProgressStepDefault.
    .PARAMETER NoEpicStep
        Item mode: no epic-level step is added.
    .PARAMETER ResetBaseline
        Clear the blocked spans.
    .PARAMETER PauseSpan
        The pause spans (startUnixSeconds, endUnixSeconds) excluded from tick batches; empty (the default) for none.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Item,
        [AllowNull()] [object] $EpicCheckpoint = $null,
        [AllowEmptyCollection()] [object[]] $SyncRow = @(),
        [Parameter(Mandatory = $true)] [string] $EpicIssue,
        [Parameter(Mandatory = $true)] [pscustomobject] $State,
        [Parameter(Mandatory = $true)] [long] $NowUnixSeconds,
        [Parameter(Mandatory = $true)] [hashtable] $Default,
        [switch] $NoEpicStep,
        [switch] $ResetBaseline,
        [AllowEmptyCollection()] [object[]] $PauseSpan = @()
    )

    $samples = [System.Collections.Generic.List[object]]::new()
    $unmapped = [System.Collections.Generic.List[object]]::new()
    $items = @{}
    $itemsChanged = $false
    foreach ($issue in $State.Items.Keys) {
        $stored = $State.Items[$issue]
        $since = $stored.BlockedSinceUnixSeconds
        if ($ResetBaseline -and $null -ne $since) { $since = $null; $itemsChanged = $true }
        $items[[string] $issue] = [pscustomobject]@{ Plans = $stored.Plans.Clone(); BlockedSinceUnixSeconds = $since }
    }
    $features = [System.Collections.Generic.List[object]]::new()
    $featureSteps = @{}
    $allSteps = [System.Collections.Generic.List[object]]::new()
    $blockedSince = @{}
    foreach ($record in $Item) {
        $issue = [string] $record.Issue
        $steps = @(Get-EpicProgressItemStep -Item $record)
        $featureSteps[$issue] = $steps
        foreach ($step in $steps) { $allSteps.Add($step) }
        $stageRecords = @()
        if ($null -ne $record.Checkpoint) { $stageRecords = @(ConvertFrom-EpicProgressStageTiming -StageTiming @($record.Checkpoint.stage_timing)) }
        foreach ($result in @(
                (Get-EpicProgressStageSample -Issue $issue -StageRecord $stageRecords -RecordedUnixSeconds $NowUnixSeconds)
                (Get-EpicProgressApproximateSample -Issue $issue -Checkpoint $record.Checkpoint -EpicRow $record.EpicRow -RecordedUnixSeconds $NowUnixSeconds))) {
            foreach ($sampleEntry in $result.Sample) { $samples.Add($sampleEntry) }
            foreach ($unmappedEntry in $result.Unmapped) { $unmapped.Add($unmappedEntry) }
        }
        if (-not $items.ContainsKey($issue)) { $items[$issue] = [pscustomobject]@{ Plans = @{}; BlockedSinceUnixSeconds = $null } }
        $entry = $items[$issue]
        $since = $entry.BlockedSinceUnixSeconds
        $merged = @($steps | Where-Object { $_.Status -ne 'done' }).Count -eq 0 -and ([string] $record.MergeStatus -in @('merged', 'worktree_removed') -or [string] $record.PrState -match 'MERGED')
        if (-not $merged) {
            $execution = @($stageRecords | Where-Object { $_.Type -eq 'execution' } | Sort-Object -Property Attempt) | Select-Object -Last 1
            $planTexts = [ordered]@{}
            if ($record.PlanFile -and -not [string]::IsNullOrEmpty([string] $record.PlanText)) { $planTexts[[string] $record.PlanFile] = [string] $record.PlanText }
            foreach ($cyclePath in @($record.CycleText.Keys)) { $planTexts[($cyclePath -split '[\\/]')[-1]] = [string] $record.CycleText[$cyclePath] }
            foreach ($planFile in $planTexts.Keys) {
                $anchor = $null
                if ($entry.Plans.ContainsKey($planFile)) { $anchor = $entry.Plans[$planFile] }
                $intervalStart = $NowUnixSeconds
                if ($null -ne $anchor) { $intervalStart = [long] $anchor.LastTickUnixSeconds }
                $blocked = Get-EpicProgressExcludedSecond -PauseSpan $PauseSpan -BlockedSinceUnixSeconds $since -IntervalStartUnixSeconds $intervalStart -IntervalEndUnixSeconds $NowUnixSeconds
                $stageForPlan = $null
                if ($planFile -eq $record.PlanFile) { $stageForPlan = $execution }
                $tick = Get-EpicProgressTickSample -Issue $issue -PlanFile $planFile -PlanText $planTexts[$planFile] -Anchor $anchor -NowUnixSeconds $NowUnixSeconds -BlockedSecond $blocked -ExecutionRecord $stageForPlan
                foreach ($sample in $tick.Sample) { $samples.Add($sample) }
                if ($tick.Changed) { $entry.Plans[$planFile] = $tick.Anchor; $itemsChanged = $true }
                # The in-progress task of this plan started at its last tick when that is later than the stage start.
                $lastTick = [long] $entry.Plans[$planFile].LastTickUnixSeconds
                $prefix = "$issue|exec|$planFile|"
                foreach ($runningStep in @($steps | Where-Object { $_.Type -eq 'execution' -and $_.Status -eq 'in_progress' -and $null -ne $_.StartedUnixSeconds -and ([string] $_.Key).StartsWith($prefix) })) {
                    $runningStep.StartedUnixSeconds = [math]::Max([long] $runningStep.StartedUnixSeconds, $lastTick)
                }
            }
        }
        if ($record.Blockage.Blocked -and $null -eq $since) { $entry.BlockedSinceUnixSeconds = $NowUnixSeconds; $itemsChanged = $true }
        if (-not $record.Blockage.Blocked -and $null -ne $since) { $entry.BlockedSinceUnixSeconds = $null; $itemsChanged = $true }
        if ($null -ne $entry.BlockedSinceUnixSeconds) { $blockedSince[$issue] = $entry.BlockedSinceUnixSeconds }
        if (@($steps | Where-Object { $_.Type -eq 'merge' -and $_.Status -eq 'done' }).Count -gt 0) {
            # A merged item keeps no state entry, so the state file does not grow with merged items.
            if ($State.Items.ContainsKey($issue)) { $itemsChanged = $true }
            $items.Remove($issue)
        } elseif ($entry.Plans.Count -eq 0 -and $null -eq $entry.BlockedSinceUnixSeconds) {
            $items.Remove($issue)
        }

        $count = Get-EpicProgressStepCount -Step $steps
        $tasks = Get-EpicProgressTaskCount -PlanText ([string] $record.PlanText)
        $featureState = Get-EpicProgressFeatureState -MergeStatus $record.MergeStatus -PrState $record.PrState -Done $tasks.Done
        if ($featureState -eq 'Pending' -and $null -ne $record.Checkpoint) { $featureState = 'Running' }
        if ($featureState -ne 'Completed' -and $record.Blockage.Blocked) { $featureState = 'Blocked' }
        # The folder basename matches a feature-folder depends_on reference (decision E5).
        $folderValue = ''
        if ($null -ne $record.Checkpoint -and $record.Checkpoint.'feature-folder') { $folderValue = [string] $record.Checkpoint.'feature-folder' }
        if ($null -ne $record.EpicRow -and $record.EpicRow.feature_folder) { $folderValue = [string] $record.EpicRow.feature_folder }
        $folderHint = ConvertTo-EpicProgressFolderHint -Value $folderValue
        $features.Add([pscustomobject]@{
                Issue = $issue; Wave = $record.Wave; Band = $record.Band; Total = $count.Total; Done = $count.Done; State = $featureState
                Phase = (Get-EpicProgressCurrentPhase -PlanText ([string] $record.PlanText)); Pr = $record.PrState; BlockedReason = $record.Blockage.Reason
                Folder = $folderHint; Blocked = [bool] $record.Blockage.Blocked; Step = [object[]] $steps
                TasksDone = $tasks.Done; TasksTotal = $tasks.Total
            })
    }
    $epicSteps = @()
    if (-not $NoEpicStep) {
        $kickoffIssues = [string[]] @($Item | ForEach-Object { [string] $_.Issue })
        $epicSteps = @(Get-EpicProgressEpicStep -Checkpoint $EpicCheckpoint -KickoffIssue $kickoffIssues -EpicIssue $EpicIssue)
        foreach ($row in $SyncRow) {
            foreach ($entry in (Get-EpicProgressApproximateSample -Issue ([string] $row.issue_num) -EpicRow $row -EpicIssue $EpicIssue -SyncRow -RecordedUnixSeconds $NowUnixSeconds).Sample) { $samples.Add($entry) }
        }
    }
    $merge = Merge-EpicProgressDuration -Ledger $State.Durations -Sample $samples.ToArray()
    $estimate = Get-EpicProgressTypeEstimate -Step @(@($allSteps.ToArray()) + @($epicSteps)) -Ledger $merge.Ledger -Default $Default -NowUnixSeconds $NowUnixSeconds -BlockedSince $blockedSince
    $done = @($allSteps | Where-Object { $_.Status -eq 'done' }).Count + @($epicSteps | Where-Object { $_.Status -eq 'done' }).Count
    $checkpointCap = $null
    $dependencyRow = @()
    if ($null -ne $EpicCheckpoint) {
        if ($EpicCheckpoint.PSObject.Properties.Name -contains 'max_parallel_features') { $checkpointCap = $EpicCheckpoint.max_parallel_features }
        $dependencyRow = @(@($EpicCheckpoint.features) | Where-Object { $null -ne $_ })
    }
    return [pscustomobject]@{
        Feature       = [object[]] $features.ToArray()
        EpicStep      = [object[]] $epicSteps
        Done          = $done
        DoneTasks     = [int] (@($features | ForEach-Object { $_.TasksDone }) | Measure-Object -Sum).Sum
        TotalTasks    = [int] (@($features | ForEach-Object { $_.TasksTotal }) | Measure-Object -Sum).Sum
        Ledger        = $merge.Ledger
        LedgerChanged = $merge.Changed
        Items         = $items
        ItemsChanged  = $itemsChanged
        Estimate      = $estimate
        BlockedSince  = $blockedSince
        CheckpointCap = $checkpointCap
        DependencyRow = [object[]] $dependencyRow
        Unmapped      = [object[]] $unmapped.ToArray()
    }
}
