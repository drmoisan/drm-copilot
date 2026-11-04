<#
.SYNOPSIS
    Generated-block markers for the documentation reference generator: marker lines, the
    fence-aware parse of a page body into prose and block segments, and the block merge.

.DESCRIPTION
    A generated block starts with the exact line '<!-- docs:generated:start id=<element-id> -->'
    and ends with '<!-- docs:generated:end id=<element-id> -->', where <element-id> passes
    Test-DocsElementId. A line outside fenced code and outside an open block whose trimmed text
    starts with '<!-- docs:generated:' but is not an exact marker is malformed. Fenced code is
    classified only through the 1021 functions Get-DocsPageFenceLine and Test-DocsPageFenceClose,
    so the generator and the page checker skip the same lines. Inside an open block only marker
    lines are interpreted.

    Merge-DocsReferenceBlock updates desired blocks in place, removes undesired blocks (reporting
    REFERENCE_BLOCK_REMOVED), inserts new blocks next to their nearest present neighbour in
    desired order, and never moves or edits a line outside a block, except that trailing blank
    lines are removed. Every edited region is returned as an edit record
    @{ BeforeStart; BeforeCount; AfterStart; AfterCount } in body coordinates: zero-based indexes
    into the input lines and the output lines.

    Body lines carry no line terminators; a page text is the lines joined with LF plus one final
    LF, so the merge result has no trailing blank line. Page line numbers in findings are
    LineOffset plus the one-based body line number.

    Every function is pure: no filesystem, clock, process, environment or module-scope mutable
    state; inputs are not mutated.

.NOTES
    Issue #1024. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSurface.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsFinding.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsPageMarkdown.psm1') -ErrorAction Stop

function New-DocsReferenceMarkerFinding {
    <#
    .SYNOPSIS
        Builds one marker, fence or block-removal finding for a page (private helper).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [string] $Code,
        [Parameter(Mandatory = $true)] [string] $Message,
        [Parameter(Mandatory = $true)] [string] $PagePath,
        [AllowNull()] [string] $ElementId
    )

    $severity = if ($Code -ceq 'REFERENCE_BLOCK_REMOVED') { 'info' } else { 'error' }
    $nextAction = switch -CaseSensitive ($Code) {
        'REFERENCE_BLOCK_REMOVED' { 'No action is needed; the element is no longer in the snapshot.' }
        'REFERENCE_FENCE_UNCLOSED' { 'Close the fenced code block before the end of the page.' }
        default { 'Restore the generated-block marker lines exactly as the generator wrote them, or delete the whole block.' }
    }
    [string[]] $related = @()
    if (-not [string]::IsNullOrEmpty($ElementId) -and (Test-DocsElementId -ElementId $ElementId)) { $related = @($ElementId) }
    return New-DocsFinding -Code $Code -Severity $severity -Message $Message -NextAction $nextAction -ArtifactPath $PagePath -RelatedId $related
}

function Get-DocsReferenceMarkerLine {
    <#
    .SYNOPSIS
        Returns the start or end marker line of the generated block of ElementId.
    .DESCRIPTION
        Throws DOCS_REFERENCE_MARKER_INVALID when ElementId fails Test-DocsElementId.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $ElementId,
        [Parameter(Mandatory = $true)] [ValidateSet('start', 'end', IgnoreCase = $false)] [string] $Position
    )

    if (-not (Test-DocsElementId -ElementId $ElementId)) { throw "DOCS_REFERENCE_MARKER_INVALID: '$ElementId' is not an element identifier." }
    return "<!-- docs:generated:$Position id=$ElementId -->"
}

