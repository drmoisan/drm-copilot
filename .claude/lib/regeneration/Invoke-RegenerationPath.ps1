<#
.SYNOPSIS
    Entry point of the regenerate path (issue #1156).

.DESCRIPTION
    Thin I/O adapter over the pure regeneration modules. Modes:
      - Merge: merges -MergeRef without committing, classifies the both-sides
        changed paths, runs the declared regeneration command twice, and verifies
        confinement, idempotency, the staged delta, and the optional unit gate.
        Every failure aborts the merge.
      - Tip: runs the declared command twice on a clean integration tip and
        restores the worktree on a not-applied result. Nothing is staged.
      - Validate: reads and validates the config only.

    Prints exactly one JSON object on stdout and exits 0 (prepared, applied, or
    valid), 3 (fall back, not applied, or not valid), 1 (git or process failure),
    or 2 (usage error). The result values follow the normative result table of the
    issue #1156 specification.

    Every git, process, file, and clock access goes through
    Invoke-RegenerationGitExe, Invoke-RegenerationProcess,
    Read-RegenerationConfigText, and the -UtcNow scriptblock; each seam default is
    the only code that touches the system. Dot-sourcing the script defines the
    functions without running the body.

.PARAMETER Mode
    Merge, Tip, or Validate (ordinal, case-sensitive).

.PARAMETER MergeRef
    Remote-tracking ref to merge (Merge only).

.PARAMETER Trigger
    integration_sync or main_sync (Merge only).

.PARAMETER ConfigPath
    Relative config path; default config/orchestration-regeneration.json.
#>
[CmdletBinding()]
param(
    [string] $Mode,
    [string] $MergeRef,
    [string] $Trigger,
    [string] $ConfigPath
)

function Read-RegenerationConfigText {
    <#
    .SYNOPSIS
        Return the config file text, or $null when the file is absent.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [string] $ConfigPath,
        [scriptblock] $TestPath = { param($Path) Test-Path -LiteralPath $Path },
        [scriptblock] $ReadText = { param($Path) Get-Content -LiteralPath $Path -Raw }
    )

    if (-not (& $TestPath $ConfigPath)) { return $null }
    return (& $ReadText $ConfigPath)
}

function Invoke-RegenerationGitExe {
    <#
    .SYNOPSIS
        Run one git command and return its exit code and LF-joined stdout.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [string[]] $GitArgs,
        [scriptblock] $Invoker = {
            param($GitArgs)
            $lines = @(git @GitArgs)
            [pscustomobject]@{ ExitCode = $LASTEXITCODE; Lines = $lines }
        }
    )

    $returned = @(& $Invoker -GitArgs $GitArgs)
    if ($returned.Count -ne 1) { throw "git invoker returned $($returned.Count) objects; expected one" }
    $names = @($returned[0].PSObject.Properties.Name)
    if ($names -cnotcontains 'ExitCode' -or $names -cnotcontains 'Lines') {
        throw 'git invoker result lacks ExitCode or Lines'
    }
    $output = (@($returned[0].Lines) | ForEach-Object { [string] $_ }) -join "`n"
    return [pscustomobject]@{ ExitCode = [int] $returned[0].ExitCode; Output = [string] $output }
}

function Invoke-RegenerationProcess {
    <#
    .SYNOPSIS
        Run one argv with no shell and return its exit code; a start failure throws.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $Argv,
        [scriptblock] $Invoker = {
            param($FilePath, $ArgumentList)
            $info = [System.Diagnostics.ProcessStartInfo]::new([string] $FilePath)
            foreach ($item in $ArgumentList) { $info.ArgumentList.Add([string] $item) }
            $info.UseShellExecute = $false
            $info.RedirectStandardOutput = $true
            $info.RedirectStandardError = $true
            $process = [System.Diagnostics.Process]::Start($info)
            if ($null -eq $process) { throw "process $FilePath was not started" }
            try {
                $stdout = $process.StandardOutput.ReadToEndAsync()
                $stderr = $process.StandardError.ReadToEndAsync()
                $process.WaitForExit()
                [Console]::Error.WriteLine($stdout.Result)
                [Console]::Error.WriteLine($stderr.Result)
                [int] $process.ExitCode
            }
            finally { $process.Dispose() }
        }
    )

    if ($Argv.Count -eq 0) { throw 'process argv is empty' }
    $rest = [string[]] @($Argv | Select-Object -Skip 1)
    $returned = @(& $Invoker -FilePath $Argv[0] -ArgumentList $rest)
    if ($returned.Count -ne 1 -or $returned[0] -isnot [int]) {
        throw 'process invoker must return exactly one integer exit code'
    }
    return [int] $returned[0]
}

