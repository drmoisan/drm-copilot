<#
.SYNOPSIS
    extension-import analyzer: validates discovery extension-result manifests captured with the
    sources and merges their findings as inert data into docs surface elements.

.DESCRIPTION
    Test-DocsExtensionManifest runs validation steps 1 through 7 of the 1033 specification
    (closed key set and constants through DocsExtensionShape.psm1, manifest digest, repository
    and revision against the selection, adapter identity, source-input capture and digests,
    result-file digests and documents, finding sources) and returns
    @{ Ok; Diagnostics; Manifest; ResultDocument }. The first failing check yields exactly one
    blocking diagnostic at the manifest path. A selection without repository_id or revision
    yields the non-blocking unverified diagnostics and the check continues. Source-input and
    result-file digests are compared with the raw-byte raw_sha256 of the captured input, because
    manifests declare raw-byte digests (issue #1173).
    Invoke-DocsAnalyzerExtensionImport selects the captured *.json inputs whose parsed root is
    an extension-result manifest, validates each, and merges every mappable finding (step 8)
    as data: nothing from a manifest is executed or imported, element identifiers and digests
    are recomputed by the docs lib, and for config-key only value_type is copied. Diagnostic
    codes follow the 1020 grammar (uppercase with underscores). Every function is pure.

.NOTES
    Issue #1033. Requires PowerShell 7.4 or later. No external module dependencies.
    Get-DocsScannerPrecisionLimit is the shipped statement of the scanner precision limit;
    extension-import has no precision-limit row (EXTENSION_FINDING_SKIPPED is not one).
    DocsAnalyzerRegistry.psm1 is imported inside Invoke-DocsAnalyzerExtensionImport, without
    -Force, only when the selection carries no registered_analyzer_ids key (no load-time
    import, so the registry seam never re-enters this module).
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsJson.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsScannerCommon.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSurface.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsExtensionShape.psm1') -ErrorAction Stop

$script:DocsExtensionAnalyzerId = 'extension-import'
$script:DocsExtensionSchema = [string] (Get-DocsExtensionManifestIdentity)['Schema']
$script:DocsExtensionArtifactKind = [string] (Get-DocsExtensionManifestIdentity)['ArtifactKind']

function New-DocsExtensionDiagnostic {
    <#
    .SYNOPSIS
        Returns one extension-import diagnostic: error when blocking, else warning (private helper).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [string] $Code,
        [Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyString()] [string] $Path,
        [Parameter(Mandatory = $true)] [string] $Message,
        [bool] $Blocking = $true
    )

    $severity = if ($Blocking) { 'error' } else { 'warning' }
    return New-DocsDiagnostic -Code $Code -Path $Path -Message $Message -AnalyzerId $script:DocsExtensionAnalyzerId -Severity $severity
}

function Find-DocsExtensionCapturedInput {
    <#
    .SYNOPSIS
        Returns the captured input whose path equals Path (ordinal), or $null (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $CapturedInput,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Path
    )

    foreach ($captured in $CapturedInput) {
        if ($null -eq $captured) { continue }
        if ([string] (Get-DocsExtensionValue -Record $captured -Name 'path') -ceq $Path) { return $captured }
    }
    return $null
}

function Test-DocsExtensionCapturedDigest {
    <#
    .SYNOPSIS
        Returns $true when a captured input's raw_sha256 and size equal the sha256 and size of a manifest payload entry (private helper).
    .DESCRIPTION
        Discovery extension manifests declare raw-byte digests, so the raw-byte raw_sha256 of the
        captured input is compared, not its line-ending-normalized sha256 (issue #1173).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)] [object] $Captured,
        [Parameter(Mandatory = $true)] [object] $Entry
    )

    $sameDigest = [string] (Get-DocsExtensionValue -Record $Captured -Name 'raw_sha256') -ceq [string] (Get-DocsExtensionValue -Record $Entry -Name 'sha256')
    $sameSize = [long] (Get-DocsExtensionValue -Record $Captured -Name 'size') -eq [long] (Get-DocsExtensionValue -Record $Entry -Name 'size')
    return $sameDigest -and $sameSize
}

