<#
.SYNOPSIS
    Cleanup-context allow legs of the preimplementation gate (issue #1026).

.DESCRIPTION
    Dot-sourced by enforce-orchestration-preimplementation-gate.ps1 on the Claude and the Codex
    surface. The gate calls Test-OrchestrationCleanupContextAllowed only where it would otherwise
    return its final PREIMPLEMENTATION_GATE_BLOCKED deny, after the epic-scope decision, the
    delegation-mode branch, and the unresolved-target and ambiguous-resolution denies, so every
    existing deny path, ordering, and wording is unchanged when no leg applies. Four legs:

      Manifest Write      - the session-root spelling of
                            artifacts/orchestration/cleanup-worktrees-manifest.json (the relative
                            literal or its join with the session root), with content that passes
                            Test-CleanupManifestText. An Edit carries no content and is denied.
                            With -AllowPatchManifest (Codex only) a patch whose single marker is
                            '*** Add File:' naming the manifest is admitted on its '+' lines.
      Scratch Write/Edit  - an absolute local path under a temporary root, outside every
                            registered worktree and the session root (Test-CleanupScratchPath).
      Consolidation Write - an absolute path inside the consolidation worktree (porcelain branch
                            documentationandmemories) whose relative remainder is allowlisted,
                            including the pr-author receipt artifacts/pr_body_<digits>.receipt.json.
      Consolidation git   - every chained segment is git -C <absolute root> add or commit, every
                            target is the consolidation root; add takes only '--' and allowlisted
                            operands; commit takes only -m, --message, -F, --file, and --trailer
                            with values, no pathspec, and a non-empty, entirely allowlisted staged
                            index read through Get-OrchestrationGateStagedIndex.

    Pure prefilters run before any process: the manifest leg compares the path literal; the
    scratch leg requires an absolute local path under a temporary root; the consolidation Write
    leg requires a /docs/, /.claude/agent-memory/, or receipt tail; the command leg requires
    every segment to be the git -C add or commit shape. Only then is the listing seam
    Get-OrchestrationGateWorktreeList called, and the staged-index seam only after every target
    matches the consolidation root. Test-OrchestrationCleanupContextAllowed never throws: any
    error answers $false, which keeps the gate's deny.

.NOTES
    PowerShell 7+. Byte-identical at .claude/hooks, .codex/hooks, and both bundle mirrors.
    Call-time dependencies loaded by each gate: Get-OrchestrationGateWorktreeList (epic-scope
    sibling), ConvertFrom-HookTargetWorktreePorcelain, Get-HookTargetWorktreeEnclosingRoot, and
    Get-HookTargetWorktreeRelativePath (HookTargetWorktree.psm1 on Claude, hook-target-worktree.ps1
    on Codex), Get-OrchestrationCommandTarget and $script:OrchestrationTargetNonLocalPattern
    (targets file), and Split-OrchestrationCommandLine, Test-OrchestrationCommandTextUnresolvable,
    and ConvertTo-OrchestrationCommandToken (helpers file).
#>

try { . (Join-Path $PSScriptRoot 'hook-cleanup-context.ps1') } catch { Add-HookDependencyFailure -Name 'hook-cleanup-context.ps1' -ErrorRecord $_ }
try { . (Join-Path $PSScriptRoot 'hook-docs-only-diff.ps1') } catch { Add-HookDependencyFailure -Name 'hook-docs-only-diff.ps1' -ErrorRecord $_ }

function Get-OrchestrationGateTemporaryRoot {
    <#
    .SYNOPSIS
        Return every accepted spelling of the operating-system temporary root (test seam).
    .DESCRIPTION
        The distinct non-empty values of [System.IO.Path]::GetTempPath(), TEMP, TMP, and TMPDIR.
        GetTempPath() supplies the long-name spelling on Windows, while the TEMP value the
        runtime hands to the Write tool can carry the 8.3 short-name spelling, so both are
        accepted. Tests mock this function.
    .OUTPUTS
        System.String[]
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param()

    $values = [System.Collections.Generic.List[string]]::new()
    foreach ($value in @([System.IO.Path]::GetTempPath(), $env:TEMP, $env:TMP, $env:TMPDIR)) {
        if (-not [string]::IsNullOrWhiteSpace($value) -and $values -cnotcontains $value) {
            $values.Add($value)
        }
    }
    return [string[]]$values.ToArray()
}

function Get-OrchestrationGateStagedIndex {
    <#
    .SYNOPSIS
        Read the staged paths of a worktree as NUL-terminated names (test seam).
    .DESCRIPTION
        Runs git diff --cached --name-only -z --no-renames --no-color --no-ext-diff --no-relative
        in the worktree through the bounded Invoke-DocsOnlyGitExe seam, which never throws and
        reports ExitCode -1 for a root that is not a directory. Tests mock this function.
    .PARAMETER WorktreeRoot
        The consolidation worktree root.
    .OUTPUTS
        System.Management.Automation.PSCustomObject with ExitCode and Output.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory)][string] $WorktreeRoot)

    return (Invoke-DocsOnlyGitExe -WorktreeRoot $WorktreeRoot -GitArgs @('diff', '--cached', '--name-only', '-z', '--no-renames', '--no-color', '--no-ext-diff', '--no-relative'))
}

