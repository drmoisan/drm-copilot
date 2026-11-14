<#
.SYNOPSIS
    Pure cleanup-context predicates shared by the cleanup legs of the enforcement gates (issue #1026).

.DESCRIPTION
    The cleanup-merged-worktrees skill writes no per-feature, epic, or parallel checkpoint, so
    the checkpoint-based gates cannot recognize its writes, commits, delegation, and pull
    request. Its integrity record is the sanctioned-removal manifest. This file holds the pure
    decisions the gates' cleanup legs share:

      Test-CleanupManifestText              - the manifest header (tool, schema_version) and,
                                              with -UtcNow, its freshness and run_id.
      Test-CleanupConsolidationRelativePath - the allowlist: the repository-relative prefixes
                                              docs/ and .claude/agent-memory/ (ordinal,
                                              case-sensitive), plus the pr-author receipt
                                              artifacts/pr_body_<digits>.receipt.json with
                                              -AllowReceipt.
      Find-CleanupConsolidationRecord       - the consolidation worktree, identified by its
                                              porcelain branch, never by its path.
      Test-CleanupScratchPath               - the scratch rule: an absolute path outside every
                                              registered worktree and the session root, under a
                                              temporary root.
      Test-CleanupConsolidationBranchLabel  - the delegation label rule of the model-routing leg.

    Every function fails closed: a malformed or ambiguous input answers $false or $null.

    The literals below restate values owned elsewhere: the branch equals
    CLEANUP_WT_CONSOLIDATION_BRANCH in
    .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_actions_lib.sh, and the
    manifest tool, schema version, and freshness bound equal $script:ExpectedManifestTool,
    $script:ExpectedManifestSchemaVersion, and $script:ManifestFreshnessBound in
    .claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1. The Codex hooks cannot import
    .claude/lib, so the values are restated here and pinned equal by
    tests/scripts/claude-hooks/hook-cleanup-context.Parity.Tests.ps1. The names avoid the
    removal gates' $script:CleanupWorktreeManifestPath.

.NOTES
    PowerShell 7+. Functions and literals only: no file, process, network, clock, or
    environment access, no dot-source, and no import. Byte-identical at .claude/hooks,
    .codex/hooks, and both bundle mirrors under extensions/drm-copilot/resources/.
#>

$script:CleanupContextBranch = 'documentationandmemories'
$script:CleanupContextManifestRelativePath = 'artifacts/orchestration/cleanup-worktrees-manifest.json'
$script:CleanupContextManifestTool = 'cleanup-merged-worktrees'
$script:CleanupContextManifestSchemaVersion = 1
$script:CleanupContextFreshnessHours = 24

function Test-CleanupManifestText {
    <#
    .SYNOPSIS
        Return $true when the text is a cleanup manifest with the expected header.
    .DESCRIPTION
        The text must parse as a JSON object whose tool is the string cleanup-merged-worktrees
        (ordinal) and whose schema_version is the integer 1. When -UtcNow is supplied, the
        manifest must also carry a generated_at that parses, is not after UtcNow, and lies
        within the freshness bound, and a run_id that is a non-blank string. The generated_at
        value is read exactly as CleanupWorktreeManifest.psm1 reads it, so the PR and
        delegation legs agree with the removal gates on freshness.
    .PARAMETER Raw
        The manifest text, or $null when no manifest exists.
    .PARAMETER UtcNow
        The current UTC time from the caller's clock seam.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()][AllowEmptyString()][string] $Raw,
        [datetime] $UtcNow
    )

    if ([string]::IsNullOrWhiteSpace($Raw)) {
        return $false
    }
    try {
        $manifest = $Raw | ConvertFrom-Json -ErrorAction Stop
    }
    catch {
        return $false
    }
    if ($manifest -isnot [System.Management.Automation.PSCustomObject]) {
        return $false
    }
    $names = @($manifest.PSObject.Properties.Name)
    if ($names -notcontains 'tool' -or $names -notcontains 'schema_version') {
        return $false
    }
    if ($manifest.tool -isnot [string] -or $manifest.tool -cne $script:CleanupContextManifestTool) {
        return $false
    }
    $schemaVersion = $manifest.schema_version
    if (($schemaVersion -isnot [int] -and $schemaVersion -isnot [long]) -or [long]$schemaVersion -ne $script:CleanupContextManifestSchemaVersion) {
        return $false
    }
    if (-not $PSBoundParameters.ContainsKey('UtcNow')) {
        return $true
    }

    if ($names -notcontains 'generated_at' -or $names -notcontains 'run_id') {
        return $false
    }
    $generatedAt = [datetime]::MinValue
    $styles = [System.Globalization.DateTimeStyles]::AdjustToUniversal -bor [System.Globalization.DateTimeStyles]::AssumeUniversal
    if (-not [datetime]::TryParse([string]$manifest.generated_at, [cultureinfo]::InvariantCulture, $styles, [ref] $generatedAt)) {
        return $false
    }
    if ($generatedAt -gt $UtcNow -or ($UtcNow - $generatedAt) -gt [timespan]::FromHours($script:CleanupContextFreshnessHours)) {
        return $false
    }
    return ($manifest.run_id -is [string] -and -not [string]::IsNullOrWhiteSpace($manifest.run_id))
}

