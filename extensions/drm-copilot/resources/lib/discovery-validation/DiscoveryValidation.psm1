<#
.SYNOPSIS
    Bounded compatibility surface of the retired PowerShell discovery-artifact validator (#475, #980).
.DESCRIPTION
    Until issue #980 this module evaluated discovery artifacts itself: a placeholder
    profile contract and `Test-Json -SchemaFile` checks against the v1 schemas. One
    Python engine now owns artifact meaning, the installed TypeScript gateway is the
    only writer of protected validation receipts, and the native hooks under
    `.claude/hooks`, `.codex/hooks` and `.github/hooks` verify protected current
    authority through the sibling Discovery* modules. This module therefore keeps
    its exported names for compatibility and directs every semantic question to
    the authoritative service:

    - the artifact-type table and the destination PowerShell floor are retained
      (the floor is still the hook runtime requirement, and an unsupported host
      fails closed with the same actionable message);
    - every former validation entry returns a validation-required result naming
      `validate_discovery_artifacts`; none parses a profile or a schema, none
      returns an empty error list, and `Invoke-DiscoveryArtifactValidation` never
      returns `ExitCode = 0`, so an old entry name cannot mint a passing gate;
    - `Get-DiscoveryValidationAuthority` reports whether the workspace holds a
      protected activation on a supported host, which is the only authority a
      native hook consults.

    No Python interpreter or other process is invoked anywhere in this module.
.NOTES
    Issues #475 and #980. Requires PowerShell 7.4 or later on a destination host.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'DiscoveryEncoding.psm1') -ErrorAction Stop
Import-Module (Join-Path $PSScriptRoot 'DiscoveryAuthority.psm1') -ErrorAction Stop

# Schema-governed artifact types mapped to their filenames under `schemas/discovery/v1/`.
# Retained as documentation and artifact-type recognition only; no schema is evaluated here.
$script:DiscoverySchemaArtifactFile = [ordered]@{
    'feature-contract'     = 'feature-contract.schema.json'
    'coverage-ledger'      = 'coverage-ledger.schema.json'
    'runtime-scenario'     = 'runtime-characterization-scenario.schema.json'
    'parity-matrix'        = 'parity-matrix.schema.json'
    'unspecified-behavior' = 'unspecified-behavior-record.schema.json'
    'product-decision'     = 'product-decision-record.schema.json'
    'evidence-reference'   = 'evidence-reference.schema.json'
}
$script:MinimumPowerShellVersion = [version]'7.4'
$script:ValidationRequiredPrefix = 'DISCOVERY_VALIDATION_REQUIRED:'
$script:ServiceOperation = 'validate_discovery_artifacts'

function Get-DiscoveryRuntimeVersionError {
    <#
    .SYNOPSIS
        Returns the fail-closed message when the host PowerShell is below 7.4, or $null when the host meets the floor.
    .DESCRIPTION
        The destination version floor (issue #475) is unchanged: the native hooks
        and this module require PowerShell 7.4 or later. `PowerShellVersion` is the
        injectable seam, defaulting to the real `$PSVersionTable.PSVersion` and only
        ever read.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $false)][version]$PowerShellVersion = $PSVersionTable.PSVersion)

    if ($PowerShellVersion -ge $script:MinimumPowerShellVersion) { return $null }
    return (
        "Discovery-artifact validation requires PowerShell $($script:MinimumPowerShellVersion) or later " +
        "(this host is PowerShell $PowerShellVersion). Reason: schema validation uses " +
        "'Test-Json -SchemaFile', whose JSON Schema Draft 2020-12 support was added in PowerShell 7.4, " +
        'and every schema under schemas/discovery/v1/ declares Draft 2020-12. ' +
        'See issue #475. Upgrade the destination host to PowerShell 7.4+ to run this gate.'
    )
}

function Get-DiscoverySchemaArtifactType {
    <#
    .SYNOPSIS
        Returns the seven schema-governed artifact-type tokens.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param()

    return [string[]]@($script:DiscoverySchemaArtifactFile.Keys)
}

function Get-DiscoverySchemaFileName {
    <#
    .SYNOPSIS
        Returns the v1 schema filename of a schema-governed artifact type, or $null for any other token.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$ArtifactType)

    if ($script:DiscoverySchemaArtifactFile.Contains($ArtifactType)) { return [string]$script:DiscoverySchemaArtifactFile[$ArtifactType] }
    return $null
}

function Resolve-DiscoverySchemaFilePath {
    <#
    .SYNOPSIS
        Returns the repository path of a schema-governed artifact type's v1 schema file, or $null.
    .DESCRIPTION
        Documentation lookup only; the schema is never evaluated here. Artifact
        `$schema` references are not resolved or fetched by this module any more.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$ArtifactType,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot
    )

    $fileName = Get-DiscoverySchemaFileName -ArtifactType $ArtifactType
    if ($null -eq $fileName) { return $null }
    return "$($RepositoryRoot.TrimEnd('/', '\'))/schemas/discovery/v1/$fileName"
}

