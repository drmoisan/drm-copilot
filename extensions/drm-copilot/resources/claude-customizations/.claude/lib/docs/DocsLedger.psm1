<#
.SYNOPSIS
    Coverage ledger model for the documentation library: the snapshot view, scanner precision
    limits, ledger entries and documents, and the ledger operations.

.DESCRIPTION
    ConvertTo-DocsSnapshotView rebuilds every snapshot element with ConvertFrom-DocsSurfaceElement
    and derives the precision-limit records from the diagnostics that carry the
    docs.precision-limit marker. New-DocsLedgerEntry, New-DocsPrecisionLimitEntry and
    New-DocsLedgerDocument build the ledger shapes. Merge-DocsLedgerEntry,
    Get-DocsLedgerWithoutEntry and Merge-DocsLedgerSnapshotRef return new ledgers and never
    mutate their inputs. The ledger rules over these shapes live in the sibling
    DocsLedgerRules.psm1 (split under the file-size guidance). Identifier and path comparisons
    are ordinal and case-sensitive; every sort is ordinal.

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

$script:DocsLedgerMarkerKey = 'docs.precision-limit'
$script:DocsLedgerDisposition = [string[]]@('documented', 'excluded', 'deferred')
$script:DocsLedgerOrderedFindingLimit = 10000

function Copy-DocsLedgerValue {
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
        foreach ($key in @($Value.Keys)) { $copy[[string] $key] = Copy-DocsLedgerValue -Value $Value[$key] }
        return $copy
    }
    if ($Value -is [string]) { return $Value }
    if ($Value -is [System.Collections.IEnumerable]) {
        $list = [System.Collections.Generic.List[object]]::new()
        foreach ($item in $Value) { $list.Add((Copy-DocsLedgerValue -Value $item)) }
        return , $list.ToArray()
    }
    return $Value
}

function Get-DocsLedgerMember {
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

function Get-DocsLedgerOrderedFinding {
    <#
    .SYNOPSIS
        Orders findings through Get-DocsOrderedFinding without truncating a practical set (private helper).
    .DESCRIPTION
        Exit codes and validation results are computed from the unbounded set, so the limit is the
        count itself (clamped to the Get-DocsOrderedFinding range).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([AllowNull()] [AllowEmptyCollection()] [object[]] $Finding)

    $items = @($Finding | Where-Object { $null -ne $_ })
    $limit = [math]::Min($script:DocsLedgerOrderedFindingLimit, [math]::Max(1, $items.Count))
    return Get-DocsOrderedFinding -Finding $items -Limit $limit
}

function New-DocsLedgerFinding {
    <#
    .SYNOPSIS
        Builds one finding for this module (private helper).
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

function Test-DocsLedgerMarker {
    <#
    .SYNOPSIS
        Returns $true when the record's extensions contain the docs.precision-limit key (private helper).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()] [object] $Record)

    $extensions = Get-DocsLedgerMember -Table $Record -Name 'extensions'
    return ($extensions -is [System.Collections.IDictionary]) -and $extensions.Contains($script:DocsLedgerMarkerKey)
}

function Get-DocsPrecisionLimitRuleFailure {
    <#
    .SYNOPSIS
        Returns $null when the three marker rules hold, otherwise @{ Pointer; Message } (private helper).
    .DESCRIPTION
        Rule 1: the docs.precision-limit value is an object whose element_kind is an element kind.
        Rule 2: path is a non-null relative path. Rule 3: analyzer_id names an analyzer whose
        analysis_method is scanner. Pointer is relative to the diagnostic.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Diagnostic,
        [AllowNull()] [AllowEmptyCollection()] [object[]] $Analyzer
    )

    $marker = Get-DocsLedgerMember -Table (Get-DocsLedgerMember -Table $Diagnostic -Name 'extensions') -Name $script:DocsLedgerMarkerKey
    $kind = Get-DocsLedgerMember -Table $marker -Name 'element_kind'
    if ($marker -isnot [System.Collections.IDictionary] -or $kind -isnot [string] -or -not (Test-DocsElementKind -Kind $kind)) {
        return @{ Pointer = '/extensions/' + $script:DocsLedgerMarkerKey + '/element_kind'; Message = 'the docs.precision-limit marker must be an object whose element_kind is an element kind' }
    }
    $path = Get-DocsLedgerMember -Table $Diagnostic -Name 'path'
    if ($path -isnot [string] -or -not (Test-DocsRelativePath -Path $path)) {
        return @{ Pointer = '/path'; Message = 'a precision-limit diagnostic must carry a non-null relative path' }
    }
    $analyzerId = [string] (Get-DocsLedgerMember -Table $Diagnostic -Name 'analyzer_id')
    $scanner = $false
    foreach ($row in @($Analyzer)) {
        if ([string] (Get-DocsLedgerMember -Table $row -Name 'id') -ceq $analyzerId -and [string] (Get-DocsLedgerMember -Table $row -Name 'analysis_method') -ceq 'scanner') { $scanner = $true }
    }
    if (-not $scanner) {
        return @{ Pointer = '/analyzer_id'; Message = "the analyzer '$analyzerId' is not a snapshot analyzer with analysis_method scanner" }
    }
    return $null
}

function Test-DocsPrecisionLimitDiagnostic {
    <#
    .SYNOPSIS
        Returns $true exactly when Diagnostic carries the docs.precision-limit marker and satisfies its three rules.
    .DESCRIPTION
        Analyzer is the snapshot analyzers array; rule 3 requires the diagnostic's analyzer_id to
        name an item whose analysis_method is scanner. A diagnostic without the marker is $false.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Diagnostic,
        [AllowNull()] [AllowEmptyCollection()] [object[]] $Analyzer
    )

    if (-not (Test-DocsLedgerMarker -Record $Diagnostic)) { return $false }
    return $null -eq (Get-DocsPrecisionLimitRuleFailure -Diagnostic $Diagnostic -Analyzer $Analyzer)
}

