<#
.SYNOPSIS
    The surface-delta command function: compares the surface inventory, coverage ledger and
    evidence pins of the working tree with the same artifacts at a base revision.

.DESCRIPTION
    Invoke-DocsSurfaceDeltaCommand follows the command function contract: it takes -Argument and
    -Context, returns a New-DocsCommandResult object, writes no output, never exits and never
    reads Context.UtcNow. Working-tree reads go through Context.ReadText and Context.ReadBytes;
    base reads go through Context.ResolveRevision and Context.ReadRevisionText. The comparison and
    the findings are the pure functions of DocsSurfaceDelta.psm1.

    Options: Base (value, required) and Profile (value, default Get-DocsDefaultProfilePath). Base
    is checked before any read: a full revision, or a ref matching ^[A-Za-z0-9][A-Za-z0-9._/-]*$
    with no '..'. Exit 0 when no error finding exists, 1 for any error finding, 2 for a usage
    error (exactly one DOCS_CLI_ARGUMENTS finding, result $null). result is
    {base_revision, added, changed, removed}.

.NOTES
    Issue #1034. Requires PowerShell 7.4 or later. No external module dependencies.
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
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSurfaceDelta.psm1') -ErrorAction Stop

function Invoke-DocsContextMember {
    <#
    .SYNOPSIS
        Invokes one command-context member with positional arguments (private helper).
    .DESCRIPTION
        Members are invoked only through this [scriptblock]-typed parameter, so the call target of
        every context read is verifiable statically.
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter(Mandatory = $true)] [scriptblock] $Member,
        [AllowEmptyCollection()] [object[]] $ArgumentList = @()
    )

    return & $Member @ArgumentList
}

function New-DocsSurfaceDeltaUsageResult {
    <#
    .SYNOPSIS
        Returns an exit-2 surface-delta result with exactly one DOCS_CLI_ARGUMENTS finding (private helper).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)] [string] $Message)

    $finding = New-DocsFinding -Code 'DOCS_CLI_ARGUMENTS' -Severity 'error' -Message $Message -NextAction 'Run Invoke-DocsCommand.ps1 -Help for the surface-delta options.'
    return New-DocsCommandResult -Command 'surface-delta' -ExitCode 2 -Finding @($finding)
}

function Test-DocsSurfaceDeltaBase {
    <#
    .SYNOPSIS
        Returns $true when Base is a full revision or a conservative ref name with no '..' (private helper).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()] [AllowEmptyString()] [string] $Base)

    if (Test-DocsFullRevision -Revision $Base) { return $true }
    return ($null -ne $Base) -and ($Base -cmatch '^[A-Za-z0-9][A-Za-z0-9._/-]*$(?![\s\S])') -and -not $Base.Contains('..')
}

function Read-DocsSurfaceDeltaJson {
    <#
    .SYNOPSIS
        Parses optional artifact text; returns @{ Value; Findings } with Value $null for $null text (private helper).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [AllowNull()] [object] $Text,
        [Parameter(Mandatory = $true)] [string] $ArtifactPath
    )

    if ($null -eq $Text) { return @{ Value = $null; Findings = @() } }
    $parsed = ConvertFrom-DocsJsonText -Text ([string] $Text) -ArtifactPath $ArtifactPath
    if (@($parsed.Findings).Count -gt 0) { return @{ Value = $null; Findings = @($parsed.Findings) } }
    if ($parsed.Value -isnot [System.Collections.IDictionary]) {
        $finding = New-DocsFinding -Code 'DOCS_JSON_INVALID' -Severity 'error' -Message "The artifact $ArtifactPath is not a JSON object." -NextAction 'Regenerate the artifact with its documentation command.' -ArtifactPath $ArtifactPath
        return @{ Value = $null; Findings = @($finding) }
    }
    return @{ Value = $parsed.Value; Findings = @() }
}

function Read-DocsSurfaceDeltaWorkingText {
    <#
    .SYNOPSIS
        Returns the working-tree text of a path through Context.ReadText, or $null when absent (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [object] $Context,
        [Parameter(Mandatory = $true)] [string] $Path
    )

    try { return [string] (Invoke-DocsContextMember -Member $Context.ReadText -ArgumentList @($Path)) } catch [System.Management.Automation.ItemNotFoundException] { return $null }
}

