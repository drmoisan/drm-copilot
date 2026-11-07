<#
.SYNOPSIS
    Stage timing report functions for the orchestrator evidence of issue #1097 (stage B).

.DESCRIPTION
    The orchestrator main session commits one evidence file per issue, named
    stage-timing.<timestamp>.json, that holds a JSON object with 'issue-num' (a string of
    decimal digits) and 'stage_timing' (a list of entries with 'stage', 'attempt',
    'started_at', and 'ended_at'; 'ended_at' is null while a stage is open). This module reads
    those files, computes per-issue stage totals and per-stage medians, and renders them as text.

    Read-StageTimingEvidence is the only function that touches the file system, and it writes
    nothing. Get-StageTimingSummary and Format-StageTimingReport are pure. The entry script is
    scripts/dev-tools/Get-StageTimingReport.ps1.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:IsoFormats = [string[]]@(
    "yyyy-MM-dd'T'HH:mm:ss.FFFFFFFK",
    "yyyy-MM-dd'T'HH:mm:ssK",
    "yyyy-MM-dd'T'HH:mmK"
)

function Read-StageTimingEvidence {
    <#
    .SYNOPSIS
        Reads every stage-timing.*.json file below a root and returns its name and text.

    .DESCRIPTION
        Returns one object with Name (the path relative to the root, with forward slashes) and
        Text for each matching file, in ordinal name order. It throws when the root is absent
        and writes nothing.

    .PARAMETER Root
        The folder searched recursively for stage-timing.*.json files.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Root
    )

    if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
        throw "Stage timing evidence root not found: $Root"
    }

    $rootFull = (Resolve-Path -LiteralPath $Root).ProviderPath
    $found = [System.Collections.Generic.List[object]]::new()
    $files = Get-ChildItem -LiteralPath $rootFull -Filter 'stage-timing.*.json' -File -Recurse
    foreach ($file in $files) {
        $relative = [System.IO.Path]::GetRelativePath($rootFull, $file.FullName).Replace('\', '/')
        $found.Add([pscustomobject]@{
                Name = $relative
                Text = [System.IO.File]::ReadAllText($file.FullName)
            })
    }

    $found.Sort([System.Comparison[object]] { param($left, $right) [string]::CompareOrdinal($left.Name, $right.Name) })
    foreach ($item in $found) {
        $item
    }
}

function ConvertTo-StageTimingInstant {
    <#
    .SYNOPSIS
        Parses an ISO-8601 time string to a DateTimeOffset, or returns null when it is not one.
    #>
    [CmdletBinding()]
    [OutputType([System.DateTimeOffset])]
    param(
        [Parameter()]
        [AllowNull()]
        [object]$Value
    )

    if ($Value -isnot [string] -or [string]::IsNullOrWhiteSpace($Value)) {
        return $null
    }

    $parsed = [System.DateTimeOffset]::MinValue
    $styles = [System.Globalization.DateTimeStyles]::AssumeUniversal
    $culture = [System.Globalization.CultureInfo]::InvariantCulture
    if ([System.DateTimeOffset]::TryParseExact($Value, $script:IsoFormats, $culture, $styles, [ref]$parsed)) {
        return $parsed
    }

    return $null
}

function ConvertFrom-StageTimingText {
    <#
    .SYNOPSIS
        Parses one evidence file text into its issue number and entry list, or a skip reason.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Text
    )

    try {
        $root = ConvertFrom-Json -InputObject $Text -DateKind String -NoEnumerate -ErrorAction Stop
    }
    catch {
        return [pscustomobject]@{ Ok = $false; Reason = "not valid JSON: $($_.Exception.Message)"; Issue = ''; Entries = @() }
    }

    if ($root -isnot [System.Management.Automation.PSCustomObject]) {
        return [pscustomobject]@{ Ok = $false; Reason = 'the JSON root is not an object'; Issue = ''; Entries = @() }
    }

    $issueProperty = $root.PSObject.Properties['issue-num']
    $issue = if ($null -ne $issueProperty) { $issueProperty.Value } else { $null }
    if ($issue -isnot [string] -or [string]::IsNullOrWhiteSpace($issue)) {
        return [pscustomobject]@{ Ok = $false; Reason = 'issue-num is missing or blank'; Issue = ''; Entries = @() }
    }

    $listProperty = $root.PSObject.Properties['stage_timing']
    # An if-expression would unroll a one-element list to its element, so assign in statements.
    $list = $null
    if ($null -ne $listProperty) {
        $list = $listProperty.Value
    }

    if ($list -isnot [System.Array]) {
        return [pscustomobject]@{ Ok = $false; Reason = 'stage_timing is not a list'; Issue = $issue.Trim(); Entries = @() }
    }

    return [pscustomobject]@{ Ok = $true; Reason = ''; Issue = $issue.Trim(); Entries = $list }
}