function New-DocsExtensionRejection {
    <#
    .SYNOPSIS
        Appends the blocking diagnostic of a failed step and returns the rejected validation result (private helper).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [System.Collections.Generic.List[object]] $Diagnostic,
        [Parameter(Mandatory = $true)] [string] $Code,
        [Parameter(Mandatory = $true)] [string] $ManifestPath,
        [Parameter(Mandatory = $true)] [string] $Message,
        [AllowNull()] [object] $Manifest
    )

    $Diagnostic.Add((New-DocsExtensionDiagnostic -Code $Code -Path $ManifestPath -Message $Message -Blocking $true))
    return @{ Ok = $false; Diagnostics = [object[]] $Diagnostic.ToArray(); Manifest = $Manifest; ResultDocument = [object[]] @() }
}

function Get-DocsExtensionResultProblem {
    <#
    .SYNOPSIS
        Runs steps 6a and 6b for one result file and returns @{ Code; Message; Document } (private helper).
    .DESCRIPTION
        Step 6b also requires a well-formed diagnostics array and a findings array in the
        result document, because both are copied by the merge.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [object] $ResultFile,
        [Parameter(Mandatory = $true)] [int] $Index,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Manifest,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $CapturedInput
    )

    $captured = Find-DocsExtensionCapturedInput -CapturedInput $CapturedInput -Path ([string] $ResultFile['path'])
    if ($null -eq $captured -or -not (Test-DocsExtensionCapturedDigest -Captured $captured -Entry $ResultFile)) {
        return @{ Code = 'EXTENSION_RESULT_DIGEST_MISMATCH'; Message = "result file $Index is not a captured input with the declared sha256 and size"; Document = $null }
    }
    $invalid = @{ Code = 'EXTENSION_RESULT_INVALID'; Message = "result document $Index does not parse or does not match its manifest entry and adapter"; Document = $null }
    $text = Get-DocsExtensionValue -Record $captured -Name 'text'
    if ($null -eq $text) { return $invalid }
    $parsed = ConvertFrom-DocsJsonText -Text ([string] $text)
    $document = $parsed['Value']
    if ($parsed['Findings'].Count -gt 0 -or $document -isnot [System.Collections.IDictionary]) { return $invalid }
    foreach ($pair in @(@('id', $ResultFile['id']), @('artifact_kind', $ResultFile['artifact_kind']), @('schema_version', $ResultFile['schema_version']), @('repository', $Manifest['repository']['id']), @('revision', $Manifest['repository']['revision']))) {
        if ([string] (Get-DocsExtensionValue -Record $document -Name $pair[0]) -cne [string] $pair[1]) { return $invalid }
    }
    $adapter = $Manifest['adapter']
    $tools = @(Get-DocsExtensionValue -Record $document -Name 'tool')
    $analyzers = Get-DocsExtensionValue -Record $document -Name 'analyzers'
    if (-not (Test-DocsExtensionArray -Value $analyzers) -or $analyzers.Count -eq 0) { return $invalid }
    foreach ($tool in $tools + @($analyzers)) {
        if (-not (Test-DocsExtensionKeySet -Record $tool -Key @('id', 'version'))) { return $invalid }
        if ([string] $tool['id'] -cne [string] $adapter['id'] -or [string] $tool['version'] -cne [string] $adapter['version']) { return $invalid }
    }
    if (-not (Test-DocsExtensionArray -Value (Get-DocsExtensionValue -Record $document -Name 'findings'))) { return $invalid }
    if ($null -ne (Get-DocsExtensionDiagnosticProblem -Value (Get-DocsExtensionValue -Record $document -Name 'diagnostics'))) { return $invalid }
    return @{ Code = $null; Message = $null; Document = $document }
}

