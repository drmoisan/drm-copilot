<#
.SYNOPSIS
    The Markdown line model of the documentation page checker: line splitting, fenced code,
    HTML-comment and inline code-span masking, ATX and setext headings and generated-block
    start-marker detection.

.DESCRIPTION
    Split-DocsPageLine removes a leading byte order mark and splits on CRLF, LF or CR.
    Get-DocsPageLineModel returns one ordered dictionary per line with the keys Number, Text,
    Kind, Masked, CommentMasked, HeadingLevel, HeadingText and HasGeneratedStartMarker. Kind is
    one of blank, text, fence-open, fence-body, fence-close, comment, heading or
    setext-underline. Masked replaces HTML-comment spans and inline code-span contents with
    spaces and is empty for fence and comment lines; CommentMasked replaces only HTML-comment
    spans, so heading slugs keep code-span text.

    The fence rule is re-implemented here rather than imported from the mermaid area: three or
    more backticks or tildes after at most three spaces of indentation, closed by the same
    character with at least the same length and no info string; an unclosed fence runs to the
    end of the page. The model is lexical, not CommonMark: indented code blocks are not
    recognized and code spans do not span lines.

    Every function is pure: no filesystem, clock, process, environment or module-scope mutable
    state.

.NOTES
    Issue #1021. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:DocsPageFencePattern = '^(?<indent> {0,3})(?<fence>`{3,}|~{3,})(?<info>.*)$'
$script:DocsPageAtxPattern = '^ {0,3}(?<marks>#{1,6})(?:[ \t]+(?<text>.*?))?[ \t]*$'
$script:DocsPageSetextPattern = '^ {0,3}(?<marks>=+|-+)[ \t]*$'
$script:DocsPageStartMarkerPattern = '^<!-- docs:generated:start id=\S+ -->[ \t]*$'

function Split-DocsPageLine {
    <#
    .SYNOPSIS
        Splits page text into lines after removing one leading byte order mark.
    #>
    [CmdletBinding()]
    [OutputType([string[]], [object[]])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text)

    $body = if ($Text.StartsWith([char]0xFEFF)) { $Text.Substring(1) } else { $Text }
    return , [string[]]([regex]::Split($body, '\r\n|\n|\r'))
}

function Get-DocsPageFenceLine {
    <#
    .SYNOPSIS
        Returns @{ FenceCharacter; FenceLength; Info } when the line is a fence line, else $null.
    .DESCRIPTION
        A backtick fence whose info string contains a backtick is not a fence (CommonMark rule).
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Line)

    $match = [regex]::Match($Line, $script:DocsPageFencePattern)
    if (-not $match.Success) { return $null }
    $fence = $match.Groups['fence'].Value
    $info = $match.Groups['info'].Value.Trim()
    if ($fence[0] -eq [char]'`' -and $info.Contains('`')) { return $null }
    return [ordered]@{ FenceCharacter = [string] $fence[0]; FenceLength = $fence.Length; Info = $info }
}

function Test-DocsPageFenceClose {
    <#
    .SYNOPSIS
        Returns $true when Fence closes OpenFence: same character, at least the same length, no info string.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Fence,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $OpenFence
    )

    return ([string] $Fence.FenceCharacter -ceq [string] $OpenFence.FenceCharacter) -and ([int] $Fence.FenceLength -ge [int] $OpenFence.FenceLength) -and ([string]::IsNullOrEmpty([string] $Fence.Info))
}

function Get-DocsPageMaskedText {
    <#
    .SYNOPSIS
        Masks HTML-comment spans and, unless CommentsOnly, inline code-span contents (private helper).
    .DESCRIPTION
        Returns @{ Text; InComment; HadComment }. InComment carries an open comment into the next
        line; a comment opened and not closed on this line masks the rest of the line.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Line,
        [Parameter(Mandatory = $true)] [bool] $InComment,
        [switch] $CommentsOnly
    )

    $chars = $Line.ToCharArray()
    $hadComment = $InComment
    $index = 0
    while ($index -lt $chars.Length) {
        if ($InComment) {
            $close = $Line.IndexOf('-->', $index, [System.StringComparison]::Ordinal)
            $end = if ($close -lt 0) { $chars.Length } else { $close + 3 }
            for ($at = $index; $at -lt $end; $at++) { $chars[$at] = ' ' }
            $index = $end
            if ($close -ge 0) { $InComment = $false }
            continue
        }
        if ($chars[$index] -eq [char]'<' -and [string]::CompareOrdinal($Line, $index, '<!--', 0, 4) -eq 0) {
            $InComment = $true
            $hadComment = $true
            for ($at = $index; $at -lt [math]::Min($index + 4, $chars.Length); $at++) { $chars[$at] = ' ' }
            $index += 4
            continue
        }
        if ($chars[$index] -eq [char]'`') {
            $runEnd = $index
            while ($runEnd -lt $chars.Length -and $chars[$runEnd] -eq [char]'`') { $runEnd++ }
            $run = $runEnd - $index
            $closeAt = -1
            $scan = $runEnd
            while ($scan -lt $chars.Length) {
                if ($chars[$scan] -eq [char]'`') {
                    $scanEnd = $scan
                    while ($scanEnd -lt $chars.Length -and $chars[$scanEnd] -eq [char]'`') { $scanEnd++ }
                    if (($scanEnd - $scan) -eq $run) { $closeAt = $scan; break }
                    $scan = $scanEnd
                } else { $scan++ }
            }
            if ($closeAt -lt 0) { $index = $runEnd; continue }
            if (-not $CommentsOnly) { for ($at = $runEnd; $at -lt $closeAt; $at++) { $chars[$at] = ' ' } }
            $index = $closeAt + $run
            continue
        }
        $index++
    }
    return @{ Text = [string]::new($chars); InComment = $InComment; HadComment = $hadComment }
}

