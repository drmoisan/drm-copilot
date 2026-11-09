<#
.SYNOPSIS
    Setting, state-file, baseline, and sample functions for Get-EpicProgressReport.ps1.

.DESCRIPTION
    Pure functions: each takes data in and returns data, and none reads a file, starts a
    process, calls the network, or reads the clock. The entry script reads and writes the
    state file through its I/O seams. Get-EpicProgressReport.Logic.ps1 dot-sources this file,
    so a consumer dot-sources the Logic hub, not this file.
#>

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

function Resolve-EpicProgressSetting {
    <#
    .SYNOPSIS
        Apply the parameter defaults of the report; pure, with the current location passed in.
    .DESCRIPTION
        A blank value takes its default and an explicit value is kept. The kickoff path is a
        git object path with '/' separators; filesystem paths are built with Join-Path. The
        default state file is .claude/state/epic-progress-<EpicFolder>.json under the
        repository root, which is gitignored and survives a container stop with the checkout.
    .PARAMETER EpicFolder
        The epic folder name.
    .PARAMETER EpicIssue
        The explicit epic issue number, or blank.
    .PARAMETER IntegrationBranch
        The explicit integration branch, or blank.
    .PARAMETER KickoffPath
        The explicit kickoff path, or blank.
    .PARAMETER RepositoryRoot
        The explicit repository root, or blank.
    .PARAMETER CheckpointPath
        The explicit checkpoint path, or blank.
    .PARAMETER StatePath
        The explicit state file path, or blank.
    .PARAMETER CurrentLocation
        The current location.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [string] $EpicFolder,
        [AllowEmptyString()] [string] $EpicIssue = '',
        [AllowEmptyString()] [string] $IntegrationBranch = '',
        [AllowEmptyString()] [string] $KickoffPath = '',
        [AllowEmptyString()] [string] $RepositoryRoot = '',
        [AllowEmptyString()] [string] $CheckpointPath = '',
        [AllowEmptyString()] [string] $StatePath = '',
        [Parameter(Mandatory = $true)] [string] $CurrentLocation
    )

    $root = $RepositoryRoot
    if ([string]::IsNullOrWhiteSpace($root)) { $root = $CurrentLocation }
    $branch = $IntegrationBranch
    if ([string]::IsNullOrWhiteSpace($branch)) { $branch = "origin/epic/$EpicFolder-integration" }
    $kickoff = $KickoffPath
    if ([string]::IsNullOrWhiteSpace($kickoff)) { $kickoff = "docs/features/epics/$EpicFolder/epic-kickoff.md" }
    $checkpoint = $CheckpointPath
    if ([string]::IsNullOrWhiteSpace($checkpoint)) {
        $checkpoint = Join-Path -Path $root -ChildPath 'artifacts' -AdditionalChildPath 'orchestration', 'epic-orchestrator-state.json'
    }
    $state = $StatePath
    if ([string]::IsNullOrWhiteSpace($state)) {
        $state = Join-Path -Path $root -ChildPath '.claude' -AdditionalChildPath 'state', "epic-progress-$EpicFolder.json"
    }

    return [pscustomobject]@{
        EpicIssue         = $EpicIssue
        IntegrationBranch = $branch
        KickoffPath       = $kickoff.Replace('\', '/')
        RepositoryRoot    = $root
        CheckpointPath    = $checkpoint
        StatePath         = $state
    }
}

function Resolve-EpicProgressItemSetting {
    <#
    .SYNOPSIS
        Apply the item-mode parameter defaults; pure, with the current location passed in.
    .DESCRIPTION
        A blank value takes its default and an explicit value is kept. The default state file
        is .claude/state/progress-item-<Issue>.json under the repository root (decision D9).
    .PARAMETER Issue
        The item issue number.
    .PARAMETER RepositoryRoot
        The explicit repository root, or blank.
    .PARAMETER StatePath
        The explicit state file path, or blank.
    .PARAMETER IntegrationBranch
        The explicit branch for git show fallbacks, or blank for none.
    .PARAMETER CurrentLocation
        The current location.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [int] $Issue,
        [AllowEmptyString()] [string] $RepositoryRoot = '',
        [AllowEmptyString()] [string] $StatePath = '',
        [AllowEmptyString()] [string] $IntegrationBranch = '',
        [Parameter(Mandatory = $true)] [string] $CurrentLocation
    )

    $root = $RepositoryRoot
    if ([string]::IsNullOrWhiteSpace($root)) { $root = $CurrentLocation }
    $state = $StatePath
    if ([string]::IsNullOrWhiteSpace($state)) {
        $state = Join-Path -Path $root -ChildPath '.claude' -AdditionalChildPath 'state', "progress-item-$Issue.json"
    }
    return [pscustomobject]@{ Issue = [string] $Issue; RepositoryRoot = $root; StatePath = $state; IntegrationBranch = $IntegrationBranch }
}

