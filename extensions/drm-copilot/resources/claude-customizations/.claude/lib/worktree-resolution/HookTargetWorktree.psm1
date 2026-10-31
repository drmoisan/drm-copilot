<#
.SYNOPSIS
    Pure target-worktree resolver for PreToolUse hooks (issue #1009).

.DESCRIPTION
    Resolves the registered git worktree that a hook call acts on, from the first present
    source in a strict order: (1) file-tool target paths, (2) command operand paths or a
    branch the caller has already parsed, (3) the identity carried by an Agent delegation
    prompt, and (4) the session root as the final fallback. Registered worktrees come only
    from `git worktree list --porcelain` text returned by the injectable
    WorktreeListInvoker seam, and a path resolves to its nearest enclosing registered
    worktree (the longest normalized root prefix). Paths are compared after forward-slash
    normalization with OrdinalIgnoreCase on every platform.

    Known limitation: an 8.3 short-name path, or a path reached through a junction, that
    differs textually from the long path git reports matches no registered worktree and
    falls back to the session root.

    The TARGET_WORKTREE_AMBIGUOUS and TARGET_WORKTREE_NOT_DERIVABLE literals are restated
    inside Resolve-HookTargetWorktree rather than read from WorktreeResolution.psm1,
    because this module imports nothing. A test pins both literals equal to the
    WorktreeResolution.psm1 accessors, following the precedent of
    validate-orchestrator-output-resolution.ps1.

.NOTES
    Compatible with PowerShell 7+. No module dependency, no file read, no environment
    read, and no clock read; the only process is the default WorktreeListInvoker body.
    Functions reference no module-scope state, so the Codex twin
    .codex/hooks/hook-target-worktree.ps1 carries byte-identical function text.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function ConvertTo-HookTargetWorktreeNormalizedPath {
    <#
    .SYNOPSIS
        Normalize a path to forward slashes with repeated and trailing slashes removed.
    .DESCRIPTION
        Backslashes become forward slashes, runs of slashes collapse to one, and a trailing
        slash is trimmed except from a bare root ('/' or a drive root such as 'C:/'). Blank
        input returns an empty string. Case is preserved; callers compare with
        OrdinalIgnoreCase.
    .PARAMETER Path
        The path to normalize.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowNull()] [AllowEmptyString()] [string] $Path
    )

    if ([string]::IsNullOrWhiteSpace($Path)) { return '' }
    $normalized = ($Path.Trim() -replace '\\', '/') -replace '/{2,}', '/'
    if ($normalized.Length -gt 1 -and $normalized.EndsWith('/') -and $normalized -notmatch '^[A-Za-z]:/$') {
        $normalized = $normalized.Substring(0, $normalized.Length - 1)
    }
    return $normalized
}

function Get-HookTargetWorktreeRelativePath {
    <#
    .SYNOPSIS
        Return a path relative to a worktree root, or $null when it lies outside the root.
    .DESCRIPTION
        Both values are normalized first. A path equal to the root returns an empty string;
        a path under the root returns its forward-slash remainder; any other path, or a
        blank value, returns $null.
    .PARAMETER Path
        The path to express relative to the root.
    .PARAMETER WorktreeRoot
        The worktree root.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowNull()] [AllowEmptyString()] [string] $Path,
        [AllowNull()] [AllowEmptyString()] [string] $WorktreeRoot
    )

    $normalizedPath = ConvertTo-HookTargetWorktreeNormalizedPath -Path $Path
    $normalizedRoot = ConvertTo-HookTargetWorktreeNormalizedPath -Path $WorktreeRoot
    if ([string]::IsNullOrEmpty($normalizedPath) -or [string]::IsNullOrEmpty($normalizedRoot)) { return $null }
    if ([string]::Equals($normalizedPath, $normalizedRoot, [System.StringComparison]::OrdinalIgnoreCase)) { return '' }
    $prefix = if ($normalizedRoot.EndsWith('/')) { $normalizedRoot } else { $normalizedRoot + '/' }
    if ($normalizedPath.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $normalizedPath.Substring($prefix.Length)
    }
    return $null
}

