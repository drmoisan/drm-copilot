<#
.SYNOPSIS
    Reverts the process-reduction ledger newest-first in memory and reports gaps (issue #1097).

.DESCRIPTION
    A stored patch is read hunk by hunk as revert blocks. Every function is pure and takes
    text, except Read-ProcessReductionChainInput, the one read seam, which writes nothing.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'ProcessReductionLedger.psm1')

function ConvertTo-ProcessReductionChainLf {
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

function Get-ProcessReductionPatchHunk {
    <#
    .SYNOPSIS
        Parses a stored patch into one object per hunk with Path, Kind, Current, Prior, and Start.

    .DESCRIPTION
        Current is the context and added lines, Prior the context and removed lines, Kind
        modify, create, or delete, and Start the post-image start line. The path drops the tab
        git appends to a spaced name. Throws, naming the section, for binary or quoted paths.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$PatchText
    )

    $section = ''
    $kind = 'modify'
    $oldPath = $null
    $newPath = $null
    $hunk = $null
    foreach ($line in (ConvertTo-ProcessReductionChainLf -Text $PatchText).Split("`n")) {
        if ($null -ne $hunk) {
            $marker = if ($line.Length -gt 0) { $line.Substring(0, 1) } else { ' ' }
            if ($marker -ceq '\') {
                continue
            }
            if ($marker -cnotin @(' ', '-', '+')) {
                throw "Patch section '$section' has a malformed hunk line '$line'."
            }
            $body = if ($line.Length -gt 0) { $line.Substring(1) } else { '' }
            if ($marker -cne '+') {
                $hunk.Prior.Add($body)
                $oldLeft--
            }
            if ($marker -cne '-') {
                $hunk.Current.Add($body)
                $newLeft--
            }
            if ($oldLeft -le 0 -and $newLeft -le 0) {
                [pscustomobject]@{ Path = $hunk.Path; Kind = $kind; Current = $hunk.Current.ToArray(); Prior = $hunk.Prior.ToArray(); Start = $hunk.Start }
                $hunk = $null
            }
        } elseif ($line.StartsWith('diff --git ', [System.StringComparison]::Ordinal)) {
            $section = $line
            $kind = 'modify'
            $oldPath = $null
            $newPath = $null
        } elseif ($line -cmatch '^(?:GIT binary patch|Binary files )') {
            throw "Patch section '$section' is binary, which the chain does not read."
        } elseif ($line -cmatch '^(?<mode>new|deleted) file mode ') {
            $kind = if ($Matches['mode'] -ceq 'new') { 'create' } else { 'delete' }
        } elseif ($line -cmatch '^(?<side>---|\+\+\+) (?<value>.*)$') {
            $side = $Matches['side']
            $value = $Matches['value'] -replace '\t$', ''
            if ($value -ceq '/dev/null') {
                $kind = if ($side -ceq '---') { 'create' } else { 'delete' }
            } elseif ($value -cnotmatch '^[ab]/(?<path>.+)$') {
                throw "Patch section '$section' has a quoted or unprefixed path, which the chain does not read."
            } elseif ($side -ceq '---') {
                $oldPath = $Matches['path']
            } else {
                $newPath = $Matches['path']
            }
        } elseif ($line -cmatch '^@@ -[0-9]+(?:,(?<old>[0-9]+))? \+(?<start>[0-9]+)(?:,(?<new>[0-9]+))? @@') {
            $path = if ($kind -ceq 'delete') { $oldPath } else { $newPath }
            if ($null -eq $path) {
                throw "Patch section '$section' has a hunk before its --- and +++ lines."
            }
            $oldLeft = if ($Matches.ContainsKey('old')) { [int]$Matches['old'] } else { 1 }
            $newLeft = if ($Matches.ContainsKey('new')) { [int]$Matches['new'] } else { 1 }
            $hunk = [pscustomobject]@{
                Path    = $path
                Start   = [int]$Matches['start']
                Current = [System.Collections.Generic.List[string]]::new()
                Prior   = [System.Collections.Generic.List[string]]::new()
            }
        }
    }
}

