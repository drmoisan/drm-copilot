Set-StrictMode -Version Latest

# Pure decision logic for the ci.yml 'CI Required Gate' job (issue #1074).
#
# The gate needs every other ci.yml job and runs under if: always(). The runner passes
# ${{ toJSON(needs) }} to scripts/ci/Invoke-CiRequiredGate.ps1, which hands the text to
# Get-CiRequiredGateDecision. Every function here works on in-memory values only: no function reads
# or writes a file, reads the process environment, starts a process, or touches the network. Every
# rule fails closed: any input the gate cannot classify gives a red verdict.

# The ci.yml jobs whose job-level if: contains needs.changes.outputs.code != 'false'. Only these may
# report 'skipped' on a docs-only run; tests/scripts/workflows/CiRequiredGateWorkflow.Tests.ps1 pins
# this list against ci.yml.
$script:CiRequiredGateSkippableJobs = [string[]] @('full-run-marker', 'npm-audit-gate', 'root-typescript-tests')

# The jobs that must be present and 'success' on a docs-only run.
$script:CiRequiredGateDocsOnlyRequiredJobs = [string[]] @(
    'changes', 'quality-checks7', 'security-scan', 'docs-validation', 'build-check', 'poshqc', 'shell-coverage', 'drm-copilot-extension-tests'
)

function Get-CiRequiredGateSkippableJob {
    <#
    .SYNOPSIS
        Returns the job ids that may report 'skipped' on a docs-only run.
    .DESCRIPTION
        Returns a new string array, sorted with ordinal comparison, so a caller cannot change the
        module constant.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param()

    $copy = [string[]] $script:CiRequiredGateSkippableJobs.Clone()
    [Array]::Sort($copy, [StringComparer]::Ordinal)
    return $copy
}

function ConvertFrom-CiRequiredGateNeedsJson {
    <#
    .SYNOPSIS
        Parses NEEDS_JSON and returns the needs object, or the configuration error that rejects it.
    .DESCRIPTION
        Returns an object with Needs (a dictionary keyed by job id, or $null) and Error (blank when the
        text is usable). Blank text, text that is not JSON, a root that is not an object, and a missing
        changes, docs-validation, or skippable-set key are configuration errors.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string] $NeedsJson
    )

    if ([string]::IsNullOrWhiteSpace($NeedsJson)) {
        return [pscustomobject]@{ Needs = $null; Error = 'NEEDS_JSON is blank' }
    }
    try {
        $parsed = ConvertFrom-Json -InputObject $NeedsJson -AsHashtable -NoEnumerate -ErrorAction Stop
    }
    catch {
        return [pscustomobject]@{ Needs = $null; Error = 'NEEDS_JSON is not valid JSON' }
    }
    if ($parsed -isnot [System.Collections.IDictionary]) {
        return [pscustomobject]@{ Needs = $null; Error = 'NEEDS_JSON is not a JSON object' }
    }

    $keys = [string[]] @($parsed.Keys)
    $missing = [System.Collections.Generic.List[string]]::new()
    foreach ($requiredKey in @(@('changes', 'docs-validation') + $script:CiRequiredGateSkippableJobs)) {
        if ($keys -cnotcontains $requiredKey) { $missing.Add($requiredKey) }
    }
    if ($missing.Count -gt 0) {
        return [pscustomobject]@{ Needs = $null; Error = ('missing job: ' + ($missing -join ', ')) }
    }
    return [pscustomobject]@{ Needs = $parsed; Error = '' }
}

function Get-CiRequiredGateJobResult {
    <#
    .SYNOPSIS
        Returns the result value of one needs entry, or $null when the entry has none.
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [AllowNull()][object] $Entry
    )

    if ($Entry -isnot [System.Collections.IDictionary] -or -not $Entry.Contains('result')) {
        return $null
    }
    return $Entry['result']
}

function Get-CiRequiredGateCode {
    <#
    .SYNOPSIS
        Returns needs.changes.outputs.code as a string, or $null when it is absent.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowNull()][object] $ChangesEntry
    )

    if ($ChangesEntry -isnot [System.Collections.IDictionary] -or -not $ChangesEntry.Contains('outputs')) {
        return $null
    }
    $outputs = $ChangesEntry['outputs']
    if ($outputs -isnot [System.Collections.IDictionary] -or -not $outputs.Contains('code') -or $null -eq $outputs['code']) {
        return $null
    }
    return [string] $outputs['code']
}

