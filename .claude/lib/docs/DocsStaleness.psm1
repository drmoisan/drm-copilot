<#
.SYNOPSIS
    Staleness detection for the documentation library: pin status, stale pages and the
    DOCS_STALE_PAGE findings.

.DESCRIPTION
    Get-DocsPinStatus compares a pin with the current elements: element-missing when no current
    element has the pin's element_id, digest-changed when the declaration-lines digests differ
    (ordinal comparison of opaque values), otherwise current; a revision difference never changes
    the status. Get-DocsStalePage lists every page with at least one non-current pin, and
    Get-DocsStalenessFinding emits one DOCS_STALE_PAGE finding per stale page at the severity the
    caller selects (warning in matrix mode; error above max_stale_pages in docs-complete).
    Identifier and path comparisons are ordinal and case-sensitive; every sort is ordinal.

    Every function is pure: no filesystem, clock, process, environment or module-scope mutable
    state.

.NOTES
    Issue #1023. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsFinding.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsEvidencePins.psm1') -ErrorAction Stop

$script:DocsStalenessOrderedFindingLimit = 10000

function Get-DocsStalenessMember {
    <#
    .SYNOPSIS
        Returns a table member, or $null when the key is absent (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [AllowNull()] [object] $Table,
        [Parameter(Mandatory = $true)] [string] $Name
    )

    if ($Table -is [System.Collections.IDictionary] -and $Table.Contains($Name)) { return $Table[$Name] }
    return $null
}

function Get-DocsPinStatus {
    <#
    .SYNOPSIS
        Returns element-missing, digest-changed or current for a pin against the current element map.
    .DESCRIPTION
        Element maps element_id to the current element (the Element member of a snapshot view).
        The digests are compared as opaque strings; the pin revision is not read.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Pin,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Element
    )

    $id = [string] (Get-DocsStalenessMember -Table $Pin -Name 'element_id')
    if (-not $Element.Contains($id)) { return 'element-missing' }
    $current = [string] (Get-DocsStalenessMember -Table $Element[$id] -Name 'source_sha256')
    $pinned = [string] (Get-DocsStalenessMember -Table $Pin -Name 'source_sha256')
    if ($current -cne $pinned) { return 'digest-changed' }
    return 'current'
}

function Get-DocsStalePage {
    <#
    .SYNOPSIS
        Returns one record per page with at least one non-current pin, sorted by page_path then pin_id.
    .DESCRIPTION
        Each record is {page_path, pins: [{pin_id, element_id, status}]} listing the non-current
        pins of that page in pin_id order.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $PinSet,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Element
    )

    $byPage = [System.Collections.Generic.SortedDictionary[string, System.Collections.Generic.SortedDictionary[string, object]]]::new([System.StringComparer]::Ordinal)
    foreach ($pin in @(Get-DocsStalenessMember -Table $PinSet -Name 'pins')) {
        if ($pin -isnot [System.Collections.IDictionary]) { continue }
        $status = Get-DocsPinStatus -Pin $pin -Element $Element
        if ($status -ceq 'current') { continue }
        $page = [string] (Get-DocsStalenessMember -Table $pin -Name 'page_path')
        $pinId = [string] (Get-DocsStalenessMember -Table $pin -Name 'pin_id')
        if (-not $byPage.ContainsKey($page)) { $byPage[$page] = [System.Collections.Generic.SortedDictionary[string, object]]::new([System.StringComparer]::Ordinal) }
        $byPage[$page][$pinId] = [ordered]@{ pin_id = $pinId; element_id = [string] (Get-DocsStalenessMember -Table $pin -Name 'element_id'); status = $status }
    }
    $records = [System.Collections.Generic.List[object]]::new()
    foreach ($page in $byPage.Keys) {
        $records.Add([ordered]@{ page_path = $page; pins = [object[]]@($byPage[$page].Values) })
    }
    return , $records.ToArray()
}

function Get-DocsStalenessFinding {
    <#
    .SYNOPSIS
        Returns one ordered DOCS_STALE_PAGE finding per stale page at the requested severity.
    .DESCRIPTION
        StalePage is the output of Get-DocsStalePage. The message names the page path and, per
        non-current pin, the declaration (the pin symbol when PinSet is given, else the current
        element declaration, else the pin id), the element id and the status. related_paths is the
        page; related_ids are the element and pin ids.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $StalePage,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Element,
        [Parameter(Mandatory = $true)] [ValidateSet('warning', 'error')] [string] $Severity,
        [AllowNull()] [System.Collections.IDictionary] $PinSet,
        [AllowNull()] [string] $ArtifactPath
    )

    $symbols = [System.Collections.Generic.Dictionary[string, string]]::new([System.StringComparer]::Ordinal)
    foreach ($pin in @(Get-DocsStalenessMember -Table $PinSet -Name 'pins')) {
        if ($pin -is [System.Collections.IDictionary]) { $symbols[[string] (Get-DocsStalenessMember -Table $pin -Name 'pin_id')] = [string] (Get-DocsStalenessMember -Table $pin -Name 'symbol') }
    }
    $findings = [System.Collections.Generic.List[object]]::new()
    foreach ($record in @($StalePage)) {
        if ($record -isnot [System.Collections.IDictionary]) { continue }
        $page = [string] (Get-DocsStalenessMember -Table $record -Name 'page_path')
        $parts = [System.Collections.Generic.List[string]]::new()
        $related = [System.Collections.Generic.List[string]]::new()
        foreach ($pin in @(Get-DocsStalenessMember -Table $record -Name 'pins')) {
            $pinId = [string] (Get-DocsStalenessMember -Table $pin -Name 'pin_id')
            $elementId = [string] (Get-DocsStalenessMember -Table $pin -Name 'element_id')
            $declaration = if ($symbols.ContainsKey($pinId)) { $symbols[$pinId] } elseif ($Element.Contains($elementId)) { [string] (Get-DocsStalenessMember -Table $Element[$elementId] -Name 'declaration') } else { $pinId }
            $parts.Add("'$declaration' ($elementId) is $((Get-DocsStalenessMember -Table $pin -Name 'status'))")
            $related.Add($elementId)
            $related.Add($pinId)
        }
        $findings.Add((New-DocsFinding -Code 'DOCS_STALE_PAGE' -Severity $Severity -Pointer '' -ArtifactPath $ArtifactPath -RelatedId ([string[]]@($related | Where-Object { $_ -cmatch '^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$(?![\s\S])' })) -RelatedPath @($page) -Message "The page $page is stale: $($parts -join '; ')." -NextAction 'Review the page against the current declaration and re-pin it with update-ledger -Operation pin.'))
    }
    $items = $findings.ToArray()
    return Get-DocsOrderedFinding -Finding $items -Limit ([math]::Min($script:DocsStalenessOrderedFindingLimit, [math]::Max(1, $items.Count)))
}

Export-ModuleMember -Function `
    Get-DocsPinStatus, `
    Get-DocsStalePage, `
    Get-DocsStalenessFinding