function Invoke-ProcessReductionHunkRevert {
    <#
    .SYNOPSIS
        Returns the text, as LF text, with the hunk's Current lines replaced by its Prior lines.

    .DESCRIPTION
        Current is matched as a line-aligned sequence of whole lines, and of several matches
        the one nearest the recorded post-image start wins, which is the git apply rule.
        Throws when Current is empty, not found, or found twice equally near.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Text,
        [Parameter(Mandatory = $true)][psobject]$Hunk
    )

    $current = [string[]]@($Hunk.Current)
    $label = "hunk at +$($Hunk.Start) of '$($Hunk.Path)'"
    if ($current.Count -eq 0) {
        throw "The $label has no Current lines."
    }

    $lines = (ConvertTo-ProcessReductionChainLf -Text $Text).Split("`n")
    $target = [int]$Hunk.Start - 1
    $best = -1
    $bestDistance = [int]::MaxValue
    $tie = $false
    $index = [Array]::IndexOf($lines, $current[0])
    while ($index -ge 0 -and $index + $current.Count -le $lines.Count) {
        $isMatch = $true
        for ($offset = 1; $isMatch -and $offset -lt $current.Count; $offset++) {
            $isMatch = $lines[$index + $offset] -ceq $current[$offset]
        }
        if ($isMatch) {
            $distance = [math]::Abs($index - $target)
            if ($distance -lt $bestDistance) {
                $best = $index
                $bestDistance = $distance
                $tie = $false
            } elseif ($distance -eq $bestDistance) {
                $tie = $true
            }
        }
        $index = [Array]::IndexOf($lines, $current[0], $index + 1)
    }

    if ($best -lt 0) {
        throw "Current text of the $label was not found."
    }
    if ($tie) {
        throw "Current text of the $label was found twice at the same distance from its start."
    }

    $tailStart = $best + $current.Count
    $result = @([System.ArraySegment[string]]::new($lines, 0, $best)) + [string[]]@($Hunk.Prior) + @([System.ArraySegment[string]]::new($lines, $tailStart, $lines.Count - $tailStart))
    return $result -join "`n"
}

function Get-ProcessReductionMappedSource {
    <#
    .SYNOPSIS
        Returns the source path a mirror or bundle path maps to by the fixed rules, or $null.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][string]$Path
    )

    if ($Path -cmatch '^extensions/drm-copilot/resources/(?:claude-customizations|codex-and-agents-customizations|customizations)/(?<rest>.+)$') {
        return $Matches['rest']
    }
    if ($Path -cmatch '^extensions/drm-copilot/resources/(?:feature-templates|templates)/(?<rest>.+)$') {
        return 'docs/features/templates/' + $Matches['rest']
    }
    if ($Path -cmatch '^\.(?:agents|github)/skills/(?<name>[^/]+)/SKILL\.md$') {
        return '.claude/skills/' + $Matches['name'] + '/SKILL.md'
    }

    return $null
}

function Get-ProcessReductionDerivedSource {
    <#
    .SYNOPSIS
        Returns the source of a derived path, 'generated' for a generated Codex variant, or $null.

    .DESCRIPTION
        A mapped path is derived only when its live text equals its source's after line-ending
        normalization; otherwise it is a source. Revert steps 2 and 3 re-create a derived path.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][hashtable]$LiveText
    )

    if ($Path -cmatch '^(?:extensions/drm-copilot/resources/codex-and-agents-customizations/)?\.codex/agents/[^/]+-(?:c[1-4]|c3-elevated)\.toml$') {
        return 'generated'
    }

    $source = Get-ProcessReductionMappedSource -Path $Path
    if ($null -eq $source -or $null -eq $LiveText[$Path] -or $null -eq $LiveText[$source]) {
        return $null
    }
    if ((ConvertTo-ProcessReductionChainLf -Text $LiveText[$Path]) -cne (ConvertTo-ProcessReductionChainLf -Text $LiveText[$source])) {
        return $null
    }

    return $source
}

function Add-ProcessReductionTouch {
    <#
    .SYNOPSIS
        Records that an entry touched a path and one of its pre-images.
    #>
    [CmdletBinding()]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][hashtable]$Touched,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$PreImage
    )

    if (-not $Touched.ContainsKey($Path)) {
        $Touched[$Path] = [pscustomobject]@{ Entry = $Name; PreImage = [System.Collections.Generic.List[string]]::new() }
    }
    if ($PreImage.Length -gt 0) {
        $Touched[$Path].PreImage.Add($PreImage)
    }
}

function Invoke-ProcessReductionBlockStep {
    <#
    .SYNOPSIS
        Reverts the blocks of one block entry in the chain state and records each failure.
    #>
    [CmdletBinding()]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][object[]]$Block,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][hashtable]$State,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][hashtable]$Touched,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][System.Collections.Generic.List[string]]$ErrorList
    )

    foreach ($item in $Block) {
        if ($null -eq $State[$item.Path]) {
            $ErrorList.Add("${Name}: $($item.Path): the file is absent at this step.")
            continue
        }
        try {
            $State[$item.Path] = Invoke-ProcessReductionRevert -Text $State[$item.Path] -Block $item
            Add-ProcessReductionTouch -Touched $Touched -Name $Name -Path $item.Path -PreImage (ConvertTo-ProcessReductionChainLf -Text $item.Prior)
        } catch {
            $ErrorList.Add("${Name}: $($item.Path): $($_.Exception.Message)")
        }
    }
}

