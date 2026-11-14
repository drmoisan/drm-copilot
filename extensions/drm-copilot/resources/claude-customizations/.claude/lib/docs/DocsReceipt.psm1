<#
.SYNOPSIS
    Validation receipt model for the documentation library: the timestamp text, the writer
    version, artifact pins, the receipt identifier, receipt counts, the receipt document and the
    gate decision over a persisted receipt.

.DESCRIPTION
    ConvertTo-DocsTimestampText formats a UTC instant and rejects any other Kind.
    Get-DocsArtifactPin pins one artifact read by Get-DocsTextSha256Hex (CRLF and lone CR mapped
    to LF before hashing, issue #1173), so a CRLF checkout of an LF-written artifact keeps its
    pin. Get-DocsReceiptId derives the
    receipt identifier from inputs, mode, repository, revision and validation_result only, so the
    identifier does not depend on the issue time. Measure-DocsReceiptCount builds the counts
    object of the receipt schema. New-DocsValidationReceipt builds the receipt document with its
    inputs sorted by artifact_kind then path. Get-DocsReceiptGateDecision returns the allow or
    deny decision that the docs enforcement hook consumes, with reasons in a fixed precedence.
    Identifier and path comparisons are ordinal and case-sensitive; every sort is ordinal.

    Every function is pure apart from the built-in Test-Json reached through
    Test-DocsArtifactText: no filesystem, clock, process, environment or module-scope mutable
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
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSchema.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSurface.psm1') -ErrorAction Stop

$script:DocsReceiptWriterVersion = '1.0.0'
$script:DocsReceiptMarkerKey = 'docs.precision-limit'
$script:DocsReceiptMode = [string[]]@('profile', 'ledger', 'matrix', 'docs-complete')
$script:DocsReceiptDisposition = [string[]]@('documented', 'excluded', 'deferred')
$script:DocsReceiptOrderedFindingLimit = 10000

function Get-DocsReceiptMember {
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

function ConvertTo-DocsTimestampText {
    <#
    .SYNOPSIS
        Formats a UTC instant as yyyy-MM-dd'T'HH:mm:ss'Z' with the invariant culture; throws DOCS_CLOCK_NOT_UTC for any other Kind.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [datetime] $UtcNow)

    if ($UtcNow.Kind -ne [System.DateTimeKind]::Utc) { throw "DOCS_CLOCK_NOT_UTC: the clock value has Kind $($UtcNow.Kind); a Utc instant is required." }
    return $UtcNow.ToString("yyyy-MM-dd'T'HH:mm:ss'Z'", [System.Globalization.CultureInfo]::InvariantCulture)
}

function Get-DocsWriterVersion {
    <#
    .SYNOPSIS
        Returns the receipt writer version, 1.0.0.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param()

    return $script:DocsReceiptWriterVersion
}

function Get-DocsArtifactPin {
    <#
    .SYNOPSIS
        Returns the artifact-pin {artifact_kind, path, sha256} of Bytes hashed with Get-DocsTextSha256Hex (line endings normalized), or $null when Bytes is $null (an absent artifact).
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [string] $ArtifactKind,
        [Parameter(Mandatory = $true)] [string] $Path,
        [AllowNull()] [AllowEmptyCollection()] [byte[]] $Bytes
    )

    if ($null -eq $Bytes) { return $null }
    return [ordered]@{ artifact_kind = $ArtifactKind; path = $Path; sha256 = (Get-DocsTextSha256Hex -Bytes $Bytes) }
}

