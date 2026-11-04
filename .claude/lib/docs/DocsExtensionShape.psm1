<#
.SYNOPSIS
    Structural checks for discovery extension-result manifests: record access, closed key sets,
    field shapes and the physical line count used by the extension-import analyzer.

.DESCRIPTION
    Split from DocsAnalyzerExtensionImport.psm1 under the 500-logical-line rule. Discovery
    schemas are not pushed down, so Get-DocsExtensionShapeProblem is a PowerShell check of the
    closed key set, the constants and the field shapes of
    schemas/discovery/v2/extension-result-manifest.schema.json (validation step 1 of the 1033
    specification), returning the first problem as text or $null. Get-DocsExtensionValue reads a
    member of a dictionary or object record without unrolling an array member. Every function is
    pure.

.NOTES
    Issue #1033. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSurface.psm1') -ErrorAction Stop

$script:DocsExtensionSchema = 'urn:drm-copilot:discovery:2.0.0:extension-result-manifest'
$script:DocsExtensionArtifactKind = 'extension-result-manifest'
$script:DocsExtensionSchemaVersion = '2.0.0'
$script:DocsExtensionResultArtifactKind = 'inventory-snapshot'
$script:DocsExtensionManifestKey = @('$schema', 'schema_version', 'artifact_kind', 'id', 'adapter', 'repository', 'input_manifest_sha256', 'source_inputs', 'result_files', 'manifest_sha256', 'generated_at', 'generated_by', 'diagnostics', 'extensions')
$script:DocsExtensionDiagnosticKey = @('id', 'code', 'severity', 'path', 'message', 'analyzer_id', 'blocking', 'extensions')
$script:DocsExtensionResultFileKey = @('artifact_kind', 'id', 'schema_version', 'path', 'sha256', 'size')
$script:DocsExtensionIdentifierPattern = '^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$(?![\s\S])'
$script:DocsExtensionKeyPattern = '^[a-z][a-z0-9]*(?:[.-][a-z0-9]+)+$(?![\s\S])'
$script:DocsExtensionSha256Pattern = '^[0-9a-f]{64}$(?![\s\S])'
$script:DocsExtensionTimestampPattern = '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(?:\.[0-9]+)?(?:Z|[+-][0-9]{2}:[0-9]{2})$(?![\s\S])'
$script:DocsExtensionNewline = [regex]::new('\r\n|\r|\n', [System.Text.RegularExpressions.RegexOptions]::CultureInvariant)

function Get-DocsExtensionValue {
    <#
    .SYNOPSIS
        Returns a member of a dictionary or object record, or $null when the record lacks it.
    .DESCRIPTION
        A list member is returned through the comma operator so that it is not unrolled; a
        string, array or $null record has no members.
    #>
    [CmdletBinding()]
    [OutputType([object], [object[]])]
    param(
        [AllowNull()] [object] $Record,
        [Parameter(Mandatory = $true)] [string] $Name
    )

    if ($null -eq $Record) { return $null }
    $value = $null
    if ($Record -is [System.Collections.IDictionary]) {
        if (-not $Record.Contains($Name)) { return $null }
        $value = $Record[$Name]
    } elseif ($Record -is [string] -or $Record -is [System.Collections.IEnumerable]) {
        return $null
    } else {
        $property = $Record.PSObject.Properties[$Name]
        if ($null -eq $property) { return $null }
        $value = $property.Value
    }
    # A PSObject-wrapped array (an object property) is copied into a plain array first.
    if ($value -is [System.Collections.IList]) { return , [object[]] @($value) }
    return $value
}

function Test-DocsExtensionKeySet {
    <#
    .SYNOPSIS
        Returns $true when Record is a dictionary whose key set is exactly Key.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()] [object] $Record,
        [Parameter(Mandatory = $true)] [string[]] $Key
    )

    if ($Record -isnot [System.Collections.IDictionary]) { return $false }
    if ($Record.Count -ne $Key.Count) { return $false }
    foreach ($name in $Key) { if (-not $Record.Contains($name)) { return $false } }
    return $true
}

function Test-DocsExtensionText {
    <#
    .SYNOPSIS
        Returns $true when Value is a string matching Pattern (ordinal, case-sensitive) (private helper).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()] [object] $Value,
        [Parameter(Mandatory = $true)] [string] $Pattern
    )

    return ($Value -is [string]) -and ([string] $Value -cmatch $Pattern)
}

function Test-DocsExtensionArray {
    <#
    .SYNOPSIS
        Returns $true when Value is a JSON array as parsed by ConvertFrom-DocsJsonText.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()] [object] $Value)

    return ($null -ne $Value) -and ($Value -is [System.Collections.IList]) -and ($Value -isnot [string])
}

function Test-DocsExtensionSize {
    <#
    .SYNOPSIS
        Returns $true when Value is a non-negative integral number.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()] [object] $Value)

    return (($Value -is [long]) -or ($Value -is [int])) -and ([long] $Value -ge 0)
}

