<#
.SYNOPSIS
    Parses, validates, and replays process-reduction ledger entries (issue #1097).

.DESCRIPTION
    The ledger under docs/engineering/process-reductions/ records every reduction of
    evidence, plan tasks, gates, or review process so that it can be reverted months
    later without git revert. Every function here is pure and takes text, except
    Read-ProcessReductionLedger, which is the one read seam and writes nothing. Markdown
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

function Get-ProcessReductionPlainLine {
    <#
    .SYNOPSIS
        Returns the lines of the text that lie outside every fence.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Text
    )

    $rows = @(Get-ProcessReductionLine -Text $Text)
    $rows | Where-Object { $_.Role -ceq 'Text' } | ForEach-Object { $_.Text }
}

function Get-ProcessReductionEntryNumber {
    <#
    .SYNOPSIS
        Returns the NNNN of an entry file name, or $null outside NNNN-<short-name>.md.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Name
    )

    if ($Name -cmatch '^(?<number>[0-9]{4})-[a-z0-9]+(?:-[a-z0-9]+)*\.md$') {
        return $Matches['number']
    }

    return $null
}

function Get-ProcessReductionSummaryError {
    <#
    .SYNOPSIS
        Returns the errors of the reduction token and Merge commit line of a Summary.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][string]$Summary,
        [Parameter(Mandatory = $true)][AllowNull()][AllowEmptyString()][string]$Number
    )

    $lines = @(Get-ProcessReductionPlainLine -Text $Summary)
    if ($Number -and $lines -cnotcontains "reduction: $Number") {
        "## Summary must carry the line 'reduction: $Number'."
    }

    $mergeLines = @($lines | Where-Object { $_ -cmatch '^Merge commit:' })
    if ($mergeLines.Count -ne 1) {
        "## Summary must carry exactly one 'Merge commit:' line; found $($mergeLines.Count)."
    } elseif ($mergeLines[0] -cnotmatch '^Merge commit: (?:pending \(PR #[1-9][0-9]*\)|[0-9a-f]{7,40})$') {
        "## Summary line '$($mergeLines[0])' is neither 'Merge commit: pending (PR #N)' nor a commit identifier."
    }
}

function Get-ProcessReductionPriorTextError {
    <#
    .SYNOPSIS
        Returns the errors of the Revert Block subsections of a Prior Text section.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][string]$PriorText
    )

    $blocks = @(Get-ProcessReductionRevertBlock -Text $PriorText)
    if ($blocks.Count -eq 0) {
        '## Prior Text must hold at least one revert block.'
    }

    foreach ($block in $blocks) {
        if ([string]::IsNullOrEmpty($block.Current)) {
            "Revert block '$($block.Path)' needs a non-empty Current fence."
        }
        if ($null -eq $block.Prior) {
            "Revert block '$($block.Path)' needs a Prior fence."
        }
    }
}

function Get-ProcessReductionRevertStepError {
    <#
    .SYNOPSIS
        Returns the errors of the six ordered labels of a Revert Steps section.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][string]$RevertSteps
    )

    $labels = @(
        'Apply the blocks',
        'Re-copy mirrors and bundles',
        'Regenerate Codex variants',
        'Restore pinned hashes',
        'Restore contract-test literals',
        'Run the contract tests'
    )
    $comparison = [System.StringComparison]::OrdinalIgnoreCase
    $position = 0
    foreach ($label in $labels) {
        $found = $RevertSteps.IndexOf($label, $position, $comparison)
        if ($found -ge 0) {
            $position = $found + $label.Length
        } elseif ($RevertSteps.IndexOf($label, $comparison) -ge 0) {
            "## Revert Steps names '$label' out of order."
        } else {
            "## Revert Steps must name '$label'."
        }
    }
}

