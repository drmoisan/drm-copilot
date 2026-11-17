Set-StrictMode -Version Latest

# Harness inventory (issue #1025): enumerates the native features of the Claude Code, Codex and
# GitHub Copilot ecosystems per spec `### Parity Matrix: Feature Kinds and Inventory Rules` and
# derives each feature id per `### Parity Matrix: Identifier Encoding`.

$script:UnreservedPattern = '^[A-Za-z0-9._-]$'
$script:IdPattern = '^(claude|codex|copilot|cross-tool):[a-z-]+:(?:[A-Za-z0-9._-]|%[0-9A-F]{2})+(?:/(?:[A-Za-z0-9._-]|%[0-9A-F]{2})*)*(?:~(?:[A-Za-z0-9._-]|%[0-9A-F]{2})+(?:~[0-9]{2})?)?$'
$script:ListingRoots = @(
    '.claude/skills', '.claude/agents', '.claude/rules', '.agents/skills', '.codex/agents', '.codex/prompts',
    '.github/skills', '.github/agents', '.github/instructions', '.github/prompts', '.github/hooks'
)
$script:ListingFiles = @(
    'AGENTS.md', 'CLAUDE.md', '.github/copilot-instructions.md', '.claude/settings.json', '.claude/settings.local.json',
    '.claude/hooks/pretooluse-dispatch.json', '.codex/hooks/pretooluse-dispatch.json', '.codex/config.toml', '.mcp.json',
    '.vscode/settings.json'
)
$script:ExcludedPrefixes = @(
    '.claude/agent-memory/', '.claude/state/', '.claude/worktrees/', '.codex/state/', 'artifacts/', '.claude/lib/',
    '.codex/scripts/', 'extensions/drm-copilot/resources/'
)
$script:ExcludedFiles = @(
    '.claude/settings.local.json', '.vscode/settings.json', '.agents/README.md', '.agents/skills/README.md', '.github/skills/README.md'
)

function ConvertTo-HarnessIdComponent {
    <#
    .SYNOPSIS
        Percent-encodes one id component per spec item 2 (UTF-8 bytes; unreserved bytes kept).
    .PARAMETER Value
        The unencoded component; the empty string encodes to the empty string.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][AllowEmptyString()][string] $Value)
    $builder = [System.Text.StringBuilder]::new()
    foreach ($byte in [System.Text.Encoding]::UTF8.GetBytes($Value)) {
        $char = [char]$byte
        if ($byte -lt 128 -and ([string]$char) -match $script:UnreservedPattern) { [void]$builder.Append($char) }
        else { [void]$builder.Append('%').Append($byte.ToString('X2')) }
    }
    return $builder.ToString()
}

function ConvertFrom-HarnessIdComponent {
    <#
    .SYNOPSIS
        Decodes one canonical id component; throws on a non-canonical form.
    .PARAMETER Value
        The encoded component.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][AllowEmptyString()][string] $Value)
    $bytes = [System.Collections.Generic.List[byte]]::new()
    $index = 0
    while ($index -lt $Value.Length) {
        $char = $Value[$index]
        if ($char -eq '%') {
            $hex = if ($index + 2 -lt $Value.Length) { $Value.Substring($index + 1, 2) } else { $Value.Substring($index + 1) }
            if ($hex -cnotmatch '^[0-9A-F]{2}$') { throw "Non-canonical id component '$Value': '%' must be followed by two uppercase hexadecimal digits." }
            $byte = [Convert]::ToByte($hex, 16)
            if ($byte -lt 128 -and ([string][char]$byte) -match $script:UnreservedPattern) { throw "Non-canonical id component '$Value': unreserved character percent-encoded as %$hex." }
            $bytes.Add($byte)
            $index += 3
            continue
        }
        if (-not (([string]$char) -match $script:UnreservedPattern)) { throw "Non-canonical id component '$Value': character '$char' must be percent-encoded." }
        $bytes.Add([byte][char]$char)
        $index++
    }
    $strict = [System.Text.UTF8Encoding]::new($false, $true)
    try { return $strict.GetString($bytes.ToArray()) }
    catch { throw "Non-canonical id component '$Value': decoded bytes are not valid UTF-8." }
}