function New-RegenerationResult {
    <#
    .SYNOPSIS
        Build the twenty-key entry-point result; defaults equal the usage-row cells.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory builder that changes no system state.')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidAssignmentToAutomaticVariable', 'Event', Justification = 'The parameter name mirrors the result key event that spec D17 fixes; it is a function parameter, not the automatic variable of an event action.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [AllowNull()] [object] $Mode = $null,
        [AllowNull()] [object] $Trigger = $null,
        [AllowNull()] [object] $Decision = $null,
        [AllowNull()] [object] $Reason = $null,
        [AllowEmptyCollection()] [object[]] $UnmatchedPaths = @(),
        [AllowEmptyCollection()] [object[]] $ConfigErrors = @(),
        [AllowNull()] [object] $FeatureHeadSha = $null,
        [AllowNull()] [object] $MergeHeadSha = $null,
        [AllowNull()] [object] $MergeBaseSha = $null,
        [AllowNull()] [object] $CommandExitCode = $null,
        [AllowNull()] [object] $Confined = $null,
        [AllowNull()] [object] $Idempotent = $null,
        [AllowNull()] [object] $UnitGate = 'not_run',
        [AllowNull()] [object] $DeltaCheck = 'not_run',
        [AllowEmptyCollection()] [object[]] $ChangedPaths = @(),
        [AllowNull()] [object] $Outcome = 'usage_error',
        [AllowNull()] [object] $At = $null,
        [AllowNull()] [object] $Event = $null,
        [AllowNull()] [object] $ReviewOutcome = $null,
        [AllowNull()] [object] $EvidenceText = $null
    )

    return [ordered]@{
        mode              = $Mode
        trigger           = $Trigger
        decision          = $Decision
        reason            = $Reason
        unmatched_paths   = [object[]] @($UnmatchedPaths)
        config_errors     = [object[]] @($ConfigErrors)
        feature_head_sha  = $FeatureHeadSha
        merge_head_sha    = $MergeHeadSha
        merge_base_sha    = $MergeBaseSha
        command_exit_code = $CommandExitCode
        confined          = $Confined
        idempotent        = $Idempotent
        unit_gate         = $UnitGate
        delta_check       = $DeltaCheck
        changed_paths     = [object[]] @($ChangedPaths)
        outcome           = $Outcome
        at                = $At
        event             = $Event
        review_outcome    = $ReviewOutcome
        evidence_text     = $EvidenceText
    }
}

function ConvertTo-RegenerationResultJson {
    <#
    .SYNOPSIS
        Serialize a result as one compressed JSON line that keeps null values.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Result)

    return (ConvertTo-Json -InputObject $Result -Depth 10 -Compress)
}

function Test-RegenerationUsageError {
    <#
    .SYNOPSIS
        Report whether the arguments violate the entry-point usage rules.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()] [AllowEmptyString()] [string] $Mode,
        [AllowNull()] [AllowEmptyString()] [string] $MergeRef,
        [AllowNull()] [AllowEmptyString()] [string] $Trigger,
        [AllowNull()] [AllowEmptyString()] [string] $ConfigPath
    )

    if ([string]::IsNullOrEmpty($Mode)) { return $true }
    $hasMergeRef = -not [string]::IsNullOrEmpty($MergeRef)
    $hasTrigger = -not [string]::IsNullOrEmpty($Trigger)
    if ($Mode -ceq 'Merge') {
        if (-not $hasMergeRef -or -not $hasTrigger) { return $true }
        if (@('integration_sync', 'main_sync') -cnotcontains $Trigger) { return $true }
    }
    elseif ($hasMergeRef -or $hasTrigger) { return $true }
    if ($ConfigPath.StartsWith('/') -or $ConfigPath -match '^[A-Za-z]:') { return $true }
    return (@($ConfigPath -split '[\\/]') -ccontains '..')
}

