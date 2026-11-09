<#
.SYNOPSIS
    Critical-path functions for Get-EpicProgressReport.ps1: dependency graph, parallel cap, list schedule, critical chain, blocked closure, epic tail, range, and the report composition.

.DESCRIPTION
    Pure, host-neutral functions (issue #1153, decisions E5 to E9): each takes data in and
    returns data, and none reads a file, starts a process, calls the network, calls an I/O
    seam, or reads the clock. The dependency graph is re-implemented locally, because the skill
    imports nothing outside its folder: a reference resolves as an issue number or as a
    feature-folder basename (an 'active/' or 'completed/' prefix is ignored). Issue numbers are
    compared as numbers when both parse, else by ordinal text, so the order does not depend on
    the host culture. Get-EpicProgressReport.Logic.ps1 dot-sources this file, so a consumer
    dot-sources the Logic hub, not this file.
#>

function Compare-EpicProgressIssue {
    <#
    .SYNOPSIS
        Return a negative, zero, or positive number ordering two issue numbers ascending.
    .DESCRIPTION
        Numbers that both parse as integers compare numerically; any other pair compares by
        ordinal text.
    .PARAMETER Left
        The first issue number.
    .PARAMETER Right
        The second issue number.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Left,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Right
    )

    $leftNumber = 0L
    $rightNumber = 0L
    $culture = [cultureinfo]::InvariantCulture
    $style = [System.Globalization.NumberStyles]::None
    if ([long]::TryParse($Left, $style, $culture, [ref] $leftNumber) -and [long]::TryParse($Right, $style, $culture, [ref] $rightNumber)) {
        return $leftNumber.CompareTo($rightNumber)
    }
    return [string]::CompareOrdinal($Left, $Right)
}

function Get-EpicProgressSortedIssue {
    <#
    .SYNOPSIS
        Return the issue numbers in ascending order by Compare-EpicProgressIssue, without duplicates.
    .PARAMETER Issue
        The issue numbers.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $Issue)

    $list = [System.Collections.Generic.List[string]]::new()
    foreach ($entry in $Issue) { if (-not $list.Contains($entry)) { $list.Add($entry) } }
    $list.Sort([System.Comparison[string]] { param($left, $right) Compare-EpicProgressIssue -Left $left -Right $right })
    return , [string[]] $list.ToArray()
}

function Resolve-EpicProgressParallelCap {
    <#
    .SYNOPSIS
        Return Cap and Source: the checkpoint max_parallel_features, else the routing-config default, else 4 (decision E5).
    .DESCRIPTION
        A value is valid when it is an integer (not text and not a fraction) from 1 to 8. The
        source is 'checkpoint', 'config', or 'built-in'.
    .PARAMETER CheckpointValue
        The epic checkpoint max_parallel_features value; null when absent.
    .PARAMETER ConfigValue
        The parallelism.default_max_parallel_features value of config/orchestration-routing.json; null when absent.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowNull()] [object] $CheckpointValue = $null,
        [AllowNull()] [object] $ConfigValue = $null
    )

    $isValid = {
        param([object] $Value)
        ($Value -is [int] -or $Value -is [long]) -and [long] $Value -ge 1 -and [long] $Value -le 8
    }
    if (& $isValid $CheckpointValue) { return [pscustomobject]@{ Cap = [int] $CheckpointValue; Source = 'checkpoint' } }
    if (& $isValid $ConfigValue) { return [pscustomobject]@{ Cap = [int] $ConfigValue; Source = 'config' } }
    return [pscustomobject]@{ Cap = 4; Source = 'built-in' }
}

function Get-EpicProgressWaveEdge {
    <#
    .SYNOPSIS
        Return the wave fallback dependencies: each feature depends on every feature of the nearest lower wave.
    .PARAMETER Feature
        The kickoff features (Issue, Wave).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Feature)

    $edges = @{}
    foreach ($record in $Feature) {
        $wave = [int] $record.Wave
        $lower = @($Feature | Where-Object { [int] $_.Wave -lt $wave } | ForEach-Object { [int] $_.Wave })
        $edges[[string] $record.Issue] = [string[]] @()
        if ($lower.Count -eq 0) { continue }
        $nearest = ($lower | Measure-Object -Maximum).Maximum
        $edges[[string] $record.Issue] = Get-EpicProgressSortedIssue -Issue ([string[]] @($Feature | Where-Object { [int] $_.Wave -eq $nearest } | ForEach-Object { [string] $_.Issue }))
    }
    return $edges
}

