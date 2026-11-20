Set-StrictMode -Version Latest

# Path-scoped rule surface (issue #1028, spec D-4, OQ-2, OQ-3, PQ-1). Each source is the pair
# scripts/harness-generation/sources/rules/<name>.json and <name>.md. The Markdown body holds named sections, each
# introduced by a marker line '<!-- harness-section: <key> -->'. The JSON lists the targets of the rule, each with:
#   kind         claude (.claude/rules/<x>.md), copilot (.github/instructions/<x>.instructions.md), or
#                codex (.agents/skills/<x>/SKILL.md, only for a rule stem absent from .claude/skills, OQ-2)
#   path         the target path
#   frontmatter  ordered [{ key, value }] with raw value text (rendered 'key:' + value), between '---' lines
#   sections     the ordered section keys rendered for this target (a section may be listed for one target only)
#   substitutions optional ordered [{ find, replace }] exact-text replacements, each occurring exactly once
# A Claude target with no 'paths' key, or with a '**' glob, is rejected unless the source declares
# "claudeUnconditional": true. Every target is written with its bundle copy; no file is renamed or deleted (PQ-1).

Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'HarnessGeneration.psm1')

function Get-HarnessRuleSourceFolder {
    <#
    .SYNOPSIS
        Returns the repository-relative folder of the rule sources.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param()
    return 'scripts/harness-generation/sources/rules'
}

function Get-HarnessRuleSection {
    <#
    .SYNOPSIS
        Splits a rule source body into its named sections; text before the first marker is not allowed.
    .OUTPUTS
        An ordered dictionary of section key to section text.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([Parameter(Mandatory = $true)][AllowEmptyString()][string] $Text, [Parameter(Mandatory = $true)][string] $SourcePath)
    $sections = [ordered]@{}
    $markers = [regex]::Matches($Text, '(?m)^<!-- harness-section: ([a-z0-9][a-z0-9-]*) -->\n')
    if ($markers.Count -eq 0) { throw "Malformed source '${SourcePath}': no section marker." }
    if ($markers[0].Index -ne 0) { throw "Malformed source '${SourcePath}': text before the first section marker." }
    for ($index = 0; $index -lt $markers.Count; $index++) {
        $key = $markers[$index].Groups[1].Value
        if ($sections.Contains($key)) { throw "Malformed source '${SourcePath}': section '$key' is defined twice." }
        $start = $markers[$index].Index + $markers[$index].Length
        $end = if ($index + 1 -lt $markers.Count) { $markers[$index + 1].Index } else { $Text.Length }
        $sections[$key] = $Text.Substring($start, $end - $start)
    }
    return $sections
}

function Test-HarnessRuleTargetPath {
    <#
    .SYNOPSIS
        Returns the rule stem when a target path matches the pattern of its kind, otherwise $null.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)][string] $Kind, [Parameter(Mandatory = $true)][string] $Path)
    $pattern = switch ($Kind) {
        'claude' { '^\.claude/rules/([a-z0-9][a-z0-9-]*)\.md$' }
        'copilot' { '^\.github/instructions/([a-z0-9][a-z0-9-]*)\.instructions\.md$' }
        'codex' { '^\.agents/skills/([a-z0-9][a-z0-9-]*)/SKILL\.md$' }
        default { $null }
    }
    if ($null -eq $pattern -or $Path -cnotmatch $pattern) { return $null }
    return $Matches[1]
}

function Format-HarnessRuleFrontmatter {
    <#
    .SYNOPSIS
        Renders ordered frontmatter keys with raw values between '---' lines; an empty list renders nothing.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)][AllowEmptyCollection()][object[]] $Frontmatter)
    if ($Frontmatter.Count -eq 0) { return '' }
    $builder = [System.Text.StringBuilder]::new()
    $null = $builder.Append("---`n")
    foreach ($item in $Frontmatter) { $null = $builder.Append("$($item.key):$($item.value)`n") }
    $null = $builder.Append("---`n")
    return $builder.ToString()
}

