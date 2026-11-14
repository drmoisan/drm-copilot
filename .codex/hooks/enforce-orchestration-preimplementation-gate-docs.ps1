<#
.SYNOPSIS
    Docs-estate allow leg of the preimplementation gate (issue #1169).

.DESCRIPTION
    Dot-sourced by enforce-orchestration-preimplementation-gate.ps1 on the Claude and the Codex
    surface. The gate calls Get-OrchestrationDocsEstateContextResult only where it would otherwise
    return its final PREIMPLEMENTATION_GATE_BLOCKED deny, after the cleanup leg has declined, and
    appends the DenySuffix after the cleanup suffix. The leg lets a checkpoint-free documentation
    run (/documentation-workflow) stage and commit docs path set changes and write its pr-author
    receipt. It never throws: any error answers Allowed $false with an empty DenySuffix.

    Prefilters (pure, before any I/O):
      Command - every Split-OrchestrationCommandLine segment is git [-C <absolute root>] add --
                <operand>... or git [-C <absolute root>] commit with only -m, --message, -F,
                --file, or --trailer and no pathspec. Any other segment, such as a chained
                pytest, ruff, black, pyright, npm, npx, or Invoke-Pester, declines.
      Write   - the path is artifacts/pr_body_<digits>.receipt.json, relative or absolute.

    Conditions, in order (the first failure declines):
      D1 the call resolves to one worktree root R that the session listing registers
         (Get-OrchestrationCommandTarget for a command, the enclosing listing root for an absolute
         Write path, the session root for a relative one), and no orchestration checkpoint
         exists beneath R (Test-OrchestrationDocsEstateCheckpointPresent);
      D2 the docs profile beneath R exists and is structurally valid;
      D3 every git add operand is in the docs path set (Test-DocsEstatePath);
      D4 for a commit, the staged index beneath R (Get-OrchestrationGateStagedIndex) is readable,
         NUL-terminated, non-empty, and entirely in the docs path set.
    The receipt Write needs D1 and D2 only.

    DenySuffix is empty unless R resolved and a profile file exists beneath it; it is then
    ' Docs-estate leg not applied: <SUB_CODE>: <detail>' with one of DOCS_LEG_PROFILE_INVALID,
    DOCS_LEG_PATH_NOT_ALLOWED, DOCS_LEG_STAGED_INDEX_UNREADABLE, DOCS_LEG_STAGED_INDEX_EMPTY, or
    DOCS_LEG_STAGED_PATH_NOT_ALLOWED. Without a profile file every deny text is unchanged.

.NOTES
    PowerShell 7+. Byte-identical at .claude/hooks, .codex/hooks, and both bundle mirrors. A
    policy-level control, not a security boundary. Call-time dependencies loaded by each gate:
    Split-OrchestrationCommandLine, Test-OrchestrationCommandTextUnresolvable, and
    ConvertTo-OrchestrationCommandToken (helpers file); Get-OrchestrationCommandTarget and
    $script:OrchestrationTargetNonLocalPattern (targets file); Get-OrchestrationGateStagedIndex
    and Get-OrchestrationCleanupListingRecord (cleanup sibling); ConvertTo-CleanupContextPath and
    Test-CleanupConsolidationRelativePath (hook-cleanup-context.ps1); and
    Get-HookTargetWorktreeEnclosingRoot and Get-HookTargetWorktreeRelativePath
    (HookTargetWorktree.psm1 on Claude, hook-target-worktree.ps1 on Codex); and
    Get-WorktreeResolutionGitFileText, which reads the docs profile and answers $null when the
    file is absent or unreadable (WorktreeResolution.psm1 on Claude,
    enforce-orchestration-preimplementation-gate-epic-resolution.ps1 on Codex). An absent, empty,
    or unreadable profile declines with an empty DenySuffix.
#>

try { . (Join-Path $PSScriptRoot 'hook-docs-estate-context.ps1') } catch { Add-HookDependencyFailure -Name 'hook-docs-estate-context.ps1' -ErrorRecord $_ }
try { . (Join-Path $PSScriptRoot 'hook-docs-only-diff.ps1') } catch { Add-HookDependencyFailure -Name 'hook-docs-only-diff.ps1' -ErrorRecord $_ }

# Every orchestration checkpoint whose presence beneath R makes the docs leg decline.
$script:DocsEstateCheckpointPaths = @(
    'artifacts/orchestration/orchestrator-state.json'
    'artifacts/orchestration/parallel-planner-state.json'
    'artifacts/orchestration/parallel-orchestrator-state.json'
    'artifacts/orchestration/epic-planner-state.json'
    'artifacts/orchestration/epic-orchestrator-state.json'
    'artifacts/orchestration/powershell-orchestrator-state.json'
    'artifacts/orchestration/csharp-orchestrator-state.json'
)

function Test-OrchestrationDocsEstateCheckpointPresent {
    <#
    .SYNOPSIS
        Return $true when any orchestration checkpoint file exists beneath a worktree root (test seam).
    .PARAMETER WorktreeRoot
        The resolved root R.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory)][string] $WorktreeRoot)

    foreach ($relative in $script:DocsEstateCheckpointPaths) {
        if (Test-Path -LiteralPath (Join-Path -Path $WorktreeRoot -ChildPath $relative) -PathType Leaf) {
            return $true
        }
    }
    return $false
}

