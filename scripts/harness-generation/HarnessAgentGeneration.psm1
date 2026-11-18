Set-StrictMode -Version Latest

# Agent surface (issue #1028, spec D-11, OQ-5, OQ-9). Each source is the pair
# scripts/harness-generation/sources/agents/<name>.json and <name>.md. The Markdown body holds named sections, each
# introduced by a marker line '<!-- harness-section: <key> -->'. The JSON has two targets:
#   claude  { path, frontmatter: [{ key, value }], sections, substitutions? }
#           renders '---', each 'key:' + raw value, '---', then the listed sections and the substitutions.
#   codex   { path, keys: [{ key, value }], delimiter, sections, substitutions?, separator?, trailer? }
#           renders each 'key = ' + raw value, the raw separator (for example a blank line),
#           'developer_instructions = <delimiter>', the listed sections with the substitutions, the closing
#           delimiter, then the raw trailer.
# For a family in codex_model_policy.generated_agent_families of config/orchestration-routing.json, the codex keys
# carry no model keys: the module inserts the C3 'model' and 'model_reasoning_effort' after 'description', which is
# the alias form render_base_alias produces. Raw values pass 'Write(' and 'Edit(' literals through verbatim (OQ-9).

Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'HarnessGeneration.psm1')

function Get-HarnessAgentSourceFolder {
    <#
    .SYNOPSIS
        Returns the repository-relative folder of the agent sources.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param()
    return 'scripts/harness-generation/sources/agents'
}

function Get-HarnessAgentSection {
    <#
    .SYNOPSIS
        Splits an agent source body into its named sections; text before the first marker is not allowed.
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

function Get-HarnessAgentAliasPolicy {
    <#
    .SYNOPSIS
        Reads the generated agent families and the C3 profile from config/orchestration-routing.json.
    .OUTPUTS
        An object with Families (string[]), Model and Effort.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)][pscustomobject] $Context)
    $path = 'config/orchestration-routing.json'
    $text = & $Context.ReadFile $path
    if ($null -eq $text) { throw "The routing config '$path' does not exist." }
    $policy = ($text | ConvertFrom-Json).codex_model_policy
    if ($null -eq $policy -or $null -eq $policy.PSObject.Properties['generated_agent_families'] -or $null -eq $policy.complexity_to_profile.C3) {
        throw "The routing config '$path' has no codex_model_policy generated_agent_families or C3 profile."
    }
    return [pscustomobject]@{
        Families = [string[]]@($policy.generated_agent_families)
        Model    = [string]$policy.complexity_to_profile.C3.model
        Effort   = [string]$policy.complexity_to_profile.C3.model_reasoning_effort
    }
}

function Assert-HarnessAgentField {
    <#
    .SYNOPSIS
        Throws naming the source when an object lacks one of the listed fields.
    #>
    [CmdletBinding()]
    param([AllowNull()] $Object, [Parameter(Mandatory = $true)][string[]] $Field, [Parameter(Mandatory = $true)][string] $Label, [Parameter(Mandatory = $true)][string] $SourcePath)
    foreach ($name in $Field) {
        if ($null -eq $Object -or $null -eq $Object.PSObject.Properties[$name]) { throw "Malformed source '${SourcePath}': $Label has no '$name'." }
    }
}

function Assert-HarnessAgentKeyList {
    <#
    .SYNOPSIS
        Validates an ordered key list: each item has a non-empty key and a value, and the required keys are present.
    #>
    [CmdletBinding()]
    param([AllowEmptyCollection()][object[]] $Items, [Parameter(Mandatory = $true)][string[]] $Required, [Parameter(Mandatory = $true)][string] $Label, [Parameter(Mandatory = $true)][string] $SourcePath)
    $names = [System.Collections.Generic.List[string]]::new()
    foreach ($item in $Items) {
        if ($null -eq $item -or $null -eq $item.PSObject.Properties['key'] -or $null -eq $item.PSObject.Properties['value'] -or [string]::IsNullOrEmpty([string]$item.key)) {
            throw "Malformed source '${SourcePath}': $Label has an item without key or value."
        }
        $names.Add([string]$item.key)
    }
    foreach ($name in $Required) {
        if (-not $names.Contains($name)) { throw "Malformed source '${SourcePath}': $Label has no required key '$name'." }
    }
}

