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
        Records that an entry touched a path, whether it created it, and one of its pre-images.
    #>
    [CmdletBinding()]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][hashtable]$Touched,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$PreImage,
        [switch]$Created
    )

    if (-not $Touched.ContainsKey($Path)) {
        $Touched[$Path] = [pscustomobject]@{ Entry = $Name; Created = $false; PreImage = [System.Collections.Generic.List[string]]::new() }
    }
    if ($Created) {
        $Touched[$Path].Created = $true
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
                $State[$path] = $null
                Add-ProcessReductionTouch -Touched $Touched -Name $Name -Path $path -PreImage '' -Created
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
        Returns an error per created path that is present and per pre-image that is absent at the end.
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
        if ($record.Created -and $null -ne $final) {
            "$($record.Entry): ${path}: the end state holds a file that the entry created."
        }
        foreach ($preImage in $record.PreImage) {
            if ($null -eq $final -or -not $final.Contains($preImage, [System.StringComparison]::Ordinal)) {
                "$($record.Entry): ${path}: the end state lacks a pre-image of the entry."
            }
        }
    }
}

function Invoke-ProcessReductionChain {
    <#
    .SYNOPSIS
        Reverts every entry newest-first in memory; returns IsValid, Errors, and FinalText.

    .DESCRIPTION
        Entry holds Name and Text; PatchText maps a patch name to its text; LiveText maps a
        path to text, $null when missing. Blocks are parsed from the chain-state text of the
        entry's own file. A patch entry's block Current must occur before its hunks are
        reverted and its non-empty Prior after. At the end, each path the oldest touching
        entry created is absent and each of its pre-images present. Errors name entry and path.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][object[]]$Entry,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][hashtable]$PatchText,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][hashtable]$LiveText,
        [string]$LedgerPath = 'docs/engineering/process-reductions'
    )

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
        $priorText = Get-ProcessReductionSection -Text $text -Heading 'Prior Text'
        $blocks = @()
        if ($null -ne $priorText) {
            $blocks = @(Get-ProcessReductionRevertBlock -Text $priorText)
        }
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
        foreach ($path in $touched.Keys) {
            $touch[$path] = $touched[$path]
        }
    }

    $errorList.AddRange([string[]]@(Get-ProcessReductionEndStateError -Touch $touch -State $state))
    return [pscustomobject]@{ IsValid = $errorList.Count -eq 0; Errors = $errorList.ToArray(); FinalText = $state }
}

Export-ModuleMember -Function @(
    'Get-ProcessReductionPatchHunk',
    'Invoke-ProcessReductionHunkRevert',
    'Get-ProcessReductionDerivedSource',
    'Invoke-ProcessReductionChain'
)
