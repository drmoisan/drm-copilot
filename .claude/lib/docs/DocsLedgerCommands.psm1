<#
.SYNOPSIS
    The coverage and update-ledger command functions of the documentation library, their
    argument validator, the input loader, and the shared private helpers of the ledger commands.

.DESCRIPTION
    The argument validator checks value grammars and the per-operation option sets before any
    read and returns one DOCS_CLI_ARGUMENTS finding or $null. Read-DocsLedgerInputSet reads the
    artifacts a command needs through scriptblock parameters (an absent artifact is $null; a
    read failure other than absence propagates). The command functions take -Argument and
    -Context, return a New-DocsCommandResult object, write no output and never exit. Context
    members are passed to [scriptblock] parameters and never invoked through a member
    expression; only update-ledger passes WriteText here, and only to Invoke-DocsArtifactWrite.
    Identifier and path comparisons are ordinal and case-sensitive. The validate command lives in
    DocsValidateCommands.psm1 (issue #1169), which calls the private helpers this module exports
    for it (Get-DocsLedgerCommandMember through Read-DocsLedgerCommandProfile in the export list).

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
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsValidation.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedgerMutation.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsCoverageReport.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedgerBindRefs.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedgerBatch.psm1') -ErrorAction Stop

$script:DocsLedgerCommandIdentifierPattern = '^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$(?![\s\S])'
$script:DocsLedgerCommandActorKind = [string[]]@('human', 'agent', 'tool')
$script:DocsLedgerCommandDisposition = [string[]]@('documented', 'excluded', 'deferred')
$script:DocsLedgerCommandState = [string[]]@('pass', 'fail', 'not-assessed', 'not-applicable')
$script:DocsLedgerCommandCommonOption = [string[]]@('Profile', 'Operation', 'ActorKind', 'ActorId', 'Write')
# Target: either (exactly one of Element and Limit), element (Element only), none (neither).
$script:DocsLedgerCommandOperation = [ordered]@{
    'set-disposition' = @{ Required = [string[]]@('Disposition'); Optional = [string[]]@('Page', 'Rationale', 'Owner', 'Target'); Target = 'either'; OnePage = $false }
    'remove-entry'    = @{ Required = [string[]]@(); Optional = [string[]]@(); Target = 'either'; OnePage = $false }
    'pin'             = @{ Required = [string[]]@('Page'); Optional = [string[]]@('Claim'); Target = 'element'; OnePage = $true }
    'unpin'           = @{ Required = [string[]]@('Page'); Optional = [string[]]@(); Target = 'element'; OnePage = $true }
    'set-dimension'   = @{ Required = [string[]]@('Page', 'Dimension', 'State'); Optional = [string[]]@('Rationale'); Target = 'element'; OnePage = $true }
    'sync-refs'       = @{ Required = [string[]]@(); Optional = [string[]]@(); Target = 'none'; OnePage = $false }
    'bind-page-refs'  = @{ Required = [string[]]@(); Optional = [string[]]@(); Target = 'none'; OnePage = $false }
}
$script:DocsLedgerCommandArtifactPathKey = @{
    'surface-inventory-snapshot' = 'inventory_snapshot'
    'docs-coverage-ledger'       = 'coverage_ledger'
    'docs-parity-matrix'         = 'parity_matrix'
    'docs-evidence-pin'          = 'evidence_pins'
    'docs-validation-receipt'    = 'validation_receipt'
}

function Get-DocsLedgerCommandMember {
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

function Test-DocsLedgerCommandOption {
    <#
    .SYNOPSIS
        Returns $true when the argument map carries a non-null value for Name (private helper).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Argument,
        [Parameter(Mandatory = $true)] [string] $Name
    )

    return $Argument.Contains($Name) -and $null -ne $Argument[$Name]
}

function New-DocsLedgerCommandUsageFinding {
    <#
    .SYNOPSIS
        Returns one DOCS_CLI_ARGUMENTS error finding (private helper).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [string] $Command,
        [Parameter(Mandatory = $true)] [string] $Message
    )

    return New-DocsFinding -Code 'DOCS_CLI_ARGUMENTS' -Severity 'error' -Message $Message -NextAction "Run Invoke-DocsCommand.ps1 -Help for the $Command options."
}

function Get-DocsLedgerCommandPageBinding {
    <#
    .SYNOPSIS
        Parses one -Page value '<relative path>[#<anchor>]' into @{ page_path; anchor }, or $null when invalid (private helper).
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([AllowNull()] [AllowEmptyString()] [string] $Value)

    if ([string]::IsNullOrEmpty($Value)) { return $null }
    $separator = $Value.IndexOf('#')
    $path = if ($separator -lt 0) { $Value } else { $Value.Substring(0, $separator) }
    $anchor = if ($separator -lt 0) { $null } else { $Value.Substring($separator + 1) }
    if (-not (Test-DocsRelativePath -Path $path)) { return $null }
    if ($separator -ge 0 -and [string]::IsNullOrWhiteSpace($anchor)) { return $null }
    return [ordered]@{ page_path = $path; anchor = $anchor }
}

