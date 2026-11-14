<#
.SYNOPSIS
    Access-aware path-pair weight and read-only path derivation (issue #1164).

.DESCRIPTION
    Pure helpers for the integration-cost scheduling layer. An item may carry two
    optional access lists beside its blast_radius block: read_paths (radius
    paths the item only reads) and separable_paths (radius paths whose edits
    sit in separable sections). Neither list removes a path from the radius;
    each only lowers the merge-time estimate of an overlapping path pair.

    Get-BlastRadiusAccessPathPairWeight is the PowerShell port of
    _path_pair_weight in scripts/dev_tools/_blast_radius_scheduling.py and
    applies the rows of spec section B2 in order: read-only on either side (0),
    append-only, separable on both sides (when the weight is configured),
    same file, and possible overlap. Without access lists the weight equals the
    former Get-PathPairWeight of BlastRadiusScheduling.psm1 for every input.

    Get-BlastRadiusReadOnlyPath derives read_paths from approved plan text
    passed in memory: a radius path is read-only when every task naming it has
    a read verb as its first title word, no naming title carries a write verb
    or one of its inflections (writes, updated, copying, written), and no task whose
    title begins with Create names it.

    Every function is pure: no filesystem, subprocess, network, or clock access,
    and no input is mutated.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'BlastRadiusGlob.psm1') -Force -ErrorAction Stop
Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'BlastRadiusConflict.psm1') -Force -ErrorAction Stop

# First title words that mark a task as reading the paths it names.
$script:ReadTitleVerb = @('Read', 'Verify', 'Confirm', 'Inspect', 'Review', 'Baseline', 'Run', 'Execute')

# Title words that mark a task as writing the paths it names.
$script:WriteTitleVerb = @(
    'Add', 'Append', 'Change', 'Copy', 'Create', 'Delete', 'Edit', 'Extend', 'Fix', 'Generate', 'Implement',
    'Insert', 'Modify', 'Move', 'Overwrite', 'Port', 'Refactor', 'Regenerate', 'Remove', 'Rename', 'Replace', 'Rewrite', 'Update',
    'Wire', 'Write'
)

# Every write verb with its inflections (s, es, ed, ing; d and e-dropping ing for
# a final e; ies and ied for a final consonant and y), compared case-insensitively.
$script:WriteTitleWordSet = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
foreach ($writeVerb in $script:WriteTitleVerb) {
    foreach ($suffix in @('', 's', 'es', 'ed', 'ing')) { [void]$script:WriteTitleWordSet.Add($writeVerb + $suffix) }
    $stem = $writeVerb.Substring(0, $writeVerb.Length - 1)
    if ($writeVerb.EndsWith('e')) {
        [void]$script:WriteTitleWordSet.Add($writeVerb + 'd')
        [void]$script:WriteTitleWordSet.Add($stem + 'ing')
    }
    if ($writeVerb -match '[^aeiou]y$') {
        [void]$script:WriteTitleWordSet.Add($stem + 'ies')
        [void]$script:WriteTitleWordSet.Add($stem + 'ied')
    }
}

# The irregular past and past-participle forms of Write, Rewrite, and Overwrite;
# every other write verb inflects regularly. Adding them only grows the set, so a
# path classified as written stays written.
$script:WriteTitleIrregularForm = @('Wrote', 'Written', 'Rewrote', 'Rewritten', 'Overwrote', 'Overwritten')
foreach ($irregularForm in $script:WriteTitleIrregularForm) { [void]$script:WriteTitleWordSet.Add($irregularForm) }

# A task line of an atomic plan: a checkbox, the task id, then the title.
$script:TaskLinePattern = '^\s*-\s*\[[ xX]\]\s*\[P\d+-T\d+\]\s*(?<title>.*)$'

function Get-AccessListEntry {
    <#
    .SYNOPSIS
        Return the string entries of one access list, or an empty array when absent.
    .PARAMETER Access
        The item's access lists (read_paths, separable_paths), or null.
    .PARAMETER Name
        The access-list name to read.
    .OUTPUTS
        System.String[]. The entries in order; empty when the list is absent or null.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [AllowNull()]
        [System.Collections.IDictionary] $Access,
        [Parameter(Mandatory = $true)]
        [string] $Name
    )

    if ($null -eq $Access -or -not $Access.Contains($Name) -or $null -eq $Access[$Name]) { return [string[]]@() }
    # Cast every entry to a string so ordinal membership tests compare strings only.
    return [string[]]@($Access[$Name] | ForEach-Object { [string]$_ })
}