function Assert-HarnessRuleTarget {
    <#
    .SYNOPSIS
        Validates one target of a rule source; throws naming the source path on the first violation.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] $Target,
        [Parameter(Mandatory = $true)][System.Collections.IDictionary] $Sections,
        [Parameter(Mandatory = $true)][bool] $ClaudeUnconditional,
        [Parameter(Mandatory = $true)][pscustomobject] $Context,
        [Parameter(Mandatory = $true)][string] $SourcePath
    )
    foreach ($field in @('kind', 'path', 'frontmatter', 'sections')) {
        if ($null -eq $Target -or $null -eq $Target.PSObject.Properties[$field]) { throw "Malformed source '${SourcePath}': a target has no '$field'." }
    }
    $stem = Test-HarnessRuleTargetPath -Kind ([string]$Target.kind) -Path ([string]$Target.path)
    if ($null -eq $stem) { throw "Malformed source '${SourcePath}': unknown target '$($Target.path)' of kind '$($Target.kind)'." }
    if ([string]$Target.kind -ceq 'codex' -and $null -ne (& $Context.ReadFile ".claude/skills/$stem/SKILL.md")) {
        throw "Malformed source '${SourcePath}': codex rule-skill target '$($Target.path)' names a stem that has a Claude skill."
    }
    foreach ($item in @($Target.frontmatter)) {
        if ($null -eq $item -or $null -eq $item.PSObject.Properties['key'] -or $null -eq $item.PSObject.Properties['value'] -or [string]::IsNullOrEmpty([string]$item.key)) {
            throw "Malformed source '${SourcePath}': target '$($Target.path)' has a frontmatter item without key or value."
        }
    }
    if ([string]$Target.kind -ceq 'copilot' -and @($Target.frontmatter).Count -eq 0) { throw "Malformed source '${SourcePath}': copilot target '$($Target.path)' has no frontmatter." }
    if ([string]$Target.kind -ceq 'claude' -and -not $ClaudeUnconditional) {
        $paths = @($Target.frontmatter | Where-Object { [string]$_.key -ceq 'paths' })
        if ($paths.Count -eq 0) { throw "Malformed source '${SourcePath}': claude target '$($Target.path)' has no 'paths' key and the source does not declare claudeUnconditional." }
        if (([string]$paths[0].value).Contains('"**"')) { throw "Malformed source '${SourcePath}': claude target '$($Target.path)' has a '**' glob and the source does not declare claudeUnconditional." }
    }
    foreach ($key in @($Target.sections)) {
        if (-not $Sections.Contains([string]$key)) { throw "Malformed source '${SourcePath}': target '$($Target.path)' lists unknown section '$key'." }
    }
}

function ConvertTo-HarnessRuleTargetText {
    <#
    .SYNOPSIS
        Renders one target: frontmatter, then the listed sections in order, then its ordered substitutions.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] $Target,
        [Parameter(Mandatory = $true)][System.Collections.IDictionary] $Sections,
        [Parameter(Mandatory = $true)][string] $SourcePath
    )
    $builder = [System.Text.StringBuilder]::new()
    $null = $builder.Append((Format-HarnessRuleFrontmatter -Frontmatter @($Target.frontmatter)))
    foreach ($key in @($Target.sections)) { $null = $builder.Append([string]$Sections[[string]$key]) }
    $text = $builder.ToString()
    $index = 0
    $substitutions = if ($null -ne $Target.PSObject.Properties['substitutions']) { @($Target.substitutions) } else { @() }
    foreach ($item in $substitutions) {
        $index++
        $find = [string]$item.find
        if ($find.Length -eq 0) { throw "Malformed source '${SourcePath}': target '$($Target.path)' substitution $index has an empty 'find'." }
        $count = 0
        $position = $text.IndexOf($find, [System.StringComparison]::Ordinal)
        $first = $position
        while ($position -ge 0) { $count++; $position = $text.IndexOf($find, $position + $find.Length, [System.StringComparison]::Ordinal) }
        if ($count -ne 1) { throw "Malformed source '${SourcePath}': target '$($Target.path)' substitution $index find occurs $count time(s); it must occur exactly once." }
        $text = $text.Substring(0, $first) + [string]$item.replace + $text.Substring($first + $find.Length)
    }
    return $text
}

