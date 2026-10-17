<#
.SYNOPSIS
    Decides whether the heavy CI steps run for the commit under test (issues #962 and #973).

.DESCRIPTION
    Runs in the ci.yml 'changes' job. On a same-repository pull_request event it finds the newest
    successful ci.yml run on the branch whose 'CI full run' job succeeded, checks that the run's head
    commit is present and is an ancestor of the current head, and lists the files changed since that
    commit. When every changed file is on the docs-only allowlist (config/ci-docs-only-paths.json), it
    writes code=false; in every other case, including any failure, it writes code=true (a full run).

    Merge-base fallback (issue #973): when the branch has no full green run (NO_FULL_GREEN_RUN), or the
    green run's head commit is missing (BASE_NOT_PRESENT) or not an ancestor of the head
    (BASE_NOT_ANCESTOR), and the pull request's base ref is exactly 'main', the script computes the merge
    base of the payload base SHA (BASE_SHA) and the head and lists the files changed since that merge
    base with the same diff arguments. An all-allowlisted diff gives code=false with the reason
    DOCS_ONLY_SINCE_MERGE_BASE_<merge base sha>. A merge base that cannot be resolved gives code=true
    with the reason MERGE_BASE_UNRESOLVED. Pull requests into any other base ref keep the green-run
    decision only.

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
        Reads the eight decision inputs that the workflow step passes as environment variables.
    .DESCRIPTION
        BaseSha and BaseRef (issue #973) are blank on events other than pull_request; they are read only
        by the merge-base fallback, so they are not required context values.
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
        BaseSha        = [string](& $ReadVariable 'BASE_SHA')
        BaseRef        = [string](& $ReadVariable 'BASE_REF')
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

function Find-CiChangeScopeMergeBase {
    <#
    .SYNOPSIS
        Resolves the merge base of the pull request base commit and the head (issue #973).
    .DESCRIPTION
        Returns an object with Reason (blank when the merge base was resolved) and BaseSha. A blank base
        SHA, a base commit missing from the checkout, a failed git merge-base, or output that is not
        exactly one full SHA gives MERGE_BASE_UNRESOLVED with a blank BaseSha. The base ref is never
        passed to git.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowEmptyString()][string] $BaseSha = '',
        [Parameter(Mandatory = $true)][string] $HeadSha,
        [Parameter(Mandatory = $true)][scriptblock] $GitInvoker
    )

    $unresolved = [pscustomobject]@{ Reason = 'MERGE_BASE_UNRESOLVED'; BaseSha = '' }
    if ([string]::IsNullOrWhiteSpace($BaseSha)) {
        return $unresolved
    }
    $present = & $GitInvoker 'cat-file' '-e' "$($BaseSha)^{commit}"
    if ($present.ExitCode -ne 0) {
        return $unresolved
    }
    $mergeBase = & $GitInvoker 'merge-base' $BaseSha $HeadSha
    if ($mergeBase.ExitCode -ne 0) {
        return $unresolved
    }
    $mergeBaseSha = ConvertFrom-CiMergeBaseOutput -Text ([string]$mergeBase.Output)
    if (-not $mergeBaseSha) {
        return $unresolved
    }
    return [pscustomobject]@{ Reason = ''; BaseSha = $mergeBaseSha }
}

function Get-CiChangeScopeDiffDecision {
    <#
    .SYNOPSIS
        Lists the files changed from a base commit to the head and returns the decision for them.
    .DESCRIPTION
        Shared by the green-run path and the merge-base path. Rename detection is off, so both the old
        and the new path of a rename are listed and classified. A failed diff or output that is not git
        diff -z output gives DIFF_FAILED; an empty diff or a path outside the allowlist gives the path
        decision reason; otherwise the decision is code=false with DocsOnlyReasonPrefix followed by the
        base SHA. Every decision carries BaseSha.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][string] $BaseSha,
        [Parameter(Mandatory = $true)][string] $HeadSha,
        [Parameter(Mandatory = $true)][pscustomobject] $Config,
        [Parameter(Mandatory = $true)][scriptblock] $GitInvoker,
        [Parameter(Mandatory = $true)][string] $DocsOnlyReasonPrefix
    )

    $diff = & $GitInvoker 'diff' '--name-only' '-z' '--no-renames' '--no-color' '--no-ext-diff' '--no-relative' $BaseSha $HeadSha
    if ($diff.ExitCode -ne 0) {
        return New-CiChangeScopeDecision -Code $true -Reason 'DIFF_FAILED' -BaseSha $BaseSha
    }
    $pathList = ConvertFrom-CiNulPathList -Text ([string]$diff.Output)
    if (-not $pathList.Valid) {
        return New-CiChangeScopeDecision -Code $true -Reason 'DIFF_FAILED' -BaseSha $BaseSha
    }
    $pathReason = Get-CiChangeScopePathDecision -Paths $pathList.Paths -Config $Config
    if ($pathReason) {
        return New-CiChangeScopeDecision -Code $true -Reason $pathReason -BaseSha $BaseSha
    }
    return New-CiChangeScopeDecision -Code $false -Reason "$DocsOnlyReasonPrefix$BaseSha" -BaseSha $BaseSha
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

    # Primary comparison: the newest full green run on the branch. A reason that means no usable green
    # base exists is kept in $primary so that the merge-base fallback below can replace it.
    $primary = $null
    $base = Find-CiChangeScopeBase -Repository ([string]$Context['Repository']) -HeadRef ([string]$Context['HeadRef']) -RunId ([string]$Context['RunId']) -GhInvoker $GhInvoker
    if ($base.Reason) {
        $primary = New-CiChangeScopeDecision -Code $true -Reason $base.Reason
    }
    if ($null -eq $primary) {
        # The base must be present in the checkout and an ancestor of the head; otherwise the diff since the
        # base would not describe what this branch changed.
        $baseSha = [string]$base.BaseSha
        $present = & $GitInvoker 'cat-file' '-e' "$($baseSha)^{commit}"
        if ($present.ExitCode -ne 0) {
            $primary = New-CiChangeScopeDecision -Code $true -Reason 'BASE_NOT_PRESENT' -BaseSha $baseSha
        }
    }
    if ($null -eq $primary) {
        $ancestry = & $GitInvoker 'merge-base' '--is-ancestor' $baseSha $headSha
        if ($ancestry.ExitCode -eq 1) {
            $primary = New-CiChangeScopeDecision -Code $true -Reason 'BASE_NOT_ANCESTOR' -BaseSha $baseSha
        }
        elseif ($ancestry.ExitCode -ne 0) {
            return New-CiChangeScopeDecision -Code $true -Reason 'ANCESTRY_CHECK_FAILED' -BaseSha $baseSha
        }
        else {
            return Get-CiChangeScopeDiffDecision -BaseSha $baseSha -HeadSha $headSha -Config $config -GitInvoker $GitInvoker -DocsOnlyReasonPrefix 'DOCS_ONLY_SINCE_'
        }
    }

    # Merge-base fallback (issue #973): only for NO_FULL_GREEN_RUN, BASE_NOT_PRESENT, or BASE_NOT_ANCESTOR
    # on a pull request whose base ref is exactly main. RUN_LIST_FAILED and JOB_LIST_FAILED are returned
    # unchanged here, as is every primary reason for another base ref.
    if (-not (Test-CiMergeBaseFallbackApplicable -PrimaryReason $primary.Reason -BaseRef ([string]$Context['BaseRef']))) {
        return $primary
    }
    $mergeBase = Find-CiChangeScopeMergeBase -BaseSha ([string]$Context['BaseSha']) -HeadSha $headSha -GitInvoker $GitInvoker
    if ($mergeBase.Reason) {
        return New-CiChangeScopeDecision -Code $true -Reason $mergeBase.Reason
    }
    return Get-CiChangeScopeDiffDecision -BaseSha $mergeBase.BaseSha -HeadSha $headSha -Config $config -GitInvoker $GitInvoker -DocsOnlyReasonPrefix 'DOCS_ONLY_SINCE_MERGE_BASE_'
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