function Test-DocsUpdateLedgerArgument {
    <#
    .SYNOPSIS
        Returns one DOCS_CLI_ARGUMENTS finding for an invalid update-ledger argument map, or $null when it is valid.
    .DESCRIPTION
        Checks, before any read: the relative Profile path; the Operation, ActorKind, Disposition,
        Dimension and State enumerations; the ActorId and Owner identifiers; every option inside
        the operation's set and every required option present; Element xor Limit per operation;
        the Element id, the diagnostic- prefixed Limit id, non-blank text values, and every Page
        as '<relative path>[#<anchor>]' (not repeated; exactly one without an anchor for pin,
        unpin and set-dimension); Limit with a Disposition other than deferred is rejected.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Argument)

    $command = 'update-ledger'
    if ((Test-DocsLedgerCommandOption -Argument $Argument -Name 'Profile') -and -not (Test-DocsRelativePath -Path ([string] $Argument['Profile']))) { return New-DocsLedgerCommandUsageFinding -Command $command -Message "Profile '$($Argument['Profile'])' is not a repository-relative path." }
    if (-not (Test-DocsLedgerCommandOption -Argument $Argument -Name 'Operation')) { return New-DocsLedgerCommandUsageFinding -Command $command -Message 'The -Operation option is required.' }
    $operation = [string] $Argument['Operation']
    if (-not $script:DocsLedgerCommandOperation.Contains($operation)) { return New-DocsLedgerCommandUsageFinding -Command $command -Message "Operation '$operation' is not one of $(@($script:DocsLedgerCommandOperation.Keys) -join ', ')." }
    $spec = $script:DocsLedgerCommandOperation[$operation]
    if (-not (Test-DocsLedgerCommandOption -Argument $Argument -Name 'ActorKind')) { return New-DocsLedgerCommandUsageFinding -Command $command -Message 'The -ActorKind option is required.' }
    if ($script:DocsLedgerCommandActorKind -cnotcontains [string] $Argument['ActorKind']) { return New-DocsLedgerCommandUsageFinding -Command $command -Message "ActorKind '$($Argument['ActorKind'])' is not one of $($script:DocsLedgerCommandActorKind -join ', ')." }
    if (-not (Test-DocsLedgerCommandOption -Argument $Argument -Name 'ActorId')) { return New-DocsLedgerCommandUsageFinding -Command $command -Message 'The -ActorId option is required.' }
    if ([string] $Argument['ActorId'] -cnotmatch $script:DocsLedgerCommandIdentifierPattern) { return New-DocsLedgerCommandUsageFinding -Command $command -Message "ActorId '$($Argument['ActorId'])' is not an identifier." }

    $permitted = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($name in $script:DocsLedgerCommandCommonOption + $spec.Required + $spec.Optional) { [void]$permitted.Add($name) }
    if ($spec.Target -ceq 'either') { [void]$permitted.Add('Element'); [void]$permitted.Add('Limit') }
    if ($spec.Target -ceq 'element') { [void]$permitted.Add('Element') }
    foreach ($name in @($Argument.Keys)) {
        if ($null -eq $Argument[$name]) { continue }
        if (-not $permitted.Contains([string] $name)) { return New-DocsLedgerCommandUsageFinding -Command $command -Message "Option '-$name' is not accepted by the operation '$operation'." }
    }
    foreach ($name in $spec.Required) {
        if (-not (Test-DocsLedgerCommandOption -Argument $Argument -Name $name)) { return New-DocsLedgerCommandUsageFinding -Command $command -Message "The operation '$operation' requires -$name." }
    }
    $hasElement = Test-DocsLedgerCommandOption -Argument $Argument -Name 'Element'
    $hasLimit = Test-DocsLedgerCommandOption -Argument $Argument -Name 'Limit'
    if ($spec.Target -ceq 'either') {
        if ($hasElement -and $hasLimit) { return New-DocsLedgerCommandUsageFinding -Command $command -Message '-Element and -Limit cannot both be given.' }
        if (-not $hasElement -and -not $hasLimit) { return New-DocsLedgerCommandUsageFinding -Command $command -Message "The operation '$operation' requires -Element or -Limit." }
    }
    if ($spec.Target -ceq 'element' -and -not $hasElement) { return New-DocsLedgerCommandUsageFinding -Command $command -Message "The operation '$operation' requires -Element." }
    if ($hasElement -and -not (Test-DocsElementId -ElementId ([string] $Argument['Element']))) { return New-DocsLedgerCommandUsageFinding -Command $command -Message "Element '$($Argument['Element'])' is not an element id." }
    if ($hasLimit) {
        $limit = [string] $Argument['Limit']
        if ($limit -cnotmatch $script:DocsLedgerCommandIdentifierPattern -or -not $limit.StartsWith('diagnostic-', [System.StringComparison]::Ordinal)) { return New-DocsLedgerCommandUsageFinding -Command $command -Message "Limit '$limit' is not a diagnostic identifier." }
        if ((Test-DocsLedgerCommandOption -Argument $Argument -Name 'Disposition') -and [string] $Argument['Disposition'] -cne 'deferred') { return New-DocsLedgerCommandUsageFinding -Command $command -Message '-Limit requires -Disposition deferred.' }
    }
    if ((Test-DocsLedgerCommandOption -Argument $Argument -Name 'Disposition') -and $script:DocsLedgerCommandDisposition -cnotcontains [string] $Argument['Disposition']) { return New-DocsLedgerCommandUsageFinding -Command $command -Message "Disposition '$($Argument['Disposition'])' is not one of $($script:DocsLedgerCommandDisposition -join ', ')." }
    if ((Test-DocsLedgerCommandOption -Argument $Argument -Name 'Dimension') -and (Get-DocsParityDimension) -cnotcontains [string] $Argument['Dimension']) { return New-DocsLedgerCommandUsageFinding -Command $command -Message "Dimension '$($Argument['Dimension'])' is not one of $((Get-DocsParityDimension) -join ', ')." }
    if ((Test-DocsLedgerCommandOption -Argument $Argument -Name 'State') -and $script:DocsLedgerCommandState -cnotcontains [string] $Argument['State']) { return New-DocsLedgerCommandUsageFinding -Command $command -Message "State '$($Argument['State'])' is not one of $($script:DocsLedgerCommandState -join ', ')." }
    if ((Test-DocsLedgerCommandOption -Argument $Argument -Name 'Owner') -and [string] $Argument['Owner'] -cnotmatch $script:DocsLedgerCommandIdentifierPattern) { return New-DocsLedgerCommandUsageFinding -Command $command -Message "Owner '$($Argument['Owner'])' is not an identifier." }
    foreach ($name in 'Rationale', 'Target', 'Claim') {
        if ((Test-DocsLedgerCommandOption -Argument $Argument -Name $name) -and [string]::IsNullOrWhiteSpace([string] $Argument[$name])) { return New-DocsLedgerCommandUsageFinding -Command $command -Message "-$name must contain a non-whitespace character." }
    }
    if (Test-DocsLedgerCommandOption -Argument $Argument -Name 'Page') {
        $pages = [string[]]@($Argument['Page'])
        $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
        foreach ($value in $pages) {
            $binding = Get-DocsLedgerCommandPageBinding -Value $value
            if ($null -eq $binding) { return New-DocsLedgerCommandUsageFinding -Command $command -Message "Page '$value' is not '<relative path>' or '<relative path>#<anchor>'." }
            if (-not $seen.Add($value)) { return New-DocsLedgerCommandUsageFinding -Command $command -Message "Page '$value' is given more than once." }
            if ($spec.OnePage -and $null -ne $binding['anchor']) { return New-DocsLedgerCommandUsageFinding -Command $command -Message "The operation '$operation' takes a page path without an anchor." }
        }
        if ($spec.OnePage -and $pages.Count -ne 1) { return New-DocsLedgerCommandUsageFinding -Command $command -Message "The operation '$operation' takes exactly one -Page." }
    }
    return $null
}

