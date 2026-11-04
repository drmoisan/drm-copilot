<#
.SYNOPSIS
    Report output of the documentation reference generator: the dry-run diff, the result object
    of the -Json envelope and the command lines of the text report.

.DESCRIPTION
    Format-DocsReferenceDiff prints the edited regions of one page as unified-diff hunks with up
    to three context lines. ConvertTo-DocsReferenceResult builds the result object
    {mode, output_directory, pages, summary, unrendered} from a generation and the write
    statuses. Get-DocsReferenceReportLine returns the command lines of the text report: the page
    lines, the dry-run diff lines, the orphan reminder per created page and the mode line.

    Every function is pure: no filesystem, clock, process, environment or module-scope mutable
    state; inputs are not mutated. Pages are ordered by ordinal path.

.NOTES
    Issue #1024. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    Split from DocsReferenceWriter.psm1 under the file-size contingency of the issue #1024 spec.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-DocsReferenceOrderedPage {
    <#
    .SYNOPSIS
        Returns the page records ordered by the ordinal value of their path key (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Page,
        [Parameter(Mandatory = $true)] [string] $Key
    )

    $sorted = [System.Collections.Generic.SortedDictionary[string, object]]::new([System.StringComparer]::Ordinal)
    for ($index = 0; $index -lt $Page.Count; $index++) { $sorted[[string] $Page[$index][$Key] + [char]0 + $index.ToString('D9')] = $Page[$index] }
    return , [object[]] @($sorted.Values)
}

function Format-DocsReferenceDiff {
    <#
    .SYNOPSIS
        Returns unified-diff hunk text for the edit records of one page, or '' without edits.
    .DESCRIPTION
        Edit holds @{ BeforeStart; BeforeCount; AfterStart; AfterCount } records in page
        coordinates (zero-based line indexes), in increasing order. The text starts with
        '--- a/<path>' ('--- /dev/null' for a new page) and '+++ b/<path>', followed by
        '@@ -a,b +c,d @@' hunks with up to three context lines; edits closer than seven lines share
        one hunk. A count of 0 gives the index of the line the empty range follows. Every line is
        LF-terminated.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [string] $PagePath,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [AllowEmptyString()] [string[]] $BeforeLine,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [AllowEmptyString()] [string[]] $AfterLine,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Edit,
        [switch] $IsNewPage
    )

    if ($Edit.Count -eq 0) { return '' }
    $context = 3
    $builder = [System.Text.StringBuilder]::new()
    $source = if ($IsNewPage) { '/dev/null' } else { "a/$PagePath" }
    [void]$builder.Append("--- $source`n+++ b/$PagePath`n")
    $first = 0
    while ($first -lt $Edit.Count) {
        $last = $first
        while ($last + 1 -lt $Edit.Count -and $Edit[$last + 1].BeforeStart - ($Edit[$last].BeforeStart + $Edit[$last].BeforeCount) -le 2 * $context) { $last++ }
        $start = [math]::Max(0, $Edit[$first].BeforeStart - $context)
        $lastEnd = $Edit[$last].BeforeStart + $Edit[$last].BeforeCount
        $end = [math]::Min($BeforeLine.Count, $lastEnd + $context)
        $afterStart = $Edit[$first].AfterStart - ($Edit[$first].BeforeStart - $start)
        $afterEnd = $Edit[$last].AfterStart + $Edit[$last].AfterCount + ($end - $lastEnd)
        $beforeCount = $end - $start
        $afterCount = $afterEnd - $afterStart
        $a = if ($beforeCount -eq 0) { $start } else { $start + 1 }
        $c = if ($afterCount -eq 0) { $afterStart } else { $afterStart + 1 }
        [void]$builder.Append("@@ -$a,$beforeCount +$c,$afterCount @@`n")
        $pointer = $start
        for ($at = $first; $at -le $last; $at++) {
            $record = $Edit[$at]
            for (; $pointer -lt $record.BeforeStart; $pointer++) { [void]$builder.Append(' ').Append($BeforeLine[$pointer]).Append("`n") }
            for ($k = 0; $k -lt $record.BeforeCount; $k++) { [void]$builder.Append('-').Append($BeforeLine[$record.BeforeStart + $k]).Append("`n") }
            for ($k = 0; $k -lt $record.AfterCount; $k++) { [void]$builder.Append('+').Append($AfterLine[$record.AfterStart + $k]).Append("`n") }
            $pointer = $record.BeforeStart + $record.BeforeCount
        }
        for (; $pointer -lt $end; $pointer++) { [void]$builder.Append(' ').Append($BeforeLine[$pointer]).Append("`n") }
        $first = $last + 1
    }
    return $builder.ToString()
}