function Get-BlastRadiusAccessPathPairWeight {
    <#
    .SYNOPSIS
        Weigh one overlapping path pair with the items' access declarations.

    .DESCRIPTION
        Port of _path_pair_weight. The first matching row applies: 0 when EntryA
        is in AccessA read_paths or EntryB is in AccessB read_paths; append_only
        when a concrete entry matches append_only_paths; separable when EntryA is
        in AccessA separable_paths, EntryB is in AccessB separable_paths, and the
        tolerance carries a separable weight; same_file for two equal concrete
        entries; otherwise possible_overlap. Membership is ordinal.

    .PARAMETER EntryA
        The path entry of the first item.

    .PARAMETER EntryB
        The overlapping path entry of the second item.

    .PARAMETER Tolerance
        A value returned by Get-ConfigConflictTolerance.

    .PARAMETER AccessA
        Optional access lists of the first item (read_paths, separable_paths).

    .PARAMETER AccessB
        Optional access lists of the second item (read_paths, separable_paths).

    .OUTPUTS
        System.Int64. The weight.
    #>
    [CmdletBinding()]
    [OutputType([long])]
    param(
        [Parameter(Mandatory = $true)]
        [string] $EntryA,
        [Parameter(Mandatory = $true)]
        [string] $EntryB,
        [Parameter(Mandatory = $true)]
        [hashtable] $Tolerance,
        [AllowNull()]
        [System.Collections.IDictionary] $AccessA,
        [AllowNull()]
        [System.Collections.IDictionary] $AccessB
    )

    # Row 1: a path one side only reads costs nothing to integrate.
    if ((Get-AccessListEntry -Access $AccessA -Name 'read_paths') -ccontains $EntryA -or
        (Get-AccessListEntry -Access $AccessB -Name 'read_paths') -ccontains $EntryB) {
        return [long]0
    }

    # Row 2: only a concrete entry can name an append-only file.
    $concrete = @(@($EntryA, $EntryB) | Where-Object { -not (Test-GlobEntry -Entry $_) })
    $appendOnly = [string[]]@($Tolerance['append_only_paths'])
    # The first concrete entry that matches an append-only path decides the row.
    foreach ($entry in $concrete) {
        if (Test-MergeablePath -Entry $entry -MergeablePath $appendOnly) {
            return [long]$Tolerance['weights']['append_only']
        }
    }

    # Row 3: separable on both sides, and only when the weight is configured.
    $weights = $Tolerance['weights']
    if ($weights.ContainsKey('separable') -and
        (Get-AccessListEntry -Access $AccessA -Name 'separable_paths') -ccontains $EntryA -and
        (Get-AccessListEntry -Access $AccessB -Name 'separable_paths') -ccontains $EntryB) {
        return [long]$weights['separable']
    }

    # Rows 4 and 5: an equal concrete pair is the same file; anything else may overlap.
    if ($concrete.Count -eq 2 -and [string]::Equals($EntryA, $EntryB, [System.StringComparison]::Ordinal)) {
        return [long]$weights['same_file']
    }
    return [long]$weights['possible_overlap']
}

function Get-PlanTaskWindow {
    <#
    .SYNOPSIS
        Return the task windows of a plan: each holds the title and the window text.
    .PARAMETER PlanText
        The approved plan text, passed in memory.
    .OUTPUTS
        System.Object[]. One hashtable per task line, with keys title and text.
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param(
        [AllowEmptyString()]
        [string] $PlanText
    )

    $window = [System.Collections.Generic.List[object]]::new()
    $current = $null
    # Walk the plan once: a task line opens a window and later lines join it.
    foreach ($line in ($PlanText -split "\r?\n")) {
        $match = [regex]::Match($line, $script:TaskLinePattern)
        if ($match.Success) {
            $current = @{ title = $match.Groups['title'].Value.Trim(); lines = [System.Collections.Generic.List[string]]::new() }
            $current['lines'].Add($line)
            $window.Add($current)
            continue
        }
        # A heading ends the current task window.
        if ($line -match '^\s*#') { $current = $null; continue }
        if ($null -ne $current) { $current['lines'].Add($line) }
    }
    # Join each window's lines into one text so path naming is a substring test.
    return @($window | ForEach-Object { @{ title = $_['title']; text = ($_['lines'] -join "`n") } })
}