function Read-DocsLedgerInputSet {
    <#
    .SYNOPSIS
        Reads the artifacts named by Need through the scriptblocks; returns @{ Artifact; PagePath }.
    .DESCRIPTION
        Artifact maps each needed artifact kind to @{ Path; Bytes } (the profile artifact_paths
        entry and its raw bytes) or $null when TestFile reports the path absent or ReadBytes
        throws an item-not-found error; any other read failure propagates. PagePath is the
        ordinal-sorted union of ListFile over each documentation_roots[].path when Need holds
        page-path-set, otherwise empty. The docs-profile kind is ignored (the caller reads it).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Profile,
        [AllowNull()] [AllowEmptyCollection()] [string[]] $Need,
        [Parameter(Mandatory = $true)] [scriptblock] $ReadBytes,
        [Parameter(Mandatory = $true)] [scriptblock] $TestFile,
        [Parameter(Mandatory = $true)] [scriptblock] $ListFile
    )

    $artifact = [ordered]@{}
    $paths = Get-DocsLedgerCommandMember -Table $Profile -Name 'artifact_paths'
    foreach ($kind in @($Need | Where-Object { $null -ne $_ })) {
        if (-not $script:DocsLedgerCommandArtifactPathKey.ContainsKey($kind)) { continue }
        $path = [string] (Get-DocsLedgerCommandMember -Table $paths -Name ([string] $script:DocsLedgerCommandArtifactPathKey[$kind]))
        $entry = $null
        if ([bool] (& $TestFile $path)) {
            try {
                $entry = @{ Path = $path; Bytes = [byte[]] (& $ReadBytes $path) }
            } catch [System.Management.Automation.ItemNotFoundException] {
                $entry = $null
            }
        }
        $artifact[$kind] = $entry
    }
    $pages = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::Ordinal)
    if (@($Need) -ccontains 'page-path-set') {
        foreach ($documentationRoot in @(Get-DocsLedgerCommandMember -Table $Profile -Name 'documentation_roots')) {
            $rootPath = [string] (Get-DocsLedgerCommandMember -Table $documentationRoot -Name 'path')
            $listed = & $ListFile $rootPath
            foreach ($page in @($listed)) { if ($page -is [string]) { [void]$pages.Add($page) } }
        }
    }
    return @{ Artifact = $artifact; PagePath = [string[]]@($pages) }
}

function Get-DocsLedgerCommandSchemaSet {
    <#
    .SYNOPSIS
        Returns the composed runtime schemas, or throws when they cannot be composed (private helper).
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.IDictionary])]
    param()

    $composed = Get-DocsComposedSchemaSet -SchemaSet (Read-DocsSchemaSet)
    if (@($composed.Findings).Count -gt 0) { throw "DOCS_SCHEMA_COMPOSITION_FAILED: $($composed.Findings[0].code) $($composed.Findings[0].message)" }
    return $composed.Schemas
}

function Get-DocsLedgerCommandArgumentValue {
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

    if (Test-DocsLedgerCommandOption -Argument $Argument -Name $Name) { return $Argument[$Name] }
    return $Default
}

function New-DocsLedgerCommandRuntimeResult {
    <#
    .SYNOPSIS
        Returns an exit-3 result with exactly one DOCS_CLI_RUNTIME finding (private helper).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [string] $Command,
        [Parameter(Mandatory = $true)] [string] $Message,
        [AllowNull()] [string] $ArtifactPath,
        [AllowNull()] [AllowEmptyCollection()] [string[]] $RelatedPath
    )

    $paths = [string[]]@($RelatedPath | Where-Object { $null -ne $_ -and (Test-DocsRelativePath -Path $_) })
    $finding = New-DocsFinding -Code 'DOCS_CLI_RUNTIME' -Severity 'error' -Message $Message -NextAction 'Correct the reported condition and run the command again.' -ArtifactPath $ArtifactPath -RelatedPath $paths
    return New-DocsCommandResult -Command $Command -ExitCode 3 -Finding @($finding)
}

function Get-DocsLedgerCommandTimestamp {
    <#
    .SYNOPSIS
        Reads the clock member and formats it; throws DOCS_CLOCK_NOT_UTC for a non-UTC clock (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [scriptblock] $UtcNow)

    return ConvertTo-DocsTimestampText -UtcNow ([datetime] (& $UtcNow))
}

function Read-DocsLedgerCommandProfile {
    <#
    .SYNOPSIS
        Reads and validates the profile; returns @{ Result; Profile; Path; Bytes } where Result is an exit-1 result when the profile does not load (private helper).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [string] $Command,
        [Parameter(Mandatory = $true)] [string] $ProfilePath,
        [Parameter(Mandatory = $true)] [scriptblock] $ReadBytes,
        [Parameter(Mandatory = $true)] [scriptblock] $TestFile,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $ComposedSchemaSet
    )

    if (-not [bool] (& $TestFile $ProfilePath)) {
        $finding = New-DocsFinding -Code 'DOCS_PROFILE_MISSING' -Severity 'error' -Message "The profile $ProfilePath does not exist." -NextAction 'Run Invoke-DocsCommand.ps1 -Command init -Write, or pass -Profile with an existing profile.' -ArtifactPath $ProfilePath
        return @{ Result = (New-DocsCommandResult -Command $Command -ExitCode 1 -Finding @($finding)); Profile = $null; Path = $ProfilePath; Bytes = $null }
    }
    $bytes = [byte[]] (& $ReadBytes $ProfilePath)
    $check = ConvertFrom-DocsProfileText -Text (ConvertFrom-DocsUtf8Bytes -Bytes $bytes) -ArtifactPath $ProfilePath -ComposedSchemaSet $ComposedSchemaSet
    if ($null -eq $check.Profile -or -not $check.Ok) {
        return @{ Result = (New-DocsCommandResult -Command $Command -ExitCode 1 -Finding $check.Findings); Profile = $null; Path = $ProfilePath; Bytes = $bytes }
    }
    return @{ Result = $null; Profile = $check.Profile; Path = $ProfilePath; Bytes = $bytes }
}

function ConvertFrom-DocsLedgerCommandArtifact {
    <#
    .SYNOPSIS
        Decodes, schema-checks and parses one present artifact entry @{ Path; Bytes }; returns @{ Path; Bytes; Sha256; Value; Findings }, Sha256 from Get-DocsTextSha256Hex (private helper).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [string] $ArtifactKind,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Entry,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $ComposedSchemaSet
    )

    $path = [string] $Entry['Path']
    $bytes = [byte[]] $Entry['Bytes']
    $text = ConvertFrom-DocsUtf8Bytes -Bytes $bytes
    $findings = Test-DocsArtifactText -ArtifactKind $ArtifactKind -JsonText $text -ComposedSchemaSet $ComposedSchemaSet -ArtifactPath $path
    $value = $null
    if (@($findings).Count -eq 0) { $value = (ConvertFrom-DocsJsonText -Text $text -ArtifactPath $path).Value }
    return @{ Path = $path; Bytes = $bytes; Sha256 = (Get-DocsTextSha256Hex -Bytes $bytes); Value = $value; Findings = [object[]]@($findings) }
}