function Find-EpicProgressDependencyRow {
    <#
    .SYNOPSIS
        Return the row of a list that belongs to a feature: matched by issue_num, else by feature_folder basename; null when none.
    .PARAMETER Row
        The checkpoint or manifest feature rows.
    .PARAMETER Issue
        The feature issue number.
    .PARAMETER Folder
        The feature-folder basename; blank when unknown.
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Row,
        [Parameter(Mandatory = $true)] [string] $Issue,
        [AllowEmptyString()] [string] $Folder = ''
    )

    $byIssue = @($Row | Where-Object { $null -ne $_ -and $null -ne $_.issue_num -and [string] $_.issue_num -eq $Issue }) | Select-Object -First 1
    if ($null -ne $byIssue) { return $byIssue }
    if ([string]::IsNullOrEmpty($Folder)) { return $null }
    return @($Row | Where-Object { $null -ne $_ -and (ConvertTo-EpicProgressFolderHint -Value ([string] $_.feature_folder)) -eq $Folder }) | Select-Object -First 1
}

function ConvertTo-EpicProgressFolderHint {
    <#
    .SYNOPSIS
        Return the basename of a feature-folder reference: the last path segment, with a docs/features/active/ or completed/ prefix ignored.
    .PARAMETER Value
        The feature_folder value or depends_on reference.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [AllowNull()] [string] $Value)

    if ([string]::IsNullOrWhiteSpace($Value)) { return '' }
    $segments = @($Value.Replace('\', '/').TrimEnd('/') -split '/')
    return $segments[$segments.Count - 1]
}

function Get-EpicProgressDependencyGraph {
    <#
    .SYNOPSIS
        Return the feature dependency graph: DependsOn (issue to dependency issues), Source, and Message (decision E5).
    .DESCRIPTION
        For each feature, the dependencies come from its epic checkpoint row when that row
        carries a depends_on key, else from its epic.md manifest row when that row carries
        one; an explicit empty list means no dependency, and a feature with the key in neither
        source has none. A reference resolves by issue number or by feature-folder basename; a
        reference to a merged feature is satisfied and gives no edge. Source is 'checkpoint',
        'manifest', or 'checkpoint+manifest' by the sources used. When no feature has the key
        in either source, the waves fallback applies: each feature depends on every feature of
        the nearest lower kickoff wave, and Source is 'waves'. A self-loop, an unresolved
        reference, and a cycle each give a distinct Message, and the graph then falls back to
        the waves; Message is empty for a valid graph.
    .PARAMETER Feature
        The kickoff features (Issue, Wave, Folder, Merged).
    .PARAMETER CheckpointRow
        The epic checkpoint features rows; empty for none.
    .PARAMETER ManifestRow
        The epic.md frontmatter features rows; empty for none.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Feature,
        [AllowEmptyCollection()] [object[]] $CheckpointRow = @(),
        [AllowEmptyCollection()] [object[]] $ManifestRow = @()
    )

    $byFolder = @{}
    $merged = @{}
    foreach ($record in $Feature) {
        if (-not [string]::IsNullOrEmpty([string] $record.Folder)) { $byFolder[[string] $record.Folder] = [string] $record.Issue }
        $merged[[string] $record.Issue] = [bool] $record.Merged
    }
    $references = @{}
    $usedCheckpoint = $false
    $usedManifest = $false
    foreach ($record in $Feature) {
        $issue = [string] $record.Issue
        $references[$issue] = @()
        foreach ($source in @(@{ Name = 'checkpoint'; Rows = $CheckpointRow }, @{ Name = 'manifest'; Rows = $ManifestRow })) {
            $row = Find-EpicProgressDependencyRow -Row @($source.Rows) -Issue $issue -Folder ([string] $record.Folder)
            if ($null -eq $row -or -not ($row.PSObject.Properties.Name -contains 'depends_on')) { continue }
            $references[$issue] = @($row.depends_on | Where-Object { $null -ne $_ })
            if ($source.Name -eq 'checkpoint') { $usedCheckpoint = $true } else { $usedManifest = $true }
            break
        }
    }
    $waves = Get-EpicProgressWaveEdge -Feature $Feature
    if (-not $usedCheckpoint -and -not $usedManifest) { return [pscustomobject]@{ DependsOn = $waves; Source = 'waves'; Message = '' } }
    $source = 'manifest'
    if ($usedCheckpoint -and $usedManifest) { $source = 'checkpoint+manifest' } elseif ($usedCheckpoint) { $source = 'checkpoint' }

    $dependsOn = @{}
    $selfLoop = ''
    $unresolved = ''
    foreach ($issue in (Get-EpicProgressSortedIssue -Issue ([string[]] @($references.Keys)))) {
        $resolvedList = [System.Collections.Generic.List[string]]::new()
        foreach ($reference in $references[$issue]) {
            $text = ([string] $reference).Trim().TrimStart('#')
            $target = $null
            if ($merged.ContainsKey($text)) {
                $target = $text
            } elseif ($byFolder.ContainsKey((ConvertTo-EpicProgressFolderHint -Value $text))) {
                $target = $byFolder[(ConvertTo-EpicProgressFolderHint -Value $text)]
            }
            if ($null -eq $target) {
                if (-not $unresolved) { $unresolved = "unresolved dependency reference: #$issue depends on '$reference', which names no kickoff feature" }
                continue
            }
            if ($target -eq $issue) {
                if (-not $selfLoop) { $selfLoop = "dependency self-loop: #$issue depends on itself" }
                continue
            }
            if (-not $merged[$target] -and -not $resolvedList.Contains($target)) { $resolvedList.Add($target) }
        }
        $dependsOn[$issue] = Get-EpicProgressSortedIssue -Issue ([string[]] $resolvedList.ToArray())
    }
    $message = $selfLoop
    if (-not $message) { $message = $unresolved }
    if (-not $message) {
        $cycle = Find-EpicProgressDependencyCycle -DependsOn $dependsOn
        if ($cycle) { $message = "dependency cycle: $cycle" }
    }
    if ($message) { return [pscustomobject]@{ DependsOn = $waves; Source = 'waves'; Message = "$message; the schedule falls back to waves" } }
    return [pscustomobject]@{ DependsOn = $dependsOn; Source = $source; Message = '' }
}

