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

Export-ModuleMember -Function Get-RunbookPinnedToolVersion
