<#
.SYNOPSIS
    Parity matrix for the documentation library: dimensions, path matching and page owners, rows
    and documents, the matrix rules, the dimension operations and the parity score.

.DESCRIPTION
    Test-DocsPathOrGlobMatch implements the shared path_or_glob rule: a value covers a path when
    the path equals it, starts with it followed by a slash, or matches it as a case-sensitive glob
    (* any run including /, ? one character, [...] a class, [!...] a negated class, no escape
    character) translated to an anchored .NET regular expression without IgnoreCase.
    Get-DocsPageOwner evaluates page_owners in array order and returns the first match.
    New-DocsParityRow and New-DocsParityMatrixDocument build the matrix shapes; Get-DocsMatrixFinding
    implements the matrix rules; Merge-DocsParityDimension, Get-DocsMatrixWithoutBinding,
    Merge-DocsMatrixPinRemoval and Merge-DocsMatrixRef return new matrices and never mutate their
    inputs; Get-DocsScoreBasisPoint and Measure-DocsParityScore use integer arithmetic only.
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

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsJson.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsFinding.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSurface.psm1') -ErrorAction Stop

$script:DocsParityDimensionList = [string[]]@('exists', 'accurate', 'example_present', 'owner_assigned', 'diataxis_mode')
$script:DocsParityStateList = [string[]]@('pass', 'fail', 'not-assessed', 'not-applicable')
$script:DocsParityOrderedFindingLimit = 10000

function Copy-DocsParityValue {
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
        foreach ($key in @($Value.Keys)) { $copy[[string] $key] = Copy-DocsParityValue -Value $Value[$key] }
        return $copy
    }
    if ($Value -is [string]) { return $Value }
    if ($Value -is [System.Collections.IEnumerable]) {
        $list = [System.Collections.Generic.List[object]]::new()
        foreach ($item in $Value) { $list.Add((Copy-DocsParityValue -Value $item)) }
        return , $list.ToArray()
    }
    return $Value
}

function Get-DocsParityMember {
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

function Get-DocsSortedParityRow {
    <#
    .SYNOPSIS
        Returns copies of the rows sorted by element_id then page_path (ordinal; private helper).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([AllowNull()] [AllowEmptyCollection()] [object[]] $Row)

    $keyed = [System.Collections.Generic.SortedDictionary[string, System.Collections.Generic.List[object]]]::new([System.StringComparer]::Ordinal)
    foreach ($item in @($Row)) {
        if ($null -eq $item) { continue }
        $key = [string] (Get-DocsParityMember -Table $item -Name 'element_id') + [string][char]0 + [string] (Get-DocsParityMember -Table $item -Name 'page_path')
        if (-not $keyed.ContainsKey($key)) { $keyed[$key] = [System.Collections.Generic.List[object]]::new() }
        $keyed[$key].Add((Copy-DocsParityValue -Value $item))
    }
    $sorted = [System.Collections.Generic.List[object]]::new()
    foreach ($group in $keyed.Values) { foreach ($item in $group) { $sorted.Add($item) } }
    return , $sorted.ToArray()
}

function Get-DocsSortedUniqueId {
    <#
    .SYNOPSIS
        Returns the distinct values sorted ordinally (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string[]], [object[]])]
    param([AllowNull()] [AllowEmptyCollection()] [string[]] $Value)

    $set = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($item in @($Value)) { if ($null -ne $item) { [void]$set.Add([string] $item) } }
    return , [string[]]@($set)
}

function Get-DocsParityDimension {
    <#
    .SYNOPSIS
        Returns the five parity dimensions in contract order.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param()

    return [string[]]@($script:DocsParityDimensionList)
}