function Test-ProcessReductionBlockText {
    <#
    .SYNOPSIS
        Records an error for each block whose Current (before) or non-empty Prior (after) is absent.
    #>
    [CmdletBinding()]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][object[]]$Block,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][hashtable]$State,
        [Parameter(Mandatory = $true)][ValidateSet('Current', 'Prior')][string]$Side,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][System.Collections.Generic.List[string]]$ErrorList
    )

    $when = if ($Side -ceq 'Current') { 'before' } else { 'after' }
    foreach ($item in $Block) {
        $expected = $item.$Side
        if ($Side -ceq 'Prior' -and [string]::IsNullOrEmpty($expected)) {
            continue
        }
        $text = $State[$item.Path]
        if ([string]::IsNullOrEmpty($expected) -or $null -eq $text -or -not $text.Contains((ConvertTo-ProcessReductionChainLf -Text $expected), [System.StringComparison]::Ordinal)) {
            $ErrorList.Add("${Name}: $($item.Path): the revert block $Side text is absent $when the patch is reverted.")
        }
    }
}

function Invoke-ProcessReductionPatchStep {
    <#
    .SYNOPSIS
        Reverts every hunk of every non-derived path of one stored patch in the chain state.
    #>
    [CmdletBinding()]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][object[]]$Hunk,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][hashtable]$LiveText,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][hashtable]$State,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][hashtable]$Touched,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][System.Collections.Generic.List[string]]$ErrorList
    )

    foreach ($group in @($Hunk | Group-Object -Property Path -CaseSensitive)) {
        $path = $group.Name
        if ($null -ne (Get-ProcessReductionDerivedSource -Path $path -LiveText $LiveText)) {
            continue
        }
        foreach ($item in @($group.Group | Sort-Object -Property Start -Descending)) {
            $prior = [string[]]@($item.Prior)
            if ($item.Kind -ceq 'create') {
                if ($null -eq $State[$path]) {
                    $ErrorList.Add("${Name}: ${path}: the file the entry created is absent at this step.")
                } else {
                    $createdText = (ConvertTo-ProcessReductionChainLf -Text $State[$path]).TrimStart([char]0xFEFF)
                    $hunkText = (([string[]]@($item.Current) -join "`n")).TrimStart([char]0xFEFF)
                    if ($createdText.EndsWith("`n", [System.StringComparison]::Ordinal)) {
                        $createdText = $createdText.Substring(0, $createdText.Length - 1)
                    }
                    if ($createdText -cne $hunkText) {
                        $ErrorList.Add("${Name}: ${path}: the file the entry created differs from its create hunk.")
                    }
                }
                $State[$path] = $null
                Add-ProcessReductionTouch -Touched $Touched -Name $Name -Path $path -PreImage ''
            } elseif ($item.Kind -ceq 'delete' -and $null -ne $State[$path]) {
                $ErrorList.Add("${Name}: ${path}: the file the entry deleted exists at this step.")
            } elseif ($item.Kind -ceq 'delete') {
                $State[$path] = ($prior -join "`n") + "`n"
                Add-ProcessReductionTouch -Touched $Touched -Name $Name -Path $path -PreImage ($prior -join "`n")
            } elseif ($null -eq $State[$path]) {
                $ErrorList.Add("${Name}: ${path}: the file is absent at this step.")
            } else {
                try {
                    $State[$path] = Invoke-ProcessReductionHunkRevert -Text $State[$path] -Hunk $item
                    Add-ProcessReductionTouch -Touched $Touched -Name $Name -Path $path -PreImage ($prior -join "`n")
                } catch {
                    $ErrorList.Add("${Name}: ${path}: $($_.Exception.Message)")
                }
            }
        }
    }
}

function Get-ProcessReductionEndStateError {
    <#
    .SYNOPSIS
        Returns an error per pre-image that is absent from the end state of its path.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][hashtable]$Touch,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][hashtable]$State
    )

    foreach ($path in @($Touch.Keys | Sort-Object)) {
        $record = $Touch[$path]
        $final = $State[$path]
        foreach ($preImage in $record.PreImage) {
            if ($null -eq $final -or -not $final.Contains($preImage, [System.StringComparison]::Ordinal)) {
                "$($record.Entry): ${path}: the end state lacks a pre-image of the entry."
            }
        }
    }
}

