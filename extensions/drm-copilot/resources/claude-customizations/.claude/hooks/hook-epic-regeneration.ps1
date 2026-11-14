<#
.SYNOPSIS
    Preimplementation allowance for the integration-tip regeneration commit (issue #1156).

.DESCRIPTION
    Dot-sourced by enforce-orchestration-preimplementation-gate-epic-scope.ps1 in both runtimes;
    this file is byte-identical in the Claude and Codex hook folders. Get-OrchestrationEpicScopeDecision
    calls Get-EpicRegenerationAllowance only when the readiness failure is exactly
    'merge-in-progress'.

    The allowance admits one Bash command when all of the following hold: the call carries no
    Write or Edit path; the command is one segment; it is a single git add with optional -- and
    paths, or a single git commit whose options are only -m, --message, -F, --file, or --trailer,
    optionally followed by -- and paths (the shape check of Get-EpicFanInAllowance); it carries no
    -a, --all, --amend, or --no-verify; the worktree HEAD is the checkpoint integration_branch; the
    integration worktree holds a valid config/orchestration-regeneration.json; and every named path,
    or for a pathless commit every staged path, is a plain repository-relative path that matches a
    configured pattern. An absent or invalid config admits nothing, so without a config the gate
    decides exactly as before.

    The config validation (rules 1 to 9 of the specification) and the glob semantics are inline
    copies of RegenerationConfig.psm1 and RegenerationClassifier.psm1, so this file imports no
    module and the Codex twin depends on no .claude/lib path; parity tests compare them with the
    library.

    Limits: this allowance is a policy-level control, not a security control. A writer in the same
    session can author the config file; the allowance proves the commit stays inside the declared
    generated paths, not who declared them.

.NOTES
    Compatible with PowerShell 7+. This file defines functions only and imports nothing. At run time
    Get-EpicRegenerationAllowance calls Get-EpicFanInAllowance and Get-EpicFanInPropertyText
    (hook-epic-fan-in.ps1) and Split-OrchestrationCommandLine and ConvertTo-OrchestrationCommandToken
    (the gate helpers), which the epic-scope file loads before it calls this file's functions.
#>

function Get-EpicRegenerationConfigPattern {
    <#
    .SYNOPSIS
        Return the paths patterns of a valid regeneration config document, or $null (pure).
    .DESCRIPTION
        Parses the text with ConvertFrom-Json -AsHashtable and applies rules 1 to 9: a JSON object;
        version the JSON integer 1; regeneration an object; no key other than command, paths,
        idempotency_check, and unit_gate; command a non-empty array of non-empty, non-whitespace
        strings; paths a non-empty array of safe pattern strings; idempotency_check and unit_gate
        in their declared shapes when present. A parse failure, any violation, an absent
        regeneration key, and regeneration null all return $null. A one-element paths list stays
        an array.
    .PARAMETER Text
        The config file text.
    .OUTPUTS
        System.String[] or $null
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param([AllowNull()][AllowEmptyString()][string] $Text)

    if ([string]::IsNullOrWhiteSpace($Text)) { return $null }
    try {
        $document = ConvertFrom-Json -InputObject $Text -AsHashtable -ErrorAction Stop
    } catch {
        # An unparseable config is invalid and admits nothing.
        return $null
    }
    if ($document -isnot [System.Collections.IDictionary]) { return $null }
    if (-not $document.Contains('version')) { return $null }
    $version = $document['version']
    if (-not (($version -is [long] -or $version -is [int]) -and $version -eq 1)) { return $null }
    if (-not $document.Contains('regeneration')) { return $null }
    $regeneration = $document['regeneration']
    if ($regeneration -isnot [System.Collections.IDictionary]) { return $null }
    foreach ($key in $regeneration.Keys) {
        if (@('command', 'paths', 'idempotency_check', 'unit_gate') -cnotcontains $key) { return $null }
    }

    # Rules 5, 8, and 9 share one shape: a non-empty array of non-empty, non-whitespace strings.
    $argvList = [System.Collections.Generic.List[object]]::new()
    if (-not $regeneration.Contains('command')) { return $null }
    $argvList.Add($regeneration['command'])
    if ($regeneration.Contains('idempotency_check')) { $argvList.Add($regeneration['idempotency_check']) }
    if ($regeneration.Contains('unit_gate')) {
        $gate = $regeneration['unit_gate']
        if ($gate -isnot [object[]] -or $gate.Count -eq 0) { return $null }
        foreach ($argv in $gate) { $argvList.Add($argv) }
    }
    foreach ($argv in $argvList) {
        if ($argv -isnot [object[]] -or $argv.Count -eq 0) { return $null }
        foreach ($element in $argv) {
            if ($element -isnot [string] -or [string]::IsNullOrWhiteSpace($element)) { return $null }
        }
    }

    # Rules 6 and 7: paths is a non-empty array of safe repository-relative patterns.
    if (-not $regeneration.Contains('paths')) { return $null }
    $paths = $regeneration['paths']
    if ($paths -isnot [object[]] -or $paths.Count -eq 0) { return $null }
    foreach ($pattern in $paths) {
        if ($pattern -isnot [string] -or $pattern.Length -eq 0) { return $null }
        if ($pattern.StartsWith('/') -or $pattern.Contains('\') -or $pattern -match '^[A-Za-z]:') { return $null }
        if ($pattern.Contains('[') -or $pattern.Contains(']')) { return $null }
        foreach ($segment in $pattern.Split('/')) {
            if ($segment.Length -eq 0 -or $segment -ceq '.' -or $segment -ceq '..') { return $null }
        }
    }
    return , ([string[]] @($paths))
}

function Test-EpicRegenerationPathMatch {
    <#
    .SYNOPSIS
        Report whether a repository path matches any regeneration pattern (pure).
    .DESCRIPTION
        Whole-string, ordinal, case-sensitive match: a single star and a question mark do not cross
        a forward slash, a double star crosses forward slashes, and every other character is
        literal. A pattern that begins with a double-star segment and a slash also matches its
        remainder at the repository root. A candidate holding a backslash never matches.
    .PARAMETER Path
        The repository-relative candidate path.
    .PARAMETER Pattern
        The configured patterns.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()][AllowEmptyString()][string] $Path,
        [AllowNull()][AllowEmptyCollection()][string[]] $Pattern
    )

    if ($null -eq $Path -or $Path.Contains('\')) { return $false }
    foreach ($declared in @($Pattern)) {
        if ($null -eq $declared) { continue }
        $variants = @($declared)
        if ($declared.StartsWith('**/', [System.StringComparison]::Ordinal)) { $variants += $declared.Substring(3) }
        foreach ($variant in $variants) {
            $regexText = [System.Text.StringBuilder]::new()
            $index = 0
            while ($index -lt $variant.Length) {
                if ($index + 1 -lt $variant.Length -and $variant[$index] -ceq '*' -and $variant[$index + 1] -ceq '*') {
                    [void]$regexText.Append('.*')
                    $index += 2
                    continue
                }
                $character = $variant[$index]
                if ($character -ceq '*') { [void]$regexText.Append('[^/]*') }
                elseif ($character -ceq '?') { [void]$regexText.Append('[^/]') }
                else { [void]$regexText.Append([regex]::Escape([string]$character)) }
                $index += 1
            }
            if ([regex]::IsMatch($Path, '\A(?:' + $regexText.ToString() + ')\z')) { return $true }
        }
    }
    return $false
}

function Read-EpicRegenerationConfig {
    <#
    .SYNOPSIS
        Read the regeneration config beneath a worktree root and return its patterns, or $null.
    .DESCRIPTION
        Builds <root>/config/orchestration-regeneration.json, passes that one path to TestPath and,
        when it reports the file present, to ReadText, and returns Get-EpicRegenerationConfigPattern
        of the text. An absent file, a reader that throws, and an invalid document return $null.
    .PARAMETER WorktreeRoot
        The integration worktree root.
    .PARAMETER TestPath
        File-existence seam; default Test-Path -LiteralPath.
    .PARAMETER ReadText
        Text-reader seam; default Get-Content -LiteralPath -Raw.
    .OUTPUTS
        System.String[] or $null
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [AllowNull()][AllowEmptyString()][string] $WorktreeRoot,
        [scriptblock] $TestPath = { param($Path) Test-Path -LiteralPath $Path },
        [scriptblock] $ReadText = { param($Path) Get-Content -LiteralPath $Path -Raw }
    )

    if ([string]::IsNullOrWhiteSpace($WorktreeRoot)) { return $null }
    $configPath = $WorktreeRoot.TrimEnd('/') + '/config/orchestration-regeneration.json'
    try {
        if (-not [bool](& $TestPath $configPath)) { return $null }
        $text = [string](& $ReadText $configPath)
    } catch {
        # An unreadable config is treated as absent, so it admits nothing.
        return $null
    }
    $patterns = Get-EpicRegenerationConfigPattern -Text $text
    if ($null -eq $patterns) { return $null }
    return , $patterns
}

function Get-EpicRegenerationAllowance {
    <#
    .SYNOPSIS
        Decide whether a call in a merge-in-progress epic scope is a sanctioned regeneration add or commit.
    .DESCRIPTION
        Refuses a Write or Edit path, a command that is not exactly one segment, the tokens -a, --all,
        --amend, and --no-verify, and a worktree HEAD other than the checkpoint integration_branch.
        Calls ConfigReader once with the scope's worktree root and refuses when it returns $null.
        Otherwise delegates to Get-EpicFanInAllowance with a path predicate that admits nothing and
        an operand predicate that rejects an empty token, a token beginning with -, a backslash,
        asterisk, question mark, or square bracket, a leading slash or drive letter, and an empty,
        . or .. segment, and otherwise requires a pattern match; the same predicate is applied to
        every staged name of a pathless commit.
    .PARAMETER Scope
        The Resolve-EpicScopeCheckpoint result (Checkpoint, WorktreeRoot, Branch, ...).
    .PARAMETER FilePath
        The path-leg paths; any non-blank entry refuses.
    .PARAMETER Command
        The command-leg text.
    .PARAMETER StagedIndexReader
        Called with the worktree root; returns an object with ExitCode and Output.
    .PARAMETER ConfigReader
        Called once with -WorktreeRoot; returns the configured patterns or $null.
    .OUTPUTS
        System.Management.Automation.PSCustomObject with Allowed and Detail.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowNull()][object] $Scope,
        [AllowNull()][AllowEmptyCollection()][AllowEmptyString()][string[]] $FilePath,
        [AllowNull()][AllowEmptyString()][string] $Command,
        [AllowNull()][scriptblock] $StagedIndexReader,
        [AllowNull()][scriptblock] $ConfigReader
    )

    try {
        if ($null -eq $Scope -or $null -eq $ConfigReader) { return [pscustomobject]@{ Allowed = $false; Detail = 'no resolved scope or config reader' } }
        if (@($FilePath | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }).Count -gt 0) {
            return [pscustomobject]@{ Allowed = $false; Detail = 'a Write or Edit call is not a regeneration commit' }
        }
        if ([string]::IsNullOrWhiteSpace($Command)) { return [pscustomobject]@{ Allowed = $false; Detail = 'command text is blank' } }
        $split = Split-OrchestrationCommandLine -CommandText $Command
        if (-not $split.Balanced -or @($split.Segments).Count -ne 1) {
            return [pscustomobject]@{ Allowed = $false; Detail = 'the command is not exactly one segment' }
        }
        $tokens = @(ConvertTo-OrchestrationCommandToken -Segment ([string]@($split.Segments)[0]).Trim())
        foreach ($token in $tokens) {
            if (@('-a', '--all', '--amend', '--no-verify') -ccontains $token) {
                return [pscustomobject]@{ Allowed = $false; Detail = "option not allowed: $token" }
            }
        }
        $integrationBranch = Get-EpicFanInPropertyText -InputObject $Scope.Checkpoint -Name 'integration_branch'
        if ([string]::IsNullOrWhiteSpace($integrationBranch) -or $integrationBranch -cne [string]$Scope.Branch) {
            return [pscustomobject]@{ Allowed = $false; Detail = 'not the epic integration branch' }
        }
        # The predicate reads $epicRegenerationPatterns through the caller scope chain when Get-EpicFanInAllowance invokes it.
        $epicRegenerationPatterns = & $ConfigReader -WorktreeRoot ([string]$Scope.WorktreeRoot)
        if ($null -eq $epicRegenerationPatterns -or @($epicRegenerationPatterns).Count -eq 0) {
            return [pscustomobject]@{ Allowed = $false; Detail = 'no valid regeneration config in the integration worktree' }
        }
        $operandPredicate = {
            param([string] $Path)
            if ([string]::IsNullOrEmpty($Path) -or $Path.StartsWith('-')) { return $false }
            if ($Path.IndexOfAny([char[]]@([char]92, '*', '?', '[', ']')) -ge 0) { return $false }
            if ($Path.StartsWith('/') -or $Path -match '^[A-Za-z]:') { return $false }
            foreach ($segment in $Path.Split('/')) {
                if ($segment.Length -eq 0 -or $segment -ceq '.' -or $segment -ceq '..') { return $false }
            }
            return (Test-EpicRegenerationPathMatch -Path $Path -Pattern $epicRegenerationPatterns)
        }
        $denyPath = { param([string] $Path) $false }
        return (Get-EpicFanInAllowance -Scope $Scope -FilePath @() -Command $Command -StagedIndexReader $StagedIndexReader -PathPredicate $denyPath -OperandPredicate $operandPredicate)
    } catch {
        return [pscustomobject]@{ Allowed = $false; Detail = "allowance error: $($_.Exception.Message)" }
    }
}
