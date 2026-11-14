<#
.SYNOPSIS
    Heading slugs, page anchors, link extraction, link target resolution and the link and
    anchor findings of the documentation page checker.

.DESCRIPTION
    Every function reads the line model of DocsPageMarkdown.psm1, so fenced code, HTML comments
    and inline code-span contents produce no link and no explicit anchor. Get-DocsPageSlug
    applies the slug rule: links and images reduced to their text, HTML tags removed,
    ToLowerInvariant, only letters, marks, decimal and letter numbers, connector punctuation,
    hyphen-minus and space kept (by code point), and each space replaced by a hyphen without
    collapsing. Get-DocsPageAnchor de-duplicates heading slugs per page with -1, -2 suffixes
    that skip taken values and adds explicit <a id> and <a name> anchors.

    Resolve-DocsPageLinkTarget skips URI schemes, // prefixes and empty targets; splits at the
    first #, drops a ?query, percent-decodes, resolves a leading / from the repository root and
    any other path against the page directory with POSIX segment normalization. Backslash is
    not a separator. Get-DocsPageLinkFinding reports DOCS_PAGE_LINK_BROKEN,
    DOCS_PAGE_LINK_ESCAPES_REPOSITORY, DOCS_PAGE_ANCHOR_MISSING and DOCS_PAGE_LINK_ANCHOR_MISSING
    and returns the page edges used for orphan detection.

    The model is lexical, not CommonMark: indented code blocks are not recognized, raw HTML
    links are not checked and fragments on targets outside the page set are not checked.

    Every function is pure: no filesystem, clock, process, environment or module-scope mutable
    state.

.NOTES
    Issue #1021. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsFinding.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsPageMarkdown.psm1') -ErrorAction Stop

$script:DocsPageInlineLinkPattern = '(?<bang>!?)\[(?<text>(?:[^\[\]]|\[[^\[\]]*\])*)\]\([ \t]*(?<dest><[^<>]*>|[^\s()<>]*(?:\([^\s()]*\)[^\s()<>]*)*)(?:[ \t]+(?:"[^"]*"|''[^'']*''|\([^()]*\)))?[ \t]*\)'
$script:DocsPageDefinitionPattern = '^ {0,3}\[(?<label>[^\]]+)\]:[ \t]*(?<dest><[^<>]*>|\S+)'
$script:DocsPageExplicitAnchorPattern = '(?i)<a\b[^>]*?\s(?:id|name)[ \t]*=[ \t]*(?:"(?<value>[^"]*)"|''(?<value>[^'']*)'')'
$script:DocsPageSchemePattern = '^[A-Za-z][A-Za-z0-9+.-]*:'
# A resolved path holding a character outside the docs common relative-path grammar cannot be a
# finding related path; such a path is reported in the message only.
$script:DocsPageUnrelatablePathPattern = '[\\:*?<>|\x00-\x1fSEPARATORS]'.Replace('SEPARATORS', [string][char]0x2028 + [char]0x2029)
$script:DocsPageSlugCategory = [System.Collections.Generic.HashSet[System.Globalization.UnicodeCategory]]::new(
    [System.Globalization.UnicodeCategory[]] @('UppercaseLetter', 'LowercaseLetter', 'TitlecaseLetter', 'ModifierLetter', 'OtherLetter', 'NonSpacingMark', 'SpacingCombiningMark', 'EnclosingMark', 'DecimalDigitNumber', 'LetterNumber', 'ConnectorPunctuation'))
$script:DocsPageLinkNextAction = @{
    'DOCS_PAGE_LINK_BROKEN'             = 'Correct the link target, or add the page or file it names.'
    'DOCS_PAGE_LINK_ESCAPES_REPOSITORY' = 'Point the link at a path inside the repository.'
    'DOCS_PAGE_ANCHOR_MISSING'          = 'Link to an existing heading or explicit anchor of this page, or add the anchor.'
    'DOCS_PAGE_LINK_ANCHOR_MISSING'     = 'Link to an existing heading or explicit anchor of the target page, or add the anchor there.'
}