function Get-DocsExtensionFindingProblem {
    <#
    .SYNOPSIS
        Runs step 7 for one finding and returns a problem text, or $null (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowNull()] [object] $Finding,
        [Parameter(Mandatory = $true)] [int] $Index,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Manifest,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $CapturedInput
    )

    if ($Finding -isnot [System.Collections.IDictionary]) { return "finding $Index is not an object" }
    $adapter = $Manifest['adapter']
    $analyzer = Get-DocsExtensionValue -Record $Finding -Name 'analyzer'
    if (-not (Test-DocsExtensionKeySet -Record $analyzer -Key @('id', 'version')) -or [string] $analyzer['id'] -cne [string] $adapter['id'] -or [string] $analyzer['version'] -cne [string] $adapter['version']) {
        return "finding $Index names an analyzer other than the adapter"
    }
    $source = Get-DocsExtensionValue -Record $Finding -Name 'source'
    if ($source -isnot [System.Collections.IDictionary]) { return "finding $Index has no source object" }
    $sourcePath = Get-DocsExtensionValue -Record $source -Name 'path'
    if ($sourcePath -isnot [string]) { return "finding $Index has no source path" }
    $declared = @($Manifest['source_inputs'] | Where-Object { [string] $_['path'] -ceq [string] $sourcePath })
    if ($declared.Count -eq 0) { return "finding $Index names a source path that is not a declared source input" }
    if ([string] (Get-DocsExtensionValue -Record $source -Name 'sha256') -cne [string] $declared[0]['sha256']) { return "finding $Index carries a source sha256 that differs from the declared source input" }
    $range = Get-DocsExtensionValue -Record $source -Name 'line_range'
    if ($null -eq $range) { return $null }
    $captured = Find-DocsExtensionCapturedInput -CapturedInput $CapturedInput -Path ([string] $sourcePath)
    $lineCount = Get-DocsExtensionLineCount -Text (Get-DocsExtensionValue -Record $captured -Name 'text')
    $start = Get-DocsExtensionValue -Record $range -Name 'start'
    $end = Get-DocsExtensionValue -Record $range -Name 'end'
    if (-not (Test-DocsExtensionKeySet -Record $range -Key @('start', 'end')) -or -not (Test-DocsExtensionSize -Value $start) -or -not (Test-DocsExtensionSize -Value $end)) { return "finding $Index has a malformed line_range" }
    if ([long] $start -lt 1 -or [long] $end -lt [long] $start -or [long] $end -gt $lineCount) { return "finding $Index has a line_range outside the captured text" }
    return $null
}

