<#
.SYNOPSIS
    Test support for the issue #1023 ledger suites: a recording in-memory command context with
    injectable failures, fixture builders for the profile, snapshot, ledger, matrix and pin
    collection, the composed runtime schema set, the property seeds and a seeded shuffle.

.DESCRIPTION
    New-DocsLedgerTestContext returns a new context on every call with the member set of the real
    context of Invoke-DocsCommand.ps1 (RepositoryRoot, ReadText, ReadBytes, TestFile, ListFile,
    WriteText, UtcNow, InvokeProcess). Files live in an ordinal hashtable of repository-relative
    path to UTF-8 bytes; every ReadText, ReadBytes, TestFile, ListFile and WriteText call is
    recorded in order in a call log; WriteText stores the text so a later read returns it; a path
    named in ReadBytesFailure or WriteTextFailure throws the configured message instead. The clock
    returns a fixed value of Kind Utc unless overridden. Nothing is cached at module scope.

    Fixture builders return fresh ordered hashtables on every call and use only issue #1020
    functions, so a suite never depends on the module it tests for its fixtures. The fixture
    snapshot holds one element of each kind with mixed-case declarations and both analysis
    methods, one native and one scanner analyzer, and one precision-limit diagnostic.

.NOTES
    Issue #1023. Test support only; never shipped.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib/docs/DocsJson.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib/docs/DocsSchema.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib/docs/DocsSurface.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib/docs/DocsProfile.psm1') -ErrorAction Stop

# Seeds of every property test; each -Because message states the seed in use.
$script:DocsPropertySeed = [int[]]@(11, 1023, 65537)
$script:DocsLedgerTestRepositoryId = 'fixture-repo'
$script:DocsLedgerTestRevision = '0123456789abcdef0123456789abcdef01234567'
$script:DocsLedgerTestTimestamp = '2026-03-01T12:00:00Z'

function Get-DocsLedgerTestSeed {
    <#
    .SYNOPSIS
        Returns the property-test seeds 11, 1023 and 65537.
    #>
    [CmdletBinding()]
    [OutputType([int[]])]
    param()

    # Emitted one seed at a time, so foreach and @() consumers see three integers.
    return [int[]]@($script:DocsPropertySeed)
}

function Get-DocsLedgerTestShuffle {
    <#
    .SYNOPSIS
        Returns a seeded Fisher-Yates permutation of Item; the same seed gives the same order.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Item,
        [Parameter(Mandatory = $true)] [int] $Seed
    )

    $copy = [object[]]@($Item)
    $random = [System.Random]::new($Seed)
    for ($index = $copy.Length - 1; $index -gt 0; $index--) {
        $other = $random.Next($index + 1)
        $swap = $copy[$index]
        $copy[$index] = $copy[$other]
        $copy[$other] = $swap
    }
    return , $copy
}

function Get-DocsLedgerTestSchemaSet {
    <#
    .SYNOPSIS
        Returns the composed runtime schema set (the Schemas map) read from the committed copies.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.IDictionary])]
    param()

    $composed = Get-DocsComposedSchemaSet -SchemaSet (Read-DocsSchemaSet)
    if (@($composed.Findings).Count -gt 0) { throw "The runtime schemas did not compose: $($composed.Findings[0].code) $($composed.Findings[0].message)" }
    return $composed.Schemas
}

