<#
.SYNOPSIS
    Docs-only diff classification and the merge-side docs-only exemption (issue #927).

.DESCRIPTION
    Shared by enforce-pr-author-skill.docs-only.ps1 (create side) and by the Claude and Codex
    copies of enforce-epic-merge-gate.ps1 (merge side). The file defines functions only: it
    imports nothing, dot-sources nothing, and has no entry point. At call time
    Get-DocsOnlyMergeExemption uses Read-CommandLineSegment, Test-CommandLineSegmentRawScan,
    Get-CommandLineStructuralMatch, Test-CommandLineFlag, and Get-CommandLineFlagValue from
    the command parsers every consumer already loads.

    Docs-only merge branch: a merge gate calls Get-DocsOnlyMergeExemption only for an explicit
    pull request number that no checkpoint records. The exemption fails closed; conditions
    are evaluated in order and the first failure returns its code:

      M1 DOCS_ONLY_EXEMPTION_PR_UNRESOLVED   - a positive number; exactly one segment that is
                                               not wrapper-led, has no live substitution, and
                                               is balanced; a structural gh pr merge; no inline
                                               VAR= prefix token (GH_REPO=, GH_HOST=); no
                                               single-dash token containing R; no --repo or
                                               --repo= token; no --auto token.
      M2 DOCS_ONLY_EXEMPTION_PR_UNRESOLVED   - the worktree root is an existing directory.
      M3 DOCS_ONLY_EXEMPTION_PR_UNRESOLVED   - gh pr view <N> --json baseRefName,headRefOid
                                               exits 0 and returns a JSON object; headRefOid
                                               is 40 or 64 lowercase hex; a --match-head-commit
                                               value, when present, equals headRefOid (OD-2).
         DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED - baseRefName is a conservative branch spelling
                                               without '..'.
      M4 DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED - refs/remotes/origin/<base> resolves to a commit.
      M5 DOCS_ONLY_EXEMPTION_DIFF_FAILED     - headRefOid is present in the local repository.
      M6 DOCS_ONLY_EXEMPTION_DIFF_FAILED     - git diff --name-only -z --no-renames --no-color
                                               --no-ext-diff --no-relative <base>...<head>
                                               exits 0.
      M7 DOCS_ONLY_EXEMPTION_DIFF_FAILED     - non-empty diff output ends with NUL.
      M8 DOCS_ONLY_EXEMPTION_EMPTY_DIFF      - the diff lists at least one path.
      M9 DOCS_ONLY_EXEMPTION_NON_DOCS_PATH   - every listed path starts with docs/ (ordinal).

    No-fetch policy: no function here fetches or writes a ref. A missing origin/<base> ref or
    a head commit that is not present locally denies, and the M5 reason names the command
    the operator can run before retrying.

    Residual limits: a GH_REPO or GH_HOST value exported by an earlier shell command or
    inherited from the session environment is not visible in the command text; a push
    between the gh pr view lookup and the merge can change the head, which only
    --match-head-commit closes; the control is policy-level, not cryptographic.

.NOTES
    PowerShell 7+. Byte-identical at .claude/hooks, .codex/hooks, and both bundle mirrors.
    git and gh run only through Invoke-DocsOnlyGitExe and Invoke-DocsOnlyGhExe, which never
    throw; unit tests pass the name of a test-local function through -GitCommand and
    -GhCommand so the seam bodies run without starting a process.
#>

function ConvertFrom-DocsOnlyNameList {
    <#
    .SYNOPSIS
        Split NUL-separated git output into paths, discarding empty elements.
    .DESCRIPTION
        Callers wrap the result in @() so that an empty listing is an empty array. A path that
        contains a line feed stays one element, because only NUL separates entries.
    .PARAMETER Text
        The captured git output.
    .OUTPUTS
        System.String, one per path
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowNull()][AllowEmptyString()][string] $Text
    )

    if ([string]::IsNullOrEmpty($Text)) {
        return
    }
    foreach ($entry in $Text.Split([char]0)) {
        if ($entry.Length -gt 0) {
            $entry
        }
    }
}

function Get-DocsOnlyPathViolation {
    <#
    .SYNOPSIS
        Return $null when every path is under docs/, else the denial sub-code text.
    .DESCRIPTION
        An empty set returns DOCS_ONLY_EXEMPTION_EMPTY_DIFF. Otherwise the first path that does
        not start with docs/ under ordinal comparison, or that is not longer than docs/ itself,
        returns DOCS_ONLY_EXEMPTION_NON_DOCS_PATH naming that path.
    .PARAMETER Path
        The changed paths, repository-relative, as git reports them.
    .OUTPUTS
        System.String or $null
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowNull()][AllowEmptyCollection()][string[]] $Path
    )

    $paths = @($Path | Where-Object { $null -ne $_ })
    if ($paths.Count -eq 0) {
        return 'DOCS_ONLY_EXEMPTION_EMPTY_DIFF: the branch diff lists no path.'
    }
    foreach ($entry in $paths) {
        if ($entry.Length -le 5 -or -not $entry.StartsWith('docs/', [System.StringComparison]::Ordinal)) {
            return "DOCS_ONLY_EXEMPTION_NON_DOCS_PATH: '$entry' is outside docs/."
        }
    }
    return $null
}

