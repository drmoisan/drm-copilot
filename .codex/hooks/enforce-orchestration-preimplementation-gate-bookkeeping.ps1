<#
.SYNOPSIS
    Bookkeeping staging leg of the preimplementation gate and its configuration (issue #1160).

.DESCRIPTION
    Dot-sourced, guarded, by .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 and
    .codex/hooks/enforce-orchestration-preimplementation-gate.ps1. The gate calls
    Get-OrchestrationBookkeepingStagingResult in its single-feature branch after the issue #1026
    cleanup leg and before the final deny, so the leg can only turn a deny into an allow. It
    admits a git add or git commit whose paths are orchestration bookkeeping, for example agent
    memory staged and committed in a coordinator checkout that holds no checkpoint.

    Configuration: the optional file config/preimplementation-gate.json, read relative to this
    file's own directory (two levels up, then config/) by Get-OrchestrationGateBookkeepingConfigText.
      - Schema: a JSON object with exactly the keys schema_version (the integer 1) and
        bookkeeping_roots (an array of strings). Each entry matches ^[A-Za-z0-9._/-]+/$, does not
        start with '/', contains no '//', and has no '.' or '..' segment; duplicate entries and
        unknown top-level keys are rejected.
      - Default: when the file is absent the declared roots are [".claude/agent-memory/"].
      - Opt-out: "bookkeeping_roots": [] disables the leg, which restores the previous behavior.
      - Invalid file: the leg is disabled and the final deny text gains the suffix
        " Bookkeeping leg not applied: BOOKKEEPING_CONFIG_INVALID: <detail>.", placed after the
        cleanup suffix. With an absent or valid file no suffix is added.

    Leg rules (decisions D4, D5, D6, and D14):
      - The command must pass Get-EpicFanInAllowance (hook-epic-fan-in.ps1) with a path predicate
        over the union of the five issue #539 trees and the declared roots: every segment is
        git [-C <absolute>] add [--] <paths> or git [-C <absolute>] commit with only -m,
        --message, -F, --file, or --trailer and nothing or -- <paths> after them, and every path
        lies strictly under a root with no backslash, glob character, '.' or '..' segment, or
        leading '/'. A pathless commit reads the staged index of the worktree, which must name
        only such paths.
      - Declared-root anchor (D14): at least one path the command names, or, for a pathless
        commit, at least one staged path, lies under a declared root. A command whose paths all
        lie in the issue #539 trees keeps the previous deny text.
      - Selector check (D14): every segment that carries -C must pass
        Test-ExemptOrchestrationSelector (helpers file).
      - Worktree root: derived from the path of the gate's checkpoint read by removing the
        item checkpoint suffix; when the caller injected the checkpoint text, or the path does
        not end with that suffix, there is no root and a pathless commit is denied without
        reading the staged index.
    This is a policy-level control, not a security control.

.NOTES
    PowerShell 7+. Only Get-OrchestrationGateBookkeepingConfigText reads a file; every other
    function is pure, and the staged index is read only through the injected reader. No
    StrictMode or preference assignment, because a dot-sourced file changes its caller's scope.
    The file holds no artifacts-tree string literal: the five trees come from
    $script:OrchestrationBookkeepingTrees (helpers file) and the checkpoint suffix from
    $script:CheckpointPaths (gate file). Call-time dependencies: Get-EpicFanInAllowance and
    Test-EpicMergedFeaturePath (hook-epic-fan-in.ps1), Split-OrchestrationCommandLine,
    ConvertTo-OrchestrationCommandToken, and Test-ExemptOrchestrationSelector (helpers file),
    and Get-OrchestrationGateStagedIndex (cleanup sibling). Byte-identical at .claude/hooks/,
    .codex/hooks/, and both bundle mirrors under extensions/drm-copilot/resources/.
    AUTHORITY: PowerShell-authoritative. This hook file starts no interpreter process.
#>

# The built-in declared roots, used when config/preimplementation-gate.json is absent (D13).
$script:OrchestrationBookkeepingDefaultRoots = @('.claude/agent-memory/')

function Get-OrchestrationGateBookkeepingConfigText {
    <#
    .SYNOPSIS
        Return the text of config/preimplementation-gate.json, or $null when it is absent.
    .DESCRIPTION
        The I/O seam of the bookkeeping leg. The file is resolved from this file's directory
        two levels up, so the same relative location serves .claude/hooks and .codex/hooks.
    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param()

    $repositoryRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
    $path = Join-Path (Join-Path $repositoryRoot 'config') 'preimplementation-gate.json'
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { return $null }
    return [string](Get-Content -LiteralPath $path -Raw -ErrorAction Stop)
}

function ConvertFrom-OrchestrationGateBookkeepingConfig {
    <#
    .SYNOPSIS
        Parse and validate the bookkeeping configuration text (decision D6).
    .DESCRIPTION
        Returns Valid, Roots, and Detail. Valid is $false, with a Detail naming the first
        failed rule of the file header, for malformed JSON, a non-object, a missing or unknown
        top-level key, a schema_version other than the integer 1, a non-array
        bookkeeping_roots, a non-string entry, an entry that fails the entry rules, or a
        duplicate entry. A valid document returns its entries, which may be empty.
    .PARAMETER Text
        The configuration file text.
    .OUTPUTS
        System.Management.Automation.PSCustomObject
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([AllowNull()][AllowEmptyString()][string] $Text)

    $keys = @('schema_version', 'bookkeeping_roots')
    $detail = ''
    $document = $null
    try {
        $document = ConvertFrom-Json -InputObject $Text -NoEnumerate -ErrorAction Stop
    } catch {
        $detail = 'the file is not valid JSON'
    }
    if (-not $detail -and $document -isnot [System.Management.Automation.PSCustomObject]) { $detail = 'the document is not a JSON object' }
    if (-not $detail) {
        $names = @($document.PSObject.Properties.Name)
        $unknown = @($names | Where-Object { $keys -cnotcontains $_ })
        $missing = @($keys | Where-Object { $names -cnotcontains $_ })
        $version = $document.schema_version
        if ($unknown.Count -gt 0) { $detail = "unknown top-level key '$($unknown[0])'" }
        elseif ($missing.Count -gt 0) { $detail = "missing top-level key '$($missing[0])'" }
        elseif (-not ($version -is [int] -or $version -is [long]) -or $version -ne 1) { $detail = 'schema_version is not the integer 1' }
        elseif ($document.bookkeeping_roots -isnot [array]) { $detail = 'bookkeeping_roots is not an array' }
    }
    $roots = [System.Collections.Generic.List[string]]::new()
    if (-not $detail) {
        $position = 0
        foreach ($entry in $document.bookkeeping_roots) {
            $detail = if ($entry -isnot [string]) { "bookkeeping_roots entry $position is not a string" }
            elseif ($entry -cnotmatch '^[A-Za-z0-9._/-]+/$') { "bookkeeping_roots entry $position must use only A-Z a-z 0-9 . _ / - and end with /" }
            elseif ($entry.StartsWith('/', [System.StringComparison]::Ordinal)) { "bookkeeping_roots entry $position starts with /" }
            elseif ($entry.Contains('//')) { "bookkeeping_roots entry $position contains //" }
            elseif (@($entry.TrimEnd('/').Split('/') | Where-Object { $_ -ceq '.' -or $_ -ceq '..' }).Count -gt 0) { "bookkeeping_roots entry $position has a . or .. segment" }
            elseif ($roots -ccontains $entry) { "bookkeeping_roots entry $position duplicates an earlier entry" }
            else { '' }
            if ($detail) { break }
            $roots.Add($entry)
            $position++
        }
    }
    if ($detail) { return [pscustomobject]@{ Valid = $false; Roots = [string[]]@(); Detail = $detail } }
    return [pscustomobject]@{ Valid = $true; Roots = [string[]]$roots.ToArray(); Detail = '' }
}

function Get-OrchestrationGateBookkeepingWorktreeRoot {
    <#
    .SYNOPSIS
        Return the worktree root of a checkpoint read path, or $null (decision D9, suffix strip).
    .DESCRIPTION
        Normalizes backslashes to '/', then removes '/' plus CheckpointSuffix from the end with an
        ordinal case-insensitive comparison. Returns $null when either value is blank, when the
        path does not end with the suffix, or when nothing remains.
    .PARAMETER CheckpointPath
        The Path of the gate's Read-OrchestrationGateCheckpoint result, or empty.
    .PARAMETER CheckpointSuffix
        The repository-relative item checkpoint path.
    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowNull()][AllowEmptyString()][string] $CheckpointPath,
        [AllowNull()][AllowEmptyString()][string] $CheckpointSuffix
    )

    if ([string]::IsNullOrWhiteSpace($CheckpointPath) -or [string]::IsNullOrWhiteSpace($CheckpointSuffix)) { return $null }
    $normalized = $CheckpointPath -replace '\\', '/'
    $suffix = '/' + ($CheckpointSuffix -replace '\\', '/').TrimStart('/')
    if (-not $normalized.EndsWith($suffix, [System.StringComparison]::OrdinalIgnoreCase)) { return $null }
    $root = $normalized.Substring(0, $normalized.Length - $suffix.Length)
    if ([string]::IsNullOrWhiteSpace($root)) { return $null }
    return $root
}