function ConvertTo-StageTimingRecord {
    <#
    .SYNOPSIS
        Validates one stage_timing entry and returns its stage, attempt, times, and seconds.

    .DESCRIPTION
        Returns Ok false with a Reason when the entry has a blank stage, an attempt below 1, an
        unparsable time, or an ended_at before its started_at. An open entry (ended_at null)
        has no End and Seconds null.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [object]$Entry
    )

    $failure = { param([string] $Stage, [string] $Reason) [pscustomobject]@{ Ok = $false; Reason = $Reason; Stage = $Stage; Attempt = 0; Start = $null; End = $null; Seconds = $null } }

    if ($Entry -isnot [System.Management.Automation.PSCustomObject]) {
        return & $failure '' 'the entry is not an object'
    }

    $stageProperty = $Entry.PSObject.Properties['stage']
    $stage = if ($null -ne $stageProperty) { $stageProperty.Value } else { $null }
    if ($stage -isnot [string] -or [string]::IsNullOrWhiteSpace($stage)) {
        return & $failure '' 'stage is missing or blank'
    }

    $attemptProperty = $Entry.PSObject.Properties['attempt']
    $attempt = if ($null -ne $attemptProperty) { $attemptProperty.Value } else { $null }
    if (($attempt -isnot [long] -and $attempt -isnot [int]) -or $attempt -lt 1) {
        return & $failure $stage 'attempt is not an integer of 1 or more'
    }

    $startProperty = $Entry.PSObject.Properties['started_at']
    $start = ConvertTo-StageTimingInstant -Value $(if ($null -ne $startProperty) { $startProperty.Value } else { $null })
    if ($null -eq $start) {
        return & $failure $stage 'started_at is not an ISO-8601 time'
    }

    $endProperty = $Entry.PSObject.Properties['ended_at']
    if ($null -eq $endProperty) {
        return & $failure $stage 'ended_at is missing'
    }

    if ($null -eq $endProperty.Value) {
        return [pscustomobject]@{ Ok = $true; Reason = ''; Stage = $stage; Attempt = [long]$attempt; Start = $start; End = $null; Seconds = $null }
    }

    $end = ConvertTo-StageTimingInstant -Value $endProperty.Value
    if ($null -eq $end) {
        return & $failure $stage 'ended_at is not an ISO-8601 time'
    }

    if ($end -lt $start) {
        return & $failure $stage 'ended_at is before started_at'
    }

    return [pscustomobject]@{ Ok = $true; Reason = ''; Stage = $stage; Attempt = [long]$attempt; Start = $start; End = $end; Seconds = ($end - $start).TotalSeconds }
}

function Get-StageTimingMedian {
    <#
    .SYNOPSIS
        Returns the median of a non-empty list of numbers; an even count averages the middle pair.
    #>
    [CmdletBinding()]
    [OutputType([double])]
    param(
        [Parameter(Mandatory = $true)]
        [double[]]$Value
    )

    $sorted = [double[]]($Value | Sort-Object)
    $middle = [int][math]::Floor($sorted.Count / 2)
    if ($sorted.Count % 2 -eq 1) {
        return $sorted[$middle]
    }

    return ($sorted[$middle - 1] + $sorted[$middle]) / 2
}

