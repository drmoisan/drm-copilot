<#
.SYNOPSIS
    Print the TL;DR block and the hourly progress report of an epic or of a standalone item.

.DESCRIPTION
    Measures progress in typed steps (issue #1118): research, spec, plan, preflight, one
    execution step per plan task, review, pr, ci, and merge per item, the steps each opened
    remediation cycle adds, and the main-sync and integration-pr steps of an epic. It reads
    the epic kickoff and the feature plans from the integration branch (or from a feature
    worktree when one holds the plan), each live item checkpoint and its stage_timing, the
    epic orchestrator checkpoint, the pull request state of each feature branch, and the
    weekly quota of the active cswap account, and in epic mode the epic.md depends_on lists
    and the routing-config cap. The headline is the critical path (issue #1153): each
    feature's remaining time at its sequential task velocity, list-scheduled over the
    dependency graph under the parallel cap, plus the epic tail; the per-type sum is the
    serial upper bound. Blocked items and their dependents are excluded by recorded state.

    The pure logic lives in Get-EpicProgressReport.Logic.ps1, which this script dot-sources and
    which dot-sources the Stages, Steps, Durations, State, Metrics, Velocity, Schedule, Render,
    and Gather files.
    Every I/O call goes through a wrapper function in this script. When gh or cswap is not
    installed, or prints no parseable output, the report still prints: the pull-request state
    is empty and the quota is n/a.

    The version-3 state file at -StatePath keeps the start instant, the baseline done step and
    task counts, the weekly baseline, the check-in samples (Unix time, done steps, done tasks,
    and per-feature done tasks), the duration ledger per step type, the per-item tick anchors
    and blocked spans, and the pause spans. It is read before the first git call; a version-2
    or version-1 file or the legacy sample array is migrated.

    This file is the canonical script of the /epic-progress-report skill. The entry-point
    block at the bottom is skipped when the file is dot-sourced.

.PARAMETER EpicFolder
    Mandatory in the Epic parameter set (the default). The epic folder name under
    docs/features/epics/. It is also the epic name printed in the status heading.

.PARAMETER Issue
    Mandatory in the Item parameter set. The issue number of a standalone item: the worktree
    whose checkpoint issue-num equals it is reported, with no kickoff, epic checkpoint, or
    epic-level step. Cannot be combined with -EpicFolder.

.PARAMETER StartUtc
    Optional. The instant from which elapsed time is measured; converted to UTC. A start
    after the current instant counts as zero elapsed time. Resolution: the passed value, else
    now when -ResetBaseline is given, else the start stored in the state file. With none of
    these the script stops with an error before any git call. A passed value is persisted
    with the next state write.

.PARAMETER EpicIssue
    The epic issue number printed in the report. Default: the number on the first
    'Epic issue: #<n>' line of the kickoff file. The script stops with an error when
    neither this parameter nor the kickoff yields a number.

.PARAMETER IntegrationBranch
    The branch that holds the kickoff and the plans. Default:
    origin/epic/<EpicFolder>-integration. In item mode it is used only for plan texts that
    are not in the item worktree, and blank means none.

.PARAMETER KickoffPath
    The repository-relative path of the kickoff file on the integration branch. Default:
    docs/features/epics/<EpicFolder>/epic-kickoff.md. Only the feature-summary table, whose
    header's first cell is issue_num or Issue, is read; every other table in the file is ignored.
    Kickoff text without that header, a feature row with fewer than five cells, and a feature
    row with a blank plan cell each raise a terminating error.

.PARAMETER RepositoryRoot
    The repository root in which git runs. Default: the current location.

.PARAMETER CheckpointPath
    The epic orchestrator checkpoint. Default:
    artifacts/orchestration/epic-orchestrator-state.json under the repository root.

.PARAMETER StatePath
    The state file. Default: .claude/state/epic-progress-<EpicFolder>.json, or
    .claude/state/progress-item-<Issue>.json in item mode, under the repository root, a
    gitignored location that survives a container stop with the checkout. The directory is
    created when missing.

.PARAMETER BaselineDone
    The number of steps already complete at the start. Resolution: the passed value, else
    the current done count when -ResetBaseline is given or the state was migrated, else the
    stored value, else 0.

.PARAMETER BaselineWeeklyPct
    The weekly quota percentage at the start. Resolution: the passed value, else the stored
    value, else 0. -ResetBaseline does not change it.

.PARAMETER WaveOverheadHours
    Accepted for compatibility with default 1.25; it affects no figure, because review and
    CI are explicit steps of the step model (decision D13).

.PARAMETER SampleCap
    The maximum number of check-in samples kept in the state file. Default: 14. The duration
    ledger is not limited by it.

.PARAMETER Mode
    TLDR prints the five-line TL;DR block only; Full prints the TL;DR block followed by
    the full report. Default: Full.

.PARAMETER ResetBaseline
    Discards every stored check-in sample and blocked span, sets the start to now (unless
    -StartUtc is passed) and the baseline done count to the current done count (unless
    -BaselineDone is passed), adds the first sample, and writes the state file. The weekly
    baseline, the duration ledger, and the tick anchors are kept.

.PARAMETER PairSamples
    After the normal sample rule, keeps the newest sample and every second older sample
    and writes the state file, so the intervals match a doubled cadence. A one-shot
    command: each run halves the samples again. Cannot be combined with -ResetBaseline.

.PARAMETER StepDefaultMinutes
    A hashtable of per-type default durations in minutes that replace the built-in defaults
    for types with no measured sample, for example @{ ci = 25 }. An unknown type or a value
    that is not a number above 0 stops the script before any I/O.

.EXAMPLE
    pwsh -NoProfile -File .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1 -EpicFolder example-epic -StartUtc 2026-01-05T09:00:00Z -BaselineDone 40 -Mode TLDR

    Prints the TL;DR block for the epic in docs/features/epics/example-epic/, measuring
    from 09:00 UTC and counting 40 steps as complete at the start; both values are stored
    for later runs.

.EXAMPLE
    pwsh -NoProfile -File .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1 -Issue 42 -StartUtc 2026-01-05T09:00:00Z -Mode TLDR

    Prints the TL;DR block for the standalone item whose worktree checkpoint carries issue-num
    42, with its state in .claude/state/progress-item-42.json.

.EXAMPLE
    pwsh -NoProfile -File .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1 -EpicFolder example-epic -EpicIssue 12

    Prints the full report for epic issue 12 with the start and baseline read from the
    state file.

.EXAMPLE
    pwsh -NoProfile -File .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1 -EpicFolder example-epic -ResetBaseline

    Restarts the measurement now after a pause: the stored samples are discarded and the
    current done count becomes the baseline.

.NOTES
    The tool is read-only toward the repository and GitHub: it runs only git fetch, git
    show, git worktree list, and gh pr list, and the only file it writes is the state file
    at -StatePath (issues #1080, #1093, and #1118).
#>

[CmdletBinding(DefaultParameterSetName = 'Epic')]
param(
    [Parameter(Mandatory = $true, ParameterSetName = 'Epic')]
    [ValidateNotNullOrEmpty()]
    [string] $EpicFolder,

    [Parameter(Mandatory = $true, ParameterSetName = 'Item')]
    [ValidateRange('Positive')]
    [int] $Issue,

    [datetime] $StartUtc,

    [string] $EpicIssue = '',

    [string] $IntegrationBranch = '',

    [string] $KickoffPath = '',

    [string] $RepositoryRoot = '',

    [string] $CheckpointPath = '',

    [string] $StatePath = '',

    [int] $BaselineDone = 0,

    [double] $BaselineWeeklyPct = 0,

    [double] $WaveOverheadHours = 1.25,

    [ValidateRange(1, 100000)]
    [int] $SampleCap = 14,

    [ValidateSet('TLDR', 'Full')]
    [string] $Mode = 'Full',

    [switch] $ResetBaseline,

    [switch] $PairSamples,

    [hashtable] $StepDefaultMinutes = @{}
)

. (Join-Path -Path $PSScriptRoot -ChildPath 'Get-EpicProgressReport.Logic.ps1')

function Invoke-GitExe {
    <#
    .SYNOPSIS
        Run git with the given arguments and return its standard output lines.
    .PARAMETER GitArgs
        The git arguments.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param([Parameter(Mandatory = $true)] [string[]] $GitArgs)

    & git @GitArgs 2>$null
}

function Invoke-GhExe {
    <#
    .SYNOPSIS
        Run gh with the given arguments and return its standard output lines.
    .PARAMETER GhArgs
        The gh arguments.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param([Parameter(Mandatory = $true)] [string[]] $GhArgs)

    & gh @GhArgs 2>$null
}

function Invoke-CswapExe {
    <#
    .SYNOPSIS
        Run cswap with the given arguments and return its standard output lines.
    .PARAMETER CswapArgs
        The cswap arguments.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param([Parameter(Mandatory = $true)] [string[]] $CswapArgs)

    & cswap @CswapArgs 2>$null
}

function Test-EpicProgressCommand {
    <#
    .SYNOPSIS
        Return whether an application of the given name is installed.
    .PARAMETER Name
        The application name.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory = $true)] [string] $Name)

    return [bool] (Get-Command -Name $Name -CommandType Application -ErrorAction SilentlyContinue)
}