function Test-CleanupConsolidationRelativePath {
    <#
    .SYNOPSIS
        Return $true when a repository-relative path is on the consolidation allowlist.
    .DESCRIPTION
        The path must use only the plain characters A-Z a-z 0-9 . _ / -, must not be rooted,
        must carry no '..' segment, and must start with docs/ or .claude/agent-memory/ under
        ordinal, case-sensitive comparison with at least one character after the prefix. Any
        other Markdown path, such as CLAUDE.md or .claude/rules/x.md, is not admitted. With
        -AllowReceipt the pr-author receipt artifacts/pr_body_<digits>.receipt.json is also
        admitted; it never enters the staging allowlist.
    .PARAMETER RelativePath
        The repository-relative path or operand.
    .PARAMETER AllowReceipt
        Admit the pr-author receipt path (Write and Edit leg only).
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()][AllowEmptyString()][string] $RelativePath,
        [switch] $AllowReceipt
    )

    $path = [string]$RelativePath
    if ($path -cnotmatch '^[A-Za-z0-9._/-]+$' -or $path.StartsWith('/')) {
        return $false
    }
    if (@($path -split '/') -contains '..') {
        return $false
    }
    if ($AllowReceipt -and $path -cmatch '^artifacts/pr_body_[0-9]+\.receipt\.json$') {
        return $true
    }
    foreach ($prefix in @('docs/', '.claude/agent-memory/')) {
        if ($path.Length -gt $prefix.Length -and $path.StartsWith($prefix, [System.StringComparison]::Ordinal)) {
            return $true
        }
    }
    return $false
}

function Find-CleanupConsolidationRecord {
    <#
    .SYNOPSIS
        Return the registered consolidation worktree record, or $null.
    .DESCRIPTION
        Takes the records ConvertFrom-HookTargetWorktreePorcelain emits. The first record (the
        main worktree stanza), prunable records, and detached records are skipped. The single
        remaining record whose Branch is ordinal-equal to documentationandmemories is returned;
        none, or more than one, returns $null. The path is never consulted, because the
        consolidation path can be overridden by CLEANUP_WT_CONSOLIDATION_PATH.
    .PARAMETER Record
        The porcelain records, in listing order.
    .OUTPUTS
        System.Management.Automation.PSCustomObject or $null
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowNull()][AllowEmptyCollection()][object[]] $Record
    )

    $records = @($Record | Where-Object { $null -ne $_ })
    $found = [System.Collections.Generic.List[object]]::new()
    for ($index = 1; $index -lt $records.Count; $index++) {
        $candidate = $records[$index]
        if ([bool]$candidate.Prunable -or $null -eq $candidate.Branch) {
            continue
        }
        if ([string]$candidate.Branch -ceq $script:CleanupContextBranch) {
            $found.Add($candidate)
        }
    }
    if ($found.Count -ne 1) {
        return $null
    }
    return $found[0]
}

function ConvertTo-CleanupContextPath {
    <#
    .SYNOPSIS
        Normalize a path to forward slashes with one trailing slash removed (bare roots kept).
    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowNull()][AllowEmptyString()][string] $Path
    )

    $normalized = ([string]$Path).Replace('\', '/')
    if ($normalized.Length -gt 1 -and $normalized.EndsWith('/') -and $normalized -notmatch '^[A-Za-z]:/$') {
        $normalized = $normalized.Substring(0, $normalized.Length - 1)
    }
    return $normalized
}

