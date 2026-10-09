<#
    Scan-root definition and file enumeration for the enforcement-hook Python-invocation
    guard (issues #475 and #737).

    This file is test support and is not mirrored under
    `extensions/drm-copilot/resources/`. It is dot-sourced by
    `enforcement-hooks-no-python-invocation.Tests.ps1` (and by the scan-root rows file when
    that file exists) after `$script:RepoRoot` has been resolved, because the scan roots
    below are built from that variable. The functions read `$script:RepoRoot` and
    `$script:ScanRoot` at call time and create, write, or delete no file.
#>

# Exactly three scan roots, anchored at the resolved repository root. A repo-wide
# recursive glob is deliberately NOT used: the bundled mirror under
# `extensions/drm-copilot/resources/claude-customizations/.claude/**` is a
# byte-identical second copy of these files and must stay out of scope, because
# allowlist keys are repo-root-relative paths.
$script:ScanRoot = @(
    (Join-Path -Path $script:RepoRoot -ChildPath '.claude/hooks'),
    (Join-Path -Path $script:RepoRoot -ChildPath '.claude/lib'),
    (Join-Path -Path $script:RepoRoot -ChildPath '.codex/hooks')
)

<#
.SYNOPSIS
    Enumerates every `*.ps1` and `*.psm1` beneath the three scan roots, excluding
    `.claude/lib/bash/**` (shell, not PowerShell). Each result carries the
    absolute path and the repo-root-relative label used by the allowlist.
#>
function Get-GuardedPowerShellFile {
    [CmdletBinding()]
    [OutputType([object[]])]
    param()

    $results = [System.Collections.Generic.List[object]]::new()
    foreach ($root in $script:ScanRoot) {
        if (-not (Test-Path -Path $root)) {
            continue
        }
        $files = Get-ChildItem -Path $root -Recurse -File |
            Where-Object { $_.Extension -in @('.ps1', '.psm1') }
        foreach ($file in $files) {
            $relative = $file.FullName.Substring($script:RepoRoot.Length).TrimStart('\', '/')
            $relative = $relative -replace '\\', '/'
            # `.claude/lib/bash/**` holds shell scripts, not PowerShell.
            if ($relative -like '.claude/lib/bash/*') {
                continue
            }
            $results.Add([pscustomobject]@{
                    FullName = $file.FullName
                    Relative = $relative
                })
        }
    }
    return , $results.ToArray()
}

<#
.SYNOPSIS
    True when a repository-relative path lies beneath a configured scan root and not
    beneath `extensions/` (the bundled mirror, which is out of scan scope).
#>
function Test-GuardedPathUnderScanRoot {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [string] $RelativePath
    )

    $normalized = $RelativePath -replace '\\', '/'
    if ($normalized -like 'extensions/*') {
        return $false
    }
    foreach ($root in $script:ScanRoot) {
        $rootRelative = $root.Substring($script:RepoRoot.Length).TrimStart('\', '/') -replace '\\', '/'
        if ($normalized -like "$rootRelative/*") {
            return $true
        }
    }
    return $false
}