function Test-OrchestrationGateBookkeepingAnchor {
    <#
    .SYNOPSIS
        Report whether at least one path lies under a declared root (decision D14 anchor).
    .DESCRIPTION
        Uses Test-EpicMergedFeaturePath, so a path equal to a root, a backslash, a glob
        character, a '.' or '..' segment, or a leading '/' never anchors.
    .PARAMETER Path
        The paths the command names, or the staged paths of a pathless commit.
    .PARAMETER Root
        The declared roots.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()][AllowEmptyCollection()][AllowEmptyString()][string[]] $Path,
        [AllowNull()][AllowEmptyCollection()][string[]] $Root
    )

    foreach ($candidate in @($Path)) {
        if (Test-EpicMergedFeaturePath -RelativePath $candidate -Root $Root) { return $true }
    }
    return $false
}

function Test-OrchestrationGateBookkeepingSelector {
    <#
    .SYNOPSIS
        Report whether every -C selector of a command passes Test-ExemptOrchestrationSelector.
    .DESCRIPTION
        Splits the command with Split-OrchestrationCommandLine, tokenizes each segment with
        ConvertTo-OrchestrationCommandToken, and calls Test-ExemptOrchestrationSelector for
        every segment that carries a -C token. Unbalanced text answers $false.
    .PARAMETER Command
        The command text.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()][AllowEmptyString()][string] $Command)

    $split = Split-OrchestrationCommandLine -CommandText ([string]$Command)
    if (-not $split.Balanced) { return $false }
    foreach ($segment in @($split.Segments)) {
        $tokens = [string[]]@(ConvertTo-OrchestrationCommandToken -Segment $segment.Trim())
        if ($tokens -ccontains '-C' -and -not (Test-ExemptOrchestrationSelector -Token $tokens)) { return $false }
    }
    return $true
}

