<#
.SYNOPSIS
    Development-docs root resolver and feature-folder name rules (issue #1035).

.DESCRIPTION
    Resolves the development-records root from the flat key development_docs_root of
    config/orchestration-routing.json (rules R-1 to R-8), maps area names onto a root,
    exposes the known-root prefixes and regex patterns that matchers accept during the
    fallback release, and parses and formats feature-folder names (F-1 to F-6, N-1 to N-5).

    Resolve-DevelopmentDocsRoot performs I/O only through its -ReadText and -TestDirectory
    script blocks and returns a typed result (Succeeded, Root, Reason) so that hooks can
    fail closed with a clear reason. Every other function is pure.

.NOTES
    PowerShell 7+. Mirrored byte-identically under extensions/drm-copilot/resources/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:DevelopmentDocsRootKey = 'development_docs_root'
$script:DevelopmentDocsRoutingFile = 'config/orchestration-routing.json'
$script:DefaultDevelopmentDocsRoot = 'docs/features'
$script:KnownDevelopmentDocsRoots = @('docs/features', '.dev')
$script:RootChildAreas = @('active', 'completed', 'archive', 'potential', 'potential/promoted', 'epics', 'parallel', 'templates')
$script:SiblingAreaPaths = @{
    'backlog'             = @{ 'docs/features' = 'docs/features/backlog.md'; '.dev' = '.dev/backlog.md' }
    'research'            = @{ 'docs/features' = 'docs/research'; '.dev' = '.dev/research' }
    'discovery-templates' = @{ 'docs/features' = 'docs/discovery/templates'; '.dev' = '.dev/discovery/templates' }
    'engineering'         = @{ 'docs/features' = 'docs/engineering'; '.dev' = '.dev/engineering' }
}
$script:FileAreas = @('backlog')
$script:FeatureNamePattern = '^[a-z0-9]+(?:[-_][a-z0-9]+)*$'
$script:MaxFeatureFolderIssue = 9999

# Private: join a workspace root and a repository-relative path with '/'.
function Join-DevelopmentDocsWorkspacePath {
    [CmdletBinding()] [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $WorkspaceRoot,
        [Parameter(Mandatory = $true)] [string] $RelativePath
    )

    $base = ($WorkspaceRoot -replace '\\', '/').TrimEnd('/')
    if ($base -eq '') { return $RelativePath }
    return "$base/$RelativePath"
}

# Private: render a parsed JSON value for an error message.
function ConvertTo-DevelopmentDocsValueText {
    [CmdletBinding()] [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowNull()] [object] $Value)

    if ($null -eq $Value) { return 'null' }
    return (ConvertTo-Json -InputObject $Value -Compress -Depth 5)
}

# Private: a typed resolution result.
function ConvertTo-DevelopmentDocsRootResult {
    [CmdletBinding()] [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [bool] $Succeeded,
        [AllowNull()] [string] $Root,
        [AllowNull()] [string] $Reason
    )

    return [pscustomobject]@{ Succeeded = $Succeeded; Root = $Root; Reason = $Reason }
}

<#
.SYNOPSIS
    Resolves the development-docs root of a workspace (rules R-1 to R-8).
.PARAMETER WorkspaceRoot
    Root that holds config/orchestration-routing.json.
.PARAMETER ReadText
    Script block that returns the file text, $null when the file is absent, and throws when it is unreadable.
.PARAMETER TestDirectory
    Script block that returns $true when a directory exists.
.OUTPUTS
    An object with Succeeded, Root, and Reason; Reason names the file, the key, and the value on failure.