function ConvertTo-HarnessFeatureId {
    <#
    .SYNOPSIS
        Builds a feature id from its ecosystem, kind and name components (spec items 2 to 4).
    .PARAMETER Ecosystem
        The owning ecosystem.
    .PARAMETER Kind
        The feature kind.
    .PARAMETER NameComponent
        The unencoded name components (three for a hook registration, one otherwise).
    .PARAMETER SourcePath
        The disambiguating source path of a duplicate-group member.
    .PARAMETER Occurrence
        The one-based same-file position of a duplicate-group member (1 to 99); 0 for none.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][string] $Ecosystem,
        [Parameter(Mandatory)][string] $Kind,
        [Parameter(Mandatory)][AllowEmptyString()][AllowEmptyCollection()][string[]] $NameComponent,
        [string] $SourcePath,
        [ValidateRange(0, 99)][int] $Occurrence = 0
    )
    $encoded = @($NameComponent | ForEach-Object { ConvertTo-HarnessIdComponent -Value $_ })
    $id = "${Ecosystem}:${Kind}:" + ($encoded -join '/')
    if ($SourcePath) {
        $id += '~' + (ConvertTo-HarnessIdComponent -Value $SourcePath)
        if ($Occurrence -gt 0) { $id += '~' + $Occurrence.ToString('00') }
    }
    return $id
}

function ConvertFrom-HarnessFeatureId {
    <#
    .SYNOPSIS
        Decodes a feature id into its parts; throws when the id is not canonical (spec item 6).
    .PARAMETER Id
        The feature id.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory)][string] $Id)
    if ($Id -cnotmatch $script:IdPattern) { throw "Feature id '$Id' does not match the id pattern." }
    $first = $Id.IndexOf(':'); $second = $Id.IndexOf(':', $first + 1)
    $parts = $Id.Substring($second + 1).Split('~')
    $components = @($parts[0].Split('/') | ForEach-Object { ConvertFrom-HarnessIdComponent -Value $_ })
    $sourcePath = if ($parts.Count -gt 1) { ConvertFrom-HarnessIdComponent -Value $parts[1] } else { $null }
    $occurrence = if ($parts.Count -gt 2) { [int]$parts[2] } else { 0 }
    return [pscustomobject]@{
        Ecosystem = $Id.Substring(0, $first); Kind = $Id.Substring($first + 1, $second - $first - 1)
        NameComponent = $components; SourcePath = $sourcePath; Occurrence = $occurrence
    }
}

function Test-HarnessInventoryPathExcluded {
    <#
    .SYNOPSIS
        Returns $true when a repository-relative path is on the spec exclusion list.
    .PARAMETER Path
        Repository-relative path (either separator).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory)][string] $Path)
    $normalized = $Path.Replace('\', '/').TrimStart('/')
    if ($script:ExcludedFiles -contains $normalized) { return $true }
    foreach ($prefix in $script:ExcludedPrefixes) { if ($normalized.StartsWith($prefix, [StringComparison]::Ordinal)) { return $true } }
    if ($normalized -match '^(\.claude|\.agents|\.github)/skills/[^/]+/.+/' -and $normalized -notmatch '^\.agents/skills/[^/]+/agents/openai\.yaml$') { return $true }
    return $false
}

function Get-HarnessCommandStem {
    <#
    .SYNOPSIS
        Returns the stem of the first .ps1 or .sh script named in a command, or the command text itself.
    .PARAMETER Command
        The hook command text.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][AllowEmptyString()][string] $Command)
    $match = [regex]::Match($Command, '([^\s"''/\\]+)\.(?:ps1|sh)(?![A-Za-z0-9])')
    if ($match.Success) { return $match.Groups[1].Value }
    return $Command
}