function Find-EpicProgressDependencyCycle {
    <#
    .SYNOPSIS
        Return one dependency cycle as '#a -> #b -> #a', or an empty string when the graph is acyclic.
    .PARAMETER DependsOn
        The dependencies: a hashtable from issue to its dependency issues.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [hashtable] $DependsOn)

    $state = @{}
    $path = [System.Collections.Generic.List[string]]::new()
    $visit = $null
    $visit = {
        param([string] $Node)
        $state[$Node] = 'open'
        $path.Add($Node)
        foreach ($next in @($DependsOn[$Node])) {
            if ([string]::IsNullOrEmpty($next) -or -not $DependsOn.ContainsKey($next)) { continue }
            if ($state[$next] -eq 'open') {
                $loop = @($path.GetRange($path.IndexOf($next), $path.Count - $path.IndexOf($next))) + @($next)
                return (@($loop | ForEach-Object { "#$_" }) -join ' -> ')
            }
            if (-not $state.ContainsKey($next)) {
                $found = & $visit $next
                if ($found) { return $found }
            }
        }
        $state[$Node] = 'closed'
        $path.RemoveAt($path.Count - 1)
        return ''
    }
    foreach ($node in (Get-EpicProgressSortedIssue -Issue ([string[]] @($DependsOn.Keys)))) {
        if ($state.ContainsKey($node)) { continue }
        $found = & $visit $node
        if ($found) { return $found }
    }
    return ''
}

function Get-EpicProgressBlockedClosure {
    <#
    .SYNOPSIS
        Return the blocked features and every feature that depends on one of them, directly or transitively, in ascending issue order (decision E7).
    .PARAMETER Blocked
        The issue numbers of the blocked features.
    .PARAMETER DependsOn
        The dependencies: a hashtable from issue to its dependency issues.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $Blocked,
        [Parameter(Mandatory = $true)] [hashtable] $DependsOn
    )

    $closed = [System.Collections.Generic.HashSet[string]]::new([string[]] $Blocked)
    $grown = $true
    while ($grown) {
        $grown = $false
        foreach ($issue in @($DependsOn.Keys)) {
            if ($closed.Contains([string] $issue)) { continue }
            if (@($DependsOn[$issue] | Where-Object { $closed.Contains([string] $_) }).Count -gt 0) {
                $null = $closed.Add([string] $issue)
                $grown = $true
            }
        }
    }
    $sorted = Get-EpicProgressSortedIssue -Issue ([string[]] @($closed))
    return $sorted
}

function Get-EpicProgressLongestPath {
    <#
    .SYNOPSIS
        Return the longest remaining path to a sink of each node: its duration plus the largest path of the nodes that depend on it.
    .PARAMETER Node
        The schedule nodes (Issue, DurationSeconds, DependsOn).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Node)

    $paths = @{}
    $pending = @($Node)
    $rounds = 0
    while ($pending.Count -gt 0 -and $rounds -le $Node.Count) {
        $rounds++
        $left = [System.Collections.Generic.List[object]]::new()
        foreach ($entry in $pending) {
            $dependents = @($Node | Where-Object { @($_.DependsOn) -contains [string] $entry.Issue })
            if (@($dependents | Where-Object { -not $paths.ContainsKey([string] $_.Issue) }).Count -gt 0) {
                $left.Add($entry)
                continue
            }
            $longest = 0.0
            foreach ($dependent in $dependents) { $longest = [math]::Max($longest, $paths[[string] $dependent.Issue]) }
            $paths[[string] $entry.Issue] = [double] $entry.DurationSeconds + $longest
        }
        $pending = @($left)
    }
    return $paths
}