function Get-StageTimingSummary {
    <#
    .SYNOPSIS
        Summarizes stage timing evidence per issue and stage, and per stage across issues.

    .DESCRIPTION
        Pure. Takes the Name and Text objects of Read-StageTimingEvidence. Per issue only the
        file with the greatest leaf name counts. A file whose text is not valid JSON, whose root
        is not an object, whose issue-num is blank, or whose stage_timing is not a list is
        skipped with a reason; so is an entry with a blank stage, an invalid attempt, an
        unparsable time, or an ended_at before its started_at. Open entries are counted and
        excluded from totals. A stage reaches the medians only through issues that hold at
        least one closed entry for it. Stage order is the order of the earliest started_at
        across all issues, ties broken by ordinal comparison.

    .PARAMETER Evidence
        The Name and Text objects to summarize; an empty list yields an empty summary.

    .OUTPUTS
        One object with Issues (Issue, Stage, Attempts, OpenCount, TotalSeconds), Stages (Stage,
        IssueCount, MedianSeconds), SkippedFiles (Name, Reason), and SkippedEntries (Issue,
        Stage, Reason).
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [object[]]$Evidence
    )

    $skippedFiles = [System.Collections.Generic.List[object]]::new()
    $skippedEntries = [System.Collections.Generic.List[object]]::new()
    $selected = [System.Collections.Generic.Dictionary[string, object]]::new([System.StringComparer]::Ordinal)

    foreach ($item in $Evidence) {
        $name = [string]$item.Name
        $document = ConvertFrom-StageTimingText -Text ([string]$item.Text)
        if (-not $document.Ok) {
            $skippedFiles.Add([pscustomobject]@{ Name = $name; Reason = $document.Reason })
            continue
        }

        $leaf = $name.Substring($name.LastIndexOf('/') + 1)
        $candidate = [pscustomobject]@{ Name = $name; Leaf = $leaf; Issue = $document.Issue; Entries = $document.Entries }
        $current = $null
        if ($selected.TryGetValue($document.Issue, [ref]$current)) {
            $order = [string]::CompareOrdinal($candidate.Leaf, $current.Leaf)
            if ($order -lt 0 -or ($order -eq 0 -and [string]::CompareOrdinal($candidate.Name, $current.Name) -le 0)) {
                continue
            }
        }

        $selected[$document.Issue] = $candidate
    }

    $cells = [System.Collections.Generic.Dictionary[string, object]]::new([System.StringComparer]::Ordinal)
    $earliest = [System.Collections.Generic.Dictionary[string, long]]::new([System.StringComparer]::Ordinal)
    $separator = [string][char]31

    foreach ($document in $selected.Values) {
        foreach ($entry in $document.Entries) {
            $record = ConvertTo-StageTimingRecord -Entry $entry
            if (-not $record.Ok) {
                $skippedEntries.Add([pscustomobject]@{ Issue = $document.Issue; Stage = $record.Stage; Reason = $record.Reason })
                continue
            }

            $ticks = $record.Start.UtcTicks
            if (-not $earliest.ContainsKey($record.Stage) -or $ticks -lt $earliest[$record.Stage]) {
                $earliest[$record.Stage] = $ticks
            }

            $key = $document.Issue + $separator + $record.Stage
            if (-not $cells.ContainsKey($key)) {
                $cells[$key] = [pscustomobject]@{ Issue = $document.Issue; Stage = $record.Stage; Attempts = 0; OpenCount = 0; TotalSeconds = [double]0 }
            }

            $cell = $cells[$key]
            $cell.Attempts += 1
            if ($null -eq $record.End) {
                $cell.OpenCount += 1
            }
            else {
                $cell.TotalSeconds += $record.Seconds
            }
        }
    }

    $stageNames = [System.Collections.Generic.List[string]]::new($earliest.Keys)
    $stageNames.Sort([System.Comparison[string]] {
            param($left, $right)
            $byStart = $earliest[$left].CompareTo($earliest[$right])
            if ($byStart -ne 0) { return $byStart }
            return [string]::CompareOrdinal($left, $right)
        })
    $stageRank = [System.Collections.Generic.Dictionary[string, int]]::new([System.StringComparer]::Ordinal)
    for ($index = 0; $index -lt $stageNames.Count; $index++) {
        $stageRank[$stageNames[$index]] = $index
    }

    $issueRows = [System.Collections.Generic.List[object]]::new($cells.Values)
    $issueRows.Sort([System.Comparison[object]] {
            param($left, $right)
            $byLength = $left.Issue.Length.CompareTo($right.Issue.Length)
            if ($byLength -ne 0) { return $byLength }
            $byIssue = [string]::CompareOrdinal($left.Issue, $right.Issue)
            if ($byIssue -ne 0) { return $byIssue }
            return $stageRank[$left.Stage].CompareTo($stageRank[$right.Stage])
        })

    $stageRows = [System.Collections.Generic.List[object]]::new()
    foreach ($stageName in $stageNames) {
        $totals = [System.Collections.Generic.List[double]]::new()
        foreach ($row in $issueRows) {
            if ($row.Stage -ceq $stageName -and $row.Attempts -gt $row.OpenCount) {
                $totals.Add($row.TotalSeconds)
            }
        }

        if ($totals.Count -gt 0) {
            $stageRows.Add([pscustomobject]@{ Stage = $stageName; IssueCount = $totals.Count; MedianSeconds = (Get-StageTimingMedian -Value $totals.ToArray()) })
        }
    }

    return [pscustomobject]@{
        Issues         = $issueRows.ToArray()
        Stages         = $stageRows.ToArray()
        SkippedFiles   = $skippedFiles.ToArray()
        SkippedEntries = $skippedEntries.ToArray()
    }
}