function New-DocsPageLineRecord {
    <#
    .SYNOPSIS
        Builds one line-model record (private helper).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [int] $Number,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text,
        [Parameter(Mandatory = $true)] [string] $Kind,
        [AllowEmptyString()] [string] $Masked = '',
        [AllowEmptyString()] [string] $CommentMasked = '',
        [bool] $HasGeneratedStartMarker = $false
    )

    return [ordered]@{
        Number                  = $Number
        Text                    = $Text
        Kind                    = $Kind
        Masked                  = $Masked
        CommentMasked           = $CommentMasked
        HeadingLevel            = 0
        HeadingText             = $null
        HasGeneratedStartMarker = $HasGeneratedStartMarker
    }
}

function Get-DocsPageAtxHeadingText {
    <#
    .SYNOPSIS
        Returns the text of an ATX heading line with the opening and closing # runs removed (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text)

    $match = [regex]::Match($Text, $script:DocsPageAtxPattern)
    $content = if ($match.Success) { $match.Groups['text'].Value } else { '' }
    if ($content -match '^#+$') { return '' }
    return ([regex]::Replace($content, '[ \t]+#+$', '')).Trim()
}

function Get-DocsPageLineModel {
    <#
    .SYNOPSIS
        Returns one ordered dictionary per line describing its kind, masked text and heading.
    .DESCRIPTION
        FirstLineNumber is the 1-based page line number of the first element of Line, so a
        caller that skips a front-matter block keeps page line numbers.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [AllowEmptyString()] [string[]] $Line,
        [int] $FirstLineNumber = 1
    )

    $model = [System.Collections.Generic.List[object]]::new()
    $openFence = $null
    $inComment = $false
    for ($index = 0; $index -lt $Line.Count; $index++) {
        $text = [string] $Line[$index]
        $number = $FirstLineNumber + $index
        if ($null -ne $openFence) {
            $fence = Get-DocsPageFenceLine -Line $text
            if ($null -ne $fence -and (Test-DocsPageFenceClose -Fence $fence -OpenFence $openFence)) {
                $model.Add((New-DocsPageLineRecord -Number $number -Text $text -Kind 'fence-close'))
                $openFence = $null
            } else {
                $model.Add((New-DocsPageLineRecord -Number $number -Text $text -Kind 'fence-body'))
            }
            continue
        }
        if (-not $inComment) {
            $fence = Get-DocsPageFenceLine -Line $text
            if ($null -ne $fence) {
                $model.Add((New-DocsPageLineRecord -Number $number -Text $text -Kind 'fence-open'))
                $openFence = $fence
                continue
            }
        }
        $marker = (-not $inComment) -and [regex]::IsMatch($text, $script:DocsPageStartMarkerPattern)
        $full = Get-DocsPageMaskedText -Line $text -InComment $inComment
        $commentOnly = Get-DocsPageMaskedText -Line $text -InComment $inComment -CommentsOnly
        $inComment = $full.InComment
        if ($full.HadComment -and [string]::IsNullOrWhiteSpace($full.Text)) {
            $model.Add((New-DocsPageLineRecord -Number $number -Text $text -Kind 'comment' -HasGeneratedStartMarker $marker))
            continue
        }
        if ([string]::IsNullOrWhiteSpace($full.Text)) {
            $model.Add((New-DocsPageLineRecord -Number $number -Text $text -Kind 'blank' -Masked $full.Text -CommentMasked $commentOnly.Text))
            continue
        }
        $record = New-DocsPageLineRecord -Number $number -Text $text -Kind 'text' -Masked $full.Text -CommentMasked $commentOnly.Text
        $atx = [regex]::Match($full.Text, $script:DocsPageAtxPattern)
        $setext = [regex]::Match($full.Text, $script:DocsPageSetextPattern)
        $previous = if ($model.Count -gt 0) { $model[$model.Count - 1] } else { $null }
        if ($atx.Success) {
            $record.Kind = 'heading'
            $record.HeadingLevel = $atx.Groups['marks'].Value.Length
            $record.HeadingText = Get-DocsPageAtxHeadingText -Text $commentOnly.Text
        } elseif ($setext.Success -and $null -ne $previous -and [string] $previous.Kind -ceq 'text') {
            $record.Kind = 'setext-underline'
            $previous.Kind = 'heading'
            $previous.HeadingLevel = if ($setext.Groups['marks'].Value[0] -eq [char]'=') { 1 } else { 2 }
            $previous.HeadingText = ([string] $previous.CommentMasked).Trim()
        }
        $model.Add($record)
    }
    return , $model.ToArray()
}

Export-ModuleMember -Function `
    Split-DocsPageLine, `
    Get-DocsPageFenceLine, `
    Test-DocsPageFenceClose, `
    Get-DocsPageLineModel