function Get-DocsSurfaceDeltaStaleInput {
    <#
    .SYNOPSIS
        Returns the head snapshot inputs whose working-tree digest (Get-DocsTextSha256Hex, line endings normalized) differs from the recorded one (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string[]], [object[]])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Snapshot,
        [Parameter(Mandatory = $true)] [object] $Context
    )

    $stale = [System.Collections.Generic.List[string]]::new()
    $inputs = if ($Snapshot.Contains('inputs') -and $null -ne $Snapshot['inputs']) { @($Snapshot['inputs']) } else { @() }
    foreach ($item in $inputs) {
        if ($item -isnot [System.Collections.IDictionary]) { continue }
        $path = [string] $item['path']
        if (-not (Test-DocsRelativePath -Path $path)) { $stale.Add($path); continue }
        if (-not [bool] (Invoke-DocsContextMember -Member $Context.TestFile -ArgumentList @($path))) { $stale.Add($path); continue }
        $digest = Get-DocsTextSha256Hex -Bytes ([byte[]] (Invoke-DocsContextMember -Member $Context.ReadBytes -ArgumentList @($path)))
        if (-not [string]::Equals($digest, [string] $item['sha256'], [System.StringComparison]::Ordinal)) { $stale.Add($path) }
    }
    return , $stale.ToArray()
}