function Test-CleanupContextPathUnder {
    <#
    .SYNOPSIS
        Return $true when a normalized path equals a root or lies beneath it (OrdinalIgnoreCase).
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $Path,
        [AllowNull()][AllowEmptyString()][string] $Root
    )

    $normalizedRoot = ConvertTo-CleanupContextPath -Path $Root
    if ([string]::IsNullOrEmpty($normalizedRoot)) {
        return $false
    }
    if ([string]::Equals($Path, $normalizedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $true
    }
    $prefix = if ($normalizedRoot.EndsWith('/')) { $normalizedRoot } else { $normalizedRoot + '/' }
    return $Path.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)
}

function Test-CleanupScratchPath {
    <#
    .SYNOPSIS
        Return $true when a path is a scratch path under a temporary root and outside every worktree.
    .DESCRIPTION
        The path must be absolute (drive-rooted or slash-rooted, not UNC), carry no '.' or '..'
        segment and no surrounding whitespace, lie outside every registered worktree root and
        outside the session root, and lie under at least one accepted temporary-root spelling.
        Comparisons use forward-slash normalization and OrdinalIgnoreCase. The rule fails
        closed when no registered root or no temporary root is supplied, and when any
        registered worktree root lies under an accepted temporary root, because a path under
        such a worktree could then be spelled so that it matches no registered root.
    .PARAMETER Path
        The Write or Edit file path.
    .PARAMETER RegisteredRoot
        Every registered worktree root from the listing, prunable ones included.
    .PARAMETER SessionRoot
        The session root.
    .PARAMETER TemporaryRoot
        Every accepted spelling of the operating-system temporary root.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()][AllowEmptyString()][string] $Path,
        [AllowNull()][AllowEmptyCollection()][string[]] $RegisteredRoot,
        [AllowNull()][AllowEmptyString()][string] $SessionRoot,
        [AllowNull()][AllowEmptyCollection()][string[]] $TemporaryRoot
    )

    $raw = [string]$Path
    if ([string]::IsNullOrEmpty($raw) -or $raw.Trim() -cne $raw) {
        return $false
    }
    $normalized = ConvertTo-CleanupContextPath -Path $raw
    if ($normalized -notmatch '^([A-Za-z]:/|/(?!/))') {
        return $false
    }
    $segments = @($normalized -split '/')
    if ($segments -contains '.' -or $segments -contains '..') {
        return $false
    }
    $roots = @($RegisteredRoot | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    $temporary = @($TemporaryRoot | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    if ($roots.Count -eq 0 -or $temporary.Count -eq 0 -or [string]::IsNullOrWhiteSpace($SessionRoot)) {
        return $false
    }
    foreach ($registeredCandidate in $roots) {
        $normalizedRoot = ConvertTo-CleanupContextPath -Path $registeredCandidate
        foreach ($temporaryCandidate in $temporary) {
            if (Test-CleanupContextPathUnder -Path $normalizedRoot -Root $temporaryCandidate) {
                return $false
            }
        }
        if (Test-CleanupContextPathUnder -Path $normalized -Root $registeredCandidate) {
            return $false
        }
    }
    if (Test-CleanupContextPathUnder -Path $normalized -Root $SessionRoot) {
        return $false
    }
    foreach ($temporaryCandidate in $temporary) {
        $normalizedTemporary = ConvertTo-CleanupContextPath -Path $temporaryCandidate
        if (-not [string]::Equals($normalized, $normalizedTemporary, [System.StringComparison]::OrdinalIgnoreCase) -and
            (Test-CleanupContextPathUnder -Path $normalized -Root $normalizedTemporary)) {
            return $true
        }
    }
    return $false
}

function Test-CleanupConsolidationBranchLabel {
    <#
    .SYNOPSIS
        Return $true when a delegation prompt names the consolidation branch by exactly one label.
    .DESCRIPTION
        The prompt must contain exactly one 'branch:' label (case-insensitive count), on its own
        line in the lowercase form 'branch: <value>', with the value ordinal-equal to
        documentationandmemories, and no --head or --branch token anywhere, so the worktree
        resolvers that read the first branch signal cannot select a different branch.
    .PARAMETER PromptText
        The delegation prompt.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()][AllowEmptyString()][string] $PromptText
    )

    $text = [string]$PromptText
    if ([regex]::Matches($text, '(?i)\bbranch:').Count -ne 1) {
        return $false
    }
    if ([regex]::IsMatch($text, '(?i)(?<![\w-])--(?:head|branch)(?![\w-])')) {
        return $false
    }
    $label = [regex]::Match($text, '(?m)^[ \t]*branch:[ \t]*(?<value>[^\r\n]*?)[ \t]*\r?$')
    return ($label.Success -and $label.Groups['value'].Value -ceq $script:CleanupContextBranch)
}
