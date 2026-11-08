<#
.SYNOPSIS
    Pure functions that check a human-exception runbook's tool commands against pinned tool versions (issue #1128).

.DESCRIPTION
    Resolves pinned tool versions from lockfile content, derives the tool name from a command line,
    and reports version-marking findings for a runbook. Every function is pure over content strings;
    file reads belong to the caller. This module imports its siblings with -ErrorAction Stop and has
    no siblings today, so the sentence records the convention for later additions.

    Counted fences are fenced code blocks whose info string is empty or one of sh, bash, shell,
    console, powershell, pwsh, ps1, cmd, bat. Other info strings are exempt. Each non-blank,
    non-comment line of a counted fence is a command. Immediately after the closing fence the
    runbook carries one 'Version check:' line per distinct tool of the block:
        Version check: verified against <tool> <version>
        Version check: not verified against <tool> <version>
        Version check: <tool> not pinned in this repository
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function ConvertTo-RunbookNormalizedToolName {
    <#
    .SYNOPSIS
        Applies PEP 503 normalization: lowercase, with runs of '-', '_' and '.' folded to '-'.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Name)

    return [regex]::Replace($Name.Trim().ToLowerInvariant(), '[-_.]+', '-')
}

function Get-RunbookPinnedToolVersion {
    <#
    .SYNOPSIS
        Maps a lockfile's content to a hashtable of normalized tool name to pinned version.
    .DESCRIPTION
        Supports poetry.lock and uv.lock ([[package]] name/version), package-lock.json (top-level
        node_modules/<name> entries; nested paths are ignored) and requirements*.txt (name==version).
        An unsupported file name returns an empty hashtable.
    .PARAMETER LockfileName
        The lockfile file name (no directory), used to select the format.
    .PARAMETER Content
        The lockfile text.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [string] $LockfileName,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Content
    )

    $pinned = @{}
    $fileName = $LockfileName.Trim()
    if ($fileName -eq 'poetry.lock' -or $fileName -eq 'uv.lock') {
        foreach ($block in [regex]::Split($Content, '(?m)^\[\[package\]\][ \t]*\r?$')) {
            $name = [regex]::Match($block, '(?m)^name[ \t]*=[ \t]*"([^"]+)"')
            $version = [regex]::Match($block, '(?m)^version[ \t]*=[ \t]*"([^"]+)"')
            if ($name.Success -and $version.Success) {
                $pinned[(ConvertTo-RunbookNormalizedToolName -Name $name.Groups[1].Value)] = $version.Groups[1].Value
            }
        }
    } elseif ($fileName -eq 'package-lock.json') {
        # -AsHashtable: package-lock.json carries an empty-string key for the root package.
        $document = $Content | ConvertFrom-Json -AsHashtable
        if ($document.ContainsKey('packages') -and $document['packages'] -is [System.Collections.IDictionary]) {
            foreach ($entry in $document['packages'].GetEnumerator()) {
                $match = [regex]::Match([string]$entry.Key, '^node_modules/((?:@[^/]+/)?[^/]+)$')
                if ($match.Success -and $entry.Value -is [System.Collections.IDictionary] -and $entry.Value.ContainsKey('version')) {
                    $pinned[(ConvertTo-RunbookNormalizedToolName -Name $match.Groups[1].Value)] = [string]$entry.Value['version']
                }
            }
        }
    } elseif ($fileName -match '^requirements.*\.txt$') {
        foreach ($line in [regex]::Split($Content, '\r?\n')) {
            $match = [regex]::Match($line, '^\s*([A-Za-z0-9][A-Za-z0-9._-]*)(?:\[[^\]]*\])?\s*==\s*([^\s;#]+)')
            if ($match.Success) {
                $pinned[(ConvertTo-RunbookNormalizedToolName -Name $match.Groups[1].Value)] = $match.Groups[2].Value
            }
        }
    }
    return $pinned
}

function Get-RunbookCommandToolName {
    <#
    .SYNOPSIS
        Derives the normalized tool name from one command line, or $null when none is found.
    .DESCRIPTION
        The first token names the tool, except that 'python -m X', 'python3 -m X', 'py -m X',
        'poetry run X', 'uv run X' and 'npx X' name X. A launcher that wraps another command
        ('poetry run python -m X') resolves the wrapped command.
    .PARAMETER CommandLine
        One command line from a runbook shell block.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $CommandLine)

    $text = [regex]::Replace($CommandLine.Trim(), '^\$\s+', '')
    if ([string]::IsNullOrWhiteSpace($text)) { return $null }
    $token = @($text -split '\s+')
    $first = [regex]::Replace($token[0], '\.exe$', '', 'IgnoreCase')
    # The array subexpression keeps a one-element result an array under strict mode.
    $rest = @(if ($token.Count -gt 1) { $token[1..($token.Count - 1)] })

    if (@('python', 'python3', 'py') -contains $first.ToLowerInvariant() -and $rest.Count -ge 2 -and $rest[0] -eq '-m') {
        return ConvertTo-RunbookNormalizedToolName -Name $rest[1]
    }
    if (($first -eq 'poetry' -or $first -eq 'uv') -and $rest.Count -ge 2 -and $rest[0] -eq 'run') {
        return Get-RunbookCommandToolName -CommandLine ($rest[1..($rest.Count - 1)] -join ' ')
    }
    if ($first -eq 'npx') {
        $operand = @($rest | Where-Object { -not $_.StartsWith('-') })
        if ($operand.Count -eq 0) { return $null }
        $name = [regex]::Replace($operand[0], '^(@?[^@]+)@.+$', '$1')
        return ConvertTo-RunbookNormalizedToolName -Name $name
    }
    return ConvertTo-RunbookNormalizedToolName -Name $first
}

