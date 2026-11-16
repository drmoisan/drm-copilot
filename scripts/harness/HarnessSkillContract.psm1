Set-StrictMode -Version Latest

# Harness skill contracts (issue #1025): checks `.agents/skills/<name>/references/standard.md` against
# spec `### Contract Format` rules 1 to 5 and 7 (rule 3's prose statement for `## Objective` is advisory
# and not checked, decision D-R6).

$script:SectionOrder = @('Objective', 'Observable Behaviors', 'Acceptance Checks')
$script:ForbiddenName = @('TaskMaster', 'No-COM')

function Get-HarnessSkillContractRequiredSet {
    <#
    .SYNOPSIS
        Returns the sorted skill names whose matrix entry is kind skill, ecosystem codex, disposition shared.
    .PARAMETER Matrix
        The parsed matrix object.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param([Parameter(Mandatory)] $Matrix)
    $names = @(@($Matrix.features) | Where-Object {
            $properties = @($_.PSObject.Properties.Name)
            ($properties -contains 'kind') -and ($properties -contains 'ecosystem') -and ($properties -contains 'disposition') -and
            $_.kind -ceq 'skill' -and $_.ecosystem -ceq 'codex' -and $_.disposition -ceq 'shared'
        } | ForEach-Object { [string]$_.name })
    $array = [string[]]$names
    [Array]::Sort($array, [StringComparer]::Ordinal)
    return $array
}

function ConvertTo-HarnessContractViolation {
    <#
    .SYNOPSIS
        Builds one contract violation.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory)][string] $Name, [Parameter(Mandatory)][string] $Rule, [Parameter(Mandatory)][string] $Detail)
    return [pscustomobject]@{ Name = $Name; Rule = $Rule; Message = ".agents/skills/$Name/references/standard.md: [$Rule] $Detail" }
}

function Test-HarnessContractSequence {
    <#
    .SYNOPSIS
        Returns $true when the numbers start at 1 and increase by 1 without gaps or repeats.
    .PARAMETER Number
        The item numbers in document order.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowEmptyCollection()][int[]] $Number = @())
    for ($i = 0; $i -lt $Number.Count; $i++) { if ($Number[$i] -ne $i + 1) { return $false } }
    return $true
}

