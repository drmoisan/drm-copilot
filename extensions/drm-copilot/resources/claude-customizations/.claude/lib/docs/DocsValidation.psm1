<#
.SYNOPSIS
    Validation modes of the documentation library: the mode list, the inputs each mode reads and
    the layered validation that produces a receipt.

.DESCRIPTION
    Get-DocsValidationMode lists profile, ledger, matrix and docs-complete in layering order;
    each mode includes the checks of the modes before it. Get-DocsValidationInputKind names the
    inputs a mode reads. Invoke-DocsValidation runs the checks of a mode over in-memory inputs
    (profile text, artifact bytes keyed by kind, the page-path set) and returns the receipt built
    by New-DocsValidationReceipt, the ordered findings and the pass flag; it never reads a file.
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
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsProfile.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedger.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedgerRules.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsParity.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsEvidencePins.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsStaleness.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsReceipt.psm1') -ErrorAction Stop

$script:DocsValidationModeList = [string[]]@('profile', 'ledger', 'matrix', 'docs-complete')
$script:DocsValidationPagePathKind = 'page-path-set'
$script:DocsValidationOrderedFindingLimit = 10000
$script:DocsValidationArtifactPathKey = @{
    'surface-inventory-snapshot' = 'inventory_snapshot'
    'docs-coverage-ledger'       = 'coverage_ledger'
    'docs-parity-matrix'         = 'parity_matrix'
    'docs-evidence-pin'          = 'evidence_pins'
    'docs-validation-receipt'    = 'validation_receipt'
}

function Get-DocsValidationMember {
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

function Get-DocsValidationOrderedFinding {
    <#
    .SYNOPSIS
        Orders findings through Get-DocsOrderedFinding with the finding count as the limit (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([AllowNull()] [AllowEmptyCollection()] [object[]] $Finding)

    $items = @($Finding | Where-Object { $null -ne $_ })
    $limit = [math]::Min($script:DocsValidationOrderedFindingLimit, [math]::Max(1, $items.Count))
    return Get-DocsOrderedFinding -Finding $items -Limit $limit
}

function Get-DocsValidationMode {
    <#
    .SYNOPSIS
        Returns the validation modes in layering order: profile, ledger, matrix, docs-complete.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param()

    return [string[]]@($script:DocsValidationModeList)
}

function Get-DocsValidationModeIndex {
    <#
    .SYNOPSIS
        Returns the layering index of a mode or throws for an unknown mode (private helper).
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Mode)

    $index = [Array]::IndexOf($script:DocsValidationModeList, $Mode)
    if ($index -lt 0) { throw "DOCS_VALIDATION_INPUT_INVALID: Mode '$Mode' is not one of $($script:DocsValidationModeList -join ', ')." }
    return $index
}

function Get-DocsValidationInputKind {
    <#
    .SYNOPSIS
        Returns the input kinds a mode reads: docs-profile; plus surface-inventory-snapshot and docs-coverage-ledger; plus docs-parity-matrix, docs-evidence-pin and page-path-set.
    #>
    [CmdletBinding()]
    [OutputType([string[]], [object[]])]
    param([Parameter(Mandatory = $true)] [string] $Mode)

    $index = Get-DocsValidationModeIndex -Mode $Mode
    $kinds = [System.Collections.Generic.List[string]]::new()
    $kinds.Add('docs-profile')
    if ($index -ge 1) { $kinds.Add('surface-inventory-snapshot'); $kinds.Add('docs-coverage-ledger') }
    if ($index -ge 2) { $kinds.Add('docs-parity-matrix'); $kinds.Add('docs-evidence-pin'); $kinds.Add($script:DocsValidationPagePathKind) }
    return , [string[]] $kinds.ToArray()
}

function Read-DocsValidationArtifact {
    <#
    .SYNOPSIS
        Decodes, schema-checks and parses one artifact of the Artifact map; returns @{ Path; Bytes; Value; Sha256; Findings } (private helper).
    .DESCRIPTION
        Artifact maps a kind to @{ Path; Bytes } or $null. An absent artifact yields one
        DOCS_INPUT_UNREADABLE error at ExpectedPath and a null Value; a parse or schema finding
        yields those findings and a null Value.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [string] $ArtifactKind,
        [AllowNull()] [System.Collections.IDictionary] $Artifact,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $ExpectedPath,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $ComposedSchemaSet
    )

    $entry = Get-DocsValidationMember -Table $Artifact -Name $ArtifactKind
    $bytes = Get-DocsValidationMember -Table $entry -Name 'Bytes'
    if ($null -eq $entry -or $null -eq $bytes) {
        $path = if (Test-DocsRelativePath -Path $ExpectedPath) { $ExpectedPath } else { $null }
        $finding = New-DocsFinding -Code 'DOCS_INPUT_UNREADABLE' -Severity 'error' -Pointer '' -ArtifactPath $path -Message "The $ArtifactKind artifact at $ExpectedPath does not exist." -NextAction 'Generate the artifact, or correct artifact_paths in the docs profile.'
        return @{ Path = $ExpectedPath; Bytes = $null; Value = $null; Sha256 = $null; Findings = [object[]]@($finding) }
    }
    $path = [string] (Get-DocsValidationMember -Table $entry -Name 'Path')
    $raw = [byte[]] $bytes
    $text = ConvertFrom-DocsUtf8Bytes -Bytes $raw
    $findings = Test-DocsArtifactText -ArtifactKind $ArtifactKind -JsonText $text -ComposedSchemaSet $ComposedSchemaSet -ArtifactPath $path
    $value = $null
    if (@($findings).Count -eq 0) { $value = (ConvertFrom-DocsJsonText -Text $text -ArtifactPath $path).Value }
    return @{ Path = $path; Bytes = $raw; Value = $value; Sha256 = (Get-DocsBytesSha256Hex -Bytes $raw); Findings = [object[]]@($findings) }
}

