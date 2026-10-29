<#
.SYNOPSIS
    Pure functions of the tiered file-size policy (500 guidance, 700 advisory, 800 hard limit).

.DESCRIPTION
    Single source of truth for the repository file-size policy (issue #990). The
    policy has three tiers: at 500 logical lines an author looks for a logical split,
    at 700 lines an author splits more aggressively and reviewers report a
    non-blocking Warning, and above 800 lines a split is enforced regardless of
    logical separability. A file of exactly 800 lines passes.

    Lines are counted as logical lines: the content is split on CRLF or LF, and a
    trailing line terminator does not add a line. CRLF and LF content of the same
    text therefore count identically, and the count equals the number of strings
    Get-Content returns for the same file.

    Covered files are identified by an extension allowlist; every other file
    (Markdown, JSON, YAML, TOML, text fixtures) is outside the policy. Paths under
    fixed build, cache, dependency, documentation, and virtual-environment
    directory names, and paths under .claude/worktrees/, are not covered. The excluded
    directory names are defined once, in Get-FileSizeExcludedSegment.

    Every function is pure: no filesystem, process, network, environment, or clock
    access. Callers supply the content, the paths, and the recorded sizes. The
    policy constants live inside the functions rather than at module scope, so the
    function definitions are self-contained and can be mirrored text-identically
    into the dot-sourced Codex twin .codex/hooks/file-size-policy.ps1.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-FileSizePolicyLimit {
    <#
    .SYNOPSIS
        Return the three tier limits of the file-size policy.
    .OUTPUTS
        A PSCustomObject with Guidance (500), Advisory (700), and HardLimit (800).
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param()

    return [pscustomobject]@{
        Guidance  = 500
        Advisory  = 700
        HardLimit = 800
    }
}

function Get-FileSizeExcludedSegment {
    <#
    .SYNOPSIS
        Return the directory names excluded from the file-size policy.
    .DESCRIPTION
        A path with any of these names as a directory segment is not covered. This
        function is the single source of the excluded names: Test-FileSizeCoveredPath
        and the repository gate traversal both read it. Each call returns a new array.
    .OUTPUTS
        System.String[].
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param()

    return [string[]]@('.git', 'node_modules', 'artifacts', 'coverage', 'dist', 'out', 'virtual', 'docs',
        'build', '.venv', 'venv', 'env', '__pycache__', '.pytest_cache', '.mypy_cache', '.ruff_cache', '.tox',
        '.nox', 'htmlcov', '.vscode-test')
}

function Get-FileSizeLogicalLineCount {
    <#
    .SYNOPSIS
        Count the logical lines of a text.
    .DESCRIPTION
        Splits the content on CRLF or LF. A trailing line terminator does not add a
        line, and empty or null content has zero lines.
    .PARAMETER Content
        The file content.
    .OUTPUTS
        System.Int32.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory)]
        [AllowNull()]
        [AllowEmptyString()]
        [string] $Content
    )

    if ([string]::IsNullOrEmpty($Content)) {
        return 0
    }

    $count = [regex]::Split($Content, '\r?\n').Count
    if ($Content.EndsWith("`n")) {
        # The split yields one empty trailing element after a final terminator.
        $count--
    }
    return $count
}

function Get-FileSizeTier {
    <#
    .SYNOPSIS
        Classify a logical line count into a policy tier.
    .DESCRIPTION
        Returns 'Below' (under 500), 'Guidance' (500 through 699), 'Advisory' (700
        through 799), or 'HardLimit' (800 and above). The hard block applies only
        above 800; a count of exactly 800 is in the HardLimit tier and still passes.
    .PARAMETER LineCount
        A non-negative logical line count.
    .OUTPUTS
        System.String.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [int] $LineCount
    )

    if ($LineCount -lt 0) {
        throw "Get-FileSizeTier: LineCount must be non-negative; received $LineCount."
    }

    $limit = Get-FileSizePolicyLimit
    if ($LineCount -ge $limit.HardLimit) { return 'HardLimit' }
    if ($LineCount -ge $limit.Advisory) { return 'Advisory' }
    if ($LineCount -ge $limit.Guidance) { return 'Guidance' }
    return 'Below'
}