function New-DocsLedgerTestContext {
    <#
    .SYNOPSIS
        Returns @{ Context; Files; CallLog; WriteLog } for one recording in-memory command context.
    .DESCRIPTION
        File maps a repository-relative path to text or bytes. ReadBytesFailure and
        WriteTextFailure map a path to the message thrown when that path is read or written.
        ReadText and ReadBytes of an absent path throw an item-not-found error; WriteText with
        Mode 'create' on an existing path throws, as the real member does. InvokeProcess throws.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Test fixture factory that builds in-memory objects only.')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseLiteralInitializerForHashtable', '', Justification = 'Repository paths are case-sensitive; an ordinal-comparer hashtable is required.')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [AllowNull()] [System.Collections.IDictionary] $File,
        [datetime] $UtcNow = [datetime]::new(2026, 3, 1, 12, 0, 0, [System.DateTimeKind]::Utc),
        [AllowNull()] [System.Collections.IDictionary] $ReadBytesFailure,
        [AllowNull()] [System.Collections.IDictionary] $WriteTextFailure,
        [string] $RepositoryRoot = 'in-memory-repository'
    )

    $utf8 = [System.Text.UTF8Encoding]::new($false, $true)
    $files = [hashtable]::new([System.StringComparer]::Ordinal)
    if ($null -ne $File) {
        foreach ($key in $File.Keys) {
            $value = $File[$key]
            $bytes = if ($null -eq $value) { [byte[]]@() } elseif ($value -is [byte[]]) { [byte[]] $value.Clone() } else { $utf8.GetBytes([string] $value) }
            $files[[string] $key] = $bytes
        }
    }
    $readFailure = [hashtable]::new([System.StringComparer]::Ordinal)
    if ($null -ne $ReadBytesFailure) { foreach ($key in $ReadBytesFailure.Keys) { $readFailure[[string] $key] = [string] $ReadBytesFailure[$key] } }
    $writeFailure = [hashtable]::new([System.StringComparer]::Ordinal)
    if ($null -ne $WriteTextFailure) { foreach ($key in $WriteTextFailure.Keys) { $writeFailure[[string] $key] = [string] $WriteTextFailure[$key] } }
    $callLog = [System.Collections.Generic.List[object]]::new()
    $writeLog = [System.Collections.Generic.List[object]]::new()
    $clock = $UtcNow

    $readBytes = {
        param($RelativePath)
        $path = [string] $RelativePath
        $callLog.Add([pscustomobject]@{ Member = 'ReadBytes'; RelativePath = $path; Mode = $null })
        if ($readFailure.ContainsKey($path)) { throw [System.IO.IOException]::new([string] $readFailure[$path]) }
        if (-not $files.ContainsKey($path)) { throw [System.Management.Automation.ItemNotFoundException]::new("Cannot find path '$path' because it does not exist.") }
        return , ([byte[]] $files[$path].Clone())
    }.GetNewClosure()
    $readText = {
        param($RelativePath)
        $path = [string] $RelativePath
        $callLog.Add([pscustomobject]@{ Member = 'ReadText'; RelativePath = $path; Mode = $null })
        if ($readFailure.ContainsKey($path)) { throw [System.IO.IOException]::new([string] $readFailure[$path]) }
        if (-not $files.ContainsKey($path)) { throw [System.Management.Automation.ItemNotFoundException]::new("Cannot find path '$path' because it does not exist.") }
        $bytes = [byte[]] $files[$path]
        $offset = if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) { 3 } else { 0 }
        return $utf8.GetString($bytes, $offset, $bytes.Length - $offset)
    }.GetNewClosure()
    $testFile = {
        param($RelativePath)
        $path = [string] $RelativePath
        $callLog.Add([pscustomobject]@{ Member = 'TestFile'; RelativePath = $path; Mode = $null })
        return $files.ContainsKey($path)
    }.GetNewClosure()
    $listFile = {
        param($RelativeRoot)
        $callLog.Add([pscustomobject]@{ Member = 'ListFile'; RelativePath = [string] $RelativeRoot; Mode = $null })
        $prefix = ([string] $RelativeRoot).TrimEnd('/') + '/'
        [string[]] $matched = @($files.Keys | Where-Object { ([string] $_).StartsWith($prefix, [System.StringComparison]::Ordinal) })
        [Array]::Sort($matched, [System.StringComparer]::Ordinal)
        return , $matched
    }.GetNewClosure()
    $writeText = {
        param($RelativePath, $Text, $Mode)
        $path = [string] $RelativePath
        $callLog.Add([pscustomobject]@{ Member = 'WriteText'; RelativePath = $path; Mode = [string] $Mode })
        if ($writeFailure.ContainsKey($path)) { throw [System.IO.IOException]::new([string] $writeFailure[$path]) }
        if ($Mode -ceq 'create' -and $files.ContainsKey($path)) { throw [System.IO.IOException]::new("The file '$path' already exists.") }
        $value = if ($null -eq $Text) { '' } else { [string] $Text }
        $writeLog.Add([pscustomobject]@{ RelativePath = $path; Text = $value; Mode = [string] $Mode })
        $files[$path] = $utf8.GetBytes($value)
    }.GetNewClosure()
    $utcNowMember = {
        return $clock
    }.GetNewClosure()
    $invokeProcess = {
        param($FilePath, $ArgumentList, $StdinText, $TimeoutSeconds)
        throw "InvokeProcess is not available in the ledger test context (FilePath '$FilePath', ArgumentList '$ArgumentList', StdinText '$StdinText', TimeoutSeconds '$TimeoutSeconds')."
    }

    $context = [pscustomobject]@{
        RepositoryRoot = $RepositoryRoot
        ReadText       = $readText
        ReadBytes      = $readBytes
        TestFile       = $testFile
        ListFile       = $listFile
        WriteText      = $writeText
        UtcNow         = $utcNowMember
        InvokeProcess  = $invokeProcess
    }
    return @{ Context = $context; Files = $files; CallLog = $callLog; WriteLog = $writeLog }
}

