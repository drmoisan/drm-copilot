<#
.SYNOPSIS
    The page set, byte decoding, rule orchestration and result of the documentation page
    checker, and the check command function.

.DESCRIPTION
    Get-DocsPageCandidatePath, ConvertFrom-DocsPageBytes and Get-DocsPageCheckFinding are pure:
    they take strings, byte arrays and hashtables. Get-DocsPageCheckFinding runs every rule over
    an in-memory page map: root and entry-page findings on the profile path, decode findings,
    front-matter parse and field findings, Diataxis rules for a page with a valid diataxis_mode,
    link and anchor findings, and orphan findings. A front-matter parse finding suppresses the
    field findings and the Diataxis rules of that page; DOCS_PAGE_TOO_LARGE and
    DOCS_PAGE_ENCODING_INVALID suppress every rule of that page except DOCS_PAGE_ORPHAN.

    Invoke-DocsCheckCommand follows the command function contract: it takes -Argument and
    -Context, returns a New-DocsCommandResult object, writes no output, never exits and never
    reads Context.UtcNow. Every repository read goes through the command context members, which
    are invoked only through the [scriptblock] parameter of Invoke-DocsContextMember.

.NOTES
    Issue #1021. Requires PowerShell 7.4 or later. No external module dependencies.
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
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsPageMarkdown.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsPageFrontMatter.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsPageLinks.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsPageDiataxis.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsPageOrphans.psm1') -ErrorAction Stop

$script:DocsPageCheckNextAction = @{
    'DOCS_PAGE_FRONT_MATTER_MISSING' = 'Add a front matter block with the fields that diataxis_policy.required_front_matter lists.'
    'DOCS_PAGE_TOO_LARGE'            = 'Split the page into pages of at most 1 MiB.'
    'DOCS_PAGE_ENCODING_INVALID'     = 'Save the page as UTF-8.'
    'DOCS_PAGE_ROOT_EMPTY'           = 'Add a Markdown page under the documentation root, or correct its path.'
    'DOCS_PAGE_ROOT_ENTRY_MISSING'   = 'Add a README.md or index.md entry page to the documentation root.'
    'DOCS_PAGE_PATH_UNMATCHED'       = 'Pass a -Path that names a page or a directory of pages in a documentation root.'
}
$script:DocsPageSuppressDiataxisCode = @('DOCS_PAGE_MODE_INVALID', 'DOCS_PAGE_FRONT_MATTER_SCHEMA_INVALID')

function New-DocsPageCheckFinding {
    <#
    .SYNOPSIS
        Builds one check finding with the fixed next action of its code (private helper).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [string] $Code,
        [Parameter(Mandatory = $true)] [string] $Message,
        [AllowNull()] [string] $ArtifactPath,
        [AllowEmptyString()] [string] $Pointer = '',
        [AllowNull()] [AllowEmptyCollection()] [string[]] $RelatedPath
    )

    return New-DocsFinding -Code $Code -Severity 'error' -Message $Message -NextAction $script:DocsPageCheckNextAction[$Code] -ArtifactPath $ArtifactPath -Pointer $Pointer -RelatedPath $RelatedPath
}

function Get-DocsPageProfileList {
    <#
    .SYNOPSIS
        Returns a member of a profile object as an array, or an empty array when absent (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [AllowNull()] [object] $Container,
        [Parameter(Mandatory = $true)] [string] $Name
    )

    if ($Container -isnot [System.Collections.IDictionary] -or -not $Container.Contains($Name) -or $null -eq $Container[$Name]) { return , [object[]] @() }
    return , [object[]] @($Container[$Name])
}

function Get-DocsPageCandidatePath {
    <#
    .SYNOPSIS
        Returns the listed paths ending in .md (ordinal, case-sensitive), de-duplicated across roots and sorted ordinally.
    .DESCRIPTION
        RootListing maps each documentation-root path to the paths that Context.ListFile returned for it.
    #>
    [CmdletBinding()]
    [OutputType([string[]], [object[]])]
    param([Parameter(Mandatory = $true)] [System.Collections.IDictionary] $RootListing)

    $pages = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($root in $RootListing.Keys) {
        foreach ($path in @($RootListing[$root])) {
            if ($null -ne $path -and ([string] $path).EndsWith('.md', [System.StringComparison]::Ordinal)) { [void]$pages.Add([string] $path) }
        }
    }
    return , [string[]] @($pages)
}

