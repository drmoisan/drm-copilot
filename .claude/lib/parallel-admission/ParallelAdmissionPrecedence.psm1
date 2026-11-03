<#
.SYNOPSIS
    Pure precedence and scheduling-record functions for the parallel surface (issue #1047).

.DESCRIPTION
    Holds the operator precedence input of /parallel-plan and /parallel-add
    (`--after`): validation of the precedence[] entries, their normalization into
    separating conflict edges, the precedence lift over a cohort table, the
    active-entry resolution and cohort-table check, and the durable scheduling
    record with its edge-reuse rule.

    A precedence entry {before, after} states that the `after` item must start
    in a later cohort than the `before` item. It is a separating input, never a
    `depends_on` key. Every function is pure: no filesystem, subprocess, network,
    or clock access, and no input is mutated. Rejections throw a message that
    starts with the rejection code (precedence_unknown_item, precedence_cycle).
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-ParallelPrecedenceMapValue {
    <#
    .SYNOPSIS
        Return the value stored under Key in a dictionary, or null when the key or the map is absent.
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param([AllowNull()][object] $Map, [string] $Key)

    if ($Map -isnot [System.Collections.IDictionary]) { return $null }
    if (-not $Map.Contains($Key)) { return $null }
    return $Map[$Key]
}

function ConvertTo-ParallelPrecedenceKey {
    <#
    .SYNOPSIS
        Convert an item key (integer or decimal-digit string) to Int64, or return null.
    #>
    [CmdletBinding()]
    [OutputType([object], [long])]
    param([AllowNull()][object] $Value)

    if ($null -eq $Value -or $Value -is [bool]) { return $null }
    $parsed = [long]0
    if ($Value -is [string]) {
        if ($Value -match '^[0-9]+$' -and [long]::TryParse($Value, [ref] $parsed)) { return $parsed }
        return $null
    }
    if ($Value -is [int] -or $Value -is [long] -or $Value -is [int16] -or $Value -is [byte]) { return [long]$Value }
    return $null
}

function Get-ParallelPrecedencePair {
    <#
    .SYNOPSIS
        Read precedence entries into [before, after] Int64 pairs.

    .DESCRIPTION
        Each entry is a dictionary carrying `before` and `after`. An entry whose
        key is missing or is not an integer throws precedence_unknown_item.
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param([AllowNull()][AllowEmptyCollection()][object[]] $Entry = @())

    $pairs = [System.Collections.Generic.List[object]]::new()
    foreach ($item in @($Entry)) {
        if ($null -eq $item) { continue }
        $before = ConvertTo-ParallelPrecedenceKey -Value (Get-ParallelPrecedenceMapValue -Map $item -Key 'before')
        $after = ConvertTo-ParallelPrecedenceKey -Value (Get-ParallelPrecedenceMapValue -Map $item -Key 'after')
        if ($null -eq $before -or $null -eq $after) {
            throw "precedence_unknown_item: a precedence entry must carry integer before and after item keys."
        }
        $pairs.Add([long[]]@($before, $after))
    }
    return , $pairs.ToArray()
}

function Get-ParallelPrecedenceOrder {
    <#
    .SYNOPSIS
        Return the item keys in topological precedence order, ties by ascending key.

    .DESCRIPTION
        Kahn's algorithm over the before -> after pairs. Keys left unvisited lie on
        a cycle, which throws precedence_cycle naming them.
    #>
    [CmdletBinding()]
    [OutputType([long[]], [System.Object[]])]
    param([AllowEmptyCollection()][object[]] $Pair = @(), [AllowEmptyCollection()][long[]] $ItemKey = @())

    $keys = [System.Collections.Generic.SortedSet[long]]::new()
    foreach ($key in @($ItemKey)) { [void]$keys.Add($key) }
    # The loop variable is not named $pair: variable names are case-insensitive, so it would overwrite $Pair.
    foreach ($edge in @($Pair)) { [void]$keys.Add($edge[0]); [void]$keys.Add($edge[1]) }
    $inDegree = @{}
    $successor = @{}
    foreach ($key in $keys) { $inDegree[$key] = 0; $successor[$key] = [System.Collections.Generic.SortedSet[long]]::new() }
    foreach ($edge in @($Pair)) {
        if ($successor[$edge[0]].Add($edge[1])) { $inDegree[$edge[1]]++ }
    }
    $ready = [System.Collections.Generic.SortedSet[long]]::new()
    foreach ($key in $keys) { if ($inDegree[$key] -eq 0) { [void]$ready.Add($key) } }
    $order = [System.Collections.Generic.List[long]]::new()
    while ($ready.Count -gt 0) {
        $next = $ready.Min
        [void]$ready.Remove($next)
        $order.Add($next)
        foreach ($after in $successor[$next]) {
            $inDegree[$after]--
            if ($inDegree[$after] -eq 0) { [void]$ready.Add($after) }
        }
    }
    if ($order.Count -lt $keys.Count) {
        $cyclic = @($keys | Where-Object { $order -notcontains $_ })
        throw "precedence_cycle: the precedence entries form a cycle among items $($cyclic -join ', ')."
    }
    return , $order.ToArray()
}

function Test-ParallelPrecedenceInput {
    <#
    .SYNOPSIS
        Validate precedence entries against the run's item keys.

    .DESCRIPTION
        Throws precedence_unknown_item when an entry names a key that is not an
        item, and precedence_cycle when an entry pairs an item with itself or the
        entries form a cycle. Returns true when the entries are valid.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()][AllowEmptyCollection()][object[]] $Entry = @(), [AllowEmptyCollection()][long[]] $ItemKey = @())

    $pairs = Get-ParallelPrecedencePair -Entry $Entry
    foreach ($pair in $pairs) {
        foreach ($key in $pair) {
            if (@($ItemKey) -notcontains $key) { throw "precedence_unknown_item: precedence entry $($pair[0]):$($pair[1]) names item $key, which is not an item of the run." }
        }
        if ($pair[0] -eq $pair[1]) { throw "precedence_cycle: precedence entry $($pair[0]):$($pair[1]) pairs an item with itself." }
    }
    [void](Get-ParallelPrecedenceOrder -Pair $pairs -ItemKey $ItemKey)
    return $true
}

