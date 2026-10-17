<#
.SYNOPSIS
    Decides whether the heavy CI steps run for the commit under test (issue #962).

.DESCRIPTION
    Runs in the ci.yml 'changes' job. On a same-repository pull_request event it finds the newest
    successful ci.yml run on the branch whose 'CI full run' job succeeded, checks that the run's head
    commit is present and is an ancestor of the current head, and lists the files changed since that
    commit. When every changed file is on the docs-only allowlist (config/ci-docs-only-paths.json), it
    writes code=false; in every other case, including any failure, it writes code=true (a full run).

    The decision logic lives in the pure module CiChangeScope.psm1. This script holds the I/O: the
    gh and git calls, the environment reads, and the writes to GITHUB_OUTPUT, GITHUB_STEP_SUMMARY,
    and the log. Each of those goes through an injectable seam (-GhInvoker, -GitInvoker,
    -OutputWriter, -ReadVariable) so the tests run without processes or files.

    The entry point runs only when the script is executed; when it is dot-sourced (tests), the guard
    at the end of the file skips it.
#>
Set-StrictMode -Version Latest
Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'CiChangeScope.psm1') -Force

function Invoke-CiChangeScopeNative {
    <#
    .SYNOPSIS
        Runs one external command and returns its exit code and its output joined with LF.
    .DESCRIPTION
        The only process boundary of the change-scope decision. Standard error is discarded; the
        caller treats a non-zero exit code as a failure.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][string] $FileName,
        [AllowEmptyCollection()][string[]] $ArgumentList = @()
    )

    $lines = @(& $FileName @ArgumentList 2>$null)
    $exitCode = [int]$LASTEXITCODE
    return [pscustomobject]@{ ExitCode = $exitCode; Output = (@($lines | ForEach-Object { [string]$_ }) -join "`n") }
}

function Write-CiChangeScopeTarget {
    <#
    .SYNOPSIS
        Publishes one decision text to the step output, the job summary, the log, or a warning.
    .DESCRIPTION
        Output appends to the file named by GITHUB_OUTPUT and Summary to the file named by
        GITHUB_STEP_SUMMARY; when that variable is blank the text is shown on the information stream
        instead. Log writes the text to the information stream, and Warning writes it as a GitHub
        Actions ::warning:: annotation.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][ValidateSet('Output', 'Summary', 'Log', 'Warning')][string] $Target,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string] $Text,
        [scriptblock] $ReadVariable = { param([string] $Name) [Environment]::GetEnvironmentVariable($Name) }
    )

    # Output and Summary go to the file GitHub Actions provides; Log and Warning go to the log.
    if ($Target -ceq 'Output' -or $Target -ceq 'Summary') {
        $variableName = 'GITHUB_OUTPUT'
        if ($Target -ceq 'Summary') { $variableName = 'GITHUB_STEP_SUMMARY' }
        $path = [string](& $ReadVariable $variableName)
        if ([string]::IsNullOrWhiteSpace($path)) {
            Write-Information -MessageData "[$Target] $Text" -InformationAction Continue
            return
        }
        Add-Content -LiteralPath $path -Value $Text
        return
    }
    if ($Target -ceq 'Warning') {
        Write-Information -MessageData "::warning::$Text" -InformationAction Continue
        return
    }
    Write-Information -MessageData $Text -InformationAction Continue
}

function Get-CiChangeScopeContext {
    <#
    .SYNOPSIS
        Reads the six decision inputs that the workflow step passes as environment variables.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [scriptblock] $ReadVariable = { param([string] $Name) [Environment]::GetEnvironmentVariable($Name) }
    )

    return @{
        EventName      = [string](& $ReadVariable 'EVENT_NAME')
        HeadSha        = [string](& $ReadVariable 'HEAD_SHA')
        HeadRef        = [string](& $ReadVariable 'HEAD_REF')
        HeadRepository = [string](& $ReadVariable 'HEAD_REPO')
        Repository     = [string](& $ReadVariable 'REPOSITORY')
        RunId          = [string](& $ReadVariable 'RUN_ID')
    }
}

function Read-CiChangeScopeConfigText {
    <#
    .SYNOPSIS
        Returns the text of the committed docs-only allowlist.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [string] $Path = (Join-Path -Path $PSScriptRoot -ChildPath '../../config/ci-docs-only-paths.json')
    )

    return (Get-Content -Raw -LiteralPath $Path -ErrorAction Stop)
}