function ConvertFrom-DocsPageBytes {
    <#
    .SYNOPSIS
        Decodes page bytes as strict UTF-8; returns @{ Text; Findings }.
    .DESCRIPTION
        A page above MaxBytes yields DOCS_PAGE_TOO_LARGE and an undecodable page
        DOCS_PAGE_ENCODING_INVALID; Text is then $null. A leading UTF-8 byte order mark is removed.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'The exported name is fixed by the issue #1021 specification; Bytes names the byte-array input.')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [byte[]] $Bytes,
        [Parameter(Mandatory = $true)] [string] $PagePath,
        [ValidateRange(1, [int]::MaxValue)] [int] $MaxBytes = 1048576
    )

    if ($Bytes.Length -gt $MaxBytes) {
        return @{ Text = $null; Findings = [object[]] @(New-DocsPageCheckFinding -Code 'DOCS_PAGE_TOO_LARGE' -Message 'page exceeds the 1 MiB scan bound' -ArtifactPath $PagePath) }
    }
    $offset = if ($Bytes.Length -ge 3 -and $Bytes[0] -eq 0xEF -and $Bytes[1] -eq 0xBB -and $Bytes[2] -eq 0xBF) { 3 } else { 0 }
    try {
        $text = [System.Text.UTF8Encoding]::new($false, $true).GetString($Bytes, $offset, $Bytes.Length - $offset)
    } catch [System.Text.DecoderFallbackException] {
        return @{ Text = $null; Findings = [object[]] @(New-DocsPageCheckFinding -Code 'DOCS_PAGE_ENCODING_INVALID' -Message 'page is not valid UTF-8' -ArtifactPath $PagePath) }
    }
    return @{ Text = $text; Findings = [object[]] @() }
}

function Get-DocsPageBodyModel {
    <#
    .SYNOPSIS
        Parses the front matter of a page text and returns @{ FrontMatter; LineModel } for the body (private helper).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text,
        [Parameter(Mandatory = $true)] [string] $PagePath
    )

    $frontMatter = ConvertFrom-DocsPageFrontMatter -Text $Text -PagePath $PagePath
    $lines = Split-DocsPageLine -Text $Text
    $start = [int] $frontMatter.BodyStartLine
    [string[]] $body = @(for ($index = $start - 1; $index -lt $lines.Count; $index++) { $lines[$index] })
    $model = Get-DocsPageLineModel -Line $body -FirstLineNumber $start
    return @{ FrontMatter = $frontMatter; LineModel = $model }
}

function ConvertTo-DocsPageEntry {
    <#
    .SYNOPSIS
        Normalizes one page map value to @{ Text; Findings } (private helper).
    .DESCRIPTION
        A string is decoded page text; a dictionary is a ConvertFrom-DocsPageBytes result.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([AllowNull()] [object] $Value)

    if ($Value -is [System.Collections.IDictionary]) {
        $text = if ($Value.Contains('Text')) { $Value['Text'] } else { $null }
        $findings = [object[]] @(if ($Value.Contains('Findings')) { @($Value['Findings'] | Where-Object { $null -ne $_ }) })
        return @{ Text = $text; Findings = $findings }
    }
    return @{ Text = $(if ($null -eq $Value) { '' } else { [string] $Value }); Findings = [object[]] @() }
}

function Get-DocsPageLinkMap {
    <#
    .SYNOPSIS
        Returns @{ Model; Link } maps (page path to body line model and to links) for every decodable page (private helper).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [System.Collections.IDictionary] $PageText)

    $models = [ordered]@{}
    $links = [ordered]@{}
    foreach ($page in $PageText.Keys) {
        $entry = ConvertTo-DocsPageEntry -Value $PageText[$page]
        if ($entry.Findings.Count -gt 0 -or $null -eq $entry.Text) { continue }
        $body = Get-DocsPageBodyModel -Text ([string] $entry.Text) -PagePath ([string] $page)
        $models[[string] $page] = $body
        $links[[string] $page] = Get-DocsPageLink -LineModel $body.LineModel
    }
    return @{ Model = $models; Link = $links }
}