function ConvertFrom-EpicProgressStateSample {
    <#
    .SYNOPSIS
        Return one stored check-in sample as ts and done, plus tasks and a features hashtable when a version-3 sample carries them.
    .DESCRIPTION
        A version-2 sample keeps only ts and done, so it never feeds task velocity (decision
        E12). A version-3 sample keeps a non-null 'tasks' value and converts 'features' into a
        hashtable from issue to done task count.
    .PARAMETER Entry
        The parsed sample object.
    .PARAMETER Version
        The document version ('2' or '3').
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [object] $Entry,
        [Parameter(Mandatory = $true)] [string] $Version
    )

    $names = @($Entry.PSObject.Properties.Name)
    $sample = [ordered]@{}
    if ($names -contains 'ts') { $sample['ts'] = $Entry.ts }
    if ($names -contains 'done') { $sample['done'] = $Entry.done }
    if ($Version -eq '3' -and $names -contains 'tasks' -and $null -ne $Entry.tasks) { $sample['tasks'] = $Entry.tasks -as [int] }
    if ($Version -eq '3' -and $Entry.features -is [System.Management.Automation.PSCustomObject]) {
        $features = @{}
        foreach ($feature in $Entry.features.PSObject.Properties) { $features[$feature.Name] = $feature.Value -as [int] }
        $sample['features'] = $features
    }
    return [pscustomobject] $sample
}

