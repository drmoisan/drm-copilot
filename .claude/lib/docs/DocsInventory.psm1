<#
.SYNOPSIS
    The inventory command function of issue #1022: Invoke-DocsInventoryCommand builds the
    surface-inventory-snapshot through the 1020 command context.

.DESCRIPTION
    Invoke-DocsInventoryCommand -Argument -Context follows the command function contract: it
    returns a New-DocsCommandResult object, writes no output and never exits. It is the only
    1022 function that uses the command context, and only through Context.ReadText,
    Context.ReadBytes, Context.ListFile, Context.UtcNow and Context.WriteText, each invoked
    through the [scriptblock] parameter of Invoke-DocsContextMember. Flow: read and validate the
    profile (absent: exit 1 with DOCS_PROFILE_MISSING; findings: exit 1, no snapshot); validate
    -Revision (invalid: exit 2); select registry rows with Select-DocsAnalyzerRegistration (an
    unknown -Analyzer identifier, or one producing none of the selected element kinds: exit 2);
    list the source roots and apply Get-DocsInventorySelection; apply the aggregate bounds (exit
    3); read each selected file with ReadBytes into New-DocsCapturedInput -MaxBytes 1048576;
    invoke each selected row with Invoke-DocsAnalyzer; build the snapshot with
    New-DocsInventorySnapshot and Context.UtcNow and self-validate it (a failure is a defect guard,
    exit 3); without -Write nothing is written, with -Write the indented snapshot text goes to
    artifact_paths.inventory_snapshot through WriteText (overwrite when the file exists, else
    create). Exit 1 with one DOCS_INVENTORY_BLOCKING_DIAGNOSTIC finding per blocking diagnostic
    (related_paths its path), else exit 0; result is {snapshot, snapshot_path, written}.

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
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSchema.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsProfile.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsAnalyzerRegistry.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsInventorySnapshot.psm1') -ErrorAction Stop

$script:DocsInventoryCommandName = 'inventory'
$script:DocsInventoryMaxInputBytes = 1048576

function Invoke-DocsContextMember {
    <#
    .SYNOPSIS
        Invokes one command-context member with positional arguments (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object], [object[]])]
    param(
        [Parameter(Mandatory = $true)] [scriptblock] $Member,
        [AllowEmptyCollection()] [object[]] $ArgumentList = @()
    )

    # The comma keeps an array result (ReadBytes, ListFile) as one object; a scalar is unaffected.
    return , (& $Member @ArgumentList)
}

function New-DocsInventoryFinding {
    <#
    .SYNOPSIS
        Builds one error finding for the inventory result (private helper).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [string] $Code,
        [Parameter(Mandatory = $true)] [string] $Message,
        [Parameter(Mandatory = $true)] [string] $NextAction,
        [AllowNull()] [string] $ArtifactPath,
        [AllowNull()] [AllowEmptyCollection()] [string[]] $RelatedPath
    )

    return New-DocsFinding -Code $Code -Severity 'error' -Message $Message -NextAction $NextAction -ArtifactPath $ArtifactPath -RelatedPath $RelatedPath
}

function New-DocsInventoryExitResult {
    <#
    .SYNOPSIS
        Returns an exit-2 (usage) or exit-3 (runtime) result with exactly one finding (private helper).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [ValidateSet(2, 3)] [int] $ExitCode,
        [Parameter(Mandatory = $true)] [string] $Message
    )

    $finding = if ($ExitCode -eq 2) {
        New-DocsInventoryFinding -Code 'DOCS_CLI_ARGUMENTS' -Message $Message -NextAction "Run Invoke-DocsCommand.ps1 -Help for the $($script:DocsInventoryCommandName) options."
    } else {
        New-DocsInventoryFinding -Code 'DOCS_CLI_RUNTIME' -Message $Message -NextAction 'Correct the reported condition and run the command again.'
    }
    return New-DocsCommandResult -Command $script:DocsInventoryCommandName -ExitCode $ExitCode -Finding @($finding)
}

function Get-DocsInventoryArgumentValue {
    <#
    .SYNOPSIS
        Returns an option value from the parsed argument map, or Default (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Argument,
        [Parameter(Mandatory = $true)] [string] $Name,
        [AllowNull()] [object] $Default
    )

    if ($Argument.Contains($Name) -and $null -ne $Argument[$Name]) { return $Argument[$Name] }
    return $Default
}

function Read-DocsInventoryText {
    <#
    .SYNOPSIS
        Reads a repository file through Context.ReadText; returns @{ Text; Exists } (private helper).
    .DESCRIPTION
        An item-not-found error means the file is absent (Exists $false); any other error is
        rethrown so that the caller reports exit 3.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [object] $Context,
        [Parameter(Mandatory = $true)] [string] $Path
    )

    try {
        $text = [string] (Invoke-DocsContextMember -Member $Context.ReadText -ArgumentList @($Path))
        return @{ Text = $text; Exists = $true }
    } catch [System.Management.Automation.ItemNotFoundException] {
        return @{ Text = $null; Exists = $false }
    }
}

