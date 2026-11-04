<#
.SYNOPSIS
    The init and validate-profile command functions and the init template table.

.DESCRIPTION
    Invoke-DocsInitCommand plans and, with -Write, creates the starter profile and every init
    template destination. Invoke-DocsValidateProfileCommand validates a profile through
    ConvertFrom-DocsProfileText. Both follow the command function contract: they take
    -Argument and -Context, return a New-DocsCommandResult object, write no output and never
    exit. Every repository read and write goes through the command context members, which are
    invoked only through the [scriptblock] parameter of Invoke-DocsContextMember.

    Init template rows have the form
    [pscustomobject]@{ Source = '.claude/lib/docs/templates/<file>'; Destination = '<destination-relative path>' }
    where Source is repository-relative and is read through Context.ReadText.

.NOTES
    Issue #1020. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsProfile.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSchema.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsFinding.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsJson.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSurface.psm1') -ErrorAction Stop

$script:DocsCommandIdentifierPattern = '^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$(?![\s\S])'

function Get-DocsInitTemplate {
    <#
    .SYNOPSIS
        Returns the init template table (rows under the 1021 and 1034 anchors).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param()

    $rows = @(
        # --- 1021: page-check configuration ---
        [pscustomobject]@{ Source = '.claude/lib/docs/templates/page-check/markdownlint.json'; Destination = '.markdownlint.json' }
        [pscustomobject]@{ Source = '.claude/lib/docs/templates/page-check/vale.ini'; Destination = '.vale.ini' }
        [pscustomobject]@{ Source = '.claude/lib/docs/templates/page-check/vale/DocsBase/HeadingPunctuation.yml'; Destination = '.vale/styles/DocsBase/HeadingPunctuation.yml' }
        [pscustomobject]@{ Source = '.claude/lib/docs/templates/page-check/vale/DocsBase/Placeholders.yml'; Destination = '.vale/styles/DocsBase/Placeholders.yml' }
        [pscustomobject]@{ Source = '.claude/lib/docs/templates/page-check/vale/Project/accept.txt'; Destination = '.vale/styles/config/vocabularies/Project/accept.txt' }
        # --- 1034: docs workflow ---
    )
    return , [object[]]$rows
}

function Invoke-DocsContextMember {
    <#
    .SYNOPSIS
        Invokes one command-context member with positional arguments (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter(Mandatory = $true)] [scriptblock] $Member,
        [AllowEmptyCollection()] [object[]] $ArgumentList = @()
    )

    return & $Member @ArgumentList
}

function New-DocsCommandFinding {
    <#
    .SYNOPSIS
        Builds one error finding for a command result (private helper).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [string] $Code,
        [Parameter(Mandatory = $true)] [string] $Message,
        [Parameter(Mandatory = $true)] [string] $NextAction,
        [AllowNull()] [string] $ArtifactPath
    )

    return New-DocsFinding -Code $Code -Severity 'error' -Message $Message -NextAction $NextAction -ArtifactPath $ArtifactPath
}