function Test-DocsExtensionManifest {
    <#
    .SYNOPSIS
        Validates one extension-result manifest (steps 1 to 7) and returns @{ Ok; Diagnostics; Manifest; ResultDocument }.
    .DESCRIPTION
        Diagnostics carry the manifest path under extension-import: exactly one blocking record
        for the first failing step, plus the non-blocking EXTENSION_REPOSITORY_UNVERIFIED and
        EXTENSION_REVISION_UNVERIFIED records when Selection lacks repository_id or revision.
        Manifest is the parsed root once step 1 passes; ResultDocument lists the parsed result
        documents in result_files order once step 6 passes. KnownManifestId and KnownAdapterId
        hold the identities of earlier selected manifests for the uniqueness checks of steps 1
        and 4. input_manifest_sha256 is carried and not verified.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [AllowNull()] [string] $ManifestText,
        [Parameter(Mandatory = $true)] [string] $ManifestPath,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $CapturedInput,
        [Parameter(Mandatory = $true)] [AllowNull()] [object] $Selection,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [AllowNull()] [string[]] $RegisteredAnalyzerId,
        [AllowEmptyCollection()] [AllowNull()] [string[]] $KnownManifestId,
        [AllowEmptyCollection()] [AllowNull()] [string[]] $KnownAdapterId
    )

    $diagnostics = [System.Collections.Generic.List[object]]::new()
    $parsed = ConvertFrom-DocsJsonText -Text $ManifestText -ArtifactPath $ManifestPath
    $manifest = $parsed['Value']
    if ($parsed['Findings'].Count -gt 0 -or $manifest -isnot [System.Collections.IDictionary]) {
        return New-DocsExtensionRejection -Diagnostic $diagnostics -Code 'EXTENSION_MANIFEST_INVALID' -ManifestPath $ManifestPath -Message 'The manifest does not parse as a JSON object with unique keys.'
    }
    $problem = Get-DocsExtensionShapeProblem -Manifest $manifest -KnownManifestId $KnownManifestId
    if ($null -ne $problem) { return New-DocsExtensionRejection -Diagnostic $diagnostics -Code 'EXTENSION_MANIFEST_INVALID' -ManifestPath $ManifestPath -Message "The manifest fails the structural check: $problem." }

    $withoutDigest = [ordered]@{}
    foreach ($key in @($manifest.Keys)) { if ([string] $key -cne 'manifest_sha256') { $withoutDigest[[string] $key] = $manifest[$key] } }
    try { $expected = Get-DocsSha256Hex -Text (ConvertTo-DocsCanonicalJson -Value $withoutDigest) }
    catch { return New-DocsExtensionRejection -Diagnostic $diagnostics -Code 'EXTENSION_MANIFEST_INVALID' -ManifestPath $ManifestPath -Message 'The manifest cannot be canonicalized (only safe integers are accepted as numbers).' -Manifest $manifest }
    if ([string] $manifest['manifest_sha256'] -cne $expected) { return New-DocsExtensionRejection -Diagnostic $diagnostics -Code 'EXTENSION_MANIFEST_DIGEST_MISMATCH' -ManifestPath $ManifestPath -Message 'The manifest_sha256 differs from the digest recomputed over the manifest without that member.' -Manifest $manifest }

    $repositoryId = Get-DocsExtensionValue -Record $Selection -Name 'repository_id'
    if ($null -eq $repositoryId) { $diagnostics.Add((New-DocsExtensionDiagnostic -Code 'EXTENSION_REPOSITORY_UNVERIFIED' -Path $ManifestPath -Message 'The selection carries no repository_id; the manifest repository is not verified.' -Blocking $false)) }
    elseif ([string] $manifest['repository']['id'] -cne [string] $repositoryId) { return New-DocsExtensionRejection -Diagnostic $diagnostics -Code 'EXTENSION_REPOSITORY_MISMATCH' -ManifestPath $ManifestPath -Message 'The manifest repository id differs from the selection repository_id.' -Manifest $manifest }
    $revision = Get-DocsExtensionValue -Record $Selection -Name 'revision'
    if ($null -eq $revision) { $diagnostics.Add((New-DocsExtensionDiagnostic -Code 'EXTENSION_REVISION_UNVERIFIED' -Path $ManifestPath -Message 'The selection carries no revision; the manifest revision is not verified.' -Blocking $false)) }
    elseif ([string] $manifest['repository']['revision'] -cne [string] $revision) { return New-DocsExtensionRejection -Diagnostic $diagnostics -Code 'EXTENSION_REPOSITORY_MISMATCH' -ManifestPath $ManifestPath -Message 'The manifest repository revision differs from the selection revision.' -Manifest $manifest }

    $adapterId = [string] $manifest['adapter']['id']
    if (@($RegisteredAnalyzerId) -ccontains $adapterId) { return New-DocsExtensionRejection -Diagnostic $diagnostics -Code 'EXTENSION_ADAPTER_INVALID' -ManifestPath $ManifestPath -Message 'The adapter id is a registered docs analyzer identifier.' -Manifest $manifest }
    if (@($KnownAdapterId) -ccontains $adapterId) { return New-DocsExtensionRejection -Diagnostic $diagnostics -Code 'EXTENSION_ADAPTER_INVALID' -ManifestPath $ManifestPath -Message 'The adapter id repeats the adapter of an earlier selected manifest.' -Manifest $manifest }

    $sourceInputs = @($manifest['source_inputs'])
    for ($index = 0; $index -lt $sourceInputs.Count; $index++) {
        $captured = Find-DocsExtensionCapturedInput -CapturedInput $CapturedInput -Path ([string] $sourceInputs[$index]['path'])
        if ($null -eq $captured) { return New-DocsExtensionRejection -Diagnostic $diagnostics -Code 'EXTENSION_INPUT_NOT_CAPTURED' -ManifestPath $ManifestPath -Message "Source input $index is not a captured input." -Manifest $manifest }
        if (-not (Test-DocsExtensionCapturedDigest -Captured $captured -Entry $sourceInputs[$index])) { return New-DocsExtensionRejection -Diagnostic $diagnostics -Code 'EXTENSION_INPUT_DIGEST_MISMATCH' -ManifestPath $ManifestPath -Message "Source input $index has a sha256 or size that differs from the captured input." -Manifest $manifest }
    }

    $documents = [System.Collections.Generic.List[object]]::new()
    $resultFiles = @($manifest['result_files'])
    for ($index = 0; $index -lt $resultFiles.Count; $index++) {
        $result = Get-DocsExtensionResultProblem -ResultFile $resultFiles[$index] -Index $index -Manifest $manifest -CapturedInput $CapturedInput
        if ($null -ne $result['Code']) { return New-DocsExtensionRejection -Diagnostic $diagnostics -Code ([string] $result['Code']) -ManifestPath $ManifestPath -Message ([string] $result['Message'] + '.') -Manifest $manifest }
        $documents.Add($result['Document'])
    }
    for ($documentIndex = 0; $documentIndex -lt $documents.Count; $documentIndex++) {
        $findings = @($documents[$documentIndex]['findings'])
        for ($index = 0; $index -lt $findings.Count; $index++) {
            $problem = Get-DocsExtensionFindingProblem -Finding $findings[$index] -Index $index -Manifest $manifest -CapturedInput $CapturedInput
            if ($null -ne $problem) { return New-DocsExtensionRejection -Diagnostic $diagnostics -Code 'EXTENSION_FINDING_SOURCE_MISMATCH' -ManifestPath $ManifestPath -Message "Result document $documentIndex is rejected: $problem." -Manifest $manifest }
        }
    }
    return @{ Ok = $true; Diagnostics = [object[]] $diagnostics.ToArray(); Manifest = $manifest; ResultDocument = [object[]] $documents.ToArray() }
}