function Get-HookTargetWorktreeEnclosingRoot {
    <#
    .SYNOPSIS
        Return the nearest root that encloses a path, or $null when none does.
    .DESCRIPTION
        A root encloses a path when the normalized path equals the normalized root or
        starts with the root followed by a slash. When several roots enclose the path, the
        longest one wins, so a worktree nested inside another wins for paths under it.
    .PARAMETER Path
        The path to place.
    .PARAMETER Roots
        The candidate worktree roots.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowNull()] [AllowEmptyString()] [string] $Path,
        [AllowNull()] [AllowEmptyCollection()] [string[]] $Roots
    )

    $best = $null
    foreach ($root in @($Roots)) {
        $normalizedRoot = ConvertTo-HookTargetWorktreeNormalizedPath -Path $root
        if ([string]::IsNullOrEmpty($normalizedRoot)) { continue }
        $relative = Get-HookTargetWorktreeRelativePath -Path $Path -WorktreeRoot $normalizedRoot
        if ($null -ne $relative -and ($null -eq $best -or $normalizedRoot.Length -gt $best.Length)) { $best = $normalizedRoot }
    }
    return $best
}

function Get-HookTargetWorktreeKey {
    <#
    .SYNOPSIS
        Return the stable key '<sanitized leaf>-<8 hex>' that names a worktree root.
    .DESCRIPTION
        The hex part is the first four bytes of the SHA-256 of the normalized root with no
        trailing slash, and the leaf is reduced to file-name-safe characters. The algorithm
        equals the worktree-derived batch-budget session id, which prefixes 'worktree-'.
    .PARAMETER WorktreeRoot
        The worktree root to key.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)] [string] $WorktreeRoot
    )

    $normalizedRoot = (ConvertTo-HookTargetWorktreeNormalizedPath -Path $WorktreeRoot).TrimEnd('/')
    $leaf = $normalizedRoot.Substring($normalizedRoot.LastIndexOf('/') + 1) -replace '[^A-Za-z0-9._-]', '_'
    $hashBytes = [System.Security.Cryptography.SHA256]::HashData([System.Text.Encoding]::UTF8.GetBytes($normalizedRoot))
    $shortHash = -join (@($hashBytes[0..3]) | ForEach-Object { $_.ToString('x2') })
    return "$leaf-$shortHash"
}

function ConvertFrom-HookTargetWorktreePorcelain {
    <#
    .SYNOPSIS
        Parse `git worktree list --porcelain` text into worktree records.
    .DESCRIPTION
        Emits one record per non-bare stanza with Root (normalized), Branch (the short
        branch name, or $null when detached), Bare, and Prunable. A bare stanza is skipped.
        Blank lines separate stanzas, and CRLF line endings are tolerated.
    .PARAMETER Text
        The porcelain text.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowNull()] [AllowEmptyString()] [string] $Text
    )

    $records = [System.Collections.Generic.List[object]]::new()
    $stanza = $null
    foreach ($rawLine in @(([string] $Text -split "`r?`n") + '')) {
        $line = $rawLine.Trim()
        if ($line -eq '' -or $line.StartsWith('worktree ')) {
            if ($null -ne $stanza -and -not $stanza.Bare) {
                $records.Add([pscustomobject]@{ Root = $stanza.Root; Branch = $stanza.Branch; Bare = $false; Prunable = $stanza.Prunable })
            }
            $stanza = $null
            if ($line -ne '') {
                $stanza = @{ Root = (ConvertTo-HookTargetWorktreeNormalizedPath -Path $line.Substring(9)); Branch = $null; Bare = $false; Prunable = $false }
            }
            continue
        }
        if ($null -eq $stanza) { continue }
        if ($line -eq 'bare') {
            $stanza.Bare = $true
        } elseif ($line.StartsWith('branch ')) {
            $reference = $line.Substring(7).Trim()
            $stanza.Branch = if ($reference.StartsWith('refs/heads/')) { $reference.Substring(11) } else { $reference }
        } elseif ($line -eq 'detached') {
            $stanza.Branch = $null
        } elseif ($line -eq 'prunable' -or $line.StartsWith('prunable ')) {
            $stanza.Prunable = $true
        }
    }
    return $records.ToArray()
}