function ConvertFrom-DocsReferenceMarkerLine {
    <#
    .SYNOPSIS
        Returns $null for a line that is not marker-like, else @{ Position; ElementId; Malformed }.
    .DESCRIPTION
        A line is marker-like when its trimmed text starts with '<!-- docs:generated:'. It is
        well-formed only when it equals a start or end marker exactly, with an identifier that
        passes Test-DocsElementId. For a malformed line, Position and ElementId hold what could be
        read from the trimmed text, or $null.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Line)

    $trimmed = $Line.Trim()
    if (-not $trimmed.StartsWith('<!-- docs:generated:', [System.StringComparison]::Ordinal)) { return $null }
    $exact = [regex]::Match($Line, '\A<!-- docs:generated:(?<position>start|end) id=(?<id>[^ ]+) -->\z')
    if ($exact.Success -and (Test-DocsElementId -ElementId $exact.Groups['id'].Value)) {
        return @{ Position = $exact.Groups['position'].Value; ElementId = $exact.Groups['id'].Value; Malformed = $false }
    }
    $loose = [regex]::Match($trimmed, '\A<!-- docs:generated:(?<position>start|end)\b(?: id=(?<id>[^ ]*))?')
    $position = if ($loose.Success) { $loose.Groups['position'].Value } else { $null }
    $id = if ($loose.Success -and $loose.Groups['id'].Success) { $loose.Groups['id'].Value } else { $null }
    return @{ Position = $position; ElementId = $id; Malformed = $true }
}

function ConvertFrom-DocsReferenceBody {
    <#
    .SYNOPSIS
        Parses body lines into prose and block segments; returns @{ Segment; Finding }.
    .DESCRIPTION
        Segments are ordered dictionaries: prose @{ Kind = 'prose'; Start; Line } and block
        @{ Kind = 'block'; Start; End; ElementId; Line }, where Start and End are zero-based body
        indexes of the first line and of the end marker and a block Line holds the lines between
        its markers. Concatenating every prose Line and every block's start marker, Line and end
        marker in order reproduces the input. Findings: REFERENCE_MARKER_MALFORMED,
        REFERENCE_MARKER_DUPLICATE, REFERENCE_MARKER_UNBALANCED, REFERENCE_MARKER_MISMATCH and
        REFERENCE_FENCE_UNCLOSED, each naming its page line number.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [AllowEmptyString()] [string[]] $Line,
        [Parameter(Mandatory = $true)] [string] $PagePath,
        [int] $LineOffset = 0
    )

    $segments = [System.Collections.Generic.List[object]]::new()
    $findings = [System.Collections.Generic.List[object]]::new()
    $opened = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $prose = [System.Collections.Generic.List[string]]::new()
    $proseStart = 0
    $block = $null
    $inner = $null
    $fence = $null
    $fenceStart = 0
    for ($index = 0; $index -lt $Line.Count; $index++) {
        $text = $Line[$index]
        $number = $LineOffset + $index + 1
        if ($null -ne $block) {
            $marker = ConvertFrom-DocsReferenceMarkerLine -Line $text
            if ($null -eq $marker -or $marker.Malformed) { $inner.Add($text); continue }
            if ($marker.Position -ceq 'start') {
                $findings.Add((New-DocsReferenceMarkerFinding -Code 'REFERENCE_MARKER_UNBALANCED' -Message "line ${number}: start marker for '$($marker.ElementId)' while the block opened on line $($LineOffset + $block.Start + 1) is still open." -PagePath $PagePath -ElementId $marker.ElementId))
                $inner.Add($text)
                continue
            }
            if ($marker.ElementId -cne $block.ElementId) {
                $findings.Add((New-DocsReferenceMarkerFinding -Code 'REFERENCE_MARKER_MISMATCH' -Message "line ${number}: end marker for '$($marker.ElementId)' closes the block '$($block.ElementId)' opened on line $($LineOffset + $block.Start + 1)." -PagePath $PagePath -ElementId $block.ElementId))
            }
            $segments.Add([ordered]@{ Kind = 'block'; Start = $block.Start; End = $index; ElementId = $block.ElementId; Line = [string[]] $inner.ToArray() })
            $block = $null
            $proseStart = $index + 1
            continue
        }
        if ($null -ne $fence) {
            $close = Get-DocsPageFenceLine -Line $text
            if ($null -ne $close -and (Test-DocsPageFenceClose -Fence $close -OpenFence $fence)) { $fence = $null }
            $prose.Add($text)
            continue
        }
        $open = Get-DocsPageFenceLine -Line $text
        if ($null -ne $open) { $fence = $open; $fenceStart = $index; $prose.Add($text); continue }
        $marker = ConvertFrom-DocsReferenceMarkerLine -Line $text
        if ($null -eq $marker) { $prose.Add($text); continue }
        if ($marker.Malformed) {
            $findings.Add((New-DocsReferenceMarkerFinding -Code 'REFERENCE_MARKER_MALFORMED' -Message "line ${number}: '$($text.Trim())' is not an exact generated-block marker line." -PagePath $PagePath -ElementId $marker.ElementId))
            $prose.Add($text)
            continue
        }
        if ($marker.Position -ceq 'end') {
            $findings.Add((New-DocsReferenceMarkerFinding -Code 'REFERENCE_MARKER_UNBALANCED' -Message "line ${number}: end marker for '$($marker.ElementId)' has no open block." -PagePath $PagePath -ElementId $marker.ElementId))
            $prose.Add($text)
            continue
        }
        if (-not $opened.Add($marker.ElementId)) {
            $findings.Add((New-DocsReferenceMarkerFinding -Code 'REFERENCE_MARKER_DUPLICATE' -Message "line ${number}: start marker repeats the block '$($marker.ElementId)' already opened in the page." -PagePath $PagePath -ElementId $marker.ElementId))
        }
        if ($prose.Count -gt 0) { $segments.Add([ordered]@{ Kind = 'prose'; Start = $proseStart; Line = [string[]] $prose.ToArray() }) }
        $prose = [System.Collections.Generic.List[string]]::new()
        $block = @{ ElementId = $marker.ElementId; Start = $index }
        $inner = [System.Collections.Generic.List[string]]::new()
    }
    if ($null -ne $block) {
        $findings.Add((New-DocsReferenceMarkerFinding -Code 'REFERENCE_MARKER_UNBALANCED' -Message "line $($LineOffset + $block.Start + 1): the block '$($block.ElementId)' is never closed." -PagePath $PagePath -ElementId $block.ElementId))
    } elseif ($prose.Count -gt 0) {
        $segments.Add([ordered]@{ Kind = 'prose'; Start = $proseStart; Line = [string[]] $prose.ToArray() })
    }
    if ($null -ne $fence) {
        $findings.Add((New-DocsReferenceMarkerFinding -Code 'REFERENCE_FENCE_UNCLOSED' -Message "line $($LineOffset + $fenceStart + 1): the fenced code block is not closed before the end of the page." -PagePath $PagePath))
    }
    [object[]] $ordered = @()
    if ($findings.Count -gt 0) { $ordered = Get-DocsOrderedFinding -Finding $findings.ToArray() }
    return @{ Segment = [object[]] $segments.ToArray(); Finding = $ordered }
}