function ConvertFrom-EpicProgressStateText {
    <#
    .SYNOPSIS
        Parse the state file text into StartUnixSeconds, BaselineDone, BaselineDoneTasks, BaselineWeeklyPct, Samples, Durations, Items, Pauses, Unit, and MigratedFrom.
    .DESCRIPTION
        Reads the version-3 object written by ConvertTo-EpicProgressStateJson (issue #1153,
        decision E12): the check-in samples count steps ('done') and carry the epic done task
        count ('tasks') and the per-feature done task counts ('features'), BaselineDoneTasks is
        the done task count at the baseline, Pauses lists the pause spans (startUnixSeconds,
        endUnixSeconds), Durations maps each step type to its sample list, and Items maps each
        issue to its plan tick anchors (Plans: file name to Checked and LastTickUnixSeconds) and
        BlockedSinceUnixSeconds. A version-2 object is migrated with its start, weekly baseline,
        baseline done count, samples, durations, and items kept, BaselineDoneTasks absent, and
        Pauses empty; its samples carry no 'tasks' value, and MigratedFrom is '2'. A version-1
        object and the legacy JSON array of samples (issues #1080 and #1093) counted tasks, so
        their samples and baseline done count are discarded, the start and the weekly baseline
        of a version-1 object are kept, and MigratedFrom is '1' or 'legacy'. MigratedFrom is
        $null for a version-3 document and for the empty state. Blank text, unparseable text,
        any other JSON value, and an object of any other version (4 or above) give the empty
        state. A field that is missing, null, or not a number is absent: its value is $null.
        Samples and Pauses are always arrays; Durations and Items are always hashtables.
    .PARAMETER Text
        The raw state file text; blank or null for no state file.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [AllowNull()] [string] $Text)

    $state = [pscustomobject]@{ StartUnixSeconds = $null; BaselineDone = $null; BaselineDoneTasks = $null; BaselineWeeklyPct = $null; Samples = [object[]] @(); Durations = @{}; Items = @{}; Pauses = [object[]] @(); Unit = 'steps'; MigratedFrom = $null }
    if (-not (Test-EpicProgressJsonText -Json $Text)) { return $state }
    $parsed = ConvertFrom-Json -InputObject $Text -NoEnumerate
    if ($parsed -is [array]) {
        $state.MigratedFrom = 'legacy'
        return $state
    }
    if ($parsed -isnot [System.Management.Automation.PSCustomObject]) { return $state }
    $names = $parsed.PSObject.Properties.Name
    $version = ''
    if ($names -contains 'version') { $version = [string] $parsed.version }
    if ($version -notin @('1', '2', '3')) { return $state }
    if ($names -contains 'startUnixSeconds' -and $null -ne $parsed.startUnixSeconds) { $state.StartUnixSeconds = $parsed.startUnixSeconds -as [long] }
    if ($names -contains 'baselineWeeklyPct' -and $null -ne $parsed.baselineWeeklyPct) { $state.BaselineWeeklyPct = $parsed.baselineWeeklyPct -as [double] }
    if ($version -eq '1') {
        $state.MigratedFrom = '1'
        return $state
    }
    if ($version -eq '2') { $state.MigratedFrom = '2' }
    if ($names -contains 'baselineDone' -and $null -ne $parsed.baselineDone) { $state.BaselineDone = $parsed.baselineDone -as [int] }
    if ($version -eq '3' -and $names -contains 'baselineDoneTasks' -and $null -ne $parsed.baselineDoneTasks) { $state.BaselineDoneTasks = $parsed.baselineDoneTasks -as [int] }
    if ($names -contains 'samples' -and $null -ne $parsed.samples) {
        $state.Samples = [object[]] @($parsed.samples | Where-Object { $null -ne $_ } | ForEach-Object { ConvertFrom-EpicProgressStateSample -Entry $_ -Version $version })
    }
    if ($version -eq '3' -and $names -contains 'pauses' -and $null -ne $parsed.pauses) {
        $state.Pauses = [object[]] @($parsed.pauses | Where-Object { $null -ne $_ -and $null -ne $_.startUnixSeconds -and $null -ne $_.endUnixSeconds } | ForEach-Object {
                [pscustomobject]@{ startUnixSeconds = $_.startUnixSeconds -as [long]; endUnixSeconds = $_.endUnixSeconds -as [long] }
            })
    }
    if ($parsed.durations -is [System.Management.Automation.PSCustomObject]) {
        foreach ($property in $parsed.durations.PSObject.Properties) { $state.Durations[$property.Name] = [object[]] @($property.Value | Where-Object { $null -ne $_ }) }
    }
    if ($parsed.items -is [System.Management.Automation.PSCustomObject]) {
        foreach ($property in $parsed.items.PSObject.Properties) {
            $plans = @{}
            if ($property.Value.plans -is [System.Management.Automation.PSCustomObject]) {
                foreach ($plan in $property.Value.plans.PSObject.Properties) {
                    $plans[$plan.Name] = [pscustomobject]@{ Checked = [string[]] @($plan.Value.checked | Where-Object { $null -ne $_ }); LastTickUnixSeconds = $plan.Value.lastTickUnixSeconds -as [long] }
                }
            }
            $blockedSince = $null
            if ($null -ne $property.Value.blockedSinceUnixSeconds) { $blockedSince = $property.Value.blockedSinceUnixSeconds -as [long] }
            $state.Items[$property.Name] = [pscustomobject]@{ Plans = $plans; BlockedSinceUnixSeconds = $blockedSince }
        }
    }
    return $state
}