function Select-DocsInventoryRow {
    <#
    .SYNOPSIS
        Selects the registry rows for the run; returns @{ Rows; Error } (private helper).
    .DESCRIPTION
        With -Analyzer the identifiers come from the arguments; otherwise from
        surface_selection.analyzers when present, else every row covering a selected kind. An
        unknown identifier, or a requested identifier whose row covers none of the selected
        element kinds, sets Error to the usage message naming it.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Profile,
        [AllowNull()] [AllowEmptyCollection()] [string[]] $AnalyzerId
    )

    $selection = $Profile['surface_selection']
    [string[]] $kinds = @($selection['element_kinds'])
    $requested = $AnalyzerId
    if ($null -eq $requested -or $requested.Count -eq 0) {
        $requested = if ($selection.Contains('analyzers') -and $null -ne $selection['analyzers']) { [string[]]@($selection['analyzers']) } else { $null }
    }
    $registration = Get-DocsAnalyzerRegistration
    $selected = Select-DocsAnalyzerRegistration -Registration $registration -ElementKind $kinds -AnalyzerId $requested
    if ($selected.Findings.Count -gt 0) { return @{ Rows = [object[]]@(); Error = [string] $selected.Findings[0]['message'] } }
    if ($null -ne $AnalyzerId -and $AnalyzerId.Count -gt 0) {
        foreach ($row in $selected.Rows) {
            if (@(@($row.ElementKinds) | Where-Object { $kinds -ccontains [string] $_ }).Count -eq 0) {
                return @{ Rows = [object[]]@(); Error = "Analyzer '$($row.Id)' produces none of the element kinds selected by the profile." }
            }
        }
    }
    return @{ Rows = [object[]]@($selected.Rows); Error = $null }
}