function Get-EpicProgressPriorityOrder {
    <#
    .SYNOPSIS
        Return issues ordered by descending longest remaining path, ties by ascending issue number.
    .PARAMETER Issue
        The issue numbers.
    .PARAMETER Path
        The longest remaining path of each issue.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $Issue,
        [Parameter(Mandatory = $true)] [hashtable] $Path
    )

    $length = @{}
    foreach ($entry in $Issue) { $length[$entry] = [double] $Path[$entry] }
    $list = [System.Collections.Generic.List[string]]::new([string[]] $Issue)
    $list.Sort([System.Comparison[string]] {
            param($left, $right)
            $byPath = $length[$right].CompareTo($length[$left])
            if ($byPath -ne 0) { return $byPath }
            return Compare-EpicProgressIssue -Left $left -Right $right
        })
    return , [string[]] $list.ToArray()
}

function Invoke-EpicProgressListSchedule {
    <#
    .SYNOPSIS
        Simulate list scheduling of the feature nodes under a parallel cap; return Feature rows, FinishSeconds, HeadlineSeconds, and LastIssue (decision E6).
    .DESCRIPTION
        From t = 0: done nodes finish at 0 and hold no slot; running nodes start at 0 and hold
        slots even when their count exceeds the cap; at each event, ready nodes (every
        dependency finished; a dependency that is not a node is satisfied) start while fewer
        than Cap nodes run, by descending longest remaining path to a sink, ties by ascending
        issue number. Each row holds Issue, StartSeconds, FinishSeconds, and Predecessor: the
        dependency that finished last, or, when the start waited for a slot, the node whose
        finish freed it (ties among nodes finishing at the same instant by ascending issue
        number); null for a start at 0 without a dependency. FinishSeconds is the latest finish,
        LastIssue the node that reaches it (ties by ascending issue number), and
        HeadlineSeconds is FinishSeconds plus TailSeconds. A node that can never start, which
        only a cycle causes, has a NaN finish.
    .PARAMETER Node
        The nodes (Issue, State 'done', 'running', or 'pending', DurationSeconds, DependsOn).
    .PARAMETER Cap
        The parallel cap; 0 for no cap.
    .PARAMETER TailSeconds
        The epic tail added after the latest finish; 0 for none.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Node,
        [ValidateRange(0, 1000)] [int] $Cap = 0,
        [double] $TailSeconds = 0
    )

    $issues = [string[]] @($Node | ForEach-Object { [string] $_.Issue })
    $byIssue = @{}
    foreach ($entry in $Node) { $byIssue[[string] $entry.Issue] = $entry }
    $paths = Get-EpicProgressLongestPath -Node $Node
    $start = @{}
    $finish = @{}
    $predecessor = @{}
    $running = [System.Collections.Generic.List[string]]::new()
    $pending = [System.Collections.Generic.List[string]]::new()
    foreach ($issue in (Get-EpicProgressSortedIssue -Issue $issues)) {
        $entry = $byIssue[$issue]
        $predecessor[$issue] = $null
        if ($entry.State -eq 'done') {
            $start[$issue] = 0.0
            $finish[$issue] = 0.0
        } elseif ($entry.State -eq 'running') {
            $start[$issue] = 0.0
            $finish[$issue] = [double] $entry.DurationSeconds
            $running.Add($issue)
        } else {
            $pending.Add($issue)
        }
    }
    $now = 0.0
    $freedBy = $null
    while ($pending.Count -gt 0) {
        foreach ($issue in @($running)) { if ($finish[$issue] -le $now) { $null = $running.Remove($issue) } }
        [string[]] $ready = @($pending | Where-Object {
                $dependencies = @($byIssue[$_].DependsOn | Where-Object { $byIssue.ContainsKey([string] $_) })
                @($dependencies | Where-Object { -not $finish.ContainsKey([string] $_) -or $finish[[string] $_] -gt $now }).Count -eq 0
            })
        $started = $false
        foreach ($issue in (Get-EpicProgressPriorityOrder -Issue $ready -Path $paths)) {
            if ($Cap -gt 0 -and $running.Count -ge $Cap) { break }
            [string[]] $dependencies = @($byIssue[$issue].DependsOn | Where-Object { $byIssue.ContainsKey([string] $_) } | ForEach-Object { [string] $_ })
            $readyAt = 0.0
            $lastDependency = $null
            foreach ($dependency in (Get-EpicProgressSortedIssue -Issue $dependencies)) {
                if ($null -eq $lastDependency -or $finish[$dependency] -gt $readyAt) {
                    $readyAt = [math]::Max($readyAt, $finish[$dependency])
                    $lastDependency = $dependency
                }
            }
            $predecessor[$issue] = $lastDependency
            if ($readyAt -lt $now -and $null -ne $freedBy) { $predecessor[$issue] = $freedBy }
            $start[$issue] = $now
            $finish[$issue] = $now + [double] $byIssue[$issue].DurationSeconds
            $running.Add($issue)
            $null = $pending.Remove($issue)
            $started = $true
        }
        if ($pending.Count -eq 0) { break }
        $later = @($running | Where-Object { $finish[$_] -gt $now } | ForEach-Object { $finish[$_] })
        if ($later.Count -eq 0) {
            if ($started) { continue }
            break
        }
        $now = ($later | Measure-Object -Minimum).Minimum
        $freedBy = (Get-EpicProgressSortedIssue -Issue ([string[]] @($running | Where-Object { $finish[$_] -eq $now })))[0]
    }
    foreach ($issue in $pending) {
        $start[$issue] = [double]::NaN
        $finish[$issue] = [double]::NaN
    }
    $rows = @(foreach ($issue in (Get-EpicProgressSortedIssue -Issue $issues)) {
            [pscustomobject]@{ Issue = $issue; StartSeconds = $start[$issue]; FinishSeconds = $finish[$issue]; Predecessor = $predecessor[$issue] }
        })
    $latest = 0.0
    $lastIssue = $null
    foreach ($row in $rows) {
        if ([double]::IsNaN($row.FinishSeconds)) {
            $latest = [double]::NaN
            break
        }
        if ($null -eq $lastIssue -or $row.FinishSeconds -gt $latest) {
            $latest = $row.FinishSeconds
            $lastIssue = $row.Issue
        }
    }
    return [pscustomobject]@{ Feature = [object[]] $rows; FinishSeconds = $latest; HeadlineSeconds = $latest + $TailSeconds; LastIssue = $lastIssue }
}