function Get-OrchestrationDocsEstateSegmentShape {
    <#
    .SYNOPSIS
        Return @{ Kind; Operand } for a git [-C <absolute root>] add -- or commit segment the leg
        admits, or $null.
    .PARAMETER Token
        The segment tokens.
    .OUTPUTS
        System.Collections.Hashtable or $null
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory)][AllowEmptyCollection()][AllowEmptyString()][string[]] $Token)

    if ($Token.Count -lt 2 -or $Token[0] -cne 'git') {
        return $null
    }
    $index = 1
    if ($Token[1] -ceq '-C') {
        if ($Token.Count -lt 4 -or $Token[2] -notmatch '^([A-Za-z]:/|/(?!/))') {
            return $null
        }
        $index = 3
    }
    $subcommand = $Token[$index]
    $rest = @(if ($Token.Count -gt $index + 1) { $Token[($index + 1)..($Token.Count - 1)] })
    if ($subcommand -ceq 'add') {
        if ($rest.Count -lt 2 -or $rest[0] -cne '--') {
            return $null
        }
        $operands = @($rest[1..($rest.Count - 1)])
        if (@($operands | Where-Object { $_ -ceq '--' }).Count -gt 0) {
            return $null
        }
        return @{ Kind = 'add'; Operand = [string[]]$operands }
    }
    if ($subcommand -cne 'commit') {
        return $null
    }
    for ($position = 0; $position -lt $rest.Count; $position++) {
        $item = $rest[$position]
        if (@('-m', '--message', '-F', '--file', '--trailer') -ccontains $item) {
            $position++
            if ($position -ge $rest.Count) {
                return $null
            }
            continue
        }
        $name = if ($item.IndexOf('=') -gt 0) { $item.Substring(0, $item.IndexOf('=')) } else { '' }
        if (@('--message', '--file', '--trailer') -cnotcontains $name) {
            return $null
        }
    }
    return @{ Kind = 'commit'; Operand = [string[]]@() }
}

function Get-OrchestrationDocsEstateCommandShape {
    <#
    .SYNOPSIS
        Return the admitted segment shapes of a command, or $null when any segment is outside the
        add or commit shape (pure prefilter).
    .PARAMETER Command
        The Bash command text.
    .OUTPUTS
        System.Object[] of hashtables, or $null.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([Parameter(Mandatory)][string] $Command)

    if (Test-OrchestrationCommandTextUnresolvable -CommandText $Command) {
        return $null
    }
    $split = Split-OrchestrationCommandLine -CommandText $Command
    $segments = @($split.Segments)
    if (-not $split.Balanced -or $segments.Count -eq 0) {
        return $null
    }
    $shapes = [System.Collections.Generic.List[object]]::new()
    foreach ($segment in $segments) {
        $shape = Get-OrchestrationDocsEstateSegmentShape -Token ([string[]]@(ConvertTo-OrchestrationCommandToken -Segment $segment))
        if ($null -eq $shape) {
            return $null
        }
        $shapes.Add($shape)
    }
    return , $shapes.ToArray()
}