function ConvertTo-DocsGlobRegex {
    <#
    .SYNOPSIS
        Translates a glob to an anchored .NET regular expression pattern (private helper).
    .DESCRIPTION
        * matches any run including /, ? one character, [...] a class and [!...] a negated class;
        there is no escape character. Every other character is escaped literally.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Glob)

    $builder = [System.Text.StringBuilder]::new('^')
    $index = 0
    while ($index -lt $Glob.Length) {
        $character = $Glob[$index]
        if ($character -eq '*') { [void]$builder.Append('.*'); $index++; continue }
        if ($character -eq '?') { [void]$builder.Append('.'); $index++; continue }
        if ($character -eq '[') {
            $close = $Glob.IndexOf(']', $index + 1)
            if ($close -gt $index + 1) {
                $body = $Glob.Substring($index + 1, $close - $index - 1)
                $negated = $body.StartsWith('!', [System.StringComparison]::Ordinal)
                if ($negated) { $body = $body.Substring(1) }
                if ($body.Length -gt 0) {
                    $escaped = $body.Replace('\', '\\').Replace(']', '\]').Replace('^', '\^')
                    [void]$builder.Append('[').Append($(if ($negated) { '^' } else { '' })).Append($escaped).Append(']')
                    $index = $close + 1
                    continue
                }
            }
        }
        [void]$builder.Append([regex]::Escape([string] $character))
        $index++
    }
    return $builder.Append('\z').ToString()
}

function Test-DocsPathOrGlobMatch {
    <#
    .SYNOPSIS
        Returns $true when PathOrGlob covers Path: equal, a directory prefix, or a case-sensitive glob match.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Path,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $PathOrGlob
    )

    if ($Path -ceq $PathOrGlob) { return $true }
    if ($Path.StartsWith($PathOrGlob + '/', [System.StringComparison]::Ordinal)) { return $true }
    $pattern = ConvertTo-DocsGlobRegex -Glob $PathOrGlob
    return [regex]::IsMatch($Path, $pattern, [System.Text.RegularExpressions.RegexOptions]::CultureInvariant)
}

function Get-DocsPageOwner {
    <#
    .SYNOPSIS
        Returns the owner of the first page_owners entry whose path_or_glob covers PagePath, or $null.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $PagePath,
        [AllowNull()] [AllowEmptyCollection()] [object[]] $PageOwner
    )

    foreach ($entry in @($PageOwner)) {
        if ($entry -isnot [System.Collections.IDictionary]) { continue }
        $glob = [string] (Get-DocsParityMember -Table $entry -Name 'path_or_glob')
        if (Test-DocsPathOrGlobMatch -Path $PagePath -PathOrGlob $glob) { return [string] (Get-DocsParityMember -Table $entry -Name 'owner') }
    }
    return $null
}

function New-DocsParityDimensionResult {
    <#
    .SYNOPSIS
        Returns one dimension result {state, rationale, evidence_pin_ids} (private helper).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [string] $State = 'not-assessed',
        [AllowNull()] [string] $Rationale,
        [AllowNull()] [AllowEmptyCollection()] [string[]] $PinId
    )

    if ($script:DocsParityStateList -cnotcontains $State) { throw "DOCS_PARITY_INPUT_INVALID: State '$State' is not one of $($script:DocsParityStateList -join ', ')." }
    return [ordered]@{
        state            = $State
        rationale        = $(if ([string]::IsNullOrEmpty($Rationale)) { $null } else { $Rationale })
        evidence_pin_ids = (Get-DocsSortedUniqueId -Value $PinId)
    }
}

function New-DocsParityRow {
    <#
    .SYNOPSIS
        Returns one matrix row with every dimension not-assessed, no rationale and no pin.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [string] $ElementId,
        [Parameter(Mandatory = $true)] [string] $Kind,
        [Parameter(Mandatory = $true)] [string] $PagePath
    )

    $dimensions = [ordered]@{}
    foreach ($name in $script:DocsParityDimensionList) { $dimensions[$name] = New-DocsParityDimensionResult }
    return [ordered]@{
        element_id = $ElementId
        kind       = $Kind
        page_path  = $PagePath
        dimensions = $dimensions
        extensions = [ordered]@{}
    }
}

function New-DocsParityMatrixDocument {
    <#
    .SYNOPSIS
        Returns an empty parity matrix with the artifact header; its id depends only on the repository id.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [string] $RepositoryId,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $SnapshotPin,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $LedgerPin
    )

    return [ordered]@{
        '$schema'      = 'urn:drm-copilot:docs:1.0.0:docs-parity-matrix'
        schema_version = '1.0.0'
        artifact_kind  = 'docs-parity-matrix'
        id             = (Get-DocsStableId -Prefix 'docs-parity-matrix' -Value ([ordered]@{ repository = $RepositoryId }))
        extensions     = [ordered]@{}
        repository     = $RepositoryId
        snapshot_ref   = [ordered]@{ artifact_kind = 'surface-inventory-snapshot'; path = [string] $SnapshotPin['path']; sha256 = [string] $SnapshotPin['sha256'] }
        ledger_ref     = [ordered]@{ artifact_kind = 'docs-coverage-ledger'; path = [string] $LedgerPin['path']; sha256 = [string] $LedgerPin['sha256'] }
        rows           = [object[]]@()
    }
}

