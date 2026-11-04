<#
.SYNOPSIS
    Evidence pins for the documentation library: pin identity, construction, the pin collection
    document, pin consistency findings and the pin operations.

.DESCRIPTION
    A pin binds a page claim to a surface element and its declaration-lines digest. Get-DocsPinId
    derives the pin identifier with Get-DocsStableId over {element_id, page_path, symbol};
    New-DocsEvidencePin copies the element identity and its source_sha256 as an opaque value;
    Get-DocsPinFinding reports DOCS_PIN_INCONSISTENT when the identity fields do not reproduce
    element_id, when pin_id differs from its derivation, or when a pin_id repeats.
    Merge-DocsEvidencePin and Get-DocsPinSetWithoutPin return new collections sorted by pin_id and
    never mutate their inputs. Identifier and path comparisons are ordinal and case-sensitive.

    Every function is pure: no filesystem, clock, process, environment or module-scope mutable
    state.

.NOTES
    Issue #1023. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsJson.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsFinding.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSurface.psm1') -ErrorAction Stop

$script:DocsPinOrderedFindingLimit = 10000

function Copy-DocsPinValue {
    <#
    .SYNOPSIS
        Returns a deep copy of a parsed artifact value: ordered tables, object arrays, scalars (private helper).
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary], [object[]])]
    param([AllowNull()] [object] $Value)

    if ($null -eq $Value) { return $null }
    if ($Value -is [System.Collections.IDictionary]) {
        $copy = [ordered]@{}
        foreach ($key in @($Value.Keys)) { $copy[[string] $key] = Copy-DocsPinValue -Value $Value[$key] }
        return $copy
    }
    if ($Value -is [string]) { return $Value }
    if ($Value -is [System.Collections.IEnumerable]) {
        $list = [System.Collections.Generic.List[object]]::new()
        foreach ($item in $Value) { $list.Add((Copy-DocsPinValue -Value $item)) }
        return , $list.ToArray()
    }
    return $Value
}

function Get-DocsPinMember {
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

function ConvertTo-DocsPinText {
    <#
    .SYNOPSIS
        Returns $null for a null or empty value, otherwise the string (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([AllowNull()] [AllowEmptyString()] [string] $Value)

    if ([string]::IsNullOrEmpty($Value)) { return $null }
    return $Value
}

function Get-DocsSortedPin {
    <#
    .SYNOPSIS
        Returns copies of the pins sorted by pin_id (ordinal; private helper).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([AllowNull()] [AllowEmptyCollection()] [object[]] $Pin)

    $keyed = [System.Collections.Generic.SortedDictionary[string, System.Collections.Generic.List[object]]]::new([System.StringComparer]::Ordinal)
    foreach ($item in @($Pin)) {
        if ($null -eq $item) { continue }
        $key = [string] (Get-DocsPinMember -Table $item -Name 'pin_id')
        if (-not $keyed.ContainsKey($key)) { $keyed[$key] = [System.Collections.Generic.List[object]]::new() }
        $keyed[$key].Add((Copy-DocsPinValue -Value $item))
    }
    $sorted = [System.Collections.Generic.List[object]]::new()
    foreach ($group in $keyed.Values) { foreach ($item in $group) { $sorted.Add($item) } }
    return , $sorted.ToArray()
}

function Get-DocsPinId {
    <#
    .SYNOPSIS
        Returns the pin identifier: Get-DocsStableId with prefix pin over {element_id, page_path, symbol}.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $ElementId,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $PagePath,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Symbol
    )

    return Get-DocsStableId -Prefix 'pin' -Value ([ordered]@{ element_id = $ElementId; page_path = $PagePath; symbol = $Symbol })
}

function New-DocsEvidencePin {
    <#
    .SYNOPSIS
        Returns one evidence pin binding PagePath to Element; source_sha256 is copied as an opaque value.
    .DESCRIPTION
        The symbol is the element declaration and the source path is the element path. Revision
        may be null (an unpinned snapshot); PinnedAt is the timestamp text of the clock.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Element,
        [Parameter(Mandatory = $true)] [string] $PagePath,
        [AllowNull()] [string] $Claim,
        [AllowNull()] [string] $Revision,
        [Parameter(Mandatory = $true)] [string] $PinnedAt,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Actor
    )

    foreach ($field in 'element_id', 'kind', 'path', 'declaration', 'source_sha256') {
        if (-not $Element.Contains($field) -or [string]::IsNullOrEmpty([string] $Element[$field])) { throw "DOCS_PIN_INPUT_INVALID: Element must carry $field." }
    }
    foreach ($field in 'kind', 'id') {
        if (-not $Actor.Contains($field) -or [string]::IsNullOrWhiteSpace([string] $Actor[$field])) { throw "DOCS_PIN_INPUT_INVALID: Actor must carry a non-blank $field." }
    }
    $elementId = [string] $Element['element_id']
    $symbol = [string] $Element['declaration']
    return [ordered]@{
        pin_id        = (Get-DocsPinId -ElementId $elementId -PagePath $PagePath -Symbol $symbol)
        element_id    = $elementId
        element_kind  = [string] $Element['kind']
        page_path     = $PagePath
        symbol        = $symbol
        source_path   = [string] $Element['path']
        source_sha256 = [string] $Element['source_sha256']
        revision      = (ConvertTo-DocsPinText -Value $Revision)
        claim         = (ConvertTo-DocsPinText -Value $Claim)
        pinned_at     = $PinnedAt
        pinned_by     = [ordered]@{ kind = [string] $Actor['kind']; id = [string] $Actor['id'] }
    }
}

