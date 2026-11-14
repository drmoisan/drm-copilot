<#
.SYNOPSIS
    Documentation profile parsing, schema and semantic validation, and the starter profile.

.DESCRIPTION
    ConvertFrom-DocsProfileText parses the profile text, validates it against the composed
    docs-profile schema through Test-DocsArtifactText, and then applies the semantic checks of
    Test-DocsProfileSemantic, each of which names the offending field by JSON pointer.
    New-DocsStarterProfile returns a neutral profile that passes those checks with the committed
    analyzer registry, whatever rows it holds.

    Every function is pure apart from the built-in Test-Json call made by Test-DocsArtifactText.

.NOTES
    Issue #1020. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsJson.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSchema.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsFinding.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsAnalyzerRegistry.psm1') -ErrorAction Stop

function Get-DocsDefaultProfilePath {
    <#
    .SYNOPSIS
        Returns the repository-relative default profile path.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param()

    return 'docs/documentation-estate/docs-profile.json'
}

function Get-DocsProfileList {
    <#
    .SYNOPSIS
        Returns a profile member as an array, or an empty array when absent (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [AllowNull()] [object] $Container,
        [Parameter(Mandatory = $true)] [string] $Name
    )

    if ($Container -isnot [System.Collections.IDictionary] -or -not $Container.Contains($Name) -or $null -eq $Container[$Name]) { return , [object[]]@() }
    return , [object[]]@($Container[$Name])
}

function New-DocsProfileFinding {
    <#
    .SYNOPSIS
        Builds one semantic error finding (private helper).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [string] $Code,
        [Parameter(Mandatory = $true)] [string] $Pointer,
        [Parameter(Mandatory = $true)] [string] $Message,
        [Parameter(Mandatory = $true)] [string] $NextAction,
        [AllowNull()] [string] $ArtifactPath
    )

    return New-DocsFinding -Code $Code -Severity 'error' -Pointer $Pointer -Message $Message -NextAction $NextAction -ArtifactPath $ArtifactPath
}

function Test-DocsProfileSemantic {
    <#
    .SYNOPSIS
        Returns semantic error findings for a schema-valid profile, each with a pointer.
    .DESCRIPTION
        DOCS_PROFILE_AUDIENCE_DUPLICATE (/audiences/<n>/id), DOCS_PROFILE_ROOT_DUPLICATE
        (/documentation_roots/<n>/id or /path), DOCS_PROFILE_AUDIENCE_UNKNOWN
        (/documentation_roots/<n>/audience_ids/<m>), DOCS_PROFILE_MODE_NOT_IN_POLICY
        (/diataxis_policy/directory_modes/<n>/mode) and DOCS_ANALYZER_UNKNOWN
        (/surface_selection/analyzers/<n>).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Profile,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $AnalyzerId,
        [AllowNull()] [string] $ArtifactPath
    )

    $findings = [System.Collections.Generic.List[object]]::new()
    $audiences = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $audienceList = Get-DocsProfileList -Container $Profile -Name 'audiences'
    for ($index = 0; $index -lt $audienceList.Count; $index++) {
        $id = [string] $audienceList[$index]['id']
        if (-not $audiences.Add($id)) {
            $findings.Add((New-DocsProfileFinding -Code 'DOCS_PROFILE_AUDIENCE_DUPLICATE' -Pointer "/audiences/$index/id" -ArtifactPath $ArtifactPath -Message "Field id declares the audience $id more than once." -NextAction 'Give every audience a distinct id.'))
        }
    }

    $rootIds = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $rootPaths = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $roots = Get-DocsProfileList -Container $Profile -Name 'documentation_roots'
    for ($index = 0; $index -lt $roots.Count; $index++) {
        $root = $roots[$index]
        if (-not $rootIds.Add([string] $root['id'])) {
            $findings.Add((New-DocsProfileFinding -Code 'DOCS_PROFILE_ROOT_DUPLICATE' -Pointer "/documentation_roots/$index/id" -ArtifactPath $ArtifactPath -Message "Field id repeats the documentation root $($root['id'])." -NextAction 'Give every documentation root a distinct id.'))
        }
        if (-not $rootPaths.Add([string] $root['path'])) {
            $findings.Add((New-DocsProfileFinding -Code 'DOCS_PROFILE_ROOT_DUPLICATE' -Pointer "/documentation_roots/$index/path" -ArtifactPath $ArtifactPath -Message "Field path repeats the documentation root path $($root['path'])." -NextAction 'Give every documentation root a distinct path.'))
        }
        $references = Get-DocsProfileList -Container $root -Name 'audience_ids'
        for ($position = 0; $position -lt $references.Count; $position++) {
            if (-not $audiences.Contains([string] $references[$position])) {
                $findings.Add((New-DocsProfileFinding -Code 'DOCS_PROFILE_AUDIENCE_UNKNOWN' -Pointer "/documentation_roots/$index/audience_ids/$position" -ArtifactPath $ArtifactPath -Message "Field audience_ids references the audience $($references[$position]), which the profile does not declare in audiences." -NextAction 'Declare the audience in audiences or remove the reference.'))
            }
        }
    }

    $policy = if ($Profile.Contains('diataxis_policy')) { $Profile['diataxis_policy'] } else { $null }
    $modes = Get-DocsProfileList -Container $policy -Name 'modes'
    $directoryModes = Get-DocsProfileList -Container $policy -Name 'directory_modes'
    for ($index = 0; $index -lt $directoryModes.Count; $index++) {
        $mode = [string] $directoryModes[$index]['mode']
        if ($modes -cnotcontains $mode) {
            $findings.Add((New-DocsProfileFinding -Code 'DOCS_PROFILE_MODE_NOT_IN_POLICY' -Pointer "/diataxis_policy/directory_modes/$index/mode" -ArtifactPath $ArtifactPath -Message "Field mode uses the mode $mode, which diataxis_policy.modes does not list." -NextAction 'Add the mode to diataxis_policy.modes or change the directory mode.'))
        }
    }

    $selection = if ($Profile.Contains('surface_selection')) { $Profile['surface_selection'] } else { $null }
    $analyzers = Get-DocsProfileList -Container $selection -Name 'analyzers'
    for ($index = 0; $index -lt $analyzers.Count; $index++) {
        if ($AnalyzerId -cnotcontains [string] $analyzers[$index]) {
            $findings.Add((New-DocsProfileFinding -Code 'DOCS_ANALYZER_UNKNOWN' -Pointer "/surface_selection/analyzers/$index" -ArtifactPath $ArtifactPath -Message "Field analyzers selects the analyzer $($analyzers[$index]), which is not registered." -NextAction 'Select a registered analyzer identifier or remove the entry.'))
        }
    }
    return Get-DocsOrderedFinding -Finding $findings.ToArray()
}

