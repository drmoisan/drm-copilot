<#
.SYNOPSIS
    Pure inventory helpers of issue #1022: input selection over path lists, the aggregate bounds,
    and the surface-inventory-snapshot builder.

.DESCRIPTION
    Get-DocsInventorySelection applies the profile source roots, the exclusions (through
    Find-DocsPathOrGlobMatch) and the env withholding rule to a list of repository-relative paths:
    a non-template env-family file (.env, .env.<other>, <name>.env) is withheld without being read
    and yields ENV_FILE_NOT_CAPTURED (non-blocking warning, analyzer docs-inventory). The four
    template names accepted by Test-DocsEnvTemplatePath are selected. Get-DocsInventoryBoundFinding
    returns one DOCS_CLI_RUNTIME finding when more than 50,000 inputs are selected or more than
    256 MiB were read in total, and $null otherwise. New-DocsInventorySnapshot merges analyzer
    outputs, filters elements to surface_selection.element_kinds, removes a repeated element_id
    with DUPLICATE_DECLARATION, sorts analyzers by id, inputs by path, elements by element_id and
    diagnostics by id, and builds the header, id (Get-DocsStableId -Prefix 'surface-inventory'
    over repository, revision, profile_sha256, analyzers and inputs, excluding captured_at),
    profile_sha256 and inputs (captured inputs whose text is not $null). No digest is computed
    here: every element arrives from 1020 New-DocsSurfaceElement.

    Every function is pure: no filesystem, clock, process, environment or module-scope mutable
    state.

.NOTES
    Issue #1022. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsJson.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsFinding.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSurface.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSourceText.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsAnalyzerConfigFiles.psm1') -ErrorAction Stop

$script:DocsInventoryAnalyzerId = 'docs-inventory'
$script:DocsInventoryMaxInputCount = 50000
$script:DocsInventoryMaxTotalBytes = 268435456L
$script:DocsInventorySchema = 'urn:drm-copilot:docs:1.0.0:surface-inventory-snapshot'

function Test-DocsInventoryEnvFamilyPath {
    <#
    .SYNOPSIS
        Returns $true when the basename of Path is .env, begins with '.env.' or ends with '.env' (private helper).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Path)

    $slash = $Path.LastIndexOf('/')
    $name = if ($slash -lt 0) { $Path } else { $Path.Substring($slash + 1) }
    return ($name -ceq '.env') -or $name.StartsWith('.env.', [System.StringComparison]::Ordinal) -or $name.EndsWith('.env', [System.StringComparison]::Ordinal)
}

function Test-DocsInventoryUnderRoot {
    <#
    .SYNOPSIS
        Returns $true when Path lies under one of SourceRoot ('.' selects every path) (private helper).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Path,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $SourceRoot
    )

    foreach ($root in $SourceRoot) {
        $trimmed = ([string] $root).TrimEnd('/')
        if ($trimmed -ceq '.' -or $trimmed -ceq '') { return $true }
        if ($Path.StartsWith($trimmed + '/', [System.StringComparison]::Ordinal)) { return $true }
    }
    return $false
}

function Get-DocsInventorySelection {
    <#
    .SYNOPSIS
        Selects the inventory inputs from listed paths; returns @{ Paths; Withheld; Diagnostics }.
    .DESCRIPTION
        Paths holds the distinct selected paths sorted ordinally: those under a source root, not
        matched by an exclusion entry, and not a non-template env-family file. Withheld lists the
        env-family paths that were not selected, each with one ENV_FILE_NOT_CAPTURED diagnostic in
        Diagnostics (warning, non-blocking, analyzer docs-inventory). The result does not depend on
        the order of Path.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [AllowEmptyString()] [AllowNull()] [string[]] $Path,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $SourceRoot,
        [AllowNull()] [AllowEmptyCollection()] [object[]] $Exclusion
    )

    $selected = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::Ordinal)
    $withheld = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($candidate in @($Path)) {
        if ([string]::IsNullOrEmpty($candidate)) { continue }
        if (-not (Test-DocsInventoryUnderRoot -Path $candidate -SourceRoot $SourceRoot)) { continue }
        if ($null -ne (Find-DocsPathOrGlobMatch -Path $candidate -Entry $Exclusion)) { continue }
        if ((Test-DocsInventoryEnvFamilyPath -Path $candidate) -and -not (Test-DocsEnvTemplatePath -Path $candidate)) { [void] $withheld.Add($candidate); continue }
        [void] $selected.Add($candidate)
    }
    $diagnostics = [System.Collections.Generic.List[object]]::new()
    foreach ($entry in $withheld) {
        $diagnostics.Add((New-DocsDiagnostic -Code 'ENV_FILE_NOT_CAPTURED' -Path $entry -Message 'The env-family file was withheld: it was not read, hashed or analyzed.' -AnalyzerId $script:DocsInventoryAnalyzerId -Severity 'warning'))
    }
    return @{ Paths = [string[]]@($selected); Withheld = [string[]]@($withheld); Diagnostics = [object[]]$diagnostics.ToArray() }
}