function ConvertFrom-HarnessTomlString {
    <#
    .SYNOPSIS
        Unquotes a TOML basic or literal string value; other values are returned trimmed.
    .PARAMETER Value
        The raw value text after '='.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][AllowEmptyString()][string] $Value)
    $text = $Value.Trim()
    if ($text -match "^'([^']*)'") { return $Matches[1] }
    if ($text -match '^"((?:[^"\\]|\\.)*)"') { return ($Matches[1] -replace '\\(["\\])', '$1') }
    return $text
}

function Get-HarnessFrontmatterLine {
    <#
    .SYNOPSIS
        Returns the lines between the opening and closing '---' of a Markdown file, or none.
    .PARAMETER Text
        The file text.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([Parameter(Mandatory)][AllowEmptyString()][string] $Text)
    $lines = $Text -split "`r?`n"
    if ($lines.Count -lt 2 -or $lines[0].Trim() -ne '---') { return , @() }
    $end = -1
    for ($i = 1; $i -lt $lines.Count; $i++) { if ($lines[$i].Trim() -eq '---') { $end = $i; break } }
    if ($end -lt 0) { return , @() }
    return , @($lines[1..($end - 1)] | Where-Object { $null -ne $_ })
}

function Get-HarnessFrontmatterKey {
    <#
    .SYNOPSIS
        Returns the distinct top-level keys of a frontmatter block (anchored regular expression).
    .PARAMETER Line
        The frontmatter lines.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([AllowEmptyCollection()][string[]] $Line = @())
    return , @($Line | Where-Object { $_ -match '^([A-Za-z0-9_-]+):' } | ForEach-Object { ([regex]::Match($_, '^([A-Za-z0-9_-]+):')).Groups[1].Value } | Select-Object -Unique)
}

function Get-HarnessAgentHookTriple {
    <#
    .SYNOPSIS
        Returns (event, matcher, command) triples from the `hooks:` block of agent frontmatter.
    .PARAMETER Line
        The frontmatter lines.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([AllowEmptyCollection()][string[]] $Line = @())
    $result = [System.Collections.Generic.List[object]]::new()
    $inHooks = $false; $hookEvent = $null; $matcher = ''; $itemIndent = -1
    foreach ($text in $Line) {
        if ($text -match '^[A-Za-z0-9_-]+:') { $inHooks = ($text -match '^hooks:\s*$'); $hookEvent = $null; continue }
        if (-not $inHooks -or $text.Trim() -eq '') { continue }
        if ($text -match '^(\s+)([A-Za-z]+):\s*$' -and $Matches[1].Length -le 2) { $hookEvent = $Matches[2]; $matcher = ''; $itemIndent = -1; continue }
        if ($null -eq $hookEvent) { continue }
        if ($text -match '^(\s*)-\s') {
            $indent = $Matches[1].Length
            if ($itemIndent -lt 0) { $itemIndent = $indent }
            if ($indent -eq $itemIndent) { $matcher = '' }
        }
        if ($text -match '^\s*-?\s*matcher:\s*(.*)$') { $matcher = ConvertFrom-HarnessTomlString -Value $Matches[1]; continue }
        if ($text -match '^\s*-?\s*command:\s*(.*)$') { $result.Add([pscustomobject]@{ Event = $hookEvent; Matcher = $matcher; Command = (ConvertFrom-HarnessTomlString -Value $Matches[1]) }) }
    }
    return , $result.ToArray()
}