function Test-DocsExtensionNamespacedTable {
    <#
    .SYNOPSIS
        Returns $true when Value is a dictionary whose every key is a namespaced extension key (private helper).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()] [object] $Value)

    if ($Value -isnot [System.Collections.IDictionary]) { return $false }
    foreach ($key in @($Value.Keys)) { if ([string] $key -cnotmatch $script:DocsExtensionKeyPattern) { return $false } }
    return $true
}

function Get-DocsExtensionPayloadProblem {
    <#
    .SYNOPSIS
        Returns the first shape problem of a source_inputs or result_files array, or $null (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowNull()] [object] $Value,
        [Parameter(Mandatory = $true)] [string] $Member,
        [Parameter(Mandatory = $true)] [string[]] $Key
    )

    if (-not (Test-DocsExtensionArray -Value $Value)) { return "member $Member is not an array" }
    $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    for ($index = 0; $index -lt $Value.Count; $index++) {
        $entry = $Value[$index]
        if (-not (Test-DocsExtensionKeySet -Record $entry -Key $Key)) { return "$Member entry $index has an unexpected key set" }
        if (-not (Test-DocsRelativePath -Path ([string] (Get-DocsExtensionValue -Record $entry -Name 'path')))) { return "$Member entry $index has an invalid path" }
        if (-not (Test-DocsExtensionText -Value (Get-DocsExtensionValue -Record $entry -Name 'sha256') -Pattern $script:DocsExtensionSha256Pattern)) { return "$Member entry $index has an invalid sha256" }
        if (-not (Test-DocsExtensionSize -Value (Get-DocsExtensionValue -Record $entry -Name 'size'))) { return "$Member entry $index has an invalid size" }
        if ($Key -ccontains 'artifact_kind') {
            if ([string] (Get-DocsExtensionValue -Record $entry -Name 'artifact_kind') -cne $script:DocsExtensionResultArtifactKind) { return "$Member entry $index has an unexpected artifact_kind" }
            if ([string] (Get-DocsExtensionValue -Record $entry -Name 'schema_version') -cne $script:DocsExtensionSchemaVersion) { return "$Member entry $index has an unexpected schema_version" }
            if (-not (Test-DocsExtensionText -Value (Get-DocsExtensionValue -Record $entry -Name 'id') -Pattern $script:DocsExtensionIdentifierPattern)) { return "$Member entry $index has an invalid id" }
        }
        $tuple = ($Key | ForEach-Object { [string] (Get-DocsExtensionValue -Record $entry -Name $_) }) -join "`n"
        if (-not $seen.Add($tuple)) { return "$Member entry $index repeats an earlier entry" }
    }
    return $null
}

function Get-DocsExtensionDiagnosticProblem {
    <#
    .SYNOPSIS
        Returns the first shape problem of a discovery diagnostics array, or $null.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([AllowNull()] [object] $Value)

    if (-not (Test-DocsExtensionArray -Value $Value)) { return 'member diagnostics is not an array' }
    for ($index = 0; $index -lt $Value.Count; $index++) {
        $entry = $Value[$index]
        if (-not (Test-DocsExtensionKeySet -Record $entry -Key $script:DocsExtensionDiagnosticKey)) { return "diagnostics entry $index has an unexpected key set" }
        foreach ($name in 'id', 'code', 'analyzer_id') {
            if (-not (Test-DocsExtensionText -Value (Get-DocsExtensionValue -Record $entry -Name $name) -Pattern $script:DocsExtensionIdentifierPattern)) { return "diagnostics entry $index has an invalid $name" }
        }
        if (@('information', 'warning', 'error') -cnotcontains [string] (Get-DocsExtensionValue -Record $entry -Name 'severity')) { return "diagnostics entry $index has an invalid severity" }
        $diagnosticPath = Get-DocsExtensionValue -Record $entry -Name 'path'
        if ($null -ne $diagnosticPath -and -not (Test-DocsRelativePath -Path ([string] $diagnosticPath))) { return "diagnostics entry $index has an invalid path" }
        if (-not (Test-DocsExtensionText -Value (Get-DocsExtensionValue -Record $entry -Name 'message') -Pattern '\S')) { return "diagnostics entry $index has a blank message" }
        if ((Get-DocsExtensionValue -Record $entry -Name 'blocking') -isnot [bool]) { return "diagnostics entry $index has a non-boolean blocking flag" }
        if (-not (Test-DocsExtensionNamespacedTable -Value (Get-DocsExtensionValue -Record $entry -Name 'extensions'))) { return "diagnostics entry $index has invalid extensions" }
    }
    return $null
}