function Invoke-DocsInventoryCommand {
    <#
    .SYNOPSIS
        Builds, and with -Write writes, the surface-inventory-snapshot for the profile.
    .DESCRIPTION
        Options: Profile (value), Analyzer (multi), Revision (value), Write (switch). Exit 0:
        snapshot built with no blocking diagnostic; 1: blocking diagnostics (one
        DOCS_INVENTORY_BLOCKING_DIAGNOSTIC each), or an absent or invalid profile (no snapshot);
        2: usage error (one DOCS_CLI_ARGUMENTS, result null); 3: runtime failure (one
        DOCS_CLI_RUNTIME, result null).
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Argument,
        [Parameter(Mandatory = $true)] [object] $Context
    )

    $name = $script:DocsInventoryCommandName
    $profilePath = [string] (Get-DocsInventoryArgumentValue -Argument $Argument -Name 'Profile' -Default (Get-DocsDefaultProfilePath))
    $revision = Get-DocsInventoryArgumentValue -Argument $Argument -Name 'Revision' -Default $null
    [string[]] $analyzerIds = @(Get-DocsInventoryArgumentValue -Argument $Argument -Name 'Analyzer' -Default @())
    $write = [bool] (Get-DocsInventoryArgumentValue -Argument $Argument -Name 'Write' -Default $false)
    if (-not (Test-DocsRelativePath -Path $profilePath)) { return New-DocsInventoryExitResult -ExitCode 2 -Message "Profile '$profilePath' is not a repository-relative path." }
    if ($null -ne $revision -and -not (Test-DocsFullRevision -Revision ([string] $revision))) { return New-DocsInventoryExitResult -ExitCode 2 -Message "Revision '$revision' is not a full object id (40 or 64 lowercase hex characters)." }

    try {
        $composed = Get-DocsComposedSchemaSet -SchemaSet (Read-DocsSchemaSet)
        if (@($composed.Findings).Count -gt 0) { return New-DocsInventoryExitResult -ExitCode 3 -Message "The runtime schemas could not be composed: $($composed.Findings[0]['code'])." }
        $schemas = $composed.Schemas

        $profileRead = Read-DocsInventoryText -Context $Context -Path $profilePath
        if (-not $profileRead.Exists) {
            $finding = New-DocsInventoryFinding -Code 'DOCS_PROFILE_MISSING' -Message "The profile $profilePath does not exist." -NextAction 'Run Invoke-DocsCommand.ps1 -Command init -Write, or pass -Profile with an existing profile.' -ArtifactPath $profilePath
            return New-DocsCommandResult -Command $name -ExitCode 1 -Finding @($finding)
        }
        $check = ConvertFrom-DocsProfileText -Text $profileRead.Text -ArtifactPath $profilePath -ComposedSchemaSet $schemas
        if (-not $check.Ok) { return New-DocsCommandResult -Command $name -ExitCode 1 -Finding $check.Findings }
        $docsProfile = $check.Profile

        $rows = Select-DocsInventoryRow -Profile $docsProfile -AnalyzerId $analyzerIds
        if ($null -ne $rows.Error) { return New-DocsInventoryExitResult -ExitCode 2 -Message $rows.Error }

        $selection = $docsProfile['surface_selection']
        $listed = [System.Collections.Generic.List[string]]::new()
        foreach ($root in @($selection['source_roots'])) {
            $rootPaths = Invoke-DocsContextMember -Member $Context.ListFile -ArgumentList @([string] $root)
            foreach ($path in @($rootPaths)) { if ($null -ne $path) { $listed.Add([string] $path) } }
        }
        $selected = Get-DocsInventorySelection -Path $listed.ToArray() -SourceRoot ([string[]]@($selection['source_roots'])) -Exclusion @($selection['exclusions'])
        $bound = Get-DocsInventoryBoundFinding -InputCount $selected.Paths.Count -TotalBytes 0
        if ($null -ne $bound) { return New-DocsCommandResult -Command $name -ExitCode 3 -Finding @($bound) }

        $captured = [System.Collections.Generic.List[object]]::new()
        [long] $totalBytes = 0
        foreach ($path in $selected.Paths) {
            [byte[]] $bytes = Invoke-DocsContextMember -Member $Context.ReadBytes -ArgumentList @($path)
            $totalBytes += $bytes.Length
            $bound = Get-DocsInventoryBoundFinding -InputCount $selected.Paths.Count -TotalBytes $totalBytes
            if ($null -ne $bound) { return New-DocsCommandResult -Command $name -ExitCode 3 -Finding @($bound) }
            $captured.Add((New-DocsCapturedInput -Path $path -Bytes $bytes -MaxBytes $script:DocsInventoryMaxInputBytes))
        }

        $outputs = [System.Collections.Generic.List[object]]::new()
        foreach ($row in $rows.Rows) {
            $result = Invoke-DocsAnalyzer -Registration $row -CapturedInput $captured.ToArray() -Selection $selection
            if (@($result.Findings).Count -gt 0) { return New-DocsInventoryExitResult -ExitCode 3 -Message "The analyzer '$($row.Id)' returned output outside the analyzer contract: $($result.Findings[0]['message'])" }
            $outputs.Add(@{ Elements = $result.Elements; Diagnostics = $result.Diagnostics })
        }

        $capturedAt = [datetime] (Invoke-DocsContextMember -Member $Context.UtcNow)
        $snapshot = New-DocsInventorySnapshot -Profile $docsProfile -Revision $revision -Registration $rows.Rows -CapturedInput $captured.ToArray() -AnalyzerOutput $outputs.ToArray() -Diagnostic $selected.Diagnostics -CapturedAt $capturedAt
        $snapshotText = ConvertTo-DocsJsonText -Value $snapshot -Indented
        $snapshotPath = [string] $docsProfile['artifact_paths']['inventory_snapshot']
        $validation = Test-DocsArtifactText -ArtifactKind 'surface-inventory-snapshot' -JsonText $snapshotText -ComposedSchemaSet $schemas -ArtifactPath $snapshotPath
        if ($validation.Count -gt 0) { return New-DocsInventoryExitResult -ExitCode 3 -Message "The built snapshot failed its own validation: $($validation[0]['code']) $($validation[0]['message'])" }

        $written = $false
        if ($write) {
            $existing = Read-DocsInventoryText -Context $Context -Path $snapshotPath
            $mode = if ($existing.Exists) { 'overwrite' } else { 'create' }
            [void] (Invoke-DocsContextMember -Member $Context.WriteText -ArgumentList @($snapshotPath, $snapshotText, $mode))
            $written = $true
        }

        $findings = [System.Collections.Generic.List[object]]::new()
        foreach ($diagnostic in @($snapshot['diagnostics'])) {
            if (-not [bool] $diagnostic['blocking']) { continue }
            $diagnosticPath = [string] $diagnostic['path']
            $related = if ([string]::IsNullOrEmpty($diagnosticPath)) { [string[]]@() } else { [string[]]@($diagnosticPath) }
            $location = if ([string]::IsNullOrEmpty($diagnosticPath)) { 'the run' } else { $diagnosticPath }
            $findings.Add((New-DocsInventoryFinding -Code 'DOCS_INVENTORY_BLOCKING_DIAGNOSTIC' -Message "The analyzer $($diagnostic['analyzer_id']) reported the blocking diagnostic $($diagnostic['code']) for $location." -NextAction 'Resolve the diagnostic in the source, or exclude the path in surface_selection.exclusions, then run the command again.' -RelatedPath $related))
        }
        $exitCode = if ($findings.Count -gt 0) { 1 } else { 0 }
        $commandResult = [ordered]@{ snapshot = $snapshot; snapshot_path = $snapshotPath; written = $written }
        $line = "$name $snapshotPath" + ": inputs=$(@($snapshot['inputs']).Count) elements=$(@($snapshot['elements']).Count) diagnostics=$(@($snapshot['diagnostics']).Count) written=$($written.ToString().ToLowerInvariant())"
        return New-DocsCommandResult -Command $name -ExitCode $exitCode -Finding $findings.ToArray() -Result $commandResult -Line @($line)
    } catch {
        return New-DocsInventoryExitResult -ExitCode 3 -Message "The inventory failed: $($_.Exception.Message)"
    }
}

Export-ModuleMember -Function Invoke-DocsInventoryCommand