function Format-CiRequiredGateSummary {
    <#
    .SYNOPSIS
        Renders the Markdown summary: header, per-job table, and the final verdict line, joined with LF.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][string] $Scope,
        # [object] rather than [string]: a [string] parameter turns $null into '' and loses '(absent)'.
        [AllowNull()][object] $Code,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][object[]] $Rows,
        [Parameter(Mandatory = $true)][string] $VerdictLine
    )

    $codeText = $Code
    if ($null -eq $Code) { $codeText = '(absent)' }
    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add("CI Required Gate: scope=$Scope code=$codeText")
    $lines.Add('')
    $lines.Add('| Job | Result | Accepted | Verdict |')
    $lines.Add('|---|---|---|---|')
    foreach ($row in $Rows) {
        $resultText = '(null)'
        if ($null -ne $row.Result) { $resultText = [string] $row.Result }
        $lines.Add("| $($row.Job) | $resultText | $($row.Accepted) | $($row.Verdict) |")
    }
    $lines.Add('')
    $lines.Add($VerdictLine)
    return ($lines -join "`n")
}

function Get-CiRequiredGateDecision {
    <#
    .SYNOPSIS
        Evaluates the needs results of the CI Required Gate and returns the verdict.
    .DESCRIPTION
        Returns an object with Passed (bool), Scope ('full', 'docs-only', or 'invalid'), Code (the raw
        changes.outputs.code string, or $null), Rows (one Job, Result, Accepted, Verdict entry per needed
        job, in ordinal job-id order), and SummaryText (Markdown). The scope is docs-only only when Code
        is exactly 'false'. In docs-only scope the skippable jobs accept 'success' or 'skipped'; every
        other job, and every job in full scope, accepts only 'success'. The changes job must be
        'success', and in docs-only scope the eight non-skippable jobs must be present. A configuration
        error gives scope 'invalid' with no rows.
    .PARAMETER NeedsJson
        The text of ${{ toJSON(needs) }}.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string] $NeedsJson
    )

    $parsed = ConvertFrom-CiRequiredGateNeedsJson -NeedsJson $NeedsJson
    if ($parsed.Error) {
        $verdictLine = "Verdict: FAIL (configuration error: $($parsed.Error))"
        return [pscustomobject]@{
            Passed      = $false
            Scope       = 'invalid'
            Code        = $null
            Rows        = [object[]] @()
            SummaryText = (Format-CiRequiredGateSummary -Scope 'invalid' -Code $null -Rows @() -VerdictLine $verdictLine)
        }
    }

    $needs = $parsed.Needs
    $code = Get-CiRequiredGateCode -ChangesEntry $needs['changes']
    $scope = 'full'
    if ($code -ceq 'false') { $scope = 'docs-only' }

    $jobIds = [string[]] @($needs.Keys)
    [Array]::Sort($jobIds, [StringComparer]::Ordinal)
    $rows = [System.Collections.Generic.List[object]]::new()
    $rejected = [System.Collections.Generic.List[string]]::new()
    foreach ($jobId in $jobIds) {
        $accepted = [string[]] @('success')
        if ($scope -ceq 'docs-only' -and $script:CiRequiredGateSkippableJobs -ccontains $jobId) {
            $accepted = [string[]] @('success', 'skipped')
        }
        $result = Get-CiRequiredGateJobResult -Entry $needs[$jobId]
        $verdict = 'fail'
        if ($result -is [string] -and $accepted -ccontains $result) { $verdict = 'ok' }
        if ($verdict -ceq 'fail') { $rejected.Add($jobId) }
        $rows.Add([pscustomobject]@{ Job = $jobId; Result = $result; Accepted = ($accepted -join ', '); Verdict = $verdict })
    }

    $reasons = [System.Collections.Generic.List[string]]::new()
    if ($rejected.Count -gt 0) {
        $reasons.Add('result not accepted: ' + ($rejected -join ', '))
    }
    $changesResult = Get-CiRequiredGateJobResult -Entry $needs['changes']
    if (-not ($changesResult -is [string] -and $changesResult -ceq 'success')) {
        $reasons.Add('changes result is not success')
    }
    if ($scope -ceq 'docs-only') {
        $absent = @($script:CiRequiredGateDocsOnlyRequiredJobs | Where-Object { $jobIds -cnotcontains $_ })
        if ($absent.Count -gt 0) {
            $reasons.Add('missing job: ' + ($absent -join ', '))
        }
    }

    $passed = ($reasons.Count -eq 0)
    $verdictLine = 'Verdict: PASS'
    if (-not $passed) { $verdictLine = "Verdict: FAIL ($($reasons -join '; '))" }
    $rowArray = [object[]] $rows.ToArray()
    return [pscustomobject]@{
        Passed      = $passed
        Scope       = $scope
        Code        = $code
        Rows        = $rowArray
        SummaryText = (Format-CiRequiredGateSummary -Scope $scope -Code $code -Rows $rowArray -VerdictLine $verdictLine)
    }
}

Export-ModuleMember -Function @('Get-CiRequiredGateDecision', 'Get-CiRequiredGateSkippableJob')
