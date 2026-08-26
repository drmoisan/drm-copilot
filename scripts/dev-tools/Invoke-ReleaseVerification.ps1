<#
.SYNOPSIS
    Out-of-band verification that a pushed release tag actually produced a
    published artifact.

.DESCRIPTION
    Layer B of the missed-npm-publish defence (issue #526). A workflow cannot
    detect its own non-existence, so this module runs outside CI and answers
    three questions about a tag that was just pushed: (a) did a workflow run
    start for the tag ref at all, (b) did the named publish step inside that run
    conclude success, and (c) does the exact version now resolve on the npm
    registry.

    Every external executable call is isolated behind a wrapper-function seam
    (Invoke-GhExe, Invoke-NpmExe) and every wait behind Invoke-Sleep, so Pester
    unit tests can mock all three without touching a real process, the network,
    or the wall clock, per repo policy. The entry-point block at the bottom is
    skipped when the file is dot-sourced.

.PARAMETER TagName
    Short name of the release tag to verify, for example 'mcp-server-v1.1.2'.
    The remaining script parameters name the workflow file, the publish job and
    step, the exact version and package for check (c), the polling interval and
    attempt budget, and the SkipRegistryResolutionCheck switch that omits check
    (c) for the extension path, which publishes to the VS Code Marketplace.

.EXAMPLE
    pwsh ./scripts/dev-tools/Invoke-ReleaseVerification.ps1 -TagName mcp-server-v1.1.2 -Version 1.1.2
#>

[CmdletBinding()]
param(
    [string]$TagName,
    [string]$WorkflowFileName = 'publish-mcp-npm.yml',
    [string]$JobName = 'Publish to npm',
    [string]$StepName = 'Publish to npm',
    [string]$Version,
    [string]$PackageName = '@danmoisan/drm-copilot-mcp',
    [int]$IntervalSeconds = 10,
    [int]$MaxAttempts = 18,
    [switch]$SkipRegistryResolutionCheck
)

function Invoke-GhExe {
    <#
    .SYNOPSIS
        Wrapper seam for the GitHub CLI, so tests can mock it without real gh.
    .OUTPUTS
        A hashtable with keys Output (string[]) and ExitCode (int).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$GhArgs
    )
    $output = & gh @GhArgs 2>&1
    return @{ Output = @($output); ExitCode = $LASTEXITCODE }
}

function Invoke-NpmExe {
    <#
    .SYNOPSIS
        Wrapper seam for npm, so tests can mock it without real npm.
    .OUTPUTS
        A hashtable with keys Output (string[]) and ExitCode (int).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$NpmArgs
    )
    $output = & npm @NpmArgs 2>&1
    return @{ Output = @($output); ExitCode = $LASTEXITCODE }
}

function Invoke-Sleep {
    <#
    .SYNOPSIS
        Wrapper seam isolating Start-Sleep, so tests can mock every wait and
        assert the exact number of polling intervals without consuming wall time.
    .OUTPUTS
        None.
    #>
    [CmdletBinding()]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true)]
        [int]$Seconds
    )
    Start-Sleep -Seconds $Seconds
}

function ConvertFrom-JsonSafely {
    <#
    .SYNOPSIS
        Parses JSON text, returning $null instead of throwing when the text is
        empty or malformed. Pure helper; performs no external call.
    .DESCRIPTION
        The gh seam returns whatever the CLI wrote, which on a transient error is
        not JSON. A poll must treat that attempt as "nothing found yet" and retry
        rather than terminate, so a parse failure is a value here, not a throw.
    .OUTPUTS
        The deserialized object, or $null when the text is empty or unparseable.
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [string]$Text
    )

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return $null
    }

    try {
        return ($Text | ConvertFrom-Json)
    }
    catch {
        return $null
    }
}

function Test-NpmVersionResolved {
    <#
    .SYNOPSIS
        Check (c). Reports whether one exact package version resolves on npm.
    .DESCRIPTION
        The package operand is built in the exact-version form, joining the
        package name and the requested version with an at sign. The bare-package
        form is prohibited here: it resolves the 'latest' dist-tag, so it would
        have reported success throughout the 1.0.25 failure this guard exists to
        catch. Success requires both halves of a conjunction, exit code 0 AND
        trimmed stdout equal to the requested version, because a bare-package
        query also exits 0 while returning a different version string.
    .OUTPUTS
        Boolean. True only when the exact requested version resolves.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Version,
        [string]$PackageName = '@danmoisan/drm-copilot-mcp'
    )

    $packageOperand = '{0}@{1}' -f $PackageName, $Version
    $result = Invoke-NpmExe -NpmArgs @('view', $packageOperand, 'version')

    if ($result.ExitCode -ne 0) {
        return $false
    }

    $observed = (@($result.Output) -join "`n").Trim()
    return ($observed -eq $Version)
}