function Get-EpicProgressCriticalChain {
    <#
    .SYNOPSIS
        Return the critical chain text '#a -> #b -> tail', walking back from the latest-finishing node through each start's delaying predecessor (decision E6).
    .PARAMETER Schedule
        The result of Invoke-EpicProgressListSchedule.
    .PARAMETER NoTail
        Omit the trailing 'tail' (item mode).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [pscustomobject] $Schedule,
        [switch] $NoTail
    )

    $byIssue = @{}
    foreach ($row in $Schedule.Feature) { $byIssue[[string] $row.Issue] = $row }
    $chain = [System.Collections.Generic.List[string]]::new()
    $current = $Schedule.LastIssue
    while ($null -ne $current -and $byIssue.ContainsKey([string] $current) -and $chain.Count -lt $byIssue.Count) {
        $chain.Insert(0, "#$current")
        $current = $byIssue[[string] $current].Predecessor
    }
    if (-not $NoTail) { $chain.Add('tail') }
    return ($chain -join ' -> ')
}

function Get-EpicProgressEpicTail {
    <#
    .SYNOPSIS
        Return TailSeconds, PredictedSync, and Step rows (Type, Seconds) of the epic tail after the last feature finishes (decision E8).
    .DESCRIPTION
        The tail is the not-done main-sync rows, the integration-pr step, and one predicted
        main-sync step, each timed by Get-EpicProgressTypeEstimate (ledger median, else the
        default; in-progress credit max(0, median - elapsed)). The predicted sync is omitted
        when a recorded sync row that is not done exists and when integration-pr is in
        progress or done; when integration-pr is done the tail is 0. The step list passed in is
        not changed, so the step total and percentage are unchanged.
    .PARAMETER EpicStep
        The epic-level steps from Get-EpicProgressEpicStep.
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
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $EpicStep,
        [Parameter(Mandatory = $true)] [AllowNull()] [hashtable] $Ledger,
        [Parameter(Mandatory = $true)] [hashtable] $Default,
        [Parameter(Mandatory = $true)] [long] $NowUnixSeconds
    )

    $integration = @($EpicStep | Where-Object { $null -ne $_ -and $_.Type -eq 'integration-pr' }) | Select-Object -First 1
    if ($null -eq $integration) { $integration = Get-EpicProgressStepRecord -Issue 'tail' -Type 'integration-pr' }
    if ($integration.Status -eq 'done') { return [pscustomobject]@{ TailSeconds = 0.0; PredictedSync = $false; Step = [object[]] @() } }
    $openSync = @($EpicStep | Where-Object { $null -ne $_ -and $_.Type -eq 'main-sync' -and $_.Status -ne 'done' })
    $predicted = $openSync.Count -eq 0 -and $integration.Status -eq 'remaining'
    $tailSteps = @($openSync) + @($integration)
    if ($predicted) { $tailSteps += Get-EpicProgressStepRecord -Issue 'tail' -Type 'main-sync' -Key 'tail|main-sync|predicted' }
    $estimate = Get-EpicProgressTypeEstimate -Step $tailSteps -Ledger $Ledger -Default $Default -NowUnixSeconds $NowUnixSeconds
    $rows = @($estimate.Type | ForEach-Object { [pscustomobject]@{ Type = $_.Type; Seconds = $_.SubtotalSeconds } })
    return [pscustomobject]@{ TailSeconds = [double] $estimate.TotalSeconds; PredictedSync = $predicted; Step = [object[]] $rows }
}