function ConvertTo-ParallelPrecedenceEdge {
    <#
    .SYNOPSIS
        Normalize precedence entries into separating `a:b` edges with a < b.

    .DESCRIPTION
        Each before/after pair becomes the undirected edge `min:max`, so the
        cohort coloring always separates the pair. Duplicates are removed and the
        edges are sorted by (a, b).
    #>
    [CmdletBinding()]
    [OutputType([string[]], [System.Object[]])]
    param([AllowNull()][AllowEmptyCollection()][object[]] $Entry = @())

    $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $edges = [System.Collections.Generic.List[long[]]]::new()
    foreach ($pair in (Get-ParallelPrecedencePair -Entry $Entry)) {
        $a = [math]::Min($pair[0], $pair[1])
        $b = [math]::Max($pair[0], $pair[1])
        if ($a -eq $b -or -not $seen.Add("${a}:${b}")) { continue }
        $edges.Add([long[]]@($a, $b))
    }
    $sorted = @($edges | Sort-Object -Property @{ Expression = { $_[0] } }, @{ Expression = { $_[1] } })
    return , [string[]]@($sorted | ForEach-Object { "$($_[0]):$($_[1])" })
}

function Get-ParallelPrecedenceNeighbor {
    <#
    .SYNOPSIS
        Build the undirected neighbor map of conflict edges plus precedence pairs.

    .DESCRIPTION
        Edge entries are `a:b` strings of integer keys; a malformed entry throws.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([AllowEmptyCollection()][string[]] $Edge = @(), [AllowEmptyCollection()][object[]] $Pair = @())

    $neighbor = @{}
    $link = {
        param([long] $Left, [long] $Right)
        foreach ($side in @(@($Left, $Right), @($Right, $Left))) {
            if (-not $neighbor.ContainsKey($side[0])) { $neighbor[$side[0]] = [System.Collections.Generic.HashSet[long]]::new() }
            [void]$neighbor[$side[0]].Add($side[1])
        }
    }
    foreach ($text in @($Edge)) {
        if ([string]::IsNullOrWhiteSpace($text)) { continue }
        if ($text -notmatch '^\s*([0-9]+):([0-9]+)\s*$') { throw "Conflict edge '$text' is not of the form <a>:<b>." }
        & $link ([long]$Matches[1]) ([long]$Matches[2])
    }
    foreach ($edgePair in @($Pair)) { & $link $edgePair[0] $edgePair[1] }
    return $neighbor
}