function Read-DocsLedgerCommandDocumentSet {
    <#
    .SYNOPSIS
        Reads the snapshot (required), ledger, matrix and pin collection (absent ones are fresh documents); returns @{ Result; View; Ledger; Matrix; PinSet; Snapshot; Path; Sha256; Present; PagePath; PageReference } where Result is an exit-1 result on an absent snapshot or an invalid input, and PageReference holds the surface_refs of the pages read through ReadText when -PageReference is set (private helper).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [string] $Command,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Profile,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $ComposedSchemaSet,
        [Parameter(Mandatory = $true)] [scriptblock] $ReadBytes,
        [Parameter(Mandatory = $true)] [scriptblock] $TestFile,
        [Parameter(Mandatory = $true)] [scriptblock] $ListFile,
        [AllowNull()] [scriptblock] $ReadText,
        [switch] $PageReference
    )

    $kinds = @('surface-inventory-snapshot', 'docs-coverage-ledger', 'docs-parity-matrix', 'docs-evidence-pin')
    $inputs = Read-DocsLedgerInputSet -Profile $Profile -Need ($kinds + @('page-path-set')) -ReadBytes $ReadBytes -TestFile $TestFile -ListFile $ListFile
    $paths = Get-DocsLedgerCommandMember -Table $Profile -Name 'artifact_paths'
    $pathOf = @{}
    $sha256 = @{}
    $present = @{}
    foreach ($kind in $kinds) {
        $pathOf[$kind] = [string] (Get-DocsLedgerCommandMember -Table $paths -Name ([string] $script:DocsLedgerCommandArtifactPathKey[$kind]))
        $sha256[$kind] = $null
        $present[$kind] = $null -ne $inputs.Artifact[$kind]
    }
    $outcome = @{ Result = $null; View = $null; Ledger = $null; Matrix = $null; PinSet = $null; Snapshot = $null; Path = $pathOf; Sha256 = $sha256; Present = $present; PagePath = $inputs.PagePath; PageReference = $null }
    if (-not $present['surface-inventory-snapshot']) {
        $finding = New-DocsFinding -Code 'DOCS_INPUT_UNREADABLE' -Severity 'error' -ArtifactPath $pathOf['surface-inventory-snapshot'] -Message "The surface-inventory-snapshot artifact at $($pathOf['surface-inventory-snapshot']) does not exist." -NextAction 'Generate the inventory snapshot, or correct artifact_paths in the docs profile.'
        $outcome.Result = New-DocsCommandResult -Command $Command -ExitCode 1 -Finding @($finding)
        return $outcome
    }
    $parsed = @{}
    $findings = [System.Collections.Generic.List[object]]::new()
    foreach ($kind in $kinds) {
        if (-not $present[$kind]) { continue }
        $read = ConvertFrom-DocsLedgerCommandArtifact -ArtifactKind $kind -Entry $inputs.Artifact[$kind] -ComposedSchemaSet $ComposedSchemaSet
        $sha256[$kind] = $read.Sha256
        $parsed[$kind] = $read.Value
        foreach ($finding in $read.Findings) { $findings.Add($finding) }
    }
    if ($findings.Count -eq 0) {
        $outcome.Snapshot = $parsed['surface-inventory-snapshot']
        $outcome.View = ConvertTo-DocsSnapshotView -Snapshot $outcome.Snapshot -SnapshotSha256 $sha256['surface-inventory-snapshot'] -ArtifactPath $pathOf['surface-inventory-snapshot']
        foreach ($finding in @($outcome.View.Findings)) { $findings.Add($finding) }
    }
    if ($findings.Count -gt 0) {
        $outcome.Result = New-DocsCommandResult -Command $Command -ExitCode 1 -Finding $findings.ToArray()
        return $outcome
    }
    $repository = [string] (Get-DocsLedgerCommandMember -Table (Get-DocsLedgerCommandMember -Table $Profile -Name 'repository') -Name 'id')
    $snapshotPin = [ordered]@{ artifact_kind = 'surface-inventory-snapshot'; path = $pathOf['surface-inventory-snapshot']; sha256 = $sha256['surface-inventory-snapshot'] }
    $outcome.Ledger = if ($present['docs-coverage-ledger']) { $parsed['docs-coverage-ledger'] } else { New-DocsLedgerDocument -RepositoryId $repository -SnapshotPin $snapshotPin }
    $ledgerSha256 = if ($present['docs-coverage-ledger']) { $sha256['docs-coverage-ledger'] } else { Get-DocsSha256Hex -Text (ConvertTo-DocsJsonText -Value $outcome.Ledger -Indented) }
    $ledgerPin = [ordered]@{ artifact_kind = 'docs-coverage-ledger'; path = $pathOf['docs-coverage-ledger']; sha256 = $ledgerSha256 }
    $outcome.Matrix = if ($present['docs-parity-matrix']) { $parsed['docs-parity-matrix'] } else { New-DocsParityMatrixDocument -RepositoryId $repository -SnapshotPin $snapshotPin -LedgerPin $ledgerPin }
    $outcome.PinSet = if ($present['docs-evidence-pin']) { $parsed['docs-evidence-pin'] } else { New-DocsPinCollectionDocument -RepositoryId $repository }
    if ($PageReference) { $outcome.PageReference = Get-DocsLedgerPageReference -PagePath $inputs.PagePath -ReadText $ReadText }
    return $outcome
}