function Get-DocsPageFieldRuleFinding {
    <#
    .SYNOPSIS
        Returns the front-matter, field and Diataxis findings of one decoded page (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [string] $PagePath,
        [Parameter(Mandatory = $true)] [hashtable] $Body,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Policy,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $ComposedSchemaSet,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $RequiredField,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $AudienceId
    )

    $frontMatter = $Body.FrontMatter
    $findings = [System.Collections.Generic.List[object]]::new()
    $findings.AddRange([object[]] $frontMatter.Findings)
    if (-not $frontMatter.Present) {
        if ($RequiredField.Count -gt 0) { $findings.Add((New-DocsPageCheckFinding -Code 'DOCS_PAGE_FRONT_MATTER_MISSING' -Message "front matter block is missing; required fields: $($RequiredField -join ', ')" -ArtifactPath $PagePath)) }
        return , [object[]] $findings.ToArray()
    }
    if ($null -eq $frontMatter.Value) { return , [object[]] $findings.ToArray() }
    $fields = Test-DocsPageFrontMatter -FrontMatter $frontMatter.Value -PagePath $PagePath -ComposedSchemaSet $ComposedSchemaSet -RequiredField $RequiredField -AudienceId $AudienceId -FieldLine $frontMatter.FieldLine
    $findings.AddRange([object[]] $fields)
    $suppressed = @($fields | Where-Object { $script:DocsPageSuppressDiataxisCode -ccontains [string] $_['code'] }).Count -gt 0
    $mode = $frontMatter.Value['diataxis_mode']
    if (-not $suppressed -and $mode -is [string]) {
        $findings.AddRange([object[]] (Get-DocsPageDiataxisFinding -PagePath $PagePath -DeclaredMode $mode -LineModel $Body.LineModel -DiataxisPolicy $Policy))
    }
    return , [object[]] $findings.ToArray()
}

function Select-DocsPageCheckFinding {
    <#
    .SYNOPSIS
        Applies -Path selection: keeps profile and path-less findings and findings of selected pages, and adds DOCS_PAGE_PATH_UNMATCHED (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Finding,
        [Parameter(Mandatory = $true)] [string[]] $SelectedPath,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $PageSet,
        [Parameter(Mandatory = $true)] [string] $ProfilePath
    )

    $prefixes = [string[]] @($SelectedPath | ForEach-Object { ([string] $_).TrimEnd('/') })
    $kept = [System.Collections.Generic.List[object]]::new()
    foreach ($item in $Finding) {
        $path = [string] $item['artifact_path']
        $covered = @($prefixes | Where-Object { $path -ceq $_ -or $path.StartsWith("$_/", [System.StringComparison]::Ordinal) }).Count -gt 0
        if ($path.Length -eq 0 -or $path -ceq $ProfilePath -or $covered) { $kept.Add($item) }
    }
    foreach ($selected in $SelectedPath) {
        $prefix = ([string] $selected).TrimEnd('/')
        $matched = @($PageSet | Where-Object { $_ -ceq $prefix -or $_.StartsWith("$prefix/", [System.StringComparison]::Ordinal) }).Count -gt 0
        if (-not $matched) { $kept.Add((New-DocsPageCheckFinding -Code 'DOCS_PAGE_PATH_UNMATCHED' -Message "-Path '$selected' matches no page in the documentation roots" -ArtifactPath $null -RelatedPath @($prefix))) }
    }
    return , [object[]] $kept.ToArray()
}