function ConvertTo-DocsReferenceResult {
    <#
    .SYNOPSIS
        Returns the ordered result object {mode, output_directory, pages, summary, unrendered}.
    .DESCRIPTION
        Generation is the result of Get-DocsReferenceGeneration, or @{ Page = @(); Unrendered = 0 }
        when a global finding stopped planning. Status: in dry run planned for create and update,
        skipped for none and blocked for blocked; in write mode the WriteStatus entry of the path,
        else blocked for blocked and not-attempted otherwise. diff is the page diff in dry run for
        create and update, else $null.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Generation,
        [Parameter(Mandatory = $true)] [ValidateSet('dry-run', 'write', IgnoreCase = $false)] [string] $Mode,
        [AllowNull()] [System.Collections.IDictionary] $WriteStatus,
        [AllowNull()] [string] $OutputDirectory
    )

    $pages = [System.Collections.Generic.List[object]]::new()
    $count = @{ added = 0; removed = 0; unchanged = 0; updated = 0; blocked = 0; changed = 0; none = 0 }
    foreach ($page in (Get-DocsReferenceOrderedPage -Page @($Generation['Page']) -Key 'Path')) {
        $action = [string] $page['Action']
        $path = [string] $page['Path']
        $status = if ($Mode -ceq 'dry-run') {
            switch -CaseSensitive ($action) { 'none' { 'skipped' } 'blocked' { 'blocked' } default { 'planned' } }
        } elseif ($null -ne $WriteStatus -and $WriteStatus.Contains($path)) { [string] $WriteStatus[$path] } elseif ($action -ceq 'blocked') { 'blocked' } else { 'not-attempted' }
        $blocks = [ordered]@{}
        foreach ($pair in @(@('added', 'Added'), @('removed', 'Removed'), @('unchanged', 'Unchanged'), @('updated', 'Updated'))) {
            $name = $pair[0]
            [string[]] $ids = @($page[$pair[1]] | Where-Object { $null -ne $_ })
            [Array]::Sort($ids, [System.StringComparer]::Ordinal)
            $blocks[$name] = $ids
            $count[$name] += $ids.Count
        }
        switch -CaseSensitive ($action) { 'blocked' { $count.blocked++ } 'none' { $count.none++ } default { $count.changed++ } }
        $diff = if ($Mode -ceq 'dry-run' -and ($action -ceq 'create' -or $action -ceq 'update')) { [string] $page['Diff'] } else { $null }
        $pages.Add([ordered]@{ action = $action; blocks = $blocks; diff = $diff; path = $path; sha256_after = $page['Sha256After']; sha256_before = $page['Sha256Before']; status = $status })
    }
    $summary = [ordered]@{
        blocks_added     = [long] $count.added
        blocks_removed   = [long] $count.removed
        blocks_unchanged = [long] $count.unchanged
        blocks_updated   = [long] $count.updated
        page_count       = [long] $pages.Count
        pages_blocked    = [long] $count.blocked
        pages_changed    = [long] $count.changed
        pages_unchanged  = [long] $count.none
    }
    $unrendered = [ordered]@{ 'architecture-component' = [long] $Generation['Unrendered'] }
    $outputDirectory = if ([string]::IsNullOrEmpty($OutputDirectory)) { $null } else { $OutputDirectory }
    return [ordered]@{ mode = $Mode; output_directory = $outputDirectory; pages = [object[]] $pages.ToArray(); summary = $summary; unrendered = $unrendered }
}

function Get-DocsReferenceReportLine {
    <#
    .SYNOPSIS
        Returns the generate-reference command lines of the text report for a result object.
    .DESCRIPTION
        One '<action> <path> (+<added> ~<updated> -<removed>)' line per page in ordinal path order;
        in dry run the diff lines of each changed page; one note line per created page naming
        DOCS_PAGE_ORPHAN; then 'dry run, nothing written', 'wrote <n> page(s)' or
        'nothing written'.
    #>
    [CmdletBinding()]
    [OutputType([string[]], [object[]])]
    param([Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Result)

    [object[]] $pages = Get-DocsReferenceOrderedPage -Page @($Result['pages']) -Key 'path'
    $lines = [System.Collections.Generic.List[string]]::new()
    foreach ($page in $pages) {
        $blocks = $page['blocks']
        $lines.Add("$($page['action']) $($page['path']) (+$(@($blocks['added']).Count) ~$(@($blocks['updated']).Count) -$(@($blocks['removed']).Count))")
    }
    $dryRun = [string] $Result['mode'] -ceq 'dry-run'
    if ($dryRun) {
        foreach ($page in $pages) {
            $diff = [string] $page['diff']
            if ($diff.Length -gt 0) { $lines.AddRange([string[]] $diff.Substring(0, $diff.Length - 1).Split("`n")) }
        }
    }
    foreach ($page in $pages) {
        if ([string] $page['action'] -ceq 'create') { $lines.Add("note: $($page['path']) is new; link it from a documentation entry page so that the check command does not report DOCS_PAGE_ORPHAN") }
    }
    $written = @($pages | Where-Object { [string] $_['status'] -ceq 'created' -or [string] $_['status'] -ceq 'updated' }).Count
    $lines.Add($(if ($dryRun) { 'dry run, nothing written' } elseif ($written -gt 0) { "wrote $written page(s)" } else { 'nothing written' }))
    return , $lines.ToArray()
}

Export-ModuleMember -Function `
    Format-DocsReferenceDiff, `
    ConvertTo-DocsReferenceResult, `
    Get-DocsReferenceReportLine