function Wait-ForWorkflowRun {
    <#
    .SYNOPSIS
        Check (a). Waits for a workflow run to exist for the supplied tag; the
        only check that can detect a run that never started.
    .DESCRIPTION
        The match is performed on the run listing's headBranch field against the
        short tag name. That field carries the tag name for a tag-triggered run,
        confirmed empirically in the gh-run-list-headbranch probe artifact of
        issue #526, so no head-SHA fallback is required. Polling is bounded and a
        sleep is taken only between attempts: a run found on the first attempt
        sleeps zero times, one found on attempt N sleeps N-1 times, and an
        exhausted budget of M attempts sleeps M-1 times.
    .OUTPUTS
        The run identifier as a string, or the token 'NO_RUN' on exhaustion.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$TagName,
        [string]$WorkflowFileName = 'publish-mcp-npm.yml',
        [int]$IntervalSeconds = 10,
        [int]$MaxAttempts = 18
    )

    for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++) {
        $result = Invoke-GhExe -GhArgs @(
            'run', 'list',
            "--workflow=$WorkflowFileName",
            '--limit', '20',
            '--json', 'databaseId,headBranch,status,conclusion'
        )

        if ($result.ExitCode -eq 0) {
            $runs = ConvertFrom-JsonSafely -Text (@($result.Output) -join "`n")
            foreach ($run in @($runs)) {
                if ($run -and $run.headBranch -eq $TagName) {
                    return [string]$run.databaseId
                }
            }
        }

        if ($attempt -lt $MaxAttempts) {
            Invoke-Sleep -Seconds $IntervalSeconds
        }
    }

    return 'NO_RUN'
}

function Resolve-PublishStepConclusion {
    <#
    .SYNOPSIS
        Classifies a completed run payload into a check (b) token. Pure function
        over the deserialized payload; performs no external call and no wait.
    .DESCRIPTION
        The lookup is hierarchical: the job is located by name first and the step
        by name within that job. A flat name search would be ambiguous, because
        publish-mcp-npm.yml gives its publish job and its publish step the same
        name, confirmed in the gh-publish-step-name probe artifact of issue #526.
        An absent job or step returns STEP_MISSING, a failure state and never an
        absence of evidence: the only way for the named step to vanish is a
        workflow rename, and a rename must not silently degrade this into a pass.
    .OUTPUTS
        One of 'SUCCESS', 'RUN_FAILED', 'STEP_SKIPPED', or 'STEP_MISSING'.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [object]$Run,
        [Parameter(Mandatory = $true)]
        [string]$JobName,
        [Parameter(Mandatory = $true)]
        [string]$StepName
    )

    if ($Run.conclusion -eq 'failure' -or $Run.conclusion -eq 'cancelled') {
        return 'RUN_FAILED'
    }

    $job = @($Run.jobs) | Where-Object { $_ -and $_.name -eq $JobName } | Select-Object -First 1
    if (-not $job) {
        return 'STEP_MISSING'
    }

    $step = @($job.steps) | Where-Object { $_ -and $_.name -eq $StepName } | Select-Object -First 1
    if (-not $step) {
        return 'STEP_MISSING'
    }

    if ($step.conclusion -eq 'skipped') {
        return 'STEP_SKIPPED'
    }
    if ($step.conclusion -eq 'success') {
        return 'SUCCESS'
    }

    return 'RUN_FAILED'
}