function Get-EpicProgressFeatureRemainingSecond {
    <#
    .SYNOPSIS
        Return a feature's remaining seconds at a sequential rate: execution tasks at 3600 / rate, other steps at their median (decision E4).
    .DESCRIPTION
        A rate that is not a finite number above 0 prices each remaining execution task at
        infinity. Blocked steps are left out, as in Get-EpicProgressTypeEstimate.
    .PARAMETER Step
        The feature's step records.
    .PARAMETER Rate
        The sequential rate in tasks per hour.
    .PARAMETER Ledger
        The duration ledger.
    .PARAMETER Default
        The default seconds per type.
    .PARAMETER NowUnixSeconds
        The current epoch second.
    .PARAMETER BlockedSince
        The start of each blocked item's span, keyed by issue; empty for none.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Step,
        [Parameter(Mandatory = $true)] [double] $Rate,
        [Parameter(Mandatory = $true)] [AllowNull()] [hashtable] $Ledger,
        [Parameter(Mandatory = $true)] [hashtable] $Default,
        [Parameter(Mandatory = $true)] [long] $NowUnixSeconds,
        [hashtable] $BlockedSince = @{}
    )

    $perTask = [double]::PositiveInfinity
    if ([double]::IsFinite($Rate) -and $Rate -gt 0) { $perTask = 3600.0 / $Rate }
    return Get-EpicProgressTypeEstimate -Step $Step -Ledger $Ledger -Default $Default -NowUnixSeconds $NowUnixSeconds -BlockedSince $BlockedSince -MedianOverride @{ execution = $perTask }
}

function Get-EpicProgressScheduleRange {
    <#
    .SYNOPSIS
        Return the range (FastSeconds, SlowSeconds, NoUpperBound, StandardDeviation, SdSource, Reason) by re-running the schedule at rate +/- 2.05 SD (decision E9).
    .DESCRIPTION
        SD is the across-feature SD when at least 2 features qualify, else the aggregate
        interval SD when at least 3 intervals exist; otherwise both ends are NaN and Reason
        states why. The slow end is infinite with NoUpperBound set when the slow rate of any
        feature with a remaining or in-progress execution task is at or below 0.5 tasks per
        hour.
    .PARAMETER Feature
        The scheduled features (Issue, NodeState, Step, Rate, DependsOn).
    .PARAMETER Pooled
        The pooled velocity (Count, StandardDeviation).
    .PARAMETER Aggregate
        The aggregate velocity (Count, StandardDeviation); null for none.
    .PARAMETER Ledger
        The duration ledger.
    .PARAMETER Default
        The default seconds per type.
    .PARAMETER NowUnixSeconds
        The current epoch second.
    .PARAMETER Cap
        The parallel cap; 0 for no cap.
    .PARAMETER TailSeconds
        The epic tail seconds.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Feature,
        [Parameter(Mandatory = $true)] [pscustomobject] $Pooled,
        [AllowNull()] [object] $Aggregate = $null,
        [Parameter(Mandatory = $true)] [AllowNull()] [hashtable] $Ledger,
        [Parameter(Mandatory = $true)] [hashtable] $Default,
        [Parameter(Mandatory = $true)] [long] $NowUnixSeconds,
        [int] $Cap = 0,
        [double] $TailSeconds = 0
    )

    $range = [pscustomobject]@{ FastSeconds = [double]::NaN; SlowSeconds = [double]::NaN; NoUpperBound = $false; StandardDeviation = [double]::NaN; SdSource = 'n/a'; Reason = '' }
    if ($Pooled.Count -ge 2) {
        $range.StandardDeviation = [double] $Pooled.StandardDeviation
        $range.SdSource = 'across-feature SD'
    } elseif ($null -ne $Aggregate -and $Aggregate.Count -ge 3) {
        $range.StandardDeviation = [double] $Aggregate.StandardDeviation
        $range.SdSource = 'aggregate interval SD'
    } else {
        $range.Reason = 'fewer than 2 qualifying features and fewer than 3 intervals'
        return $range
    }
    $ends = @{}
    foreach ($side in @(@{ Name = 'fast'; Sign = 1.0 }, @{ Name = 'slow'; Sign = -1.0 })) {
        $nodes = foreach ($record in $Feature) {
            $rate = [double] $record.Rate + $side.Sign * 2.05 * $range.StandardDeviation
            $hasTask = @($record.Step | Where-Object { $_.Type -eq 'execution' -and $_.Status -in @('remaining', 'in_progress') }).Count -gt 0
            if ($side.Name -eq 'slow' -and $hasTask -and $rate -le 0.5) { $range.NoUpperBound = $true }
            $seconds = 0.0
            if ($record.NodeState -ne 'done') { $seconds = (Get-EpicProgressFeatureRemainingSecond -Step @($record.Step) -Rate $rate -Ledger $Ledger -Default $Default -NowUnixSeconds $NowUnixSeconds).TotalSeconds }
            [pscustomobject]@{ Issue = $record.Issue; State = $record.NodeState; DurationSeconds = $seconds; DependsOn = [string[]] @($record.DependsOn) }
        }
        $ends[$side.Name] = (Invoke-EpicProgressListSchedule -Node @($nodes) -Cap $Cap -TailSeconds $TailSeconds).HeadlineSeconds
    }
    $range.FastSeconds = $ends['fast']
    $range.SlowSeconds = $ends['slow']
    if ($range.NoUpperBound) { $range.SlowSeconds = [double]::PositiveInfinity }
    return $range
}