function ConvertFrom-DocsProfileText {
    <#
    .SYNOPSIS
        Parses and validates profile text; returns @{ Profile; Findings; Ok }.
    .DESCRIPTION
        Profile is the parsed ordinal hashtable, or $null when parsing or schema validation fails.
        Ok is $true when no error finding exists. AnalyzerId defaults to the identifiers of
        Get-DocsAnalyzerRegistration. ComposedSchemaSet is the Schemas map of
        Get-DocsComposedSchemaSet.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text,
        [Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyString()] [string] $ArtifactPath,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $ComposedSchemaSet,
        [AllowNull()] [AllowEmptyCollection()] [string[]] $AnalyzerId
    )

    if (-not $PSBoundParameters.ContainsKey('AnalyzerId') -or $null -eq $AnalyzerId) {
        $registration = Get-DocsAnalyzerRegistration
        $AnalyzerId = [string[]]@(foreach ($row in $registration) { [string] $row.Id })
    }
    $findings = Test-DocsArtifactText -ArtifactKind 'docs-profile' -JsonText $Text -ComposedSchemaSet $ComposedSchemaSet -ArtifactPath $ArtifactPath
    if ($findings.Count -gt 0) {
        return @{ Profile = $null; Findings = $findings; Ok = -not (Test-DocsFindingHasError -Finding $findings) }
    }
    $profileValue = (ConvertFrom-DocsJsonText -Text $Text -ArtifactPath $ArtifactPath).Value
    $semantic = Test-DocsProfileSemantic -Profile $profileValue -AnalyzerId $AnalyzerId -ArtifactPath $ArtifactPath
    return @{ Profile = $profileValue; Findings = $semantic; Ok = -not (Test-DocsFindingHasError -Finding $semantic) }
}

function New-DocsStarterProfile {
    <#
    .SYNOPSIS
        Returns a neutral starter profile for RepositoryId.
    .DESCRIPTION
        The profile omits surface_selection.analyzers and sets
        completion_gates.integration_pr_gate.enabled to false, so it passes
        ConvertFrom-DocsProfileText with the committed registry whatever rows it holds.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state; the exported name is fixed by the issue #1020 contract.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([string] $RepositoryId = 'repository')

    $estate = 'docs/documentation-estate'
    return [ordered]@{
        '$schema'           = 'urn:drm-copilot:docs:1.0.0:docs-profile'
        schema_version      = '1.0.0'
        artifact_kind       = 'docs-profile'
        id                  = "$RepositoryId.docs-profile"
        extensions          = [ordered]@{}
        repository          = [ordered]@{ id = $RepositoryId }
        audiences           = @([ordered]@{ id = 'maintainers'; description = 'People who change and release this repository.' })
        documentation_roots = @([ordered]@{ id = 'docs-root'; path = 'docs'; audience_ids = @('maintainers') })
        surface_selection   = [ordered]@{
            element_kinds = @('cli-command', 'cli-option', 'http-route', 'config-key', 'public-symbol', 'architecture-component')
            source_roots  = @('src')
            exclusions    = @()
        }
        page_owners         = @()
        diataxis_policy     = [ordered]@{
            modes                 = @('tutorial', 'how-to', 'reference', 'explanation')
            required_front_matter = @('owner', 'last_reviewed', 'audience', 'diataxis_mode', 'surface_refs')
            directory_modes       = @()
        }
        completion_gates    = [ordered]@{
            docs_complete       = [ordered]@{ required_dispositions_complete = $true; allow_deferred = $true; max_stale_pages = 0L; required_parity_dimensions = @('exists', 'accurate', 'owner_assigned') }
            integration_pr_gate = [ordered]@{ enabled = $false }
        }
        artifact_paths      = [ordered]@{
            inventory_snapshot = "$estate/surface-inventory-snapshot.json"
            coverage_ledger    = "$estate/docs-coverage-ledger.json"
            parity_matrix      = "$estate/docs-parity-matrix.json"
            evidence_pins      = "$estate/docs-evidence-pins.json"
            validation_receipt = "$estate/docs-validation-receipt.json"
        }
    }
}

Export-ModuleMember -Function `
    Get-DocsDefaultProfilePath, `
    ConvertFrom-DocsProfileText, `
    Test-DocsProfileSemantic, `
    New-DocsStarterProfile