function Get-DiscoveryValidationRequiredMessage {
    <#
    .SYNOPSIS
        Returns the validation-required message that directs an artifact question to the authoritative service.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $false)][AllowNull()][AllowEmptyString()][string]$ArtifactType = $null,
        [Parameter(Mandatory = $false)][AllowNull()][AllowEmptyString()][string]$Path = $null
    )

    $subject = $(if ([string]::IsNullOrWhiteSpace($ArtifactType)) { 'the artifact' } else { "the $ArtifactType artifact" })
    if (-not [string]::IsNullOrWhiteSpace($Path)) { $subject = "$subject at $Path" }
    return "$($script:ValidationRequiredPrefix) $subject is validated only by the installed discovery service ($($script:ServiceOperation)); " +
    'this compatibility module no longer evaluates profile or schema semantics and cannot authorize a gate. ' +
    'Native hooks verify the protected validation receipt the gateway writes.'
}

function Add-DiscoveryCompatibilityError {
    <#
    .SYNOPSIS
        Appends the never-empty compatibility errors shared by the retired validation entries to a caller's list.
    .DESCRIPTION
        The version floor is appended alone when the host is below it. Otherwise an
        unrecognized artifact type is appended first (when requested) and the
        validation-required message always follows, so the list is never left empty.
    #>
    [CmdletBinding()]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][System.Collections.Generic.List[string]]$ErrorList,
        [Parameter(Mandatory = $false)][AllowNull()][AllowEmptyString()][string]$ArtifactType = $null,
        [Parameter(Mandatory = $false)][version]$PowerShellVersion = $PSVersionTable.PSVersion,
        [Parameter(Mandatory = $false)][switch]$ReportUnrecognizedType
    )

    $floor = Get-DiscoveryRuntimeVersionError -PowerShellVersion $PowerShellVersion
    if ($null -ne $floor) {
        $ErrorList.Add($floor)
        return
    }
    if ($ReportUnrecognizedType) { $ErrorList.Add("Unrecognized discovery artifact type '$ArtifactType'.") }
    $ErrorList.Add((Get-DiscoveryValidationRequiredMessage -ArtifactType $ArtifactType))
}

function Get-DiscoveryProfileTopLevelKey {
    <#
    .SYNOPSIS
        Compatibility export: profile parsing is retired, so no top-level key is ever reported.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$Text)

    # The text is deliberately not read; the service owns profile semantics.
    $null = $Text
    return [string[]]@()
}

function Get-DiscoveryProfileValidationError {
    <#
    .SYNOPSIS
        Returns the version-floor error below PowerShell 7.4, otherwise the validation-required message for the profile.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Text,
        [Parameter(Mandatory = $false)][version]$PowerShellVersion = $PSVersionTable.PSVersion
    )

    $null = $Text
    $errors = [System.Collections.Generic.List[string]]::new()
    Add-DiscoveryCompatibilityError -ErrorList $errors -ArtifactType 'profile' -PowerShellVersion $PowerShellVersion
    return , $errors.ToArray()
}

function Get-DiscoverySchemaArtifactValidationError {
    <#
    .SYNOPSIS
        Returns the version-floor error below PowerShell 7.4, otherwise the validation-required message for a schema-governed artifact.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Text,
        [Parameter(Mandatory = $false)][AllowNull()][AllowEmptyString()][string]$ArtifactType = $null,
        [Parameter(Mandatory = $false)][version]$PowerShellVersion = $PSVersionTable.PSVersion
    )

    $null = $Text
    $errors = [System.Collections.Generic.List[string]]::new()
    Add-DiscoveryCompatibilityError -ErrorList $errors -ArtifactType $ArtifactType -PowerShellVersion $PowerShellVersion
    return , $errors.ToArray()
}

function Get-DiscoveryArtifactValidationError {
    <#
    .SYNOPSIS
        Returns the compatibility error list for an artifact: the floor, an unrecognized type, and always the validation-required message.
    .DESCRIPTION
        The list is never empty. The version floor is reported alone when the host is
        below it; otherwise an unrecognized artifact type is reported before the
        validation-required message so the caller sees both defects.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$ArtifactType,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Text,
        [Parameter(Mandatory = $false)][version]$PowerShellVersion = $PSVersionTable.PSVersion
    )

    $null = $Text
    $unrecognized = ($ArtifactType -ne 'profile' -and $null -eq (Get-DiscoverySchemaFileName -ArtifactType $ArtifactType))
    $errors = [System.Collections.Generic.List[string]]::new()
    Add-DiscoveryCompatibilityError -ErrorList $errors -ArtifactType $ArtifactType -PowerShellVersion $PowerShellVersion -ReportUnrecognizedType:$unrecognized
    return , $errors.ToArray()
}

function ConvertTo-DiscoveryValidationResult {
    <#
    .SYNOPSIS
        Shapes an error list into the hook seam's `@{ ExitCode; Output }` result.
    .DESCRIPTION
        The defect D-2 contract in one place: an empty list yields `ExitCode = 0` with
        empty `Output`. No entry of this module produces an empty list any more; the
        shape is kept for callers that assemble their own lists.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)][AllowEmptyCollection()][string[]]$ValidationError)

    if (@($ValidationError).Count -eq 0) { return @{ ExitCode = 0; Output = '' } }
    return @{ ExitCode = 1; Output = ($ValidationError -join [System.Environment]::NewLine) }
}

