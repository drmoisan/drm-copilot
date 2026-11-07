<#
.SYNOPSIS
    Review target and policy-audit selection for the Codex feature-review coverage hook (issue #1114).

.DESCRIPTION
    Dot-sourced by .codex/hooks/validate-feature-review-coverage.ps1 after hook-target-worktree.ps1.
    The hook judges the policy audit that the reviewer names in its final message
    (last_assistant_message), never the most recent audit in the checkout:

      - Get-CodexReviewPolicyAuditPath extracts the policy-audit paths from the message.
      - Select-CodexReviewPolicyAudit selects one audit from the repository-relative paths.
      - Resolve-CodexReviewCoverageTarget resolves the item root through Resolve-HookTargetWorktree
        (absolute paths) or the session root (relative paths) and requires the selected audit to
        exist beneath that root.
      - Invoke-CodexReviewCoverageGitLog and Get-CodexReviewCoverageWorktreeList are the git
        wrappers the hook passes as -GitInvoker and -WorktreeListInvoker; both call git only through
        Invoke-CodexReviewCoverageGitExe, which tests mock.

    Every blocking result carries a ReasonCode (AUDIT_NOT_NAMED, AUDIT_PATH_TRAVERSAL,
    AUDIT_AMBIGUOUS, TARGET_WORKTREE_AMBIGUOUS, or AUDIT_NOT_FOUND) and a Reason that names the
    condition. Functions-only: the file has no entry point, no dot-source, and no statement outside
    the function definitions.

.NOTES
    Compatible with PowerShell 7+. Invokes no Python and holds no script-scope state. Mirrored
    byte-identically under extensions/drm-copilot/resources/codex-and-agents-customizations/.
#>

function Invoke-CodexReviewCoverageGitExe {
    <#
    .SYNOPSIS
        Runs git with the given arguments and returns its exit code and output. Tests mock this seam.
    .PARAMETER GitArgs
        The git argument list.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)] [string[]] $GitArgs)

    $output = & git @GitArgs 2>$null; [pscustomobject]@{ ExitCode = $LASTEXITCODE; Output = (@($output) -join "`n") }
}

function Invoke-CodexReviewCoverageGitLog {
    <#
    .SYNOPSIS
        Returns the committer time of the newest HEAD commit in a root that touches the pathspecs.
    .DESCRIPTION
        Runs git -C <root> log -1 --format=%ct HEAD -- <pathspecs> through
        Invoke-CodexReviewCoverageGitExe and returns its ExitCode and Output unchanged, the shape of
        the -GitInvoker seam of Get-FeatureReviewCoverageFreshnessDecision. A throw propagates.
    .PARAMETER Root
        The worktree root to query.
    .PARAMETER Pathspec
        The git pathspecs of the language.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [string] $Root,
        [AllowEmptyCollection()] [string[]] $Pathspec = @()
    )

    $gitArgs = [string[]](@('-C', $Root, 'log', '-1', '--format=%ct', 'HEAD', '--') + @($Pathspec))
    $result = Invoke-CodexReviewCoverageGitExe -GitArgs $gitArgs
    return [pscustomobject]@{ ExitCode = $result.ExitCode; Output = $result.Output }
}

function Get-CodexReviewCoverageWorktreeList {
    <#
    .SYNOPSIS
        Returns the git worktree list --porcelain text of the session root, or an empty string.
    .DESCRIPTION
        A non-zero exit or a throw from Invoke-CodexReviewCoverageGitExe yields an empty string, which
        Resolve-HookTargetWorktree reads as no registered worktree.
    .PARAMETER SessionRoot
        The hook's session root.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [string] $SessionRoot)

    try {
        $result = Invoke-CodexReviewCoverageGitExe -GitArgs @('-C', $SessionRoot, 'worktree', 'list', '--porcelain')
    }
    catch {
        return ''
    }
    if ($result.ExitCode -ne 0) { return '' }
    return [string]$result.Output
}