function Get-OrchestrationCleanupListingRecord {
    <#
    .SYNOPSIS
        Return the porcelain records of the session root's worktree listing, or an empty array.
    .OUTPUTS
        System.Object[]
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([Parameter(Mandatory)][string] $SessionRoot)

    $text = [string](Get-OrchestrationGateWorktreeList -SessionRoot $SessionRoot)
    return @(ConvertFrom-HookTargetWorktreePorcelain -Text $text)
}

function ConvertTo-OrchestrationCleanupComparablePath {
    <#
    .SYNOPSIS
        Normalize separators and upper-case a leading drive letter, so only the drive letter
        is compared without case.
    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([AllowNull()][AllowEmptyString()][string] $Path)

    $normalized = ConvertTo-CleanupContextPath -Path $Path
    if ($normalized -match '^[A-Za-z]:') {
        $normalized = $normalized.Substring(0, 1).ToUpperInvariant() + $normalized.Substring(1)
    }
    return $normalized
}

function Test-OrchestrationCleanupManifestPath {
    <#
    .SYNOPSIS
        Return $true when a path is the session-root spelling of the cleanup manifest.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()][AllowEmptyString()][string] $Path, [Parameter(Mandatory)][string] $SessionRoot)

    $relative = $script:CleanupContextManifestRelativePath
    $candidate = ConvertTo-OrchestrationCleanupComparablePath -Path $Path
    if ($candidate -ceq $relative) {
        return $true
    }
    $root = ConvertTo-OrchestrationCleanupComparablePath -Path $SessionRoot
    $joined = if ($root.EndsWith('/')) { $root + $relative } else { $root + '/' + $relative }
    return ($candidate -ceq $joined)
}

function Get-OrchestrationCleanupPatchManifestContent {
    <#
    .SYNOPSIS
        Return the added text of a patch whose single marker adds the manifest, or $null.
    .DESCRIPTION
        The first non-empty line must be '*** Begin Patch' and the patch must carry exactly one
        file marker, an '*** Add File:' naming the manifest. The content is the '+' lines that
        follow the marker, with the '+' removed, up to the next '***' line.
    .OUTPUTS
        System.String or $null
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][AllowEmptyString()][string] $PatchText, [Parameter(Mandatory)][string] $SessionRoot)

    $markers = @(Get-OrchestrationPatchMarkerPath -PatchText $PatchText)
    $lines = @($PatchText -split "`r?`n")
    $markerLines = @($lines | Where-Object { $_ -cmatch '^\*\*\* (Add File|Update File|Delete File|Move to):' })
    if ($markers.Count -ne 1 -or $markerLines.Count -ne 1 -or -not $markerLines[0].StartsWith('*** Add File:', [System.StringComparison]::Ordinal)) {
        return $null
    }
    if (-not (Test-OrchestrationCleanupManifestPath -Path $markers[0] -SessionRoot $SessionRoot)) {
        return $null
    }
    $added = [System.Collections.Generic.List[string]]::new()
    $inside = $false
    foreach ($line in $lines) {
        if ($line.StartsWith('*** Add File:', [System.StringComparison]::Ordinal)) { $inside = $true; continue }
        if (-not $inside) { continue }
        if ($line.StartsWith('***', [System.StringComparison]::Ordinal)) { break }
        if (-not $line.StartsWith('+', [System.StringComparison]::Ordinal)) { return $null }
        $added.Add($line.Substring(1))
    }
    return ($added -join "`n")
}