function Invoke-DocsCoverageCommand {
    <#
    .SYNOPSIS
        Builds the read-only coverage report over the profile, snapshot, ledger, matrix, pin collection and page-path set.
    .DESCRIPTION
        Options: Profile. An absent ledger, matrix or pin collection is treated as empty. Exit 0
        with the report and no finding; exit 1 with a null result when the profile does not load,
        the snapshot is absent (DOCS_INPUT_UNREADABLE) or an input fails parse, schema or element
        rebuild; exit 2 for a usage error before any read; exit 3 (DOCS_CLI_RUNTIME) for a read
        failure, uncomposable schemas or a non-UTC clock. The WriteText member is never read.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Argument,
        [Parameter(Mandatory = $true)] [object] $Context
    )

    $command = 'coverage'
    $profilePath = [string] (Get-DocsLedgerCommandArgumentValue -Argument $Argument -Name 'Profile' -Default (Get-DocsDefaultProfilePath))
    if (-not (Test-DocsRelativePath -Path $profilePath)) { return New-DocsCommandResult -Command $command -ExitCode 2 -Finding @((New-DocsLedgerCommandUsageFinding -Command $command -Message "Profile '$profilePath' is not a repository-relative path.")) }
    try {
        [void] (Get-DocsLedgerCommandTimestamp -UtcNow $Context.UtcNow)
        $schemas = Get-DocsLedgerCommandSchemaSet
        $profileRead = Read-DocsLedgerCommandProfile -Command $command -ProfilePath $profilePath -ReadBytes $Context.ReadBytes -TestFile $Context.TestFile -ComposedSchemaSet $schemas
        if ($null -ne $profileRead.Result) { return $profileRead.Result }
        $documents = Read-DocsLedgerCommandDocumentSet -Command $command -Profile $profileRead.Profile -ComposedSchemaSet $schemas -ReadBytes $Context.ReadBytes -TestFile $Context.TestFile -ListFile $Context.ListFile
        if ($null -ne $documents.Result) { return $documents.Result }
        $report = Get-DocsCoverageReport -SnapshotView $documents.View -Ledger $documents.Ledger -Matrix $documents.Matrix -PinSet $documents.PinSet
        return New-DocsCommandResult -Command $command -ExitCode 0 -Finding @() -Result $report -Line (ConvertTo-DocsCoverageReportLine -Report $report)
    } catch {
        return New-DocsLedgerCommandRuntimeResult -Command $command -Message "The command failed: $($_.Exception.Message)"
    }
}

function Get-DocsLedgerCommandRuleFinding {
    <#
    .SYNOPSIS
        Returns the rule findings of the documents named by Kind (ledger rules, pin rules, matrix rules), plus the schema findings of their text when -IncludeSchema (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $View,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Document,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Path,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $LedgerSha256,
        [AllowNull()] [AllowEmptyCollection()] [string[]] $PagePath,
        [AllowNull()] [AllowEmptyCollection()] [object[]] $PageOwner,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $ComposedSchemaSet,
        [AllowNull()] [AllowEmptyCollection()] [string[]] $Kind,
        [switch] $IncludeSchema
    )

    $findings = [System.Collections.Generic.List[object]]::new()
    foreach ($name in @($Kind | Where-Object { $null -ne $_ })) {
        if ($IncludeSchema) {
            foreach ($finding in (Test-DocsArtifactText -ArtifactKind $name -JsonText (ConvertTo-DocsJsonText -Value $Document[$name] -Indented) -ComposedSchemaSet $ComposedSchemaSet -ArtifactPath $Path[$name])) { $findings.Add($finding) }
        }
        $rules = switch ($name) {
            'docs-coverage-ledger' { Get-DocsLedgerFinding -Ledger $Document[$name] -SnapshotView $View -ArtifactPath $Path[$name] }
            'docs-evidence-pin' { Get-DocsPinFinding -PinSet $Document[$name] -ArtifactPath $Path[$name] }
            'docs-parity-matrix' { Get-DocsMatrixFinding -Matrix $Document[$name] -Ledger $Document['docs-coverage-ledger'] -PinSet $Document['docs-evidence-pin'] -PagePath $PagePath -PageOwner $PageOwner -LedgerSha256 $LedgerSha256 -ArtifactPath $Path[$name] }
            default { @() }
        }
        foreach ($finding in @($rules)) { $findings.Add($finding) }
    }
    return , [object[]] $findings.ToArray()
}

function Get-DocsLedgerCommandFindingKey {
    <#
    .SYNOPSIS
        Returns the identity of a finding over every field except pointer (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Finding)

    $separator = [string][char]0
    return @([string] $Finding['code'], [string] $Finding['severity'], [string] $Finding['artifact_path'], (@($Finding['related_ids']) -join ','), (@($Finding['related_paths']) -join ','), [string] $Finding['message'], [string] $Finding['next_action']) -join $separator
}

function New-DocsLedgerCommandTargetFinding {
    <#
    .SYNOPSIS
        Returns one DOCS_UPDATE_TARGET_INVALID error finding (private helper).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [string] $Message,
        [AllowNull()] [string] $ArtifactPath,
        [AllowNull()] [AllowEmptyCollection()] [string[]] $RelatedId
    )

    $ids = [string[]]@($RelatedId | Where-Object { $null -ne $_ -and $_ -cmatch $script:DocsLedgerCommandIdentifierPattern })
    return New-DocsFinding -Code 'DOCS_UPDATE_TARGET_INVALID' -Severity 'error' -Message $Message -NextAction 'Name an element, precision limit, binding or pin that exists in the current snapshot and documents.' -ArtifactPath $ArtifactPath -RelatedId $ids
}