function Get-DocsCommandSchemaSet {
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

function Get-DocsArgumentValue {
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

function New-DocsUsageResult {
    <#
    .SYNOPSIS
        Returns an exit-2 result with exactly one DOCS_CLI_ARGUMENTS finding (private helper).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [string] $Command,
        [Parameter(Mandatory = $true)] [string] $Message
    )

    $finding = New-DocsCommandFinding -Code 'DOCS_CLI_ARGUMENTS' -Message $Message -NextAction "Run Invoke-DocsCommand.ps1 -Help for the $Command options."
    return New-DocsCommandResult -Command $Command -ExitCode 2 -Finding @($finding)
}

function Invoke-DocsInitCommand {
    <#
    .SYNOPSIS
        Plans, and with -Write creates, the starter profile and the init template destinations.
    .DESCRIPTION
        Options: RepositoryId (value), Profile (value), Write (switch), Force (switch). Without
        Write only existence checks run and nothing is written. With Write every destination is
        checked first; an existing destination without Force exits 1 with one
        DOCS_INIT_TARGET_EXISTS finding per path and writes nothing. TemplateRow defaults to
        Get-DocsInitTemplate.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Argument,
        [Parameter(Mandatory = $true)] [object] $Context,
        [AllowNull()] [AllowEmptyCollection()] [object[]] $TemplateRow
    )

    if (-not $PSBoundParameters.ContainsKey('TemplateRow') -or $null -eq $TemplateRow) { $TemplateRow = Get-DocsInitTemplate }
    $repositoryId = [string] (Get-DocsArgumentValue -Argument $Argument -Name 'RepositoryId' -Default 'repository')
    $profilePath = [string] (Get-DocsArgumentValue -Argument $Argument -Name 'Profile' -Default (Get-DocsDefaultProfilePath))
    $write = [bool] (Get-DocsArgumentValue -Argument $Argument -Name 'Write' -Default $false)
    $force = [bool] (Get-DocsArgumentValue -Argument $Argument -Name 'Force' -Default $false)
    if ($repositoryId -cnotmatch $script:DocsCommandIdentifierPattern) { return New-DocsUsageResult -Command 'init' -Message "RepositoryId '$repositoryId' is not an identifier." }
    if (-not (Test-DocsRelativePath -Path $profilePath)) { return New-DocsUsageResult -Command 'init' -Message "Profile '$profilePath' is not a repository-relative path." }

    $starter = New-DocsStarterProfile -RepositoryId $repositoryId
    $profileText = ConvertTo-DocsJsonText -Value $starter -Indented
    $check = ConvertFrom-DocsProfileText -Text $profileText -ArtifactPath $profilePath -ComposedSchemaSet (Get-DocsCommandSchemaSet)
    if (-not $check.Ok) {
        $finding = New-DocsCommandFinding -Code 'DOCS_CLI_RUNTIME' -Message 'The generated starter profile failed its own validation.' -NextAction 'Report this defect in the documentation tooling.' -ArtifactPath $profilePath
        return New-DocsCommandResult -Command 'init' -ExitCode 3 -Finding @($finding)
    }

    $targets = [System.Collections.Generic.List[object]]::new()
    $targets.Add([pscustomobject]@{ Destination = $profilePath; Source = $null })
    foreach ($row in @($TemplateRow)) {
        if (-not (Test-DocsRelativePath -Path ([string] $row.Source)) -or -not (Test-DocsRelativePath -Path ([string] $row.Destination))) {
            $finding = New-DocsCommandFinding -Code 'DOCS_CLI_RUNTIME' -Message "The init template row '$($row.Source)' is not repository-relative." -NextAction 'Report this defect in the documentation tooling.'
            return New-DocsCommandResult -Command 'init' -ExitCode 3 -Finding @($finding)
        }
        $targets.Add([pscustomobject]@{ Destination = [string] $row.Destination; Source = [string] $row.Source })
    }

    $planned = [System.Collections.Generic.List[object]]::new()
    $existing = [System.Collections.Generic.List[object]]::new()
    foreach ($target in $targets) {
        $exists = [bool] (Invoke-DocsContextMember -Member $Context.TestFile -ArgumentList @($target.Destination))
        if ($exists) { $existing.Add($target) }
        $action = if (-not $exists) { 'create' } elseif ($force) { 'overwrite' } else { 'exists' }
        $planned.Add([ordered]@{ path = $target.Destination; action = $action })
    }
    $result = [ordered]@{ profile = $starter; planned_writes = $planned.ToArray() }
    $lines = [string[]]@($planned | ForEach-Object { "$($_.action) $($_.path)" })
    if (-not $write) { return New-DocsCommandResult -Command 'init' -ExitCode 0 -Finding @() -Result $result -Line $lines }

    if ($existing.Count -gt 0 -and -not $force) {
        $findings = @($existing | ForEach-Object { New-DocsCommandFinding -Code 'DOCS_INIT_TARGET_EXISTS' -Message "The destination $($_.Destination) already exists." -NextAction 'Pass -Force to overwrite it, or remove it first.' -ArtifactPath $_.Destination })
        return New-DocsCommandResult -Command 'init' -ExitCode 1 -Finding $findings -Result $result -Line $lines
    }
    foreach ($target in $targets) {
        $text = if ($null -eq $target.Source) { $profileText } else { [string] (Invoke-DocsContextMember -Member $Context.ReadText -ArgumentList @($target.Source)) }
        $mode = if ($existing -contains $target) { 'overwrite' } else { 'create' }
        [void](Invoke-DocsContextMember -Member $Context.WriteText -ArgumentList @($target.Destination, $text, $mode))
    }
    return New-DocsCommandResult -Command 'init' -ExitCode 0 -Finding @() -Result $result -Line $lines
}

function Invoke-DocsValidateProfileCommand {
    <#
    .SYNOPSIS
        Validates the profile named by -Profile (default Get-DocsDefaultProfilePath).
    .DESCRIPTION
        Exit 0 when ConvertFrom-DocsProfileText returns no error finding, otherwise 1. An absent
        profile exits 1 with DOCS_PROFILE_MISSING. Result is {profile_path, repository_id} when a
        profile was parsed, otherwise $null.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Argument,
        [Parameter(Mandatory = $true)] [object] $Context
    )

    $profilePath = [string] (Get-DocsArgumentValue -Argument $Argument -Name 'Profile' -Default (Get-DocsDefaultProfilePath))
    if (-not (Test-DocsRelativePath -Path $profilePath)) { return New-DocsUsageResult -Command 'validate-profile' -Message "Profile '$profilePath' is not a repository-relative path." }
    if (-not [bool] (Invoke-DocsContextMember -Member $Context.TestFile -ArgumentList @($profilePath))) {
        $finding = New-DocsCommandFinding -Code 'DOCS_PROFILE_MISSING' -Message "The profile $profilePath does not exist." -NextAction 'Run Invoke-DocsCommand.ps1 -Command init -Write, or pass -Profile with an existing profile.' -ArtifactPath $profilePath
        return New-DocsCommandResult -Command 'validate-profile' -ExitCode 1 -Finding @($finding)
    }
    $text = [string] (Invoke-DocsContextMember -Member $Context.ReadText -ArgumentList @($profilePath))
    $check = ConvertFrom-DocsProfileText -Text $text -ArtifactPath $profilePath -ComposedSchemaSet (Get-DocsCommandSchemaSet)
    $result = $null
    if ($null -ne $check.Profile) { $result = [ordered]@{ profile_path = $profilePath; repository_id = [string] $check.Profile['repository']['id'] } }
    $exitCode = if ($check.Ok) { 0 } else { 1 }
    return New-DocsCommandResult -Command 'validate-profile' -ExitCode $exitCode -Finding $check.Findings -Result $result
}

Export-ModuleMember -Function `
    Get-DocsInitTemplate, `
    Invoke-DocsInitCommand, `
    Invoke-DocsValidateProfileCommand
