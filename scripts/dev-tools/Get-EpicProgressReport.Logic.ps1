<#
.SYNOPSIS
    Pure logic for Get-EpicProgressReport.ps1.

.DESCRIPTION
    Parsing, counting, velocity, estimate, sample-retention, formatting, and line
    composition functions for the epic progress report. Every function takes data in and
    returns data: none reads a file, starts a process, calls the network, or reads the
    clock. The main script dot-sources this file and supplies the data through its I/O
    wrapper seams. Numeric and date text uses the invariant culture so the printed lines
    do not depend on the host culture.
#>

function Test-EpicProgressJsonText {
    <#
    .SYNOPSIS
        Return whether a text is non-blank, well-formed JSON; guards every JSON conversion.
    .PARAMETER Json
        The text to test. Blank and null text return $false.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [AllowNull()] [string] $Json)

    if ([string]::IsNullOrWhiteSpace($Json)) { return $false }
    return [bool] (Test-Json -Json $Json -ErrorAction SilentlyContinue)
}

function ConvertFrom-EpicProgressKickoffRow {
    <#
    .SYNOPSIS
        Return one record (Issue, Wave, Band, PlanPath) per feature row of a kickoff table.
    .DESCRIPTION
        A feature row is a Markdown table row whose first cell is a numeric issue number of
        any length. Cells 1, 3, 4, and 5 hold the issue, the wave, the band, and the
        repository-relative plan path. Header and separator rows are ignored.
    .PARAMETER KickoffText
        The full text of the kickoff file.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $KickoffText)

    $lines = $KickoffText -split '\r?\n'
    foreach ($line in $lines) {
        if ($line -notmatch '^\| (\d+) \|') { continue }
        $cells = @($line -split '\|' | ForEach-Object { $_.Trim() })
        [pscustomobject]@{ Issue = $cells[1]; Wave = [int] $cells[3]; Band = $cells[4]; PlanPath = $cells[5] }
    }
}

function Get-EpicProgressIssueFromKickoff {
    <#
    .SYNOPSIS
        Return the digits of the first 'Epic issue: #n' marker (mid-line allowed), or $null.
    .PARAMETER KickoffText
        The full text of the kickoff file.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $KickoffText)

    $match = [regex]::Match($KickoffText, 'Epic issue: #(\d+)')
    if ($match.Success) { return $match.Groups[1].Value }
    return $null
}

function ConvertFrom-EpicProgressWorktreeList {
    <#
    .SYNOPSIS
        Return a map from branch name to worktree path from 'git worktree list --porcelain'.
    .DESCRIPTION
        Each 'worktree' line opens a record and the following 'branch refs/heads/' line
        names its branch. Detached worktrees have no branch line and are omitted.
    .PARAMETER PorcelainLine
        The porcelain output lines.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [AllowEmptyString()] [string[]] $PorcelainLine)

    $map = @{}
    $worktreePath = $null
    foreach ($entry in $PorcelainLine) {
        if ($entry -like 'worktree *') {
            $worktreePath = $entry.Substring(9)
        } elseif ($entry -like 'branch refs/heads/*') {
            $map[$entry.Substring(18)] = $worktreePath
        }
    }
    return $map
}

function ConvertFrom-EpicProgressPrList {
    <#
    .SYNOPSIS
        Return '#number state' for the first entry of a 'gh pr list --json number,state' array.
    .DESCRIPTION
        Returns an empty string for an empty array, blank or unparseable output, or an
        entry without a number.
    .PARAMETER Json
        The JSON text printed by gh.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Json)

    if (-not (Test-EpicProgressJsonText -Json $Json)) { return '' }
    $items = @(ConvertFrom-Json -InputObject $Json)
    if ($items.Count -eq 0) { return '' }
    $first = $items[0]
    if ($null -eq $first -or -not ($first.PSObject.Properties.Name -contains 'number')) { return '' }
    return "#$($first.number) $($first.state)"
}

function Get-EpicProgressWeeklyQuota {
    <#
    .SYNOPSIS
        Return usage.sevenDay.pct of the first active account in 'cswap list --json' output.
    .DESCRIPTION
        Returns NaN when no account is active, the percentage is missing, or the output is
        blank or unparseable.
    .PARAMETER Json
        The JSON text printed by cswap.
    #>
    [CmdletBinding()]
    [OutputType([double])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Json)

    if (-not (Test-EpicProgressJsonText -Json $Json)) { return [double]::NaN }
    $data = ConvertFrom-Json -InputObject $Json
    if ($null -eq $data -or -not ($data.PSObject.Properties.Name -contains 'accounts')) { return [double]::NaN }
    $active = @($data.accounts | Where-Object { $null -ne $_ -and $_.active }) | Select-Object -First 1
    if ($null -eq $active -or $null -eq $active.usage -or $null -eq $active.usage.sevenDay -or $null -eq $active.usage.sevenDay.pct) {
        return [double]::NaN
    }
    return [double] $active.usage.sevenDay.pct
}

function Get-EpicProgressTaskCount {
    <#
    .SYNOPSIS
        Return Total and Done counts of '- [ ] [P#-T#]' and '- [x] [P#-T#]' plan checkboxes.
    .PARAMETER PlanText
        The full plan text. Checkboxes without a task identifier are not counted.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $PlanText)

    $taskMatches = [regex]::Matches($PlanText, '(?m)^\s*- \[( |x)\] \[P\d+-T\d+\]')
    $done = 0
    foreach ($taskMatch in $taskMatches) {
        if ($taskMatch.Groups[1].Value -eq 'x') { $done++ }
    }
    return [pscustomobject]@{ Total = $taskMatches.Count; Done = $done }
}