function Get-HarnessJsonHookTriple {
    <#
    .SYNOPSIS
        Returns (event, matcher, command, pointer) tuples from a JSON `hooks` object.
    .PARAMETER Hooks
        The parsed `hooks` object (event name to group array).
    .PARAMETER EventFilter
        Optional event names to read; all events when empty.
    .PARAMETER CommandField
        The command property name ('command' for grouped hooks; 'powershell' for flat Copilot hooks).
    .PARAMETER Flat
        Read each event array element as one hook (Copilot `.github/hooks/*.json` shape).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([Parameter(Mandatory)] $Hooks, [string[]] $EventFilter = @(), [string] $CommandField = 'command', [switch] $Flat)
    $result = [System.Collections.Generic.List[object]]::new()
    foreach ($property in $Hooks.PSObject.Properties) {
        if ($EventFilter.Count -gt 0 -and $EventFilter -notcontains $property.Name) { continue }
        $groups = @($property.Value)
        for ($g = 0; $g -lt $groups.Count; $g++) {
            $group = $groups[$g]
            $matcher = if ($group.PSObject.Properties.Name -contains 'matcher') { [string]$group.matcher } else { '' }
            if ($Flat) {
                $command = if ($group.PSObject.Properties.Name -contains $CommandField) { [string]$group.$CommandField } else { '' }
                $result.Add([pscustomobject]@{ Event = $property.Name; Matcher = $matcher; Command = $command; Pointer = "/hooks/$($property.Name)/$g" })
                continue
            }
            $hookList = @(if ($group.PSObject.Properties.Name -contains 'hooks') { $group.hooks })
            for ($h = 0; $h -lt $hookList.Count; $h++) {
                $result.Add([pscustomobject]@{ Event = $property.Name; Matcher = $matcher; Command = [string]$hookList[$h].$CommandField; Pointer = "/hooks/$($property.Name)/$g/hooks/$h" })
            }
        }
    }
    return , $result.ToArray()
}

function Get-HarnessTomlFeature {
    <#
    .SYNOPSIS
        Returns raw features of `.codex/config.toml`: top-level keys and first-level tables as settings,
        `[mcp_servers.<id>]`, `[permissions.<profile>]` and `[[hooks.<Event>]]` registrations.
    .PARAMETER Text
        The TOML text.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([Parameter(Mandatory)][AllowEmptyString()][string] $Text)
    $result = [System.Collections.Generic.List[object]]::new()
    $table = $null; $registration = $null
    foreach ($line in ($Text -split "`r?`n")) {
        $trimmed = $line.Trim()
        if ($trimmed -match '^\[\[([^\[\]]+)\]\]$') {
            $segments = @(Split-HarnessTomlKey -Key $Matches[1])
            $table = 'array'
            if ($segments.Count -eq 2 -and $segments[0] -eq 'hooks') {
                $registration = [pscustomobject]@{ Kind = 'hook-registration'; Event = $segments[1]; Matcher = ''; Command = $null; Pointer = "[[hooks.$($segments[1])]]" }
                $result.Add($registration)
            } elseif (-not ($segments.Count -eq 3 -and $segments[0] -eq 'hooks' -and $segments[2] -eq 'hooks')) { $registration = $null }
            continue
        }
        if ($trimmed -match '^\[([^\[\]]+)\]$') {
            $registration = $null
            $segments = @(Split-HarnessTomlKey -Key $Matches[1]); $table = $Matches[1]
            if ($segments.Count -eq 2 -and $segments[0] -eq 'mcp_servers') { $result.Add([pscustomobject]@{ Kind = 'mcp-server'; Name = $segments[1]; Pointer = "[$table]" }) }
            elseif ($segments.Count -eq 2 -and $segments[0] -eq 'permissions') { $result.Add([pscustomobject]@{ Kind = 'permission'; Name = $segments[1]; Pointer = "[$table]" }) }
            elseif ($segments.Count -eq 1 -and $segments[0] -notin @('hooks', 'mcp_servers', 'permissions')) { $result.Add([pscustomobject]@{ Kind = 'setting'; Name = $segments[0]; Pointer = "[$table]" }) }
            continue
        }
        if ($trimmed -match '^([A-Za-z0-9_-]+)\s*=\s*(.*)$') {
            $key = $Matches[1]; $value = $Matches[2]
            if ($null -eq $table) { $result.Add([pscustomobject]@{ Kind = 'setting'; Name = $key; Pointer = $key }); continue }
            if ($null -ne $registration) {
                if ($key -eq 'matcher' -and $table -eq 'array' -and $null -eq $registration.Command) { $registration.Matcher = ConvertFrom-HarnessTomlString -Value $value }
                elseif ($key -eq 'command' -and $null -eq $registration.Command) { $registration.Command = ConvertFrom-HarnessTomlString -Value $value }
            }
        }
    }
    return , $result.ToArray()
}