function ConvertTo-EpicProgressStateJson {
    <#
    .SYNOPSIS
        Return the version-3 state document as JSON text.
    .DESCRIPTION
        The document holds version 3, unit 'steps', startUnixSeconds, baselineDone,
        baselineDoneTasks (null when none is stored), baselineWeeklyPct, samples (each with an
        integer 'ts' in Unix epoch seconds, a 'done' step count, and, when the sample carries
        them, the epic done task count 'tasks' and the per-feature done task counts 'features';
        a sample without 'ts' is not written), durations (each step type with its samples: key,
        type, seconds, source, approx, recorded), items (each issue with its plan tick anchors
        and blockedSinceUnixSeconds), and pauses (startUnixSeconds, endUnixSeconds) (issue
        #1153, decision E12). Epoch seconds are used because ConvertFrom-Json converts ISO date
        strings into local-time DateTime values. A pause span that ends before the earliest
        stored instant (StartUnixSeconds, the oldest sample, or the oldest tick anchor in Item)
        is not written (Select-EpicProgressRetainedPauseSpan).
    .PARAMETER StartUnixSeconds
        The start instant in Unix epoch seconds.
    .PARAMETER BaselineDone
        The done step count at the start instant.
    .PARAMETER BaselineWeeklyPct
        The weekly quota percentage at the start instant.
    .PARAMETER Sample
        The retained check-in samples (ts, done, and optionally tasks and features).
    .PARAMETER Duration
        The duration ledger: a hashtable from step type to its samples.
    .PARAMETER Item
        The per-item state: a hashtable from issue to Plans and BlockedSinceUnixSeconds.
    .PARAMETER BaselineDoneTasks
        The done task count at the start instant; null (the default) when none is stored.
    .PARAMETER PauseSpan
        The pause spans (startUnixSeconds, endUnixSeconds); empty by default.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [long] $StartUnixSeconds,
        [Parameter(Mandatory = $true)] [int] $BaselineDone,
        [Parameter(Mandatory = $true)] [double] $BaselineWeeklyPct,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Sample,
        [hashtable] $Duration = @{},
        [hashtable] $Item = @{},
        [AllowNull()] [object] $BaselineDoneTasks = $null,
        [AllowEmptyCollection()] [object[]] $PauseSpan = @()
    )

    $written = [System.Collections.Generic.List[object]]::new()
    foreach ($entry in $Sample) {
        if ($null -eq $entry -or -not ($entry.PSObject.Properties.Name -contains 'ts')) { continue }
        $record = [ordered]@{ ts = [long] $entry.ts; done = [int] $entry.done }
        $names = @($entry.PSObject.Properties.Name)
        if ($names -contains 'tasks' -and $null -ne $entry.tasks) { $record['tasks'] = [int] $entry.tasks }
        if ($names -contains 'features' -and $null -ne $entry.features) {
            $source = $entry.features
            $features = [ordered]@{}
            if ($source -is [System.Collections.IDictionary]) {
                foreach ($key in @($source.Keys | Sort-Object)) { $features[[string] $key] = [int] $source[$key] }
            } else {
                foreach ($property in @($source.PSObject.Properties | Sort-Object -Property Name)) { $features[$property.Name] = [int] $property.Value }
            }
            $record['features'] = $features
        }
        $written.Add($record)
    }
    $retained = @(Select-EpicProgressRetainedPauseSpan -PauseSpan $PauseSpan -StartUnixSeconds $StartUnixSeconds -Sample $Sample -Item $Item)
    $pauses = [object[]] @($retained | Where-Object { $null -ne $_ } | ForEach-Object { [ordered]@{ startUnixSeconds = [long] $_.startUnixSeconds; endUnixSeconds = [long] $_.endUnixSeconds } })
    $tasksBaseline = $null
    if ($null -ne $BaselineDoneTasks) { $tasksBaseline = [int] $BaselineDoneTasks }
    $durations = [ordered]@{}
    foreach ($type in @($Duration.Keys | Sort-Object)) {
        $durations[[string] $type] = [object[]] @($Duration[$type] | Where-Object { $null -ne $_ } | ForEach-Object {
                [ordered]@{ key = [string] $_.key; type = [string] $_.type; seconds = [double] $_.seconds; source = [string] $_.source; approx = [bool] $_.approx; recorded = [long] $_.recorded }
            })
    }
    $items = [ordered]@{}
    foreach ($issue in @($Item.Keys | Sort-Object)) {
        $plans = [ordered]@{}
        $record = $Item[$issue]
        foreach ($file in @($record.Plans.Keys | Sort-Object)) {
            $plans[[string] $file] = [ordered]@{ checked = [string[]] @($record.Plans[$file].Checked); lastTickUnixSeconds = [long] $record.Plans[$file].LastTickUnixSeconds }
        }
        $items[[string] $issue] = [ordered]@{ plans = $plans; blockedSinceUnixSeconds = $record.BlockedSinceUnixSeconds }
    }
    $document = [ordered]@{
        version           = 3
        unit              = 'steps'
        startUnixSeconds  = $StartUnixSeconds
        baselineDone      = $BaselineDone
        baselineDoneTasks = $tasksBaseline
        baselineWeeklyPct = $BaselineWeeklyPct
        samples           = [object[]] $written.ToArray()
        durations         = $durations
        items             = $items
        pauses            = $pauses
    }
    return ConvertTo-Json -InputObject $document -Depth 8
}