function Invoke-ParallelPrecedenceLift {
    <#
    .SYNOPSIS
        Lift unstarted `after` items into later cohorts than their `before` items.

    .DESCRIPTION
        Visits the cohort items in topological precedence order (ties by ascending
        key). An unpinned `after` item whose cohort index is not above every
        `before` index moves to the smallest index at or above both
        max(before index) + 1 and Floor that holds no conflict neighbor (conflict
        edges plus precedence pairs, pinned neighbors included). Pinned items
        never move and unstarted items only move upward, so every cohort stays an
        independent set and a second application changes nothing. A pinned
        `after` item that violates its precedence is left in place; the
        cohort-table check reports it.

    .PARAMETER Cohort
        The cohort table: one array of item keys per cohort index.

    .PARAMETER Edge
        Conflict edges as `a:b` strings.

    .PARAMETER Precedence
        precedence[] entries carrying `before` and `after`.

    .PARAMETER Pinned
        Item keys that have started and therefore cannot move.

    .PARAMETER Floor
        The lowest cohort index a moved item may take.

    .OUTPUTS
        System.Object[] of Int64 arrays, one per cohort; trailing empty cohorts are dropped.
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param(
        [AllowEmptyCollection()][object[]] $Cohort = @(),
        [AllowEmptyCollection()][string[]] $Edge = @(),
        [AllowNull()][AllowEmptyCollection()][object[]] $Precedence = @(),
        [AllowEmptyCollection()][long[]] $Pinned = @(),
        [int] $Floor = 0
    )

    $table = [System.Collections.Generic.List[System.Collections.Generic.SortedSet[long]]]::new()
    $position = @{}
    foreach ($members in @($Cohort)) {
        $set = [System.Collections.Generic.SortedSet[long]]::new()
        foreach ($member in @($members)) {
            $key = ConvertTo-ParallelPrecedenceKey -Value $member
            if ($null -eq $key) { throw "Cohort member '$member' is not an integer item key." }
            if ($position.ContainsKey($key)) { throw "Item $key appears in more than one cohort." }
            [void]$set.Add($key)
            $position[$key] = $table.Count
        }
        $table.Add($set)
    }
    $itemKey = [long[]]@($position.Keys)
    [void](Test-ParallelPrecedenceInput -Entry $Precedence -ItemKey $itemKey)
    $pairs = Get-ParallelPrecedencePair -Entry $Precedence
    $neighbor = Get-ParallelPrecedenceNeighbor -Edge $Edge -Pair $pairs

    foreach ($key in (Get-ParallelPrecedenceOrder -Pair $pairs -ItemKey $itemKey)) {
        $before = @($pairs | Where-Object { $_[1] -eq $key } | ForEach-Object { $_[0] })
        if ($before.Count -eq 0 -or @($Pinned) -contains $key) { continue }
        $need = (@($before | ForEach-Object { $position[$_] }) | Measure-Object -Maximum).Maximum + 1
        if ($position[$key] -ge $need) { continue }
        $target = [math]::Max([int]$need, $Floor)
        while ($true) {
            while ($table.Count -le $target) { $table.Add([System.Collections.Generic.SortedSet[long]]::new()) }
            $blocked = $neighbor.ContainsKey($key) -and @($table[$target] | Where-Object { $neighbor[$key].Contains($_) }).Count -gt 0
            if (-not $blocked) { break }
            $target++
        }
        [void]$table[$position[$key]].Remove($key)
        [void]$table[$target].Add($key)
        $position[$key] = $target
    }
    while ($table.Count -gt 0 -and $table[$table.Count - 1].Count -eq 0) { $table.RemoveAt($table.Count - 1) }
    $result = [System.Collections.Generic.List[object]]::new()
    foreach ($set in $table) { $result.Add([long[]]@($set)) }
    return , $result.ToArray()
}