function Get-DocsPageCheckFinding {
    <#
    .SYNOPSIS
        Runs every page rule over an in-memory page map; returns @{ Findings; Result }.
    .DESCRIPTION
        PageText maps each page path to its decoded text, or to a ConvertFrom-DocsPageBytes
        result. Profile is a parsed docs profile; ComposedSchemaSet is the Schemas map of
        Get-DocsComposedSchemaSet; ExistingPath lists the non-page link targets that exist.
        SelectedPath restricts reported page findings to pages equal to, or under, a given
        path; links, anchors and reachability are still computed over the full page set.
        Result is {page_count, profile_path, roots[{id, page_count, path}]} with roots in
        profile order. Findings are in Get-DocsOrderedFinding order, not truncated.
        LinkMap is the @{ Model; Link } result of the private link-map helper Get-DocsPageLinkMap
        for the same PageText; when it is $null the map is built here.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $PageText,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Profile,
        [Parameter(Mandatory = $true)] [string] $ProfilePath,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $ComposedSchemaSet,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $ExistingPath,
        [AllowNull()] [AllowEmptyCollection()] [string[]] $SelectedPath,
        [AllowNull()] [hashtable] $LinkMap = $null
    )

    [string[]] $pageSet = @($PageText.Keys | ForEach-Object { [string] $_ })
    [Array]::Sort($pageSet, [System.StringComparer]::Ordinal)
    $policy = if ($Profile.Contains('diataxis_policy') -and $Profile['diataxis_policy'] -is [System.Collections.IDictionary]) { $Profile['diataxis_policy'] } else { [ordered]@{} }
    # The list helper returns its array with the unary comma, so each result is assigned before it is enumerated.
    $requiredList = Get-DocsPageProfileList -Container $policy -Name 'required_front_matter'
    $audienceList = Get-DocsPageProfileList -Container $Profile -Name 'audiences'
    [string[]] $required = @($requiredList | ForEach-Object { [string] $_ })
    [string[]] $audiences = @($audienceList | ForEach-Object { [string] $_['id'] })
    $findings = [System.Collections.Generic.List[object]]::new()

    $roots = Get-DocsPageProfileList -Container $Profile -Name 'documentation_roots'
    $rootResult = [System.Collections.Generic.List[object]]::new()
    $entries = [System.Collections.Generic.List[string]]::new()
    for ($index = 0; $index -lt $roots.Count; $index++) {
        $id = [string] $roots[$index]['id']
        $rootPath = ([string] $roots[$index]['path']).TrimEnd('/')
        [string[]] $rootPages = @($pageSet | Where-Object { $_.StartsWith("$rootPath/", [System.StringComparison]::Ordinal) })
        $rootResult.Add([ordered]@{ id = $id; page_count = [long] $rootPages.Count; path = [string] $roots[$index]['path'] })
        $pointer = "/documentation_roots/$index/path"
        if ($rootPages.Count -eq 0) {
            $findings.Add((New-DocsPageCheckFinding -Code 'DOCS_PAGE_ROOT_EMPTY' -Message "documentation root '$id' at '$($roots[$index]['path'])' contains no Markdown page" -ArtifactPath $ProfilePath -Pointer $pointer))
            continue
        }
        $entry = Get-DocsPageEntryPage -RootPath $rootPath -PageSet $rootPages
        if ($null -eq $entry) { $findings.Add((New-DocsPageCheckFinding -Code 'DOCS_PAGE_ROOT_ENTRY_MISSING' -Message "documentation root '$id' has no README.md or index.md entry page" -ArtifactPath $ProfilePath -Pointer $pointer)) }
        else { $entries.Add($entry) }
    }

    $map = $LinkMap
    if ($null -eq $map) { $map = Get-DocsPageLinkMap -PageText $PageText }
    $anchors = @{}
    foreach ($page in $map.Model.Keys) { $anchors[$page] = Get-DocsPageAnchor -LineModel $map.Model[$page].LineModel }
    $edges = @{}
    foreach ($page in $pageSet) {
        $entryValue = ConvertTo-DocsPageEntry -Value $PageText[$page]
        $findings.AddRange([object[]] $entryValue.Findings)
        if (-not $map.Model.Contains($page)) { continue }
        $findings.AddRange([object[]] (Get-DocsPageFieldRuleFinding -PagePath $page -Body $map.Model[$page] -Policy $policy -ComposedSchemaSet $ComposedSchemaSet -RequiredField $required -AudienceId $audiences))
        $linkResult = Get-DocsPageLinkFinding -PagePath $page -Link $map.Link[$page] -PageAnchor $anchors -PageSet $pageSet -ExistingPath $ExistingPath
        $findings.AddRange([object[]] $linkResult.Findings)
        $edges[$page] = $linkResult.Edges
    }
    $reachable = Get-DocsPageReachable -EntryPage $entries.ToArray() -Edge $edges
    $findings.AddRange([object[]] (Get-DocsPageOrphanFinding -PageSet $pageSet -Reachable $reachable))

    $all = [object[]] $findings.ToArray()
    if ($null -ne $SelectedPath -and $SelectedPath.Count -gt 0) { $all = Select-DocsPageCheckFinding -Finding $all -SelectedPath $SelectedPath -PageSet $pageSet -ProfilePath $ProfilePath }
    # A plain assignment keeps a one-finding array an array; an if expression would unroll it.
    $ordered = [object[]] @()
    if ($all.Count -gt 0) { $ordered = Get-DocsOrderedFinding -Finding $all -Limit 10000 }
    $result = [ordered]@{ page_count = [long] $pageSet.Count; profile_path = $ProfilePath; roots = [object[]] $rootResult.ToArray() }
    return @{ Findings = $ordered; Result = $result }
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

function New-DocsCheckUsageResult {
    <#
    .SYNOPSIS
        Returns an exit-2 check result with exactly one DOCS_CLI_ARGUMENTS finding (private helper).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)] [string] $Message)

    $finding = New-DocsFinding -Code 'DOCS_CLI_ARGUMENTS' -Severity 'error' -Message $Message -NextAction 'Run Invoke-DocsCommand.ps1 -Help for the check options.'
    return New-DocsCommandResult -Command 'check' -ExitCode 2 -Finding @($finding)
}