function Get-OrchestrationDocsEstateRoot {
    <#
    .SYNOPSIS
        Return the registered worktree root R of a command or a receipt Write path, or $null.
    .DESCRIPTION
        A command resolves through Get-OrchestrationCommandTarget to exactly one target; a relative
        Write path resolves to the session root; an absolute Write path resolves to its enclosing
        listing root and must name artifacts/pr_body_<digits>.receipt.json beneath it. A target
        equal to the session root is R with no listing read; any other target must be a root of
        the session worktree listing.
    .OUTPUTS
        System.String or $null
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowNull()][AllowEmptyString()][string] $FilePath,
        [AllowNull()][AllowEmptyString()][string] $Command,
        [Parameter(Mandatory)][string] $SessionRoot
    )

    $session = (ConvertTo-CleanupContextPath -Path $SessionRoot).TrimEnd('/')
    $candidate = $null
    $normalized = ConvertTo-CleanupContextPath -Path $FilePath
    if ($FilePath -and $normalized -cmatch '^artifacts/pr_body_[0-9]+\.receipt\.json$') {
        return $SessionRoot
    }
    if (-not $FilePath) {
        $target = Get-OrchestrationCommandTarget -Command $Command -SessionRoot $SessionRoot
        if (-not $target.Resolved -or @($target.Targets).Count -ne 1) {
            return $null
        }
        $candidate = (ConvertTo-CleanupContextPath -Path ([string]@($target.Targets)[0])).TrimEnd('/')
        if ([string]::Equals($candidate, $session, [System.StringComparison]::OrdinalIgnoreCase)) {
            return $SessionRoot
        }
    }
    $records = @(Get-OrchestrationCleanupListingRecord -SessionRoot $SessionRoot)
    $roots = [string[]]@($records | ForEach-Object { [string]$_.Root })
    if ($roots.Count -eq 0) {
        return $null
    }
    if ($FilePath) {
        if ($normalized -notmatch '^([A-Za-z]:/|/(?!/))' -or $FilePath -match $script:OrchestrationTargetNonLocalPattern) {
            return $null
        }
        $enclosing = Get-HookTargetWorktreeEnclosingRoot -Path $normalized -Roots $roots
        if ($null -eq $enclosing -or (Get-HookTargetWorktreeRelativePath -Path $normalized -WorktreeRoot $enclosing) -cnotmatch '^artifacts/pr_body_[0-9]+\.receipt\.json$') {
            return $null
        }
        $candidate = [string]$enclosing
    }
    if ([string]::IsNullOrEmpty($candidate)) {
        return $null
    }
    $comparable = (ConvertTo-CleanupContextPath -Path $candidate).TrimEnd('/')
    foreach ($root in $roots) {
        if ([string]::Equals((ConvertTo-CleanupContextPath -Path $root).TrimEnd('/'), $comparable, [System.StringComparison]::OrdinalIgnoreCase)) {
            return $root
        }
    }
    return $null
}

function Get-OrchestrationDocsEstateStagedResult {
    <#
    .SYNOPSIS
        D4: check the staged index beneath R; return $null when it passes, else the deny suffix.
    .OUTPUTS
        System.String or $null
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][string] $WorktreeRoot, [Parameter(Mandatory)][hashtable] $ProfileDocument)

    $prefix = ' Docs-estate leg not applied: '
    $unreadable = "${prefix}DOCS_LEG_STAGED_INDEX_UNREADABLE: the staged index could not be read as NUL-terminated names."
    $empty = "${prefix}DOCS_LEG_STAGED_INDEX_EMPTY: the staged index lists no path."
    $staged = Get-OrchestrationGateStagedIndex -WorktreeRoot $WorktreeRoot
    if ($null -eq $staged -or $staged.ExitCode -ne 0) {
        return $unreadable
    }
    $text = [string]$staged.Output
    if ($text.Length -eq 0) {
        return $empty
    }
    if (-not $text.EndsWith([char]0)) {
        return $unreadable
    }
    $paths = @(ConvertFrom-DocsOnlyNameList -Text $text)
    if ($paths.Count -eq 0) {
        return $empty
    }
    foreach ($path in $paths) {
        if (-not (Test-DocsEstatePath -RelativePath $path -ProfileDocument $ProfileDocument -InitWorkflowPath $script:DocsOnlyInitWorkflowPath)) {
            return "${prefix}DOCS_LEG_STAGED_PATH_NOT_ALLOWED: the staged path '$path' is not in the docs path set."
        }
    }
    return $null
}