function Get-RegenerationConfigStage {
    <#
    .SYNOPSIS
        Parse the config text and name the config-stage reason, or $null for a valid config.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyString()] [object] $Text)

    $parsed = ConvertFrom-RegenerationConfigText -Text $Text
    $reason = $null
    if (@($parsed.Errors).Count -gt 0) { $reason = 'config_invalid' }
    elseif ($null -eq $parsed.Config) { $reason = 'no_config' }
    return [pscustomobject]@{ Config = $parsed.Config; Errors = [object[]] @($parsed.Errors); Reason = $reason }
}

function Invoke-RegenerationPathCommand {
    <#
    .SYNOPSIS
        Run one entry-point invocation and return { ExitCode, Result }.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [string] $Mode,
        [string] $MergeRef,
        [string] $Trigger,
        [string] $ConfigPath = 'config/orchestration-regeneration.json',
        [scriptblock] $UtcNow = { [datetime]::UtcNow }
    )

    $configPathSupplied = $PSBoundParameters.ContainsKey('ConfigPath')
    if ([string]::IsNullOrEmpty($ConfigPath)) {
        $ConfigPath = 'config/orchestration-regeneration.json'
        $configPathSupplied = $false
    }
    $canonical = $null
    if (@('Merge', 'Tip', 'Validate') -ccontains $Mode) { $canonical = $Mode }
    if (Test-RegenerationUsageError -Mode $canonical -MergeRef $MergeRef -Trigger $Trigger -ConfigPath $ConfigPath) {
        return [pscustomobject]@{ ExitCode = 2; Result = (New-RegenerationResult -Mode $canonical) }
    }

    $text = Read-RegenerationConfigText -ConfigPath $ConfigPath
    $now = & $UtcNow
    $at = ConvertTo-RegenerationIsoUtc -Value $now
    $stage = Get-RegenerationConfigStage -Text $text
    $context = @{
        MergeRef = $MergeRef; Trigger = $Trigger; At = $at; Stage = $stage
        Stamp                = (ConvertTo-RegenerationStamp -Value $now)
        InvocationConfigPath = $(if ($configPathSupplied) { $ConfigPath } else { $null })
    }

    if ($canonical -ceq 'Validate') {
        if ($null -ne $stage.Reason) {
            $result = New-RegenerationResult -Mode 'Validate' -Reason $stage.Reason -ConfigErrors $stage.Errors -Outcome 'not_valid' -At $at
            return [pscustomobject]@{ ExitCode = 3; Result = $result }
        }
        return [pscustomobject]@{ ExitCode = 0; Result = (New-RegenerationResult -Mode 'Validate' -Outcome 'valid' -At $at) }
    }
    if ($canonical -ceq 'Tip') { return (Invoke-RegenerationTipMode -Context $context) }
    return (Invoke-RegenerationMergeMode -Context $context)
}