function New-DocsPinCollectionDocument {
    <#
    .SYNOPSIS
        Returns an empty pin collection with the artifact header; its id depends only on the repository id.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([Parameter(Mandatory = $true)] [string] $RepositoryId)

    return [ordered]@{
        '$schema'      = 'urn:drm-copilot:docs:1.0.0:docs-evidence-pin'
        schema_version = '1.0.0'
        artifact_kind  = 'docs-evidence-pin'
        id             = (Get-DocsStableId -Prefix 'docs-evidence-pin' -Value ([ordered]@{ repository = $RepositoryId }))
        extensions     = [ordered]@{}
        repository     = $RepositoryId
        pins           = [object[]]@()
    }
}

function Get-DocsPinFinding {
    <#
    .SYNOPSIS
        Returns the ordered DOCS_PIN_INCONSISTENT findings of a pin collection.
    .DESCRIPTION
        A pin is inconsistent when Get-DocsElementId over element_kind, source_path and symbol
        differs from element_id (or cannot be derived), when pin_id differs from Get-DocsPinId
        over element_id, page_path and symbol, or when its pin_id repeats an earlier pin.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $PinSet,
        [AllowNull()] [string] $ArtifactPath
    )

    $findings = [System.Collections.Generic.List[object]]::new()
    $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $pins = @(Get-DocsPinMember -Table $PinSet -Name 'pins')
    $next = 'Re-pin the element with update-ledger -Operation pin, or remove the pin with -Operation unpin.'
    for ($index = 0; $index -lt $pins.Count; $index++) {
        $pin = $pins[$index]
        if ($pin -isnot [System.Collections.IDictionary]) { continue }
        $pointer = "/pins/$index"
        $pinId = [string] (Get-DocsPinMember -Table $pin -Name 'pin_id')
        $elementId = [string] (Get-DocsPinMember -Table $pin -Name 'element_id')
        $pagePath = [string] (Get-DocsPinMember -Table $pin -Name 'page_path')
        $symbol = [string] (Get-DocsPinMember -Table $pin -Name 'symbol')
        $related = [string[]]@($elementId, $pinId)
        $expectedElement = $null
        try {
            $expectedElement = Get-DocsElementId -Kind ([string] (Get-DocsPinMember -Table $pin -Name 'element_kind')) -Path ([string] (Get-DocsPinMember -Table $pin -Name 'source_path')) -Declaration $symbol
        } catch {
            $expectedElement = $null
        }
        if ($null -eq $expectedElement -or $expectedElement -cne $elementId) {
            $findings.Add((New-DocsFinding -Code 'DOCS_PIN_INCONSISTENT' -Severity 'error' -Pointer "$pointer/element_id" -ArtifactPath $ArtifactPath -RelatedId $related -RelatedPath @($pagePath | Where-Object { Test-DocsRelativePath -Path $_ }) -Message "The pin $pinId records element_kind, source_path and symbol that do not reproduce the element id $elementId." -NextAction $next))
        }
        $expectedPin = Get-DocsPinId -ElementId $elementId -PagePath $pagePath -Symbol $symbol
        if ($expectedPin -cne $pinId) {
            $findings.Add((New-DocsFinding -Code 'DOCS_PIN_INCONSISTENT' -Severity 'error' -Pointer "$pointer/pin_id" -ArtifactPath $ArtifactPath -RelatedId @($related | Where-Object { $_ -cmatch '^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$(?![\s\S])' }) -RelatedPath @($pagePath | Where-Object { Test-DocsRelativePath -Path $_ }) -Message "The pin_id $pinId differs from the identifier derived from element_id, page_path and symbol." -NextAction $next))
        }
        if (-not $seen.Add($pinId)) {
            $findings.Add((New-DocsFinding -Code 'DOCS_PIN_INCONSISTENT' -Severity 'error' -Pointer "$pointer/pin_id" -ArtifactPath $ArtifactPath -RelatedId @($related | Where-Object { $_ -cmatch '^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$(?![\s\S])' }) -Message "The pin_id $pinId appears more than once in the collection." -NextAction $next))
        }
    }
    $items = $findings.ToArray()
    return Get-DocsOrderedFinding -Finding $items -Limit ([math]::Min($script:DocsPinOrderedFindingLimit, [math]::Max(1, $items.Count)))
}