function Get-EpicProgressCriticalPathReport {
    <#
    .SYNOPSIS
        Compose the critical-path report: per-feature rates and remaining time, schedule, chain, cap, dependency source, tail, headline, serial sum, range, and exclusions.
    .DESCRIPTION
        Each feature's rate is its own, the pooled, or the default sequential rate; its
        remaining time prices execution tasks at 3600 / rate through -MedianOverride. Blocked
        features and their dependents are excluded from the schedule and the serial sum and
        listed in Excluded with their remaining time (blocked steps included). The headline is
        the schedule finish plus the tail, and the serial sum is the sum of the scheduled
        features' remaining time plus the tail. In item mode the one feature has no
        dependency, no cap, and no tail, and the chain names the item alone.
    .PARAMETER Feature
        The features (Issue, Wave, Folder, State 'Completed', 'Running', or 'Pending', Blocked, Step, TasksDone, TasksTotal).
    .PARAMETER EpicStep
        The epic-level steps; empty in item mode.
    .PARAMETER Ledger
        The duration ledger merged in this run.
    .PARAMETER Default
        The default seconds per type.
    .PARAMETER NowUnixSeconds
        The current epoch second.
    .PARAMETER BlockedSince
        The start of each blocked item's span, keyed by issue; empty for none.
    .PARAMETER CheckpointRow
        The epic checkpoint features rows; empty for none.
    .PARAMETER ManifestRow
        The epic.md frontmatter features rows; empty for none.
    .PARAMETER CheckpointCap
        The epic checkpoint max_parallel_features value; null when absent.
    .PARAMETER ConfigCap
        The routing-config default_max_parallel_features value; null when absent.
    .PARAMETER Aggregate
        The aggregate velocity from Get-EpicProgressAggregateVelocity; null for none.
    .PARAMETER ItemMode
        Report on one item: one node, no cap, and no tail.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Feature,
        [AllowEmptyCollection()] [object[]] $EpicStep = @(),
        [Parameter(Mandatory = $true)] [AllowNull()] [hashtable] $Ledger,
        [Parameter(Mandatory = $true)] [hashtable] $Default,
        [Parameter(Mandatory = $true)] [long] $NowUnixSeconds,
        [hashtable] $BlockedSince = @{},
        [AllowEmptyCollection()] [object[]] $CheckpointRow = @(),
        [AllowEmptyCollection()] [object[]] $ManifestRow = @(),
        [AllowNull()] [object] $CheckpointCap = $null,
        [AllowNull()] [object] $ConfigCap = $null,
        [AllowNull()] [object] $Aggregate = $null,
        [switch] $ItemMode
    )

    $defaultRate = Get-EpicProgressDefaultRate -Default $Default
    $velocities = @($Feature | ForEach-Object { Get-EpicProgressFeatureVelocity -Issue ([string] $_.Issue) -Ledger $Ledger })
    $pooled = Get-EpicProgressPooledVelocity -Feature $velocities -DefaultRate $defaultRate
    $rateOf = @{}
    foreach ($rate in $pooled.Rate) { $rateOf[$rate.Issue] = $rate }
    if ($ItemMode) {
        $graph = [pscustomobject]@{ DependsOn = @{}; Source = 'none'; Message = '' }
        foreach ($record in $Feature) { $graph.DependsOn[[string] $record.Issue] = [string[]] @() }
        $cap = [pscustomobject]@{ Cap = 0; Source = 'none' }
        $tail = [pscustomobject]@{ TailSeconds = 0.0; PredictedSync = $false; Step = [object[]] @() }
    } else {
        $graphInput = @($Feature | ForEach-Object { [pscustomobject]@{ Issue = [string] $_.Issue; Wave = $_.Wave; Folder = [string] $_.Folder; Merged = ($_.State -eq 'Completed') } })
        $graph = Get-EpicProgressDependencyGraph -Feature $graphInput -CheckpointRow $CheckpointRow -ManifestRow $ManifestRow
        $cap = Resolve-EpicProgressParallelCap -CheckpointValue $CheckpointCap -ConfigValue $ConfigCap
        $tail = Get-EpicProgressEpicTail -EpicStep $EpicStep -Ledger $Ledger -Default $Default -NowUnixSeconds $NowUnixSeconds
    }
    $blocked = [string[]] @($Feature | Where-Object { $_.Blocked -and $_.State -ne 'Completed' } | ForEach-Object { [string] $_.Issue })
    $excludedIssues = @(Get-EpicProgressBlockedClosure -Blocked $blocked -DependsOn $graph.DependsOn)
    $nodeStateOf = @{ Completed = 'done'; Running = 'running'; Pending = 'pending' }
    $scheduled = [System.Collections.Generic.List[object]]::new()
    $rows = [System.Collections.Generic.List[object]]::new()
    $excluded = [System.Collections.Generic.List[object]]::new()
    $serial = 0.0
    foreach ($record in $Feature) {
        $issue = [string] $record.Issue
        $rate = $rateOf[$issue]
        $remaining = 0.0
        $blockedPart = 0.0
        if ($record.State -ne 'Completed') {
            $estimate = Get-EpicProgressFeatureRemainingSecond -Step @($record.Step) -Rate $rate.TasksPerHour -Ledger $Ledger -Default $Default -NowUnixSeconds $NowUnixSeconds -BlockedSince $BlockedSince
            $remaining = $estimate.TotalSeconds
            $blockedPart = $estimate.BlockedSubtotalSeconds
        }
        $isExcluded = $excludedIssues -contains $issue
        if ($isExcluded) {
            $excluded.Add([pscustomobject]@{ Issue = $issue; RemainingSeconds = $remaining + $blockedPart })
        } else {
            $serial += $remaining
            $scheduled.Add([pscustomobject]@{ Issue = $issue; NodeState = $nodeStateOf[[string] $record.State]; Step = @($record.Step); Rate = $rate.TasksPerHour; DependsOn = [string[]] @($graph.DependsOn[$issue]) })
        }
        $rows.Add([pscustomobject]@{ Issue = $issue; State = $record.State; TasksDone = $record.TasksDone; TasksTotal = $record.TasksTotal; Rate = $rate.TasksPerHour; RateSource = $rate.Source; RemainingSeconds = $remaining; StartSeconds = [double]::NaN; FinishSeconds = [double]::NaN; Excluded = $isExcluded })
    }
    $nodes = @($scheduled | ForEach-Object { [pscustomobject]@{ Issue = $_.Issue; State = $_.NodeState; DurationSeconds = @($rows | Where-Object Issue -EQ $_.Issue)[0].RemainingSeconds; DependsOn = $_.DependsOn } })
    $schedule = Invoke-EpicProgressListSchedule -Node $nodes -Cap $cap.Cap -TailSeconds $tail.TailSeconds
    foreach ($entry in $schedule.Feature) {
        $row = @($rows | Where-Object Issue -EQ $entry.Issue)[0]
        $row.StartSeconds = $entry.StartSeconds
        $row.FinishSeconds = $entry.FinishSeconds
    }
    return [pscustomobject]@{
        Feature          = [object[]] $rows.ToArray()
        Excluded         = [object[]] $excluded.ToArray()
        Pooled           = $pooled
        DefaultRate      = $defaultRate
        Cap              = $cap.Cap
        CapSource        = $cap.Source
        DependencySource = $graph.Source
        GraphMessage     = $graph.Message
        Tail             = $tail
        FinishSeconds    = $schedule.FinishSeconds
        HeadlineSeconds  = $schedule.HeadlineSeconds
        Chain            = Get-EpicProgressCriticalChain -Schedule $schedule -NoTail:$ItemMode
        SerialSumSeconds = $serial + $tail.TailSeconds
        Range            = Get-EpicProgressScheduleRange -Feature @($scheduled) -Pooled $pooled -Aggregate $Aggregate -Ledger $Ledger -Default $Default -NowUnixSeconds $NowUnixSeconds -Cap $cap.Cap -TailSeconds $tail.TailSeconds
    }
}