function Test-PublishStepConclusion {
    <#
    .SYNOPSIS
        Check (b). Reports how the named publish step of a run concluded.
    .DESCRIPTION
        A run found by check (a) may still be in progress, so this check polls
        until the run reports status 'completed', on the same bounded schedule as
        check (a). Classification of a completed payload is delegated to
        Resolve-PublishStepConclusion. Budget exhaustion, meaning the run never
        completed, returns 'RUN_FAILED': the run did not reach a successful
        conclusion, and that state's recovery instruction is the correct one.
    .OUTPUTS
        One of 'SUCCESS', 'RUN_FAILED', 'STEP_SKIPPED', or 'STEP_MISSING'.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RunIdentifier,
        [string]$JobName = 'Publish to npm',
        [string]$StepName = 'Publish to npm',
        [int]$IntervalSeconds = 10,
        [int]$MaxAttempts = 18
    )

    for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++) {
        $result = Invoke-GhExe -GhArgs @(
            'run', 'view', $RunIdentifier,
            '--json', 'status,conclusion,jobs'
        )

        if ($result.ExitCode -eq 0) {
            $run = ConvertFrom-JsonSafely -Text (@($result.Output) -join "`n")
            if ($run -and $run.status -eq 'completed') {
                return (Resolve-PublishStepConclusion -Run $run -JobName $JobName -StepName $StepName)
            }
        }

        if ($attempt -lt $MaxAttempts) {
            Invoke-Sleep -Seconds $IntervalSeconds
        }
    }

    return 'RUN_FAILED'
}

function Get-RecoveryInstruction {
    <#
    .SYNOPSIS
        Maps a state token to its operator recovery instruction. Pure lookup.
    .DESCRIPTION
        Each non-success state carries its own instruction and no two of them are
        the same string. A single generic failure message would say that
        something went wrong without saying whether the version number was
        consumed, which is the one fact that decides whether a retry is safe. The
        table mirrors section 3.2 of the feature spec for issue #526.
    .OUTPUTS
        The instruction string, or an empty string for an unrecognized token.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$State
    )

    $instructions = @{
        VERSION_CONSUMED_ELSEWHERE = 'Abort before pushing anything. The target version number is already taken on the registry; bump the version again and re-run the release.'
        NO_RUN                     = 'No run started for the tag ref. With the ref-based publish guard in place, re-dispatch non-destructively with "gh workflow run publish-mcp-npm.yml --ref" against the tag; that consumes no version number. Delete-and-re-push of the tag is precondition-gated and runbook-only.'
        RUN_FAILED                 = 'The run did not reach a successful conclusion. Read the run logs. The version may or may not be consumed; evaluate the registry-resolution check before any retry.'
        STEP_SKIPPED               = 'The job concluded success but the publish step was skipped, so the publish guard did not match and the version is NOT consumed. Fix the guard or the trigger, then re-dispatch.'
        STEP_MISSING               = 'The named job or step was not found in the run payload, which means the workflow was renamed. Treat this as a failure, never as absence of evidence, and reconcile the job and step names before retrying.'
        UNRESOLVED                 = 'The publish step succeeded but the version did not appear on the registry within the polling budget. This is most likely registry propagation delay. Re-run the verifier before concluding, and do NOT retry the publish.'
        RESOLVED                   = ''
    }

    if ($instructions.ContainsKey($State)) {
        return [string]$instructions[$State]
    }
    return ''
}

function ConvertTo-VerificationResult {
    <#
    .SYNOPSIS
        Builds the verification result object for one state token. Pure
        constructor; performs no external call and changes no state outside the
        object it returns.
    .OUTPUTS
        A PSCustomObject with State, ExitCode, RunExistence, StepConclusion, and
        Instruction. ExitCode is 0 only for RESOLVED.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$State,
        [Parameter(Mandatory = $true)]
        [string]$RunExistence,
        [Parameter(Mandatory = $true)]
        [string]$StepConclusion
    )

    return [pscustomobject]@{
        State          = $State
        ExitCode       = $(if ($State -eq 'RESOLVED') { 0 } else { 1 })
        RunExistence   = $RunExistence
        StepConclusion = $StepConclusion
        Instruction    = (Get-RecoveryInstruction -State $State)
    }
}

function Get-CodexPinnedMcpVersion {
    <#
    .SYNOPSIS
        Reads the mcp-server version pinned in the npx argument array of a
        .codex/config.toml document. Pure function over an in-memory string that
        performs no filesystem access and opens no temporary file.
    .DESCRIPTION
        The content is a parameter rather than a disk read so the caller owns the
        single read and the function stays testable without a temporary file,
        which repo test policy prohibits outright. The pin appears in the
        exact-version form, so the version is whatever follows the at sign up to
        the closing quote.
    .OUTPUTS
        The pinned version string, or $null when the package is not pinned.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$ConfigContent,
        [string]$PackageName = '@danmoisan/drm-copilot-mcp'
    )

    if ([string]::IsNullOrWhiteSpace($ConfigContent)) {
        return $null
    }

    $pattern = [regex]::Escape($PackageName) + '@([^"'']+)'
    $match = [regex]::Match($ConfigContent, $pattern)
    if (-not $match.Success) {
        return $null
    }

    return $match.Groups[1].Value.Trim()
}