function Get-DocsSortedArtifactPin {
    <#
    .SYNOPSIS
        Returns copies of the non-null pins sorted by artifact_kind then path (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([AllowNull()] [AllowEmptyCollection()] [object[]] $InputPin)

    $keyed = [System.Collections.Generic.SortedDictionary[string, object]]::new([System.StringComparer]::Ordinal)
    foreach ($pin in @($InputPin)) {
        if ($pin -isnot [System.Collections.IDictionary]) { continue }
        $kind = [string] (Get-DocsReceiptMember -Table $pin -Name 'artifact_kind')
        $path = [string] (Get-DocsReceiptMember -Table $pin -Name 'path')
        $keyed[$kind + [string][char]0 + $path] = [ordered]@{ artifact_kind = $kind; path = $path; sha256 = [string] (Get-DocsReceiptMember -Table $pin -Name 'sha256') }
    }
    return , [object[]]@($keyed.Values)
}

function Get-DocsReceiptId {
    <#
    .SYNOPSIS
        Returns the receipt identifier: Get-DocsStableId over inputs, mode, repository, revision and validation_result.
    .DESCRIPTION
        issued_at, counts, findings and writer are excluded, so the identifier does not depend on
        the issue time. InputPin is sorted by artifact_kind then path before hashing.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [string] $Mode,
        [Parameter(Mandatory = $true)] [string] $Repository,
        [Parameter(Mandatory = $true)] [string] $Revision,
        [AllowNull()] [AllowEmptyCollection()] [object[]] $InputPin,
        [Parameter(Mandatory = $true)] [string] $ValidationResult
    )

    $value = [ordered]@{
        inputs            = (Get-DocsSortedArtifactPin -InputPin $InputPin)
        mode              = $Mode
        repository        = $Repository
        revision          = $Revision
        validation_result = $ValidationResult
    }
    return Get-DocsStableId -Prefix 'docs-validation-receipt' -Value $value
}

function Test-DocsReceiptMarker {
    <#
    .SYNOPSIS
        Returns $true when the entry carries the docs.precision-limit marker (private helper).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()] [object] $Entry)

    $extensions = Get-DocsReceiptMember -Table $Entry -Name 'extensions'
    return ($extensions -is [System.Collections.IDictionary]) -and $extensions.Contains($script:DocsReceiptMarkerKey)
}

function Measure-DocsReceiptCount {
    <#
    .SYNOPSIS
        Returns the receipt counts {elements_total, undocumented, stale_pages, by_disposition, by_kind} for a mode.
    .DESCRIPTION
        elements_total and by_kind count the snapshot view elements; by_disposition counts the
        unmarked ledger entries whose element_id is a current element (precision-limit entries are
        excluded); undocumented counts the elements without such an entry; stale_pages is
        StalePageCount. Every count is zero where the mode reads no such input: profile mode
        reads no snapshot or ledger, and only matrix and docs-complete read the pin collection.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [string] $Mode,
        [AllowNull()] [System.Collections.IDictionary] $SnapshotView,
        [AllowNull()] [System.Collections.IDictionary] $Ledger,
        [long] $StalePageCount = 0
    )

    if ($script:DocsReceiptMode -cnotcontains $Mode) { throw "DOCS_RECEIPT_INPUT_INVALID: Mode '$Mode' is not one of $($script:DocsReceiptMode -join ', ')." }
    $byDisposition = [ordered]@{}
    foreach ($name in $script:DocsReceiptDisposition) { $byDisposition[$name] = [long] 0 }
    $byKind = [ordered]@{}
    foreach ($name in Get-DocsElementKind) { $byKind[$name] = [long] 0 }
    $total = [long] 0
    $undocumented = [long] 0
    $stale = [long] 0
    $readsLedger = $Mode -cne 'profile' -and $null -ne $SnapshotView
    if ($readsLedger) {
        $elements = $SnapshotView['Element']
        $covered = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
        foreach ($entry in @(Get-DocsReceiptMember -Table $Ledger -Name 'entries')) {
            if ($entry -isnot [System.Collections.IDictionary] -or (Test-DocsReceiptMarker -Entry $entry)) { continue }
            $id = [string] (Get-DocsReceiptMember -Table $entry -Name 'element_id')
            if (-not $elements.Contains($id) -or -not $covered.Add($id)) { continue }
            $disposition = [string] (Get-DocsReceiptMember -Table $entry -Name 'disposition')
            if ($byDisposition.Contains($disposition)) { $byDisposition[$disposition] = $byDisposition[$disposition] + 1 }
        }
        foreach ($id in @($elements.Keys)) {
            $total++
            $kind = [string] (Get-DocsReceiptMember -Table $elements[$id] -Name 'kind')
            if ($byKind.Contains($kind)) { $byKind[$kind] = $byKind[$kind] + 1 }
            if (-not $covered.Contains([string] $id)) { $undocumented++ }
        }
    }
    if ($Mode -ceq 'matrix' -or $Mode -ceq 'docs-complete') { $stale = $StalePageCount }
    return [ordered]@{
        elements_total = $total
        undocumented   = $undocumented
        stale_pages    = $stale
        by_disposition = $byDisposition
        by_kind        = $byKind
    }
}