function Get-DocsPrecisionLimitElementId {
    <#
    .SYNOPSIS
        Returns the precision-limit element id: Get-DocsElementId over the marker kind, the diagnostic path and the diagnostic id.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $ElementKind,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Path,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $DiagnosticId
    )

    return Get-DocsElementId -Kind $ElementKind -Path $Path -Declaration $DiagnosticId
}

function ConvertTo-DocsSnapshotView {
    <#
    .SYNOPSIS
        Rebuilds a parsed snapshot into @{ Repository; Revision; Sha256; Element; PrecisionLimit; Findings }.
    .DESCRIPTION
        Element maps element_id to the element rebuilt with ConvertFrom-DocsSurfaceElement; a
        rebuild failure or a repeated element_id is DOCS_SNAPSHOT_ELEMENT_INVALID at /elements/<n>.
        PrecisionLimit maps the precision-limit element id to
        @{ DiagnosticId; AnalyzerId; Code; Path; ElementKind; ElementId } for every diagnostic that
        carries the docs.precision-limit marker; a marked diagnostic that fails a marker rule, or
        whose derived id equals an element id or another limit id, is DOCS_SNAPSHOT_LIMIT_INVALID
        at /diagnostics/<n>. Diagnostics without the marker are not read. Findings are ordered.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseLiteralInitializerForHashtable', '', Justification = 'Identifiers are case-sensitive; the @{} literal is case-insensitive, so an ordinal-comparer hashtable is required.')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Snapshot,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $SnapshotSha256,
        [AllowNull()] [string] $ArtifactPath
    )

    $findings = [System.Collections.Generic.List[object]]::new()
    $elements = [hashtable]::new([System.StringComparer]::Ordinal)
    $records = @(Get-DocsLedgerMember -Table $Snapshot -Name 'elements')
    for ($index = 0; $index -lt $records.Count; $index++) {
        $pointer = "/elements/$index"
        try {
            $rebuilt = ConvertFrom-DocsSurfaceElement -Record $records[$index]
        } catch {
            $findings.Add((New-DocsLedgerFinding -Code 'DOCS_SNAPSHOT_ELEMENT_INVALID' -Severity 'error' -Pointer $pointer -ArtifactPath $ArtifactPath -Message "Element $index cannot be rebuilt: $($_.Exception.Message)" -NextAction 'Regenerate the inventory snapshot with the registered analyzers.'))
            continue
        }
        $id = [string] $rebuilt['element_id']
        if ($elements.ContainsKey($id)) {
            $findings.Add((New-DocsLedgerFinding -Code 'DOCS_SNAPSHOT_ELEMENT_INVALID' -Severity 'error' -Pointer "$pointer/element_id" -ArtifactPath $ArtifactPath -RelatedId @($id) -Message "Element $index repeats the element id $id." -NextAction 'Regenerate the inventory snapshot so each element id appears once.'))
            continue
        }
        $elements[$id] = $rebuilt
    }

    $limits = [hashtable]::new([System.StringComparer]::Ordinal)
    $analyzers = @(Get-DocsLedgerMember -Table $Snapshot -Name 'analyzers')
    $diagnostics = @(Get-DocsLedgerMember -Table $Snapshot -Name 'diagnostics')
    for ($index = 0; $index -lt $diagnostics.Count; $index++) {
        $diagnostic = $diagnostics[$index]
        if ($diagnostic -isnot [System.Collections.IDictionary] -or -not (Test-DocsLedgerMarker -Record $diagnostic)) { continue }
        $pointer = "/diagnostics/$index"
        $failure = Get-DocsPrecisionLimitRuleFailure -Diagnostic $diagnostic -Analyzer $analyzers
        if ($null -ne $failure) {
            $findings.Add((New-DocsLedgerFinding -Code 'DOCS_SNAPSHOT_LIMIT_INVALID' -Severity 'error' -Pointer ($pointer + $failure.Pointer) -ArtifactPath $ArtifactPath -Message "Diagnostic $index is not a valid precision-limit diagnostic: $($failure.Message)." -NextAction 'Correct the scanner so precision-limit diagnostics carry a valid marker, a path and a scanner analyzer.'))
            continue
        }
        $kind = [string] $diagnostic['extensions'][$script:DocsLedgerMarkerKey]['element_kind']
        $path = [string] $diagnostic['path']
        $diagnosticId = [string] (Get-DocsLedgerMember -Table $diagnostic -Name 'id')
        $limitId = Get-DocsPrecisionLimitElementId -ElementKind $kind -Path $path -DiagnosticId $diagnosticId
        if ($elements.ContainsKey($limitId) -or $limits.ContainsKey($limitId)) {
            $findings.Add((New-DocsLedgerFinding -Code 'DOCS_SNAPSHOT_LIMIT_INVALID' -Severity 'error' -Pointer "$pointer/id" -ArtifactPath $ArtifactPath -RelatedId @($limitId, $diagnosticId) -RelatedPath @($path) -Message "Diagnostic $index derives the precision-limit element id $limitId, which is already an element id or another precision-limit id." -NextAction 'Regenerate the inventory snapshot so each precision-limit diagnostic derives a distinct id.'))
            continue
        }
        $limits[$limitId] = @{
            DiagnosticId = $diagnosticId
            AnalyzerId   = [string] $diagnostic['analyzer_id']
            Code         = [string] (Get-DocsLedgerMember -Table $diagnostic -Name 'code')
            Path         = $path
            ElementKind  = $kind
            ElementId    = $limitId
        }
    }

    return @{
        Repository     = Get-DocsLedgerMember -Table $Snapshot -Name 'repository'
        Revision       = Get-DocsLedgerMember -Table $Snapshot -Name 'revision'
        Sha256         = $SnapshotSha256
        Element        = $elements
        PrecisionLimit = $limits
        Findings       = (Get-DocsLedgerOrderedFinding -Finding $findings.ToArray())
    }
}