function Get-DocsLedgerTestElementSpec {
    <#
    .SYNOPSIS
        Returns the six fixture element specifications in kind order (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param()

    return [object[]]@(
        @{ Kind = 'cli-command'; Path = 'src/app/Cli.ps1'; Declaration = 'Tool Docs Inventory'; Name = 'inventory'; AnalyzerId = 'fixture-native'; AnalysisMethod = 'native' }
        @{ Kind = 'cli-option'; Path = 'src/app/Cli.ps1'; Declaration = 'Tool Docs Inventory -Analyzer'; Name = '-Analyzer'; AnalyzerId = 'fixture-native'; AnalysisMethod = 'native' }
        @{ Kind = 'http-route'; Path = 'src/app/Routes.ps1'; Declaration = 'GET /Items/{id}'; Name = 'get_item'; AnalyzerId = 'fixture-scanner'; AnalysisMethod = 'scanner' }
        @{ Kind = 'config-key'; Path = 'config/Settings.json'; Declaration = 'tool.settings.Timeout'; Name = 'Timeout'; AnalyzerId = 'fixture-scanner'; AnalysisMethod = 'scanner' }
        @{ Kind = 'public-symbol'; Path = 'src/app/Module.psm1'; Declaration = 'function Get-Thing'; Name = 'Get-Thing'; AnalyzerId = 'fixture-native'; AnalysisMethod = 'native' }
        @{ Kind = 'architecture-component'; Path = 'src/app'; Declaration = 'src/app'; Name = 'app'; AnalyzerId = 'fixture-scanner'; AnalysisMethod = 'scanner' }
    )
}

function New-DocsLedgerTestElement {
    <#
    .SYNOPSIS
        Returns the fixture element of one kind, built with New-DocsSurfaceElement.
    .DESCRIPTION
        The source text is the declaration followed by LF; every kind except
        architecture-component uses line range 1-1. AnalysisMethod overrides the fixture method.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Test fixture factory that builds in-memory objects only.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [string] $Kind,
        [AllowNull()] [string] $AnalysisMethod,
        [AllowNull()] [string] $SourceText
    )

    $spec = @(Get-DocsLedgerTestElementSpec | Where-Object { $_.Kind -ceq $Kind })
    if ($spec.Count -ne 1) { throw "No fixture element has the kind '$Kind'." }
    $spec = $spec[0]
    $method = if ([string]::IsNullOrEmpty($AnalysisMethod)) { $spec.AnalysisMethod } else { $AnalysisMethod }
    $text = if ([string]::IsNullOrEmpty($SourceText)) { $spec.Declaration + "`n" } else { $SourceText }
    $parent = $null
    if ($Kind -ceq 'cli-option') {
        $command = @(Get-DocsLedgerTestElementSpec | Where-Object { $_.Kind -ceq 'cli-command' })[0]
        $parent = Get-DocsElementId -Kind 'cli-command' -Path $command.Path -Declaration $command.Declaration
    }
    $range = if ($Kind -ceq 'architecture-component') { $null } else { [int[]]@(1, 1) }
    return New-DocsSurfaceElement -Kind $Kind -Path $spec.Path -Declaration $spec.Declaration -Name $spec.Name -AnalyzerId $spec.AnalyzerId -AnalysisMethod $method -SourceText $text -ParentId $parent -LineRange $range
}