function Get-DocsExtensionShapeProblem {
    <#
    .SYNOPSIS
        Returns the first step-1 problem of a parsed manifest (closed key set, constants, field shapes, id uniqueness), or $null.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowNull()] [object] $Manifest,
        [AllowNull()] [AllowEmptyCollection()] [string[]] $KnownManifestId
    )

    if (-not (Test-DocsExtensionKeySet -Record $Manifest -Key $script:DocsExtensionManifestKey)) { return 'the root key set is not the closed manifest key set' }
    if ([string] $Manifest['$schema'] -cne $script:DocsExtensionSchema) { return 'member $schema is not the extension-result-manifest schema' }
    if ([string] $Manifest['schema_version'] -cne $script:DocsExtensionSchemaVersion) { return 'member schema_version is not 2.0.0' }
    if ([string] $Manifest['artifact_kind'] -cne $script:DocsExtensionArtifactKind) { return 'member artifact_kind is not extension-result-manifest' }
    if (-not (Test-DocsExtensionText -Value $Manifest['id'] -Pattern $script:DocsExtensionIdentifierPattern)) { return 'member id is not an identifier' }
    if (@($KnownManifestId) -ccontains [string] $Manifest['id']) { return 'member id repeats the id of an earlier selected manifest' }
    $adapter = $Manifest['adapter']
    if (-not (Test-DocsExtensionKeySet -Record $adapter -Key @('id', 'version'))) { return 'member adapter has an unexpected key set' }
    if (-not (Test-DocsExtensionText -Value $adapter['id'] -Pattern $script:DocsExtensionIdentifierPattern)) { return 'member adapter.id is not an identifier' }
    if (-not (Test-DocsExtensionText -Value $adapter['version'] -Pattern '\S')) { return 'member adapter.version is blank' }
    $repository = $Manifest['repository']
    if (-not (Test-DocsExtensionKeySet -Record $repository -Key @('id', 'revision'))) { return 'member repository has an unexpected key set' }
    if (-not (Test-DocsExtensionText -Value $repository['id'] -Pattern $script:DocsExtensionIdentifierPattern)) { return 'member repository.id is not an identifier' }
    if ($repository['revision'] -isnot [string] -or -not (Test-DocsFullRevision -Revision ([string] $repository['revision']))) { return 'member repository.revision is not a full revision' }
    if (-not (Test-DocsExtensionText -Value $Manifest['input_manifest_sha256'] -Pattern $script:DocsExtensionSha256Pattern)) { return 'member input_manifest_sha256 is not a sha256' }
    $problem = Get-DocsExtensionPayloadProblem -Value $Manifest['source_inputs'] -Member 'source_inputs' -Key @('path', 'sha256', 'size')
    if ($null -ne $problem) { return $problem }
    $problem = Get-DocsExtensionPayloadProblem -Value $Manifest['result_files'] -Member 'result_files' -Key $script:DocsExtensionResultFileKey
    if ($null -ne $problem) { return $problem }
    if (-not (Test-DocsExtensionText -Value $Manifest['manifest_sha256'] -Pattern $script:DocsExtensionSha256Pattern)) { return 'member manifest_sha256 is not a sha256' }
    if (-not (Test-DocsExtensionText -Value $Manifest['generated_at'] -Pattern $script:DocsExtensionTimestampPattern)) { return 'member generated_at is not a timestamp' }
    $generatedBy = $Manifest['generated_by']
    if (-not (Test-DocsExtensionKeySet -Record $generatedBy -Key @('kind', 'id'))) { return 'member generated_by has an unexpected key set' }
    if (@('human', 'agent', 'tool') -cnotcontains [string] $generatedBy['kind']) { return 'member generated_by.kind is not human, agent or tool' }
    if (-not (Test-DocsExtensionText -Value $generatedBy['id'] -Pattern $script:DocsExtensionIdentifierPattern)) { return 'member generated_by.id is not an identifier' }
    $problem = Get-DocsExtensionDiagnosticProblem -Value $Manifest['diagnostics']
    if ($null -ne $problem) { return $problem }
    if (-not (Test-DocsExtensionNamespacedTable -Value $Manifest['extensions'])) { return 'member extensions is not a namespaced table' }
    $method = Get-DocsExtensionValue -Record $Manifest['extensions'] -Name 'docs.analysis-method'
    if ($null -ne $method -and (Get-DocsAnalysisMethod) -cnotcontains [string] $method) { return 'extension docs.analysis-method is not an analysis method' }
    $blockingCount = @($Manifest['diagnostics'] | Where-Object { $_['blocking'] }).Count
    if ($Manifest['result_files'].Count -eq 0 -and $blockingCount -eq 0) { return 'the manifest has neither a result file nor a blocking diagnostic' }
    return $null
}

function Get-DocsExtensionLineCount {
    <#
    .SYNOPSIS
        Returns the physical line count of a text ($null or empty text has no line).
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param([AllowNull()] [AllowEmptyString()] [string] $Text)

    if ([string]::IsNullOrEmpty($Text)) { return 0 }
    $count = $script:DocsExtensionNewline.Matches($Text).Count
    if ($Text.EndsWith("`n") -or $Text.EndsWith("`r")) { return $count }
    return $count + 1
}

Export-ModuleMember -Function `
    Get-DocsExtensionValue, `
    Test-DocsExtensionKeySet, `
    Test-DocsExtensionArray, `
    Test-DocsExtensionSize, `
    Get-DocsExtensionDiagnosticProblem, `
    Get-DocsExtensionShapeProblem, `
    Get-DocsExtensionLineCount
