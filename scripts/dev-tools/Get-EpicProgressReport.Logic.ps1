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