function Test-EpicProgressPath {
    <#
    .SYNOPSIS
        Return whether a file exists at the given path; a blank path returns $false.
    .PARAMETER Path
        The file path.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Path)

    if ([string]::IsNullOrWhiteSpace($Path)) { return $false }
    return Test-Path -LiteralPath $Path -PathType Leaf
}

function Read-EpicProgressFile {
    <#
    .SYNOPSIS
        Return the raw text of a file.
    .PARAMETER Path
        The file path.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [string] $Path)

    return Get-Content -LiteralPath $Path -Raw
}

function Write-EpicProgressState {
    <#
    .SYNOPSIS
        Write the state file content as UTF-8; the only file the report writes.
    .DESCRIPTION
        Creates the parent directory (for example .claude/state) when it is missing. Both
        writes run only inside the ShouldProcess block, so -WhatIf writes nothing.
    .PARAMETER Path
        The state file path.
    .PARAMETER Content
        The JSON text to write.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)] [string] $Path,
        [Parameter(Mandatory = $true)] [string] $Content
    )

    if ($PSCmdlet.ShouldProcess($Path, 'Write epic progress state')) {
        $directory = Split-Path -Path $Path -Parent
        if ($directory -and -not (Test-Path -LiteralPath $directory -PathType Container)) {
            $null = New-Item -ItemType Directory -Path $directory -Force
        }
        Set-Content -LiteralPath $Path -Value $Content -Encoding utf8
    }
}

