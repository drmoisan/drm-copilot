<#
.SYNOPSIS
    Parses, validates, and replays process-reduction ledger entries (issue #1097).

.DESCRIPTION
    The ledger under docs/engineering/process-reductions/ records every reduction of
    evidence, plan tasks, gates, or review process so that it can be reverted months
    later without git revert. Every function here is pure and takes text. Markdown
    parsing is fence-aware: an entry stores prior text verbatim, so a heading inside a
    fence never ends a section.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function ConvertTo-ProcessReductionLf {
    <#
    .SYNOPSIS
        Converts CRLF and lone CR line endings to LF.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Text
    )

    return $Text.Replace("`r`n", "`n").Replace("`r", "`n")
}

function Get-ProcessReductionFence {
    <#
    .SYNOPSIS
        Returns the backtick run length and info string of a fence line, or $null.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Line
    )

    if ($Line -cnotmatch '^ {0,3}(?<run>`{3,})[ \t]*(?<info>[^`]*?)[ \t]*$') {
        return $null
    }

    return [pscustomobject]@{ Length = $Matches['run'].Length; Info = $Matches['info'] }
}

function Get-ProcessReductionLine {
    <#
    .SYNOPSIS
        Splits text into LF lines and marks each line's role relative to backtick fences.

    .DESCRIPTION
        Role is Text outside a fence, and Open, Body, or Close for a fence; Info is the
        info string of the enclosing fence. A fence closes only on a bare fence line at
        least as long as its opener, so a shorter fence inside it stays verbatim content.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Text
    )

    $openLength = 0
    $openInfo = ''
    $lines = (ConvertTo-ProcessReductionLf -Text $Text).Split("`n")
    foreach ($line in $lines) {
        $fence = Get-ProcessReductionFence -Line $line
        $role = 'Body'
        if ($openLength -eq 0) {
            $role = 'Text'
            $openInfo = ''
            if ($null -ne $fence) {
                $role = 'Open'
                $openLength = $fence.Length
                $openInfo = $fence.Info
            }
        } elseif ($null -ne $fence -and $fence.Info -ceq '' -and $fence.Length -ge $openLength) {
            $role = 'Close'
            $openLength = 0
        }

        [pscustomobject]@{ Text = $line; Role = $role; Info = $openInfo }
    }
}

function Get-ProcessReductionSection {
    <#
    .SYNOPSIS
        Returns the body of a level-two section, or $null when the section is absent.

    .DESCRIPTION
        Heading is the section title without its marker, for example 'Summary'. The body
        is LF text without its outer blank lines, and ends at the next level-one or
        level-two heading outside a fence. A present but empty section returns ''.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Text,

        [Parameter(Mandatory = $true)][string]$Heading
    )

    $body = $null
    $rows = @(Get-ProcessReductionLine -Text $Text)
    foreach ($row in $rows) {
        $isHeading = $row.Role -ceq 'Text' -and $row.Text -cmatch '^#{1,2}[ \t]'
        if ($null -ne $body) {
            if ($isHeading) {
                break
            }
            $body.Add($row.Text)
        } elseif ($isHeading -and $row.Text -cmatch '^##[ \t]+(?<title>.*?)[ \t]*$' -and $Matches['title'] -ceq $Heading) {
            $body = [System.Collections.Generic.List[string]]::new()
        }
    }

    if ($null -eq $body) {
        return $null
    }

    return ($body -join "`n").Trim("`n")
}

function Get-ProcessReductionRevertBlock {
    <#
    .SYNOPSIS
        Returns one object with Path, Current, and Prior per Revert Block subsection.

    .DESCRIPTION
        Current and Prior are the bodies of the fences labeled by that info string. A
        fence that is absent or never closed gives $null, and an empty fence gives an
        empty string. When a label repeats within a block, the first fence is used.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Text
    )

    $block = $null
    $fenceBody = $null
    $rows = @(Get-ProcessReductionLine -Text $Text)
    foreach ($row in $rows) {
        if ($row.Role -ceq 'Text') {
            if ($row.Text -cmatch '^#{1,3}[ \t]') {
                if ($null -ne $block) {
                    $block
                }
                $block = $null
                if ($row.Text -cmatch '^### Revert Block:[ \t]*(?<path>\S.*?)[ \t]*$') {
                    $block = [pscustomobject]@{ Path = $Matches['path']; Current = $null; Prior = $null }
                }
            }
            continue
        }

        if ($null -eq $block -or $row.Info -cnotin @('Current', 'Prior')) {
            continue
        }

        if ($row.Role -ceq 'Open') {
            $fenceBody = [System.Collections.Generic.List[string]]::new()
        } elseif ($row.Role -ceq 'Body') {
            $fenceBody.Add($row.Text)
        } elseif ($null -eq $block.($row.Info)) {
            $block.($row.Info) = $fenceBody -join "`n"
        }
    }

    if ($null -ne $block) {
        $block
    }
}

function Invoke-ProcessReductionRevert {
    <#
    .SYNOPSIS
        Returns the live text, as LF text, with the block's Current replaced by its Prior.

    .DESCRIPTION
        Line endings are normalized before comparing, because .gitattributes rewrites them
        on checkout and an entry and its target can differ. Throws when Current is $null,
        empty, not found, or found more than once, and when Prior is $null, because each
        of those would make the result a wrong revert with no visible failure.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Text,

        [Parameter(Mandatory = $true)][psobject]$Block
    )

    if ([string]::IsNullOrEmpty($Block.Current)) {
        throw "Revert block '$($Block.Path)' has no Current text."
    }
    if ($null -eq $Block.Prior) {
        throw "Revert block '$($Block.Path)' has no Prior text."
    }

    $live = ConvertTo-ProcessReductionLf -Text $Text
    $current = ConvertTo-ProcessReductionLf -Text $Block.Current
    $prior = ConvertTo-ProcessReductionLf -Text $Block.Prior
    $first = $live.IndexOf($current, [System.StringComparison]::Ordinal)
    if ($first -lt 0) {
        throw "Current text of revert block '$($Block.Path)' was not found."
    }
    if ($live.IndexOf($current, $first + 1, [System.StringComparison]::Ordinal) -ge 0) {
        throw "Current text of revert block '$($Block.Path)' was found more than once."
    }

    return $live.Substring(0, $first) + $prior + $live.Substring($first + $current.Length)
}

Export-ModuleMember -Function @(
    'Get-ProcessReductionSection',
    'Get-ProcessReductionRevertBlock',
    'Invoke-ProcessReductionRevert'
)