function Resolve-EpicProgressBaseline {
    <#
    .SYNOPSIS
        Resolve the start instant and the baseline values from the passed values, the stored state, and the reset switch.
    .DESCRIPTION
        Start: the passed value, else (with ResetBaseline) NowUtc, else the stored value; with
        none of these a terminating error names -StartUtc and -ResetBaseline. Baseline done:
        the passed value, else (with ResetBaseline) the current done count, else (for a state
        migrated from version 1 or the legacy array, whose counts were tasks) the current done
        count, else the stored value, else 0. A state migrated from version 2 counted steps,
        so its stored baseline is kept. The MigratedFrom property is read only when the state
        carries it. Weekly baseline: the passed value, else the stored value, else 0; a reset
        does not capture it. The current done count is not known before the git calls, so
        UseCurrentDone is $true when the caller must substitute it for BaselineDone. Task
        baseline (issue #1153, decision E12): with ResetBaseline, or when the state stores no
        BaselineDoneTasks (a version-2 migration or no state), UseCurrentDoneTasks is $true and
        the caller substitutes the current done task count; otherwise BaselineDoneTasks is the
        stored value.
    .PARAMETER StartUtc
        The passed start instant; read only when StartUtcPassed is set.
    .PARAMETER StartUtcPassed
        Whether -StartUtc was passed to the report.
    .PARAMETER BaselineDone
        The passed baseline done count; read only when BaselineDonePassed is set.
    .PARAMETER BaselineDonePassed
        Whether -BaselineDone was passed to the report.
    .PARAMETER BaselineWeeklyPct
        The passed weekly baseline; read only when BaselineWeeklyPctPassed is set.
    .PARAMETER BaselineWeeklyPctPassed
        Whether -BaselineWeeklyPct was passed to the report.
    .PARAMETER State
        The parsed state from ConvertFrom-EpicProgressStateText.
    .PARAMETER ResetBaseline
        Whether the run resets the baseline.
    .PARAMETER NowUtc
        The current instant (UTC).
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [datetime] $StartUtc,
        [switch] $StartUtcPassed,
        [int] $BaselineDone,
        [switch] $BaselineDonePassed,
        [double] $BaselineWeeklyPct,
        [switch] $BaselineWeeklyPctPassed,
        [Parameter(Mandatory = $true)] [pscustomobject] $State,
        [switch] $ResetBaseline,
        [Parameter(Mandatory = $true)] [datetime] $NowUtc
    )

    if ($StartUtcPassed) {
        $start = $StartUtc.ToUniversalTime()
    } elseif ($ResetBaseline) {
        $start = $NowUtc.ToUniversalTime()
    } elseif ($null -ne $State.StartUnixSeconds) {
        $start = [DateTimeOffset]::FromUnixTimeSeconds([long] $State.StartUnixSeconds).UtcDateTime
    } else {
        throw 'The start instant could not be resolved: pass -StartUtc, or pass -ResetBaseline to start the measurement now; the state file holds no start.'
    }

    $useCurrentDone = $false
    $done = 0
    if ($BaselineDonePassed) {
        $done = $BaselineDone
    } elseif ($ResetBaseline) {
        $useCurrentDone = $true
    } elseif ($State.PSObject.Properties.Name -contains 'MigratedFrom' -and $State.MigratedFrom -in @('1', 'legacy')) {
        # A migrated version-1 or legacy state counted tasks, so the baseline restarts at the current step count.
        $useCurrentDone = $true
    } elseif ($null -ne $State.BaselineDone) {
        $done = [int] $State.BaselineDone
    }

    $weekly = 0.0
    if ($BaselineWeeklyPctPassed) {
        $weekly = $BaselineWeeklyPct
    } elseif ($null -ne $State.BaselineWeeklyPct) {
        $weekly = [double] $State.BaselineWeeklyPct
    }

    $useCurrentDoneTasks = $true
    $doneTasks = $null
    if (-not $ResetBaseline -and $State.PSObject.Properties.Name -contains 'BaselineDoneTasks' -and $null -ne $State.BaselineDoneTasks) {
        $useCurrentDoneTasks = $false
        $doneTasks = [int] $State.BaselineDoneTasks
    }

    return [pscustomobject]@{ StartUtc = $start; BaselineDone = $done; BaselineWeeklyPct = $weekly; UseCurrentDone = $useCurrentDone; BaselineDoneTasks = $doneTasks; UseCurrentDoneTasks = $useCurrentDoneTasks }
}

function Merge-EpicProgressSamplePair {
    <#
    .SYNOPSIS
        Keep the newest sample and every second older sample (indices n-1, n-3, ...), in chronological order.
    .DESCRIPTION
        Each kept sample is returned unchanged, so its 'tasks' and 'features' values are kept.
        With k intervals the result has floor(k/2) intervals, each spanning two original
        intervals; when k is odd the oldest interval is discarded. 14 samples become 7, 13
        become 7, 2 become 1, and 1 or 0 samples are returned unchanged. Each application
        doubles the spacing again, so the function is not idempotent.
    .PARAMETER Sample
        The samples in chronological order.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Sample)

    $kept = [System.Collections.Generic.List[object]]::new()
    for ($index = $Sample.Count - 1; $index -ge 0; $index -= 2) { $kept.Insert(0, $Sample[$index]) }
    return [object[]] $kept.ToArray()
}
