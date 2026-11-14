<#
.SYNOPSIS
    Starter source-root detection and the source-root existence finding of the documentation
    profile commands (issue #1173 B6).

.DESCRIPTION
    Get-DocsProfileSourceRootDefault returns the source root that init writes into a starter
    profile: 'src' when the ListFile seam lists a file under it; otherwise the package directory
    named by pyproject.toml when that directory lists a file; otherwise 'src', which
    validate-profile and init then report with DOCS_PROFILE_SOURCE_ROOT_MISSING. The package
    directory comes from the first present key in this order: [tool.poetry].packages[].include
    (inline array or array of tables; the first include), [project].name, [tool.poetry].name;
    a '-' in a name is mapped to '_'. Keys are located with Get-DocsTomlKey of DocsTomlKeys.psm1
    and the one-line string value is read from the reported span. A candidate that fails
    Test-DocsRelativePath is not listed. A '.' root is never returned, because the docs common
    relative-path grammar rejects it.

    Get-DocsProfileSourceRootFinding returns one DOCS_PROFILE_SOURCE_ROOT_MISSING error finding
    at /surface_selection/source_roots/<i> for each source root for which ListFile returns no
    file. A root that fails Test-DocsRelativePath is skipped without a ListFile call, because the
    profile schema already reports it.

    The functions read no file, clock, process or environment: listings come only from the
    ListFile scriptblock and pyproject.toml arrives as text.

.NOTES
    Issue #1173. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsFinding.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSurface.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSourceText.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsTomlKeys.psm1') -ErrorAction Stop

$script:DocsProfileDefaultSourceRoot = 'src'
$script:DocsProfileTomlStringPattern = '(?:"(?<value>[^"\\\r\n]*)"|''(?<value>[^''\r\n]*)'')'

function Test-DocsProfileRootListsFile {
    <#
    .SYNOPSIS
        Returns $true when the ListFile scriptblock lists at least one file under Root (private helper).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)] [string] $Root,
        [Parameter(Mandatory = $true)] [scriptblock] $ListFile
    )

    $listed = @(& $ListFile $Root)
    return @($listed | Where-Object { -not [string]::IsNullOrEmpty([string] $_) }).Count -gt 0
}

function Get-DocsProfileTomlKeyValue {
    <#
    .SYNOPSIS
        Returns the first one-line string value matched by Pattern within the span of the TOML key Path, else $null (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [object[]] $Key,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $Line,
        [Parameter(Mandatory = $true)] [string] $Path,
        [Parameter(Mandatory = $true)] [string] $Pattern
    )

    foreach ($entry in $Key) {
        if ((@($entry['Segment']) -join '.') -cne $Path) { continue }
        $first = [int] $entry['Span'][0] - 1
        $last = [Math]::Min([int] $entry['Span'][1], $Line.Count) - 1
        $text = (@($Line[$first..$last]) -join "`n")
        $match = [regex]::Match($text, $Pattern)
        if ($match.Success) { return $match.Groups['value'].Value }
        return $null
    }
    return $null
}

function Get-DocsProfilePyprojectPackage {
    <#
    .SYNOPSIS
        Returns the package directory named by pyproject.toml text, or $null (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([AllowNull()] [AllowEmptyString()] [string] $Text)

    if ([string]::IsNullOrEmpty($Text)) { return $null }
    $scan = Get-DocsTomlKey -Text $Text
    if (@($scan['Diagnostics'] | Where-Object { $_['Blocking'] }).Count -gt 0) { return $null }
    $keys = [object[]] @($scan['Keys'])
    # ConvertTo-DocsSourceLine returns its array with a comma, so it is assigned without @().
    $lines = ConvertTo-DocsSourceLine -Text $Text
    $includePattern = 'include\s*=\s*' + $script:DocsProfileTomlStringPattern
    $namePattern = '=\s*' + $script:DocsProfileTomlStringPattern
    $include = Get-DocsProfileTomlKeyValue -Key $keys -Line $lines -Path 'tool.poetry.packages' -Pattern $includePattern
    if ($null -eq $include) { $include = Get-DocsProfileTomlKeyValue -Key $keys -Line $lines -Path 'tool.poetry.packages.[].include' -Pattern $namePattern }
    if (-not [string]::IsNullOrEmpty($include)) { return $include.TrimEnd('/') }
    foreach ($namePath in @('project.name', 'tool.poetry.name')) {
        $name = Get-DocsProfileTomlKeyValue -Key $keys -Line $lines -Path $namePath -Pattern $namePattern
        if (-not [string]::IsNullOrEmpty($name)) { return $name.Replace('-', '_') }
    }
    return $null
}

function Get-DocsProfileSourceRootDefault {
    <#
    .SYNOPSIS
        Returns the starter source root: src, else the pyproject.toml package directory, else src.
    .DESCRIPTION
        ListFile is invoked with one repository-relative root and returns the files under it (the
        Context.ListFile member). PyprojectText is the text of the repository-root
        pyproject.toml, or $null when the file is absent. 'src' is returned when it lists a
        file; otherwise the package directory of Get-DocsProfilePyprojectPackage when it passes
        Test-DocsRelativePath and lists a file; otherwise 'src' (premise correction PC-1 of issue
        #1173: '.' is not a valid relative path).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowNull()] [AllowEmptyString()] [string] $PyprojectText,
        [Parameter(Mandatory = $true)] [scriptblock] $ListFile
    )

    if (Test-DocsProfileRootListsFile -Root $script:DocsProfileDefaultSourceRoot -ListFile $ListFile) { return $script:DocsProfileDefaultSourceRoot }
    $package = Get-DocsProfilePyprojectPackage -Text $PyprojectText
    if ((Test-DocsRelativePath -Path $package) -and (Test-DocsProfileRootListsFile -Root $package -ListFile $ListFile)) { return $package }
    return $script:DocsProfileDefaultSourceRoot
}

function Get-DocsProfileSourceRootFinding {
    <#
    .SYNOPSIS
        Returns one DOCS_PROFILE_SOURCE_ROOT_MISSING error finding per source root that lists no file.
    .DESCRIPTION
        Each finding carries the pointer /surface_selection/source_roots/<i> and the artifact path
        ProfilePath. A root that fails Test-DocsRelativePath is skipped without a ListFile call.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [AllowNull()] [string[]] $SourceRoot,
        [Parameter(Mandatory = $true)] [scriptblock] $ListFile,
        [Parameter(Mandatory = $true)] [string] $ProfilePath
    )

    $findings = [System.Collections.Generic.List[object]]::new()
    $roots = [string[]] @($SourceRoot)
    for ($index = 0; $index -lt $roots.Count; $index++) {
        $root = $roots[$index]
        if (-not (Test-DocsRelativePath -Path $root)) { continue }
        if (Test-DocsProfileRootListsFile -Root $root -ListFile $ListFile) { continue }
        $findings.Add((New-DocsFinding -Code 'DOCS_PROFILE_SOURCE_ROOT_MISSING' -Severity 'error' -Message "The source root '$root' lists no file." -NextAction 'Set surface_selection.source_roots to directories that hold the source files, then run the command again.' -ArtifactPath $ProfilePath -Pointer "/surface_selection/source_roots/$index"))
    }
    return $findings.ToArray()
}

Export-ModuleMember -Function Get-DocsProfileSourceRootDefault, Get-DocsProfileSourceRootFinding