function Split-HarnessTomlKey {
    <#
    .SYNOPSIS
        Splits a dotted TOML key, honoring quoted segments.
    .PARAMETER Key
        The dotted key text inside a table header.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([Parameter(Mandatory)][string] $Key)
    return @([regex]::Matches($Key, '"[^"]*"|''[^'']*''|[^.\s]+') | ForEach-Object { $_.Value.Trim('"', "'") })
}

function ConvertTo-HarnessRawFeature {
    <#
    .SYNOPSIS
        Builds one raw inventory record before the duplicate tie-break.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([string] $Ecosystem, [string] $Kind, [AllowEmptyString()][string[]] $Component, [string] $SourcePath, [string] $Pointer)
    return [pscustomobject]@{
        Ecosystem = $Ecosystem; Kind = $Kind; Component = @($Component); Name = (@($Component) -join '/'); SourcePath = $SourcePath; Pointer = $Pointer
        BaseId = (ConvertTo-HarnessFeatureId -Ecosystem $Ecosystem -Kind $Kind -NameComponent @($Component))
    }
}

function Get-HarnessHookRecord {
    <#
    .SYNOPSIS
        Converts hook triples into raw hook-registration records.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([string] $Ecosystem, [AllowEmptyCollection()][object[]] $Triple = @(), [string] $SourcePath)
    return , @($Triple | ForEach-Object {
            $pointer = if ($_.PSObject.Properties.Name -contains 'Pointer') { $_.Pointer } else { $null }
            ConvertTo-HarnessRawFeature -Ecosystem $Ecosystem -Kind 'hook-registration' -Component @($_.Event, $_.Matcher, (Get-HarnessCommandStem -Command ([string]$_.Command))) -SourcePath $SourcePath -Pointer $pointer
        })
}