function ConvertTo-DocsExtensionCode {
    <#
    .SYNOPSIS
        Maps an adapter diagnostic code (discovery identifier grammar) to the 1020 code grammar (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [string] $Code)

    return [regex]::Replace($Code.ToUpperInvariant(), '[^A-Z0-9]', '_')
}

function ConvertTo-DocsExtensionCopiedDiagnostic {
    <#
    .SYNOPSIS
        Copies one validated manifest or result-document diagnostic under extension-import with its blocking flag (private helper).
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Entry)

    $code = ConvertTo-DocsExtensionCode -Code ([string] $Entry['code'])
    return New-DocsExtensionDiagnostic -Code $code -Path $Entry['path'] -Message ([string] $Entry['message']) -Blocking ([bool] $Entry['blocking'])
}

function Get-DocsExtensionFindingProperty {
    <#
    .SYNOPSIS
        Returns the value of a finding property by name, or $null (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Finding,
        [Parameter(Mandatory = $true)] [string] $Name
    )

    $properties = Get-DocsExtensionValue -Record $Finding -Name 'properties'
    foreach ($property in @($properties)) {
        if ($property -is [System.Collections.IDictionary] -and [string] (Get-DocsExtensionValue -Record $property -Name 'name') -ceq $Name) { return Get-DocsExtensionValue -Record $property -Name 'value' }
    }
    return $null
}

function Get-DocsExtensionSkipReason {
    <#
    .SYNOPSIS
        Returns why a validated finding cannot become an element, or $null when it is mappable (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Finding)

    $kind = Get-DocsExtensionValue -Record $Finding -Name 'kind'
    if ($kind -isnot [string] -or -not (Test-DocsElementKind -Kind ([string] $kind))) { return 'kind-not-docs-element' }
    $source = Get-DocsExtensionValue -Record $Finding -Name 'source'
    $symbol = Get-DocsExtensionValue -Record $source -Name 'symbol'
    if ($symbol -isnot [string] -or [string]::IsNullOrWhiteSpace([string] $symbol)) { return 'symbol-missing' }
    if ($null -eq (Get-DocsExtensionValue -Record $source -Name 'line_range')) { return 'line-range-missing' }
    if ([string] $kind -ceq 'cli-option') {
        $parent = Get-DocsExtensionFindingProperty -Finding $Finding -Name 'parent_symbol'
        if ($parent -isnot [string] -or [string]::IsNullOrWhiteSpace([string] $parent)) { return 'parent-symbol-missing' }
    }
    return $null
}