function Test-OrchestrationCleanupScratchWrite {
    <#
    .SYNOPSIS
        Scratch leg: an absolute local path under a temporary root and outside every worktree.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory)][string] $FilePath, [Parameter(Mandatory)][string] $SessionRoot)

    if ($FilePath -match $script:OrchestrationTargetNonLocalPattern) {
        return $false
    }
    $normalized = ConvertTo-CleanupContextPath -Path $FilePath
    if ($normalized -notmatch '^([A-Za-z]:/|/(?!/))') {
        return $false
    }
    $temporary = @(Get-OrchestrationGateTemporaryRoot)
    if (@($temporary | Where-Object { Test-CleanupContextPathUnder -Path $normalized -Root $_ }).Count -eq 0) {
        return $false
    }
    $records = @(Get-OrchestrationCleanupListingRecord -SessionRoot $SessionRoot)
    if ($records.Count -eq 0) {
        return $false
    }
    $roots = [string[]]@($records | ForEach-Object { [string]$_.Root })
    if ($null -ne (Get-HookTargetWorktreeEnclosingRoot -Path $normalized -Roots $roots)) {
        return $false
    }
    return (Test-CleanupScratchPath -Path $FilePath -RegisteredRoot $roots -SessionRoot $SessionRoot -TemporaryRoot $temporary)
}

function Test-OrchestrationCleanupConsolidationWrite {
    <#
    .SYNOPSIS
        Consolidation Write/Edit leg: an allowlisted path inside the consolidation worktree.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory)][string] $FilePath, [Parameter(Mandatory)][string] $SessionRoot)

    if ($FilePath -match $script:OrchestrationTargetNonLocalPattern) {
        return $false
    }
    $normalized = ConvertTo-CleanupContextPath -Path $FilePath
    if ($normalized -notmatch '^([A-Za-z]:/|/(?!/))' -or $normalized -cnotmatch '/docs/|/\.claude/agent-memory/|/artifacts/pr_body_[0-9]+\.receipt\.json$') {
        return $false
    }
    $records = @(Get-OrchestrationCleanupListingRecord -SessionRoot $SessionRoot)
    $record = Find-CleanupConsolidationRecord -Record $records
    if ($null -eq $record) {
        return $false
    }
    $enclosing = Get-HookTargetWorktreeEnclosingRoot -Path $normalized -Roots ([string[]]@($records | ForEach-Object { [string]$_.Root }))
    if (-not [string]::Equals([string]$enclosing, [string]$record.Root, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $false
    }
    $relative = Get-HookTargetWorktreeRelativePath -Path $normalized -WorktreeRoot $record.Root
    return (Test-CleanupConsolidationRelativePath -RelativePath $relative -AllowReceipt)
}

function Test-OrchestrationCleanupSegmentShape {
    <#
    .SYNOPSIS
        Return the subcommand of a git -C <absolute> add|commit segment whose options the leg
        admits, or $null.
    .DESCRIPTION
        add admits only '--' and at least one allowlisted operand. commit admits only -m,
        --message, -F, --file, and --trailer, each with a separate value or an '=' value, and no
        pathspec.
    .OUTPUTS
        System.String or $null
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][AllowEmptyCollection()][AllowEmptyString()][string[]] $Token)

    if ($Token.Count -lt 4 -or $Token[0] -cne 'git' -or $Token[1] -cne '-C' -or $Token[2] -notmatch '^([A-Za-z]:/|/(?!/))') {
        return $null
    }
    $subcommand = $Token[3]
    $rest = if ($Token.Count -gt 4) { @($Token[4..($Token.Count - 1)]) } else { @() }
    if ($subcommand -ceq 'add') {
        $operands = @($rest | Where-Object { $_ -cne '--' })
        if (($rest.Count - $operands.Count) -gt 1 -or $operands.Count -eq 0) {
            return $null
        }
        foreach ($operand in $operands) {
            if ($operand.StartsWith('-') -or -not (Test-CleanupConsolidationRelativePath -RelativePath $operand)) {
                return $null
            }
        }
        return 'add'
    }
    if ($subcommand -cne 'commit') {
        return $null
    }
    $valueOptions = @('-m', '--message', '-F', '--file', '--trailer')
    for ($index = 0; $index -lt $rest.Count; $index++) {
        $item = $rest[$index]
        if ($valueOptions -ccontains $item) {
            $index++
            if ($index -ge $rest.Count) {
                return $null
            }
            continue
        }
        $name = if ($item.IndexOf('=') -gt 0) { $item.Substring(0, $item.IndexOf('=')) } else { '' }
        if (@('--message', '--file', '--trailer') -ccontains $name) {
            continue
        }
        return $null
    }
    return 'commit'
}