function ConvertTo-FileSizeRelativePath {
    <#
    .SYNOPSIS
        Convert a file path to a repository-relative forward-slash path.
    .DESCRIPTION
        Backslashes are normalized to forward slashes. A relative path is returned
        without a leading './'. An absolute path under the repository root is
        returned relative to the root (compared case-insensitively, because the
        root may come from a case-insensitive file system). A path outside the root,
        a relative path that climbs above the root, and the root itself return
        $null, which callers treat as not covered.
    .PARAMETER Path
        The file path from a tool payload or a discovery.
    .PARAMETER RepositoryRoot
        The repository root directory.
    .OUTPUTS
        System.String, or $null for a path outside the repository root.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [AllowNull()]
        [AllowEmptyString()]
        [string] $Path,

        [Parameter(Mandatory)]
        [string] $RepositoryRoot
    )

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $null
    }

    $normalized = $Path.Replace('\', '/')
    $isRooted = $normalized.StartsWith('/') -or ($normalized -match '^[A-Za-z]:/')
    if (-not $isRooted) {
        while ($normalized.StartsWith('./')) {
            $normalized = $normalized.Substring(2)
        }
        if ($normalized -eq '..' -or $normalized.StartsWith('../') -or $normalized.Length -eq 0) {
            return $null
        }
        return $normalized
    }

    $root = $RepositoryRoot.Replace('\', '/').TrimEnd('/')
    $prefix = $root + '/'
    if (-not $normalized.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $null
    }

    $relative = $normalized.Substring($prefix.Length)
    if ($relative.Length -eq 0) {
        return $null
    }
    return $relative
}

function Test-FileSizeCoveredPath {
    <#
    .SYNOPSIS
        Report whether a repository-relative path is covered by the file-size policy.
    .DESCRIPTION
        A path is covered when its extension (case-insensitive) is in the allowlist
        (py, ps1, psm1, ts, tsx, js, cjs, mjs, cs, sh, and bats), no directory segment
        is an excluded name, and it is not under the worktrees folder of .claude.
        Excluded directory names are matched exactly. Null or empty input is not covered.
    .PARAMETER RelativePath
        A repository-relative path, for example from ConvertTo-FileSizeRelativePath.
    .OUTPUTS
        System.Boolean.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [AllowNull()]
        [AllowEmptyString()]
        [string] $RelativePath
    )

    if ([string]::IsNullOrWhiteSpace($RelativePath)) {
        return $false
    }

    $allowedExtension = @('.py', '.ps1', '.psm1', '.ts', '.tsx', '.js', '.cjs', '.mjs', '.cs', '.sh', '.bats')
    $excludedSegment = @(Get-FileSizeExcludedSegment)

    $normalized = $RelativePath.Replace('\', '/')
    if ($normalized.StartsWith('.claude/worktrees/')) {
        return $false
    }

    $segment = @($normalized.Split('/'))
    for ($index = 0; $index -lt ($segment.Count - 1); $index++) {
        if ($excludedSegment -ccontains $segment[$index]) {
            return $false
        }
    }

    $extension = [System.IO.Path]::GetExtension($segment[-1]).ToLowerInvariant()
    return ($allowedExtension -contains $extension)
}

function Compare-FileSizeBaselineEntry {
    <#
    .SYNOPSIS
        Compare one file's current size with its baseline entry under the strict ratchet.
    .DESCRIPTION
        Rows (S is the current size, B the recorded size):
          S <= 800, no entry       -> pass
          S <= 800, entry          -> 'stale-entry' (remove the entry)
          S > 800, no entry        -> 'new-over-limit'
          S > 800, entry, S > B    -> 'grew'
          S > 800, entry, S == B   -> pass
          S > 800, entry, S < B    -> 'tighten' (tighten the entry to S)
          no file, entry           -> 'missing-file' (stale entry for a deleted or renamed file)
          no file, no entry        -> pass
    .PARAMETER Path
        The repository-relative path, used in the violation message.
    .PARAMETER CurrentSize
        The current logical line count, or $null when no file exists on disk.
    .PARAMETER BaselineSize
        The recorded size, or $null when the baseline has no entry.
    .OUTPUTS
        $null on pass; otherwise a PSCustomObject with Path, Rule, and Message.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [string] $Path,

        [AllowNull()]
        [Nullable[int]] $CurrentSize,

        [AllowNull()]
        [Nullable[int]] $BaselineSize
    )

    $hardLimit = (Get-FileSizePolicyLimit).HardLimit
    $rule = $null
    $message = $null

    if ($null -eq $CurrentSize) {
        if ($null -ne $BaselineSize) {
            $rule = 'missing-file'
            $message = "stale baseline entry: '$Path' has no file on disk (deleted or renamed); remove the entry or move it with its recorded size unchanged."
        }
    } elseif ($CurrentSize -le $hardLimit) {
        if ($null -ne $BaselineSize) {
            $rule = 'stale-entry'
            $message = "stale baseline entry: '$Path' has $CurrentSize lines, at or below the $hardLimit-line hard limit; remove the entry."
        }
    } elseif ($null -eq $BaselineSize) {
        $rule = 'new-over-limit'
        $message = "new file over the hard limit: '$Path' has $CurrentSize lines, above the $hardLimit-line hard limit; split the file."
    } elseif ($CurrentSize -gt $BaselineSize) {
        $rule = 'grew'
        $message = "baselined file grew: '$Path' has $CurrentSize lines, above its recorded $BaselineSize; a baselined file may not grow."
    } elseif ($CurrentSize -lt $BaselineSize) {
        $rule = 'tighten'
        $message = "baselined file shrank: '$Path' has $CurrentSize lines, below its recorded $BaselineSize; tighten the entry to $CurrentSize."
    }

    if ($null -eq $rule) {
        return $null
    }
    return [pscustomobject]@{ Path = $Path; Rule = $rule; Message = $message }
}