function Get-CodexReviewPolicyAuditPath {
    <#
    .SYNOPSIS
        Extracts the distinct policy-audit paths named in the reviewer's final message.
    .DESCRIPTION
        Accepts docs/features/active/<folder>/[<version>/]policy-audit.<timestamp>.md and
        docs/features/active/<folder>/audit/<timestamp>/policy-audit.md, relative or absolute, with /
        or \ separators, with or without a policy-audit-path: label. Separators are returned as /.
        Candidates come from three sources, merged in first-seen order and de-duplicated: (1) the rest
        of a line after policy-audit-path: (trimmed, one pair of surrounding backticks or quotes
        removed, spaces kept); (2) the content of a single-line backtick, single-quote, or
        double-quote span that holds docs/features/active/ (spaces kept); (3) each whitespace-delimited
        token. Trailing . , : ; after .md are not part of a path. A candidate is examined only when it
        holds docs/features/active/ exactly once, so a source that spans two audit paths is skipped and
        the token scan extracts both. A '..' segment in an examined policy-audit candidate (final
        segment policy-audit.md or policy-audit.<timestamp>.md) is checked before the shape test and
        yields reason code AUDIT_PATH_TRAVERSAL; an examined candidate with any other final segment
        and a '..' segment fails the shape test and is skipped. A $null or non-string message yields no
        paths. Returns Paths, ReasonCode, and Reason.
    .PARAMETER Message
        The last_assistant_message value of the payload; any type.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([AllowNull()] [object] $Message)

    $paths = [System.Collections.Generic.List[string]]::new()
    if ($Message -isnot [string] -or [string]::IsNullOrWhiteSpace($Message)) {
        return [pscustomobject]@{ Paths = [string[]]@(); ReasonCode = $null; Reason = $null }
    }

    $text = $Message -replace '\\', '/'
    $tokenPattern = '(?<![^\s`''"()<>|*?,;\[\]])[^\s`''"()<>|*?,;\[\]]*docs/features/active/[^\s`''"()<>|*?,;\[\]]+?\.md(?=[.:]*(?:[\s`''"()<>|*?,;\[\]]|$))'
    $spanPattern = '`([^`\r\n]*docs/features/active/[^`\r\n]*)`|''([^''\r\n]*docs/features/active/[^''\r\n]*)''|"([^"\r\n]*docs/features/active/[^"\r\n]*)"'
    $shapePattern = '^docs/features/active/[^/]+/(?:(?:[^/]+/)?policy-audit\.[^/]+\.md|audit/[^/]+/policy-audit\.md)$'
    $auditNamePattern = '^policy-audit\.(?:[^/]+\.)?md$'
    $docsPrefix = 'docs/features/active/'
    $candidates = [System.Collections.Generic.List[string]]::new()
    foreach ($labelMatch in [regex]::Matches($text, 'policy-audit-path:(?<rest>[^\r\n]*)')) {
        $candidates.Add(($labelMatch.Groups['rest'].Value.Trim() -replace '^(?<q>[`''"])(?<c>.*)\k<q>$', '${c}'))
    }
    foreach ($spanMatch in [regex]::Matches($text, $spanPattern)) {
        $candidates.Add(($spanMatch.Groups[1].Value + $spanMatch.Groups[2].Value + $spanMatch.Groups[3].Value).Trim())
    }
    foreach ($match in [regex]::Matches($text, $tokenPattern)) { $candidates.Add($match.Value) }
    foreach ($candidateText in $candidates) {
        $token = $candidateText -replace '^policy-audit-path:', ''
        $token = $token -replace '/{2,}', '/'
        $token = $token -replace '(?<=\.md)[.,:;]+$', ''
        $index = $token.IndexOf($docsPrefix, [System.StringComparison]::Ordinal)
        if ($index -lt 0 -or $token.LastIndexOf($docsPrefix, [System.StringComparison]::Ordinal) -ne $index) { continue }
        $segments = @($token -split '/')
        if ($segments[-1] -match $auditNamePattern -and $segments -contains '..') {
            return [pscustomobject]@{ Paths = [string[]]@(); ReasonCode = 'AUDIT_PATH_TRAVERSAL'; Reason = "the policy-audit path '$token' contains a '..' segment; name the audit by a path without '..'." }
        }
        $prefix = $token.Substring(0, $index)
        $relative = $token.Substring($index)
        if ($relative -notmatch $shapePattern) { continue }
        $candidate = if ($prefix -eq '' -or $prefix -eq './') { $relative } elseif ($prefix -match '^(/|[A-Za-z]:/)') { $token } else { $null }
        if ($null -eq $candidate) { continue }
        $known = $false
        foreach ($existing in $paths) { if ([string]::Equals($existing, $candidate, [System.StringComparison]::Ordinal)) { $known = $true } }
        if (-not $known) { $paths.Add($candidate) }
    }
    return [pscustomobject]@{ Paths = [string[]]$paths.ToArray(); ReasonCode = $null; Reason = $null }
}