function Invoke-RegenerationTipMode {
    <#
    .SYNOPSIS
        Produce the Tip-mode result for a parsed config stage.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)] [hashtable] $Context)

    $stage = $Context.Stage
    if ($null -ne $stage.Reason) {
        $result = New-RegenerationResult -Mode 'Tip' -Reason $stage.Reason -ConfigErrors $stage.Errors -Outcome 'not_applied' -At $Context.At
        return [pscustomobject]@{ ExitCode = 3; Result = $result }
    }
    $state = New-RegenerationMergeState
    $state.restore = $false
    $exitCode = Invoke-RegenerationTipFlow -Config $stage.Config -State $state
    if ($state.restore -and -not (Invoke-RegenerationTipRestore)) { $exitCode = 1 }
    $outcome = if ($exitCode -eq 0) { 'applied' } else { 'not_applied' }
    $result = New-RegenerationResult -Mode 'Tip' -CommandExitCode $state.command_exit_code -Confined $state.confined `
        -Idempotent $state.idempotent -ChangedPaths $state.changed_paths -Outcome $outcome -At $Context.At
    return [pscustomobject]@{ ExitCode = $exitCode; Result = $result }
}

function Get-RegenerationTipSnapshot {
    <#
    .SYNOPSIS
        List the worktree changes and the blob id of each changed path, or ExitCode 1.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param()

    $change = Get-RegenerationWorktreeChange
    if ($change.ExitCode -ne 0) { return [pscustomobject]@{ ExitCode = 1; Path = [string[]] @(); Blob = @{} } }
    $blob = [ordered]@{}
    foreach ($path in $change.Path) {
        $step = Invoke-RegenerationGitStep -GitArgs @('hash-object', '--', $path)
        if ($step.ExitCode -ne 0) { return [pscustomobject]@{ ExitCode = 1; Path = $change.Path; Blob = $blob } }
        $blob[$path] = $step.Output.Trim()
    }
    return [pscustomobject]@{ ExitCode = 0; Path = $change.Path; Blob = $blob }
}

function Invoke-RegenerationTipFlow {
    <#
    .SYNOPSIS
        Run the Tip-mode sequence after the config stage and return its exit code.

    .DESCRIPTION
        Fills the result cells in State and sets State.restore once run 1 was
        attempted. Nothing is staged, committed, or reset, and no unit gate runs.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Config,
        [Parameter(Mandatory = $true)] [hashtable] $State
    )

    if ((Invoke-RegenerationGitStep -GitArgs @('rev-parse', '-q', '--verify', 'MERGE_HEAD')).ExitCode -eq 0) { return 3 }
    $status = Invoke-RegenerationGitStep -GitArgs @('status', '--porcelain', '-z')
    if ($status.ExitCode -ne 0) { return 1 }
    if ($status.Output.Length -gt 0) { return 3 }

    $State.restore = $true
    $run = Invoke-RegenerationProcessStep -Argv @($Config['command'])
    if (-not $run.Started) { return 1 }
    $State.command_exit_code = $run.ExitCode
    if ($run.ExitCode -ne 0) { return 3 }
    $first = Get-RegenerationTipSnapshot
    if ($first.ExitCode -ne 0) { return 1 }
    $State.confined = Get-RegenerationConfinementDecision -ChangedPath $first.Path -Pattern ([string[]] @($Config['paths']))
    if (-not $State.confined) { return 3 }

    $run = Invoke-RegenerationProcessStep -Argv @($Config['command'])
    $State.command_exit_code = $run.ExitCode
    if (-not $run.Started) { return 1 }
    if ($run.ExitCode -ne 0) { return 3 }
    $checkExitCode = $null
    if ($Config.Contains('idempotency_check')) {
        $run = Invoke-RegenerationProcessStep -Argv @($Config['idempotency_check'])
        $State.command_exit_code = $run.ExitCode
        if (-not $run.Started) { return 1 }
        $checkExitCode = $run.ExitCode
    }
    if ($null -ne $checkExitCode -and $checkExitCode -ne 0) {
        $State.idempotent = $false
        return 3
    }
    $second = Get-RegenerationTipSnapshot
    if ($second.ExitCode -ne 0) { return 1 }
    $State.idempotent = Get-RegenerationIdempotencyDecision -FirstSnapshot $first.Blob -SecondSnapshot $second.Blob -CheckExitCode $checkExitCode
    if (-not $State.idempotent) { return 3 }
    $State.restore = $false
    $State.changed_paths = [object[]] @($first.Path)
    return 0
}

function Invoke-RegenerationTipRestore {
    <#
    .SYNOPSIS
        Restore tracked and remove untracked worktree changes; return $true when every call succeeds.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    $ok = $true
    $tracked = [string[]] @()
    $untracked = [string[]] @()
    $step = Invoke-RegenerationGitStep -GitArgs @('diff', '--name-only', '-z')
    if ($step.ExitCode -ne 0) { $ok = $false } else { $tracked = Get-RegenerationSortedPath -Listing @($step.Output) }
    $step = Invoke-RegenerationGitStep -GitArgs @('ls-files', '--others', '--exclude-standard', '-z')
    if ($step.ExitCode -ne 0) { $ok = $false } else { $untracked = Get-RegenerationSortedPath -Listing @($step.Output) }
    if ($tracked.Count -gt 0 -and (Invoke-RegenerationGitStep -GitArgs ([string[]] (@('checkout', '--') + $tracked))).ExitCode -ne 0) { $ok = $false }
    if ($untracked.Count -gt 0 -and (Invoke-RegenerationGitStep -GitArgs ([string[]] (@('clean', '-f', '-q', '--') + $untracked))).ExitCode -ne 0) { $ok = $false }
    return $ok
}

function Invoke-RegenerationMergeMode {
    <#
    .SYNOPSIS
        Produce the Merge-mode result for a parsed config stage.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)] [hashtable] $Context)

    $state = New-RegenerationMergeState
    $stage = $Context.Stage
    $exitCode = 3
    if ($null -ne $stage.Reason) {
        $state.decision = 'remediation_loop'
        $state.reason = $stage.Reason
        $state.config_errors = $stage.Errors
    }
    else {
        $exitCode = Invoke-RegenerationMergeFlow -Config $stage.Config -MergeRef $Context.MergeRef -State $state
        if ($exitCode -ne 0 -and $null -ne $state.merge_head_sha) {
            $abort = Invoke-RegenerationGitStep -GitArgs @('merge', '--abort')
            if ($abort.ExitCode -ne 0) { $exitCode = 1 }
        }
    }
    return (ConvertTo-RegenerationMergeOutput -Context $Context -State $state -ExitCode $exitCode)
}

function Invoke-RegenerationGitStep {
    <#
    .SYNOPSIS
        Run one git call; a throwing call is reported as exit code -1.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)] [string[]] $GitArgs)

    try {
        return (Invoke-RegenerationGitExe -GitArgs $GitArgs)
    }
    catch {
        [Console]::Error.WriteLine("git $($GitArgs -join ' ') failed: $($_.Exception.Message)")
        return [pscustomobject]@{ ExitCode = -1; Output = '' }
    }
}

function Invoke-RegenerationProcessStep {
    <#
    .SYNOPSIS
        Run one declared argv; Started is $false when the process cannot be started.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)] [object[]] $Argv)

    try {
        $exitCode = Invoke-RegenerationProcess -Argv ([string[]] $Argv)
        return [pscustomobject]@{ Started = $true; ExitCode = $exitCode }
    }
    catch {
        [Console]::Error.WriteLine("process $($Argv -join ' ') cannot be started: $($_.Exception.Message)")
        return [pscustomobject]@{ Started = $false; ExitCode = $null }
    }
}

function Get-RegenerationSortedPath {
    <#
    .SYNOPSIS
        Split NUL-separated listings into one ordinal-sorted, de-duplicated path list.
    #>
    [CmdletBinding()]
    [OutputType([string[]], [object[]])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [AllowEmptyString()] [string[]] $Listing)

    $set = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($text in $Listing) {
        foreach ($path in $text.Split([char] 0)) {
            if ($path.Length -gt 0) { [void] $set.Add($path) }
        }
    }
    return , [string[]] @($set)
}

function Get-RegenerationWorktreeChange {
    <#
    .SYNOPSIS
        Return the union of the unstaged and the untracked listing, or ExitCode non-zero.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param()

    $unstaged = Invoke-RegenerationGitStep -GitArgs @('diff', '--name-only', '-z')
    if ($unstaged.ExitCode -ne 0) { return [pscustomobject]@{ ExitCode = 1; Path = [string[]] @() } }
    $untracked = Invoke-RegenerationGitStep -GitArgs @('ls-files', '--others', '--exclude-standard', '-z')
    if ($untracked.ExitCode -ne 0) { return [pscustomobject]@{ ExitCode = 1; Path = [string[]] @() } }
    $paths = Get-RegenerationSortedPath -Listing @($unstaged.Output, $untracked.Output)
    return [pscustomobject]@{ ExitCode = 0; Path = $paths }
}

function Invoke-RegenerationMergeClassification {
    <#
    .SYNOPSIS
        Merge without committing, verify MERGE_HEAD, and classify the both-sides changed paths.

    .OUTPUTS
        PSCustomObject with ExitCode (0 to continue, 1 or 3 to stop), Ours, and Theirs.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Config,
        [Parameter(Mandatory = $true)] [string] $MergeRef,
        [Parameter(Mandatory = $true)] [hashtable] $State
    )

    $failed = [pscustomobject]@{ ExitCode = 1; Ours = ''; Theirs = '' }
    $null = Invoke-RegenerationGitStep -GitArgs @('merge', '--no-commit', '--no-ff', $MergeRef)
    $step = Invoke-RegenerationGitStep -GitArgs @('rev-parse', '-q', '--verify', 'MERGE_HEAD')
    if ($step.ExitCode -ne 0) { return $failed }
    $State.merge_head_sha = $step.Output.Trim()
    $step = Invoke-RegenerationGitStep -GitArgs @('rev-parse', 'HEAD')
    if ($step.ExitCode -ne 0) { return $failed }
    $State.feature_head_sha = $step.Output.Trim()
    $step = Invoke-RegenerationGitStep -GitArgs @('merge-base', '--all', 'HEAD', 'MERGE_HEAD')
    if ($step.ExitCode -ne 0) { return $failed }
    $bases = @($step.Output.Split("`n") | ForEach-Object { $_.Trim() } | Where-Object { $_.Length -gt 0 })
    $ours = ''
    $theirs = ''
    if ($bases.Count -eq 1) {
        $State.merge_base_sha = $bases[0]
        $step = Invoke-RegenerationGitStep -GitArgs @('diff', '--name-only', '-z', '--no-renames', $bases[0], 'HEAD')
        if ($step.ExitCode -ne 0) { return $failed }
        $ours = $step.Output
        $step = Invoke-RegenerationGitStep -GitArgs @('diff', '--name-only', '-z', '--no-renames', $bases[0], 'MERGE_HEAD')
        if ($step.ExitCode -ne 0) { return $failed }
        $theirs = $step.Output
    }
    $changed = Get-RegenerationChangedPath -OursListing $ours -TheirsListing $theirs
    $decision = Get-RegenerationPathDecision -ChangedPath $changed -MergeBaseCount $bases.Count -Config $Config -ConfigError @()
    $State.decision = $decision.Decision
    $State.reason = $decision.Reason
    $State.unmatched_paths = [object[]] @($decision.UnmatchedPath)
    if ($decision.Decision -cne 'regenerate') { return [pscustomobject]@{ ExitCode = 3; Ours = ''; Theirs = '' } }
    return [pscustomobject]@{ ExitCode = 0; Ours = $ours; Theirs = $theirs }
}