function Invoke-DocsCheckCommand {
    <#
    .SYNOPSIS
        Checks the documentation pages of every documentation root of the profile.
    .DESCRIPTION
        Options: Profile (value, default Get-DocsDefaultProfilePath) and Path (multi). Exit 0
        when no error finding exists, 1 for any error finding or DOCS_PROFILE_MISSING, 2 for a
        non-relative -Profile or -Path. An uncomposable schema set or a read failure other than
        absence throws, which the entry boundary reports as exit 3 with DOCS_CLI_RUNTIME.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Argument,
        [Parameter(Mandatory = $true)] [object] $Context
    )

    $profilePath = if ($Argument.Contains('Profile') -and $null -ne $Argument['Profile']) { [string] $Argument['Profile'] } else { Get-DocsDefaultProfilePath }
    [string[]] $selected = @(if ($Argument.Contains('Path') -and $null -ne $Argument['Path']) { $Argument['Path'] | ForEach-Object { [string] $_ } })
    if (-not (Test-DocsRelativePath -Path $profilePath)) { return New-DocsCheckUsageResult -Message "Profile '$profilePath' is not a repository-relative path." }
    foreach ($path in $selected) {
        if (-not (Test-DocsRelativePath -Path $path)) { return New-DocsCheckUsageResult -Message "Path '$path' is not a repository-relative path." }
    }

    try {
        $profileText = [string] (Invoke-DocsContextMember -Member $Context.ReadText -ArgumentList @($profilePath))
    } catch [System.Management.Automation.ItemNotFoundException] {
        $missing = New-DocsFinding -Code 'DOCS_PROFILE_MISSING' -Severity 'error' -Message "The profile $profilePath does not exist." -NextAction 'Run Invoke-DocsCommand.ps1 -Command init -Write, or pass -Profile with an existing profile.' -ArtifactPath $profilePath
        return New-DocsCommandResult -Command 'check' -ExitCode 1 -Finding @($missing)
    }
    $composed = Get-DocsComposedSchemaSet -SchemaSet (Read-DocsSchemaSet)
    if (@($composed.Findings).Count -gt 0) { throw "DOCS_SCHEMA_COMPOSITION_FAILED: $($composed.Findings[0].code) $($composed.Findings[0].message)" }
    $check = ConvertFrom-DocsProfileText -Text $profileText -ArtifactPath $profilePath -ComposedSchemaSet $composed.Schemas
    if (-not $check.Ok -or $null -eq $check.Profile) { return New-DocsCommandResult -Command 'check' -ExitCode 1 -Finding $check.Findings }

    # Every list helper returns its array with the unary comma, so each result is assigned before it is enumerated.
    $roots = Get-DocsPageProfileList -Container $check.Profile -Name 'documentation_roots'
    $listing = [ordered]@{}
    foreach ($root in $roots) {
        $rootPath = [string] $root['path']
        $listing[$rootPath] = Invoke-DocsContextMember -Member $Context.ListFile -ArgumentList @($rootPath)
    }
    $candidates = Get-DocsPageCandidatePath -RootListing $listing
    $pageText = [ordered]@{}
    foreach ($page in $candidates) {
        $bytes = [byte[]] (Invoke-DocsContextMember -Member $Context.ReadBytes -ArgumentList @($page))
        $pageText[$page] = ConvertFrom-DocsPageBytes -Bytes $bytes -PagePath $page
    }
    [string[]] $pageSet = @($pageText.Keys)
    $existing = [System.Collections.Generic.List[string]]::new()
    # The link map is built once per run and shared by the external-target probe and the page rules.
    $linkMap = Get-DocsPageLinkMap -PageText $pageText
    $external = Get-DocsPageExternalTarget -PageLink $linkMap.Link -PagePath $pageSet
    foreach ($path in $external) {
        if ([bool] (Invoke-DocsContextMember -Member $Context.TestFile -ArgumentList @($path))) { $existing.Add($path) }
    }
    $outcome = Get-DocsPageCheckFinding -PageText $pageText -Profile $check.Profile -ProfilePath $profilePath -ComposedSchemaSet $composed.Schemas -ExistingPath $existing.ToArray() -SelectedPath $selected -LinkMap $linkMap
    $all = [object[]] (@($check.Findings) + @($outcome.Findings) | Where-Object { $null -ne $_ })
    $exitCode = if (Test-DocsFindingHasError -Finding $all) { 1 } else { 0 }
    $line = "check: pages=$($outcome.Result['page_count']) roots=$(@($outcome.Result['roots']).Count)"
    return New-DocsCommandResult -Command 'check' -ExitCode $exitCode -Finding $all -Result $outcome.Result -Line @($line)
}

Export-ModuleMember -Function `
    Get-DocsPageCandidatePath, `
    ConvertFrom-DocsPageBytes, `
    Get-DocsPageCheckFinding, `
    Invoke-DocsCheckCommand
