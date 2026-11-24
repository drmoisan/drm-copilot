<#
.SYNOPSIS
    The placeholder counter of the documentation library: counts the literal placeholder token
    in page bodies and renders the placeholders section of the coverage report.

.DESCRIPTION
    The token is the literal SME input required, matched case-sensitively and ordinally. Adjacent
    words may be separated by one or more spaces or tabs, or by a single line break with optional
    surrounding spaces or tabs; words separated by a blank line are not counted.

    Measure-DocsPagePlaceholder normalizes CRLF to LF, takes the page body from BodyStartLine of
    ConvertFrom-DocsPageFrontMatter (1 for a page without a terminated front-matter block), and
    searches the Masked text of the Get-DocsPageLineModel lines joined with LF, so front matter,
    fence lines and fenced code bodies, HTML comments and inline code-span contents are excluded.

    Get-DocsPlaceholderReport reads only .md pages through the ReadBytes scriptblock and decodes
    them strictly as UTF-8; a page that fails to decode contributes zero and is not listed. It
    returns an ordered dictionary with token, total and pages, where pages holds the pages with a
    count above zero sorted ordinally by page_path. ConvertTo-DocsPlaceholderReportLine renders
    the summary line and one line per listed page.

    Every function is pure: no filesystem, network, clock, process, environment or module-scope
    mutable state. Page bytes reach the module only through the ReadBytes parameter.

.NOTES
    Issue #1219. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsJson.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsPageMarkdown.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsPageFrontMatter.psm1') -ErrorAction Stop

$script:DocsPlaceholderToken = 'SME input required'
$script:DocsPlaceholderPattern = 'SME(?:[ \t]+|[ \t]*\n[ \t]*)input(?:[ \t]+|[ \t]*\n[ \t]*)required'

function Get-DocsPlaceholderToken {
    <#
    .SYNOPSIS
        Returns the literal placeholder token SME input required.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param()

    return $script:DocsPlaceholderToken
}

function Measure-DocsPagePlaceholder {
    <#
    .SYNOPSIS
        Returns the number of placeholder tokens in the body of one page.
    .DESCRIPTION
        CRLF is normalized to LF. The searched text is the Masked text of the line model of the
        body lines joined with LF; the match is ordinal and case-sensitive.
    #>
    [CmdletBinding()]
    [OutputType([long])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text,
        [Parameter(Mandatory = $true)] [string] $PagePath
    )

    $normalized = $Text.Replace("`r`n", "`n")
    $frontMatter = ConvertFrom-DocsPageFrontMatter -Text $normalized -PagePath $PagePath
    $lines = Split-DocsPageLine -Text $normalized
    $bodyStart = [int] $frontMatter.BodyStartLine
    $body = [string[]]::new(0)
    if ($bodyStart -le $lines.Count) { $body = [string[]] $lines[($bodyStart - 1)..($lines.Count - 1)] }
    $model = Get-DocsPageLineModel -Line $body -FirstLineNumber $bodyStart
    $searched = (@($model | ForEach-Object { [string] $_.Masked }) -join "`n")
    $options = [System.Text.RegularExpressions.RegexOptions]::CultureInvariant
    return [long] [regex]::Matches($searched, $script:DocsPlaceholderPattern, $options).Count
}

function Get-DocsPlaceholderReport {
    <#
    .SYNOPSIS
        Returns the ordered placeholders section (token, total, pages) over the .md pages of PagePath.
    .DESCRIPTION
        Pages are read through ReadBytes and decoded strictly as UTF-8; a non-.md path is not
        read, and a page that fails to decode contributes zero and is not listed. pages holds
        [ordered]@{ page_path; count } for each page with a count above zero, sorted ordinally.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [AllowNull()] [AllowEmptyCollection()] [string[]] $PagePath,
        [Parameter(Mandatory = $true)] [scriptblock] $ReadBytes
    )

    $sorted = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($path in @($PagePath | Where-Object { $_ -is [string] })) {
        if ($path.EndsWith('.md', [System.StringComparison]::Ordinal)) { [void] $sorted.Add($path) }
    }
    $pages = [System.Collections.Generic.List[object]]::new()
    $total = [long] 0
    foreach ($path in $sorted) {
        try {
            $text = ConvertFrom-DocsUtf8Bytes -Bytes ([byte[]] (& $ReadBytes $path))
        } catch [System.Text.DecoderFallbackException] {
            continue
        }
        $count = Measure-DocsPagePlaceholder -Text $text -PagePath $path
        if ($count -le 0) { continue }
        $total += $count
        $pages.Add([ordered]@{ page_path = $path; count = $count })
    }
    return [ordered]@{ token = $script:DocsPlaceholderToken; total = $total; pages = [object[]] $pages.ToArray() }
}

function ConvertTo-DocsPlaceholderReportLine {
    <#
    .SYNOPSIS
        Renders the placeholders summary line and one placeholder line per listed page, in pages order.
    #>
    [CmdletBinding()]
    [OutputType([string[]], [object[]])]
    param([Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Report)

    $pages = @($Report['pages'])
    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add(('placeholders: token="{0}" total={1} pages={2}' -f [string] $Report['token'], [long] $Report['total'], $pages.Count))
    foreach ($page in $pages) { $lines.Add(('placeholder {0} count={1}' -f [string] $page['page_path'], [long] $page['count'])) }
    return , [string[]] $lines.ToArray()
}

Export-ModuleMember -Function `
    Get-DocsPlaceholderToken, `
    Measure-DocsPagePlaceholder, `
    Get-DocsPlaceholderReport, `
    ConvertTo-DocsPlaceholderReportLine