# A predecessor in one of these merge states, or in state withdrawn, no longer
# constrains its dependent (decision D6). A blocked predecessor still holds.
$script:ReleasedMergeStatus = @('merged', 'worktree_removed')

function Get-ParallelActivePrecedence {
    <#
    .SYNOPSIS
        Resolve the precedence entries that still constrain scheduling.

    .DESCRIPTION
        Each entry's keys are mapped to the item that carries them: an item
        carries its own issue_num and every key in its combined_issue_nums, so a
        combined item inherits the union of its members' entries, and a pair
        inside one combination is dropped. An entry is inactive when its `before`
        item has merge_status merged or worktree_removed, or state withdrawn; a
        blocked predecessor holds (D6). A key that resolves to no item throws
        precedence_unknown_item. Duplicate entries collapse to one.

    .OUTPUTS
        System.Object[] of pscustomobject {before, after}, sorted by (before, after).
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param([AllowNull()][AllowEmptyCollection()][object[]] $Precedence = @(), [AllowNull()][AllowEmptyCollection()][object[]] $Item = @())

    $owner = @{}
    $record = @{}
    foreach ($entry in @($Item)) {
        $key = ConvertTo-ParallelPrecedenceKey -Value (Get-ParallelPrecedenceMapValue -Map $entry -Key 'issue_num')
        if ($null -eq $key) { continue }
        $record[$key] = $entry
        $owner[$key] = $key
        foreach ($member in @(Get-ParallelPrecedenceMapValue -Map $entry -Key 'combined_issue_nums')) {
            $memberKey = ConvertTo-ParallelPrecedenceKey -Value $member
            if ($null -ne $memberKey) { $owner[$memberKey] = $key }
        }
    }
    $active = [System.Collections.Generic.SortedDictionary[string, object]]::new([System.StringComparer]::Ordinal)
    foreach ($pair in (Get-ParallelPrecedencePair -Entry $Precedence)) {
        foreach ($side in $pair) {
            if (-not $owner.ContainsKey($side)) { throw "precedence_unknown_item: precedence entry $($pair[0]):$($pair[1]) names item $side, which is not an item of the run." }
        }
        $before = [long]$owner[$pair[0]]
        $after = [long]$owner[$pair[1]]
        if ($before -eq $after) { continue }
        $predecessor = $record[$before]
        $mergeStatus = Get-ParallelPrecedenceMapValue -Map $predecessor -Key 'merge_status'
        $state = Get-ParallelPrecedenceMapValue -Map $predecessor -Key 'state'
        if ($script:ReleasedMergeStatus -ccontains $mergeStatus -or $state -ceq 'withdrawn') { continue }
        $active[('{0:D20}:{1:D20}' -f $before, $after)] = [pscustomobject]@{ before = $before; after = $after }
    }
    return , [object[]]@($active.Values)
}