function Get-DocsScoreBasisPoint {
    <#
    .SYNOPSIS
        Returns floor(10000 * Pass / (Pass + Fail + NotAssessed)), or $null when the denominator is 0.
    #>
    [CmdletBinding()]
    [OutputType([long])]
    param(
        [Parameter(Mandatory = $true)] [long] $Pass,
        [Parameter(Mandatory = $true)] [long] $Fail,
        [Parameter(Mandatory = $true)] [long] $NotAssessed
    )

    $denominator = $Pass + $Fail + $NotAssessed
    if ($denominator -eq 0) { return $null }
    return [long] [System.Math]::DivRem([long] (10000 * $Pass), [long] $denominator, [ref] ([long] 0))
}

function Measure-DocsParityScore {
    <#
    .SYNOPSIS
        Returns per dimension {pass, fail, not_assessed, not_applicable, score_basis_points} over the matrix rows.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Matrix)

    $result = [ordered]@{}
    foreach ($name in $script:DocsParityDimensionList) {
        $counts = [ordered]@{ pass = [long] 0; fail = [long] 0; not_assessed = [long] 0; not_applicable = [long] 0 }
        foreach ($row in @(Get-DocsParityMember -Table $Matrix -Name 'rows')) {
            $state = [string] (Get-DocsParityMember -Table (Get-DocsParityMember -Table (Get-DocsParityMember -Table $row -Name 'dimensions') -Name $name) -Name 'state')
            $key = $state.Replace('-', '_')
            if ($counts.Contains($key)) { $counts[$key] = $counts[$key] + 1 }
        }
        $counts['score_basis_points'] = Get-DocsScoreBasisPoint -Pass $counts['pass'] -Fail $counts['fail'] -NotAssessed $counts['not_assessed']
        $result[$name] = $counts
    }
    return $result
}

function New-DocsParityFinding {
    <#
    .SYNOPSIS
        Builds one finding for this module; related ids and paths outside their grammar are dropped (private helper).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [string] $Code,
        [Parameter(Mandatory = $true)] [string] $Severity,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Pointer,
        [Parameter(Mandatory = $true)] [string] $Message,
        [Parameter(Mandatory = $true)] [string] $NextAction,
        [AllowNull()] [string] $ArtifactPath,
        [AllowNull()] [AllowEmptyCollection()] [string[]] $RelatedId,
        [AllowNull()] [AllowEmptyCollection()] [string[]] $RelatedPath
    )

    $ids = [string[]]@($RelatedId | Where-Object { $null -ne $_ -and $_ -cmatch '^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$(?![\s\S])' })
    $paths = [string[]]@($RelatedPath | Where-Object { $null -ne $_ -and (Test-DocsRelativePath -Path $_) })
    return New-DocsFinding -Code $Code -Severity $Severity -Pointer $Pointer -Message $Message -NextAction $NextAction -ArtifactPath $ArtifactPath -RelatedId $ids -RelatedPath $paths
}