function Merge-DocsEvidencePin {
    <#
    .SYNOPSIS
        Returns a new pin collection in which Pin replaces or joins the pin with its pin_id; pins sorted by pin_id.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $PinSet,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Pin
    )

    $result = Copy-DocsPinValue -Value $PinSet
    $id = [string] (Get-DocsPinMember -Table $Pin -Name 'pin_id')
    $kept = @(@(Get-DocsPinMember -Table $PinSet -Name 'pins') | Where-Object { [string] (Get-DocsPinMember -Table $_ -Name 'pin_id') -cne $id })
    $result['pins'] = Get-DocsSortedPin -Pin ($kept + @($Pin))
    return $result
}

function Get-DocsPinSetWithoutPin {
    <#
    .SYNOPSIS
        Returns a new pin collection without the pins of ElementId, or of ElementId on PagePath when given.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $PinSet,
        [Parameter(Mandatory = $true)] [string] $ElementId,
        [AllowNull()] [string] $PagePath
    )

    $result = Copy-DocsPinValue -Value $PinSet
    $kept = @(@(Get-DocsPinMember -Table $PinSet -Name 'pins') | Where-Object {
            $sameElement = [string] (Get-DocsPinMember -Table $_ -Name 'element_id') -ceq $ElementId
            $samePage = [string]::IsNullOrEmpty($PagePath) -or ([string] (Get-DocsPinMember -Table $_ -Name 'page_path') -ceq $PagePath)
            -not ($sameElement -and $samePage)
        })
    $result['pins'] = Get-DocsSortedPin -Pin $kept
    return $result
}

Export-ModuleMember -Function `
    Get-DocsPinId, `
    New-DocsEvidencePin, `
    New-DocsPinCollectionDocument, `
    Get-DocsPinFinding, `
    Merge-DocsEvidencePin, `
    Get-DocsPinSetWithoutPin