function Invoke-DocsSurfaceDeltaCommand {
    <#
    .SYNOPSIS
        Reports added and changed surface elements that carry no coverage ledger change.
    .DESCRIPTION
        Reads the profile, resolves Base through Context.ResolveRevision (an unresolved base is
        DOCS_SURFACE_BASE_UNRESOLVED), reads the head snapshot, ledger and pins at the profile
        artifact_paths through Context.ReadText and the base copies through
        Context.ReadRevisionText, checks the head snapshot inputs against Context.ReadBytes, and
        returns the findings of Get-DocsSurfaceDeltaFinding. An absent profile is
        DOCS_PROFILE_MISSING (exit 1). An uncomposable schema set throws, which the entry
        boundary reports as exit 3 with DOCS_CLI_RUNTIME.
    .PARAMETER Argument
        The parsed options: Base and optional Profile.
    .PARAMETER Context
        The command context.
    .OUTPUTS
        System.Management.Automation.PSCustomObject (New-DocsCommandResult)
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Argument,
        [Parameter(Mandatory = $true)] [object] $Context
    )

    $base = if ($Argument.Contains('Base') -and $null -ne $Argument['Base']) { [string] $Argument['Base'] } else { $null }
    if ($null -eq $base) { return New-DocsSurfaceDeltaUsageResult -Message 'The -Base option is required.' }
    if (-not (Test-DocsSurfaceDeltaBase -Base $base)) { return New-DocsSurfaceDeltaUsageResult -Message "Base '$base' is not a full revision or a ref name matching ^[A-Za-z0-9][A-Za-z0-9._/-]*$ without '..'." }
    $profilePath = if ($Argument.Contains('Profile') -and $null -ne $Argument['Profile']) { [string] $Argument['Profile'] } else { Get-DocsDefaultProfilePath }
    if (-not (Test-DocsRelativePath -Path $profilePath)) { return New-DocsSurfaceDeltaUsageResult -Message "Profile '$profilePath' is not a repository-relative path." }

    $profileText = Read-DocsSurfaceDeltaWorkingText -Context $Context -Path $profilePath
    if ($null -eq $profileText) {
        $missing = New-DocsFinding -Code 'DOCS_PROFILE_MISSING' -Severity 'error' -Message "The profile $profilePath does not exist." -NextAction 'Run Invoke-DocsCommand.ps1 -Command init -Write, or pass -Profile with an existing profile.' -ArtifactPath $profilePath
        return New-DocsCommandResult -Command 'surface-delta' -ExitCode 1 -Finding @($missing)
    }
    $composed = Get-DocsComposedSchemaSet -SchemaSet (Read-DocsSchemaSet)
    if (@($composed.Findings).Count -gt 0) { throw "DOCS_SCHEMA_COMPOSITION_FAILED: $($composed.Findings[0]['code'])" }
    $check = ConvertFrom-DocsProfileText -Text $profileText -ArtifactPath $profilePath -ComposedSchemaSet $composed.Schemas
    if (-not $check.Ok -or $null -eq $check.Profile) { return New-DocsCommandResult -Command 'surface-delta' -ExitCode 1 -Finding $check.Findings }
    $paths = $check.Profile['artifact_paths']
    $snapshotPath = [string] $paths['inventory_snapshot']
    $ledgerPath = [string] $paths['coverage_ledger']
    $pinsPath = [string] $paths['evidence_pins']

    $revision = Invoke-DocsContextMember -Member $Context.ResolveRevision -ArgumentList @($base)
    $result = [ordered]@{ base_revision = $null; added = [string[]]@(); changed = [string[]]@(); removed = [string[]]@() }
    if ($null -eq $revision) {
        $outcome = Get-DocsSurfaceDeltaFinding -BaseRef $base -BaseResolved $false
        return New-DocsCommandResult -Command 'surface-delta' -ExitCode 1 -Finding $outcome.Findings -Result $result -Line @("surface-delta: base '$base' unresolved")
    }
    $result['base_revision'] = [string] $revision

    $parseFindings = [System.Collections.Generic.List[object]]::new()
    $artifact = @{}
    foreach ($name in 'snapshot', 'ledger', 'pins') {
        $path = switch ($name) { 'snapshot' { $snapshotPath } 'ledger' { $ledgerPath } default { $pinsPath } }
        $head = Read-DocsSurfaceDeltaJson -Text (Read-DocsSurfaceDeltaWorkingText -Context $Context -Path $path) -ArtifactPath $path
        $baseCopy = Read-DocsSurfaceDeltaJson -Text (Invoke-DocsContextMember -Member $Context.ReadRevisionText -ArgumentList @([string] $revision, $path)) -ArtifactPath $path
        foreach ($finding in @($head.Findings) + @($baseCopy.Findings)) { if ($null -ne $finding) { $parseFindings.Add($finding) } }
        $artifact["head-$name"] = $head.Value
        $artifact["base-$name"] = $baseCopy.Value
    }
    if ($parseFindings.Count -gt 0) { return New-DocsCommandResult -Command 'surface-delta' -ExitCode 1 -Finding (Get-DocsOrderedFinding -Finding $parseFindings.ToArray()) -Result $result }

    [string[]] $stale = @()
    if ($null -ne $artifact['head-snapshot']) { $stale = Get-DocsSurfaceDeltaStaleInput -Snapshot $artifact['head-snapshot'] -Context $Context }
    $outcome = Get-DocsSurfaceDeltaFinding -BaseSnapshot $artifact['base-snapshot'] -HeadSnapshot $artifact['head-snapshot'] -BaseLedger $artifact['base-ledger'] -HeadLedger $artifact['head-ledger'] -BasePins $artifact['base-pins'] -HeadPins $artifact['head-pins'] -BaseRef $base -SnapshotPath $snapshotPath -StaleInputPath $stale
    if ($null -ne $outcome.Delta) {
        $result['added'] = [string[]] $outcome.Delta['added']
        $result['changed'] = [string[]] $outcome.Delta['changed']
        $result['removed'] = [string[]] $outcome.Delta['removed']
    }
    $exitCode = if (Test-DocsFindingHasError -Finding $outcome.Findings) { 1 } else { 0 }
    $line = "surface-delta: base=$revision added=$(@($result['added']).Count) changed=$(@($result['changed']).Count) removed=$(@($result['removed']).Count)"
    return New-DocsCommandResult -Command 'surface-delta' -ExitCode $exitCode -Finding $outcome.Findings -Result $result -Line @($line)
}

Export-ModuleMember -Function Invoke-DocsSurfaceDeltaCommand