function Resolve-HookTargetWorktree {
    <#
    .SYNOPSIS
        Resolve the registered worktree that a hook call acts on.
    .DESCRIPTION
        The first present source decides, in the order FilePath, CommandOperand (paths
        and/or branch), DelegationIdentity, SessionRoot; a later source is never consulted.
        Relative paths map to the session root without enumerating worktrees. An absolute
        path maps to its nearest enclosing registered worktree, and a path inside none, or
        an invoker that throws or returns no worktree, falls back to the session root.
        Disagreeing components yield TARGET_WORKTREE_AMBIGUOUS; a present branch or
        identity that names no worktree yields TARGET_WORKTREE_NOT_DERIVABLE and never the
        session root. The result carries WorktreeRoot, Source, Ambiguous, ReasonCode,
        Detail, and Candidates. The invoker runs at most once.
    .PARAMETER SessionRoot
        The absolute session root (the hook's root); the fallback root.
    .PARAMETER FilePath
        File-tool target paths.
    .PARAMETER CommandOperandPath
        Command operand paths parsed by the caller.
    .PARAMETER CommandBranch
        A command branch operand parsed by the caller.
    .PARAMETER DelegationPrompt
        Agent delegation prompt text; its 'branch:' label and canonical issue line are read.
    .PARAMETER CheckpointIssueReader
        Optional { param($WorktreeRoot) <issue number or $null> } used only for an issue identity.
    .PARAMETER WorktreeListInvoker
        { param($SessionRoot) <porcelain text> }; the default runs git worktree list --porcelain.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)] [string] $SessionRoot,
        [AllowNull()] [AllowEmptyCollection()] [string[]] $FilePath,
        [AllowNull()] [AllowEmptyCollection()] [string[]] $CommandOperandPath,
        [AllowNull()] [AllowEmptyString()] [string] $CommandBranch,
        [AllowNull()] [AllowEmptyString()] [string] $DelegationPrompt,
        [scriptblock] $CheckpointIssueReader,
        [scriptblock] $WorktreeListInvoker = { param($SessionRoot) $porcelain = & git -C $SessionRoot worktree list --porcelain 2>$null; if ($LASTEXITCODE -ne 0) { return '' }; return ($porcelain -join "`n") }
    )

    $ambiguousCode = 'TARGET_WORKTREE_AMBIGUOUS'
    $notDerivableCode = 'TARGET_WORKTREE_NOT_DERIVABLE'
    $ignoreCase = [System.StringComparison]::OrdinalIgnoreCase
    $absolutePattern = '^(/|[A-Za-z]:/)'
    $session = ConvertTo-HookTargetWorktreeNormalizedPath -Path $SessionRoot

    # Nested helpers are called by constant name and read this function's variables.
    function Get-HookTargetResult {
        param($Root, [string] $Source, $Code, [string] $Detail = '', [string[]] $Candidates = @())
        [pscustomobject]@{
            WorktreeRoot = $Root
            Source       = $Source
            Ambiguous    = ($Code -eq $ambiguousCode)
            ReasonCode   = $Code
            Detail       = $Detail
            Candidates   = [string[]] @($Candidates)
        }
    }
    function Add-HookTargetDistinctValue {
        param([System.Collections.Generic.List[string]] $List, [string] $Value)
        foreach ($existing in $List) { if ([string]::Equals($existing, $Value, $ignoreCase)) { return } }
        $List.Add($Value)
    }
    function Get-HookTargetRecordedIssue {
        param([string] $Root)
        try { $value = ([string] (& $CheckpointIssueReader $Root)).Trim().TrimStart('#') } catch { return $null }
        if ($value -notmatch '^\d+$') { return $null }
        $digits = $value.TrimStart('0')
        return $(if ($digits -eq '') { '0' } else { $digits })
    }
    function Resolve-HookTargetPathSource {
        param([string[]] $Paths, [string] $Source)
        $resolved = [System.Collections.Generic.List[string]]::new()
        $details = [System.Collections.Generic.List[string]]::new()
        $fellBack = $false
        foreach ($candidate in $Paths) {
            $normalized = ConvertTo-HookTargetWorktreeNormalizedPath -Path $candidate
            $root = $session
            if ($normalized -notmatch $absolutePattern) {
                $fellBack = $true
                $details.Add("relative path '$normalized' maps to the session root")
            } else {
                $enclosing = Get-HookTargetWorktreeEnclosingRoot -Path $normalized -Roots $roots
                if ($null -eq $enclosing) {
                    $fellBack = $true
                    $details.Add($(if ($listDetail) { $listDetail } else { "path '$normalized' is inside no registered worktree" }))
                } else {
                    $root = $enclosing
                }
            }
            Add-HookTargetDistinctValue -List $resolved -Value $root
        }
        if ($resolved.Count -gt 1) {
            return (Get-HookTargetResult -Root $null -Source $Source -Code $ambiguousCode -Detail ('the paths resolve to {0} different worktrees' -f $resolved.Count) -Candidates $resolved.ToArray())
        }
        $decidedBy = if ($fellBack) { 'SessionRoot' } else { $Source }
        return (Get-HookTargetResult -Root $resolved[0] -Source $decidedBy -Code $null -Detail ($details -join '; '))
    }
    function Resolve-HookTargetBranchSource {
        param([string] $Branch, [string] $Source)
        $matched = @($records | Where-Object { $null -ne $_.Branch -and [string]::Equals($_.Branch, $Branch, $ignoreCase) } | ForEach-Object { $_.Root })
        if ($matched.Count -eq 0) { return (Get-HookTargetResult -Root $null -Source $Source -Code $notDerivableCode -Detail "branch '$Branch' is checked out in no registered worktree") }
        if ($matched.Count -gt 1) { return (Get-HookTargetResult -Root $null -Source $Source -Code $ambiguousCode -Detail "branch '$Branch' is checked out in $($matched.Count) registered worktrees" -Candidates $matched) }
        return (Get-HookTargetResult -Root $matched[0] -Source $Source -Code $null)
    }

    # Select the deciding source: the first present one in precedence order.
    $filePaths = @($FilePath | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    $operandPaths = @($CommandOperandPath | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    $branchOperand = if ([string]::IsNullOrWhiteSpace($CommandBranch)) { '' } else { $CommandBranch.Trim() }
    $branches = [System.Collections.Generic.List[string]]::new()
    $issues = [System.Collections.Generic.List[string]]::new()
    if ($filePaths.Count -gt 0) {
        $source = 'FilePath'
    } elseif ($operandPaths.Count -gt 0 -or $branchOperand) {
        $source = 'CommandOperand'
    } elseif (-not [string]::IsNullOrWhiteSpace($DelegationPrompt)) {
        $source = 'DelegationIdentity'
        foreach ($match in [regex]::Matches($DelegationPrompt, '(?i)\bbranch:\s*(?<name>[A-Za-z0-9][A-Za-z0-9._/-]*)')) {
            Add-HookTargetDistinctValue -List $branches -Value $match.Groups['name'].Value.TrimEnd('.', '/')
        }
        foreach ($match in [regex]::Matches($DelegationPrompt, 'Canonical issue number for this feature is #?(?<number>\d+)')) {
            $digits = $match.Groups['number'].Value.TrimStart('0')
            Add-HookTargetDistinctValue -List $issues -Value $(if ($digits -eq '') { '0' } else { $digits })
        }
    } else {
        return (Get-HookTargetResult -Root $session -Source 'SessionRoot' -Code $null -Detail 'no target source is present; the session root applies')
    }

    # Enumerate registered worktrees at most once, and only when the deciding source needs them.
    $needsList = switch ($source) {
        'FilePath' { @($filePaths | Where-Object { (ConvertTo-HookTargetWorktreeNormalizedPath -Path $_) -match $absolutePattern }).Count -gt 0 }
        'CommandOperand' { [bool] $branchOperand -or @($operandPaths | Where-Object { (ConvertTo-HookTargetWorktreeNormalizedPath -Path $_) -match $absolutePattern }).Count -gt 0 }
        default { ($branches.Count -eq 1 -and $issues.Count -le 1) -or ($branches.Count -eq 0 -and $issues.Count -eq 1 -and $null -ne $CheckpointIssueReader) }
    }
    $records = @()
    $listDetail = ''
    if ($needsList) {
        try {
            $records = @(ConvertFrom-HookTargetWorktreePorcelain -Text (@(& $WorktreeListInvoker $SessionRoot) -join "`n"))
            if ($records.Count -eq 0) { $listDetail = 'the worktree list returned no registered worktree' }
        } catch {
            $records = @()
            $listDetail = "the worktree list failed: $($_.Exception.Message)"
        }
    }
    $roots = @($records | ForEach-Object { $_.Root })

    if ($source -eq 'FilePath') { return (Resolve-HookTargetPathSource -Paths $filePaths -Source 'FilePath') }

    if ($source -eq 'CommandOperand') {
        $pathResult = if ($operandPaths.Count -gt 0) { Resolve-HookTargetPathSource -Paths $operandPaths -Source 'CommandOperand' } else { $null }
        if (-not $branchOperand) { return $pathResult }
        $branchResult = Resolve-HookTargetBranchSource -Branch $branchOperand -Source 'CommandOperand'
        if ($null -eq $pathResult) { return $branchResult }
        if ($pathResult.Ambiguous) { return $pathResult }
        if ($null -ne $branchResult.ReasonCode) { return $branchResult }
        if (-not [string]::Equals($pathResult.WorktreeRoot, $branchResult.WorktreeRoot, $ignoreCase)) {
            return (Get-HookTargetResult -Root $null -Source 'CommandOperand' -Code $ambiguousCode -Detail "the operand paths and branch '$branchOperand' resolve to different worktrees" -Candidates @($pathResult.WorktreeRoot, $branchResult.WorktreeRoot))
        }
        return $branchResult
    }

    if ($branches.Count -gt 1) { return (Get-HookTargetResult -Root $null -Source $source -Code $ambiguousCode -Detail ('the prompt names {0} different branches: {1}' -f $branches.Count, ($branches -join ', '))) }
    if ($issues.Count -gt 1) { return (Get-HookTargetResult -Root $null -Source $source -Code $ambiguousCode -Detail ('the prompt names {0} different issue numbers: {1}' -f $issues.Count, ($issues -join ', '))) }
    if ($branches.Count -eq 1) {
        $branchResult = Resolve-HookTargetBranchSource -Branch $branches[0] -Source $source
        if ($null -ne $branchResult.ReasonCode -or $issues.Count -eq 0 -or $null -eq $CheckpointIssueReader) { return $branchResult }
        $target = $branchResult.WorktreeRoot
        $recorded = Get-HookTargetRecordedIssue -Root $target
        if ($null -ne $recorded) {
            if ($recorded -eq $issues[0]) { return $branchResult }
            return (Get-HookTargetResult -Root $null -Source $source -Code $ambiguousCode -Detail "branch '$($branches[0])' places the call in a worktree whose checkpoint records issue $recorded, not issue $($issues[0])" -Candidates @($target))
        }
        $elsewhere = @($records | Where-Object { -not [string]::Equals($_.Root, $target, $ignoreCase) -and (Get-HookTargetRecordedIssue -Root $_.Root) -eq $issues[0] } | ForEach-Object { $_.Root })
        if ($elsewhere.Count -gt 0) {
            return (Get-HookTargetResult -Root $null -Source $source -Code $ambiguousCode -Detail "branch '$($branches[0])' and issue $($issues[0]) place the call in different worktrees" -Candidates (@($target) + $elsewhere))
        }
        return $branchResult
    }
    if ($issues.Count -eq 1) {
        if ($null -eq $CheckpointIssueReader) { return (Get-HookTargetResult -Root $null -Source $source -Code $notDerivableCode -Detail "issue $($issues[0]) cannot be placed without a checkpoint issue reader") }
        $matched = @($records | Where-Object { (Get-HookTargetRecordedIssue -Root $_.Root) -eq $issues[0] } | ForEach-Object { $_.Root })
        if ($matched.Count -eq 0) { return (Get-HookTargetResult -Root $null -Source $source -Code $notDerivableCode -Detail "issue $($issues[0]) is recorded by no registered worktree") }
        if ($matched.Count -gt 1) { return (Get-HookTargetResult -Root $null -Source $source -Code $ambiguousCode -Detail "issue $($issues[0]) is recorded by $($matched.Count) registered worktrees" -Candidates $matched) }
        return (Get-HookTargetResult -Root $matched[0] -Source $source -Code $null)
    }
    return (Get-HookTargetResult -Root $null -Source $source -Code $notDerivableCode -Detail 'the prompt carries no branch: label and no canonical issue line')
}

Export-ModuleMember -Function `
    Resolve-HookTargetWorktree, `
    ConvertFrom-HookTargetWorktreePorcelain, `
    Get-HookTargetWorktreeEnclosingRoot, `
    ConvertTo-HookTargetWorktreeNormalizedPath, `
    Get-HookTargetWorktreeRelativePath, `
    Get-HookTargetWorktreeKey