function Test-DocsReferenceBlankLine {
    <#
    .SYNOPSIS
        Returns $true when Text holds only spaces and tabs (private helper).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text)

    return $Text -cmatch '\A[ \t]*\z'
}

function Find-DocsReferenceEntry {
    <#
    .SYNOPSIS
        Returns the index of the entry that is reference-equal to Entry, or -1 (private helper).
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [System.Collections.Generic.List[object]] $List,
        [Parameter(Mandatory = $true)] [hashtable] $Entry
    )

    $target = $Entry
    return $List.FindIndex([System.Predicate[object]] { param($Candidate) [object]::ReferenceEquals($Candidate, $target) })
}

function Get-DocsReferenceEdit {
    <#
    .SYNOPSIS
        Derives the edit records from the merged entry list (private helper).
    .DESCRIPTION
        An entry with Source -1 is a new line; a gap in the increasing Source indexes is a
        removal. Each maximal run of new lines and removals is one edit record.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [System.Collections.Generic.List[object]] $Entry,
        [Parameter(Mandatory = $true)] [int] $InputCount
    )

    $edits = [System.Collections.Generic.List[object]]::new()
    $pending = $null
    $next = 0
    for ($at = 0; $at -le $Entry.Count; $at++) {
        $source = if ($at -lt $Entry.Count) { [int] $Entry[$at].Source } else { $InputCount }
        if ($source -gt $next -or $source -lt 0) {
            if ($null -eq $pending) { $pending = [ordered]@{ BeforeStart = $next; BeforeCount = 0; AfterStart = $at; AfterCount = 0 } }
            if ($source -gt $next) { $pending.BeforeCount += $source - $next; $next = $source }
            if ($source -lt 0) { $pending.AfterCount++; continue }
        }
        if ($null -ne $pending) { $edits.Add($pending); $pending = $null }
        $next = $source + 1
    }
    return , [object[]] $edits.ToArray()
}