function Get-HarnessRuleFileMap {
    <#
    .SYNOPSIS
        Returns the rule surface result: every target of every rule source and its bundle copy.
    .DESCRIPTION
        Every source is validated and rendered before any write. A selected parity-matrix target (kind
        path-scoped-rule, disposition generated, owner_child 3) that no source produces is reported as NO-SOURCE, and a
        claude or copilot target that is not a selected matrix target is rejected as unknown.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)][pscustomobject] $Context)
    $folder = Get-HarnessRuleSourceFolder
    $matrix = Import-HarnessGenerationMatrix -Context $Context
    $selectedTargets = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($entry in @(Get-HarnessMatrixSelection -Matrix $matrix -Kind 'path-scoped-rule' -Disposition 'generated' -OwnerChild 3)) {
        foreach ($path in @($entry.target_paths)) { $null = $selectedTargets.Add([string]$path) }
    }
    $files = [ordered]@{}
    $produced = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $jsonPaths = [string[]]@(& $Context.ListFiles $folder | Where-Object { ([string]$_).EndsWith('.json') })
    [System.Array]::Sort($jsonPaths, [System.StringComparer]::Ordinal)
    foreach ($jsonPath in $jsonPaths) {
        $mdPath = $jsonPath.Substring(0, $jsonPath.Length - '.json'.Length) + '.md'
        try { $source = (& $Context.ReadFile $jsonPath) | ConvertFrom-Json -ErrorAction Stop }
        catch { throw "Malformed source '${jsonPath}': not valid JSON." }
        if ($null -eq $source -or $null -eq $source.PSObject.Properties['targets'] -or @($source.targets).Count -eq 0) { throw "Malformed source '${jsonPath}': missing 'targets'." }
        $body = & $Context.ReadFile $mdPath
        if ($null -eq $body) { throw "Malformed source '${mdPath}': the section body does not exist." }
        $sections = Get-HarnessRuleSection -Text (ConvertTo-HarnessGeneratedText -Text ([string]$body)) -SourcePath $mdPath
        $unconditional = $null -ne $source.PSObject.Properties['claudeUnconditional'] -and $source.claudeUnconditional -eq $true
        foreach ($target in @($source.targets)) {
            Assert-HarnessRuleTarget -Target $target -Sections $sections -ClaudeUnconditional $unconditional -Context $Context -SourcePath $jsonPath
            $path = [string]$target.path
            if ([string]$target.kind -cne 'codex' -and -not $selectedTargets.Contains($path)) { throw "Malformed source '${jsonPath}': target '$path' is not a selected parity-matrix target." }
            if ($produced.Contains($path)) { throw "Malformed source '${jsonPath}': target '$path' is produced by more than one source." }
            $null = $produced.Add($path)
            $text = ConvertTo-HarnessRuleTargetText -Target $target -Sections $sections -SourcePath $jsonPath
            $files[$path] = $text
            $files[(Get-HarnessBundlePath -Path $path)] = $text
        }
    }
    $findings = [System.Collections.Generic.List[object]]::new()
    foreach ($path in @($selectedTargets | Sort-Object)) {
        if (-not $produced.Contains($path)) { $findings.Add((New-HarnessFinding -Kind 'NO-SOURCE' -Path $path -Detail 'selected rule target has no source')) }
    }
    return [pscustomobject]@{ Files = $files; ManagedFolders = [string[]]@(); Findings = $findings.ToArray() }
}

Export-ModuleMember -Function @(
    'Get-HarnessRuleSourceFolder', 'Get-HarnessRuleSection', 'Test-HarnessRuleTargetPath', 'Format-HarnessRuleFrontmatter',
    'Assert-HarnessRuleTarget', 'ConvertTo-HarnessRuleTargetText', 'Get-HarnessRuleFileMap'
)