function Test-ProcessReductionEntry {
    <#
    .SYNOPSIS
        Checks the structure of one ledger entry and returns IsValid, Errors, and PatchPath.

    .DESCRIPTION
        Name is the entry file name. PatchPath is the patches/<entry stem>.patch path that
        a Stored Patch section names, or $null.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Text
    )

    $errorList = [System.Collections.Generic.List[string]]::new()
    $number = Get-ProcessReductionEntryNumber -Name $Name
    if ($null -eq $number) {
        $errorList.Add("Entry name '$Name' is not NNNN-<short-name>.md.")
    }

    $sections = @{}
    foreach ($title in @('Summary', 'Reason and Evidence', 'Files Changed', 'Revert Steps', 'Revert Signals')) {
        $sections[$title] = Get-ProcessReductionSection -Text $Text -Heading $title
        if ($null -eq $sections[$title]) {
            $errorList.Add("Required section '## $title' is missing.")
        } elseif ([string]::IsNullOrWhiteSpace($sections[$title])) {
            $errorList.Add("Required section '## $title' is empty.")
        }
    }

    if (-not [string]::IsNullOrWhiteSpace($sections['Summary'])) {
        $errorList.AddRange([string[]]@(Get-ProcessReductionSummaryError -Summary $sections['Summary'] -Number $number))
    }
    if (-not [string]::IsNullOrWhiteSpace($sections['Revert Steps'])) {
        $errorList.AddRange([string[]]@(Get-ProcessReductionRevertStepError -RevertSteps $sections['Revert Steps']))
    }

    $priorText = Get-ProcessReductionSection -Text $Text -Heading 'Prior Text'
    $storedPatch = Get-ProcessReductionSection -Text $Text -Heading 'Stored Patch'
    if ($null -eq $priorText -and $null -eq $storedPatch) {
        $errorList.Add("An entry needs '## Prior Text' or '## Stored Patch'.")
    }
    if ($null -ne $priorText) {
        if ([string]::IsNullOrWhiteSpace($priorText)) {
            $errorList.Add("Required section '## Prior Text' is empty.")
        } else {
            $errorList.AddRange([string[]]@(Get-ProcessReductionPriorTextError -PriorText $priorText))
        }
    }

    $patchPath = $null
    if ($null -ne $storedPatch) {
        $expectedPatch = 'patches/{0}.patch' -f [System.IO.Path]::GetFileNameWithoutExtension($Name)
        if ($storedPatch -cmatch ('(?<![\w./-])' + [regex]::Escape($expectedPatch) + '(?![\w./-])')) {
            $patchPath = $expectedPatch
        } else {
            $errorList.Add("## Stored Patch must name '$expectedPatch'.")
        }
    }

    return [pscustomobject]@{ IsValid = $errorList.Count -eq 0; Errors = $errorList.ToArray(); PatchPath = $patchPath }
}

function Test-ProcessReductionIndex {
    <#
    .SYNOPSIS
        Checks the Index table against the entry file names; returns IsValid, Errors, RowCount.

    .DESCRIPTION
        IndexText is the README text; only its Index section is read. A data row's ID cell
        is a link such as [0001](0001-short-name.md). EntryName may be empty.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$IndexText,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][string[]]$EntryName
    )

    $errorList = [System.Collections.Generic.List[string]]::new()
    $section = Get-ProcessReductionSection -Text $IndexText -Heading 'Index'
    if ($null -eq $section) {
        return [pscustomobject]@{ IsValid = $false; Errors = @("The README has no '## Index' section."); RowCount = 0 }
    }

    $tableLines = @(Get-ProcessReductionPlainLine -Text $section | Where-Object { $_ -cmatch '^\s*\|' } | ForEach-Object { $_.Trim() })
    if ($tableLines.Count -lt 2 -or $tableLines[0] -cne '| ID | Title | Date | Issue | Status |' -or $tableLines[1] -cnotmatch '^\|(?: *:?-+:? *\|){5}$') {
        return [pscustomobject]@{ IsValid = $false; Errors = @("'## Index' has no table with the header row and separator row."); RowCount = 0 }
    }

    $rows = @($tableLines | Select-Object -Skip 2)
    $seenNumbers = [System.Collections.Generic.HashSet[string]]::new()
    $linkedFiles = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($row in $rows) {
        if ($row -cnotmatch '^\| *\[(?<label>[0-9]{4})\]\((?<file>[^()\s]+)\) *\|(?:[^|]*[^|\s][^|]*\|){4}$') {
            $errorList.Add("Index row '$row' is malformed.")
            continue
        }

        $label = $Matches['label']
        $file = $Matches['file']
        [void]$linkedFiles.Add($file)
        if (-not $seenNumbers.Add($label)) {
            $errorList.Add("Index number '$label' is repeated.")
        }
        if ($file -cnotin $EntryName) {
            $errorList.Add("Index row '$label' links '$file', which has no entry file.")
        }
        if ((Get-ProcessReductionEntryNumber -Name $file) -cne $label) {
            $errorList.Add("Index label '$label' differs from the number of '$file'.")
        }
    }

    foreach ($entry in $EntryName) {
        if ($null -eq (Get-ProcessReductionEntryNumber -Name $entry)) {
            $errorList.Add("Entry name '$entry' is not NNNN-<short-name>.md.")
        }
        if (-not $linkedFiles.Contains($entry)) {
            $errorList.Add("Entry file '$entry' has no index row.")
        }
    }

    return [pscustomobject]@{ IsValid = $errorList.Count -eq 0; Errors = $errorList.ToArray(); RowCount = $rows.Count }
}

