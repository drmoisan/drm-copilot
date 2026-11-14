<#
.SYNOPSIS
    Splitting of a generated reference family page above the page budget into an index page and
    group pages (issue #1173 B5).

.DESCRIPTION
    Get-DocsReferenceSplitPage decides, from the UTF-8 byte size of the rendered family page,
    whether the family stays one page (at or below the budget of 921,600 bytes, the page is
    returned unchanged) or is planned as an index page at the family path plus group pages
    <OutputDirectory>/<family-stem>/<group>.md. The group key is the first path segment of the
    element path beneath the longest matching surface_selection.source_roots entry; an element
    whose path has no directory segment beneath its root, or that lies under no root, is grouped
    under the reserved key _root. A group whose estimated size exceeds the budget is split into
    ordinal parts <group>-<n>.md (n from 1), filled in element order. Groups are ordered
    ordinally and elements keep the family order, so the same plan yields the same pages. The
    index plan carries the family owner, root and audience and a body that links every group or
    part page; its front matter is composed by the writer.

    The size of a page is estimated per element as the UTF-8 bytes of its rendered block plus its
    surface_refs entry, with a fixed allowance for the title and front matter, so that every
    emitted page stays at or below the budget; a single element larger than the budget is placed
    alone in its own part.

    Get-DocsReferenceStaleSplitFinding returns one REFERENCE_SPLIT_GROUP_STALE warning per
    existing split page that no group plans; such a page is never deleted.

    Every function is pure: no filesystem, clock, process, environment or module-scope mutable
    state; inputs are not mutated.

.NOTES
    Issue #1173. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsFinding.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsReferenceRender.psm1') -ErrorAction Stop

$script:DocsReferenceSplitBudget = 921600
$script:DocsReferenceSplitAllowance = 8192
$script:DocsReferenceSplitRootGroup = '_root'

function Get-DocsReferenceSplitGroupKey {
    <#
    .SYNOPSIS
        Returns the group key of an element path for the given source roots (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Path,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $SourceRoot
    )

    $best = $null
    foreach ($root in $SourceRoot) {
        $trimmed = ([string] $root).TrimEnd('/')
        $covers = $trimmed.Length -eq 0 -or $trimmed -ceq '.' -or $Path.StartsWith($trimmed + '/', [System.StringComparison]::Ordinal)
        if ($covers -and ($null -eq $best -or $trimmed.Length -gt $best.Length)) { $best = $trimmed }
    }
    if ($null -eq $best) { return $script:DocsReferenceSplitRootGroup }
    $remainder = if ($best.Length -eq 0 -or $best -ceq '.') { $Path } else { $Path.Substring($best.Length + 1) }
    $slash = $remainder.IndexOf('/')
    if ($slash -le 0) { return $script:DocsReferenceSplitRootGroup }
    return [regex]::Replace($remainder.Substring(0, $slash), '[^A-Za-z0-9._-]', '-')
}

function Get-DocsReferenceSplitElementSize {
    <#
    .SYNOPSIS
        Returns the estimated UTF-8 bytes one element adds to a page: its block and its surface_refs entry (private helper).
    #>
    [CmdletBinding()]
    [OutputType([long])]
    param([Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Element)

    # Get-DocsReferenceBlockLine returns its lines with the unary comma; the assignment unwraps them.
    [string[]] $line = Get-DocsReferenceBlockLine -Element $Element
    $block = ($line -join "`n") + "`n`n"
    return [long] ([System.Text.Encoding]::UTF8.GetByteCount($block) + ([string] $Element['element_id']).Length + 4)
}

function New-DocsReferenceSplitPagePlan {
    <#
    .SYNOPSIS
        Returns one group or part page plan that inherits the family owner, root and audience (private helper).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $PagePlan,
        [Parameter(Mandatory = $true)] [string] $Path,
        [Parameter(Mandatory = $true)] [string] $Name,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Element
    )

    return [ordered]@{
        Path     = $Path
        Title    = [string] $PagePlan['Title'] + ': ' + $Name
        Element  = [object[]] $Element
        Owner    = $PagePlan['Owner']
        RootId   = $PagePlan['RootId']
        Audience = [string[]] @($PagePlan['Audience'])
        Finding  = [object[]] @()
    }
}

function Get-DocsReferenceSplitPage {
    <#
    .SYNOPSIS
        Plans the pages of one rendered family; returns @{ Split; Index; Part }.
    .DESCRIPTION
        When RenderedSize is at or below Budget (default 921,600), Split is $false, Index is $null
        and Part holds PagePlan unchanged. Otherwise Split is $true, Part holds the group or part
        page plans ordinal by Path, and Index is the index plan at the family path with an empty
        Element array and BodyLine, the title line followed by one link per group or part page.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $PagePlan,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $SourceRoot,
        [Parameter(Mandatory = $true)] [long] $RenderedSize,
        [ValidateRange(16384, 1048576)] [long] $Budget = $script:DocsReferenceSplitBudget
    )

    if ($RenderedSize -le $Budget) { return @{ Split = $false; Index = $null; Part = [object[]] @($PagePlan) } }
    $familyPath = [string] $PagePlan['Path']
    $slash = $familyPath.LastIndexOf('/')
    $directory = $familyPath.Substring(0, $slash)
    $stem = [System.IO.Path]::GetFileNameWithoutExtension($familyPath.Substring($slash + 1))
    $groups = [System.Collections.Generic.SortedDictionary[string, System.Collections.Generic.List[object]]]::new([System.StringComparer]::Ordinal)
    foreach ($element in @($PagePlan['Element'])) {
        $key = Get-DocsReferenceSplitGroupKey -Path ([string] $element['path']) -SourceRoot $SourceRoot
        if (-not $groups.ContainsKey($key)) { $groups[$key] = [System.Collections.Generic.List[object]]::new() }
        $groups[$key].Add($element)
    }
    $capacity = $Budget - $script:DocsReferenceSplitAllowance
    $parts = [System.Collections.Generic.List[object]]::new()
    foreach ($key in $groups.Keys) {
        $sizes = @($groups[$key] | ForEach-Object { Get-DocsReferenceSplitElementSize -Element $_ })
        $total = [long] 0
        foreach ($size in $sizes) { $total += $size }
        if ($total -le $capacity) {
            $parts.Add((New-DocsReferenceSplitPagePlan -PagePlan $PagePlan -Path "$directory/$stem/$key.md" -Name $key -Element $groups[$key].ToArray()))
            continue
        }
        $current = [System.Collections.Generic.List[object]]::new()
        $used = [long] 0
        $number = 1
        for ($index = 0; $index -lt $groups[$key].Count; $index++) {
            if ($current.Count -gt 0 -and $used + $sizes[$index] -gt $capacity) {
                $parts.Add((New-DocsReferenceSplitPagePlan -PagePlan $PagePlan -Path "$directory/$stem/$key-$number.md" -Name "$key-$number" -Element $current.ToArray()))
                $current = [System.Collections.Generic.List[object]]::new()
                $used = 0
                $number++
            }
            $current.Add($groups[$key][$index])
            $used += $sizes[$index]
        }
        $parts.Add((New-DocsReferenceSplitPagePlan -PagePlan $PagePlan -Path "$directory/$stem/$key-$number.md" -Name "$key-$number" -Element $current.ToArray()))
    }
    $ordered = [System.Collections.Generic.SortedDictionary[string, object]]::new([System.StringComparer]::Ordinal)
    foreach ($part in $parts) { $ordered[[string] $part['Path']] = $part }
    $body = [System.Collections.Generic.List[string]]::new()
    $body.Add('# ' + [string] $PagePlan['Title'])
    $body.Add('')
    $body.Add('This reference is split into the following pages.')
    $body.Add('')
    foreach ($part in $ordered.Values) {
        $name = [System.IO.Path]::GetFileNameWithoutExtension([string] $part['Path'])
        $body.Add("- [$name]($stem/$name.md)")
    }
    $index = [ordered]@{
        Path     = $familyPath
        Title    = [string] $PagePlan['Title']
        Element  = [object[]] @()
        Owner    = $PagePlan['Owner']
        RootId   = $PagePlan['RootId']
        Audience = [string[]] @($PagePlan['Audience'])
        Finding  = [object[]] @($PagePlan['Finding'])
        BodyLine = [string[]] $body.ToArray()
    }
    return @{ Split = $true; Index = $index; Part = [object[]] @($ordered.Values) }
}

function Get-DocsReferenceStaleSplitFinding {
    <#
    .SYNOPSIS
        Returns one REFERENCE_SPLIT_GROUP_STALE warning per existing split page that no group plans.
    .DESCRIPTION
        SplitPath lists the existing pages under the family split directories; PlannedPath lists
        every planned page path. The findings are ordinal by path; no page is deleted.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $SplitPath,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $PlannedPath
    )

    $planned = [System.Collections.Generic.HashSet[string]]::new([string[]] $PlannedPath, [System.StringComparer]::Ordinal)
    $stale = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($path in $SplitPath) { if (-not $planned.Contains($path)) { [void] $stale.Add($path) } }
    $findings = [System.Collections.Generic.List[object]]::new()
    foreach ($path in $stale) {
        $findings.Add((New-DocsFinding -Code 'REFERENCE_SPLIT_GROUP_STALE' -Severity 'warning' -Message "the split page $path has no planned group; it was not deleted." -NextAction 'Delete the page when its group no longer exists, or regenerate the inventory snapshot.' -ArtifactPath $path))
    }
    return , [object[]] $findings.ToArray()
}

Export-ModuleMember -Function Get-DocsReferenceSplitPage, Get-DocsReferenceStaleSplitFinding