function ConvertTo-DocsLedgerActor {
    <#
    .SYNOPSIS
        Copies an actor table to the ordered {kind, id} shape (private helper).
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Actor)

    foreach ($field in 'kind', 'id') {
        if (-not $Actor.Contains($field) -or [string]::IsNullOrWhiteSpace([string] $Actor[$field])) { throw "DOCS_LEDGER_INPUT_INVALID: Actor must carry a non-blank $field." }
    }
    return [ordered]@{ kind = [string] $Actor['kind']; id = [string] $Actor['id'] }
}

function ConvertTo-DocsLedgerText {
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

function Get-DocsLedgerSortedBinding {
    <#
    .SYNOPSIS
        Returns page bindings as ordered {page_path, anchor} records sorted by page_path then anchor, null anchor first (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([AllowNull()] [AllowEmptyCollection()] [object[]] $PageBinding)

    $keyed = [System.Collections.Generic.SortedDictionary[string, System.Collections.Generic.List[object]]]::new([System.StringComparer]::Ordinal)
    foreach ($binding in @($PageBinding)) {
        if ($null -eq $binding) { continue }
        if ($binding -isnot [System.Collections.IDictionary] -or -not $binding.Contains('page_path')) { throw 'DOCS_LEDGER_INPUT_INVALID: each page binding must carry page_path.' }
        $anchor = ConvertTo-DocsLedgerText -Value (Get-DocsLedgerMember -Table $binding -Name 'anchor')
        $key = [string] $binding['page_path'] + [string][char]0 + $(if ($null -eq $anchor) { '' } else { [string][char]1 + $anchor })
        if (-not $keyed.ContainsKey($key)) { $keyed[$key] = [System.Collections.Generic.List[object]]::new() }
        $keyed[$key].Add([ordered]@{ page_path = [string] $binding['page_path']; anchor = $anchor })
    }
    $sorted = [System.Collections.Generic.List[object]]::new()
    foreach ($group in $keyed.Values) { foreach ($item in $group) { $sorted.Add($item) } }
    return , $sorted.ToArray()
}

function New-DocsLedgerEntry {
    <#
    .SYNOPSIS
        Returns one ledger entry whose element_id, kind and analysis_method come from the current element.
    .DESCRIPTION
        PageBinding items are {page_path, anchor} records, sorted by page_path then anchor (null
        first). Disposition must be documented, excluded or deferred; the companion rules are not
        enforced here (Get-DocsLedgerEntryCompanionFinding reports them).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Element,
        [Parameter(Mandatory = $true)] [string] $Disposition,
        [AllowNull()] [AllowEmptyCollection()] [object[]] $PageBinding,
        [AllowNull()] [string] $Rationale,
        [AllowNull()] [string] $Owner,
        [AllowNull()] [string] $Target,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Actor
    )

    if ($script:DocsLedgerDisposition -cnotcontains $Disposition) { throw "DOCS_LEDGER_INPUT_INVALID: Disposition '$Disposition' is not one of $($script:DocsLedgerDisposition -join ', ')." }
    foreach ($field in 'element_id', 'kind', 'analysis_method') {
        if (-not $Element.Contains($field) -or [string]::IsNullOrEmpty([string] $Element[$field])) { throw "DOCS_LEDGER_INPUT_INVALID: Element must carry $field." }
    }
    return [ordered]@{
        element_id      = [string] $Element['element_id']
        kind            = [string] $Element['kind']
        analysis_method = [string] $Element['analysis_method']
        disposition     = $Disposition
        page_bindings   = (Get-DocsLedgerSortedBinding -PageBinding $PageBinding)
        rationale       = (ConvertTo-DocsLedgerText -Value $Rationale)
        owner           = (ConvertTo-DocsLedgerText -Value $Owner)
        target          = (ConvertTo-DocsLedgerText -Value $Target)
        updated_by      = (ConvertTo-DocsLedgerActor -Actor $Actor)
        extensions      = [ordered]@{}
    }
}

function New-DocsPrecisionLimitEntry {
    <#
    .SYNOPSIS
        Returns the deferred scanner ledger entry for one precision limit of a snapshot view.
    .DESCRIPTION
        Limit is a PrecisionLimit record of ConvertTo-DocsSnapshotView. The entry carries the
        precision-limit element id, the marker kind, analysis_method scanner, disposition deferred,
        no binding, the owner and target, and the docs.precision-limit marker
        {analyzer_id, code, diagnostic_id} in extensions.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Limit,
        [Parameter(Mandatory = $true)] [string] $Owner,
        [Parameter(Mandatory = $true)] [string] $Target,
        [AllowNull()] [string] $Rationale,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Actor
    )

    foreach ($field in 'DiagnosticId', 'AnalyzerId', 'Code', 'Path', 'ElementKind', 'ElementId') {
        if (-not $Limit.Contains($field) -or [string]::IsNullOrEmpty([string] $Limit[$field])) { throw "DOCS_LEDGER_INPUT_INVALID: Limit must carry $field." }
    }
    return [ordered]@{
        element_id      = [string] $Limit['ElementId']
        kind            = [string] $Limit['ElementKind']
        analysis_method = 'scanner'
        disposition     = 'deferred'
        page_bindings   = [object[]]@()
        rationale       = (ConvertTo-DocsLedgerText -Value $Rationale)
        owner           = $Owner
        target          = $Target
        updated_by      = (ConvertTo-DocsLedgerActor -Actor $Actor)
        extensions      = [ordered]@{
            $script:DocsLedgerMarkerKey = [ordered]@{ analyzer_id = [string] $Limit['AnalyzerId']; code = [string] $Limit['Code']; diagnostic_id = [string] $Limit['DiagnosticId'] }
        }
    }
}