function Get-DocsInventoryBoundFinding {
    <#
    .SYNOPSIS
        Returns one DOCS_CLI_RUNTIME finding when an aggregate bound is exceeded, else $null.
    .DESCRIPTION
        The bounds are more than 50,000 selected inputs and more than 256 MiB (268,435,456 bytes)
        read in total. The finding names the bound and the observed value, never a path.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [long] $InputCount,
        [Parameter(Mandatory = $true)] [long] $TotalBytes
    )

    $message = $null
    if ($InputCount -gt $script:DocsInventoryMaxInputCount) { $message = "The inventory selected $InputCount inputs, above the bound of $($script:DocsInventoryMaxInputCount)." }
    elseif ($TotalBytes -gt $script:DocsInventoryMaxTotalBytes) { $message = "The inventory read $TotalBytes bytes in total, above the bound of $($script:DocsInventoryMaxTotalBytes)." }
    if ($null -eq $message) { return $null }
    return New-DocsFinding -Code 'DOCS_CLI_RUNTIME' -Severity 'error' -Message $message -NextAction 'Narrow surface_selection.source_roots or add exclusions, then run the command again.'
}

function Get-DocsInventoryTimestampText {
    <#
    .SYNOPSIS
        Renders a clock value as the docs common UTC timestamp (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [datetime] $Value)

    return $Value.ToUniversalTime().ToString('yyyy-MM-dd\THH:mm:ss\Z', [System.Globalization.CultureInfo]::InvariantCulture)
}

function Get-DocsInventorySortedRecord {
    <#
    .SYNOPSIS
        Returns records sorted ordinally by one string field (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Record,
        [Parameter(Mandatory = $true)] [string] $Key
    )

    # A SortedDictionary keyed by the field value plus the input index gives a stable ordinal sort;
    # the paired [Array]::Sort overload does not reorder the items array under PowerShell 7.
    $sorted = [System.Collections.Generic.SortedDictionary[string, object]]::new([System.StringComparer]::Ordinal)
    $index = 0
    foreach ($item in @($Record)) {
        if ($null -eq $item) { continue }
        $sorted[([string] $item[$Key]) + "`n" + $index.ToString('D9', [System.Globalization.CultureInfo]::InvariantCulture)] = $item
        $index++
    }
    return , [object[]]@($sorted.Values)
}