function New-DocsLedgerTestPrecisionLimitDiagnostic {
    <#
    .SYNOPSIS
        Returns a scanner diagnostic carrying the docs.precision-limit marker.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Test fixture factory that builds in-memory objects only.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [string] $Code = 'DOCS_SCANNER_DYNAMIC_COMMAND',
        [AllowNull()] [string] $Path = 'src/app/Dynamic.ps1',
        [string] $ElementKind = 'cli-command',
        [string] $AnalyzerId = 'fixture-scanner'
    )

    $diagnostic = New-DocsDiagnostic -Code $Code -Path $Path -Message 'The scanner cannot classify a dynamically registered command.' -AnalyzerId $AnalyzerId -Severity 'warning'
    $diagnostic['extensions']['docs.precision-limit'] = [ordered]@{ element_kind = $ElementKind }
    return $diagnostic
}

function New-DocsLedgerTestSnapshot {
    <#
    .SYNOPSIS
        Returns the fixture snapshot: six elements, two analyzers, one precision-limit diagnostic.
    .DESCRIPTION
        Element and Diagnostic replace the default lists when supplied; -NoRevision sets a null
        revision. The inputs list holds one row per distinct element path.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Test fixture factory that builds in-memory objects only.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [AllowNull()] [AllowEmptyCollection()] [object[]] $Element,
        [AllowNull()] [AllowEmptyCollection()] [object[]] $Diagnostic,
        [string] $Revision = $script:DocsLedgerTestRevision,
        [switch] $NoRevision,
        [string] $RepositoryId = $script:DocsLedgerTestRepositoryId
    )

    if (-not $PSBoundParameters.ContainsKey('Element')) { $Element = @(foreach ($kind in Get-DocsElementKind) { New-DocsLedgerTestElement -Kind $kind }) }
    if (-not $PSBoundParameters.ContainsKey('Diagnostic')) { $Diagnostic = @(New-DocsLedgerTestPrecisionLimitDiagnostic) }
    $paths = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($item in @($Element)) { [void]$paths.Add([string] $item['path']) }
    $inputs = @(foreach ($path in $paths) { [ordered]@{ path = $path; sha256 = (Get-DocsSha256Hex -Text $path); size = [long] $path.Length } })
    return [ordered]@{
        '$schema'      = 'urn:drm-copilot:docs:1.0.0:surface-inventory-snapshot'
        schema_version = '1.0.0'
        artifact_kind  = 'surface-inventory-snapshot'
        id             = "$RepositoryId.surface-inventory-snapshot"
        extensions     = [ordered]@{}
        repository     = $RepositoryId
        revision       = $(if ($NoRevision) { $null } else { $Revision })
        profile_sha256 = (Get-DocsSha256Hex -Text 'fixture-profile')
        analyzers      = @(
            [ordered]@{ id = 'fixture-native'; version = '1.0.0'; analysis_method = 'native' }
            [ordered]@{ id = 'fixture-scanner'; version = '1.0.0'; analysis_method = 'scanner' }
        )
        inputs         = [object[]] $inputs
        elements       = [object[]] @($Element)
        diagnostics    = [object[]] @($Diagnostic)
        captured_at    = $script:DocsLedgerTestTimestamp
    }
}

function New-DocsLedgerTestProfile {
    <#
    .SYNOPSIS
        Returns the fixture profile: starter profile with fixture roots, owners, gate and paths.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Test fixture factory that builds in-memory objects only.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [bool] $AllowDeferred = $true,
        [long] $MaxStalePages = 0,
        [string[]] $RequiredParityDimension = @('exists', 'accurate', 'owner_assigned'),
        [string] $RepositoryId = $script:DocsLedgerTestRepositoryId
    )

    $document = New-DocsStarterProfile -RepositoryId $RepositoryId
    $document['documentation_roots'] = @([ordered]@{ id = 'docs-root'; path = 'docs'; audience_ids = @('maintainers') })
    $document['page_owners'] = @(
        [ordered]@{ path_or_glob = 'docs/reference/**'; owner = 'docs-team' }
        [ordered]@{ path_or_glob = 'docs'; owner = 'maintainer-team' }
    )
    $document['completion_gates']['docs_complete'] = [ordered]@{
        required_dispositions_complete = $true
        allow_deferred                 = $AllowDeferred
        max_stale_pages                = [long] $MaxStalePages
        required_parity_dimensions     = [string[]] $RequiredParityDimension
    }
    $document['artifact_paths'] = [ordered]@{
        inventory_snapshot = 'estate/surface-inventory-snapshot.json'
        coverage_ledger    = 'estate/docs-coverage-ledger.json'
        parity_matrix      = 'estate/docs-parity-matrix.json'
        evidence_pins      = 'estate/docs-evidence-pins.json'
        validation_receipt = 'estate/docs-validation-receipt.json'
    }
    return $document
}