function Invoke-TagPublishVerification {
    <#
    .SYNOPSIS
        Composes checks (a), (b), and (c) into the per-tag state machine.
    .DESCRIPTION
        The checks run in order and short-circuit on the first negative result,
        so the reported state names the earliest point at which the release
        diverged. The observed check (a) and check (b) outcomes are reported
        alongside the state token so the failure is actionable without re-running
        the verifier. Supplying SkipRegistryResolutionCheck omits check (c)
        entirely and returns RESOLVED when checks (a) and (b) both succeed,
        without touching the npm seam at all. That is the extension release path,
        which publishes to the VS Code Marketplace rather than to the npm
        registry and so has no npm version for check (c) to resolve. One
        composition entry point therefore serves both release paths.
    .OUTPUTS
        A PSCustomObject whose State is exactly one of RESOLVED, NO_RUN,
        RUN_FAILED, STEP_SKIPPED, STEP_MISSING, or UNRESOLVED, with ExitCode 0
        only for RESOLVED.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$TagName,
        [string]$WorkflowFileName = 'publish-mcp-npm.yml',
        [string]$JobName = 'Publish to npm',
        [string]$StepName = 'Publish to npm',
        [string]$Version,
        [string]$PackageName = '@danmoisan/drm-copilot-mcp',
        [int]$IntervalSeconds = 10,
        [int]$MaxAttempts = 18,
        [switch]$SkipRegistryResolutionCheck
    )

    $runIdentifier = Wait-ForWorkflowRun `
        -TagName $TagName `
        -WorkflowFileName $WorkflowFileName `
        -IntervalSeconds $IntervalSeconds `
        -MaxAttempts $MaxAttempts

    if ($runIdentifier -eq 'NO_RUN') {
        return (ConvertTo-VerificationResult -State 'NO_RUN' -RunExistence 'NO_RUN' -StepConclusion 'NOT_REACHED')
    }

    $stepConclusion = Test-PublishStepConclusion `
        -RunIdentifier $runIdentifier `
        -JobName $JobName `
        -StepName $StepName `
        -IntervalSeconds $IntervalSeconds `
        -MaxAttempts $MaxAttempts

    if ($stepConclusion -ne 'SUCCESS') {
        return (ConvertTo-VerificationResult -State $stepConclusion -RunExistence $runIdentifier -StepConclusion $stepConclusion)
    }

    if ($SkipRegistryResolutionCheck) {
        return (ConvertTo-VerificationResult -State 'RESOLVED' -RunExistence $runIdentifier -StepConclusion $stepConclusion)
    }

    for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++) {
        if (Test-NpmVersionResolved -Version $Version -PackageName $PackageName) {
            return (ConvertTo-VerificationResult -State 'RESOLVED' -RunExistence $runIdentifier -StepConclusion $stepConclusion)
        }
        if ($attempt -lt $MaxAttempts) {
            Invoke-Sleep -Seconds $IntervalSeconds
        }
    }

    return (ConvertTo-VerificationResult -State 'UNRESOLVED' -RunExistence $runIdentifier -StepConclusion $stepConclusion)
}

# Entry point: skipped when the script is dot-sourced for testing or for reuse
# by a sibling release script.
if ($MyInvocation.InvocationName -ne '.') {
    $verification = Invoke-TagPublishVerification `
        -TagName $TagName `
        -WorkflowFileName $WorkflowFileName `
        -JobName $JobName `
        -StepName $StepName `
        -Version $Version `
        -PackageName $PackageName `
        -IntervalSeconds $IntervalSeconds `
        -MaxAttempts $MaxAttempts `
        -SkipRegistryResolutionCheck:$SkipRegistryResolutionCheck

    Write-Output "State: $($verification.State); RunExistence: $($verification.RunExistence); StepConclusion: $($verification.StepConclusion)"
    Write-Output "Instruction: $($verification.Instruction)"
    exit $verification.ExitCode
}