#>
function Resolve-DevelopmentDocsRoot {
    [CmdletBinding()] [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $WorkspaceRoot,
        [scriptblock] $ReadText = {
            param([string] $Path)
            if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $null }
            return (Get-Content -LiteralPath $Path -Raw -ErrorAction Stop)
        },
        [scriptblock] $TestDirectory = { param([string] $Path) Test-Path -LiteralPath $Path -PathType Container }
    )

    $file = $script:DevelopmentDocsRoutingFile
    $key = $script:DevelopmentDocsRootKey
    $default = $script:DefaultDevelopmentDocsRoot
    $configPath = Join-DevelopmentDocsWorkspacePath -WorkspaceRoot $WorkspaceRoot -RelativePath $file

    try {
        $text = & $ReadText $configPath
    } catch {
        # R-1: an unreadable file resolves the default root.
        return (ConvertTo-DevelopmentDocsRootResult -Succeeded $true -Root $default -Reason $null)
    }
    if ($null -eq $text) {
        return (ConvertTo-DevelopmentDocsRootResult -Succeeded $true -Root $default -Reason $null)
    }

    try {
        $parsed = ConvertFrom-Json -InputObject ([string] $text) -AsHashtable -NoEnumerate -DateKind String -ErrorAction Stop
    } catch {
        $reason = "$file is not valid JSON, so $key cannot be read (value: unparseable; $($_.Exception.Message))."
        return (ConvertTo-DevelopmentDocsRootResult -Succeeded $false -Root $null -Reason $reason)
    }
    if ($parsed -isnot [System.Collections.IDictionary]) {
        $valueText = ConvertTo-DevelopmentDocsValueText -Value $parsed
        $reason = "$file is not a JSON object, so $key cannot be read (value: $valueText)."
        return (ConvertTo-DevelopmentDocsRootResult -Succeeded $false -Root $null -Reason $reason)
    }

    $matchedKey = @($parsed.Keys | Where-Object { $_ -ceq $key })
    if ($matchedKey.Count -eq 0) {
        # R-2: no .dev probe when the key is absent.
        return (ConvertTo-DevelopmentDocsRootResult -Succeeded $true -Root $default -Reason $null)
    }
    $value = $parsed[$matchedKey[0]]
    $isKnown = ($value -is [string]) -and ($script:KnownDevelopmentDocsRoots -ccontains $value)
    if (-not $isKnown) {
        $valueText = ConvertTo-DevelopmentDocsValueText -Value $value
        $reason = "$file $key value $valueText is not one of: $($script:KnownDevelopmentDocsRoots -join ', ')."
        return (ConvertTo-DevelopmentDocsRootResult -Succeeded $false -Root $null -Reason $reason)
    }
    if ($value -ceq $default) {
        return (ConvertTo-DevelopmentDocsRootResult -Succeeded $true -Root $default -Reason $null)
    }
    if (& $TestDirectory (Join-DevelopmentDocsWorkspacePath -WorkspaceRoot $WorkspaceRoot -RelativePath '.dev')) {
        return (ConvertTo-DevelopmentDocsRootResult -Succeeded $true -Root '.dev' -Reason $null)
    }
    if (& $TestDirectory (Join-DevelopmentDocsWorkspacePath -WorkspaceRoot $WorkspaceRoot -RelativePath $default)) {
        return (ConvertTo-DevelopmentDocsRootResult -Succeeded $true -Root $default -Reason $null)
    }
    return (ConvertTo-DevelopmentDocsRootResult -Succeeded $true -Root '.dev' -Reason $null)
}

<#
.SYNOPSIS
    Maps an area name onto a known root (spec area map); throws for an unknown area or root.
#>
function Get-DevelopmentDocsPath {
    [CmdletBinding()] [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [string] $Root,
        [Parameter(Mandatory = $true)] [string] $Area
    )

    if ($script:KnownDevelopmentDocsRoots -cnotcontains $Root) {
        throw "Unknown development docs root: $Root"
    }
    if ($script:RootChildAreas -ccontains $Area) {
        return "$Root/$Area"
    }
    $sibling = $null
    foreach ($name in $script:SiblingAreaPaths.Keys) {
        if ($name -ceq $Area) { $sibling = $script:SiblingAreaPaths[$name] }
    }
    if ($null -eq $sibling) {
        throw "Unknown development docs area: $Area"
    }
    return $sibling[$Root]
}

<#
.SYNOPSIS
    Returns the known roots in order, the default root first.
#>
function Get-DevelopmentDocsKnownRoot {
    [CmdletBinding()] [OutputType([string])]
    param()

    foreach ($root in $script:KnownDevelopmentDocsRoots) { [string] $root }
}

<#
.SYNOPSIS
    Returns the prefixes of an area under every known root, in root order.
.DESCRIPTION
    Directory areas end with '/'; the file area backlog is the exact path.
#>
function Get-DevelopmentDocsKnownRootPrefix {
    [CmdletBinding()] [OutputType([string])]
    param([Parameter(Mandatory = $true)] [string] $Area)

    $suffix = if ($script:FileAreas -ccontains $Area) { '' } else { '/' }
    $prefixes = foreach ($root in $script:KnownDevelopmentDocsRoots) {
        (Get-DevelopmentDocsPath -Root $root -Area $Area) + $suffix
    }
    return $prefixes
}

# Private: regex for one forward-slash path with either separator between segments.
function ConvertTo-DevelopmentDocsSeparatorPattern {
    [CmdletBinding()] [OutputType([string])]
    param([Parameter(Mandatory = $true)] [string] $Path)

    $segments = foreach ($segment in $Path.Split('/')) { [regex]::Escape($segment) }
    return ($segments -join '[\\/]')
}

<#
.SYNOPSIS
    Returns a regex that matches any known root, or the forms of one area under every known root.