function Get-DocsOnlyDiffTextViolation {
    <#
    .SYNOPSIS
        Return $null when NUL-terminated diff output lists only docs/ paths, else the sub-code text.
    .DESCRIPTION
        Pure. Non-empty text that does not end with NUL returns DOCS_ONLY_EXEMPTION_DIFF_FAILED,
        because entries could otherwise run together into one path that starts with docs/.
        Otherwise the text is split on NUL and classified by Get-DocsOnlyPathViolation, so empty
        text reaches DOCS_ONLY_EXEMPTION_EMPTY_DIFF.
    .PARAMETER DiffText
        The captured output of git diff --name-only -z.
    .PARAMETER BaseName
        The base branch named in the denial text.
    .OUTPUTS
        System.String or $null
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowNull()][AllowEmptyString()][string] $DiffText,
        [AllowNull()][AllowEmptyString()][string] $BaseName
    )

    $text = [string]$DiffText
    if ($text.Length -gt 0 -and -not $text.EndsWith([char]0)) {
        return "DOCS_ONLY_EXEMPTION_DIFF_FAILED: git diff against origin/$BaseName did not return NUL-terminated output."
    }
    return (Get-DocsOnlyPathViolation -Path @(ConvertFrom-DocsOnlyNameList -Text $text))
}

function Invoke-DocsOnlyGitExe {
    <#
    .SYNOPSIS
        Run <GitCommand> -C <root> with the given arguments; the git seam of the merge exemption.
    .DESCRIPTION
        Never throws. A root that is not an existing directory returns ExitCode -1 without
        running the command, and so does a command that cannot start. Standard error is
        discarded so that it is never read as path data. Output lines are joined with a line
        feed.
    .PARAMETER WorktreeRoot
        The directory git runs in.
    .PARAMETER GitArgs
        The git arguments that follow -C <root>.
    .PARAMETER GitCommand
        The command to run; git unless a unit test passes the name of a test-local function.
    .OUTPUTS
        System.Management.Automation.PSCustomObject with ExitCode and Output.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowNull()][AllowEmptyString()][string] $WorktreeRoot,
        [Parameter(Mandatory)][string[]] $GitArgs,
        [ValidateNotNullOrEmpty()][string] $GitCommand = 'git'
    )

    $failure = [pscustomobject]@{ ExitCode = -1; Output = '' }
    if ([string]::IsNullOrWhiteSpace($WorktreeRoot) -or -not (Test-Path -LiteralPath $WorktreeRoot -PathType Container)) {
        return $failure
    }
    try {
        $lines = @(& $GitCommand -C $WorktreeRoot @GitArgs 2>$null)
        $code = $LASTEXITCODE
    }
    catch {
        return $failure
    }
    return [pscustomobject]@{ ExitCode = [int]$code; Output = ($lines -join "`n") }
}

function Invoke-DocsOnlyGhExe {
    <#
    .SYNOPSIS
        Run <GhCommand> with the given arguments inside a working root; the gh seam.
    .DESCRIPTION
        Never throws. gh has no -C option, so the seam pushes the working root and pops it in
        finally, restoring the caller's location after success and after a throw. A root that
        is not an existing directory returns ExitCode -1 without running the command.
        Standard error is discarded. Output lines are joined with a line feed.
    .PARAMETER WorkingRoot
        The directory gh runs in.
    .PARAMETER GhArgs
        The gh arguments.
    .PARAMETER GhCommand
        The command to run; gh unless a unit test passes the name of a test-local function.
    .OUTPUTS
        System.Management.Automation.PSCustomObject with ExitCode and Output.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowNull()][AllowEmptyString()][string] $WorkingRoot,
        [Parameter(Mandatory)][string[]] $GhArgs,
        [ValidateNotNullOrEmpty()][string] $GhCommand = 'gh'
    )

    $failure = [pscustomobject]@{ ExitCode = -1; Output = '' }
    if ([string]::IsNullOrWhiteSpace($WorkingRoot) -or -not (Test-Path -LiteralPath $WorkingRoot -PathType Container)) {
        return $failure
    }
    try {
        Push-Location -LiteralPath $WorkingRoot -ErrorAction Stop
    }
    catch {
        return $failure
    }
    try {
        $lines = @(& $GhCommand @GhArgs 2>$null)
        $code = $LASTEXITCODE
    }
    catch {
        return $failure
    }
    finally {
        Pop-Location
    }
    return [pscustomobject]@{ ExitCode = [int]$code; Output = ($lines -join "`n") }
}