function Invoke-DocsLedgerOperation {
    <#
    .SYNOPSIS
        Applies one update-ledger operation to the loaded documents; returns @{ Ledger; Matrix; PinSet; Finding } where Finding is a DOCS_UPDATE_TARGET_INVALID finding or $null (private helper).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Argument,
        [Parameter(Mandatory = $true)] [hashtable] $Documents,
        [Parameter(Mandatory = $true)] [string] $IssuedAt
    )

    $view = $Documents.View
    $ledger = $Documents.Ledger
    $matrix = $Documents.Matrix
    $pinSet = $Documents.PinSet
    $ledgerPath = [string] $Documents.Path['docs-coverage-ledger']
    $actor = @{ kind = [string] $Argument['ActorKind']; id = [string] $Argument['ActorId'] }
    $operation = [string] $Argument['Operation']
    $elementId = [string] (Get-DocsLedgerCommandArgumentValue -Argument $Argument -Name 'Element' -Default '')
    $limitId = [string] (Get-DocsLedgerCommandArgumentValue -Argument $Argument -Name 'Limit' -Default '')
    $pages = [string[]]@(Get-DocsLedgerCommandArgumentValue -Argument $Argument -Name 'Page' -Default @())
    $firstPage = if ($pages.Count -gt 0) { (Get-DocsLedgerCommandPageBinding -Value $pages[0])['page_path'] } else { '' }
    $entries = @(Get-DocsLedgerCommandMember -Table $ledger -Name 'entries')
    $current = @($entries | Where-Object { [string] (Get-DocsLedgerCommandMember -Table $_ -Name 'element_id') -ceq $elementId -and -not ((Get-DocsLedgerCommandMember -Table $_ -Name 'extensions') -is [System.Collections.IDictionary] -and (Get-DocsLedgerCommandMember -Table $_ -Name 'extensions').Contains('docs.precision-limit')) })
    $limit = $null
    foreach ($key in @($view.PrecisionLimit.Keys)) { if ([string] $view.PrecisionLimit[$key]['DiagnosticId'] -ceq $limitId) { $limit = $view.PrecisionLimit[$key] } }
    $element = if ($elementId.Length -gt 0 -and $view.Element.Contains($elementId)) { $view.Element[$elementId] } else { $null }
    # remove-entry targets the ledger entry (an orphan may name an element that left the snapshot).
    $needsElement = $operation -cne 'sync-refs' -and $operation -cne 'remove-entry' -and $operation -cne 'bind-page-refs' -and $limitId.Length -eq 0
    if ($needsElement -and $null -eq $element) { return @{ Finding = (New-DocsLedgerCommandTargetFinding -Message "The element $elementId is not in the current snapshot." -ArtifactPath $Documents.Path['surface-inventory-snapshot'] -RelatedId @($elementId)) } }
    if ($limitId.Length -gt 0 -and $operation -ceq 'set-disposition' -and $null -eq $limit) { return @{ Finding = (New-DocsLedgerCommandTargetFinding -Message "The precision-limit diagnostic $limitId is not in the current snapshot." -ArtifactPath $Documents.Path['surface-inventory-snapshot'] -RelatedId @($limitId)) } }
    switch ($operation) {
        'set-disposition' {
            if ($null -ne $limit) {
                $owner = [string] (Get-DocsLedgerCommandArgumentValue -Argument $Argument -Name 'Owner' -Default '')
                $target = [string] (Get-DocsLedgerCommandArgumentValue -Argument $Argument -Name 'Target' -Default '')
                $entry = New-DocsPrecisionLimitEntry -Limit $limit -Owner $(if ($owner.Length -gt 0) { $owner } else { 'owner' }) -Target $(if ($target.Length -gt 0) { $target } else { 'target' }) -Rationale (Get-DocsLedgerCommandArgumentValue -Argument $Argument -Name 'Rationale' -Default $null) -Actor $actor
                # A missing owner or target is reported by the companion rules as a newly-introduced error.
                if ($owner.Length -eq 0) { $entry['owner'] = $null }
                if ($target.Length -eq 0) { $entry['target'] = $null }
                $ledger = Merge-DocsLedgerEntry -Ledger $ledger -Entry $entry
                break
            }
            $bindings = [object[]]@($pages | ForEach-Object { Get-DocsLedgerCommandPageBinding -Value $_ })
            $entry = New-DocsLedgerEntry -Element $element -Disposition ([string] $Argument['Disposition']) -PageBinding $bindings -Rationale (Get-DocsLedgerCommandArgumentValue -Argument $Argument -Name 'Rationale' -Default $null) -Owner (Get-DocsLedgerCommandArgumentValue -Argument $Argument -Name 'Owner' -Default $null) -Target (Get-DocsLedgerCommandArgumentValue -Argument $Argument -Name 'Target' -Default $null) -Actor $actor
            $kept = [System.Collections.Generic.HashSet[string]]::new([string[]]@($bindings | ForEach-Object { [string] $_['page_path'] }), [System.StringComparer]::Ordinal)
            foreach ($old in $current) {
                foreach ($binding in @(Get-DocsLedgerCommandMember -Table $old -Name 'page_bindings')) {
                    $page = [string] (Get-DocsLedgerCommandMember -Table $binding -Name 'page_path')
                    if ($kept.Contains($page)) { continue }
                    $matrix = Get-DocsMatrixWithoutBinding -Matrix $matrix -ElementId $elementId -PagePath $page
                    $pinSet = Get-DocsPinSetWithoutPin -PinSet $pinSet -ElementId $elementId -PagePath $page
                }
            }
            $ledger = Merge-DocsLedgerEntry -Ledger $ledger -Entry $entry
        }
        'remove-entry' {
            if ($limitId.Length -gt 0) {
                $marked = @($entries | Where-Object { $extensions = Get-DocsLedgerCommandMember -Table $_ -Name 'extensions'; $extensions -is [System.Collections.IDictionary] -and $extensions.Contains('docs.precision-limit') -and [string] (Get-DocsLedgerCommandMember -Table $extensions['docs.precision-limit'] -Name 'diagnostic_id') -ceq $limitId })
                if ($marked.Count -eq 0) { return @{ Finding = (New-DocsLedgerCommandTargetFinding -Message "The ledger has no precision-limit entry for the diagnostic $limitId." -ArtifactPath $ledgerPath -RelatedId @($limitId)) } }
                $ledger = Get-DocsLedgerWithoutEntry -Ledger $ledger -ElementId ([string] $marked[0]['element_id'])
                break
            }
            if ($current.Count -eq 0) { return @{ Finding = (New-DocsLedgerCommandTargetFinding -Message "The ledger has no entry for the element $elementId." -ArtifactPath $ledgerPath -RelatedId @($elementId)) } }
            $ledger = Get-DocsLedgerWithoutEntry -Ledger $ledger -ElementId $elementId
            $matrix = Get-DocsMatrixWithoutBinding -Matrix $matrix -ElementId $elementId
            $pinSet = Get-DocsPinSetWithoutPin -PinSet $pinSet -ElementId $elementId
        }
        'pin' {
            $pin = New-DocsEvidencePin -Element $element -PagePath $firstPage -Claim (Get-DocsLedgerCommandArgumentValue -Argument $Argument -Name 'Claim' -Default $null) -Revision $view.Revision -PinnedAt $IssuedAt -Actor $actor
            $pinSet = Merge-DocsEvidencePin -PinSet $pinSet -Pin $pin
        }
        'unpin' {
            $existing = @(@(Get-DocsLedgerCommandMember -Table $pinSet -Name 'pins') | Where-Object { [string] (Get-DocsLedgerCommandMember -Table $_ -Name 'element_id') -ceq $elementId -and [string] (Get-DocsLedgerCommandMember -Table $_ -Name 'page_path') -ceq $firstPage })
            if ($existing.Count -eq 0) { return @{ Finding = (New-DocsLedgerCommandTargetFinding -Message "No pin binds the element $elementId to the page $firstPage." -ArtifactPath $Documents.Path['docs-evidence-pin'] -RelatedId @($elementId)) } }
            $pinSet = Get-DocsPinSetWithoutPin -PinSet $pinSet -ElementId $elementId -PagePath $firstPage
            foreach ($pin in $existing) { $matrix = Merge-DocsMatrixPinRemoval -Matrix $matrix -PinId ([string] $pin['pin_id']) }
        }
        'set-dimension' {
            $pinIds = [string[]]@(@(Get-DocsLedgerCommandMember -Table $pinSet -Name 'pins') | Where-Object { [string] (Get-DocsLedgerCommandMember -Table $_ -Name 'element_id') -ceq $elementId -and [string] (Get-DocsLedgerCommandMember -Table $_ -Name 'page_path') -ceq $firstPage } | ForEach-Object { [string] $_['pin_id'] })
            $matrix = Merge-DocsParityDimension -Matrix $matrix -ElementId $elementId -Kind ([string] $element['kind']) -PagePath $firstPage -Dimension ([string] $Argument['Dimension']) -State ([string] $Argument['State']) -Rationale (Get-DocsLedgerCommandArgumentValue -Argument $Argument -Name 'Rationale' -Default $null) -PinId $pinIds
        }
        'bind-page-refs' {
            $ledger = Update-DocsLedgerPageBinding -Ledger $ledger -View $view -Reference $Documents.PageReference -ElementId $elementId -Actor $actor
        }
        'sync-refs' {
            $snapshotPin = [ordered]@{ artifact_kind = 'surface-inventory-snapshot'; path = [string] $Documents.Path['surface-inventory-snapshot']; sha256 = [string] $view.Sha256 }
            $ledger = Merge-DocsLedgerSnapshotRef -Ledger $ledger -SnapshotPin $snapshotPin -SnapshotView $view
            $ledgerPin = [ordered]@{ artifact_kind = 'docs-coverage-ledger'; path = $ledgerPath; sha256 = (Get-DocsSha256Hex -Text (ConvertTo-DocsJsonText -Value $ledger -Indented)) }
            $matrix = Merge-DocsMatrixRef -Matrix $matrix -SnapshotPin $snapshotPin -LedgerPin $ledgerPin
        }
    }
    return @{ Ledger = $ledger; Matrix = $matrix; PinSet = $pinSet; Finding = $null }
}

