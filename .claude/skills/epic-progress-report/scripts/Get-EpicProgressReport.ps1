<#
.SYNOPSIS
    Print the TL;DR block and the hourly progress report of an epic.

.DESCRIPTION
    Reads the epic kickoff and the feature plans from the integration branch (or from a
    feature worktree when one holds the plan), the epic orchestrator checkpoint, the pull
    request state of each feature branch, and the weekly quota of the active cswap
    account, then prints the task progress, the per-feature state, the average and
    recent velocity, the sample standard deviation, the estimated time remaining, and the
    weekly quota.

    The pure logic lives in Get-EpicProgressReport.Logic.ps1, which this script
    dot-sources. Every I/O call goes through a wrapper function in this script. When gh
    or cswap is not installed, or prints no parseable output, the report still prints:
    the pull-request state is empty and the quota is n/a.

    A check-in sample (Unix time and done count) is kept in the state file at -StatePath
    when the previous sample is at least 90 seconds old; the recent velocity and its
    standard deviation are computed from those samples.

    The entry-point block at the bottom is skipped when the file is dot-sourced.

.PARAMETER EpicFolder
    Mandatory. The epic folder name under docs/features/epics/. It is also the epic name
    printed in the status heading.

.PARAMETER StartUtc
    Mandatory. The instant from which elapsed time and average velocity are measured;
    converted to UTC. A start after the current instant counts as zero elapsed time.

.PARAMETER EpicIssue
    The epic issue number printed in the report. Default: the number on the first
    'Epic issue: #<n>' line of the kickoff file. The script stops with an error when
    neither this parameter nor the kickoff yields a number.

.PARAMETER IntegrationBranch
    The branch that holds the kickoff and the plans. Default:
    origin/epic/<EpicFolder>-integration.

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
    The state file that keeps the check-in samples. Default:
    epic-progress-<EpicFolder>.json under the system temporary directory, never inside the
    repository.

.PARAMETER BaselineDone
    The number of tasks already complete at -StartUtc. Default: 0.

.PARAMETER BaselineWeeklyPct
    The weekly quota percentage at -StartUtc. Default: 0.

.PARAMETER WaveOverheadHours
    The review and CI hours added per open wave in the wave-parallel estimate.
    Default: 1.25.

.PARAMETER SampleCap
    The maximum number of check-in samples kept in the state file. Default: 14.

.PARAMETER Mode
    TLDR prints the four-line TL;DR block only; Full prints the TL;DR block followed by
    the full report. Default: Full.

.EXAMPLE
    pwsh -NoProfile -File scripts/dev-tools/Get-EpicProgressReport.ps1 -EpicFolder example-epic -StartUtc 2026-01-05T09:00:00Z -Mode TLDR

    Prints the TL;DR block for the epic in docs/features/epics/example-epic/, measuring
    from 09:00 UTC with no baseline tasks.

.EXAMPLE
    pwsh -NoProfile -File scripts/dev-tools/Get-EpicProgressReport.ps1 -EpicFolder example-epic -StartUtc 2026-01-05T09:00:00Z -BaselineDone 40 -EpicIssue 12

    Prints the full report for epic issue 12, counting 40 tasks as complete at the start.