function Get-HarnessSkillContractViolation {
    <#
    .SYNOPSIS
        Returns the violations of one contract text.
    .PARAMETER Name
        The skill folder name.
    .PARAMETER Content
        The contract text.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([Parameter(Mandatory)][string] $Name, [Parameter(Mandatory)][AllowEmptyString()][string] $Content)
    $found = [System.Collections.Generic.List[object]]::new()
    $add = { param([string] $Rule, [string] $Detail) $found.Add((ConvertTo-HarnessContractViolation -Name $Name -Rule $Rule -Detail $Detail)) }
    $lines = @($Content -split "`r?`n")
    if ($lines[0] -cne "# Gold Standard: $Name") { & $add 'h1' "first line must be '# Gold Standard: $Name'" }
    if (@($lines | Where-Object { $_ -match '^#\s' }).Count -ne 1) { & $add 'h1' 'exactly one H1 heading is required' }
    if (@($lines | Where-Object { $_ -match '^#{3,6}\s' }).Count -gt 0) { & $add 'heading-level' 'H3 or deeper headings are not used' }
    $headings = @($lines | Where-Object { $_ -match '^##\s' } | ForEach-Object { ($_ -replace '^##\s+', '').Trim() })
    if (($headings -join '|') -cne ($script:SectionOrder -join '|')) {
        foreach ($missing in @($script:SectionOrder | Where-Object { $headings -cnotcontains $_ })) { & $add 'h2-missing' "missing H2 '## $missing'" }
        foreach ($extra in @($headings | Where-Object { $script:SectionOrder -cnotcontains $_ })) { & $add 'h2-extra' "unexpected H2 '## $extra'" }
        $known = @($headings | Where-Object { $script:SectionOrder -ccontains $_ })
        $expected = @($script:SectionOrder | Where-Object { $known -ccontains $_ })
        if (($known -join '|') -cne ($expected -join '|') -or @($known | Select-Object -Unique).Count -ne $known.Count) { & $add 'h2-order' 'H2 headings must be Objective, Observable Behaviors, Acceptance Checks in this order, once each' }
    }
    $sections = @{}
    $current = $null
    foreach ($line in $lines) {
        if ($line -match '^##\s+(.+)$') { $current = $Matches[1].Trim(); if (-not $sections.ContainsKey($current)) { $sections[$current] = [System.Collections.Generic.List[string]]::new() }; continue }
        if ($line -match '^#\s') { $current = $null; continue }
        if ($null -ne $current) { $sections[$current].Add($line) }
    }
    foreach ($section in $script:SectionOrder) {
        if ($sections.ContainsKey($section) -and -not (($sections[$section] -join '').Trim())) { & $add 'empty-section' "section '## $section' is empty" }
    }
    $behaviors = [System.Collections.Generic.List[int]]::new()
    $checks = [System.Collections.Generic.List[int]]::new()
    $cited = [System.Collections.Generic.HashSet[int]]::new()
    $citations = [System.Collections.Generic.List[int]]::new()
    foreach ($pair in @(@('Observable Behaviors', 'OB'), @('Acceptance Checks', 'AC'))) {
        if (-not $sections.ContainsKey($pair[0]) -or -not (($sections[$pair[0]] -join '').Trim())) { continue }
        $items = @($sections[$pair[0]] | Where-Object { $_ -match '^- ' })
        if ($items.Count -eq 0) { & $add 'list-item' "section '## $($pair[0])' has no list item"; continue }
        foreach ($item in $items) {
            if ($pair[1] -eq 'OB') {
                if ($item -cmatch '^- \*\*OB-(\d+)\*\* \S') { $behaviors.Add([int]$Matches[1]) } else { & $add 'behavior-prefix' "behavior item does not begin '- **OB-<n>** ': $item" }
            } elseif ($item -cmatch '^- \*\*AC-(\d+)\*\* \((OB-\d+(?:, OB-\d+)*)\) \S') {
                $checks.Add([int]$Matches[1])
                foreach ($ref in ($Matches[2] -split ', ')) { $citations.Add([int]($ref.Substring(3))); [void]$cited.Add([int]($ref.Substring(3))) }
            } else { & $add 'check-prefix' "check item does not begin '- **AC-<n>** (<refs>) ': $item" }
        }
    }
    if (-not (Test-HarnessContractSequence -Number $behaviors.ToArray())) { & $add 'numbering' 'OB-<n> must start at 1 and increase by 1 without gaps or repeats' }
    if (-not (Test-HarnessContractSequence -Number $checks.ToArray())) { & $add 'numbering' 'AC-<n> must start at 1 and increase by 1 without gaps or repeats' }
    foreach ($ref in ($citations | Select-Object -Unique)) { if (-not $behaviors.Contains($ref)) { & $add 'unknown-citation' "a check cites OB-$ref, which does not exist" } }
    foreach ($behavior in ($behaviors | Select-Object -Unique)) { if (-not $cited.Contains($behavior)) { & $add 'uncited-behavior' "OB-$behavior is cited by no check" } }
    if (@($lines | Where-Object { $_ -match '^\s*[-*+]\s+\[[ xX]\]' }).Count -gt 0) { & $add 'checkbox' 'checkbox syntax is not allowed' }
    foreach ($product in $script:ForbiddenName) { if ($Content.Contains($product)) { & $add 'product-name' "consuming-product name '$product' is not allowed" } }
    return $found.ToArray()
}

function Get-HarnessSkillContractSetViolation {
    <#
    .SYNOPSIS
        Returns the violations of every contract in the matrix-derived required set.
    .PARAMETER Matrix
        The parsed matrix object.
    .PARAMETER RepositoryRoot
        Repository root passed to the seams.
    .PARAMETER ReadFile
        Script block returning a file's text (root, relative path).
    .PARAMETER TestPath
        Script block returning whether a file exists (root, relative path).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory)] $Matrix,
        [string] $RepositoryRoot = (Get-Location).Path,
        [scriptblock] $ReadFile = { param([string] $Root, [string] $Path) [IO.File]::ReadAllText((Join-Path $Root $Path)) },
        [scriptblock] $TestPath = { param([string] $Root, [string] $Path) Test-Path -LiteralPath (Join-Path $Root $Path) -PathType Leaf }
    )
    $found = [System.Collections.Generic.List[object]]::new()
    foreach ($name in (Get-HarnessSkillContractRequiredSet -Matrix $Matrix)) {
        $path = ".agents/skills/$name/references/standard.md"
        if (-not (& $TestPath $RepositoryRoot $path)) { $found.Add((ConvertTo-HarnessContractViolation -Name $name -Rule 'missing' -Detail 'contract file is missing')); continue }
        foreach ($violation in (Get-HarnessSkillContractViolation -Name $name -Content (& $ReadFile $RepositoryRoot $path))) { $found.Add($violation) }
    }
    return $found.ToArray()
}

Export-ModuleMember -Function Get-HarnessSkillContractRequiredSet, Get-HarnessSkillContractViolation, Get-HarnessSkillContractSetViolation