function ConvertTo-DocsExtensionElement {
    <#
    .SYNOPSIS
        Builds one element from a mappable finding as inert data (private helper).
    .DESCRIPTION
        element_id and the declaration-lines digest are recomputed by New-DocsSurfaceElement
        over the captured source text; adapter_id, adapter_version, classification, confidence
        and finding_id are copied as scalars; for config-key only value_type is copied, for any
        other kind the finding's scalar properties are copied; a cli-option's parent is the
        cli-command identifier of parent_symbol at parent_path (default: the same path).
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Finding,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Manifest,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $SourceText,
        [Parameter(Mandatory = $true)] [string] $AnalysisMethod
    )

    $kind = [string] $Finding['kind']
    $source = $Finding['source']
    $path = [string] $source['path']
    $declaration = [string] $source['symbol']
    [int[]] $range = @([int] $source['line_range']['start'], [int] $source['line_range']['end'])
    $nameValue = Get-DocsExtensionFindingProperty -Finding $Finding -Name 'name'
    $name = if ($nameValue -is [string] -and -not [string]::IsNullOrWhiteSpace([string] $nameValue)) { [string] $nameValue } else { $declaration }
    $property = [ordered]@{}
    if ($kind -ceq 'config-key') {
        $valueType = Get-DocsExtensionFindingProperty -Finding $Finding -Name 'value_type'
        if ($null -ne $valueType) { $property['value_type'] = $valueType }
    } else {
        $properties = Get-DocsExtensionValue -Record $Finding -Name 'properties'
        foreach ($entry in @($properties)) {
            if ($entry -is [System.Collections.IDictionary]) { $property[[string] (Get-DocsExtensionValue -Record $entry -Name 'name')] = Get-DocsExtensionValue -Record $entry -Name 'value' }
        }
    }
    $adapter = $Manifest['adapter']
    $property['adapter_id'] = [string] $adapter['id']
    $property['adapter_version'] = [string] $adapter['version']
    foreach ($copied in 'classification', 'confidence', 'finding_id') { $property[$copied] = Get-DocsExtensionValue -Record $Finding -Name $copied }
    $parentId = $null
    if ($kind -ceq 'cli-option') {
        $parentPath = Get-DocsExtensionFindingProperty -Finding $Finding -Name 'parent_path'
        if ($parentPath -isnot [string] -or [string]::IsNullOrWhiteSpace([string] $parentPath)) { $parentPath = $path }
        $parentId = Get-DocsElementId -Kind 'cli-command' -Path ([string] $parentPath) -Declaration ([string] (Get-DocsExtensionFindingProperty -Finding $Finding -Name 'parent_symbol'))
    }
    return New-DocsSurfaceElement -Kind $kind -Path $path -Declaration $declaration -Name $name -AnalyzerId $script:DocsExtensionAnalyzerId -AnalysisMethod $AnalysisMethod -SourceText $SourceText -LineRange $range -ParentId $parentId -Property $property
}

function Add-DocsExtensionManifestResult {
    <#
    .SYNOPSIS
        Merges one validated manifest (step 8): copies its diagnostics, builds elements from mappable findings and records skipped findings (private helper).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $Validation,
        [Parameter(Mandatory = $true)] [string] $ManifestPath,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $CapturedInput,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [System.Collections.Generic.List[object]] $Element,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [System.Collections.Generic.List[object]] $Direct,
        [Parameter(Mandatory = $true)] [hashtable] $Set
    )

    $manifest = $Validation['Manifest']
    $method = Get-DocsExtensionValue -Record $manifest['extensions'] -Name 'docs.analysis-method'
    if ($null -eq $method) { $method = 'scanner' }
    foreach ($entry in @($manifest['diagnostics'])) { $Direct.Add((ConvertTo-DocsExtensionCopiedDiagnostic -Entry $entry)) }
    $skipped = [System.Collections.Generic.SortedDictionary[string, int]]::new([System.StringComparer]::Ordinal)
    foreach ($document in @($Validation['ResultDocument'])) {
        $documentDiagnostics = Get-DocsExtensionValue -Record $document -Name 'diagnostics'
        foreach ($entry in @($documentDiagnostics)) { $Direct.Add((ConvertTo-DocsExtensionCopiedDiagnostic -Entry $entry)) }
        $findings = Get-DocsExtensionValue -Record $document -Name 'findings'
        foreach ($finding in @($findings)) {
            $reason = Get-DocsExtensionSkipReason -Finding $finding
            if ($null -ne $reason) { $skipped[$reason] = $(if ($skipped.ContainsKey($reason)) { $skipped[$reason] + 1 } else { 1 }); continue }
            $sourcePath = [string] $finding['source']['path']
            $captured = Find-DocsExtensionCapturedInput -CapturedInput $CapturedInput -Path $sourcePath
            try {
                $Element.Add((ConvertTo-DocsExtensionElement -Finding $finding -Manifest $manifest -SourceText ([string] (Get-DocsExtensionValue -Record $captured -Name 'text')) -AnalysisMethod ([string] $method)))
            } catch {
                Add-DocsScannerDiagnostic -Set $Set -Code 'DECLARATION_INVALID' -Path $sourcePath -Line ([int] $finding['source']['line_range']['start'])
            }
        }
    }
    if ($skipped.Count -gt 0) {
        $total = 0
        foreach ($count in $skipped.Values) { $total += $count }
        $parts = @($skipped.Keys | ForEach-Object { $_ + ' ' + $skipped[$_] }) -join ', '
        $Direct.Add((New-DocsExtensionDiagnostic -Code 'EXTENSION_FINDING_SKIPPED' -Path $ManifestPath -Message "$total finding(s) were not mapped to an element ($parts)." -Blocking $false))
    }
}

