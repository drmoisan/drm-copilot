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
    step, the exact version and package for check (c), a separate polling
    interval and attempt budget for each of the three checks, and the
    SkipRegistryResolutionCheck switch that omits check (c) for the extension
    path, which publishes to the VS Code Marketplace.

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
    [int]$RunIntervalSeconds = 10,
    [int]$RunMaxAttempts = 18,
    [int]$StepIntervalSeconds = 20,
    [int]$StepMaxAttempts = 60,
    [int]$NpmIntervalSeconds = 15,
    [int]$NpmMaxAttempts = 40,
    [switch]$SkipRegistryResolutionCheck
)

# The pure helpers live in a sibling file because this one stood one line under
# the 500-line cap. They are dot-sourced rather than imported as a module so
# their functions resolve in every consumer scope, including the scope of
# scripts/dev-tools/Invoke-ReleaseTagPush.ps1, which dot-sources this file in
# turn and calls Get-CodexPinnedMcpVersion transitively.
. (Join-Path -Path $PSScriptRoot -ChildPath 'Invoke-ReleaseVerificationHelpers.ps1')

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
        until the run reports status 'completed', on its own bounded schedule.
        Classification of a completed payload is delegated to
        Resolve-PublishStepConclusion. Budget exhaustion returns
        'RUN_INCOMPLETE', which is not a failure of the run: the run never
        completed, so no conclusion was ever observed and the polling budget is
        what expired. The correct operator action is to re-run the verifier,
        because the run may still be in progress and may still succeed. Reporting
        that case as 'RUN_FAILED' would send the operator to read the logs of a
        run that has not concluded, and would assert a failure that was never
        observed.
    .OUTPUTS
        One of 'SUCCESS', 'RUN_FAILED', 'RUN_INCOMPLETE', 'STEP_SKIPPED', or
        'STEP_MISSING'. 'RUN_FAILED' means a terminal failure conclusion was
        observed; 'RUN_INCOMPLETE' means the budget expired before any conclusion
        was observed.
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

    # The budget expired without the run ever reporting status 'completed', so no
    # conclusion was observed. That is not the same fact as an observed failure.
    return 'RUN_INCOMPLETE'
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
    .PARAMETER RunIntervalSeconds
        Polling interval for check (a). With RunMaxAttempts this forms the check
        (a) budget, whose default of 10 seconds by 18 attempts is the 3-minute
        ceiling of section 3.4 of the feature spec for issue #526.
    .PARAMETER RunMaxAttempts
        Attempt budget for check (a). See RunIntervalSeconds.
    .PARAMETER StepIntervalSeconds
        Polling interval for check (b). With StepMaxAttempts this forms the check
        (b) budget, whose default of 20 seconds by 60 attempts is the 20-minute
        ceiling of section 3.4. A workflow run takes far longer to reach a
        terminal conclusion than it takes to appear, so this budget is much wider
        than check (a)'s. Sharing one pair across all three checks was the issue
        526 R1 defect: it ran check (b) at 3 minutes.
    .PARAMETER StepMaxAttempts
        Attempt budget for check (b). See StepIntervalSeconds.
    .PARAMETER NpmIntervalSeconds
        Polling interval for check (c). With NpmMaxAttempts this forms the check
        (c) budget, whose default of 15 seconds by 40 attempts is the 10-minute
        ceiling of section 3.4, sized for registry propagation delay.
    .PARAMETER NpmMaxAttempts
        Attempt budget for check (c). See NpmIntervalSeconds.
    .OUTPUTS
        A PSCustomObject whose State is exactly one of the seven tokens RESOLVED,
        NO_RUN, RUN_FAILED, RUN_INCOMPLETE, STEP_SKIPPED, STEP_MISSING, or
        UNRESOLVED, with ExitCode 0 only for RESOLVED. RUN_FAILED and
        RUN_INCOMPLETE are distinct: the first means a terminal failure
        conclusion was observed, the second that the check (b) budget expired
        before any conclusion was observed.
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
        [int]$RunIntervalSeconds = 10,
        [int]$RunMaxAttempts = 18,
        [int]$StepIntervalSeconds = 20,
        [int]$StepMaxAttempts = 60,
        [int]$NpmIntervalSeconds = 15,
        [int]$NpmMaxAttempts = 40,
        [switch]$SkipRegistryResolutionCheck
    )

    $runIdentifier = Wait-ForWorkflowRun `
        -TagName $TagName `
        -WorkflowFileName $WorkflowFileName `
        -IntervalSeconds $RunIntervalSeconds `
        -MaxAttempts $RunMaxAttempts

    if ($runIdentifier -eq 'NO_RUN') {
        return (ConvertTo-VerificationResult -State 'NO_RUN' -RunExistence 'NO_RUN' -StepConclusion 'NOT_REACHED')
    }

    $stepConclusion = Test-PublishStepConclusion `
        -RunIdentifier $runIdentifier `
        -JobName $JobName `
        -StepName $StepName `
        -IntervalSeconds $StepIntervalSeconds `
        -MaxAttempts $StepMaxAttempts

    if ($stepConclusion -ne 'SUCCESS') {
        return (ConvertTo-VerificationResult -State $stepConclusion -RunExistence $runIdentifier -StepConclusion $stepConclusion)
    }

    if ($SkipRegistryResolutionCheck) {
        return (ConvertTo-VerificationResult -State 'RESOLVED' -RunExistence $runIdentifier -StepConclusion $stepConclusion)
    }

    for ($attempt = 1; $attempt -le $NpmMaxAttempts; $attempt++) {
        if (Test-NpmVersionResolved -Version $Version -PackageName $PackageName) {
            return (ConvertTo-VerificationResult -State 'RESOLVED' -RunExistence $runIdentifier -StepConclusion $stepConclusion)
        }
        if ($attempt -lt $NpmMaxAttempts) {
            Invoke-Sleep -Seconds $NpmIntervalSeconds
        }
    }

    return (ConvertTo-VerificationResult -State 'UNRESOLVED' -RunExistence $runIdentifier -StepConclusion $stepConclusion)
}

# Entry point: skipped when the script is dot-sourced for testing or for reuse
# by a sibling release script.
if ($MyInvocation.InvocationName -ne '.') {
    # Forward all six per-check budgets; one shared pair was the issue 526 R1 defect.
    $verification = Invoke-TagPublishVerification `
        -TagName $TagName `
        -WorkflowFileName $WorkflowFileName `
        -JobName $JobName `
        -StepName $StepName `
        -Version $Version `
        -PackageName $PackageName `
        -RunIntervalSeconds $RunIntervalSeconds `
        -RunMaxAttempts $RunMaxAttempts `
        -StepIntervalSeconds $StepIntervalSeconds `
        -StepMaxAttempts $StepMaxAttempts `
        -NpmIntervalSeconds $NpmIntervalSeconds `
        -NpmMaxAttempts $NpmMaxAttempts `
        -SkipRegistryResolutionCheck:$SkipRegistryResolutionCheck

    Write-Output "State: $($verification.State); RunExistence: $($verification.RunExistence); StepConclusion: $($verification.StepConclusion)"
    Write-Output "Instruction: $($verification.Instruction)"
    exit $verification.ExitCode
}