function Get-DocsOnlyMergeShapeViolation {
    <#
    .SYNOPSIS
        Return $null when the merge command has the M1 shape, else the denial text.
    .DESCRIPTION
        Pure; runs before any process. See M1 in the file header.
    .PARAMETER CommandText
        The Bash command text under evaluation.
    .PARAMETER PrNumber
        The explicit pull request number the gate read, or $null.
    .OUTPUTS
        System.String or $null
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowNull()][AllowEmptyString()][string] $CommandText,
        [AllowNull()][Nullable[int]] $PrNumber
    )

    $prefix = 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED: '
    if ($null -eq $PrNumber -or $PrNumber -le 0) {
        return $prefix + 'the command names no positive pull request number.'
    }
    $segments = @(Read-CommandLineSegment -CommandText $CommandText)
    if ($segments.Count -ne 1 -or (Test-CommandLineSegmentRawScan -Segment $segments[0])) {
        return $prefix + 'the command must be one gh pr merge segment with no chain, wrapper, or substitution.'
    }
    if ($null -eq (Get-CommandLineStructuralMatch -CommandText $CommandText -CommandWord 'gh' -SubcommandPath @('pr', 'merge'))) {
        return $prefix + 'the command is not a structural gh pr merge.'
    }
    foreach ($token in @($segments[0].Tokens)) {
        $text = [string]$token
        if ($text -cmatch '^[A-Za-z_][A-Za-z0-9_]*=') {
            return $prefix + "the inline environment prefix '$text' is not accepted."
        }
        if ($text.Length -ge 2 -and $text[0] -eq '-' -and $text[1] -ne '-' -and $text.Substring(1).Contains('R')) {
            return $prefix + "the repository override '$text' is not accepted."
        }
        if ($text -eq '--repo' -or $text.StartsWith('--repo=', [System.StringComparison]::OrdinalIgnoreCase)) {
            return $prefix + "the repository override '$text' is not accepted."
        }
        if ($text -eq '--auto' -or $text.StartsWith('--auto=', [System.StringComparison]::OrdinalIgnoreCase)) {
            return $prefix + 'auto-merge (--auto) is not eligible.'
        }
    }
    return $null
}

function Get-DocsOnlyPullRequestTarget {
    <#
    .SYNOPSIS
        Read the base branch and head commit of a pull request through the gh seam (M3).
    .DESCRIPTION
        Returns an object with Reason, Base, and Head. Reason is $null when the lookup
        succeeded and every M3 check passed; otherwise it carries the denial text.
    .PARAMETER CommandText
        The Bash command text, read for an optional --match-head-commit value.
    .PARAMETER PrNumber
        The pull request number.
    .PARAMETER WorktreeRoot
        The directory gh runs in.
    .OUTPUTS
        System.Management.Automation.PSCustomObject with Reason, Base, and Head.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowNull()][AllowEmptyString()][string] $CommandText,
        [Parameter(Mandatory)][int] $PrNumber,
        [Parameter(Mandatory)][string] $WorktreeRoot
    )

    $unresolved = 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED: '
    $lookup = Invoke-DocsOnlyGhExe -WorkingRoot $WorktreeRoot -GhArgs @('pr', 'view', [string]$PrNumber, '--json', 'baseRefName,headRefOid')
    $pr = $null
    if ($null -ne $lookup -and $lookup.ExitCode -eq 0) {
        try {
            $pr = ConvertFrom-Json -InputObject ([string]$lookup.Output) -ErrorAction Stop
        }
        catch {
            $pr = $null
        }
    }
    if ($pr -isnot [System.Management.Automation.PSCustomObject]) {
        return [pscustomobject]@{ Reason = $unresolved + "gh pr view $PrNumber did not return a readable pull request."; Base = $null; Head = $null }
    }
    $base = [string]$pr.baseRefName
    if ($base -cnotmatch '^[A-Za-z0-9][A-Za-z0-9._/-]*$' -or $base.Contains('..')) {
        return [pscustomobject]@{ Reason = "DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED: the base branch '$base' of pull request $PrNumber is not a conservative branch name."; Base = $null; Head = $null }
    }
    $head = [string]$pr.headRefOid
    if ($head -cnotmatch '^[0-9a-f]{40}([0-9a-f]{24})?$') {
        return [pscustomobject]@{ Reason = $unresolved + "the head commit of pull request $PrNumber is not a full lowercase object id."; Base = $null; Head = $null }
    }
    $subcommandPath = @('pr', 'merge')
    if (Test-CommandLineFlag -CommandText $CommandText -CommandWord 'gh' -SubcommandPath $subcommandPath -FlagName '--match-head-commit') {
        $pinned = Get-CommandLineFlagValue -CommandText $CommandText -CommandWord 'gh' -SubcommandPath $subcommandPath -FlagName '--match-head-commit'
        if (-not [string]::Equals($pinned, $head, [System.StringComparison]::Ordinal)) {
            return [pscustomobject]@{ Reason = $unresolved + "--match-head-commit does not equal the head commit $head of pull request $PrNumber."; Base = $null; Head = $null }
        }
    }
    return [pscustomobject]@{ Reason = $null; Base = $base; Head = $head }
}