function Format-StageTimingDuration {
    <#
    .SYNOPSIS
        Renders a number of seconds as H:MM:SS, rounding to the nearest second.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [double]$Seconds
    )

    $whole = [long][math]::Round($Seconds, [System.MidpointRounding]::AwayFromZero)
    $hours = [long][math]::Floor($whole / 3600)
    $minutes = [long][math]::Floor(($whole % 3600) / 60)
    $rest = $whole % 60
    return ('{0}:{1:00}:{2:00}' -f $hours, $minutes, $rest)
}

function Format-StageTimingReport {
    <#
    .SYNOPSIS
        Renders a stage timing summary as text lines.

    .DESCRIPTION
        Pure. The two labels come first and print even when there is no data. Then come the
        per-stage medians, the per-issue totals, and the skipped files and entries. Durations
        print as H:MM:SS.

    .PARAMETER Summary
        The object returned by Get-StageTimingSummary.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$Summary
    )

    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add('Figures are wall-clock time and include queueing; they are not agent time.')
    $lines.Add('The merge stage is not captured.')
    $lines.Add('')

    if (@($Summary.Issues).Count -eq 0) {
        $lines.Add('No stage timing evidence was found.')
    }
    else {
        $lines.Add('Median per stage across issues')
        foreach ($stage in $Summary.Stages) {
            $lines.Add("  $($stage.Stage): $($stage.IssueCount) issue(s), median $(Format-StageTimingDuration -Seconds $stage.MedianSeconds)")
        }

        $lines.Add('')
        $lines.Add('Total per issue and stage')
        foreach ($row in $Summary.Issues) {
            $lines.Add("  Issue $($row.Issue), $($row.Stage): $($row.Attempts) attempt(s), $($row.OpenCount) open, total $(Format-StageTimingDuration -Seconds $row.TotalSeconds)")
        }
    }

    if (@($Summary.SkippedFiles).Count -gt 0) {
        $lines.Add('')
        $lines.Add('Skipped files')
        foreach ($skipped in $Summary.SkippedFiles) {
            $lines.Add("  $($skipped.Name): $($skipped.Reason)")
        }
    }

    if (@($Summary.SkippedEntries).Count -gt 0) {
        $lines.Add('')
        $lines.Add('Skipped entries')
        foreach ($skipped in $Summary.SkippedEntries) {
            $lines.Add("  Issue $($skipped.Issue), stage '$($skipped.Stage)': $($skipped.Reason)")
        }
    }

    return $lines.ToArray()
}

Export-ModuleMember -Function Read-StageTimingEvidence, Get-StageTimingSummary, Format-StageTimingReport