function Get-DocsMatrixFinding {
    <#
    .SYNOPSIS
        Returns the ordered matrix findings against the ledger, the pin collection, the page-path set and the page owners.
    .DESCRIPTION
        DOCS_MATRIX_UNBOUND_ROW: a row not bound by a documented entry; DOCS_MATRIX_ROW_MISSING: a
        documented binding without a row; DOCS_MATRIX_DUPLICATE_ROW: a repeated element and page;
        DOCS_MATRIX_PIN_UNKNOWN: an evidence pin id that is unknown or belongs to another element
        or page; DOCS_MATRIX_ACCURACY_UNPINNED: accurate pass without a pin;
        DOCS_MATRIX_EXISTS_INCONSISTENT: exists pass for a page outside the page-path set;
        DOCS_MATRIX_OWNER_INCONSISTENT: owner_assigned pass with no page owner;
        DOCS_MATRIX_LEDGER_REF (warning): ledger_ref.sha256 differs from LedgerSha256.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseLiteralInitializerForHashtable', '', Justification = 'Identifiers are case-sensitive; the @{} literal is case-insensitive, so an ordinal-comparer hashtable is required.')]
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Matrix,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Ledger,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $PinSet,
        [AllowNull()] [AllowEmptyCollection()] [string[]] $PagePath,
        [AllowNull()] [AllowEmptyCollection()] [object[]] $PageOwner,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $LedgerSha256,
        [AllowNull()] [string] $ArtifactPath
    )

    $findings = [System.Collections.Generic.List[object]]::new()
    $separator = [string][char]0
    $bindings = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($entry in @(Get-DocsParityMember -Table $Ledger -Name 'entries')) {
        if ([string] (Get-DocsParityMember -Table $entry -Name 'disposition') -cne 'documented') { continue }
        foreach ($binding in @(Get-DocsParityMember -Table $entry -Name 'page_bindings')) {
            [void]$bindings.Add([string] (Get-DocsParityMember -Table $entry -Name 'element_id') + $separator + [string] (Get-DocsParityMember -Table $binding -Name 'page_path'))
        }
    }
    $pins = [hashtable]::new([System.StringComparer]::Ordinal)
    foreach ($pin in @(Get-DocsParityMember -Table $PinSet -Name 'pins')) {
        if ($pin -is [System.Collections.IDictionary]) { $pins[[string] (Get-DocsParityMember -Table $pin -Name 'pin_id')] = $pin }
    }
    $pages = [System.Collections.Generic.HashSet[string]]::new([string[]]@($PagePath | Where-Object { $null -ne $_ }), [System.StringComparer]::Ordinal)
    $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $rows = @(Get-DocsParityMember -Table $Matrix -Name 'rows')
    for ($index = 0; $index -lt $rows.Count; $index++) {
        $row = $rows[$index]
        if ($row -isnot [System.Collections.IDictionary]) { continue }
        $pointer = "/rows/$index"
        $elementId = [string] (Get-DocsParityMember -Table $row -Name 'element_id')
        $page = [string] (Get-DocsParityMember -Table $row -Name 'page_path')
        $key = $elementId + $separator + $page
        $related = @($elementId)
        if (-not $seen.Add($key)) {
            $findings.Add((New-DocsParityFinding -Code 'DOCS_MATRIX_DUPLICATE_ROW' -Severity 'error' -Pointer $pointer -ArtifactPath $ArtifactPath -RelatedId $related -RelatedPath @($page) -Message "The matrix holds more than one row for $elementId on $page." -NextAction 'Keep exactly one row per element and page.'))
        }
        if (-not $bindings.Contains($key)) {
            $findings.Add((New-DocsParityFinding -Code 'DOCS_MATRIX_UNBOUND_ROW' -Severity 'error' -Pointer $pointer -ArtifactPath $ArtifactPath -RelatedId $related -RelatedPath @($page) -Message "The row for $elementId on $page is not bound by a documented ledger entry." -NextAction 'Bind the element to the page with update-ledger -Operation set-disposition, or remove the row.'))
        }
        $dimensions = Get-DocsParityMember -Table $row -Name 'dimensions'
        foreach ($name in $script:DocsParityDimensionList) {
            $dimension = Get-DocsParityMember -Table $dimensions -Name $name
            $state = [string] (Get-DocsParityMember -Table $dimension -Name 'state')
            $pinIds = @(Get-DocsParityMember -Table $dimension -Name 'evidence_pin_ids')
            for ($position = 0; $position -lt $pinIds.Count; $position++) {
                $pinId = [string] $pinIds[$position]
                $known = $pins.ContainsKey($pinId) -and ([string] (Get-DocsParityMember -Table $pins[$pinId] -Name 'element_id') -ceq $elementId) -and ([string] (Get-DocsParityMember -Table $pins[$pinId] -Name 'page_path') -ceq $page)
                if (-not $known) {
                    $findings.Add((New-DocsParityFinding -Code 'DOCS_MATRIX_PIN_UNKNOWN' -Severity 'error' -Pointer "$pointer/dimensions/$name/evidence_pin_ids/$position" -ArtifactPath $ArtifactPath -RelatedId ($related + @($pinId)) -RelatedPath @($page) -Message "The evidence pin $pinId of $name for $elementId on $page is unknown or pins another element or page." -NextAction 'Pin the element to the page with update-ledger -Operation pin, or remove the pin id from the dimension.'))
                }
            }
            if ($name -ceq 'accurate' -and $state -ceq 'pass' -and $pinIds.Count -eq 0) {
                $findings.Add((New-DocsParityFinding -Code 'DOCS_MATRIX_ACCURACY_UNPINNED' -Severity 'error' -Pointer "$pointer/dimensions/accurate" -ArtifactPath $ArtifactPath -RelatedId $related -RelatedPath @($page) -Message "The accurate dimension passes for $elementId on $page without an evidence pin." -NextAction 'Pin the element to the page with update-ledger -Operation pin before recording accurate as pass.'))
            }
            if ($name -ceq 'exists' -and $state -ceq 'pass' -and -not $pages.Contains($page)) {
                $findings.Add((New-DocsParityFinding -Code 'DOCS_MATRIX_EXISTS_INCONSISTENT' -Severity 'error' -Pointer "$pointer/dimensions/exists" -ArtifactPath $ArtifactPath -RelatedId $related -RelatedPath @($page) -Message "The exists dimension passes for $elementId but $page is not in the page-path set." -NextAction 'Create the page under a documentation root, or record exists as fail.'))
            }
            if ($name -ceq 'owner_assigned' -and $state -ceq 'pass' -and $null -eq (Get-DocsPageOwner -PagePath $page -PageOwner $PageOwner)) {
                $findings.Add((New-DocsParityFinding -Code 'DOCS_MATRIX_OWNER_INCONSISTENT' -Severity 'error' -Pointer "$pointer/dimensions/owner_assigned" -ArtifactPath $ArtifactPath -RelatedId $related -RelatedPath @($page) -Message "The owner_assigned dimension passes for $elementId but no page_owners entry covers $page." -NextAction 'Add a page_owners entry that covers the page, or record owner_assigned as fail.'))
            }
        }
    }
    foreach ($binding in $bindings) {
        if ($seen.Contains($binding)) { continue }
        $parts = $binding.Split([char]0)
        $findings.Add((New-DocsParityFinding -Code 'DOCS_MATRIX_ROW_MISSING' -Severity 'error' -Pointer '/rows' -ArtifactPath $ArtifactPath -RelatedId @($parts[0]) -RelatedPath @($parts[1]) -Message "The documented binding of $($parts[0]) to $($parts[1]) has no matrix row." -NextAction 'Record a dimension with update-ledger -Operation set-dimension to create the row.'))
    }
    $reference = Get-DocsParityMember -Table (Get-DocsParityMember -Table $Matrix -Name 'ledger_ref') -Name 'sha256'
    if ([string] $reference -cne $LedgerSha256) {
        $findings.Add((New-DocsParityFinding -Code 'DOCS_MATRIX_LEDGER_REF' -Severity 'warning' -Pointer '/ledger_ref/sha256' -ArtifactPath $ArtifactPath -Message 'The matrix ledger_ref digest differs from the current ledger bytes.' -NextAction 'Run update-ledger -Operation sync-refs after the ledger changes.'))
    }
    $items = $findings.ToArray()
    return Get-DocsOrderedFinding -Finding $items -Limit ([math]::Min($script:DocsParityOrderedFindingLimit, [math]::Max(1, $items.Count)))
}