function New-DocsLedgerDocument {
    <#
    .SYNOPSIS
        Returns an empty ledger with the artifact header; its id depends only on the repository id.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [string] $RepositoryId,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $SnapshotPin
    )

    return [ordered]@{
        '$schema'      = 'urn:drm-copilot:docs:1.0.0:docs-coverage-ledger'
        schema_version = '1.0.0'
        artifact_kind  = 'docs-coverage-ledger'
        id             = (Get-DocsStableId -Prefix 'docs-coverage-ledger' -Value ([ordered]@{ repository = $RepositoryId }))
        extensions     = [ordered]@{}
        repository     = $RepositoryId
        snapshot_ref   = [ordered]@{ artifact_kind = 'surface-inventory-snapshot'; path = [string] $SnapshotPin['path']; sha256 = [string] $SnapshotPin['sha256'] }
        entries        = [object[]]@()
    }
}

function Get-DocsLedgerSortedEntry {
    <#
    .SYNOPSIS
        Returns copies of the entries sorted by element_id (ordinal; private helper).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([AllowNull()] [AllowEmptyCollection()] [object[]] $Entry)

    $keyed = [System.Collections.Generic.SortedDictionary[string, System.Collections.Generic.List[object]]]::new([System.StringComparer]::Ordinal)
    foreach ($item in @($Entry)) {
        if ($null -eq $item) { continue }
        $key = [string] (Get-DocsLedgerMember -Table $item -Name 'element_id')
        if (-not $keyed.ContainsKey($key)) { $keyed[$key] = [System.Collections.Generic.List[object]]::new() }
        $keyed[$key].Add((Copy-DocsLedgerValue -Value $item))
    }
    $sorted = [System.Collections.Generic.List[object]]::new()
    foreach ($group in $keyed.Values) { foreach ($item in $group) { $sorted.Add($item) } }
    return , $sorted.ToArray()
}