function Read-ProcessReductionLedger {
    <#
    .SYNOPSIS
        Reads the ledger folder and returns IndexText, Entries, and PatchNames.

    .DESCRIPTION
        The one read seam of this module; it writes nothing. Entries holds Name and Text
        for every top-level *.md file except README.md, ordered by name. PatchNames holds
        the file names under patches/, and is empty when that folder is absent.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][string]$LedgerPath
    )

    if (-not (Test-Path -LiteralPath $LedgerPath -PathType Container)) {
        throw "Ledger folder '$LedgerPath' does not exist."
    }
    $readmePath = Join-Path -Path $LedgerPath -ChildPath 'README.md'
    if (-not (Test-Path -LiteralPath $readmePath -PathType Leaf)) {
        throw "Ledger folder '$LedgerPath' has no README.md."
    }

    $entryFiles = @(Get-ChildItem -LiteralPath $LedgerPath -File | Where-Object { $_.Extension -eq '.md' -and $_.Name -ne 'README.md' } | Sort-Object -Property Name)
    $entries = @($entryFiles | ForEach-Object {
            [pscustomobject]@{ Name = $_.Name; Text = [string](Get-Content -LiteralPath $_.FullName -Raw) }
        })

    $patchNames = @()
    $patchFolder = Join-Path -Path $LedgerPath -ChildPath 'patches'
    if (Test-Path -LiteralPath $patchFolder -PathType Container) {
        $patchNames = @(Get-ChildItem -LiteralPath $patchFolder -File | ForEach-Object { $_.Name })
    }

    return [pscustomobject]@{
        IndexText  = [string](Get-Content -LiteralPath $readmePath -Raw)
        Entries    = $entries
        PatchNames = $patchNames
    }
}

function Test-ProcessReductionLedger {
    <#
    .SYNOPSIS
        Checks a ledger object from Read-ProcessReductionLedger; returns IsValid, Errors, RowCount.

    .DESCRIPTION
        Runs the index check, runs the entry check on every entry, and reports a PatchPath
        that is absent from PatchNames. Pure, so a real ledger and an in-memory ledger go
        through the same code.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][psobject]$Ledger
    )

    $entries = @($Ledger.Entries)
    $patchNames = @($Ledger.PatchNames)
    $index = Test-ProcessReductionIndex -IndexText $Ledger.IndexText -EntryName ([string[]]@($entries | ForEach-Object { $_.Name }))
    $errorList = [System.Collections.Generic.List[string]]::new()
    $errorList.AddRange([string[]]@($index.Errors))

    foreach ($entry in $entries) {
        $result = Test-ProcessReductionEntry -Name $entry.Name -Text $entry.Text
        foreach ($entryError in $result.Errors) {
            $errorList.Add("$($entry.Name): $entryError")
        }
        if ($null -ne $result.PatchPath -and ($result.PatchPath -replace '^patches/', '') -cnotin $patchNames) {
            $errorList.Add("$($entry.Name): stored patch '$($result.PatchPath)' does not exist.")
        }
    }

    return [pscustomobject]@{ IsValid = $errorList.Count -eq 0; Errors = $errorList.ToArray(); RowCount = $index.RowCount }
}

Export-ModuleMember -Function @(
    'Get-ProcessReductionSection',
    'Get-ProcessReductionRevertBlock',
    'Invoke-ProcessReductionRevert',
    'Test-ProcessReductionEntry',
    'Test-ProcessReductionIndex',
    'Read-ProcessReductionLedger',
    'Test-ProcessReductionLedger'
)