.DESCRIPTION
    With -Area: the regex-escaped union of both roots' forms of that area, either separator
    (spec OD-P1); an unknown area raises the area-map error. Without -Area: the root
    alternation, both roots with either separator and no area segment. The pattern is an
    unanchored non-capturing group; callers add anchors.
#>
function Get-DevelopmentDocsKnownRootPattern {
    [CmdletBinding()] [OutputType([string])]
    param([string] $Area)

    $forms = foreach ($root in $script:KnownDevelopmentDocsRoots) {
        if ($PSBoundParameters.ContainsKey('Area')) {
            ConvertTo-DevelopmentDocsSeparatorPattern -Path (Get-DevelopmentDocsPath -Root $root -Area $Area)
        } else {
            ConvertTo-DevelopmentDocsSeparatorPattern -Path $root
        }
    }
    return '(?:' + ($forms -join '|') + ')'
}

# Private: split a trailing -<digits> issue suffix.
function Split-DevelopmentDocsTrailingIssue {
    [CmdletBinding()] [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)] [string] $Text)

    $match = [regex]::Match($Text, '^(.+)-([0-9]+)$')
    if (-not $match.Success) {
        return [pscustomobject]@{ Feature = $Text; IssueNumber = $null }
    }
    return [pscustomobject]@{ Feature = $match.Groups[1].Value; IssueNumber = [long] $match.Groups[2].Value }
}

<#
.SYNOPSIS
    Parses a feature-folder name into Format, Date, Feature, and IssueNumber (F-1 to F-6).
#>
function ConvertFrom-FeatureFolderName {
    [CmdletBinding()] [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)] [string] $Name)

    $dated = [regex]::Match($Name, '^([0-9]{4}-[0-9]{2}-[0-9]{2})-(.+)$')
    if ($dated.Success) {
        $rest = Split-DevelopmentDocsTrailingIssue -Text $dated.Groups[2].Value
        return [pscustomobject]@{ Format = 'date-first'; Date = $dated.Groups[1].Value; Feature = $rest.Feature; IssueNumber = $rest.IssueNumber }
    }
    $issueFirst = [regex]::Match($Name, '^([0-9]{4})-(.+)$')
    if ($issueFirst.Success -and ([long] $issueFirst.Groups[1].Value) -gt 0) {
        return [pscustomobject]@{ Format = 'issue-first'; Date = $null; Feature = $issueFirst.Groups[2].Value; IssueNumber = [long] $issueFirst.Groups[1].Value }
    }
    $other = Split-DevelopmentDocsTrailingIssue -Text $Name
    return [pscustomobject]@{ Format = 'other'; Date = $null; Feature = $other.Feature; IssueNumber = $other.IssueNumber }
}

<#
.SYNOPSIS
    Formats the issue-first folder name <NNNN>-<feature> (N-1 to N-5).
.DESCRIPTION
    Removes a leading yyyy-MM-dd- date and a trailing -<issue> from the feature, then
    validates it. Throws for an issue that is not an integer from 1 to 9999 and for an
    empty feature, a feature failing the name pattern, or one beginning with dd-dd-.
#>
function ConvertTo-FeatureFolderName {
    [CmdletBinding()] [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [object] $IssueNumber,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Feature
    )

    $isInteger = ($IssueNumber -is [int]) -or ($IssueNumber -is [long])
    if (-not $isInteger -or $IssueNumber -le 0) {
        throw "Feature folder issue number must be a positive integer: $IssueNumber"
    }
    if ($IssueNumber -gt $script:MaxFeatureFolderIssue) {
        throw "Feature folder issue number must be at most $($script:MaxFeatureFolderIssue): $IssueNumber"
    }
    $stem = $Feature -replace '^[0-9]{4}-[0-9]{2}-[0-9]{2}-', ''
    $issueSuffix = "-$IssueNumber"
    if ($stem.EndsWith($issueSuffix, [System.StringComparison]::Ordinal) -and $stem.Length -gt $issueSuffix.Length) {
        $stem = $stem.Substring(0, $stem.Length - $issueSuffix.Length)
    }
    if ($stem -eq '' -or $stem -cnotmatch $script:FeatureNamePattern -or $stem -match '^[0-9]{2}-[0-9]{2}-') {
        throw "Feature folder feature name is invalid: $(ConvertTo-Json -InputObject $Feature -Compress)"
    }
    return ('{0:D4}-{1}' -f [long] $IssueNumber, $stem)
}

Export-ModuleMember -Function `
    Resolve-DevelopmentDocsRoot, `
    Get-DevelopmentDocsPath, `
    Get-DevelopmentDocsKnownRoot, `
    Get-DevelopmentDocsKnownRootPrefix, `
    Get-DevelopmentDocsKnownRootPattern, `
    ConvertFrom-FeatureFolderName, `
    ConvertTo-FeatureFolderName