function Merge-DocsLedgerEntry {
    <#
    .SYNOPSIS
        Returns a new ledger in which Entry replaces or joins the entry with its element_id; entries sorted by element_id.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Ledger,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Entry
    )

    $result = Copy-DocsLedgerValue -Value $Ledger
    $id = [string] (Get-DocsLedgerMember -Table $Entry -Name 'element_id')
    $kept = @(@(Get-DocsLedgerMember -Table $Ledger -Name 'entries') | Where-Object { [string] (Get-DocsLedgerMember -Table $_ -Name 'element_id') -cne $id })
    $result['entries'] = Get-DocsLedgerSortedEntry -Entry ($kept + @($Entry))
    return $result
}

function Get-DocsLedgerWithoutEntry {
    <#
    .SYNOPSIS
        Returns a new ledger without the entry named by ElementId (an element or precision-limit id).
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Ledger,
        [Parameter(Mandatory = $true)] [string] $ElementId
    )

    $result = Copy-DocsLedgerValue -Value $Ledger
    $kept = @(@(Get-DocsLedgerMember -Table $Ledger -Name 'entries') | Where-Object { [string] (Get-DocsLedgerMember -Table $_ -Name 'element_id') -cne $ElementId })
    $result['entries'] = Get-DocsLedgerSortedEntry -Entry $kept
    return $result
}

function Merge-DocsLedgerSnapshotRef {
    <#
    .SYNOPSIS
        Returns a new ledger with snapshot_ref set to SnapshotPin and each element entry's analysis_method refreshed from the view.
    .DESCRIPTION
        Precision-limit entries (marked) are unchanged. SnapshotPin is {artifact_kind, path, sha256}.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Ledger,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $SnapshotPin,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $SnapshotView
    )

    $result = Copy-DocsLedgerValue -Value $Ledger
    $result['snapshot_ref'] = [ordered]@{ artifact_kind = 'surface-inventory-snapshot'; path = [string] $SnapshotPin['path']; sha256 = [string] $SnapshotPin['sha256'] }
    $elements = $SnapshotView['Element']
    $entries = Get-DocsLedgerSortedEntry -Entry @(Get-DocsLedgerMember -Table $Ledger -Name 'entries')
    foreach ($entry in $entries) {
        if (Test-DocsLedgerMarker -Record $entry) { continue }
        $id = [string] (Get-DocsLedgerMember -Table $entry -Name 'element_id')
        if ($elements.ContainsKey($id)) { $entry['analysis_method'] = [string] $elements[$id]['analysis_method'] }
    }
    $result['entries'] = $entries
    return $result
}

Export-ModuleMember -Function `
    ConvertTo-DocsSnapshotView, `
    Test-DocsPrecisionLimitDiagnostic, `
    Get-DocsPrecisionLimitElementId, `
    New-DocsLedgerEntry, `
    New-DocsPrecisionLimitEntry, `
    New-DocsLedgerDocument, `
    Merge-DocsLedgerEntry, `
    Get-DocsLedgerWithoutEntry, `
    Merge-DocsLedgerSnapshotRef