function Get-EpicProgressUtcNow {
    <#
    .SYNOPSIS
        Return the current UTC instant.
    #>
    [CmdletBinding()]
    [OutputType([datetime])]
    param()

    return [datetime]::UtcNow
}

function Get-EpicProgressLastExitCode {
    <#
    .SYNOPSIS
        Return the exit code of the most recent native command ($LASTEXITCODE).
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param()

    return $LASTEXITCODE
}


function Invoke-EpicProgressReport {
    <#
    .SYNOPSIS
        Gather the report inputs through the I/O seams and return the report lines.
    .DESCRIPTION
        Wiring only; the parameters mirror the script's (Epic and Item sets). Validates
        -ResetBaseline with -PairSamples and -StepDefaultMinutes before any I/O, reads the state
        before the first git call, runs git with exactly 'fetch -q origin' (epic mode, a failure
        is a warning), 'worktree list --porcelain', and 'show', gh and cswap only when installed,
        gathers through the Gather functions, computes the velocity and the critical path, and
        writes the state only when the samples, the ledger, or the anchors changed, a pause span
        was appended, or on ResetBaseline or PairSamples. Returns the TL;DR
        lines, followed by the Full lines unless Mode is TLDR.
    .PARAMETER EpicFolder
        The epic folder name (Epic set).
    .PARAMETER Issue
        The standalone item issue number (Item set).
    .PARAMETER StartUtc
        The start instant; when not passed, resolved by Resolve-EpicProgressBaseline.
    .PARAMETER EpicIssue
        The epic issue number; blank to read it from the kickoff file.
    .PARAMETER IntegrationBranch
        The integration branch; blank for the default.
    .PARAMETER KickoffPath
        The kickoff path on the integration branch; blank for the default.
    .PARAMETER RepositoryRoot
        The repository root; blank for the current location.
    .PARAMETER CheckpointPath
        The epic orchestrator checkpoint path; blank for the default.
    .PARAMETER StatePath
        The state file path; blank for the default under .claude/state of the repository root.
    .PARAMETER BaselineDone
        The steps already complete at the start; when not passed, resolved from the reset or the state.
    .PARAMETER BaselineWeeklyPct
        The weekly quota percentage at the start; when not passed, resolved from the state.
    .PARAMETER WaveOverheadHours
        Accepted for compatibility; affects no figure.
    .PARAMETER SampleCap
        The maximum number of check-in samples kept.
    .PARAMETER Mode
        TLDR or Full.
    .PARAMETER ResetBaseline
        Discard the stored samples and blocked spans, restart the baseline now, and write the state.
    .PARAMETER PairSamples
        Pair the samples after the sample rule and write the state.
    .PARAMETER StepDefaultMinutes
        Per-type default durations in minutes.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Epic')]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Epic')] [ValidateNotNullOrEmpty()] [string] $EpicFolder,
        [Parameter(Mandatory = $true, ParameterSetName = 'Item')] [ValidateRange('Positive')] [int] $Issue,
        [datetime] $StartUtc = [datetime]::MinValue,
        [string] $EpicIssue = '',
        [string] $IntegrationBranch = '',
        [string] $KickoffPath = '',
        [string] $RepositoryRoot = '',
        [string] $CheckpointPath = '',
        [string] $StatePath = '',
        [int] $BaselineDone = 0,
        [double] $BaselineWeeklyPct = 0,
        [double] $WaveOverheadHours = 1.25,
        [ValidateRange(1, 100000)] [int] $SampleCap = 14,
        [ValidateSet('TLDR', 'Full')] [string] $Mode = 'Full',
        [switch] $ResetBaseline,
        [switch] $PairSamples,
        [hashtable] $StepDefaultMinutes = @{}
    )

    if ($ResetBaseline -and $PairSamples) {
        throw '-ResetBaseline and -PairSamples cannot be combined: a reset discards the samples that -PairSamples would pair. Run them separately.'
    }
    $defaults = Resolve-EpicProgressStepDefault -StepDefaultMinutes $StepDefaultMinutes
    Write-Verbose "-WaveOverheadHours $WaveOverheadHours is accepted for compatibility and affects no figure: review and CI are explicit steps."
    $itemMode = $PSCmdlet.ParameterSetName -eq 'Item'
    $location = (Get-Location).ProviderPath
    if ($itemMode) {
        $setting = Resolve-EpicProgressItemSetting -Issue $Issue -RepositoryRoot $RepositoryRoot -StatePath $StatePath -IntegrationBranch $IntegrationBranch -CurrentLocation $location
    } else {
        $setting = Resolve-EpicProgressSetting -EpicFolder $EpicFolder -EpicIssue $EpicIssue -IntegrationBranch $IntegrationBranch -KickoffPath $KickoffPath -RepositoryRoot $RepositoryRoot -CheckpointPath $CheckpointPath -StatePath $StatePath -CurrentLocation $location
    }
    # The state file is read before the first git call.
    $stateText = ''
    if (Test-EpicProgressPath -Path $setting.StatePath) { $stateText = Read-EpicProgressFile -Path $setting.StatePath }
    $storedState = ConvertFrom-EpicProgressStateText -Text $stateText
    $nowUtc = (Get-EpicProgressUtcNow).ToUniversalTime()
    $nowUnixSeconds = [DateTimeOffset]::new($nowUtc).ToUnixTimeSeconds()
    $baseline = Resolve-EpicProgressBaseline -StartUtc $StartUtc -StartUtcPassed:($PSBoundParameters.ContainsKey('StartUtc')) -BaselineDone $BaselineDone -BaselineDonePassed:($PSBoundParameters.ContainsKey('BaselineDone')) -BaselineWeeklyPct $BaselineWeeklyPct -BaselineWeeklyPctPassed:($PSBoundParameters.ContainsKey('BaselineWeeklyPct')) -State $storedState -ResetBaseline:$ResetBaseline -NowUtc $nowUtc
    # The pause span this run closes is taken from the newest stored sample before a reset discards
    # the samples (decision E11): the reset span, else a gap above 3600 s; a stored span is never re-appended.
    [long[]] $storedInstants = @($storedState.Samples | Where-Object { $null -ne $_ -and $null -ne $_.ts } | ForEach-Object { [long] $_.ts })
    if ($ResetBaseline) {
        $newPause = @(Get-EpicProgressResetPauseSpan -SampleInstant $storedInstants -ResumeUnixSeconds $nowUnixSeconds)
    } else {
        $newPause = @()
        if ($storedInstants.Count -gt 0) { $newPause = @(Get-EpicProgressPauseSpan -SampleInstant @(($storedInstants | Measure-Object -Maximum).Maximum, $nowUnixSeconds)) }
    }
    $pauseSpans = [object[]] (@($storedState.Pauses) + $newPause)
    # A reset discards every stored sample; the sample rule then adds the first sample (now, done).
    $priorSamples = $storedState.Samples
    if ($ResetBaseline) { $priorSamples = [object[]] @() }
    if (-not $itemMode) {
        $null = Invoke-GitExe -GitArgs @('fetch', '-q', 'origin')
        $fetchExitCode = Get-EpicProgressLastExitCode
        if ($fetchExitCode -ne 0) {
            Write-Warning "git fetch -q origin failed with exit code $fetchExitCode; the report uses the last fetched state of $($setting.IntegrationBranch)."
        }
    }
    $worktreeOf = ConvertFrom-EpicProgressWorktreeList -PorcelainLine @(Invoke-GitExe -GitArgs @('worktree', 'list', '--porcelain'))
    $ghInstalled = Test-EpicProgressCommand -Name 'gh'
    $prStateOf = {
        param([string] $Branch)
        if (-not $Branch -or -not $ghInstalled) { return '' }
        ConvertFrom-EpicProgressPrList -Json (@(Invoke-GhExe -GhArgs @('pr', 'list', '--head', $Branch, '--state', 'all', '--json', 'number,state')) -join "`n")
    }
    $items = [System.Collections.Generic.List[object]]::new()
    $epicRows = $null
    $manifestRows = @()
    $configCap = $null
    if ($itemMode) {
        $epicIssueText = [string] $Issue
        $found = Find-EpicProgressItemWorktree -Issue $epicIssueText -WorktreeMap $worktreeOf
        $items.Add((Get-EpicProgressItemInput -Issue $epicIssueText -PlanPath ([string] $found.Checkpoint.'plan-path') -WorktreePath $found.Path -IntegrationBranch $setting.IntegrationBranch -Checkpoint $found.Checkpoint -PrState (& $prStateOf $found.Branch)))
    } else {
        $kickoffText = @(Invoke-GitExe -GitArgs @('show', "$($setting.IntegrationBranch):$($setting.KickoffPath)")) -join "`n"
        $epicIssueText = $setting.EpicIssue
        if ([string]::IsNullOrWhiteSpace($epicIssueText)) { $epicIssueText = Get-EpicProgressIssueFromKickoff -KickoffText $kickoffText }
        if ([string]::IsNullOrWhiteSpace($epicIssueText)) {
            throw "The epic issue number could not be resolved: pass -EpicIssue or add an 'Epic issue: #<n>' line to $($setting.KickoffPath) on $($setting.IntegrationBranch)."
        }
        $rows = @(ConvertFrom-EpicProgressKickoffRow -KickoffText $kickoffText)
        $kickoffIssues = [string[]] @($rows | ForEach-Object { $_.Issue })
        $epicRows = Get-EpicProgressEpicCheckpointRow -CheckpointPath $setting.CheckpointPath -KickoffIssue $kickoffIssues
        # Dependency and cap inputs (decision E5); item mode reads neither.
        $manifestRows = @(Read-EpicProgressManifestFeature -KickoffIssue $kickoffIssues -CheckpointRow @($epicRows.Checkpoint.features | Where-Object { $null -ne $_ }) -ManifestPath "docs/features/epics/$EpicFolder/epic.md" -IntegrationBranch $setting.IntegrationBranch)
        $configCap = Read-EpicProgressRoutingCap -RepositoryRoot $setting.RepositoryRoot
        foreach ($row in $rows) {
            $epicRow = $epicRows.Feature[$row.Issue]
            $branch = ''
            if ($null -ne $epicRow -and $epicRow.branch_name) { $branch = [string] $epicRow.branch_name }
            $worktree = ''
            if ($branch -and $worktreeOf.ContainsKey($branch)) { $worktree = $worktreeOf[$branch] }
            $prState = & $prStateOf $branch
            $items.Add((Get-EpicProgressItemInput -Issue $row.Issue -PlanPath $row.PlanPath -WorktreePath $worktree -IntegrationBranch $setting.IntegrationBranch -Checkpoint (Read-EpicProgressItemCheckpoint -WorktreePath $worktree) -EpicRow $epicRow -PrState $prState -Wave $row.Wave -Band $row.Band))
        }
    }

    $weeklyPct = [double]::NaN
    if (Test-EpicProgressCommand -Name 'cswap') {
        $weeklyPct = Get-EpicProgressWeeklyQuota -Json (@(Invoke-CswapExe -CswapArgs @('list', '--json')) -join "`n")
    }
    # The stored spans plus the span this run closes are excluded from this run's tick batches.
    $report = Get-EpicProgressStepReport -Item $items.ToArray() -EpicCheckpoint $epicRows.Checkpoint -SyncRow @($epicRows.Sync | Where-Object { $null -ne $_ }) -EpicIssue $epicIssueText -State $storedState -NowUnixSeconds $nowUnixSeconds -Default $defaults -NoEpicStep:$itemMode -ResetBaseline:$ResetBaseline -PauseSpan $pauseSpans
    $baselineDoneValue = $baseline.BaselineDone
    if ($baseline.UseCurrentDone) { $baselineDoneValue = $report.Done }
    $baselineDoneTasksValue = $baseline.BaselineDoneTasks
    if ($baseline.UseCurrentDoneTasks) { $baselineDoneTasksValue = $report.DoneTasks }
    $selection = Select-EpicProgressSample -Sample $priorSamples -NowUnixSeconds $nowUnixSeconds -Done $report.Done -SampleCap $SampleCap
    $currentSamples = $selection.Sample
    if ($selection.Changed) {
        # The sample added for this run carries the epic and per-feature done task counts (decision E12).
        $taskCounts = @{}
        foreach ($record in $report.Feature) { $taskCounts[[string] $record.Issue] = [int] $record.TasksDone }
        $added = $currentSamples[$currentSamples.Count - 1]
        $added | Add-Member -NotePropertyName 'tasks' -NotePropertyValue $report.DoneTasks -Force
        $added | Add-Member -NotePropertyName 'features' -NotePropertyValue $taskCounts -Force
    }
    # Pairing is a one-shot rewrite applied after the sample rule (cadence change).
    if ($PairSamples) { $currentSamples = [object[]] @(Merge-EpicProgressSamplePair -Sample $currentSamples) }
    $startUnixSeconds = [DateTimeOffset]::new($baseline.StartUtc).ToUnixTimeSeconds()
    # Migrated version-2 samples carry no 'tasks' value and are passed unchanged, so they form no interval.
    $aggregate = Get-EpicProgressAggregateVelocity -Sample $currentSamples -PauseSpan $pauseSpans -StartUnixSeconds $startUnixSeconds -NowUnixSeconds $nowUnixSeconds -DoneTasks $report.DoneTasks -BaselineDoneTasks $baselineDoneTasksValue
    $criticalPath = Get-EpicProgressCriticalPathReport -Feature $report.Feature -EpicStep $report.EpicStep -Ledger $report.Ledger -Default $defaults -NowUnixSeconds $nowUnixSeconds -BlockedSince $report.BlockedSince -CheckpointRow $report.DependencyRow -ManifestRow $manifestRows -CheckpointCap $report.CheckpointCap -ConfigCap $configCap -Aggregate $aggregate -ItemMode:$itemMode
    if ($selection.Changed -or $report.LedgerChanged -or $report.ItemsChanged -or $ResetBaseline -or $PairSamples -or $newPause.Count -gt 0) {
        $stateJson = ConvertTo-EpicProgressStateJson -StartUnixSeconds $startUnixSeconds -BaselineDone $baselineDoneValue -BaselineWeeklyPct $baseline.BaselineWeeklyPct -Sample $currentSamples -Duration $report.Ledger -Item $report.Items -BaselineDoneTasks $baselineDoneTasksValue -PauseSpan $pauseSpans
        Write-EpicProgressState -Path $setting.StatePath -Content $stateJson
    }

    $subject = 'Epic'
    $epicName = $EpicFolder
    if ($itemMode) { $subject = 'Item'; $epicName = '' }
    $summary = Get-EpicProgressSummary -Feature $report.Feature -EpicStep $report.EpicStep -Estimate $report.Estimate -CriticalPath $criticalPath -Aggregate $aggregate -Unmapped $report.Unmapped -Subject $subject -StartUtc $baseline.StartUtc -NowUtc $nowUtc -WeeklyPct $weeklyPct -BaselineWeeklyPct $baseline.BaselineWeeklyPct -EpicIssue $epicIssueText -EpicName $epicName
    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.AddRange([string[]] @(Get-EpicProgressTldrLine -Summary $summary))
    if ($Mode -ne 'TLDR') { $lines.AddRange([string[]] @(Get-EpicProgressFullLine -Summary $summary)) }
    return $lines.ToArray()
}

# Entry point: skipped when the script is dot-sourced for testing. Git runs in the
# repository root, so the location is pushed there for the run and restored afterwards.
if ($MyInvocation.InvocationName -ne '.') {
    $entryRoot = $RepositoryRoot
    if ([string]::IsNullOrWhiteSpace($entryRoot)) { $entryRoot = (Get-Location).ProviderPath }
    Push-Location -LiteralPath $entryRoot
    try {
        Invoke-EpicProgressReport @PSBoundParameters
    } finally {
        Pop-Location
    }
}