function Get-OrchestrationDocsEstateContextResult {
    <#
    .SYNOPSIS
        Decide whether a call that the gate would deny is a sanctioned docs-estate operation.
    .DESCRIPTION
        Applies the prefilters and D1 to D4 of the file header. Never throws: any error answers
        Allowed $false with an empty DenySuffix.
    .PARAMETER FilePath
        The Write or Edit file path; empty for a command.
    .PARAMETER Command
        The Bash command; empty for a path leg.
    .OUTPUTS
        System.Management.Automation.PSCustomObject with Allowed and DenySuffix.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowNull()][AllowEmptyString()][string] $FilePath,
        [AllowNull()][AllowEmptyString()][string] $Command
    )

    $denied = [pscustomobject]@{ Allowed = $false; DenySuffix = '' }
    try {
        $shapes = @()
        if ($FilePath) {
            if ((ConvertTo-CleanupContextPath -Path $FilePath) -cnotmatch '(^|/)artifacts/pr_body_[0-9]+\.receipt\.json$') {
                return $denied
            }
        }
        elseif ($Command) {
            $shapes = Get-OrchestrationDocsEstateCommandShape -Command $Command
            if ($null -eq $shapes) {
                return $denied
            }
        }
        else {
            return $denied
        }
        $root = Get-OrchestrationDocsEstateRoot -FilePath $FilePath -Command $Command -SessionRoot (Get-Location).Path
        if ($null -eq $root -or (Test-OrchestrationDocsEstateCheckpointPresent -WorktreeRoot $root)) {
            return $denied
        }
        $profileText = Get-WorktreeResolutionGitFileText -Path (Join-Path -Path $root -ChildPath $script:DocsEstateProfileRelativePath)
        if ([string]::IsNullOrEmpty($profileText)) {
            return $denied
        }
        $prefix = ' Docs-estate leg not applied: '
        $profileDocument = ConvertFrom-DocsEstateProfileText -Text $profileText
        if ($null -eq $profileDocument) {
            return [pscustomobject]@{ Allowed = $false; DenySuffix = "${prefix}DOCS_LEG_PROFILE_INVALID: $($script:DocsEstateProfileRelativePath) is not a structurally valid docs profile." }
        }
        foreach ($shape in $shapes) {
            foreach ($operand in @($shape.Operand)) {
                if (-not (Test-DocsEstatePath -RelativePath $operand -ProfileDocument $profileDocument -InitWorkflowPath $script:DocsOnlyInitWorkflowPath)) {
                    return [pscustomobject]@{ Allowed = $false; DenySuffix = "${prefix}DOCS_LEG_PATH_NOT_ALLOWED: '$operand' is not in the docs path set." }
                }
            }
        }
        if (@($shapes | Where-Object { $_.Kind -ceq 'commit' }).Count -gt 0) {
            $stagedSuffix = Get-OrchestrationDocsEstateStagedResult -WorktreeRoot $root -ProfileDocument $profileDocument
            if ($null -ne $stagedSuffix) {
                return [pscustomobject]@{ Allowed = $false; DenySuffix = $stagedSuffix }
            }
        }
        return [pscustomobject]@{ Allowed = $true; DenySuffix = '' }
    }
    catch {
        Write-Debug "PREIMPL_DOCS_LEG_ERROR: $($_.Exception.Message)"
        return $denied
    }
}