function New-DocsLedgerTestEntry {
    <#
    .SYNOPSIS
        Returns one literal ledger entry for Element (default: documented with one binding).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Test fixture factory that builds in-memory objects only.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Element,
        [string] $Disposition = 'documented',
        [AllowNull()] [AllowEmptyCollection()] [object[]] $PageBinding,
        [AllowNull()] [string] $Rationale,
        [AllowNull()] [string] $Owner,
        [AllowNull()] [string] $Target,
        [AllowNull()] [System.Collections.IDictionary] $Extension
    )

    if (-not $PSBoundParameters.ContainsKey('PageBinding')) {
        $PageBinding = if ($Disposition -ceq 'documented') { @([ordered]@{ page_path = 'docs/reference/Cli.md'; anchor = $null }) } else { @() }
    }
    $extensions = [ordered]@{}
    if ($null -ne $Extension) { foreach ($key in $Extension.Keys) { $extensions[[string] $key] = $Extension[$key] } }
    return [ordered]@{
        element_id      = [string] $Element['element_id']
        kind            = [string] $Element['kind']
        analysis_method = [string] $Element['analysis_method']
        disposition     = $Disposition
        page_bindings   = [object[]] @($PageBinding)
        rationale       = $(if ([string]::IsNullOrEmpty($Rationale)) { $null } else { $Rationale })
        owner           = $(if ([string]::IsNullOrEmpty($Owner)) { $null } else { $Owner })
        target          = $(if ([string]::IsNullOrEmpty($Target)) { $null } else { $Target })
        updated_by      = [ordered]@{ kind = 'tool'; id = 'fixture-tool' }
        extensions      = $extensions
    }
}

function New-DocsLedgerTestLedger {
    <#
    .SYNOPSIS
        Returns a ledger document with the given entries and snapshot digest.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Test fixture factory that builds in-memory objects only.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [string] $SnapshotSha256,
        [AllowNull()] [AllowEmptyCollection()] [object[]] $Entry,
        [string] $SnapshotPath = 'estate/surface-inventory-snapshot.json',
        [string] $RepositoryId = $script:DocsLedgerTestRepositoryId
    )

    return [ordered]@{
        '$schema'      = 'urn:drm-copilot:docs:1.0.0:docs-coverage-ledger'
        schema_version = '1.0.0'
        artifact_kind  = 'docs-coverage-ledger'
        id             = "$RepositoryId.docs-coverage-ledger"
        extensions     = [ordered]@{}
        repository     = $RepositoryId
        snapshot_ref   = [ordered]@{ artifact_kind = 'surface-inventory-snapshot'; path = $SnapshotPath; sha256 = $SnapshotSha256 }
        entries        = [object[]] @($Entry)
    }
}

function New-DocsLedgerTestRow {
    <#
    .SYNOPSIS
        Returns one literal parity row; Dimension overrides dimension results by name.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Test fixture factory that builds in-memory objects only.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Element,
        [string] $PagePath = 'docs/reference/Cli.md',
        [AllowNull()] [System.Collections.IDictionary] $Dimension
    )

    $dimensions = [ordered]@{}
    foreach ($name in 'exists', 'accurate', 'example_present', 'owner_assigned', 'diataxis_mode') {
        $dimensions[$name] = if ($null -ne $Dimension -and $Dimension.Contains($name)) { $Dimension[$name] } else { [ordered]@{ state = 'not-assessed'; rationale = $null; evidence_pin_ids = [string[]]@() } }
    }
    return [ordered]@{
        element_id = [string] $Element['element_id']
        kind       = [string] $Element['kind']
        page_path  = $PagePath
        dimensions = $dimensions
        extensions = [ordered]@{}
    }
}