function ConvertTo-HarnessAgentBody {
    <#
    .SYNOPSIS
        Joins the listed sections in order and applies the ordered exact-once substitutions.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] $Target, [Parameter(Mandatory = $true)][System.Collections.IDictionary] $Sections, [Parameter(Mandatory = $true)][string] $SourcePath)
    $builder = [System.Text.StringBuilder]::new()
    foreach ($key in @($Target.sections)) {
        if (-not $Sections.Contains([string]$key)) { throw "Malformed source '${SourcePath}': target '$($Target.path)' lists unknown section '$key'." }
        $null = $builder.Append([string]$Sections[[string]$key])
    }
    $text = $builder.ToString()
    $substitutions = if ($null -ne $Target.PSObject.Properties['substitutions']) { @($Target.substitutions) } else { @() }
    $index = 0
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

function ConvertTo-HarnessClaudeAgentText {
    <#
    .SYNOPSIS
        Renders the Claude agent file: frontmatter keys in source order with raw values, then the body.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] $Target, [Parameter(Mandatory = $true)][System.Collections.IDictionary] $Sections, [Parameter(Mandatory = $true)][string] $SourcePath)
    Assert-HarnessAgentField -Object $Target -Field @('path', 'frontmatter', 'sections') -Label 'the claude target' -SourcePath $SourcePath
    Assert-HarnessAgentKeyList -Items @($Target.frontmatter) -Required @('name', 'description') -Label 'the claude frontmatter' -SourcePath $SourcePath
    $builder = [System.Text.StringBuilder]::new()
    $null = $builder.Append("---`n")
    foreach ($item in @($Target.frontmatter)) { $null = $builder.Append("$($item.key):$($item.value)`n") }
    $null = $builder.Append("---`n")
    $null = $builder.Append((ConvertTo-HarnessAgentBody -Target $Target -Sections $Sections -SourcePath $SourcePath))
    return $builder.ToString()
}

function ConvertTo-HarnessCodexAgentText {
    <#
    .SYNOPSIS
        Renders the base Codex agent TOML: keys in source order, the alias model keys for a generated family,
        developer_instructions from the body, then the raw trailer.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] $Target,
        [Parameter(Mandatory = $true)][System.Collections.IDictionary] $Sections,
        [Parameter(Mandatory = $true)][string] $Name,
        [Parameter(Mandatory = $true)][pscustomobject] $AliasPolicy,
        [Parameter(Mandatory = $true)][string] $SourcePath
    )
    Assert-HarnessAgentField -Object $Target -Field @('path', 'keys', 'delimiter', 'sections') -Label 'the codex target' -SourcePath $SourcePath
    $keys = @($Target.keys)
    Assert-HarnessAgentKeyList -Items $keys -Required @('name', 'description') -Label 'the codex keys' -SourcePath $SourcePath
    $delimiter = [string]$Target.delimiter
    if ($delimiter -cne "'''" -and $delimiter -cne '"""') { throw "Malformed source '${SourcePath}': the codex delimiter must be ''' or `"`"`"." }
    $isFamily = $AliasPolicy.Families -ccontains $Name
    $hasModel = @($keys | Where-Object { [string]$_.key -ceq 'model' -or [string]$_.key -ceq 'model_reasoning_effort' }).Count -gt 0
    if ($isFamily -and $hasModel) { throw "Malformed source '${SourcePath}': generated family '$Name' must not declare model keys; the C3 alias keys are inserted." }
    $builder = [System.Text.StringBuilder]::new()
    foreach ($item in $keys) {
        $null = $builder.Append("$($item.key) = $($item.value)`n")
        if ($isFamily -and [string]$item.key -ceq 'description') {
            $null = $builder.Append("model = `"$($AliasPolicy.Model)`"`nmodel_reasoning_effort = `"$($AliasPolicy.Effort)`"`n")
        }
    }
    $body = ConvertTo-HarnessAgentBody -Target $Target -Sections $Sections -SourcePath $SourcePath
    if ($body.Contains($delimiter)) { throw "Malformed source '${SourcePath}': the codex body contains its delimiter $delimiter." }
    $trailer = if ($null -ne $Target.PSObject.Properties['trailer']) { [string]$Target.trailer } else { '' }
    $separator = if ($null -ne $Target.PSObject.Properties['separator']) { [string]$Target.separator } else { '' }
    $null = $builder.Append("${separator}developer_instructions = $delimiter`n").Append($body).Append("$delimiter`n").Append($trailer)
    return $builder.ToString()
}