function Get-DocsPageSlug {
    <#
    .SYNOPSIS
        Returns the base slug of one heading text.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $HeadingText)

    $text = [regex]::Replace($HeadingText, '!\[(?<alt>[^\]]*)\]\([^)]*\)', '${alt}')
    $text = [regex]::Replace($text, '\[(?<label>[^\]]*)\]\([^)]*\)', '${label}')
    $text = [regex]::Replace($text, '<[^<>]*>', '')
    $builder = [System.Text.StringBuilder]::new()
    foreach ($rune in $text.ToLowerInvariant().EnumerateRunes()) {
        if ($rune.Value -eq 0x20) { [void]$builder.Append('-'); continue }
        if ($rune.Value -eq 0x2D -or $script:DocsPageSlugCategory.Contains([System.Text.Rune]::GetUnicodeCategory($rune))) { [void]$builder.Append($rune.ToString()) }
    }
    return $builder.ToString()
}

function Get-DocsPageAnchor {
    <#
    .SYNOPSIS
        Returns the heading slugs, de-duplicated per page, plus explicit anchors, in document order.
    .DESCRIPTION
        A later heading whose base slug is taken receives the first free suffix -1, -2, ...;
        explicit <a id> and <a name> values are read from the masked text and are listed once.
    #>
    [CmdletBinding()]
    [OutputType([string[]], [object[]])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $LineModel)

    $anchors = [System.Collections.Generic.List[string]]::new()
    $taken = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($record in $LineModel) {
        if ([string] $record.Kind -ceq 'heading') {
            $base = Get-DocsPageSlug -HeadingText ([string] $record.HeadingText)
            $slug = $base
            $suffix = 0
            while ($taken.Contains($slug)) { $suffix++; $slug = "$base-$suffix" }
            [void]$taken.Add($slug)
            $anchors.Add($slug)
        }
        foreach ($match in [regex]::Matches([string] $record.Masked, $script:DocsPageExplicitAnchorPattern)) {
            $value = $match.Groups['value'].Value
            if ($value.Length -gt 0 -and $taken.Add($value)) { $anchors.Add($value) }
        }
    }
    return , [string[]] $anchors.ToArray()
}

function Add-DocsPageInlineLink {
    <#
    .SYNOPSIS
        Appends the inline links and images of one text, and of their link text, to a list (private helper).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text,
        [Parameter(Mandatory = $true)] [int] $Number,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [System.Collections.Generic.List[object]] $Link,
        [int] $Depth = 0
    )

    foreach ($match in [regex]::Matches($Text, $script:DocsPageInlineLinkPattern)) {
        $form = if ($match.Groups['bang'].Value.Length -gt 0) { 'image' } else { 'inline' }
        if ($Depth -eq 0) { Add-DocsPageInlineLink -Text $match.Groups['text'].Value -Number $Number -Link $Link -Depth 1 }
        $Link.Add([ordered]@{ Line = $Number; Target = $match.Groups['dest'].Value.TrimStart('<').TrimEnd('>'); Form = $form })
    }
}

function Get-DocsPageLink {
    <#
    .SYNOPSIS
        Returns @{ Line; Target; Form } for every inline link, image and reference definition.
    .DESCRIPTION
        Form is inline, image or definition. Links are read from the masked text, so fenced
        code, HTML comments and code-span contents produce none. An image nested in link text
        is listed before the link that contains it.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $LineModel)

    $links = [System.Collections.Generic.List[object]]::new()
    foreach ($record in $LineModel) {
        $masked = [string] $record.Masked
        if ([string]::IsNullOrWhiteSpace($masked)) { continue }
        $definition = [regex]::Match($masked, $script:DocsPageDefinitionPattern)
        if ($definition.Success) {
            $links.Add([ordered]@{ Line = [int] $record.Number; Target = $definition.Groups['dest'].Value.TrimStart('<').TrimEnd('>'); Form = 'definition' })
            continue
        }
        Add-DocsPageInlineLink -Text $masked -Number ([int] $record.Number) -Link $links
    }
    return , [object[]] $links.ToArray()
}