function Get-DocsValidationArtifactPath {
    <#
    .SYNOPSIS
        Returns the artifact_paths entry of the profile for a kind, or the empty string (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Profile,
        [Parameter(Mandatory = $true)] [string] $ArtifactKind
    )

    $key = [string] $script:DocsValidationArtifactPathKey[$ArtifactKind]
    $value = Get-DocsValidationMember -Table (Get-DocsValidationMember -Table $Profile -Name 'artifact_paths') -Name $key
    if ($value -is [string]) { return $value }
    return ''
}

function Get-DocsCompletionGateFinding {
    <#
    .SYNOPSIS
        Returns the ordered docs-complete gate findings for completion_gates.docs_complete.
    .DESCRIPTION
        DOCS_SNAPSHOT_UNPINNED when SnapshotRevision is null; DOCS_DEFERRED_NOT_ALLOWED per
        deferred entry (element and precision-limit entries alike) when allow_deferred is false;
        DOCS_PARITY_REQUIRED_DIMENSION per matrix row whose required dimension is fail or
        not-assessed; DOCS_BOUND_PAGE_MISSING per documented binding whose page is outside
        PagePath; and DOCS_STALE_PAGE per stale page, an error when the stale-page count exceeds
        max_stale_pages and a warning otherwise. StalePage is the output of Get-DocsStalePage.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Gate,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $SnapshotView,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Ledger,
        [AllowNull()] [System.Collections.IDictionary] $Matrix,
        [AllowNull()] [AllowEmptyCollection()] [object[]] $StalePage,
        [AllowNull()] [AllowEmptyCollection()] [string[]] $PagePath,
        [AllowNull()] [string] $SnapshotRevision,
        [AllowNull()] [System.Collections.IDictionary] $PinSet,
        [AllowNull()] [string] $SnapshotPath,
        [AllowNull()] [string] $LedgerPath,
        [AllowNull()] [string] $MatrixPath,
        [AllowNull()] [string] $PinPath
    )

    $findings = [System.Collections.Generic.List[object]]::new()
    if ([string]::IsNullOrEmpty($SnapshotRevision)) {
        $findings.Add((New-DocsFinding -Code 'DOCS_SNAPSHOT_UNPINNED' -Severity 'error' -Pointer '/revision' -ArtifactPath $SnapshotPath -Message 'The snapshot revision is null, so docs-complete cannot pin the receipt to a revision.' -NextAction 'Regenerate the snapshot from a committed revision before validating docs-complete.'))
    }
    $allowDeferred = [bool] (Get-DocsValidationMember -Table $Gate -Name 'allow_deferred')
    $pages = [System.Collections.Generic.HashSet[string]]::new([string[]]@($PagePath | Where-Object { $null -ne $_ }), [System.StringComparer]::Ordinal)
    $entries = @(Get-DocsValidationMember -Table $Ledger -Name 'entries')
    for ($index = 0; $index -lt $entries.Count; $index++) {
        $entry = $entries[$index]
        if ($entry -isnot [System.Collections.IDictionary]) { continue }
        $id = [string] (Get-DocsValidationMember -Table $entry -Name 'element_id')
        $related = [string[]]@($id | Where-Object { $_ -cmatch '^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$(?![\s\S])' })
        $disposition = [string] (Get-DocsValidationMember -Table $entry -Name 'disposition')
        if ($disposition -ceq 'deferred' -and -not $allowDeferred) {
            $findings.Add((New-DocsFinding -Code 'DOCS_DEFERRED_NOT_ALLOWED' -Severity 'error' -Pointer "/entries/$index/disposition" -ArtifactPath $LedgerPath -RelatedId $related -Message "The entry for $id is deferred, and the docs-complete gate does not allow deferred entries." -NextAction 'Document the element, or set completion_gates.docs_complete.allow_deferred to true.'))
        }
        if ($disposition -cne 'documented') { continue }
        $bindings = @(Get-DocsValidationMember -Table $entry -Name 'page_bindings')
        for ($position = 0; $position -lt $bindings.Count; $position++) {
            $page = [string] (Get-DocsValidationMember -Table $bindings[$position] -Name 'page_path')
            if ($pages.Contains($page)) { continue }
            $findings.Add((New-DocsFinding -Code 'DOCS_BOUND_PAGE_MISSING' -Severity 'error' -Pointer "/entries/$index/page_bindings/$position/page_path" -ArtifactPath $LedgerPath -RelatedId $related -RelatedPath ([string[]]@($page | Where-Object { Test-DocsRelativePath -Path $_ })) -Message "The entry for $id is bound to $page, which is not under a documentation root." -NextAction 'Create the page under a documentation root, or bind the element to an existing page.'))
        }
    }
    $required = [string[]]@(Get-DocsValidationMember -Table $Gate -Name 'required_parity_dimensions' | Where-Object { $_ -is [string] })
    $rows = @(Get-DocsValidationMember -Table $Matrix -Name 'rows')
    for ($index = 0; $index -lt $rows.Count; $index++) {
        $row = $rows[$index]
        if ($row -isnot [System.Collections.IDictionary]) { continue }
        $id = [string] (Get-DocsValidationMember -Table $row -Name 'element_id')
        $page = [string] (Get-DocsValidationMember -Table $row -Name 'page_path')
        $dimensions = Get-DocsValidationMember -Table $row -Name 'dimensions'
        foreach ($name in $required) {
            $state = [string] (Get-DocsValidationMember -Table (Get-DocsValidationMember -Table $dimensions -Name $name) -Name 'state')
            if ($state -cne 'fail' -and $state -cne 'not-assessed') { continue }
            $findings.Add((New-DocsFinding -Code 'DOCS_PARITY_REQUIRED_DIMENSION' -Severity 'error' -Pointer "/rows/$index/dimensions/$name/state" -ArtifactPath $MatrixPath -RelatedId ([string[]]@($id | Where-Object { $_ -cmatch '^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$(?![\s\S])' })) -RelatedPath ([string[]]@($page | Where-Object { Test-DocsRelativePath -Path $_ })) -Message "The required parity dimension $name is $state for $id on $page." -NextAction 'Assess the dimension with update-ledger -Operation set-dimension and record pass or not-applicable.'))
        }
    }
    $stale = @($StalePage | Where-Object { $null -ne $_ })
    $maxStale = [long] (Get-DocsValidationMember -Table $Gate -Name 'max_stale_pages')
    $severity = if ($stale.Count -gt $maxStale) { 'error' } else { 'warning' }
    foreach ($finding in (Get-DocsStalenessFinding -StalePage $stale -Element $SnapshotView['Element'] -Severity $severity -PinSet $PinSet -ArtifactPath $PinPath)) { $findings.Add($finding) }
    return Get-DocsValidationOrderedFinding -Finding $findings.ToArray()
}