function Resolve-FileSizeEditContent {
    <#
    .SYNOPSIS
        Apply an Edit-tool old_string to new_string replacement to pre-edit content in memory.
    .DESCRIPTION
        Follows the replacement approach of Resolve-EditedCheckpointContent in
        .claude/hooks/enforce-completion-consistency.ps1: CRLF is normalized to LF in
        all three strings, matching is ordinal (no regular expression, so '$' in the
        new text stays literal), one occurrence is replaced unless ReplaceAll is true,
        and a second match after the first is ambiguous. Failure is 'no-old-string'
        (absent or empty old string), 'not-found', or 'ambiguous'.
    .PARAMETER Content
        The pre-edit file content.
    .PARAMETER OldString
        The text to replace.
    .PARAMETER NewString
        The replacement text; null is treated as empty.
    .PARAMETER ReplaceAll
        Replace every occurrence instead of exactly one.
    .OUTPUTS
        A PSCustomObject with Content (the edited text, or $null on failure) and
        Failure (a failure code, or $null on success).
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [AllowNull()]
        [AllowEmptyString()]
        [string] $Content,

        [Parameter(Mandatory)]
        [AllowNull()]
        [AllowEmptyString()]
        [string] $OldString,

        [AllowNull()]
        [AllowEmptyString()]
        [string] $NewString = '',

        [bool] $ReplaceAll = $false
    )

    if ([string]::IsNullOrEmpty($OldString)) {
        return [pscustomobject]@{ Content = $null; Failure = 'no-old-string' }
    }

    $text = ([string]$Content).Replace("`r`n", "`n")
    $old = $OldString.Replace("`r`n", "`n")
    $new = ([string]$NewString).Replace("`r`n", "`n")

    $first = $text.IndexOf($old, [System.StringComparison]::Ordinal)
    if ($first -lt 0) {
        return [pscustomobject]@{ Content = $null; Failure = 'not-found' }
    }
    if ($ReplaceAll) {
        return [pscustomobject]@{ Content = $text.Replace($old, $new); Failure = $null }
    }

    $second = $text.IndexOf($old, $first + $old.Length, [System.StringComparison]::Ordinal)
    if ($second -ge 0) {
        return [pscustomobject]@{ Content = $null; Failure = 'ambiguous' }
    }

    $edited = $text.Substring(0, $first) + $new + $text.Substring($first + $old.Length)
    return [pscustomobject]@{ Content = $edited; Failure = $null }
}

function Get-FileSizeHookDecision {
    <#
    .SYNOPSIS
        Decide whether a Write or Edit may leave a file at its resulting size.
    .DESCRIPTION
        Baseline-free pre-edit-size ratchet. A path that is not covered is allowed.
        A covered result of at most 800 lines is allowed. A covered result above 800
        lines is allowed only when the file already existed and the result is not
        larger than its pre-edit size, so an already-large file may shrink or stay
        the same size but may not grow; every other case is denied. The deny reason
        starts with 'FILE_SIZE_LIMIT_BLOCKED:' and names the path, the resulting
        count, the three tiers, and the split requirement.
    .PARAMETER RelativePath
        The repository-relative path; $null or empty (outside the repository) is not covered.
    .PARAMETER ResultLineCount
        The logical line count the file would have after the operation.
    .PARAMETER PreEditLineCount
        The logical line count before the operation, or $null for a new file.
    .OUTPUTS
        A PSCustomObject with Allowed (bool) and Reason ($null when allowed).
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [AllowNull()]
        [AllowEmptyString()]
        [string] $RelativePath,

        [Parameter(Mandatory)]
        [int] $ResultLineCount,

        [AllowNull()]
        [Nullable[int]] $PreEditLineCount
    )

    $limit = Get-FileSizePolicyLimit
    $isAllowed = (-not (Test-FileSizeCoveredPath -RelativePath $RelativePath)) -or
    ($ResultLineCount -le $limit.HardLimit) -or
    (($null -ne $PreEditLineCount) -and ($ResultLineCount -le $PreEditLineCount))
    if ($isAllowed) {
        return [pscustomobject]@{ Allowed = $true; Reason = $null }
    }

    $growth = ''
    if ($null -ne $PreEditLineCount) {
        $growth = " It has $PreEditLineCount lines now; a file already above the hard limit may shrink or stay the same size but may not grow."
    }
    $reason = "FILE_SIZE_LIMIT_BLOCKED: '$RelativePath' would have $ResultLineCount logical lines, above the " +
    "$($limit.HardLimit)-line hard limit.$growth File-size policy tiers: $($limit.Guidance) lines is guidance " +
    "(look for a logical split), $($limit.Advisory) lines is advisory (split more aggressively; reviewers report " +
    "a non-blocking Warning), and above $($limit.HardLimit) lines a split is enforced regardless of logical " +
    "separability. Split the file into smaller files so each stays at or below $($limit.HardLimit) lines."
    return [pscustomobject]@{ Allowed = $false; Reason = $reason }
}

Export-ModuleMember -Function Get-FileSizePolicyLimit, Get-FileSizeLogicalLineCount, Get-FileSizeTier,
Get-FileSizeExcludedSegment, ConvertTo-FileSizeRelativePath, Test-FileSizeCoveredPath, Compare-FileSizeBaselineEntry,
Resolve-FileSizeEditContent, Get-FileSizeHookDecision