function Resolve-DocsPageLinkTarget {
    <#
    .SYNOPSIS
        Resolves one link target of a page to @{ Skip; Path; Fragment; EscapesRepository }.
    .DESCRIPTION
        Skip is $true for an empty target, a URI scheme or a // prefix. Path is the
        repository-relative POSIX path ('' for the repository root), or $null when the target
        resolves above the root (EscapesRepository $true). A fragment-only target resolves to
        the page itself. Fragment is the decoded text after the first #, or $null when absent
        or empty.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [string] $PagePath,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Target
    )

    $skip = [ordered]@{ Skip = $true; Path = $null; Fragment = $null; EscapesRepository = $false }
    if ($Target.Length -eq 0 -or $Target.StartsWith('//') -or $Target -match $script:DocsPageSchemePattern) { return $skip }
    $hash = $Target.IndexOf('#')
    $pathPart = if ($hash -ge 0) { $Target.Substring(0, $hash) } else { $Target }
    $fragment = if ($hash -ge 0) { [uri]::UnescapeDataString($Target.Substring($hash + 1)) } else { $null }
    if ([string]::IsNullOrEmpty($fragment)) { $fragment = $null }
    $query = $pathPart.IndexOf('?')
    if ($query -ge 0) { $pathPart = $pathPart.Substring(0, $query) }
    $pathPart = [uri]::UnescapeDataString($pathPart)
    if ($pathPart.Length -eq 0) { return [ordered]@{ Skip = $false; Path = $PagePath; Fragment = $fragment; EscapesRepository = $false } }

    $segments = [System.Collections.Generic.List[string]]::new()
    if (-not $pathPart.StartsWith('/')) {
        $pageSegments = $PagePath.Split('/')
        for ($index = 0; $index -lt $pageSegments.Count - 1; $index++) { $segments.Add($pageSegments[$index]) }
    }
    foreach ($segment in $pathPart.Split('/')) {
        if ($segment.Length -eq 0 -or $segment -ceq '.') { continue }
        if ($segment -ceq '..') {
            if ($segments.Count -eq 0) { return [ordered]@{ Skip = $false; Path = $null; Fragment = $fragment; EscapesRepository = $true } }
            $segments.RemoveAt($segments.Count - 1)
            continue
        }
        $segments.Add($segment)
    }
    return [ordered]@{ Skip = $false; Path = ($segments -join '/'); Fragment = $fragment; EscapesRepository = $false }
}

function Find-DocsPageLinkPage {
    <#
    .SYNOPSIS
        Returns @{ Page; Directory } for a resolved path against the page set (private helper).
    .DESCRIPTION
        Page is the path itself when it is a page, else <path>/README.md, else <path>/index.md
        when that is a page, else $null. Directory is $true when some page lies under <path>/.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Path,
        [Parameter(Mandatory = $true)] [System.Collections.Generic.HashSet[string]] $PageSet
    )

    $prefix = if ($Path.Length -eq 0) { '' } else { "$Path/" }
    foreach ($candidate in @($Path, "${prefix}README.md", "${prefix}index.md")) {
        if ($candidate.Length -gt 0 -and $PageSet.Contains($candidate)) { return @{ Page = $candidate; Directory = $false } }
    }
    foreach ($page in $PageSet) {
        if ($page.StartsWith($prefix, [System.StringComparison]::Ordinal)) { return @{ Page = $null; Directory = $true } }
    }
    return @{ Page = $null; Directory = $false }
}

function Get-DocsPageExternalTarget {
    <#
    .SYNOPSIS
        Returns the sorted, de-duplicated resolved link paths that are neither pages nor page directories.
    .DESCRIPTION
        PageLink maps each page path to its Get-DocsPageLink records. Skipped targets and
        targets above the repository root are not returned. These are the paths whose existence
        the check command asks Context.TestFile about.
    #>
    [CmdletBinding()]
    [OutputType([string[]], [object[]])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $PageLink,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $PagePath
    )

    $pages = [System.Collections.Generic.HashSet[string]]::new([string[]] $PagePath, [System.StringComparer]::Ordinal)
    $external = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($page in $PageLink.Keys) {
        foreach ($link in @($PageLink[$page])) {
            $resolved = Resolve-DocsPageLinkTarget -PagePath ([string] $page) -Target ([string] $link.Target)
            if ($resolved.Skip -or $resolved.EscapesRepository -or ([string] $resolved.Path).Length -eq 0) { continue }
            $found = Find-DocsPageLinkPage -Path $resolved.Path -PageSet $pages
            if ($null -eq $found.Page -and -not $found.Directory) { [void]$external.Add([string] $resolved.Path) }
        }
    }
    return , [string[]] @($external)
}