function Invoke-RegenerationMergeFlow {
    <#
    .SYNOPSIS
        Run the Merge-mode sequence after the config stage and return its exit code.

    .DESCRIPTION
        Fills the result cells in State as each stage completes. The caller aborts
        the merge for a non-zero exit once MERGE_HEAD was verified. No call commits
        or resets.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Config,
        [Parameter(Mandatory = $true)] [string] $MergeRef,
        [Parameter(Mandatory = $true)] [hashtable] $State
    )

    $pattern = [string[]] @($Config['paths'])
    $classified = Invoke-RegenerationMergeClassification -Config $Config -MergeRef $MergeRef -State $State
    if ($classified.ExitCode -ne 0) { return $classified.ExitCode }

    $step = Invoke-RegenerationGitStep -GitArgs @('diff', '--name-only', '-z', '--diff-filter=U')
    if ($step.ExitCode -ne 0) { return 1 }
    $conflicted = Get-RegenerationSortedPath -Listing @($step.Output)
    if ($conflicted.Count -gt 0) {
        if ((Invoke-RegenerationGitStep -GitArgs ([string[]] (@('checkout', '--ours', '--') + $conflicted))).ExitCode -ne 0) { return 1 }
        if ((Invoke-RegenerationGitStep -GitArgs ([string[]] (@('add', '--') + $conflicted))).ExitCode -ne 0) { return 1 }
    }
    $clean = Get-RegenerationWorktreeChange
    if ($clean.ExitCode -ne 0) { return 1 }
    if ($clean.Path.Count -gt 0) { return 3 }

    $run = Invoke-RegenerationProcessStep -Argv @($Config['command'])
    if (-not $run.Started) { return 1 }
    $State.command_exit_code = $run.ExitCode
    if ($run.ExitCode -ne 0) { return 3 }
    $firstChange = Get-RegenerationWorktreeChange
    if ($firstChange.ExitCode -ne 0) { return 1 }
    $State.confined = Get-RegenerationConfinementDecision -ChangedPath $firstChange.Path -Pattern $pattern
    if (-not $State.confined) { return 3 }
    if ($firstChange.Path.Count -gt 0) {
        if ((Invoke-RegenerationGitStep -GitArgs ([string[]] (@('add', '-A', '--') + $firstChange.Path))).ExitCode -ne 0) { return 1 }
    }

    $run = Invoke-RegenerationProcessStep -Argv @($Config['command'])
    $State.command_exit_code = $run.ExitCode
    if (-not $run.Started) { return 1 }
    if ($run.ExitCode -ne 0) { return 3 }
    $checkExitCode = $null
    if ($Config.Contains('idempotency_check')) {
        $run = Invoke-RegenerationProcessStep -Argv @($Config['idempotency_check'])
        $State.command_exit_code = $run.ExitCode
        if (-not $run.Started) { return 1 }
        $checkExitCode = $run.ExitCode
        if ($checkExitCode -ne 0) {
            $State.idempotent = $false
            return 3
        }
    }
    $secondChange = Get-RegenerationWorktreeChange
    if ($secondChange.ExitCode -ne 0) { return 1 }
    $State.idempotent = Get-RegenerationIdempotencyDecision -SecondRunChange $secondChange.Path -CheckExitCode $checkExitCode
    if (-not $State.idempotent) { return 3 }

    $staged = @()
    foreach ($parent in @('HEAD', 'MERGE_HEAD')) {
        $step = Invoke-RegenerationGitStep -GitArgs @('diff', '--cached', '--name-only', '-z', '--no-renames', $parent)
        if ($step.ExitCode -ne 0) { return 1 }
        $staged += , (Get-RegenerationSortedPath -Listing @($step.Output))
    }
    $State.delta_check = Get-RegenerationDeltaDecision -StagedAgainstFeatureHead $staged[0] -StagedAgainstIncomingTip $staged[1] `
        -BaseToFeatureHead (Get-RegenerationSortedPath -Listing @($classified.Ours)) `
        -BaseToIncomingTip (Get-RegenerationSortedPath -Listing @($classified.Theirs)) -Pattern $pattern
    if ($State.delta_check -cne 'pass') { return 3 }

    if ($Config.Contains('unit_gate')) {
        foreach ($gateArgv in @($Config['unit_gate'])) {
            $run = Invoke-RegenerationProcessStep -Argv @($gateArgv)
            $State.command_exit_code = $run.ExitCode
            if (-not $run.Started) {
                $State.unit_gate = 'fail'
                return 1
            }
            if ($run.ExitCode -ne 0) {
                $State.unit_gate = 'fail'
                return 3
            }
        }
        $State.unit_gate = 'pass'
    }
    $State.changed_paths = [object[]] @($firstChange.Path)
    return 0
}