function Get-DocsLedgerCommandOutcome {
    <#
    .SYNOPSIS
        Runs the newly-introduced rule comparison over the loaded and changed documents; returns @{ After; Text; Changed; Introduced; NewErrors; Preexisting } (private helper).
    .DESCRIPTION
        Rules of changed documents are compared on every field except pointer; Preexisting counts
        the prior error findings. Used by the single path and once per Invoke-DocsLedgerBatch run.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $Documents,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Applied,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $DocsProfile,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $ComposedSchemaSet
    )

    $before = [ordered]@{ 'docs-coverage-ledger' = $Documents.Ledger; 'docs-parity-matrix' = $Documents.Matrix; 'docs-evidence-pin' = $Documents.PinSet }
    $after = [ordered]@{ 'docs-coverage-ledger' = $Applied.Ledger; 'docs-parity-matrix' = $Applied.Matrix; 'docs-evidence-pin' = $Applied.PinSet }
    $text = @{}
    $changed = @{}
    foreach ($kind in @($after.Keys)) {
        $text[$kind] = ConvertTo-DocsJsonText -Value $after[$kind] -Indented
        $changed[$kind] = (ConvertTo-DocsCanonicalJson -Value $after[$kind]) -cne (ConvertTo-DocsCanonicalJson -Value $before[$kind])
    }
    $pageOwners = [object[]]@(Get-DocsLedgerCommandMember -Table $DocsProfile -Name 'page_owners')
    $allKinds = [string[]]@($after.Keys)
    $changedKinds = [string[]]@($allKinds | Where-Object { $changed[$_] })
    $ledgerBefore = if ($Documents.Present['docs-coverage-ledger']) { [string] $Documents.Sha256['docs-coverage-ledger'] } else { Get-DocsSha256Hex -Text (ConvertTo-DocsJsonText -Value $Documents.Ledger -Indented) }
    $ledgerAfter = if ($changed['docs-coverage-ledger']) { Get-DocsSha256Hex -Text $text['docs-coverage-ledger'] } else { $ledgerBefore }
    $common = @{ View = $Documents.View; Path = $Documents.Path; PagePath = $Documents.PagePath; PageOwner = $pageOwners; ComposedSchemaSet = $ComposedSchemaSet }
    $allBefore = Get-DocsLedgerCommandRuleFinding @common -Document $before -LedgerSha256 $ledgerBefore -Kind $allKinds
    $beforeFindings = Get-DocsLedgerCommandRuleFinding @common -Document $before -LedgerSha256 $ledgerBefore -Kind $changedKinds
    $afterFindings = Get-DocsLedgerCommandRuleFinding @common -Document $after -LedgerSha256 $ledgerAfter -Kind $changedKinds -IncludeSchema
    $beforeKeys = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($finding in $beforeFindings) { [void]$beforeKeys.Add((Get-DocsLedgerCommandFindingKey -Finding $finding)) }
    $introduced = [object[]]@($afterFindings | Where-Object { -not $beforeKeys.Contains((Get-DocsLedgerCommandFindingKey -Finding $_)) })
    return @{ After = $after; Text = $text; Changed = $changed; Introduced = $introduced; NewErrors = [object[]]@($introduced | Where-Object { [string] $_['severity'] -ceq 'error' }); Preexisting = @($allBefore | Where-Object { [string] $_['severity'] -ceq 'error' }).Count }
}

