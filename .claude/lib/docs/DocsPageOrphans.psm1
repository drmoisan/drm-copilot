<#
.SYNOPSIS
    Orphan detection of the documentation page checker: entry pages, reachability and
    DOCS_PAGE_ORPHAN findings.

.DESCRIPTION
    The entry page of a documentation root is <root>/README.md, else <root>/index.md.
    Get-DocsPageReachable walks page edges breadth-first from every entry page, visiting
    neighbors in ordinal order; cycles terminate because each page is visited once. Every page
    of the page set that is not reached yields DOCS_PAGE_ORPHAN. Entry pages are never orphans,
    and links from files outside the page set do not count because only page edges are walked.

    Every function is pure: no filesystem, clock, process, environment or module-scope mutable
    state.

.NOTES
    Issue #1021. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsFinding.psm1') -ErrorAction Stop

function Get-DocsPageEntryPage {
    <#
    .SYNOPSIS
        Returns <root>/README.md, else <root>/index.md, when that path is in the page set; otherwise $null.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [string] $RootPath,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $PageSet
    )

    $root = $RootPath.TrimEnd('/')
    foreach ($name in @('README.md', 'index.md')) {
        $candidate = "$root/$name"
        if ($PageSet -ccontains $candidate) { return $candidate }
    }
    return $null
}

function Get-DocsPageReachable {
    <#
    .SYNOPSIS
        Returns the sorted set of pages reachable from the entry pages over the page edges.
    .DESCRIPTION
        Edge maps a page path to the page paths it links to. The walk is breadth-first with
        neighbors in ordinal order; each page is visited once.
    #>
    [CmdletBinding()]
    [OutputType([string[]], [object[]])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $EntryPage,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Edge
    )

    $visited = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::Ordinal)
    $queue = [System.Collections.Generic.Queue[string]]::new()
    [string[]] $start = @($EntryPage | Where-Object { -not [string]::IsNullOrEmpty($_) })
    [Array]::Sort($start, [System.StringComparer]::Ordinal)
    foreach ($page in $start) { if ($visited.Add($page)) { $queue.Enqueue($page) } }
    while ($queue.Count -gt 0) {
        $page = $queue.Dequeue()
        if (-not $Edge.Contains($page)) { continue }
        [string[]] $neighbors = @($Edge[$page] | Where-Object { -not [string]::IsNullOrEmpty($_) })
        [Array]::Sort($neighbors, [System.StringComparer]::Ordinal)
        foreach ($neighbor in $neighbors) { if ($visited.Add($neighbor)) { $queue.Enqueue($neighbor) } }
    }
    return , [string[]] @($visited)
}

function Get-DocsPageOrphanFinding {
    <#
    .SYNOPSIS
        Returns one DOCS_PAGE_ORPHAN finding per page of the page set that is not reachable, in page order.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $PageSet,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $Reachable
    )

    $reached = [System.Collections.Generic.HashSet[string]]::new([string[]] $Reachable, [System.StringComparer]::Ordinal)
    $findings = [System.Collections.Generic.List[object]]::new()
    foreach ($page in $PageSet) {
        if ($reached.Contains($page)) { continue }
        $findings.Add((New-DocsFinding -Code 'DOCS_PAGE_ORPHAN' -Severity 'error' -Message 'page is not reachable from any documentation-root entry page' -NextAction 'Link the page from its documentation-root entry page or from a page that the entry page reaches.' -ArtifactPath $page -Pointer ''))
    }
    if ($findings.Count -eq 0) { return , [object[]] @() }
    return , [object[]] (Get-DocsOrderedFinding -Finding $findings.ToArray() -Limit 10000)
}

Export-ModuleMember -Function `
    Get-DocsPageEntryPage, `
    Get-DocsPageReachable, `
    Get-DocsPageOrphanFinding