function Get-ProcessReductionLanding {
    <#
    .SYNOPSIS
        Splits an entry's Prior Text into its landings and returns them in revert order.

    .DESCRIPTION
        A heading '### Later Landing: <label>' outside a fence starts a later landing. One
        object per landing carries Label and Block: the later landings last heading first,
        then the first landing, labeled 'first', with the blocks above the first heading. An
        entry with no Prior Text returns only the first landing, with no blocks. Throws,
        naming the label, for a later landing that holds no revert block.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Text
    )

    $priorText = Get-ProcessReductionSection -Text (ConvertTo-ProcessReductionChainLf -Text $Text) -Heading 'Prior Text'
    $labels = [System.Collections.Generic.List[string]]::new()
    $parts = [System.Collections.Generic.List[object]]::new()
    $labels.Add('first')
    $parts.Add([System.Collections.Generic.List[string]]::new())
    $openLength = 0
    $lines = if ($null -eq $priorText) { [string[]]@() } else { $priorText.Split("`n") }
    foreach ($line in $lines) {
        $fence = [regex]::Match($line, '^ {0,3}(`{3,})[ \t]*([^`]*?)[ \t]*$')
        if ($openLength -eq 0 -and $fence.Success) {
            $openLength = $fence.Groups[1].Length
        } elseif ($openLength -gt 0 -and $fence.Success -and $fence.Groups[2].Value -ceq '' -and $fence.Groups[1].Length -ge $openLength) {
            $openLength = 0
        } elseif ($openLength -eq 0 -and $line -cmatch '^### Later Landing:[ \t]*(?<label>\S.*?)[ \t]*$') {
            $labels.Add($Matches['label'])
            $parts.Add([System.Collections.Generic.List[string]]::new())
            continue
        }
        $parts[$parts.Count - 1].Add($line)
    }

    for ($index = $parts.Count - 1; $index -ge 0; $index--) {
        $block = @(Get-ProcessReductionRevertBlock -Text ($parts[$index] -join "`n"))
        if ($index -gt 0 -and $block.Count -eq 0) {
            throw "Later landing '$($labels[$index])' holds no revert block."
        }
        [pscustomobject]@{ Label = $labels[$index]; Block = $block }
    }
}

function Merge-ProcessReductionTouch {
    <#
    .SYNOPSIS
        Copies one landing's touched records into the chain's map; a later call wins a path.
    #>
    [CmdletBinding()]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][hashtable]$Touch,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][hashtable]$Touched
    )

    foreach ($path in $Touched.Keys) {
        $Touch[$path] = $Touched[$path]
    }
}