function Merge-DocsParityDimension {
    <#
    .SYNOPSIS
        Returns a new matrix in which the row for ElementId and PagePath (created when absent) records Dimension as State with the sorted PinId list.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Matrix,
        [Parameter(Mandatory = $true)] [string] $ElementId,
        [Parameter(Mandatory = $true)] [string] $Kind,
        [Parameter(Mandatory = $true)] [string] $PagePath,
        [Parameter(Mandatory = $true)] [string] $Dimension,
        [Parameter(Mandatory = $true)] [string] $State,
        [AllowNull()] [string] $Rationale,
        [AllowNull()] [AllowEmptyCollection()] [string[]] $PinId
    )

    if ($script:DocsParityDimensionList -cnotcontains $Dimension) { throw "DOCS_PARITY_INPUT_INVALID: Dimension '$Dimension' is not one of $($script:DocsParityDimensionList -join ', ')." }
    $result = Copy-DocsParityValue -Value $Matrix
    $rows = Get-DocsSortedParityRow -Row @(Get-DocsParityMember -Table $Matrix -Name 'rows')
    $target = @($rows | Where-Object { [string] (Get-DocsParityMember -Table $_ -Name 'element_id') -ceq $ElementId -and [string] (Get-DocsParityMember -Table $_ -Name 'page_path') -ceq $PagePath })
    if ($target.Count -eq 0) {
        $rows = Get-DocsSortedParityRow -Row ($rows + @((New-DocsParityRow -ElementId $ElementId -Kind $Kind -PagePath $PagePath)))
        $target = @($rows | Where-Object { [string] (Get-DocsParityMember -Table $_ -Name 'element_id') -ceq $ElementId -and [string] (Get-DocsParityMember -Table $_ -Name 'page_path') -ceq $PagePath })
    }
    foreach ($row in $target) { $row['dimensions'][$Dimension] = New-DocsParityDimensionResult -State $State -Rationale $Rationale -PinId $PinId }
    $result['rows'] = $rows
    return $result
}