function Invoke-DiscoveryArtifactValidation {
    <#
    .SYNOPSIS
        Compatibility entry of the retired validator: reports the floor, a missing artifact or the validation-required result, never a pass.
    .DESCRIPTION
        `ValidatorArgs` keeps the CLI shape `@(<artifact-type>, <path>)`. The result
        always carries `ExitCode = 1`: the version floor first, then too few
        arguments, then a missing artifact file (actionable), then the
        validation-required message naming the authoritative service.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][string[]]$ValidatorArgs,
        [Parameter(Mandatory = $false)][version]$PowerShellVersion = $PSVersionTable.PSVersion,
        [Parameter(Mandatory = $false)][scriptblock]$TestArtifactPath = { param([string]$Candidate) Test-Path -LiteralPath $Candidate -PathType Leaf }
    )

    $floor = Get-DiscoveryRuntimeVersionError -PowerShellVersion $PowerShellVersion
    if ($null -ne $floor) { return ConvertTo-DiscoveryValidationResult -ValidationError @($floor) }
    if (@($ValidatorArgs).Count -lt 2) {
        return ConvertTo-DiscoveryValidationResult -ValidationError @('Discovery validation requires an artifact type and a path.')
    }
    $artifactType = [string]$ValidatorArgs[0]
    $path = [string]$ValidatorArgs[1]
    if (-not (& $TestArtifactPath $path)) {
        return ConvertTo-DiscoveryValidationResult -ValidationError @("Artifact not found: $path")
    }
    return ConvertTo-DiscoveryValidationResult -ValidationError @((Get-DiscoveryValidationRequiredMessage -ArtifactType $artifactType -Path $path))
}

function Get-DiscoveryValidationAuthority {
    <#
    .SYNOPSIS
        Reports the only authority a native hook consults: the protected activation of the workspace on a supported host.
    .DESCRIPTION
        Status is `active`, `missing`, `inactive`, `invalid` or `unsupported-host`;
        Supported is true only for `active`. The message is actionable in every case
        and names the authoritative service. No artifact is read.
    .OUTPUTS
        [pscustomobject] Status, Supported, Message, Service, Directory.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][string]$WorkspaceRoot,
        [Parameter(Mandatory = $false)][AllowNull()][hashtable]$HostEnvironment = $null,
        [Parameter(Mandatory = $false)][AllowNull()][scriptblock]$ReadText = $null
    )

    try {
        if ($null -eq $HostEnvironment) { $HostEnvironment = Get-DiscoveryTrustedHostEnvironment }
        $location = Resolve-DiscoveryAuthorityLocation -WorkspaceRoot $WorkspaceRoot -Platform $HostEnvironment.Platform `
            -UserHome $HostEnvironment.UserHome -LocalAppData $HostEnvironment.LocalAppData -XdgStateHome $HostEnvironment.XdgStateHome
    } catch {
        return [pscustomobject]@{ Status = 'unsupported-host'; Supported = $false; Service = $script:ServiceOperation; Directory = $null; Message = "$($script:ValidationRequiredPrefix) this host cannot resolve the protected discovery authority ($($_.Exception.Message)); discovery agents are fail-closed here and no artifact can be validated locally." }
    }
    $parameters = @{ Location = $location }
    if ($null -ne $ReadText) { $parameters['ReadText'] = $ReadText }
    $activation = Read-DiscoveryActivationState @parameters
    $message = switch ($activation.Status) {
        'active' { "the workspace holds an active protected activation; run $($script:ServiceOperation) through the installed service to validate artifacts and let the native hooks verify the protected receipt." }
        'missing' { "no protected activation exists for this workspace; initialize or configure discovery through the installed service before any artifact gate can pass." }
        'inactive' { 'discovery was deliberately deactivated for this workspace; only a root-owned activation can restore artifact gates.' }
        default { "the protected activation record is unreadable ($($activation.Reason)); the gate fails closed until the service rewrites it." }
    }
    return [pscustomobject]@{
        Status    = $activation.Status
        Supported = ($activation.Status -eq 'active')
        Service   = $script:ServiceOperation
        Directory = $location.Directory
        Message   = "$($script:ValidationRequiredPrefix) $message"
    }
}

Export-ModuleMember -Function @(
    'Get-DiscoveryRuntimeVersionError',
    'Get-DiscoverySchemaArtifactType',
    'Get-DiscoverySchemaFileName',
    'Get-DiscoveryProfileTopLevelKey',
    'Get-DiscoveryProfileValidationError',
    'Resolve-DiscoverySchemaFilePath',
    'Get-DiscoverySchemaArtifactValidationError',
    'Get-DiscoveryArtifactValidationError',
    'ConvertTo-DiscoveryValidationResult',
    'Invoke-DiscoveryArtifactValidation',
    'Get-DiscoveryValidationRequiredMessage',
    'Get-DiscoveryValidationAuthority'
)