function Get-TitleWord {
    <#
    .SYNOPSIS
        Split a title into its alphabetic words; backticks and punctuation separate words.
    .PARAMETER Title
        The task title.
    .OUTPUTS
        System.String[]. The words in title order.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [AllowEmptyString()]
        [string] $Title
    )

    # Drop the empty pieces that leading, trailing, or repeated separators produce.
    return [string[]]@($Title -split '[^A-Za-z]+' | Where-Object { $_ })
}

function Test-WriteTitleWord {
    <#
    .SYNOPSIS
        Report whether a title word is a write verb or one of its inflections.
    .PARAMETER Word
        One title word.
    .OUTPUTS
        System.Boolean. True when the word is in the write-word set, compared case-insensitively.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string] $Word
    )

    return $script:WriteTitleWordSet.Contains($Word)
}

function Test-ReadOnlyWindowSet {
    <#
    .SYNOPSIS
        Report whether every window naming a path is a read task (no write verb, no Create).
    .PARAMETER Window
        The task windows that name the path.
    .OUTPUTS
        System.Boolean. True when every window is a read task.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [object[]] $Window
    )

    # One write-like window makes the path a write path, so the first such window decides.
    foreach ($entry in $Window) {
        $words = @(Get-TitleWord -Title $entry['title'])
        $first = if ($words.Count -gt 0) { $words[0] } else { '' }
        # A write verb anywhere in the title outweighs a read verb in first position.
        $hasWriteVerb = @($words | Where-Object { Test-WriteTitleWord -Word $_ }).Count -gt 0
        if ($first -ceq 'Create' -or $script:ReadTitleVerb -cnotcontains $first -or $hasWriteVerb) { return $false }
    }
    return $true
}

function Get-BlastRadiusReadOnlyPath {
    <#
    .SYNOPSIS
        Derive the read-only radius paths of one item from its approved plan text.

    .DESCRIPTION
        A radius path is read-only when at least one task window names it, the
        first title word of every naming window is one of Read, Verify, Confirm,
        Inspect, Review, Baseline, Run, or Execute, no naming title contains a
        write verb or one of its inflections (for example writes, updated,
        copying, or written), and no task whose title begins with Create names it. A task
        window is a checkbox task line with its id and every following line up to
        the next task line or heading; a window names a path when its text
        contains the path ordinally. A path the plan creates is therefore never
        read-only, and a path no task names is not derived (fail closed).

    .PARAMETER PlanText
        The approved plan text, passed in memory.

    .PARAMETER RadiusPath
        The item's blast_radius.paths.

    .OUTPUTS
        System.String[]. The read-only paths, in RadiusPath order without repeats.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        [string] $PlanText,
        [AllowNull()]
        [AllowEmptyCollection()]
        [string[]] $RadiusPath
    )

    $windows = @(Get-PlanTaskWindow -PlanText ([string]$PlanText))
    $result = [System.Collections.Generic.List[string]]::new()
    # Test each radius path once, in RadiusPath order, against the windows that name it.
    foreach ($path in @($RadiusPath)) {
        if ([string]::IsNullOrEmpty($path) -or $result.Contains($path)) { continue }
        # A window names the path when its text contains the path ordinally.
        $naming = @($windows | Where-Object { $_['text'].Contains($path, [System.StringComparison]::Ordinal) })
        if ($naming.Count -gt 0 -and (Test-ReadOnlyWindowSet -Window $naming)) { $result.Add($path) }
    }
    return [string[]]$result.ToArray()
}

Export-ModuleMember -Function `
    Get-BlastRadiusAccessPathPairWeight, `
    Get-BlastRadiusReadOnlyPath