function New-DocsValidationReceipt {
    <#
    .SYNOPSIS
        Returns the docs-validation-receipt document for one validation run.
    .DESCRIPTION
        InputPin holds one artifact-pin per artifact read ($null items, absent artifacts, are
        dropped) and is sorted by artifact_kind then path. Count is the Measure-DocsReceiptCount
        object, Finding the ordered finding set, IssuedAt the timestamp text of the clock.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [string] $Mode,
        [Parameter(Mandatory = $true)] [string] $Repository,
        [Parameter(Mandatory = $true)] [string] $Revision,
        [AllowNull()] [AllowEmptyCollection()] [object[]] $InputPin,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Count,
        [AllowNull()] [AllowEmptyCollection()] [object[]] $Finding,
        [Parameter(Mandatory = $true)] [string] $IssuedAt,
        [Parameter(Mandatory = $true)] [ValidateSet('pass', 'fail')] [string] $ValidationResult
    )

    if ($script:DocsReceiptMode -cnotcontains $Mode) { throw "DOCS_RECEIPT_INPUT_INVALID: Mode '$Mode' is not one of $($script:DocsReceiptMode -join ', ')." }
    $inputs = Get-DocsSortedArtifactPin -InputPin $InputPin
    $findings = [object[]]@(@($Finding) | Where-Object { $null -ne $_ })
    return [ordered]@{
        '$schema'         = 'urn:drm-copilot:docs:1.0.0:docs-validation-receipt'
        schema_version    = '1.0.0'
        artifact_kind     = 'docs-validation-receipt'
        id                = (Get-DocsReceiptId -Mode $Mode -Repository $Repository -Revision $Revision -InputPin $inputs -ValidationResult $ValidationResult)
        extensions        = [ordered]@{}
        mode              = $Mode
        repository        = $Repository
        revision          = $Revision
        inputs            = $inputs
        counts            = $Count
        validation_result = $ValidationResult
        findings          = $findings
        issued_at         = $IssuedAt
        writer            = [ordered]@{ tool = 'drm-copilot-docs'; version = (Get-DocsWriterVersion) }
    }
}

function Get-DocsReceiptGateDecision {
    <#
    .SYNOPSIS
        Returns @{ Allow; Reason; ReceiptId } for persisted receipt text against the head revision.
    .DESCRIPTION
        Reasons in fixed precedence: receipt-invalid (a parse or schema finding),
        mode-not-docs-complete, result-fail, revision-mismatch (ordinal comparison), else Allow is
        $true with Reason pass. An absent receipt file is the caller's receipt-missing. ReceiptId
        is the parsed id when the text parses, otherwise $null.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $ReceiptText,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $HeadRevision,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $ComposedSchemaSet
    )

    $parsed = ConvertFrom-DocsJsonText -Text $ReceiptText
    $receiptId = $null
    if ($null -ne $parsed.Value) {
        $id = Get-DocsReceiptMember -Table $parsed.Value -Name 'id'
        if ($id -is [string]) { $receiptId = $id }
    }
    $findings = Test-DocsArtifactText -ArtifactKind 'docs-validation-receipt' -JsonText $ReceiptText -ComposedSchemaSet $ComposedSchemaSet
    if (@($parsed.Findings).Count -gt 0 -or @($findings).Count -gt 0) { return @{ Allow = $false; Reason = 'receipt-invalid'; ReceiptId = $receiptId } }
    $receipt = $parsed.Value
    if ([string] (Get-DocsReceiptMember -Table $receipt -Name 'mode') -cne 'docs-complete') { return @{ Allow = $false; Reason = 'mode-not-docs-complete'; ReceiptId = $receiptId } }
    if ([string] (Get-DocsReceiptMember -Table $receipt -Name 'validation_result') -cne 'pass') { return @{ Allow = $false; Reason = 'result-fail'; ReceiptId = $receiptId } }
    if ([string] (Get-DocsReceiptMember -Table $receipt -Name 'revision') -cne $HeadRevision) { return @{ Allow = $false; Reason = 'revision-mismatch'; ReceiptId = $receiptId } }
    return @{ Allow = $true; Reason = 'pass'; ReceiptId = $receiptId }
}

Export-ModuleMember -Function `
    ConvertTo-DocsTimestampText, `
    Get-DocsWriterVersion, `
    Get-DocsArtifactPin, `
    Get-DocsReceiptId, `
    Measure-DocsReceiptCount, `
    New-DocsValidationReceipt, `
    Get-DocsReceiptGateDecision