function Invoke-DocsAnalyzerExtensionImport {
    <#
    .SYNOPSIS
        Imports the captured extension-result manifests and returns @{ Elements; Diagnostics }.
    .DESCRIPTION
        A captured *.json input is selected when its parsed root carries the manifest $schema
        and artifact_kind constants. Each selected manifest is validated by
        Test-DocsExtensionManifest with the registered analyzer identifiers from
        Selection.registered_analyzer_ids, or from DocsAnalyzerRegistry.psm1 imported inside
        this function (without -Force) when that key is absent, and merged as inert data.
        Elements are sorted by element_id and diagnostics by id; a repeated diagnostic id
        keeps its first record.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $CapturedInput,
        [AllowNull()] [object] $Selection
    )

    $registered = Get-DocsExtensionValue -Record $Selection -Name 'registered_analyzer_ids'
    if ($null -eq $registered) {
        Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsAnalyzerRegistry.psm1') -ErrorAction Stop
        [object[]] $rows = Get-DocsAnalyzerRegistration
        $registered = @($rows | ForEach-Object { [string] $_.Id })
    }
    [string[]] $registeredIds = @($registered | ForEach-Object { [string] $_ })
    $set = New-DocsScannerDiagnosticSet
    $elements = [System.Collections.Generic.List[object]]::new()
    $direct = [System.Collections.Generic.List[object]]::new()
    $knownManifest = [System.Collections.Generic.List[string]]::new()
    $knownAdapter = [System.Collections.Generic.List[string]]::new()
    $selected = Select-DocsScannerInput -CapturedInput $CapturedInput -Suffix @('.json')
    foreach ($captured in $selected) {
        $path = [string] (Get-DocsExtensionValue -Record $captured -Name 'path')
        $text = Get-DocsExtensionValue -Record $captured -Name 'text'
        if ($text -isnot [string] -or -not ([string] $text).Contains($script:DocsExtensionSchema)) { continue }
        $root = (ConvertFrom-DocsJsonText -Text ([string] $text))['Value']
        if ($root -isnot [System.Collections.IDictionary]) { continue }
        if ([string] (Get-DocsExtensionValue -Record $root -Name '$schema') -cne $script:DocsExtensionSchema -or [string] (Get-DocsExtensionValue -Record $root -Name 'artifact_kind') -cne $script:DocsExtensionArtifactKind) { continue }
        $validation = Test-DocsExtensionManifest -ManifestText ([string] $text) -ManifestPath $path -CapturedInput $CapturedInput -Selection $Selection -RegisteredAnalyzerId $registeredIds -KnownManifestId $knownManifest.ToArray() -KnownAdapterId $knownAdapter.ToArray()
        foreach ($diagnostic in @($validation['Diagnostics'])) { $direct.Add($diagnostic) }
        $manifest = $validation['Manifest']
        if ($null -ne $manifest) { $knownManifest.Add([string] $manifest['id']); $knownAdapter.Add([string] $manifest['adapter']['id']) }
        if (-not $validation['Ok']) { continue }
        Add-DocsExtensionManifestResult -Validation $validation -ManifestPath $path -CapturedInput $CapturedInput -Element $elements -Direct $direct -Set $set
    }
    [object[]] $sortedElements = ConvertTo-DocsScannerElementList -Element $elements.ToArray() -Set $set
    [object[]] $setDiagnostics = ConvertTo-DocsScannerDiagnostic -Set $set -AnalyzerId $script:DocsExtensionAnalyzerId
    $merged = [System.Collections.Generic.SortedDictionary[string, object]]::new([System.StringComparer]::Ordinal)
    foreach ($diagnostic in $setDiagnostics + $direct.ToArray()) {
        $id = [string] $diagnostic['id']
        if (-not $merged.ContainsKey($id)) { $merged[$id] = $diagnostic }
    }
    return @{ Elements = $sortedElements; Diagnostics = [object[]] @($merged.Values) }
}

Export-ModuleMember -Function Test-DocsExtensionManifest, Invoke-DocsAnalyzerExtensionImport