function Find-CiChangeScopeBase {
    <#
    .SYNOPSIS
        Finds the head SHA of the newest full green run, or the reason no base can be used.
    .DESCRIPTION
        Returns an object with Reason (blank when a base was found) and BaseSha. A failed or
        unparseable run list gives RUN_LIST_FAILED, a failed or unparseable job list gives
        JOB_LIST_FAILED, and no run with a successful 'CI full run' job gives NO_FULL_GREEN_RUN.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][string] $Repository,
        [Parameter(Mandatory = $true)][string] $HeadRef,
        [Parameter(Mandatory = $true)][string] $RunId,
        [Parameter(Mandatory = $true)][scriptblock] $GhInvoker
    )

    $runsPath = "repos/$Repository/actions/workflows/ci.yml/runs?branch=$([uri]::EscapeDataString($HeadRef))&event=pull_request&status=success&per_page=50"
    $runsCall = & $GhInvoker 'api' $runsPath
    if ($runsCall.ExitCode -ne 0) {
        return [pscustomobject]@{ Reason = 'RUN_LIST_FAILED'; BaseSha = '' }
    }
    try {
        $candidates = @(Select-CiGreenBaseCandidates -RunsJson ([string]$runsCall.Output) -CurrentRunId $RunId -Repository $Repository)
    }
    catch {
        # Only the module's run-list validation error maps to RUN_LIST_FAILED; anything else reaches the
        # fail-closed envelope of Invoke-CiChangeScope.
        if (-not $_.Exception.Message.StartsWith('CI_RUN_LIST_INVALID:', [StringComparison]::Ordinal)) { throw }
        return [pscustomobject]@{ Reason = 'RUN_LIST_FAILED'; BaseSha = '' }
    }

    # Candidates are newest first; the first one whose marker job succeeded is the base.
    foreach ($candidate in $candidates) {
        $jobsCall = & $GhInvoker 'api' "repos/$Repository/actions/runs/$($candidate.Id)/jobs?filter=latest&per_page=100"
        if ($jobsCall.ExitCode -ne 0) {
            return [pscustomobject]@{ Reason = 'JOB_LIST_FAILED'; BaseSha = '' }
        }
        try {
            $hasMarker = Test-CiFullRunMarker -JobsJson ([string]$jobsCall.Output)
        }
        catch {
            if (-not $_.Exception.Message.StartsWith('CI_JOB_LIST_INVALID:', [StringComparison]::Ordinal)) { throw }
            return [pscustomobject]@{ Reason = 'JOB_LIST_FAILED'; BaseSha = '' }
        }
        if ($hasMarker) {
            return [pscustomobject]@{ Reason = ''; BaseSha = $candidate.HeadSha }
        }
    }
    return [pscustomobject]@{ Reason = 'NO_FULL_GREEN_RUN'; BaseSha = '' }
}

