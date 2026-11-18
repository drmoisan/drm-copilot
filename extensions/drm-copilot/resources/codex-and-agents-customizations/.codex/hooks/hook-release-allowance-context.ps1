<#
.SYNOPSIS
    Pure predicates of the release-commit allowance leg of the preimplementation gate (issue #1201).

.DESCRIPTION
    Dot-sourced, guarded, by enforce-orchestration-preimplementation-gate-release.ps1, which holds
    the I/O seams and the leg entry. This file reads no file, starts no process, and reads no
    environment state. It parses the destination-owned allowance file
    .claude/release-commit-allowance.json (schema version 1), matches branch patterns, classifies
    the git add and git commit segments of a command line, and decides one line against the
    parsed allowances.

    Allowance file rules (the first failing rule wins; keys are compared ordinally):
      - The text parses as JSON and the root is an object with exactly the keys schema_version and
        allowances; schema_version is the integer 1.
      - allowances is a non-empty array of objects with exactly the keys id, branch_patterns, and
        allowed_paths; id is a non-blank string, unique across allowances.
      - branch_patterns is a non-empty array of non-empty strings matching ^[A-Za-z0-9._/*?-]+$.
      - allowed_paths is a non-empty array of strings matching
        ^[A-Za-z0-9._-]+(/[A-Za-z0-9._-]+)*$ with no '.' or '..' segment, no glob character, no
        leading or trailing '/', no drive letter, no backslash, and no duplicate in the allowance.
        Whether an entry is a directory is checked by the leg entry through its container seam.

    Command rules (decision order of Get-ReleaseAllowanceCommandDecision; the first failure wins):
      6  the whole line is resolvable and balanced, every segment is a modelled git add or git
         commit, and at most one segment is a git commit (RELEASE_ALLOWANCE_COMMAND_NOT_MODELLED);
      7  the HEAD branch matches a pattern of at least one allowance
         (RELEASE_ALLOWANCE_BRANCH_NOT_MATCHED);
      8  per segment: the only global option is -C <the target worktree root>; git add takes no
         option before '--' and at least one operand; git commit takes only -m, --message, -F,
         --file (separate or '=' value) and -s, --signoff, and no pathspec
         (RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED, RELEASE_ALLOWANCE_PATH_NOT_ALLOWED);
      9  with a commit segment, the staged index is read once; the evaluated set is the ordered
         union of the staged names and the operands of every git add segment before the commit
         (RELEASE_ALLOWANCE_STAGED_INDEX_UNREADABLE, RELEASE_ALLOWANCE_STAGED_INDEX_EMPTY);
      10 one candidate allowance, in file order, must list every git add operand and every member
         of the evaluated set (RELEASE_ALLOWANCE_PATH_NOT_ALLOWED,
         RELEASE_ALLOWANCE_STAGED_PATH_NOT_ALLOWED); otherwise the first candidate's failure is
         reported.

.NOTES
    PowerShell 7+. Byte-identical at .claude/hooks, .codex/hooks, and both bundle mirrors under
    extensions/drm-copilot/resources/. Script-scope names use the prefix ReleaseAllowance, because
    the PreToolUse dispatcher dot-sources many hooks into one process. Call-time dependencies loaded
    by the gate: Split-OrchestrationCommandLine, ConvertTo-OrchestrationCommandToken, and
    Test-OrchestrationCommandTextUnresolvable (helpers sibling); ConvertTo-OrchestrationCleanupComparablePath
    (cleanup sibling); ConvertFrom-DocsOnlyNameList (hook-docs-only-diff.ps1); and
    Test-CommandLineTokenLiteral (hook-command-invocation.ps1). This hook file starts no
    interpreter process. A policy-level control, not a security control.
#>

$script:ReleaseAllowanceRootKeys = @('schema_version', 'allowances')
$script:ReleaseAllowanceEntryKeys = @('id', 'branch_patterns', 'allowed_paths')
$script:ReleaseAllowanceBranchPatternRule = '^[A-Za-z0-9._/*?-]+$'
$script:ReleaseAllowancePathRule = '^[A-Za-z0-9._-]+(/[A-Za-z0-9._-]+)*$'
$script:ReleaseAllowanceSeparateValueGlobalOptions = @('-C', '-c', '--git-dir', '--work-tree', '--namespace', '--config-env')
$script:ReleaseAllowanceCommitValueOptions = @('-m', '--message', '-F', '--file')
$script:ReleaseAllowanceCommitFlagOptions = @('-s', '--signoff')

function Get-ReleaseAllowanceInvalidConfigResult {
    <#
    .SYNOPSIS
        Return the parser result for an invalid allowance file.
    .PARAMETER Detail
        The first failed rule, naming the offending key or entry.
    .OUTPUTS
        System.Management.Automation.PSCustomObject
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory)][string] $Detail)

    return [pscustomobject]@{ Valid = $false; Allowances = @(); Detail = $Detail }
}

function Get-ReleaseAllowanceShapeResult {
    <#
    .SYNOPSIS
        Return a segment shape result: Kind (add, commit, or other), Paths (the git add operands),
        and Code and Detail ('' when the segment passes).
    .OUTPUTS
        System.Management.Automation.PSCustomObject
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([string] $Kind, [AllowEmptyCollection()][string[]] $Paths = @(), [string] $Code = '', [string] $Detail = '')

    return [pscustomobject]@{ Kind = $Kind; Paths = [string[]]@($Paths); Code = $Code; Detail = $Detail }
}

function Get-ReleaseAllowanceDenialResult {
    <#
    .SYNOPSIS
        Return a decision result that denies with RELEASE_ALLOWANCE_<Code> and a detail.
    .PARAMETER Code
        The code without the RELEASE_ALLOWANCE_ prefix.
    .PARAMETER Detail
        The detail of the failure.
    .OUTPUTS
        System.Management.Automation.PSCustomObject
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory)][string] $Code, [Parameter(Mandatory)][string] $Detail)

    return [pscustomobject]@{ Allowed = $false; Code = "RELEASE_ALLOWANCE_$Code"; Detail = $Detail }
}

function Get-ReleaseAllowanceStringListError {
    <#
    .SYNOPSIS
        Return the detail of the first rule a branch_patterns or allowed_paths value breaks, or ''.
    .PARAMETER Value
        The JSON value of the key.
    .PARAMETER Key
        The key name, branch_patterns or allowed_paths.
    .PARAMETER Position
        The position of the allowance in the allowances array.
    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([AllowNull()][object] $Value, [Parameter(Mandatory)][string] $Key, [int] $Position)

    if ($Value -isnot [array]) { return "allowances entry $Position $Key is not an array" }
    if (@($Value).Count -eq 0) { return "allowances entry $Position $Key is empty" }
    $seen = [System.Collections.Generic.List[string]]::new()
    $index = 0
    foreach ($entry in $Value) {
        if ($entry -isnot [string]) { return "allowances entry $Position $Key element $index is not a string" }
        $detail = if ($Key -ceq 'branch_patterns') { Get-ReleaseAllowanceBranchPatternError -Pattern $entry } else { Get-ReleaseAllowancePathError -Path $entry -Seen $seen.ToArray() }
        if ($detail) { return $detail }
        $seen.Add($entry)
        $index++
    }
    return ''
}

function Get-ReleaseAllowanceBranchPatternError {
    <#
    .SYNOPSIS
        Return the detail of the first rule a branch pattern breaks, or ''.
    .PARAMETER Pattern
        The branch pattern.
    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([AllowEmptyString()][string] $Pattern)

    if ($Pattern.Length -eq 0) { return "branch_patterns entry '' is empty" }
    if ($Pattern -cnotmatch $script:ReleaseAllowanceBranchPatternRule) { return "branch_patterns entry '$Pattern' contains a character outside A-Z a-z 0-9 . _ / * ? -" }
    return ''
}

function Get-ReleaseAllowancePathError {
    <#
    .SYNOPSIS
        Return the detail of the first rule an allowed_paths entry breaks, or ''.
    .PARAMETER Path
        The allowed_paths entry.
    .PARAMETER Seen
        The earlier entries of the same allowance.
    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([AllowEmptyString()][string] $Path, [AllowEmptyCollection()][string[]] $Seen = @())

    $label = "allowed_paths entry '$Path'"
    if ($Path.Length -eq 0) { return "$label is empty" }
    if ($Path.Contains('\')) { return "$label contains a backslash" }
    if ($Path -match '^[A-Za-z]:') { return "$label has a drive letter" }
    if ($Path.IndexOfAny([char[]]@('*', '?', '[', ']')) -ge 0) { return "$label contains a glob character" }
    if ($Path.StartsWith('/', [System.StringComparison]::Ordinal)) { return "$label has a leading slash" }
    if ($Path.EndsWith('/', [System.StringComparison]::Ordinal)) { return "$label has a trailing slash" }
    if (@($Path.Split('/') | Where-Object { $_ -ceq '.' -or $_ -ceq '..' }).Count -gt 0) { return "$label has a . or .. segment" }
    if ($Path -cnotmatch $script:ReleaseAllowancePathRule) { return "$label contains a character outside A-Z a-z 0-9 . _ - /" }
    if ($Seen -ccontains $Path) { return "$label duplicates an earlier entry" }
    return ''
}

function ConvertFrom-ReleaseAllowanceConfig {
    <#
    .SYNOPSIS
        Parse and validate the release-commit allowance file text.
    .DESCRIPTION
        Returns Valid, Allowances (objects with Id, BranchPatterns, and AllowedPaths), and Detail,
        which names the offending key or entry of the first failed rule of the file header.
    .PARAMETER Text
        The allowance file text.
    .OUTPUTS
        System.Management.Automation.PSCustomObject
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([AllowNull()][AllowEmptyString()][string] $Text)

    try {
        $document = ConvertFrom-Json -InputObject $Text -NoEnumerate -ErrorAction Stop
    } catch {
        return (Get-ReleaseAllowanceInvalidConfigResult -Detail 'the file is not valid JSON')
    }
    if ($document -isnot [System.Management.Automation.PSCustomObject]) { return (Get-ReleaseAllowanceInvalidConfigResult -Detail 'the document is not a JSON object') }
    $names = @($document.PSObject.Properties.Name)
    $unknown = @($names | Where-Object { $script:ReleaseAllowanceRootKeys -cnotcontains $_ })
    $missing = @($script:ReleaseAllowanceRootKeys | Where-Object { $names -cnotcontains $_ })
    if ($unknown.Count -gt 0) { return (Get-ReleaseAllowanceInvalidConfigResult -Detail "unknown top-level key '$($unknown[0])'") }
    if ($missing.Count -gt 0) { return (Get-ReleaseAllowanceInvalidConfigResult -Detail "missing top-level key '$($missing[0])'") }
    $version = $document.schema_version
    if (-not ($version -is [int] -or $version -is [long]) -or $version -ne 1) { return (Get-ReleaseAllowanceInvalidConfigResult -Detail 'schema_version is not the integer 1') }
    if ($document.allowances -isnot [array]) { return (Get-ReleaseAllowanceInvalidConfigResult -Detail 'allowances is not an array') }
    if (@($document.allowances).Count -eq 0) { return (Get-ReleaseAllowanceInvalidConfigResult -Detail 'allowances is empty') }

    $allowances = [System.Collections.Generic.List[object]]::new()
    $ids = [System.Collections.Generic.List[string]]::new()
    $position = 0
    foreach ($entry in $document.allowances) {
        if ($entry -isnot [System.Management.Automation.PSCustomObject]) { return (Get-ReleaseAllowanceInvalidConfigResult -Detail "allowances entry $position is not an object") }
        $entryNames = @($entry.PSObject.Properties.Name)
        $entryUnknown = @($entryNames | Where-Object { $script:ReleaseAllowanceEntryKeys -cnotcontains $_ })
        $entryMissing = @($script:ReleaseAllowanceEntryKeys | Where-Object { $entryNames -cnotcontains $_ })
        if ($entryUnknown.Count -gt 0) { return (Get-ReleaseAllowanceInvalidConfigResult -Detail "allowances entry $position has unknown key '$($entryUnknown[0])'") }
        if ($entryMissing.Count -gt 0) { return (Get-ReleaseAllowanceInvalidConfigResult -Detail "allowances entry $position is missing key '$($entryMissing[0])'") }
        if ($entry.id -isnot [string]) { return (Get-ReleaseAllowanceInvalidConfigResult -Detail "allowances entry $position id is not a string") }
        if ([string]::IsNullOrWhiteSpace($entry.id)) { return (Get-ReleaseAllowanceInvalidConfigResult -Detail "allowances entry $position id is empty") }
        if ($ids -ccontains $entry.id) { return (Get-ReleaseAllowanceInvalidConfigResult -Detail "allowances entry $position id '$($entry.id)' duplicates an earlier id") }
        foreach ($key in 'branch_patterns', 'allowed_paths') {
            $detail = Get-ReleaseAllowanceStringListError -Value $entry.$key -Key $key -Position $position
            if ($detail) { return (Get-ReleaseAllowanceInvalidConfigResult -Detail $detail) }
        }
        $ids.Add($entry.id)
        $allowances.Add([pscustomobject]@{ Id = [string]$entry.id; BranchPatterns = [string[]]@($entry.branch_patterns); AllowedPaths = [string[]]@($entry.allowed_paths) })
        $position++
    }
    return [pscustomobject]@{ Valid = $true; Allowances = $allowances.ToArray(); Detail = '' }
}

function Test-ReleaseAllowanceBranchMatch {
    <#
    .SYNOPSIS
        Report whether a branch name matches a pattern as a whole, case-sensitively.
    .PARAMETER Branch
        The HEAD branch name.
    .PARAMETER Pattern
        The branch pattern (* and ? wildcards).
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()][AllowEmptyString()][string] $Branch, [AllowNull()][AllowEmptyString()][string] $Pattern)

    if ([string]::IsNullOrEmpty($Branch) -or [string]::IsNullOrEmpty($Pattern)) { return $false }
    return [System.Management.Automation.WildcardPattern]::new($Pattern, [System.Management.Automation.WildcardOptions]::None).IsMatch($Branch)
}

function Get-ReleaseAllowanceSubcommandIndex {
    <#
    .SYNOPSIS
        Return the index of the first token after the git global options, or the token count.
    .DESCRIPTION
        Skips every token that begins with '-' and, for -C, -c, --git-dir, --work-tree,
        --namespace, and --config-env, the separate value token after it.
    .PARAMETER Token
        The segment tokens; Token[0] is git.
    .OUTPUTS
        System.Int32
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param([Parameter(Mandatory)][AllowEmptyCollection()][AllowEmptyString()][string[]] $Token)

    $index = 1
    while ($index -lt $Token.Count -and $Token[$index].StartsWith('-', [System.StringComparison]::Ordinal)) {
        if ($script:ReleaseAllowanceSeparateValueGlobalOptions -ccontains $Token[$index]) { $index++ }
        $index++
    }
    return [Math]::Min($index, $Token.Count)
}

function Test-ReleaseAllowanceCommandRelevant {
    <#
    .SYNOPSIS
        Report whether any segment of a command line is git add or git commit (decision AD-3).
    .DESCRIPTION
        Every segment of Split-OrchestrationCommandLine is read, whether or not the line is
        balanced; the first non-option token after git and its global options is compared.
    .PARAMETER Command
        The command line.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()][AllowEmptyString()][string] $Command)

    if ([string]::IsNullOrWhiteSpace($Command)) { return $false }
    foreach ($segment in @((Split-OrchestrationCommandLine -CommandText $Command).Segments)) {
        $tokens = [string[]]@(ConvertTo-OrchestrationCommandToken -Segment $segment.Trim())
        if ($tokens.Count -lt 2 -or $tokens[0] -cne 'git') { continue }
        $index = Get-ReleaseAllowanceSubcommandIndex -Token $tokens
        if ($index -lt $tokens.Count -and ($tokens[$index] -ceq 'add' -or $tokens[$index] -ceq 'commit')) { return $true }
    }
    return $false
}

function Get-ReleaseAllowanceGlobalOptionFailure {
    <#
    .SYNOPSIS
        Return the detail of the first global option that is not -C <worktree root>, or ''.
    .PARAMETER Token
        The segment tokens.
    .PARAMETER SubcommandIndex
        The index of the subcommand token.
    .PARAMETER WorktreeRoot
        The target worktree root R.
    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][AllowEmptyCollection()][AllowEmptyString()][string[]] $Token, [int] $SubcommandIndex, [AllowNull()][AllowEmptyString()][string] $WorktreeRoot)

    $index = 1
    while ($index -lt $SubcommandIndex) {
        $option = $Token[$index]
        if ($option -cne '-C') { return "git global option '$option' is not allowed" }
        $value = $Token[$index + 1]
        $comparable = ConvertTo-OrchestrationCleanupComparablePath -Path $value
        $isAbsolute = $comparable -match '^([A-Za-z]:/|/(?!/))'
        $root = ConvertTo-OrchestrationCleanupComparablePath -Path $WorktreeRoot
        if (-not $isAbsolute -or [string]::IsNullOrEmpty($WorktreeRoot) -or -not (Test-CommandLineTokenLiteral -Token $value) -or
            -not [string]::Equals($comparable, $root, [System.StringComparison]::OrdinalIgnoreCase)) {
            return "-C '$value' is not the target worktree root"
        }
        $index += 2
    }
    return ''
}

function Get-ReleaseAllowanceSegmentShape {
    <#
    .SYNOPSIS
        Classify one segment as git add, git commit, or other, and report its first option or path failure.
    .DESCRIPTION
        Returns Kind (add, commit, or other), Paths (the git add operands), Code, and Detail. Code
        is empty when the segment passes the step 8 checks of the file header. A segment whose
        global options consume every token (for example a bare git -C) is of kind other and
        reports RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED.
    .PARAMETER Token
        The segment tokens.
    .PARAMETER WorktreeRoot
        The target worktree root R that a -C value must equal.
    .OUTPUTS
        System.Management.Automation.PSCustomObject
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory)][AllowEmptyCollection()][AllowEmptyString()][string[]] $Token, [AllowNull()][AllowEmptyString()][string] $WorktreeRoot)

    $optionCode = 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED'
    $pathCode = 'RELEASE_ALLOWANCE_PATH_NOT_ALLOWED'
    if ($Token.Count -lt 2 -or $Token[0] -cne 'git') { return (Get-ReleaseAllowanceShapeResult -Kind 'other') }
    $index = Get-ReleaseAllowanceSubcommandIndex -Token $Token
    if ($index -ge $Token.Count) {
        $last = $Token[$Token.Count - 1]
        if ($script:ReleaseAllowanceSeparateValueGlobalOptions -ccontains $last) { return (Get-ReleaseAllowanceShapeResult -Kind 'other' -Code $optionCode -Detail "git global option '$last' is not allowed") }
        return (Get-ReleaseAllowanceShapeResult -Kind 'other')
    }
    $kind = $Token[$index]
    if ($kind -cne 'add' -and $kind -cne 'commit') { return (Get-ReleaseAllowanceShapeResult -Kind 'other') }
    $globalDetail = Get-ReleaseAllowanceGlobalOptionFailure -Token $Token -SubcommandIndex $index -WorktreeRoot $WorktreeRoot
    if ($globalDetail) { return (Get-ReleaseAllowanceShapeResult -Kind $kind -Code $optionCode -Detail $globalDetail) }
    # Assigned outside an if expression, which would unroll a one-element array into a string.
    [string[]] $rest = @()
    if ($index + 1 -lt $Token.Count) { $rest = [string[]]@($Token[($index + 1)..($Token.Count - 1)]) }
    if ($kind -ceq 'add') {
        $paths = [System.Collections.Generic.List[string]]::new()
        $separated = $false
        foreach ($item in $rest) {
            if (-not $separated -and $item.StartsWith('-', [System.StringComparison]::Ordinal)) {
                if ($item -ceq '--' -and $paths.Count -eq 0) { $separated = $true; continue }
                return (Get-ReleaseAllowanceShapeResult -Kind 'add' -Paths $paths.ToArray() -Code $optionCode -Detail "option '$item' is not allowed for git add")
            }
            $paths.Add($item)
        }
        if ($paths.Count -eq 0) { return (Get-ReleaseAllowanceShapeResult -Kind 'add' -Code $pathCode -Detail 'git add has no path operand') }
        return (Get-ReleaseAllowanceShapeResult -Kind 'add' -Paths $paths.ToArray())
    }
    $position = 0
    while ($position -lt $rest.Count) {
        $item = $rest[$position]
        if ($script:ReleaseAllowanceCommitValueOptions -ccontains $item) {
            if ($position + 1 -ge $rest.Count) { return (Get-ReleaseAllowanceShapeResult -Kind 'commit' -Code $optionCode -Detail "option '$item' is not allowed for git commit") }
            $position += 2
            continue
        }
        $isAttached = $item.StartsWith('--message=', [System.StringComparison]::Ordinal) -or $item.StartsWith('--file=', [System.StringComparison]::Ordinal)
        if ($isAttached -or $script:ReleaseAllowanceCommitFlagOptions -ccontains $item) { $position++; continue }
        if ($item -ceq '--' -or -not $item.StartsWith('-', [System.StringComparison]::Ordinal)) { return (Get-ReleaseAllowanceShapeResult -Kind 'commit' -Code $pathCode -Detail "git commit pathspec '$item' is not allowed") }
        return (Get-ReleaseAllowanceShapeResult -Kind 'commit' -Code $optionCode -Detail "option '$item' is not allowed for git commit")
    }
    return (Get-ReleaseAllowanceShapeResult -Kind 'commit')
}

function Get-ReleaseAllowanceCommandDecision {
    <#
    .SYNOPSIS
        Decide one command line against the parsed allowances (steps 6 to 10 of the file header).
    .DESCRIPTION
        Returns Allowed, Code, and Detail. The branch is read only after the whole-line check, and
        the staged index is read at most once and only when the line has a git commit segment.
    .PARAMETER Command
        The command line.
    .PARAMETER WorktreeRoot
        The target worktree root R.
    .PARAMETER Branch
        The HEAD branch reader: a scriptblock called once with the worktree root, only after the
        whole-line check, that returns the branch name or $null for a detached or unreadable HEAD.
    .PARAMETER Allowances
        The Allowances of ConvertFrom-ReleaseAllowanceConfig.
    .PARAMETER StagedReader
        A scriptblock called with the worktree root that returns ExitCode and Output (NUL-terminated names).
    .OUTPUTS
        System.Management.Automation.PSCustomObject
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowNull()][AllowEmptyString()][string] $Command,
        [AllowNull()][AllowEmptyString()][string] $WorktreeRoot,
        [Parameter(Mandatory)][scriptblock] $Branch,
        [AllowNull()][AllowEmptyCollection()][object[]] $Allowances,
        [Parameter(Mandatory)][scriptblock] $StagedReader
    )

    if (Test-OrchestrationCommandTextUnresolvable -CommandText ([string]$Command)) { return (Get-ReleaseAllowanceDenialResult 'COMMAND_NOT_MODELLED' 'the command text is not resolvable') }
    $split = Split-OrchestrationCommandLine -CommandText ([string]$Command)
    if (-not $split.Balanced) { return (Get-ReleaseAllowanceDenialResult 'COMMAND_NOT_MODELLED' 'the command line is not balanced') }
    $shapes = [System.Collections.Generic.List[object]]::new()
    foreach ($segment in @($split.Segments)) {
        $trimmed = $segment.Trim()
        $tokens = [string[]]@(ConvertTo-OrchestrationCommandToken -Segment $trimmed)
        $shape = Get-ReleaseAllowanceSegmentShape -Token $tokens -WorktreeRoot $WorktreeRoot
        if ($shape.Kind -ceq 'other') { return (Get-ReleaseAllowanceDenialResult 'COMMAND_NOT_MODELLED' "segment '$trimmed' is not a modelled git add or git commit") }
        $shapes.Add($shape)
    }
    if (@($shapes | Where-Object { $_.Kind -ceq 'commit' }).Count -gt 1) { return (Get-ReleaseAllowanceDenialResult 'COMMAND_NOT_MODELLED' 'the command line has more than one git commit segment') }

    $branchName = & $Branch $WorktreeRoot
    if ([string]::IsNullOrEmpty([string]$branchName)) { return (Get-ReleaseAllowanceDenialResult 'BRANCH_NOT_MATCHED' 'HEAD is detached or unreadable') }
    $candidates = @(@($Allowances) | Where-Object { $allowance = $_; @($allowance.BranchPatterns | Where-Object { Test-ReleaseAllowanceBranchMatch -Branch ([string]$branchName) -Pattern $_ }).Count -gt 0 })
    if ($candidates.Count -eq 0) { return (Get-ReleaseAllowanceDenialResult 'BRANCH_NOT_MATCHED' "branch '$branchName' matches no allowance") }

    foreach ($shape in $shapes) {
        if ($shape.Code) { return [pscustomobject]@{ Allowed = $false; Code = $shape.Code; Detail = $shape.Detail } }
    }

    $addOperands = [System.Collections.Generic.List[string]]::new()
    $evaluated = [System.Collections.Generic.List[string]]::new()
    $hasCommit = $false
    foreach ($shape in $shapes) {
        if ($shape.Kind -ceq 'add') { foreach ($path in $shape.Paths) { $addOperands.Add($path) } }
        if ($shape.Kind -ceq 'commit') {
            $hasCommit = $true
            $staged = & $StagedReader $WorktreeRoot
            if ($null -eq $staged -or $staged.ExitCode -ne 0 -or (-not [string]::IsNullOrEmpty([string]$staged.Output) -and -not ([string]$staged.Output).EndsWith([string][char]0, [System.StringComparison]::Ordinal))) {
                return (Get-ReleaseAllowanceDenialResult 'STAGED_INDEX_UNREADABLE' 'the staged index could not be read')
            }
            foreach ($name in @(@(ConvertFrom-DocsOnlyNameList -Text ([string]$staged.Output)) + $addOperands.ToArray())) {
                if ($evaluated -cnotcontains $name) { $evaluated.Add($name) }
            }
            if ($evaluated.Count -eq 0) { return (Get-ReleaseAllowanceDenialResult 'STAGED_INDEX_EMPTY' 'nothing is staged for the commit') }
        }
    }

    $firstFailure = $null
    foreach ($candidate in $candidates) {
        $allowed = [string[]]@($candidate.AllowedPaths)
        $failure = $null
        $operand = @($addOperands | Where-Object { $allowed -cnotcontains $_ } | Select-Object -First 1)
        if ($operand.Count -gt 0) { $failure = Get-ReleaseAllowanceDenialResult 'PATH_NOT_ALLOWED' "operand '$($operand[0])' is not an allowed path" }
        elseif ($hasCommit) {
            $member = @($evaluated | Where-Object { $allowed -cnotcontains $_ } | Select-Object -First 1)
            if ($member.Count -gt 0) { $failure = Get-ReleaseAllowanceDenialResult 'STAGED_PATH_NOT_ALLOWED' "staged path '$($member[0])' is not an allowed path" }
        }
        if ($null -eq $failure) { return [pscustomobject]@{ Allowed = $true; Code = ''; Detail = '' } }
        if ($null -eq $firstFailure) { $firstFailure = $failure }
    }
    return $firstFailure
}