function Get-HarnessAgentFileMap {
    <#
    .SYNOPSIS
        Returns the agent surface result: the Claude agent, the base Codex agent and both bundle copies per source.
    .DESCRIPTION
        Every source renders before any write, so a missing required field throws first. Each source must name an
        agent whose claude and codex entries are selected (kind agent, disposition generated, owner_child 3) with
        the rendered paths as their target_paths; a selected agent without a source is reported as NO-SOURCE.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)][pscustomobject] $Context)
    $matrix = Import-HarnessGenerationMatrix -Context $Context
    $selected = @{}
    foreach ($entry in @(Get-HarnessMatrixSelection -Matrix $matrix -Kind 'agent' -Disposition 'generated' -OwnerChild 3)) {
        $selected["$($entry.ecosystem)|$($entry.name)"] = [string[]]@($entry.target_paths)
    }
    $policy = Get-HarnessAgentAliasPolicy -Context $Context
    $folder = Get-HarnessAgentSourceFolder
    $files = [ordered]@{}
    $produced = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $jsonPaths = [string[]]@(& $Context.ListFiles $folder | Where-Object { ([string]$_).EndsWith('.json') })
    [System.Array]::Sort($jsonPaths, [System.StringComparer]::Ordinal)
    foreach ($jsonPath in $jsonPaths) {
        $name = [System.IO.Path]::GetFileNameWithoutExtension($jsonPath)
        try { $source = (& $Context.ReadFile $jsonPath) | ConvertFrom-Json -ErrorAction Stop }
        catch { throw "Malformed source '${jsonPath}': not valid JSON." }
        Assert-HarnessAgentField -Object $source -Field @('claude', 'codex') -Label 'the source' -SourcePath $jsonPath
        $body = & $Context.ReadFile ($jsonPath.Substring(0, $jsonPath.Length - 5) + '.md')
        if ($null -eq $body) { throw "Malformed source '${jsonPath}': the section body does not exist." }
        $sections = Get-HarnessAgentSection -Text (ConvertTo-HarnessGeneratedText -Text ([string]$body)) -SourcePath $jsonPath
        $claudePath = ".claude/agents/$name.md"
        $codexPath = ".codex/agents/$name.toml"
        foreach ($pair in @(@('claude', $claudePath), @('codex', $codexPath))) {
            $targets = $selected["$($pair[0])|$name"]
            if ($null -eq $targets -or $targets -cnotcontains $pair[1]) { throw "Malformed source '${jsonPath}': '$($pair[1])' is not a selected parity-matrix target." }
            if ([string]$source.($pair[0]).path -cne $pair[1]) { throw "Malformed source '${jsonPath}': the $($pair[0]) target path must be '$($pair[1])'." }
        }
        $claudeText = ConvertTo-HarnessClaudeAgentText -Target $source.claude -Sections $sections -SourcePath $jsonPath
        $codexText = ConvertTo-HarnessCodexAgentText -Target $source.codex -Sections $sections -Name $name -AliasPolicy $policy -SourcePath $jsonPath
        foreach ($item in @(@($claudePath, $claudeText), @($codexPath, $codexText))) {
            $files[$item[0]] = $item[1]
            $files[(Get-HarnessBundlePath -Path $item[0])] = $item[1]
            $null = $produced.Add($item[0])
        }
    }
    $findings = [System.Collections.Generic.List[object]]::new()
    foreach ($key in @($selected.Keys | Sort-Object)) {
        foreach ($path in $selected[$key]) {
            if (-not $produced.Contains($path)) { $findings.Add((New-HarnessFinding -Kind 'NO-SOURCE' -Path $path -Detail 'selected agent target has no source')) }
        }
    }
    return [pscustomobject]@{ Files = $files; ManagedFolders = [string[]]@(); Findings = $findings.ToArray() }
}

Export-ModuleMember -Function @(
    'Get-HarnessAgentSourceFolder', 'Get-HarnessAgentSection', 'Get-HarnessAgentAliasPolicy', 'Assert-HarnessAgentField',
    'Assert-HarnessAgentKeyList', 'ConvertTo-HarnessAgentBody', 'ConvertTo-HarnessClaudeAgentText',
    'ConvertTo-HarnessCodexAgentText', 'Get-HarnessAgentFileMap'
)