function Merge-DocsReferenceBlock {
    <#
    .SYNOPSIS
        Merges the desired generated blocks into body lines; returns @{ Line; Added; Updated; Unchanged; Removed; Edit; Finding }.
    .DESCRIPTION
        Desired is the ordered list of @{ ElementId; Line } items, Line being the block body
        lines. A parse finding returns Line $null, empty lists and the findings. Otherwise an
        existing desired block is updated in place (blank line, body, blank line between its
        markers); an undesired block is deleted with one following blank line when the line
        before it is blank or it starts the body (REFERENCE_BLOCK_REMOVED, info); a new block is
        inserted after the end marker of the nearest preceding present desired block as blank
        line plus block, else before the start marker of the nearest following present block as
        block plus blank line, else at the end after removing trailing blank lines and adding
        one blank line when the body is non-empty. Trailing blank lines are then removed.
        Added, Updated, Unchanged and Removed hold ordinal-sorted identifiers.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [AllowEmptyString()] [string[]] $Line,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Desired,
        [Parameter(Mandatory = $true)] [string] $PagePath,
        [int] $LineOffset = 0
    )

    $parsed = ConvertFrom-DocsReferenceBody -Line $Line -PagePath $PagePath -LineOffset $LineOffset
    if ($parsed.Finding.Count -gt 0) {
        return @{ Line = $null; Added = [string[]]@(); Updated = [string[]]@(); Unchanged = [string[]]@(); Removed = [string[]]@(); Edit = [object[]]@(); Finding = $parsed.Finding }
    }
    $wanted = [System.Collections.Generic.Dictionary[string, string[]]]::new([System.StringComparer]::Ordinal)
    foreach ($item in $Desired) {
        $id = [string] $item.ElementId
        if ($wanted.ContainsKey($id)) { throw "DOCS_REFERENCE_MARKER_INVALID: desired block '$id' is listed twice." }
        $wanted[$id] = [string[]] (@('') + @($item.Line) + @(''))
    }
    $sets = @{ Added = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::Ordinal); Updated = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::Ordinal); Unchanged = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::Ordinal); Removed = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::Ordinal) }
    $findings = [System.Collections.Generic.List[object]]::new()
    $drop = [bool[]]::new($Line.Count)
    $replace = [System.Collections.Generic.Dictionary[int, string[]]]::new()
    $markerId = [System.Collections.Generic.Dictionary[int, string]]::new()
    $blockSegment = @($parsed.Segment | Where-Object { $_.Kind -ceq 'block' })
    foreach ($segment in $blockSegment) {
        $id = [string] $segment.ElementId
        if ($wanted.ContainsKey($id)) {
            $markerId[[int] $segment.Start] = $id
            $markerId[[int] $segment.End] = $id
            if (($segment.Line -join "`n") -ceq ($wanted[$id] -join "`n") -and $segment.Line.Count -eq $wanted[$id].Count) { [void]$sets.Unchanged.Add($id); continue }
            [void]$sets.Updated.Add($id)
            for ($at = $segment.Start + 1; $at -lt $segment.End; $at++) { $drop[$at] = $true }
            $replace[[int] $segment.Start] = $wanted[$id]
            continue
        }
        [void]$sets.Removed.Add($id)
        $last = [int] $segment.End
        $leading = $segment.Start -eq 0 -or (Test-DocsReferenceBlankLine -Text $Line[$segment.Start - 1])
        if ($leading -and $last + 1 -lt $Line.Count -and (Test-DocsReferenceBlankLine -Text $Line[$last + 1])) { $last++ }
        for ($at = [int] $segment.Start; $at -le $last; $at++) { $drop[$at] = $true }
        $findings.Add((New-DocsReferenceMarkerFinding -Code 'REFERENCE_BLOCK_REMOVED' -Message "line $($LineOffset + $segment.Start + 1): removed the generated block '$id', whose element is no longer planned for the page." -PagePath $PagePath -ElementId $id))
    }
    $entries = [System.Collections.Generic.List[object]]::new()
    $startEntry = [System.Collections.Generic.Dictionary[string, hashtable]]::new([System.StringComparer]::Ordinal)
    $endEntry = [System.Collections.Generic.Dictionary[string, hashtable]]::new([System.StringComparer]::Ordinal)
    for ($index = 0; $index -lt $Line.Count; $index++) {
        if (-not $drop[$index]) {
            $entry = @{ Source = $index; Text = $Line[$index] }
            $entries.Add($entry)
            if ($markerId.ContainsKey($index)) {
                $owner = $markerId[$index]
                if ($startEntry.ContainsKey($owner)) { $endEntry[$owner] = $entry } else { $startEntry[$owner] = $entry }
            }
        }
        if ($replace.ContainsKey($index)) { foreach ($text in $replace[$index]) { $entries.Add(@{ Source = -1; Text = $text }) } }
    }
    for ($position = 0; $position -lt $Desired.Count; $position++) {
        $id = [string] $Desired[$position].ElementId
        if ($endEntry.ContainsKey($id)) { continue }
        $blockEntry = [System.Collections.Generic.List[object]]::new()
        $start = @{ Source = -1; Text = (Get-DocsReferenceMarkerLine -ElementId $id -Position 'start') }
        $end = @{ Source = -1; Text = (Get-DocsReferenceMarkerLine -ElementId $id -Position 'end') }
        $blockEntry.Add($start)
        foreach ($text in $wanted[$id]) { $blockEntry.Add(@{ Source = -1; Text = $text }) }
        $blockEntry.Add($end)
        $at = -1
        for ($back = $position - 1; $back -ge 0 -and $at -lt 0; $back--) {
            $neighbour = [string] $Desired[$back].ElementId
            if ($endEntry.ContainsKey($neighbour)) { $at = (Find-DocsReferenceEntry -List $entries -Entry $endEntry[$neighbour]) + 1; $blockEntry.Insert(0, @{ Source = -1; Text = '' }) }
        }
        for ($forward = $position + 1; $forward -lt $Desired.Count -and $at -lt 0; $forward++) {
            $neighbour = [string] $Desired[$forward].ElementId
            if ($startEntry.ContainsKey($neighbour)) { $at = Find-DocsReferenceEntry -List $entries -Entry $startEntry[$neighbour]; $blockEntry.Add(@{ Source = -1; Text = '' }) }
        }
        if ($at -lt 0) {
            while ($entries.Count -gt 0 -and (Test-DocsReferenceBlankLine -Text $entries[$entries.Count - 1].Text)) { $entries.RemoveAt($entries.Count - 1) }
            if ($entries.Count -gt 0) { $blockEntry.Insert(0, @{ Source = -1; Text = '' }) }
            $at = $entries.Count
        }
        $entries.InsertRange($at, $blockEntry)
        $startEntry[$id] = $start
        $endEntry[$id] = $end
        [void]$sets.Added.Add($id)
    }
    while ($entries.Count -gt 0 -and (Test-DocsReferenceBlankLine -Text $entries[$entries.Count - 1].Text)) { $entries.RemoveAt($entries.Count - 1) }
    [string[]] $output = @($entries | ForEach-Object { [string] $_.Text })
    $edit = Get-DocsReferenceEdit -Entry $entries -InputCount $Line.Count
    [object[]] $ordered = @()
    if ($findings.Count -gt 0) { $ordered = Get-DocsOrderedFinding -Finding $findings.ToArray() }
    return @{
        Line      = $output
        Added     = [string[]] @($sets.Added)
        Updated   = [string[]] @($sets.Updated)
        Unchanged = [string[]] @($sets.Unchanged)
        Removed   = [string[]] @($sets.Removed)
        Edit      = $edit
        Finding   = $ordered
    }
}

Export-ModuleMember -Function `
    Get-DocsReferenceMarkerLine, `
    ConvertFrom-DocsReferenceMarkerLine, `
    ConvertFrom-DocsReferenceBody, `
    Merge-DocsReferenceBlock