function Test-ParallelPrecedenceCohortTable {
    <#
    .SYNOPSIS
        Check a parallel checkpoint's current-generation cohort table against its active precedence entries.

    .DESCRIPTION
        For each active entry, the cohort index of the `after` item must be
        strictly greater than the index of the `before` item within the cohorts
        whose generation equals recolor_generation. An entry whose item is in no
        current-generation cohort is not compared. An absent precedence key gives
        a satisfied table.

    .OUTPUTS
        pscustomobject with Satisfied, Violation (strings), and Active (the active entries).
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([AllowNull()][object] $Checkpoint)

    if ($Checkpoint -isnot [System.Collections.IDictionary]) { throw 'The parallel checkpoint must be a JSON object.' }
    $active = Get-ParallelActivePrecedence -Precedence @(Get-ParallelPrecedenceMapValue -Map $Checkpoint -Key 'precedence') -Item @(Get-ParallelPrecedenceMapValue -Map $Checkpoint -Key 'items')
    $generation = Get-ParallelPrecedenceMapValue -Map $Checkpoint -Key 'recolor_generation'
    $index = @{}
    foreach ($cohort in @(Get-ParallelPrecedenceMapValue -Map $Checkpoint -Key 'cohorts')) {
        if ((Get-ParallelPrecedenceMapValue -Map $cohort -Key 'generation') -ne $generation) { continue }
        $cohortIndex = Get-ParallelPrecedenceMapValue -Map $cohort -Key 'index'
        foreach ($member in @(Get-ParallelPrecedenceMapValue -Map $cohort -Key 'item_keys')) {
            $memberKey = ConvertTo-ParallelPrecedenceKey -Value $member
            if ($null -ne $memberKey) { $index[$memberKey] = [long]$cohortIndex }
        }
    }
    $violation = [System.Collections.Generic.List[string]]::new()
    foreach ($entry in $active) {
        if (-not $index.ContainsKey($entry.before) -or -not $index.ContainsKey($entry.after)) { continue }
        if ($index[$entry.after] -le $index[$entry.before]) {
            $violation.Add("item $($entry.after) in cohort $($index[$entry.after]) must follow item $($entry.before) in cohort $($index[$entry.before])")
        }
    }
    return [pscustomobject]@{ Satisfied = ($violation.Count -eq 0); Violation = [string[]]$violation.ToArray(); Active = $active }
}

function ConvertTo-ParallelSchedulingProjection {
    <#
    .SYNOPSIS
        Project each dictionary onto the named keys in ordinal key order; a missing key becomes null.
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param([AllowNull()][AllowEmptyCollection()][object[]] $Value = @(), [string[]] $Key)

    $sortedKey = [string[]]@($Key)
    [Array]::Sort($sortedKey, [System.StringComparer]::Ordinal)
    $projection = [System.Collections.Generic.List[object]]::new()
    foreach ($entry in @($Value)) {
        if ($entry -isnot [System.Collections.IDictionary]) { continue }
        $row = [ordered]@{}
        foreach ($name in $sortedKey) { $row[$name] = Get-ParallelPrecedenceMapValue -Map $entry -Key $name }
        $projection.Add($row)
    }
    return , $projection.ToArray()
}

$script:RecordItemKey = @('issue_num', 'branch_name', 'plan_path', 'plan_hash', 'base_commit', 'preparation_status', 'complexity_band')