function Get-OrchestrationBookkeepingStagingResult {
    <#
    .SYNOPSIS
        Decide whether a call the gate would deny is bookkeeping staging (issue #1160).
    .DESCRIPTION
        Returns Allowed, DenySuffix, and Detail. Not applied (Allowed $false, empty suffix) for
        a blank command, apply_patch text, an empty declared list, a rejected -C selector, a
        command Get-EpicFanInAllowance does not admit, or a command with no declared-root path.
        An invalid configuration answers Allowed $false with the BOOKKEEPING_CONFIG_INVALID
        suffix. The configuration is read only for a non-blank command that is not apply_patch
        text.
    .PARAMETER Command
        The Bash command text.
    .PARAMETER CheckpointPath
        The Path of the gate's checkpoint read, or empty when the checkpoint text was injected.
    .PARAMETER ConfigReader
        Returns the configuration text or $null; default Get-OrchestrationGateBookkeepingConfigText.
    .PARAMETER StagedIndexReader
        Called with the worktree root; default Get-OrchestrationGateStagedIndex.
    .OUTPUTS
        System.Management.Automation.PSCustomObject
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowNull()][AllowEmptyString()][string] $Command,
        [AllowNull()][AllowEmptyString()][string] $CheckpointPath,
        [scriptblock] $ConfigReader = { Get-OrchestrationGateBookkeepingConfigText },
        [scriptblock] $StagedIndexReader = { param([string] $WorktreeRoot) Get-OrchestrationGateStagedIndex -WorktreeRoot $WorktreeRoot }
    )

    if ([string]::IsNullOrWhiteSpace($Command) -or $Command.TrimStart().StartsWith('*** Begin Patch', [System.StringComparison]::Ordinal)) {
        return [pscustomobject]@{ Allowed = $false; DenySuffix = ''; Detail = 'not a Bash command' }
    }
    try {
        $configText = & $ConfigReader
        $config = if ($null -eq $configText) {
            [pscustomobject]@{ Valid = $true; Roots = [string[]]$script:OrchestrationBookkeepingDefaultRoots; Detail = '' }
        } else {
            ConvertFrom-OrchestrationGateBookkeepingConfig -Text ([string]$configText)
        }
    } catch {
        $config = [pscustomobject]@{ Valid = $false; Roots = [string[]]@(); Detail = 'the file could not be read' }
    }
    if (-not $config.Valid) {
        return [pscustomobject]@{ Allowed = $false; DenySuffix = " Bookkeeping leg not applied: BOOKKEEPING_CONFIG_INVALID: $($config.Detail)."; Detail = $config.Detail }
    }
    $bookkeepingDeclaredRoot = [string[]]@($config.Roots)
    if ($bookkeepingDeclaredRoot.Count -eq 0) { return [pscustomobject]@{ Allowed = $false; DenySuffix = ''; Detail = 'no declared root' } }
    if (-not (Test-OrchestrationGateBookkeepingSelector -Command $Command)) {
        return [pscustomobject]@{ Allowed = $false; DenySuffix = ''; Detail = 'a -C selector is not accepted' }
    }

    # The predicate records every operand and staged name it judges, for the anchor test, and
    # reads both variables through the caller scope chain when Get-EpicFanInAllowance invokes it.
    $bookkeepingUnionRoot = [string[]](@($script:OrchestrationBookkeepingTrees) + $bookkeepingDeclaredRoot)
    $bookkeepingObservedPath = [System.Collections.Generic.List[string]]::new()
    $predicate = { param([string] $Path) $bookkeepingObservedPath.Add($Path); Test-EpicMergedFeaturePath -RelativePath $Path -Root $bookkeepingUnionRoot }
    $worktreeRoot = Get-OrchestrationGateBookkeepingWorktreeRoot -CheckpointPath $CheckpointPath -CheckpointSuffix ([string]@($script:CheckpointPaths)[0])
    $reader = if ($null -ne $worktreeRoot) { $StagedIndexReader } else { { [pscustomobject]@{ ExitCode = -1; Output = '' } } }
    $scope = [pscustomobject]@{ Checkpoint = $null; WorktreeRoot = $worktreeRoot }
    $allowance = Get-EpicFanInAllowance -Scope $scope -Command $Command -StagedIndexReader $reader -PathPredicate $predicate -OperandPredicate $predicate
    if (-not $allowance.Allowed) { return [pscustomobject]@{ Allowed = $false; DenySuffix = ''; Detail = [string]$allowance.Detail } }
    if (-not (Test-OrchestrationGateBookkeepingAnchor -Path $bookkeepingObservedPath.ToArray() -Root $bookkeepingDeclaredRoot)) {
        return [pscustomobject]@{ Allowed = $false; DenySuffix = ''; Detail = 'no path lies under a declared root' }
    }
    return [pscustomobject]@{ Allowed = $true; DenySuffix = ''; Detail = 'bookkeeping staging' }
}