function Invoke-DocsValidation {
    <#
    .SYNOPSIS
        Runs the checks of Mode over in-memory inputs and returns @{ Receipt; Findings; Ok }.
    .DESCRIPTION
        ProfileText is validated with ConvertFrom-DocsProfileText; Receipt is $null only when the
        profile does not load. Artifact maps an artifact kind to @{ Path; Bytes } or $null (an
        absent artifact, reported as DOCS_INPUT_UNREADABLE in a mode that needs it); every read
        artifact is pinned in the receipt inputs. The ledger layer builds the snapshot view, runs
        the ledger rules and reports DOCS_REVISION_MISMATCH when a non-null snapshot revision
        differs from Revision. The matrix layer runs the pin and matrix rules over PagePath (the
        page-path set) and the profile page owners and reports DOCS_STALE_PAGE as a warning; the
        docs-complete layer replaces that warning with the gate findings of
        Get-DocsCompletionGateFinding. Ok and validation_result come from the unbounded finding
        set. The built receipt is validated against its schema; a failure throws
        DOCS_RECEIPT_INVALID.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [string] $Mode,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Revision,
        [Parameter(Mandatory = $true)] [string] $IssuedAt,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $ProfileText,
        [Parameter(Mandatory = $true)] [string] $ProfilePath,
        [AllowNull()] [System.Collections.IDictionary] $Artifact,
        [AllowNull()] [AllowEmptyCollection()] [string[]] $PagePath,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $ComposedSchemaSet,
        [AllowNull()] [AllowEmptyCollection()] [string[]] $AnalyzerId
    )

    $index = Get-DocsValidationModeIndex -Mode $Mode
    $findings = [System.Collections.Generic.List[object]]::new()
    $profileResult = if ($PSBoundParameters.ContainsKey('AnalyzerId') -and $null -ne $AnalyzerId) {
        ConvertFrom-DocsProfileText -Text $ProfileText -ArtifactPath $ProfilePath -ComposedSchemaSet $ComposedSchemaSet -AnalyzerId $AnalyzerId
    } else {
        ConvertFrom-DocsProfileText -Text $ProfileText -ArtifactPath $ProfilePath -ComposedSchemaSet $ComposedSchemaSet
    }
    foreach ($finding in @($profileResult.Findings)) { $findings.Add($finding) }
    if ($null -eq $profileResult.Profile) {
        return @{ Receipt = $null; Findings = (Get-DocsValidationOrderedFinding -Finding $findings.ToArray()); Ok = $false }
    }
    $profileDocument = $profileResult.Profile
    $repository = [string] (Get-DocsValidationMember -Table (Get-DocsValidationMember -Table $profileDocument -Name 'repository') -Name 'id')
    $pins = [System.Collections.Generic.List[object]]::new()
    $profileEntry = Get-DocsValidationMember -Table $Artifact -Name 'docs-profile'
    if ($null -ne $profileEntry) {
        $pins.Add((Get-DocsArtifactPin -ArtifactKind 'docs-profile' -Path ([string] (Get-DocsValidationMember -Table $profileEntry -Name 'Path')) -Bytes (Get-DocsValidationMember -Table $profileEntry -Name 'Bytes')))
    }

    $view = $null
    $ledger = $null
    $stalePageCount = [long] 0
    if ($index -ge 1) {
        $snapshot = Read-DocsValidationArtifact -ArtifactKind 'surface-inventory-snapshot' -Artifact $Artifact -ExpectedPath (Get-DocsValidationArtifactPath -Profile $profileDocument -ArtifactKind 'surface-inventory-snapshot') -ComposedSchemaSet $ComposedSchemaSet
        foreach ($finding in $snapshot.Findings) { $findings.Add($finding) }
        $pins.Add((Get-DocsArtifactPin -ArtifactKind 'surface-inventory-snapshot' -Path $snapshot.Path -Bytes $snapshot.Bytes))
        if ($null -ne $snapshot.Value) {
            $view = ConvertTo-DocsSnapshotView -Snapshot $snapshot.Value -SnapshotSha256 $snapshot.Sha256 -ArtifactPath $snapshot.Path
            foreach ($finding in @($view.Findings)) { $findings.Add($finding) }
            $snapshotRevision = $view.Revision
            if ($snapshotRevision -is [string] -and $snapshotRevision -cne $Revision) {
                $findings.Add((New-DocsFinding -Code 'DOCS_REVISION_MISMATCH' -Severity 'error' -Pointer '/revision' -ArtifactPath $snapshot.Path -Message "The snapshot revision $snapshotRevision differs from the validated revision $Revision." -NextAction 'Regenerate the snapshot at the validated revision, or validate the revision the snapshot captured.'))
            }
        }
        $ledgerRead = Read-DocsValidationArtifact -ArtifactKind 'docs-coverage-ledger' -Artifact $Artifact -ExpectedPath (Get-DocsValidationArtifactPath -Profile $profileDocument -ArtifactKind 'docs-coverage-ledger') -ComposedSchemaSet $ComposedSchemaSet
        foreach ($finding in $ledgerRead.Findings) { $findings.Add($finding) }
        $pins.Add((Get-DocsArtifactPin -ArtifactKind 'docs-coverage-ledger' -Path $ledgerRead.Path -Bytes $ledgerRead.Bytes))
        $ledger = $ledgerRead.Value
        if ($null -ne $ledger -and $null -ne $view) {
            foreach ($finding in (Get-DocsLedgerFinding -Ledger $ledger -SnapshotView $view -ArtifactPath $ledgerRead.Path)) { $findings.Add($finding) }
        }
    }

    if ($index -ge 2) {
        $matrixRead = Read-DocsValidationArtifact -ArtifactKind 'docs-parity-matrix' -Artifact $Artifact -ExpectedPath (Get-DocsValidationArtifactPath -Profile $profileDocument -ArtifactKind 'docs-parity-matrix') -ComposedSchemaSet $ComposedSchemaSet
        foreach ($finding in $matrixRead.Findings) { $findings.Add($finding) }
        $pins.Add((Get-DocsArtifactPin -ArtifactKind 'docs-parity-matrix' -Path $matrixRead.Path -Bytes $matrixRead.Bytes))
        $pinRead = Read-DocsValidationArtifact -ArtifactKind 'docs-evidence-pin' -Artifact $Artifact -ExpectedPath (Get-DocsValidationArtifactPath -Profile $profileDocument -ArtifactKind 'docs-evidence-pin') -ComposedSchemaSet $ComposedSchemaSet
        foreach ($finding in $pinRead.Findings) { $findings.Add($finding) }
        $pins.Add((Get-DocsArtifactPin -ArtifactKind 'docs-evidence-pin' -Path $pinRead.Path -Bytes $pinRead.Bytes))
        $matrix = $matrixRead.Value
        $pinSet = $pinRead.Value
        $stalePages = [object[]]@()
        if ($null -ne $pinSet) {
            foreach ($finding in (Get-DocsPinFinding -PinSet $pinSet -ArtifactPath $pinRead.Path)) { $findings.Add($finding) }
            if ($null -ne $view) {
                $stalePages = Get-DocsStalePage -PinSet $pinSet -Element $view['Element']
                $stalePageCount = [long] @($stalePages).Count
            }
        }
        if ($null -ne $matrix -and $null -ne $ledger -and $null -ne $pinSet) {
            $pageOwners = [object[]]@(Get-DocsValidationMember -Table $profileDocument -Name 'page_owners')
            foreach ($finding in (Get-DocsMatrixFinding -Matrix $matrix -Ledger $ledger -PinSet $pinSet -PagePath $PagePath -PageOwner $pageOwners -LedgerSha256 $ledgerRead.Sha256 -ArtifactPath $matrixRead.Path)) { $findings.Add($finding) }
        }
        if ($null -ne $view -and $null -ne $ledger) {
            if ($Mode -ceq 'docs-complete') {
                $gate = Get-DocsValidationMember -Table (Get-DocsValidationMember -Table $profileDocument -Name 'completion_gates') -Name 'docs_complete'
                foreach ($finding in (Get-DocsCompletionGateFinding -Gate $gate -SnapshotView $view -Ledger $ledger -Matrix $matrix -StalePage $stalePages -PagePath $PagePath -SnapshotRevision $view.Revision -PinSet $pinSet -SnapshotPath $snapshot.Path -LedgerPath $ledgerRead.Path -MatrixPath $matrixRead.Path -PinPath $pinRead.Path)) { $findings.Add($finding) }
            } elseif ($null -ne $pinSet) {
                foreach ($finding in (Get-DocsStalenessFinding -StalePage $stalePages -Element $view['Element'] -Severity 'warning' -PinSet $pinSet -ArtifactPath $pinRead.Path)) { $findings.Add($finding) }
            }
        }
    }

    $ordered = Get-DocsValidationOrderedFinding -Finding $findings.ToArray()
    $hasError = Test-DocsFindingHasError -Finding $ordered
    $count = Measure-DocsReceiptCount -Mode $Mode -SnapshotView $view -Ledger $ledger -StalePageCount $stalePageCount
    $receipt = New-DocsValidationReceipt -Mode $Mode -Repository $repository -Revision $Revision -InputPin $pins.ToArray() -Count $count -Finding $ordered -IssuedAt $IssuedAt -ValidationResult $(if ($hasError) { 'fail' } else { 'pass' })
    $guard = Test-DocsArtifactText -ArtifactKind 'docs-validation-receipt' -JsonText (ConvertTo-DocsJsonText -Value $receipt) -ComposedSchemaSet $ComposedSchemaSet
    if (@($guard).Count -gt 0) { throw "DOCS_RECEIPT_INVALID: the built receipt fails its schema: $($guard[0]['code']) at '$($guard[0]['pointer'])'." }
    return @{ Receipt = $receipt; Findings = $ordered; Ok = -not $hasError }
}

Export-ModuleMember -Function `
    Get-DocsValidationMode, `
    Get-DocsValidationInputKind, `
    Get-DocsCompletionGateFinding, `
    Invoke-DocsValidation