function Get-DocsOnlyMergeExemption {
    <#
    .SYNOPSIS
        Decide whether gh pr merge <N> --merge is exempt because the pull request changes only docs/.
    .DESCRIPTION
        Evaluates M1 to M9 of the file header in order and returns at the first failure. M1
        and M2 run before any process. Every seam failure denies.
    .PARAMETER CommandText
        The Bash command text under evaluation.
    .PARAMETER PrNumber
        The explicit pull request number the gate read from the command, or $null.
    .PARAMETER WorktreeRoot
        The directory gh and git run in.
    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary with Exempt and Reason.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [AllowNull()][AllowEmptyString()][string] $CommandText,
        [AllowNull()][Nullable[int]] $PrNumber,
        [AllowNull()][AllowEmptyString()][string] $WorktreeRoot
    )

    $shape = Get-DocsOnlyMergeShapeViolation -CommandText $CommandText -PrNumber $PrNumber
    if ($shape) {
        return [ordered]@{ Exempt = $false; Reason = $shape }
    }
    if ([string]::IsNullOrWhiteSpace($WorktreeRoot) -or -not (Test-Path -LiteralPath $WorktreeRoot -PathType Container)) {
        return [ordered]@{ Exempt = $false; Reason = 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED: the worktree root for the lookup is not an existing directory.' }
    }
    $target = Get-DocsOnlyPullRequestTarget -CommandText $CommandText -PrNumber ([int]$PrNumber) -WorktreeRoot $WorktreeRoot
    if ($target.Reason) {
        return [ordered]@{ Exempt = $false; Reason = $target.Reason }
    }
    $base = $target.Base
    $head = $target.Head

    $baseRev = Invoke-DocsOnlyGitExe -WorktreeRoot $WorktreeRoot -GitArgs @('rev-parse', '--verify', '--quiet', ('refs/remotes/origin/' + $base + '^{commit}'))
    $baseCommit = if ($null -ne $baseRev) { ([string]$baseRev.Output).Trim() } else { '' }
    if ($null -eq $baseRev -or $baseRev.ExitCode -ne 0 -or $baseCommit -cnotmatch '^[0-9a-f]{40}([0-9a-f]{24})?$') {
        return [ordered]@{ Exempt = $false; Reason = "DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED: refs/remotes/origin/$base does not resolve to a commit in the worktree." }
    }

    $headRev = Invoke-DocsOnlyGitExe -WorktreeRoot $WorktreeRoot -GitArgs @('rev-parse', '--verify', '--quiet', ($head + '^{commit}'))
    $headCommit = if ($null -ne $headRev) { ([string]$headRev.Output).Trim() } else { '' }
    if ($null -eq $headRev -or $headRev.ExitCode -ne 0 -or -not [string]::Equals($headCommit, $head, [System.StringComparison]::Ordinal)) {
        return [ordered]@{ Exempt = $false; Reason = "DOCS_ONLY_EXEMPTION_DIFF_FAILED: the head commit $head of pull request $PrNumber is not present locally; run git fetch origin pull/$PrNumber/head, then retry. This hook does not fetch." }
    }

    $diff = Invoke-DocsOnlyGitExe -WorktreeRoot $WorktreeRoot -GitArgs @('diff', '--name-only', '-z', '--no-renames', '--no-color', '--no-ext-diff', '--no-relative', ($baseCommit + '...' + $head))
    if ($null -eq $diff -or $diff.ExitCode -ne 0) {
        return [ordered]@{ Exempt = $false; Reason = "DOCS_ONLY_EXEMPTION_DIFF_FAILED: git diff against origin/$base could not be computed." }
    }
    $violation = Get-DocsOnlyDiffTextViolation -DiffText ([string]$diff.Output) -BaseName $base
    if ($violation) {
        return [ordered]@{ Exempt = $false; Reason = $violation }
    }
    return [ordered]@{ Exempt = $true; Reason = $null }
}