function Get-HarnessRawFeature {
    <#
    .SYNOPSIS
        Applies the 13 inventory rules to a file list and returns raw records in source order.
    .PARAMETER File
        Repository-relative POSIX paths, already filtered by the exclusion list.
    .PARAMETER ReadText
        Script block that returns a file's text from its repository-relative path.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([AllowEmptyCollection()][string[]] $File = @(), [Parameter(Mandatory)][scriptblock] $ReadText)
    $records = [System.Collections.Generic.List[object]]::new()
    $add = { param($Items) foreach ($item in @($Items)) { if ($null -ne $item) { $records.Add($item) } } }
    $instructions = @{ 'AGENTS.md' = 'cross-tool'; 'CLAUDE.md' = 'claude'; '.github/copilot-instructions.md' = 'copilot' }
    foreach ($path in $File) { if ($instructions.ContainsKey($path)) { & $add (ConvertTo-HarnessRawFeature -Ecosystem $instructions[$path] -Kind 'instructions' -Component @(Split-Path -Leaf $path) -SourcePath $path) } }
    $skillTrees = @(@('claude', '.claude/skills'), @('codex', '.agents/skills'), @('copilot', '.github/skills'))
    foreach ($tree in $skillTrees) {
        $skillFiles = @($File | Where-Object { $_ -match "^$([regex]::Escape($tree[1]))/([^/]+)/SKILL\.md$" })
        $keys = [System.Collections.Generic.List[string]]::new()
        foreach ($path in $skillFiles) {
            & $add (ConvertTo-HarnessRawFeature -Ecosystem $tree[0] -Kind 'skill' -Component @($path.Split('/')[2]) -SourcePath $path)
            foreach ($key in (Get-HarnessFrontmatterKey -Line (Get-HarnessFrontmatterLine -Text (& $ReadText $path)))) { if (-not $keys.Contains($key)) { $keys.Add($key) } }
        }
        foreach ($key in $keys) { & $add (ConvertTo-HarnessRawFeature -Ecosystem $tree[0] -Kind 'skill-frontmatter-field' -Component @($key) -SourcePath "$($tree[1])" -Pointer $key) }
    }
    foreach ($path in @($File | Where-Object { $_ -match '^\.agents/skills/([^/]+)/agents/openai\.yaml$' })) { & $add (ConvertTo-HarnessRawFeature -Ecosystem 'codex' -Kind 'skill-metadata-file' -Component @($path.Split('/')[2]) -SourcePath $path) }
    foreach ($path in @($File | Where-Object { $_ -match '^\.claude/rules/[^/]+\.md$' })) { & $add (ConvertTo-HarnessRawFeature -Ecosystem 'claude' -Kind 'path-scoped-rule' -Component @([IO.Path]::GetFileNameWithoutExtension($path)) -SourcePath $path) }
    foreach ($path in @($File | Where-Object { $_ -match '^\.github/instructions/[^/]+\.instructions\.md$' })) { & $add (ConvertTo-HarnessRawFeature -Ecosystem 'copilot' -Kind 'path-scoped-rule' -Component @((Split-Path -Leaf $path) -replace '\.instructions\.md$', '') -SourcePath $path) }
    $agentTrees = @(@('claude', '^\.claude/agents/[^/]+\.md$', '\.md$'), @('codex', '^\.codex/agents/[^/]+\.toml$', '\.toml$'), @('copilot', '^\.github/agents/[^/]+\.agent\.md$', '\.agent\.md$'))
    foreach ($tree in $agentTrees) {
        $keys = [System.Collections.Generic.List[string]]::new()
        foreach ($path in @($File | Where-Object { $_ -match $tree[1] })) {
            $stem = (Split-Path -Leaf $path) -replace $tree[2], ''
            & $add (ConvertTo-HarnessRawFeature -Ecosystem $tree[0] -Kind 'agent' -Component @($stem) -SourcePath $path)
            $text = & $ReadText $path
            if ($tree[0] -eq 'codex') {
                $top = [System.Collections.Generic.List[string]]::new()
                foreach ($tomlLine in ($text -split "`r?`n")) { if ($tomlLine -match '^\s*\[') { break }; $top.Add($tomlLine) }
                $found = @($top | Where-Object { $_ -match '^([A-Za-z0-9_-]+)\s*=' } | ForEach-Object { ([regex]::Match($_, '^([A-Za-z0-9_-]+)')).Value })
            } else {
                $front = Get-HarnessFrontmatterLine -Text $text
                $found = Get-HarnessFrontmatterKey -Line $front
                if ($tree[0] -eq 'copilot' -and $found -contains 'handoffs') { & $add (ConvertTo-HarnessRawFeature -Ecosystem 'copilot' -Kind 'handoff' -Component @($stem) -SourcePath $path -Pointer 'handoffs') }
                if ($tree[0] -eq 'claude') { & $add (Get-HarnessHookRecord -Ecosystem 'claude' -Triple (Get-HarnessAgentHookTriple -Line $front) -SourcePath $path) }
            }
            foreach ($key in $found) { if (-not $keys.Contains($key)) { $keys.Add($key) } }
        }
        $treeRoot = @('.claude/agents', '.codex/agents', '.github/agents')[[array]::IndexOf(@('claude', 'codex', 'copilot'), $tree[0])]
        foreach ($key in $keys) { & $add (ConvertTo-HarnessRawFeature -Ecosystem $tree[0] -Kind 'subagent-frontmatter-field' -Component @($key) -SourcePath $treeRoot -Pointer $key) }
    }
    foreach ($path in @($File | Where-Object { $_ -match '^\.github/prompts/.+\.prompt\.md$' })) { & $add (ConvertTo-HarnessRawFeature -Ecosystem 'copilot' -Kind 'prompt' -Component @((Split-Path -Leaf $path) -replace '\.prompt\.md$', '') -SourcePath $path) }
    foreach ($path in @($File | Where-Object { $_ -match '^\.codex/prompts/[^/]+\.md$' })) { & $add (ConvertTo-HarnessRawFeature -Ecosystem 'codex' -Kind 'prompt' -Component @([IO.Path]::GetFileNameWithoutExtension($path)) -SourcePath $path) }
    if ($File -contains '.claude/settings.json') {
        $settings = (& $ReadText '.claude/settings.json') | ConvertFrom-Json
        foreach ($property in $settings.PSObject.Properties) {
            switch ($property.Name) {
                '$schema' { }
                'hooks' { & $add (Get-HarnessHookRecord -Ecosystem 'claude' -Triple (Get-HarnessJsonHookTriple -Hooks $property.Value) -SourcePath '.claude/settings.json') }
                'permissions' { foreach ($sub in $property.Value.PSObject.Properties) { & $add (ConvertTo-HarnessRawFeature -Ecosystem 'claude' -Kind 'permission' -Component @($sub.Name) -SourcePath '.claude/settings.json' -Pointer "/permissions/$($sub.Name)") } }
                default { & $add (ConvertTo-HarnessRawFeature -Ecosystem 'claude' -Kind 'setting' -Component @($property.Name) -SourcePath '.claude/settings.json' -Pointer "/$($property.Name)") }
            }
        }
    }
    foreach ($registry in @(@('claude', '.claude/hooks/pretooluse-dispatch.json'), @('codex', '.codex/hooks/pretooluse-dispatch.json'))) {
        if ($File -notcontains $registry[1]) { continue }
        $parsed = (& $ReadText $registry[1]) | ConvertFrom-Json
        if ($parsed.PSObject.Properties.Name -contains 'hooks') { & $add (Get-HarnessHookRecord -Ecosystem $registry[0] -Triple (Get-HarnessJsonHookTriple -Hooks $parsed.hooks -EventFilter @('PreToolUse')) -SourcePath $registry[1]) }
    }
    if ($File -contains '.codex/config.toml') {
        foreach ($item in (Get-HarnessTomlFeature -Text (& $ReadText '.codex/config.toml'))) {
            if ($item.Kind -eq 'hook-registration') { & $add (Get-HarnessHookRecord -Ecosystem 'codex' -Triple @($item) -SourcePath '.codex/config.toml') }
            else { & $add (ConvertTo-HarnessRawFeature -Ecosystem 'codex' -Kind $item.Kind -Component @($item.Name) -SourcePath '.codex/config.toml' -Pointer $item.Pointer) }
        }
    }
    foreach ($path in @($File | Where-Object { $_ -match '^\.github/hooks/[^/]+\.json$' })) {
        $parsed = (& $ReadText $path) | ConvertFrom-Json
        if ($parsed.PSObject.Properties.Name -contains 'hooks') { & $add (Get-HarnessHookRecord -Ecosystem 'copilot' -Triple (Get-HarnessJsonHookTriple -Hooks $parsed.hooks -CommandField 'powershell' -Flat) -SourcePath $path) }
    }
    if ($File -contains '.mcp.json') {
        $mcp = (& $ReadText '.mcp.json') | ConvertFrom-Json
        if ($mcp.PSObject.Properties.Name -contains 'mcpServers') { foreach ($server in $mcp.mcpServers.PSObject.Properties) { & $add (ConvertTo-HarnessRawFeature -Ecosystem 'claude' -Kind 'mcp-server' -Component @($server.Name) -SourcePath '.mcp.json' -Pointer "/mcpServers/$($server.Name)") } }
    }
    return , $records.ToArray()
}