function Invoke-ProcessReductionChain {
    <#
    .SYNOPSIS
        Reverts every entry newest-first in memory; returns IsValid, Errors, and FinalText.

    .DESCRIPTION
        Entry holds Name and Text; PatchText maps a patch name to its text; LiveText maps a
        path to text, $null when missing. Landings are parsed from the chain-state text of
        the entry's own file. In each entry's turn its later landings are reverted first,
        last heading first, each error prefixed '<entry> (later landing <label>)'; then its
        first landing. A patch entry's first-landing block Current must occur before its
        hunks are reverted and its non-empty Prior after. StopBefore names an entry: the
        chain stops after that entry's later landings and before its first landing. At the
        end, each pre-image of the oldest touching landing is present. Errors name entry
        and path.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][object[]]$Entry,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][hashtable]$PatchText,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][hashtable]$LiveText,
        [string]$LedgerPath = 'docs/engineering/process-reductions',
        [string]$StopBefore = ''
    )

    if ($StopBefore.Length -gt 0 -and @($Entry | Where-Object { $_.Name -ceq $StopBefore }).Count -eq 0) {
        throw "StopBefore '$StopBefore' names no supplied entry."
    }
    $state = @{}
    foreach ($key in $LiveText.Keys) {
        $state[$key] = if ($null -eq $LiveText[$key]) { $null } else { ConvertTo-ProcessReductionChainLf -Text $LiveText[$key] }
    }
    $errorList = [System.Collections.Generic.List[string]]::new()
    $touch = @{}

    foreach ($item in @($Entry | Sort-Object -Property Name -Descending)) {
        $name = $item.Name
        $entryPath = "$LedgerPath/$name"
        $text = if ($null -ne $state[$entryPath]) { $state[$entryPath] } else { ConvertTo-ProcessReductionChainLf -Text $item.Text }
        try {
            $landings = @(Get-ProcessReductionLanding -Text $text)
        } catch {
            $errorList.Add("${name}: $($_.Exception.Message)")
            continue
        }
        for ($index = 0; $index -lt $landings.Count - 1; $index++) {
            $landingTouched = @{}
            Invoke-ProcessReductionBlockStep -Name "$name (later landing $($landings[$index].Label))" -Block @($landings[$index].Block) -State $state -Touched $landingTouched -ErrorList $errorList
            Merge-ProcessReductionTouch -Touch $touch -Touched $landingTouched
        }
        if ($name -ceq $StopBefore) {
            break
        }
        $blocks = @($landings[$landings.Count - 1].Block)
        $touched = @{}
        $stepArgs = @{ Name = $name; State = $state; Touched = $touched; ErrorList = $errorList }
        if ($null -eq (Get-ProcessReductionSection -Text $text -Heading 'Stored Patch')) {
            Invoke-ProcessReductionBlockStep @stepArgs -Block $blocks
        } else {
            $patchName = [System.IO.Path]::GetFileNameWithoutExtension($name) + '.patch'
            try {
                if ($null -eq $PatchText[$patchName]) {
                    throw 'the stored patch was not supplied.'
                }
                $hunks = @(Get-ProcessReductionPatchHunk -PatchText $PatchText[$patchName])
            } catch {
                $errorList.Add("${name}: patches/${patchName}: $($_.Exception.Message)")
                continue
            }
            Test-ProcessReductionBlockText -Name $name -Block $blocks -State $state -Side Current -ErrorList $errorList
            Invoke-ProcessReductionPatchStep @stepArgs -Hunk $hunks -LiveText $LiveText
            Test-ProcessReductionBlockText -Name $name -Block $blocks -State $state -Side Prior -ErrorList $errorList
        }
        Merge-ProcessReductionTouch -Touch $touch -Touched $touched
    }

    $errorList.AddRange([string[]]@(Get-ProcessReductionEndStateError -Touch $touch -State $state))
    return [pscustomobject]@{ IsValid = $errorList.Count -eq 0; Errors = $errorList.ToArray(); FinalText = $state }
}

function Read-ProcessReductionChainInput {
    <#
    .SYNOPSIS
        Reads the ledger, its stored patches, and the live text of every path they name.

    .DESCRIPTION
        The one read seam of this module; it writes nothing. Returns Entries, PatchText, and
        LiveText ($null for a missing file) over every path a block or patch section names,
        each entry file, and each mapped source path, as Invoke-ProcessReductionChain takes.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [string]$LedgerPath = 'docs/engineering/process-reductions'
    )

    $ledgerRoot = Join-Path -Path $RepositoryRoot -ChildPath $LedgerPath
    $ledger = Read-ProcessReductionLedger -LedgerPath $ledgerRoot
    $paths = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $patchText = @{}
    foreach ($patchName in @($ledger.PatchNames)) {
        $patchText[$patchName] = [string](Get-Content -LiteralPath (Join-Path -Path $ledgerRoot -ChildPath "patches/$patchName") -Raw)
        @(Get-ProcessReductionPatchHunk -PatchText $patchText[$patchName]) | ForEach-Object { [void]$paths.Add($_.Path) }
    }
    foreach ($entry in @($ledger.Entries)) {
        [void]$paths.Add("$LedgerPath/$($entry.Name)")
        $priorText = Get-ProcessReductionSection -Text $entry.Text -Heading 'Prior Text'
        if ($null -ne $priorText) {
            @(Get-ProcessReductionRevertBlock -Text $priorText) | ForEach-Object { [void]$paths.Add($_.Path) }
        }
    }
    foreach ($path in @($paths)) {
        $source = Get-ProcessReductionMappedSource -Path $path
        if ($null -ne $source) {
            [void]$paths.Add($source)
        }
    }

    $liveText = @{}
    foreach ($path in $paths) {
        $fullPath = Join-Path -Path $RepositoryRoot -ChildPath $path
        $liveText[$path] = if (Test-Path -LiteralPath $fullPath -PathType Leaf) { [string](Get-Content -LiteralPath $fullPath -Raw) } else { $null }
    }

    return [pscustomobject]@{ Entries = @($ledger.Entries); PatchText = $patchText; LiveText = $liveText; LedgerPath = $LedgerPath }
}

Export-ModuleMember -Function @(
    'Get-ProcessReductionPatchHunk',
    'Invoke-ProcessReductionHunkRevert',
    'Get-ProcessReductionDerivedSource',
    'Get-ProcessReductionLanding',
    'Invoke-ProcessReductionChain',
    'Read-ProcessReductionChainInput'
)