function New-ParallelSchedulingRecord {
    <#
    .SYNOPSIS
        Build the durable scheduling record docs/features/parallel/<slug>/parallel-scheduling.json.

    .DESCRIPTION
        The record carries exactly schema_version, parallel_slug, edges,
        tolerated_overlaps, precedence, and items. Edges keep a, b, and reason;
        tolerated overlaps keep a, b, reasons, cost, and benefit; precedence
        entries keep before, after, source, and recorded_at; items keep
        issue_num, branch_name, plan_path, plan_hash, base_commit,
        preparation_status, and complexity_band. Keys are in ordinal order at
        every level and lists are sorted by their keys, so the same input always
        yields the same record. The function builds content only; the caller
        writes and commits it.

    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure record constructor; no state is changed.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [string] $Slug,
        [AllowNull()][AllowEmptyCollection()][object[]] $Edge = @(),
        [AllowNull()][AllowEmptyCollection()][object[]] $ToleratedOverlap = @(),
        [AllowNull()][AllowEmptyCollection()][object[]] $Precedence = @(),
        [AllowNull()][AllowEmptyCollection()][object[]] $Item = @()
    )

    if ([string]::IsNullOrWhiteSpace($Slug)) { throw 'New-ParallelSchedulingRecord requires -Slug.' }
    $byPair = { @{ Expression = { [long]$_['a'] } }, @{ Expression = { [long]$_['b'] } } }
    # Each projection is parenthesized so the pipeline enumerates its rows rather than passing the array as one object.
    $edges = @((ConvertTo-ParallelSchedulingProjection -Value $Edge -Key @('a', 'b', 'reason')) | Sort-Object -Property (& $byPair))
    $tolerated = @((ConvertTo-ParallelSchedulingProjection -Value $ToleratedOverlap -Key @('a', 'b', 'reasons', 'cost', 'benefit')) | Sort-Object -Property (& $byPair))
    $precedence = @((ConvertTo-ParallelSchedulingProjection -Value $Precedence -Key @('before', 'after', 'source', 'recorded_at')) |
            Sort-Object -Property @{ Expression = { [long]$_['before'] } }, @{ Expression = { [long]$_['after'] } })
    $items = @((ConvertTo-ParallelSchedulingProjection -Value $Item -Key $script:RecordItemKey) | Sort-Object -Property @{ Expression = { [long]$_['issue_num'] } })
    $record = [ordered]@{}
    $record['edges'] = [object[]]$edges
    $record['items'] = [object[]]$items
    $record['parallel_slug'] = $Slug
    $record['precedence'] = [object[]]$precedence
    $record['schema_version'] = [long]1
    $record['tolerated_overlaps'] = [object[]]$tolerated
    return $record
}

function Get-ParallelSchedulingRecordReuse {
    <#
    .SYNOPSIS
        Decide whether a re-seed may reuse an item's recorded conflict edges.

    .DESCRIPTION
        Reuse applies only when the record lists the item and its recorded
        plan_hash equals the current plan blob hash; the item's recorded edges
        (those with the item at either end) are then returned. Otherwise the
        result is a recompute marker with the reason unknown_item or
        plan_hash_changed.

    .OUTPUTS
        pscustomobject with action (reuse or recompute), reason, and edges.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([AllowNull()][object] $Record, [long] $IssueNum, [AllowNull()][AllowEmptyString()][string] $CurrentPlanHash)

    $recorded = @(@(Get-ParallelPrecedenceMapValue -Map $Record -Key 'items') | Where-Object {
            (ConvertTo-ParallelPrecedenceKey -Value (Get-ParallelPrecedenceMapValue -Map $_ -Key 'issue_num')) -eq $IssueNum
        })
    if ($recorded.Count -eq 0) {
        return [pscustomobject]@{ action = 'recompute'; reason = 'unknown_item'; edges = [object[]]@() }
    }
    $hash = Get-ParallelPrecedenceMapValue -Map $recorded[0] -Key 'plan_hash'
    if ([string]::IsNullOrEmpty($CurrentPlanHash) -or [string]$hash -cne $CurrentPlanHash) {
        return [pscustomobject]@{ action = 'recompute'; reason = 'plan_hash_changed'; edges = [object[]]@() }
    }
    $edges = @(@(Get-ParallelPrecedenceMapValue -Map $Record -Key 'edges') | Where-Object {
            $_ -is [System.Collections.IDictionary] -and (
                (ConvertTo-ParallelPrecedenceKey -Value $_['a']) -eq $IssueNum -or (ConvertTo-ParallelPrecedenceKey -Value $_['b']) -eq $IssueNum)
        })
    return [pscustomobject]@{ action = 'reuse'; reason = 'plan_hash_matches'; edges = [object[]]$edges }
}

Export-ModuleMember -Function `
    ConvertTo-ParallelPrecedenceKey, `
    Get-ParallelPrecedencePair, `
    Get-ParallelPrecedenceOrder, `
    Test-ParallelPrecedenceInput, `
    ConvertTo-ParallelPrecedenceEdge, `
    Invoke-ParallelPrecedenceLift, `
    Get-ParallelActivePrecedence, `
    Test-ParallelPrecedenceCohortTable, `
    New-ParallelSchedulingRecord, `
    Get-ParallelSchedulingRecordReuse