.NOTES
    The tool is read-only toward the repository and GitHub: it runs only git fetch, git
    show, git worktree list, and gh pr list, and the only file it writes is the state file
    at -StatePath (issue #1080).
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $EpicFolder,

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
    [string] $Mode = 'Full'
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

    if ($PSCmdlet.ShouldProcess($Path, 'Write epic progress state')) { Set-Content -LiteralPath $Path -Value $Content -Encoding utf8 }
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
        Wiring only. Runs git with exactly 'fetch -q origin', 'worktree list --porcelain',
        and 'show <IntegrationBranch>:<path>'; runs 'gh pr list' only when gh is installed
        and 'cswap list --json' only when cswap is installed; treats an unparseable
        checkpoint or state file as empty; writes the state file only when the sample set
        changed. When 'git fetch -q origin' exits with a non-zero code, writes a warning
        naming the code and continues with the last fetched state of the integration branch.
        Returns the TL;DR lines, followed by the Full lines unless Mode is TLDR.
    .PARAMETER EpicFolder
        The epic folder name; also the epic name in the status heading.
    .PARAMETER StartUtc
        The start instant.
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
        The tasks already complete at StartUtc.
    .PARAMETER BaselineWeeklyPct
        The weekly quota percentage at StartUtc.
    .PARAMETER WaveOverheadHours
        The hours added per open wave.
    .PARAMETER SampleCap
        The maximum number of samples kept.
    .PARAMETER Mode
        TLDR or Full.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory = $true)] [string] $EpicFolder,
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
        [ValidateSet('TLDR', 'Full')] [string] $Mode = 'Full'
    )

    $setting = Resolve-EpicProgressSetting -EpicFolder $EpicFolder -EpicIssue $EpicIssue -IntegrationBranch $IntegrationBranch -KickoffPath $KickoffPath -RepositoryRoot $RepositoryRoot -CheckpointPath $CheckpointPath -StatePath $StatePath -CurrentLocation (Get-Location).ProviderPath
    # The state file is read before the first git call.
    $stateText = ''
    if (Test-EpicProgressPath -Path $setting.StatePath) { $stateText = Read-EpicProgressFile -Path $setting.StatePath }
    $storedState = ConvertFrom-EpicProgressStateText -Text $stateText
    $nowUtc = (Get-EpicProgressUtcNow).ToUniversalTime()
    $baseline = Resolve-EpicProgressBaseline -StartUtc $StartUtc -StartUtcPassed:($PSBoundParameters.ContainsKey('StartUtc')) -BaselineDone $BaselineDone -BaselineDonePassed:($PSBoundParameters.ContainsKey('BaselineDone')) -BaselineWeeklyPct $BaselineWeeklyPct -BaselineWeeklyPctPassed:($PSBoundParameters.ContainsKey('BaselineWeeklyPct')) -State $storedState -NowUtc $nowUtc
    $null = Invoke-GitExe -GitArgs @('fetch', '-q', 'origin')
    $fetchExitCode = Get-EpicProgressLastExitCode
    if ($fetchExitCode -ne 0) {
        Write-Warning "git fetch -q origin failed with exit code $fetchExitCode; the report uses the last fetched state of $($setting.IntegrationBranch)."
    }
    $worktreeLines = @(Invoke-GitExe -GitArgs @('worktree', 'list', '--porcelain'))
    $worktreeOf = ConvertFrom-EpicProgressWorktreeList -PorcelainLine $worktreeLines
    $kickoffText = @(Invoke-GitExe -GitArgs @('show', "$($setting.IntegrationBranch):$($setting.KickoffPath)")) -join "`n"

    $epicIssueText = $setting.EpicIssue
    if ([string]::IsNullOrWhiteSpace($epicIssueText)) { $epicIssueText = Get-EpicProgressIssueFromKickoff -KickoffText $kickoffText }
    if ([string]::IsNullOrWhiteSpace($epicIssueText)) {
        throw "The epic issue number could not be resolved: pass -EpicIssue or add an 'Epic issue: #<n>' line to $($setting.KickoffPath) on $($setting.IntegrationBranch)."
    }

    $checkpointFeature = @{}
    if (Test-EpicProgressPath -Path $setting.CheckpointPath) {
        $checkpointText = Read-EpicProgressFile -Path $setting.CheckpointPath
        if (Test-EpicProgressJsonText -Json $checkpointText) {
            $checkpoint = ConvertFrom-Json -InputObject $checkpointText
            $checkpointEntries = @($checkpoint.features)
            foreach ($checkpointEntry in $checkpointEntries) {
                if ($null -ne $checkpointEntry -and $null -ne $checkpointEntry.issue_num) { $checkpointFeature["$($checkpointEntry.issue_num)"] = $checkpointEntry }
            }
        }
    }

    $ghInstalled = Test-EpicProgressCommand -Name 'gh'
    $features = [System.Collections.Generic.List[object]]::new()
    $rows = @(ConvertFrom-EpicProgressKickoffRow -KickoffText $kickoffText)
    foreach ($row in $rows) {
        $checkpointEntry = $checkpointFeature[$row.Issue]
        $branch = ''
        $mergeStatus = 'not_started'
        if ($null -ne $checkpointEntry) {
            if ($checkpointEntry.branch_name) { $branch = [string] $checkpointEntry.branch_name }
            if ($checkpointEntry.merge_status) { $mergeStatus = [string] $checkpointEntry.merge_status }
        }
        $prState = ''
        if ($branch -and $ghInstalled) {
            $prJson = @(Invoke-GhExe -GhArgs @('pr', 'list', '--head', $branch, '--state', 'all', '--json', 'number,state')) -join "`n"
            $prState = ConvertFrom-EpicProgressPrList -Json $prJson
        }
        $planText = $null
        if ($branch -and $worktreeOf.ContainsKey($branch)) {
            $livePath = Join-Path -Path $worktreeOf[$branch] -ChildPath $row.PlanPath
            if (Test-EpicProgressPath -Path $livePath) { $planText = Read-EpicProgressFile -Path $livePath }
        }
        if ($null -eq $planText) { $planText = @(Invoke-GitExe -GitArgs @('show', "$($setting.IntegrationBranch):$($row.PlanPath)")) -join "`n" }
        $count = Get-EpicProgressTaskCount -PlanText $planText
        $features.Add([pscustomobject]@{
                Issue = $row.Issue; Wave = $row.Wave; Band = $row.Band; Total = $count.Total; Done = $count.Done
                State = (Get-EpicProgressFeatureState -MergeStatus $mergeStatus -PrState $prState -Done $count.Done)
                Phase = (Get-EpicProgressCurrentPhase -PlanText $planText); Pr = $prState
            })
    }

    $weeklyPct = [double]::NaN
    if (Test-EpicProgressCommand -Name 'cswap') {
        $quotaJson = @(Invoke-CswapExe -CswapArgs @('list', '--json')) -join "`n"
        $weeklyPct = Get-EpicProgressWeeklyQuota -Json $quotaJson
    }

    $nowUnixSeconds = [DateTimeOffset]::new($nowUtc).ToUnixTimeSeconds()
    $done = 0
    foreach ($record in $features) { $done += $record.Done }
    $baselineDoneValue = $baseline.BaselineDone
    if ($baseline.UseCurrentDone) { $baselineDoneValue = $done }
    $selection = Select-EpicProgressSample -Sample $storedState.Samples -NowUnixSeconds $nowUnixSeconds -Done $done -SampleCap $SampleCap
    if ($selection.Changed) {
        $startUnixSeconds = [DateTimeOffset]::new($baseline.StartUtc).ToUnixTimeSeconds()
        $stateJson = ConvertTo-EpicProgressStateJson -StartUnixSeconds $startUnixSeconds -BaselineDone $baselineDoneValue -BaselineWeeklyPct $baseline.BaselineWeeklyPct -Sample $selection.Sample
        Write-EpicProgressState -Path $setting.StatePath -Content $stateJson
    }

    $summary = Get-EpicProgressSummary -Feature $features.ToArray() -BaselineDone $baselineDoneValue -StartUtc $baseline.StartUtc -NowUtc $nowUtc -Sample $selection.Sample -WaveOverheadHours $WaveOverheadHours -WeeklyPct $weeklyPct -BaselineWeeklyPct $baseline.BaselineWeeklyPct -EpicIssue $epicIssueText -EpicName $EpicFolder
    $lines = [System.Collections.Generic.List[string]]::new()
    $tldrLines = Get-EpicProgressTldrLine -Summary $summary
    $lines.AddRange([string[]] $tldrLines)
    if ($Mode -ne 'TLDR') {
        $fullLines = Get-EpicProgressFullLine -Summary $summary
        $lines.AddRange([string[]] $fullLines)
    }
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