function New-DocsPageLinkFinding {
    <#
    .SYNOPSIS
        Builds one link or anchor finding with the line prefix and the fixed next action (private helper).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [string] $Code,
        [Parameter(Mandatory = $true)] [string] $PagePath,
        [Parameter(Mandatory = $true)] [int] $Line,
        [Parameter(Mandatory = $true)] [string] $Message,
        [AllowNull()] [AllowEmptyCollection()] [string[]] $RelatedPath
    )

    return New-DocsFinding -Code $Code -Severity 'error' -Message "line ${Line}: $Message" -NextAction $script:DocsPageLinkNextAction[$Code] -ArtifactPath $PagePath -Pointer '' -RelatedPath $RelatedPath
}

function Get-DocsPageLinkFinding {
    <#
    .SYNOPSIS
        Checks the links of one page; returns @{ Findings; Edges }.
    .DESCRIPTION
        A resolved path is satisfied when it is a page, when <path>/README.md or <path>/index.md
        is a page (the edge goes to that page), when a page lies under <path>/, or when it is in
        ExistingPath. Fragments are checked only on targets in the page set and only when
        PageAnchor holds that page. Edges are the sorted pages this page links to, itself
        excluded.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [string] $PagePath,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Link,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $PageAnchor,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $PageSet,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $ExistingPath
    )

    $pages = [System.Collections.Generic.HashSet[string]]::new([string[]] $PageSet, [System.StringComparer]::Ordinal)
    $existing = [System.Collections.Generic.HashSet[string]]::new([string[]] $ExistingPath, [System.StringComparer]::Ordinal)
    $edges = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::Ordinal)
    $findings = [System.Collections.Generic.List[object]]::new()
    foreach ($item in $Link) {
        $target = [string] $item.Target
        $line = [int] $item.Line
        $resolved = Resolve-DocsPageLinkTarget -PagePath $PagePath -Target $target
        if ($resolved.Skip) { continue }
        if ($resolved.EscapesRepository) {
            $findings.Add((New-DocsPageLinkFinding -Code 'DOCS_PAGE_LINK_ESCAPES_REPOSITORY' -PagePath $PagePath -Line $line -Message "link target '$target' resolves above the repository root"))
            continue
        }
        $path = [string] $resolved.Path
        $found = Find-DocsPageLinkPage -Path $path -PageSet $pages
        if ($null -eq $found.Page) {
            if (-not $found.Directory -and -not $existing.Contains($path)) {
                $related = if ($path -match $script:DocsPageUnrelatablePathPattern) { $null } else { [string[]] @($path) }
                $findings.Add((New-DocsPageLinkFinding -Code 'DOCS_PAGE_LINK_BROKEN' -PagePath $PagePath -Line $line -Message "link target '$target' does not resolve to a page or an existing path" -RelatedPath $related))
            }
            continue
        }
        $page = [string] $found.Page
        if ($page -cne $PagePath) { [void]$edges.Add($page) }
        if ($null -eq $resolved.Fragment -or -not $PageAnchor.Contains($page)) { continue }
        if (@($PageAnchor[$page]) -ccontains [string] $resolved.Fragment) { continue }
        if ($page -ceq $PagePath) {
            $findings.Add((New-DocsPageLinkFinding -Code 'DOCS_PAGE_ANCHOR_MISSING' -PagePath $PagePath -Line $line -Message "anchor '#$($resolved.Fragment)' is not a heading or explicit anchor of this page"))
        } else {
            $findings.Add((New-DocsPageLinkFinding -Code 'DOCS_PAGE_LINK_ANCHOR_MISSING' -PagePath $PagePath -Line $line -Message "anchor '#$($resolved.Fragment)' is not a heading or explicit anchor of '$page'" -RelatedPath @($page)))
        }
    }
    return @{ Findings = [object[]] $findings.ToArray(); Edges = [string[]] @($edges) }
}

Export-ModuleMember -Function `
    Get-DocsPageSlug, `
    Get-DocsPageAnchor, `
    Get-DocsPageLink, `
    Resolve-DocsPageLinkTarget, `
    Get-DocsPageExternalTarget, `
    Get-DocsPageLinkFinding