function New-DocsLedgerTestMatrix {
    <#
    .SYNOPSIS
        Returns a parity matrix document with the given rows and reference digests.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Test fixture factory that builds in-memory objects only.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [string] $SnapshotSha256,
        [Parameter(Mandatory = $true)] [string] $LedgerSha256,
        [AllowNull()] [AllowEmptyCollection()] [object[]] $Row,
        [string] $RepositoryId = $script:DocsLedgerTestRepositoryId
    )

    return [ordered]@{
        '$schema'      = 'urn:drm-copilot:docs:1.0.0:docs-parity-matrix'
        schema_version = '1.0.0'
        artifact_kind  = 'docs-parity-matrix'
        id             = "$RepositoryId.docs-parity-matrix"
        extensions     = [ordered]@{}
        repository     = $RepositoryId
        snapshot_ref   = [ordered]@{ artifact_kind = 'surface-inventory-snapshot'; path = 'estate/surface-inventory-snapshot.json'; sha256 = $SnapshotSha256 }
        ledger_ref     = [ordered]@{ artifact_kind = 'docs-coverage-ledger'; path = 'estate/docs-coverage-ledger.json'; sha256 = $LedgerSha256 }
        rows           = [object[]] @($Row)
    }
}

function New-DocsLedgerTestPin {
    <#
    .SYNOPSIS
        Returns one literal evidence pin for Element on PagePath with the derived pin_id.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Test fixture factory that builds in-memory objects only.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Element,
        [string] $PagePath = 'docs/reference/Cli.md',
        [AllowNull()] [string] $Claim,
        [AllowNull()] [string] $Revision = $script:DocsLedgerTestRevision,
        [AllowNull()] [string] $SourceSha256,
        [string] $PinnedAt = $script:DocsLedgerTestTimestamp
    )

    $symbol = [string] $Element['declaration']
    $digest = if ([string]::IsNullOrEmpty($SourceSha256)) { [string] $Element['source_sha256'] } else { $SourceSha256 }
    return [ordered]@{
        pin_id        = (Get-DocsStableId -Prefix 'pin' -Value ([ordered]@{ element_id = [string] $Element['element_id']; page_path = $PagePath; symbol = $symbol }))
        element_id    = [string] $Element['element_id']
        element_kind  = [string] $Element['kind']
        page_path     = $PagePath
        symbol        = $symbol
        source_path   = [string] $Element['path']
        source_sha256 = $digest
        revision      = $(if ([string]::IsNullOrEmpty($Revision)) { $null } else { $Revision })
        claim         = $(if ([string]::IsNullOrEmpty($Claim)) { $null } else { $Claim })
        pinned_at     = $PinnedAt
        pinned_by     = [ordered]@{ kind = 'tool'; id = 'fixture-tool' }
    }
}

function New-DocsLedgerTestPinSet {
    <#
    .SYNOPSIS
        Returns a pin collection document with the given pins.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Test fixture factory that builds in-memory objects only.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [AllowNull()] [AllowEmptyCollection()] [object[]] $Pin,
        [string] $RepositoryId = $script:DocsLedgerTestRepositoryId
    )

    return [ordered]@{
        '$schema'      = 'urn:drm-copilot:docs:1.0.0:docs-evidence-pin'
        schema_version = '1.0.0'
        artifact_kind  = 'docs-evidence-pin'
        id             = "$RepositoryId.docs-evidence-pins"
        extensions     = [ordered]@{}
        repository     = $RepositoryId
        pins           = [object[]] @($Pin)
    }
}

Export-ModuleMember -Variable DocsPropertySeed -Function `
    Get-DocsLedgerTestSeed, `
    Get-DocsLedgerTestShuffle, `
    Get-DocsLedgerTestSchemaSet, `
    New-DocsLedgerTestContext, `
    New-DocsLedgerTestElement, `
    New-DocsLedgerTestPrecisionLimitDiagnostic, `
    New-DocsLedgerTestSnapshot, `
    New-DocsLedgerTestProfile, `
    New-DocsLedgerTestEntry, `
    New-DocsLedgerTestLedger, `
    New-DocsLedgerTestRow, `
    New-DocsLedgerTestMatrix, `
    New-DocsLedgerTestPin, `
    New-DocsLedgerTestPinSet