function Get-EpicProgressCurrentPhase {
    <#
    .SYNOPSIS
        Return the heading text of the phase that holds the first unchecked task.
    .DESCRIPTION
        Returns the first level-2 to level-4 'Phase N' heading without its hash marks,
        'Phase N' when no heading matches, and an empty string when every task is checked.
    .PARAMETER PlanText
        The full plan text.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $PlanText)

    $first = [regex]::Match($PlanText, '(?m)^\s*- \[ \] \[P(\d+)-T\d+\]')
    if (-not $first.Success) { return '' }
    $phaseNumber = $first.Groups[1].Value
    $heading = [regex]::Match($PlanText, "(?m)^#{2,4}\s+Phase\s+$phaseNumber\b[^\r\n]*")
    if ($heading.Success) { return ($heading.Value -replace '^#+\s+', '').Trim() }
    return "Phase $phaseNumber"
}

function Get-EpicProgressFeatureState {
    <#
    .SYNOPSIS
        Classify a feature as Completed, Running, or Pending.
    .DESCRIPTION
        Completed when the merge status is 'merged' or 'worktree_removed' or the PR state
        contains MERGED; Running when a task is checked, the merge status is not
        'not_started', or a PR exists; Pending otherwise.
    .PARAMETER MergeStatus
        The checkpoint merge status ('not_started' when the feature has no entry).
    .PARAMETER PrState
        The pull-request text from ConvertFrom-EpicProgressPrList; empty when none.
    .PARAMETER Done
        The number of checked plan tasks.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [string] $MergeStatus,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $PrState,
        [Parameter(Mandatory = $true)] [int] $Done
    )

    $isMerged = ($MergeStatus -eq 'merged') -or ($MergeStatus -eq 'worktree_removed') -or ($PrState -match 'MERGED')
    if ($isMerged) { return 'Completed' }
    if ($Done -gt 0 -or $MergeStatus -ne 'not_started' -or $PrState) { return 'Running' }
    return 'Pending'
}

function Select-EpicProgressSample {
    <#
    .SYNOPSIS
        Apply the sample-retention rule for one check-in; return Sample and Changed.
    .DESCRIPTION
        A sample (ts, done) is added only when there is no previous sample, the previous
        sample has no 'ts', or it is at least 90 seconds older than now. On add, samples
        without 'ts' are dropped and only the last SampleCap samples are kept.
    .PARAMETER Sample
        The samples read from the state file.
    .PARAMETER NowUnixSeconds
        The current instant in Unix seconds.
    .PARAMETER Done
        The checked task count now.
    .PARAMETER SampleCap
        The maximum number of samples kept.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Sample,
        [Parameter(Mandatory = $true)] [long] $NowUnixSeconds,
        [Parameter(Mandatory = $true)] [int] $Done,
        [Parameter(Mandatory = $true)] [ValidateRange(1, 100000)] [int] $SampleCap
    )

    $last = $null
    if ($Sample.Count -gt 0) { $last = $Sample[$Sample.Count - 1] }
    $add = ($null -eq $last) -or -not ($last.PSObject.Properties.Name -contains 'ts') -or (($NowUnixSeconds - [long] $last.ts) -ge 90)
    if (-not $add) { return [pscustomobject]@{ Sample = $Sample; Changed = $false } }
    $kept = [System.Collections.Generic.List[object]]::new()
    foreach ($entry in $Sample) {
        if ($null -ne $entry -and $entry.PSObject.Properties.Name -contains 'ts') { $kept.Add($entry) }
    }
    $kept.Add([pscustomobject]@{ ts = $NowUnixSeconds; done = $Done })
    $retained = [object[]] @($kept | Select-Object -Skip ([math]::Max(0, $kept.Count - $SampleCap)))
    return [pscustomobject]@{ Sample = $retained; Changed = $true }
}

function Format-EpicProgressHours {
    <#
    .SYNOPSIS
        Format hours as 'H h MM min' from the rounded total minutes; 'n/a' when not finite.
    .PARAMETER Hours
        The hours to format.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [double] $Hours)

    if ([double]::IsNaN($Hours) -or [double]::IsInfinity($Hours)) { return 'n/a' }
    $minutes = [math]::Round($Hours * 60, [System.MidpointRounding]::AwayFromZero)
    $wholeHours = [math]::Floor($minutes / 60)
    return [string]::Format([cultureinfo]::InvariantCulture, '{0:N0} h {1:00} min', $wholeHours, ($minutes - 60 * $wholeHours))
}

function Format-EpicProgressClock {
    <#
    .SYNOPSIS
        Format hours as 'HH:MM' from the rounded total minutes; 'n/a' when not finite.
    .PARAMETER Hours
        The hours to format.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [double] $Hours)

    if ([double]::IsNaN($Hours) -or [double]::IsInfinity($Hours)) { return 'n/a' }
    $minutes = [math]::Round($Hours * 60)
    $wholeHours = [math]::Floor($minutes / 60)
    return [string]::Format([cultureinfo]::InvariantCulture, '{0:00}:{1:00}', $wholeHours, ($minutes - 60 * $wholeHours))
}

function Format-EpicProgressNumber {
    <#
    .SYNOPSIS
        Return a number rounded to Digits decimals as invariant text; 'n/a' when not finite.
    .PARAMETER Value
        The number to format.
    .PARAMETER Digits
        The decimal digits kept (0 to 15). The default of 15 prints the value unrounded.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [double] $Value,
        [ValidateRange(0, 15)] [int] $Digits = 15
    )

    if ([double]::IsNaN($Value) -or [double]::IsInfinity($Value)) { return 'n/a' }
    return ([math]::Round($Value, $Digits)).ToString([cultureinfo]::InvariantCulture)
}