function Get-DocsMatrixWithoutBinding {
    <#
    .SYNOPSIS
        Returns a new matrix without the rows of ElementId, or of ElementId on PagePath when given.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Matrix,
        [Parameter(Mandatory = $true)] [string] $ElementId,
        [AllowNull()] [string] $PagePath
    )

    $result = Copy-DocsParityValue -Value $Matrix
    $kept = @(@(Get-DocsParityMember -Table $Matrix -Name 'rows') | Where-Object {
            $sameElement = [string] (Get-DocsParityMember -Table $_ -Name 'element_id') -ceq $ElementId
            $samePage = [string]::IsNullOrEmpty($PagePath) -or ([string] (Get-DocsParityMember -Table $_ -Name 'page_path') -ceq $PagePath)
            -not ($sameElement -and $samePage)
        })
    $result['rows'] = Get-DocsSortedParityRow -Row $kept
    return $result
}

function Merge-DocsMatrixPinRemoval {
    <#
    .SYNOPSIS
        Returns a new matrix in which PinId is removed from every evidence_pin_ids list; other ids keep their order.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Matrix,
        [Parameter(Mandatory = $true)] [string] $PinId
    )

    $result = Copy-DocsParityValue -Value $Matrix
    $rows = Get-DocsSortedParityRow -Row @(Get-DocsParityMember -Table $Matrix -Name 'rows')
    foreach ($row in $rows) {
        $dimensions = Get-DocsParityMember -Table $row -Name 'dimensions'
        if ($dimensions -isnot [System.Collections.IDictionary]) { continue }
        foreach ($name in @($dimensions.Keys)) {
            $dimension = $dimensions[$name]
            if ($dimension -isnot [System.Collections.IDictionary] -or -not $dimension.Contains('evidence_pin_ids')) { continue }
            $dimension['evidence_pin_ids'] = [string[]]@(@($dimension['evidence_pin_ids']) | Where-Object { [string] $_ -cne $PinId })
        }
    }
    $result['rows'] = $rows
    return $result
}

function Merge-DocsMatrixRef {
    <#
    .SYNOPSIS
        Returns a new matrix with snapshot_ref and ledger_ref set to the supplied pins.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Matrix,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $SnapshotPin,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $LedgerPin
    )

    $result = Copy-DocsParityValue -Value $Matrix
    $result['snapshot_ref'] = [ordered]@{ artifact_kind = 'surface-inventory-snapshot'; path = [string] $SnapshotPin['path']; sha256 = [string] $SnapshotPin['sha256'] }
    $result['ledger_ref'] = [ordered]@{ artifact_kind = 'docs-coverage-ledger'; path = [string] $LedgerPin['path']; sha256 = [string] $LedgerPin['sha256'] }
    $result['rows'] = Get-DocsSortedParityRow -Row @(Get-DocsParityMember -Table $Matrix -Name 'rows')
    return $result
}

Export-ModuleMember -Function `
    Get-DocsParityDimension, `
    Test-DocsPathOrGlobMatch, `
    Get-DocsPageOwner, `
    New-DocsParityRow, `
    New-DocsParityMatrixDocument, `
    Get-DocsMatrixFinding, `
    Merge-DocsParityDimension, `
    Get-DocsMatrixWithoutBinding, `
    Merge-DocsMatrixPinRemoval, `
    Merge-DocsMatrixRef, `
    Get-DocsScoreBasisPoint, `
    Measure-DocsParityScore
