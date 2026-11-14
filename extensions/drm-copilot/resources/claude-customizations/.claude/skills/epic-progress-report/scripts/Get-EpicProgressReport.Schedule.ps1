<#
.SYNOPSIS
    Scheduling functions for Get-EpicProgressReport.ps1: dependency graph, parallel cap, dependency cycle, blocked closure, longest path, priority order, and list schedule.

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
        Numbers that both parse as integers compare numerically; a number orders before any
        other value, such as an external node '<epic>#<issue>' (issue #1162); any other pair
        compares by ordinal text.
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
    $leftIsNumber = [long]::TryParse($Left, $style, $culture, [ref] $leftNumber)
    $rightIsNumber = [long]::TryParse($Right, $style, $culture, [ref] $rightNumber)
    if ($leftIsNumber -and $rightIsNumber) { return $leftNumber.CompareTo($rightNumber) }
    if ($leftIsNumber) { return -1 }
    if ($rightIsNumber) { return 1 }
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
    .DESCRIPTION
        Unlike _epic_orchestrator_state_resolution.py, which strips only the four lifecycle prefixes and reads every string as a
        folder hint, any path gives its last segment here and a digits-only string is an issue number (in the graph builder).
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
        the waves; Message is empty for a valid graph. Unlike _epic_orchestrator_state_resolution.py, a digits-only
        string (after an optional '#') is an issue number and a folder hint is the last segment of any path, not only
        of the four lifecycle prefixes; both affect only references the epic checkpoint validator rejects or
        folders named only by digits (see ConvertTo-EpicProgressFolderHint).
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
        only a cycle causes, has a NaN finish. A node whose External property is true (a
        cross-epic prerequisite, issue #1162) never occupies a slot and starts when ready.
    .PARAMETER Node
        The nodes (Issue, State 'done', 'running', or 'pending', DurationSeconds, DependsOn, and
        optionally External).
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
    $external = @{}
    foreach ($entry in $Node) {
        $byIssue[[string] $entry.Issue] = $entry
        $external[[string] $entry.Issue] = ($entry.PSObject.Properties.Name -contains 'External') -and [bool] $entry.External
    }
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
            # External nodes hold no slot, so a full cap skips only this epic's nodes.
            $slotsUsed = @($running | Where-Object { -not $external[$_] }).Count
            if ($Cap -gt 0 -and -not $external[$issue] -and $slotsUsed -ge $Cap) { continue }
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