function Select-CodexReviewPolicyAudit {
    <#
    .SYNOPSIS
        Selects one policy audit from repository-relative audit paths.
    .DESCRIPTION
        One distinct audit is selected as is. Several audits of one feature folder select the
        lexicographically greatest timestamp. Audits of different folders yield AUDIT_AMBIGUOUS naming
        the folders; no path yields AUDIT_NOT_NAMED (decision D2: no recency fallback). Returns
        RelativePath, ReasonCode, and Reason.
    .PARAMETER RelativePath
        Repository-relative policy-audit paths.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([AllowNull()] [AllowEmptyCollection()] [string[]] $RelativePath)

    $audits = @(foreach ($path in @($RelativePath | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })) {
            $match = [regex]::Match($path, '^docs/features/active/(?<folder>[^/]+)/(?:(?:[^/]+/)?policy-audit\.(?<stamp>[^/]+)\.md|audit/(?<stamp>[^/]+)/policy-audit\.md)$')
            if ($match.Success) { [pscustomobject]@{ Path = $path; Folder = $match.Groups['folder'].Value; Stamp = $match.Groups['stamp'].Value } }
        })
    if ($audits.Count -eq 0) {
        return [pscustomobject]@{ RelativePath = $null; ReasonCode = 'AUDIT_NOT_NAMED'; Reason = 'the reviewer''s final message names no policy audit; state the policy-audit path (policy-audit-path: docs/features/active/<folder>/policy-audit.<timestamp>.md) in the final message so the coverage verdicts can be checked.' }
    }
    $folders = @($audits | ForEach-Object { $_.Folder } | Sort-Object -Unique -CaseSensitive)
    if ($folders.Count -gt 1) {
        return [pscustomobject]@{ RelativePath = $null; ReasonCode = 'AUDIT_AMBIGUOUS'; Reason = "the reviewer's final message names policy audits of $($folders.Count) feature folders ($($folders -join ', ')); name the policy audit of the reviewed item only." }
    }
    $selected = $audits[0]
    foreach ($audit in $audits) { if ([string]::CompareOrdinal($audit.Stamp, $selected.Stamp) -gt 0) { $selected = $audit } }
    return [pscustomobject]@{ RelativePath = $selected.Path; ReasonCode = $null; Reason = $null }
}

function Resolve-CodexReviewCoverageTarget {
    <#
    .SYNOPSIS
        Resolves the item root and the policy audit that the coverage hook judges.
    .DESCRIPTION
        Absolute audit paths are resolved with Resolve-HookTargetWorktree (the worktree list comes
        from Get-CodexReviewCoverageWorktreeList) and made relative with
        Get-HookTargetWorktreeRelativePath; relative paths use the session root with Source
        SessionRoot. The selected audit must exist beneath the item root. Returns ItemRoot, Source,
        AuditRelativePath, ReasonCode, and Reason; ReasonCode is $null when the target is usable.
    .PARAMETER Message
        The last_assistant_message value of the payload; any type.
    .PARAMETER SessionRoot
        The hook's session root.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowNull()] [object] $Message,
        [Parameter(Mandatory = $true)] [string] $SessionRoot
    )

    $session = ConvertTo-HookTargetWorktreeNormalizedPath -Path $SessionRoot
    $extracted = Get-CodexReviewPolicyAuditPath -Message $Message
    if ($null -ne $extracted.ReasonCode) {
        return [pscustomobject]@{ ItemRoot = $null; Source = $null; AuditRelativePath = $null; ReasonCode = $extracted.ReasonCode; Reason = $extracted.Reason }
    }

    $paths = @($extracted.Paths)
    $absolute = @($paths | Where-Object { $_ -match '^(/|[A-Za-z]:/)' })
    $itemRoot = $session
    $source = 'SessionRoot'
    if ($absolute.Count -gt 0) {
        $resolution = Resolve-HookTargetWorktree -SessionRoot $SessionRoot -FilePath $paths -WorktreeListInvoker { param($Root) Get-CodexReviewCoverageWorktreeList -SessionRoot $Root }
        if ($null -ne $resolution.ReasonCode) {
            $names = @($resolution.Candidates) -join ', '
            return [pscustomobject]@{ ItemRoot = $null; Source = $resolution.Source; AuditRelativePath = $null; ReasonCode = $resolution.ReasonCode; Reason = "the named policy-audit paths resolve to more than one worktree ($names): $($resolution.Detail); name the policy audit of the reviewed item only." }
        }
        $itemRoot = $resolution.WorktreeRoot
        $source = $resolution.Source
    }

    $relative = [System.Collections.Generic.List[string]]::new()
    foreach ($path in $paths) {
        $converted = if ($path -match '^(/|[A-Za-z]:/)') { Get-HookTargetWorktreeRelativePath -Path $path -WorktreeRoot $itemRoot } else { $path }
        if ($null -eq $converted) {
            return [pscustomobject]@{ ItemRoot = $itemRoot; Source = $source; AuditRelativePath = $null; ReasonCode = 'AUDIT_NOT_FOUND'; Reason = "the named policy audit '$path' does not exist beneath the item root '$itemRoot'." }
        }
        $relative.Add($converted)
    }
    $selection = Select-CodexReviewPolicyAudit -RelativePath $relative.ToArray()
    if ($null -ne $selection.ReasonCode) {
        return [pscustomobject]@{ ItemRoot = $itemRoot; Source = $source; AuditRelativePath = $null; ReasonCode = $selection.ReasonCode; Reason = $selection.Reason }
    }
    if (-not (Test-Path -LiteralPath "$itemRoot/$($selection.RelativePath)" -PathType Leaf)) {
        return [pscustomobject]@{ ItemRoot = $itemRoot; Source = $source; AuditRelativePath = $selection.RelativePath; ReasonCode = 'AUDIT_NOT_FOUND'; Reason = "the named policy audit '$($selection.RelativePath)' does not exist beneath the item root '$itemRoot'." }
    }
    return [pscustomobject]@{ ItemRoot = $itemRoot; Source = $source; AuditRelativePath = $selection.RelativePath; ReasonCode = $null; Reason = $null }
}