function Get-HarnessInventory {
    <#
    .SYNOPSIS
        Enumerates every native feature and returns id, ecosystem, kind, name, source_path and
        optional source_pointer, sorted ordinally by id.
    .PARAMETER RepositoryRoot
        Repository root used by the default listing and reading seams.
    .PARAMETER ListFiles
        Script block returning repository-relative paths (default: the feature source folders on disk).
    .PARAMETER ReadFile
        Script block returning the text of a repository-relative path (default: read from disk).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [string] $RepositoryRoot = (Get-Location).Path,
        [scriptblock] $ListFiles,
        [scriptblock] $ReadFile
    )
    if (-not $ListFiles) {
        $ListFiles = {
            param([string] $Root)
            $paths = [System.Collections.Generic.List[string]]::new()
            foreach ($relative in $script:ListingRoots) {
                $full = Join-Path $Root $relative
                if (Test-Path -LiteralPath $full) { Get-ChildItem -LiteralPath $full -Recurse -File | ForEach-Object { $paths.Add([IO.Path]::GetRelativePath($Root, $_.FullName).Replace('\', '/')) } }
            }
            foreach ($relative in $script:ListingFiles) { if (Test-Path -LiteralPath (Join-Path $Root $relative) -PathType Leaf) { $paths.Add($relative) } }
            return , $paths.ToArray()
        }
    }
    if (-not $ReadFile) { $ReadFile = { param([string] $Root, [string] $Path) [IO.File]::ReadAllText((Join-Path $Root $Path)) } }
    $listed = & $ListFiles $RepositoryRoot
    $files = @($listed | ForEach-Object { ([string]$_).Replace('\', '/') } | Where-Object { -not (Test-HarnessInventoryPathExcluded -Path $_) })
    $read = { param([string] $Path) & $ReadFile $RepositoryRoot $Path }.GetNewClosure()
    $raw = Get-HarnessRawFeature -File $files -ReadText $read
    $features = [System.Collections.Generic.List[object]]::new()
    foreach ($group in ($raw | Group-Object -Property BaseId -CaseSensitive)) {
        $members = @($group.Group)
        if ($members.Count -eq 1) { $features.Add((ConvertTo-HarnessInventoryEntry -Record $members[0] -Id $members[0].BaseId)); continue }
        foreach ($byFile in ($members | Group-Object -Property SourcePath -CaseSensitive)) {
            $same = @($byFile.Group)
            if ($same.Count -gt 99) { throw "Inventory error: more than 99 members of duplicate group '$($group.Name)' in '$($byFile.Name)'." }
            for ($i = 0; $i -lt $same.Count; $i++) {
                $occurrence = if ($same.Count -gt 1) { $i + 1 } else { 0 }
                $id = ConvertTo-HarnessFeatureId -Ecosystem $same[$i].Ecosystem -Kind $same[$i].Kind -NameComponent $same[$i].Component -SourcePath $same[$i].SourcePath -Occurrence $occurrence
                $features.Add((ConvertTo-HarnessInventoryEntry -Record $same[$i] -Id $id))
            }
        }
    }
    $array = $features.ToArray()
    [Array]::Sort($array, [System.Comparison[object]] { param($left, $right) [string]::CompareOrdinal($left.id, $right.id) })
    return $array
}

function ConvertTo-HarnessInventoryEntry {
    <#
    .SYNOPSIS
        Converts a raw record into the returned inventory entry shape.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory)] $Record, [Parameter(Mandatory)][string] $Id)
    $entry = [ordered]@{ id = $Id; ecosystem = $Record.Ecosystem; kind = $Record.Kind; name = $Record.Name; source_path = $Record.SourcePath }
    if ($Record.Pointer) { $entry['source_pointer'] = $Record.Pointer }
    return [pscustomobject]$entry
}

Export-ModuleMember -Function Get-HarnessInventory, Test-HarnessInventoryPathExcluded, ConvertTo-HarnessFeatureId, ConvertFrom-HarnessFeatureId