function Resolve-CiChangeScopeDecision {
    <#
    .SYNOPSIS
        Applies the decision steps in order and returns the decision of the first step that decides.
    .DESCRIPTION
        Throws on a blank context value or an invalid allowlist; Invoke-CiChangeScope turns any throw
        into a code=true UNEXPECTED_ERROR decision.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][hashtable] $Context,
        [AllowEmptyString()][string] $ConfigJson = '',
        [switch] $HasConfigJson,
        [Parameter(Mandatory = $true)][scriptblock] $GhInvoker,
        [Parameter(Mandatory = $true)][scriptblock] $GitInvoker
    )

    $ineligible = Test-CiChangeScopeEventEligible -EventName ([string]$Context['EventName']) -HeadRepository ([string]$Context['HeadRepository']) -Repository ([string]$Context['Repository'])
    if ($ineligible) {
        return New-CiChangeScopeDecision -Code $true -Reason $ineligible
    }
    # These four values are required for the API and git calls below.
    foreach ($name in @('HeadSha', 'HeadRef', 'Repository', 'RunId')) {
        if ([string]::IsNullOrWhiteSpace([string]$Context[$name])) {
            throw "CI_CHANGE_SCOPE_CONTEXT_INVALID: $name is blank"
        }
    }
    $headSha = [string]$Context['HeadSha']

    $configText = $ConfigJson
    if (-not $HasConfigJson) { $configText = Read-CiChangeScopeConfigText }
    $config = ConvertFrom-CiDocsOnlyPathConfig -Json $configText

    $base = Find-CiChangeScopeBase -Repository ([string]$Context['Repository']) -HeadRef ([string]$Context['HeadRef']) -RunId ([string]$Context['RunId']) -GhInvoker $GhInvoker
    if ($base.Reason) {
        return New-CiChangeScopeDecision -Code $true -Reason $base.Reason
    }
    $baseSha = [string]$base.BaseSha

    # The base must be present in the checkout and an ancestor of the head; otherwise the diff since the
    # base would not describe what this branch changed.
    $present = & $GitInvoker 'cat-file' '-e' "$($baseSha)^{commit}"
    if ($present.ExitCode -ne 0) {
        return New-CiChangeScopeDecision -Code $true -Reason 'BASE_NOT_PRESENT' -BaseSha $baseSha
    }
    $ancestry = & $GitInvoker 'merge-base' '--is-ancestor' $baseSha $headSha
    if ($ancestry.ExitCode -eq 1) {
        return New-CiChangeScopeDecision -Code $true -Reason 'BASE_NOT_ANCESTOR' -BaseSha $baseSha
    }
    if ($ancestry.ExitCode -ne 0) {
        return New-CiChangeScopeDecision -Code $true -Reason 'ANCESTRY_CHECK_FAILED' -BaseSha $baseSha
    }

    $diff = & $GitInvoker 'diff' '--name-only' '-z' '--no-renames' '--no-color' '--no-ext-diff' '--no-relative' $baseSha $headSha
    if ($diff.ExitCode -ne 0) {
        return New-CiChangeScopeDecision -Code $true -Reason 'DIFF_FAILED' -BaseSha $baseSha
    }
    $pathList = ConvertFrom-CiNulPathList -Text ([string]$diff.Output)
    if (-not $pathList.Valid) {
        return New-CiChangeScopeDecision -Code $true -Reason 'DIFF_FAILED' -BaseSha $baseSha
    }
    $pathReason = Get-CiChangeScopePathDecision -Paths $pathList.Paths -Config $config
    if ($pathReason) {
        return New-CiChangeScopeDecision -Code $true -Reason $pathReason -BaseSha $baseSha
    }
    return New-CiChangeScopeDecision -Code $false -Reason "DOCS_ONLY_SINCE_$baseSha" -BaseSha $baseSha
}

function Invoke-CiChangeScope {
    <#
    .SYNOPSIS
        Makes the change-scope decision, publishes it, and returns the decision object.
    .DESCRIPTION
        Never throws to its caller: any exception becomes code=true with reason UNEXPECTED_ERROR and a
        warning annotation. The decision is then written to the Output, Log, and Summary targets.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][hashtable] $Context,
        [AllowEmptyString()][string] $ConfigJson = '',
        [scriptblock] $GhInvoker = { Invoke-CiChangeScopeNative -FileName 'gh' -ArgumentList $args },
        [scriptblock] $GitInvoker = { Invoke-CiChangeScopeNative -FileName 'git' -ArgumentList $args },
        [scriptblock] $OutputWriter = { param([string] $Target, [string] $Text) Write-CiChangeScopeTarget -Target $Target -Text $Text }
    )

    try {
        $decision = Resolve-CiChangeScopeDecision -Context $Context -ConfigJson $ConfigJson -HasConfigJson:($PSBoundParameters.ContainsKey('ConfigJson')) -GhInvoker $GhInvoker -GitInvoker $GitInvoker
    }
    catch {
        # Fail-closed envelope: an unexpected failure must never skip the heavy CI steps.
        $decision = New-CiChangeScopeDecision -Code $true -Reason 'UNEXPECTED_ERROR'
        & $OutputWriter 'Warning' "Change scope failed closed: $($_.Exception.Message)"
    }
    & $OutputWriter 'Output' $decision.OutputLine
    & $OutputWriter 'Log' $decision.LogLine
    & $OutputWriter 'Summary' $decision.SummaryText
    return $decision
}

if ($MyInvocation.InvocationName -ne '.') {
    $null = Invoke-CiChangeScope -Context (Get-CiChangeScopeContext)
    exit 0
}