function Test-OrchestrationCleanupConsolidationCommand {
    <#
    .SYNOPSIS
        Consolidation git leg: every segment stages or commits allowlisted paths in the
        consolidation worktree.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory)][string] $Command, [Parameter(Mandatory)][string] $SessionRoot)

    if (Test-OrchestrationCommandTextUnresolvable -CommandText $Command) {
        return $false
    }
    $split = Split-OrchestrationCommandLine -CommandText $Command
    $segments = @($split.Segments)
    if (-not $split.Balanced -or $segments.Count -eq 0) {
        return $false
    }
    $commitRoots = [System.Collections.Generic.List[string]]::new()
    foreach ($segment in $segments) {
        $tokens = [string[]]@(ConvertTo-OrchestrationCommandToken -Segment $segment)
        $shape = Test-OrchestrationCleanupSegmentShape -Token $tokens
        if ($null -eq $shape) {
            return $false
        }
        if ($shape -ceq 'commit') {
            $commitRoots.Add($tokens[2])
        }
    }

    $target = Get-OrchestrationCommandTarget -Command $Command -SessionRoot $SessionRoot
    if (-not $target.Resolved -or @($target.Targets).Count -eq 0) {
        return $false
    }
    $record = Find-CleanupConsolidationRecord -Record @(Get-OrchestrationCleanupListingRecord -SessionRoot $SessionRoot)
    if ($null -eq $record) {
        return $false
    }
    $consolidationRoot = ConvertTo-OrchestrationCleanupComparablePath -Path $record.Root
    foreach ($candidate in @($target.Targets)) {
        if (-not [string]::Equals((ConvertTo-OrchestrationCleanupComparablePath -Path $candidate), $consolidationRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
            return $false
        }
    }
    if ($commitRoots.Count -gt 0) {
        $staged = Get-OrchestrationGateStagedIndex -WorktreeRoot $record.Root
        $text = [string]$staged.Output
        if ($null -eq $staged -or $staged.ExitCode -ne 0 -or $text.Length -eq 0 -or -not $text.EndsWith([char]0)) {
            return $false
        }
        $paths = @(ConvertFrom-DocsOnlyNameList -Text $text)
        if ($paths.Count -eq 0) {
            return $false
        }
        foreach ($path in $paths) {
            if (-not (Test-CleanupConsolidationRelativePath -RelativePath $path)) {
                return $false
            }
        }
    }
    return $true
}

function Test-OrchestrationCleanupContextAllowed {
    <#
    .SYNOPSIS
        Return $true when a call that the gate would deny is a sanctioned cleanup operation.
    .DESCRIPTION
        Composes the manifest, scratch, consolidation Write/Edit, and consolidation git legs of
        the file header. Never throws: any error answers $false.
    .PARAMETER FilePath
        The Write or Edit file path; empty for a command.
    .PARAMETER Content
        The Write content; empty for an Edit.
    .PARAMETER Command
        The Bash command, or the Codex apply_patch text; empty for a path leg.
    .PARAMETER AllowPatchManifest
        Admit a Codex apply_patch that adds the manifest (Codex gate only).
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()][AllowEmptyString()][string] $FilePath,
        [AllowNull()][AllowEmptyString()][string] $Content,
        [AllowNull()][AllowEmptyString()][string] $Command,
        [switch] $AllowPatchManifest
    )

    try {
        $sessionRoot = (Get-Location).Path
        if ($FilePath) {
            if (Test-OrchestrationCleanupManifestPath -Path $FilePath -SessionRoot $sessionRoot) {
                return (Test-CleanupManifestText -Raw $Content)
            }
            if (Test-OrchestrationCleanupScratchWrite -FilePath $FilePath -SessionRoot $sessionRoot) {
                return $true
            }
            return (Test-OrchestrationCleanupConsolidationWrite -FilePath $FilePath -SessionRoot $sessionRoot)
        }
        if (-not $Command) {
            return $false
        }
        if ($AllowPatchManifest -and $Command.TrimStart().StartsWith('*** Begin Patch', [System.StringComparison]::Ordinal)) {
            $patchContent = Get-OrchestrationCleanupPatchManifestContent -PatchText $Command -SessionRoot $sessionRoot
            return ($null -ne $patchContent -and (Test-CleanupManifestText -Raw $patchContent))
        }
        return (Test-OrchestrationCleanupConsolidationCommand -Command $Command -SessionRoot $sessionRoot)
    }
    catch {
        Write-Debug "PREIMPL_CLEANUP_LEG_ERROR: $($_.Exception.Message)"
        return $false
    }
}