function New-RegenerationMergeState {
    <#
    .SYNOPSIS
        Return the mutable Merge-mode result cells, initialized to their pre-stage values.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory builder that changes no system state.')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param()

    return @{
        decision = $null; reason = $null; unmatched_paths = [object[]] @(); config_errors = [object[]] @()
        feature_head_sha = $null; merge_head_sha = $null; merge_base_sha = $null; command_exit_code = $null
        confined = $null; idempotent = $null; unit_gate = 'not_run'; delta_check = 'not_run'
        changed_paths = [object[]] @()
    }
}

function ConvertTo-RegenerationMergeOutput {
    <#
    .SYNOPSIS
        Build the Merge-mode { ExitCode, Result } with its event and, on exit 0, the delta records.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $Context,
        [Parameter(Mandatory = $true)] [hashtable] $State,
        [Parameter(Mandatory = $true)] [int] $ExitCode
    )

    $eventOutcome = if ($ExitCode -eq 0) { 'regenerated' } else { 'fell_back' }
    $regenerationEvent = New-RegenerationEvent -At $Context.At -Trigger $Context.Trigger -FeatureHeadSha $State.feature_head_sha `
        -MergeHeadSha $State.merge_head_sha -MergeBaseSha $State.merge_base_sha -Decision $State.decision -Reason $State.reason `
        -UnmatchedPaths ([string[]] @($State.unmatched_paths)) -CommandExitCode $State.command_exit_code -Confined $State.confined `
        -Idempotent $State.idempotent -UnitGate $State.unit_gate -DeltaCheck $State.delta_check -Outcome $eventOutcome `
        -HeadSha $null -EvidencePath $null
    $reviewOutcome = $null
    $evidenceText = $null
    $outcome = 'fell_back'
    if ($ExitCode -eq 0) {
        $outcome = 'prepared'
        $reviewOutcome = New-RegenerationDeltaReviewOutcome -HeadSha $null -EvidencePath $null
        $invocation = Get-RegenerationInvocationText -MergeRef $Context.MergeRef -Trigger $Context.Trigger -ConfigPath $Context.InvocationConfigPath
        $evidenceText = New-RegenerationEvidenceText -Timestamp $Context.Stamp -Command $invocation -ExitCode 0 -Reason $State.reason `
            -Confined $State.confined -Idempotent $State.idempotent -UnitGate $State.unit_gate -DeltaCheck $State.delta_check
    }
    $result = New-RegenerationResult -Mode 'Merge' -Trigger $Context.Trigger -Decision $State.decision -Reason $State.reason `
        -UnmatchedPaths $State.unmatched_paths -ConfigErrors $State.config_errors -FeatureHeadSha $State.feature_head_sha `
        -MergeHeadSha $State.merge_head_sha -MergeBaseSha $State.merge_base_sha -CommandExitCode $State.command_exit_code `
        -Confined $State.confined -Idempotent $State.idempotent -UnitGate $State.unit_gate -DeltaCheck $State.delta_check `
        -ChangedPaths $State.changed_paths -Outcome $outcome -At $Context.At -Event $regenerationEvent `
        -ReviewOutcome $reviewOutcome -EvidenceText $evidenceText
    return [pscustomobject]@{ ExitCode = $ExitCode; Result = $result }
}

if ($MyInvocation.InvocationName -ne '.') {
    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'
    Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'RegenerationConfig.psm1') -ErrorAction Stop
    Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'RegenerationClassifier.psm1') -ErrorAction Stop
    Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'RegenerationDelta.psm1') -ErrorAction Stop
    $commandResult = Invoke-RegenerationPathCommand @PSBoundParameters
    ConvertTo-RegenerationResultJson -Result $commandResult.Result
    exit $commandResult.ExitCode
}