function New-DocsInventorySnapshot {
    <#
    .SYNOPSIS
        Builds the surface-inventory-snapshot artifact from analyzer outputs and captured inputs.
    .DESCRIPTION
        Profile is the parsed profile; Revision a full object id or $null; Registration the
        selected rows (Id, Version, AnalysisMethod); CapturedInput the New-DocsCapturedInput
        records (only those with text are listed under inputs; every capture diagnostic is kept);
        AnalyzerOutput the @{ Elements; Diagnostics } records; Diagnostic extra diagnostics such
        as ENV_FILE_NOT_CAPTURED; CapturedAt the clock value. Elements outside
        surface_selection.element_kinds are dropped; a repeated element_id is dropped with
        DUPLICATE_DECLARATION (first by analyzer order kept). The id excludes captured_at.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state; the exported name is fixed by the issue #1022 contract.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Profile,
        [Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyString()] [string] $Revision,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Registration,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $CapturedInput,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $AnalyzerOutput,
        [AllowNull()] [AllowEmptyCollection()] [object[]] $Diagnostic,
        [Parameter(Mandatory = $true)] [datetime] $CapturedAt
    )

    $kinds = [string[]]@($Profile['surface_selection']['element_kinds'])
    $analyzers = [System.Collections.Generic.List[object]]::new()
    foreach ($row in $Registration) {
        $analyzers.Add([ordered]@{ id = [string] $row.Id; version = [string] $row.Version; analysis_method = [string] $row.AnalysisMethod })
    }
    $inputs = [System.Collections.Generic.List[object]]::new()
    $diagnostics = [System.Collections.Generic.List[object]]::new()
    foreach ($captured in $CapturedInput) {
        if ($null -eq $captured) { continue }
        if ($null -ne $captured['diagnostic']) { $diagnostics.Add($captured['diagnostic']) }
        if ($null -eq $captured['text']) { continue }
        $inputs.Add([ordered]@{ path = [string] $captured['path']; sha256 = [string] $captured['sha256']; size = [long] $captured['size'] })
    }
    foreach ($entry in @($Diagnostic)) { if ($null -ne $entry) { $diagnostics.Add($entry) } }

    $aggregate = New-DocsDiagnosticAggregate
    $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $elements = [System.Collections.Generic.List[object]]::new()
    foreach ($output in $AnalyzerOutput) {
        if ($null -eq $output) { continue }
        foreach ($entry in @($output['Diagnostics'])) { if ($null -ne $entry) { $diagnostics.Add($entry) } }
        foreach ($element in @($output['Elements'])) {
            if ($null -eq $element -or $kinds -cnotcontains [string] $element['kind']) { continue }
            if (-not $seen.Add([string] $element['element_id'])) {
                $line = if ($null -ne $element['line_range']) { [int] $element['line_range']['start'] } else { 0 }
                Add-DocsDiagnosticOccurrence -Aggregate $aggregate -AnalyzerId $script:DocsInventoryAnalyzerId -Code 'DUPLICATE_DECLARATION' -Path ([string] $element['path']) -Line $line -Severity 'warning'
                continue
            }
            $elements.Add($element)
        }
    }
    foreach ($entry in $aggregate.Diagnostics) { $diagnostics.Add($entry) }
    $uniqueDiagnostics = [System.Collections.Generic.Dictionary[string, object]]::new([System.StringComparer]::Ordinal)
    foreach ($entry in $diagnostics) { if (-not $uniqueDiagnostics.ContainsKey([string] $entry['id'])) { $uniqueDiagnostics[[string] $entry['id']] = $entry } }

    $sortedAnalyzers = Get-DocsInventorySortedRecord -Record $analyzers.ToArray() -Key 'id'
    $sortedInputs = Get-DocsInventorySortedRecord -Record $inputs.ToArray() -Key 'path'
    $repository = [string] $Profile['repository']['id']
    $revisionValue = if ([string]::IsNullOrEmpty($Revision)) { $null } else { $Revision }
    $profileSha256 = Get-DocsSha256Hex -Text (ConvertTo-DocsCanonicalJson -Value $Profile)
    $identity = [ordered]@{ repository = $repository; revision = $revisionValue; profile_sha256 = $profileSha256; analyzers = [object[]]$sortedAnalyzers; inputs = [object[]]$sortedInputs }
    return [ordered]@{
        '$schema'      = $script:DocsInventorySchema
        schema_version = '1.0.0'
        artifact_kind  = 'surface-inventory-snapshot'
        id             = (Get-DocsStableId -Prefix 'surface-inventory' -Value $identity)
        extensions     = [ordered]@{}
        repository     = $repository
        revision       = $revisionValue
        profile_sha256 = $profileSha256
        analyzers      = [object[]]$sortedAnalyzers
        inputs         = [object[]]$sortedInputs
        elements       = [object[]](Get-DocsInventorySortedRecord -Record $elements.ToArray() -Key 'element_id')
        diagnostics    = [object[]](Get-DocsInventorySortedRecord -Record @($uniqueDiagnostics.Values) -Key 'id')
        captured_at    = (Get-DocsInventoryTimestampText -Value $CapturedAt)
    }
}

Export-ModuleMember -Function Get-DocsInventorySelection, Get-DocsInventoryBoundFinding, New-DocsInventorySnapshot