function Get-RunbookCountedBlock {
    <#
    .SYNOPSIS
        Returns one object per counted fenced block: Command (its lines) and Marker (the consecutive
        'Version check:' lines that immediately follow the closing fence).
    .PARAMETER RunbookText
        The runbook text.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $RunbookText)

    $countedInfo = @('', 'sh', 'bash', 'shell', 'console', 'powershell', 'pwsh', 'ps1', 'cmd', 'bat')
    $line = @([regex]::Split($RunbookText, '\r?\n'))
    $index = 0
    while ($index -lt $line.Count) {
        $open = [regex]::Match($line[$index], '^\s*(`{3,}|~{3,})\s*([^\s`]*)')
        if (-not $open.Success) { $index++; continue }
        $fence = $open.Groups[1].Value
        $info = $open.Groups[2].Value.ToLowerInvariant()
        $command = [System.Collections.Generic.List[string]]::new()
        $cursor = $index + 1
        $closePattern = '^\s*' + [regex]::Escape([string]$fence[0]) + '{' + $fence.Length + ',}\s*$'
        while ($cursor -lt $line.Count -and $line[$cursor] -notmatch $closePattern) {
            $command.Add($line[$cursor])
            $cursor++
        }
        $marker = [System.Collections.Generic.List[string]]::new()
        $after = $cursor + 1
        while ($after -lt $line.Count -and $line[$after].TrimStart().StartsWith('Version check:')) {
            $marker.Add($line[$after].Trim())
            $after++
        }
        if ($countedInfo -contains $info) {
            [pscustomobject]@{ Command = $command.ToArray(); Marker = $marker.ToArray() }
        }
        $index = $cursor + 1
    }
}

function Get-RunbookCommandVersionFinding {
    <#
    .SYNOPSIS
        Reports version-marking findings for a runbook against a pinned-version map.
    .DESCRIPTION
        Finding classes: a tool with no marker line; a marker naming a version other than the pinned
        version; a 'not pinned' marker for a pinned tool; a malformed 'Version check:' line.
    .PARAMETER RunbookText
        The runbook text.
    .PARAMETER PinnedVersion
        Hashtable of normalized tool name to pinned version, merged from the repository lockfiles.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $RunbookText,
        [Parameter(Mandatory = $true)] [hashtable] $PinnedVersion
    )

    $finding = [System.Collections.Generic.List[string]]::new()
    $blockNumber = 0
    foreach ($block in @(Get-RunbookCountedBlock -RunbookText $RunbookText)) {
        $blockNumber++
        $tool = [System.Collections.Generic.List[string]]::new()
        foreach ($commandLine in $block.Command) {
            $trimmed = $commandLine.Trim()
            if ($trimmed.Length -eq 0 -or $trimmed.StartsWith('#')) { continue }
            $name = Get-RunbookCommandToolName -CommandLine $trimmed
            if ($null -ne $name -and -not $tool.Contains($name)) { $tool.Add($name) }
        }
        $marker = @{}
        foreach ($markerLine in $block.Marker) {
            $verified = [regex]::Match($markerLine, '^Version check:\s+(verified|not verified) against (\S+) (\S+)\s*$')
            $unpinned = [regex]::Match($markerLine, '^Version check:\s+(\S+) not pinned in this repository\s*$')
            if ($verified.Success) {
                $marker[(ConvertTo-RunbookNormalizedToolName -Name $verified.Groups[2].Value)] = @{ Kind = 'version'; Version = $verified.Groups[3].Value }
            } elseif ($unpinned.Success) {
                $marker[(ConvertTo-RunbookNormalizedToolName -Name $unpinned.Groups[1].Value)] = @{ Kind = 'unpinned'; Version = $null }
            } else {
                $finding.Add("Counted block $blockNumber has a malformed marker ``$markerLine``; use 'Version check: verified against <tool> <version>', 'Version check: not verified against <tool> <version>', or 'Version check: <tool> not pinned in this repository'.")
            }
        }
        foreach ($name in $tool) {
            $isPinned = $PinnedVersion.ContainsKey($name)
            $pinnedText = if ($isPinned) { "pinned version $($PinnedVersion[$name])" } else { 'not pinned in any lockfile' }
            if (-not $marker.ContainsKey($name)) {
                $finding.Add("Counted block $blockNumber runs tool $name ($pinnedText) and has no 'Version check:' line for it immediately after the closing fence.")
            } elseif ($marker[$name].Kind -eq 'unpinned' -and $isPinned) {
                $finding.Add("Counted block $blockNumber marks tool $name as not pinned, but it is pinned at version $($PinnedVersion[$name]).")
            } elseif ($marker[$name].Kind -eq 'version' -and (-not $isPinned -or $marker[$name].Version -ne $PinnedVersion[$name])) {
                $finding.Add("Counted block $blockNumber marks tool $name at version $($marker[$name].Version), which differs from the repository state ($pinnedText).")
            }
        }
    }
    return $finding.ToArray()
}

Export-ModuleMember -Function Get-RunbookPinnedToolVersion, Get-RunbookCommandToolName, Get-RunbookCommandVersionFinding