function Invoke-DocsUpdateLedgerCommand {
    <#
    .SYNOPSIS
        Applies one update-ledger operation, or an operations batch, to the ledger, matrix and pin collection; dry run by default, committed with -Write through Invoke-DocsArtifactWrite.
    .DESCRIPTION
        Exit 2 for a usage error before any read. Exit 1 with a null result when the profile does
        not load, the snapshot is absent or invalid, a named target does not exist
        (DOCS_UPDATE_TARGET_INVALID), or the operation would introduce an error finding absent
        before it (compared on every field except pointer); nothing is written. Exit 0 with
        {dry_run, preexisting_errors, writes} and only the warning and info findings the
        operation introduced. Exit 3 (DOCS_CLI_RUNTIME) for a read failure, a non-UTC clock, or
        a commit conflict or write failure (the message names the path and status; related_paths
        holds that path and every path already written). A created document carries the 1020
        header with a repository-derived id. Issue #1173: bind-page-refs reads the Markdown pages
        through Context.ReadText, binds each surface_refs element as documented with the union of
        its pages, and warns DOCS_LEDGER_BIND_REF_UNKNOWN per unknown id. -Operations <path|-> reads
        an operations document through Context.ReadText or Context.ReadStdin (exit 2 when it is
        invalid, or with -Operation or a per-operation option) and applies it through
        Invoke-DocsLedgerBatch: one document load, one rule comparison, one Invoke-DocsArtifactWrite
        call; an item error exits 1 with the item index and writes nothing.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Argument,
        [Parameter(Mandatory = $true)] [object] $Context
    )

    $command = 'update-ledger'
    $batch = Test-DocsLedgerCommandOption -Argument $Argument -Name 'Operations'
    $usage = if ($batch) { Test-DocsLedgerBatchArgument -Argument $Argument } else { Test-DocsUpdateLedgerArgument -Argument $Argument }
    if ($null -ne $usage) { return New-DocsCommandResult -Command $command -ExitCode 2 -Finding @($usage) }
    try {
        $issuedAt = Get-DocsLedgerCommandTimestamp -UtcNow $Context.UtcNow
        $schemas = Get-DocsLedgerCommandSchemaSet
        $profilePath = [string] (Get-DocsLedgerCommandArgumentValue -Argument $Argument -Name 'Profile' -Default (Get-DocsDefaultProfilePath))
        $profileRead = Read-DocsLedgerCommandProfile -Command $command -ProfilePath $profilePath -ReadBytes $Context.ReadBytes -TestFile $Context.TestFile -ComposedSchemaSet $schemas
        if ($null -ne $profileRead.Result) { return $profileRead.Result }
        $items = @()
        if ($batch) {
            $operationsText = Read-DocsLedgerOperationText -Source ([string] $Argument['Operations']) -ReadText $Context.ReadText -ReadStdin $Context.ReadStdin
            $parsed = ConvertFrom-DocsLedgerOperationText -Text $operationsText -ActorKind ([string] $Argument['ActorKind']) -ActorId ([string] $Argument['ActorId']) -ProfilePath ([string] $Argument['Profile']) -ValidateArgument ${function:Test-DocsUpdateLedgerArgument}
            if ($null -ne $parsed.Finding) { return New-DocsCommandResult -Command $command -ExitCode 2 -Finding @($parsed.Finding) }
            $items = @($parsed.Item)
        }
        $binds = ($batch -and @($items | Where-Object { [string] $_.Argument['Operation'] -ceq 'bind-page-refs' }).Count -gt 0) -or [string] $Argument['Operation'] -ceq 'bind-page-refs'
        $load = { Read-DocsLedgerCommandDocumentSet -Command $command -Profile $profileRead.Profile -ComposedSchemaSet $schemas -ReadBytes $Context.ReadBytes -TestFile $Context.TestFile -ListFile $Context.ListFile -ReadText $Context.ReadText -PageReference:$binds }
        if ($batch) {
            $compare = { param($Documents, $After) Get-DocsLedgerCommandOutcome -Documents $Documents -Applied $After -DocsProfile $profileRead.Profile -ComposedSchemaSet $schemas }
            $run = Invoke-DocsLedgerBatch -Item $items -LoadDocument $load -ApplyOperation ${function:Invoke-DocsLedgerOperation} -CompareRule $compare -IssuedAt $issuedAt
            $documents = $run.Documents
            if ($null -ne $documents.Result) { return $documents.Result }
            if (@($run.Finding).Count -gt 0) { return New-DocsCommandResult -Command $command -ExitCode 1 -Finding @($run.Finding) }
            $outcome = $run.Outcome
        } else {
            $documents = Read-DocsLedgerCommandDocumentSet -Command $command -Profile $profileRead.Profile -ComposedSchemaSet $schemas -ReadBytes $Context.ReadBytes -TestFile $Context.TestFile -ListFile $Context.ListFile -ReadText $Context.ReadText -PageReference:$binds
            if ($null -ne $documents.Result) { return $documents.Result }
            $applied = Invoke-DocsLedgerOperation -Argument $Argument -Documents $documents -IssuedAt $issuedAt
            if ($null -ne $applied.Finding) { return New-DocsCommandResult -Command $command -ExitCode 1 -Finding @($applied.Finding) }
            $outcome = Get-DocsLedgerCommandOutcome -Documents $documents -Applied $applied -DocsProfile $profileRead.Profile -ComposedSchemaSet $schemas
            if (@($outcome.NewErrors).Count -gt 0) { return New-DocsCommandResult -Command $command -ExitCode 1 -Finding @($outcome.NewErrors) }
        }
        $warnings = if ($binds) { @(Get-DocsLedgerPageReferenceWarning -Reference $documents.PageReference -View $documents.View) } else { @() }
        $plannedDocuments = @(foreach ($kind in @($outcome.After.Keys)) {
                if (-not $outcome.Changed[$kind] -and -not $documents.Present[$kind]) { continue }
                @{ Path = $documents.Path[$kind]; ArtifactKind = $kind; ArtifactId = [string] $outcome.After[$kind]['id']; Text = $outcome.Text[$kind]; BeforeSha256 = $documents.Sha256[$kind] }
            })
        $plans = Get-DocsArtifactWritePlan -Document $plannedDocuments
        $write = [bool] (Get-DocsLedgerCommandArgumentValue -Argument $Argument -Name 'Write' -Default $false)
        $commit = Invoke-DocsArtifactWrite -Plan $plans -ReadBytes $Context.ReadBytes -TestFile $Context.TestFile -WriteText $Context.WriteText -DryRun:(-not $write)
        if ($null -ne $commit.Failed) {
            return New-DocsLedgerCommandRuntimeResult -Command $command -Message "The write of $($commit.Failed['Path']) ended with status $($commit.Failed['Status']): $($commit.Failed['Message'])" -ArtifactPath ([string] $commit.Failed['Path']) -RelatedPath (@([string] $commit.Failed['Path']) + @($commit.WrittenPath))
        }
        $writes = [object[]]@($commit.Write | ForEach-Object { [ordered]@{ path = $_['Path']; artifact_kind = $_['ArtifactKind']; artifact_id = $_['ArtifactId']; sha256 = $_['Sha256']; status = $_['Status'] } })
        $result = [ordered]@{ dry_run = (-not $write); preexisting_errors = [long] $outcome.Preexisting; writes = $writes }
        return New-DocsCommandResult -Command $command -ExitCode 0 -Finding (@($outcome.Introduced) + $warnings) -Result $result -Line ([string[]]@($writes | ForEach-Object { "$($_['status']) $($_['path'])" }))
    } catch {
        return New-DocsLedgerCommandRuntimeResult -Command $command -Message "The command failed: $($_.Exception.Message)"
    }
}

Export-ModuleMember -Function `
    Test-DocsUpdateLedgerArgument, `
    Read-DocsLedgerInputSet, `
    Invoke-DocsCoverageCommand, `
    Invoke-DocsUpdateLedgerCommand, `
    Get-DocsLedgerCommandMember, `
    Test-DocsLedgerCommandOption, `
    New-DocsLedgerCommandUsageFinding, `
    Get-DocsLedgerCommandSchemaSet, `
    Get-DocsLedgerCommandArgumentValue, `
    New-DocsLedgerCommandRuntimeResult, `
    Get-DocsLedgerCommandTimestamp, `
    Read-DocsLedgerCommandProfile
