<#
.SYNOPSIS
    Evaluates the results of every other ci.yml job for the 'CI Required Gate' job (issue #1074).

.DESCRIPTION
    Runs in the ci.yml 'ci-required-gate' job, which needs every other ci.yml job and runs under
    if: always(). The workflow step passes ${{ toJSON(needs) }} in the NEEDS_JSON environment
    variable. The decision is made by Get-CiRequiredGateDecision in the pure module
    CiRequiredGate.psm1; this script holds the I/O: the environment read, the write of the per-job
    summary table to GITHUB_STEP_SUMMARY and the log, and the process exit code. The environment read
    and the writes go through injectable seams (-ReadVariable and -OutputWriter) so the tests run
    without environment variables or files.

    The entry point runs only when the script is executed; when it is dot-sourced (tests), the guard
    at the end of the file skips it. The entry point ends with an explicit exit 0 for a passing
    decision and exit 1 otherwise (.claude/rules/ci-workflows.md).
#>
Set-StrictMode -Version Latest
Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'CiRequiredGate.psm1') -Force

function Get-CiRequiredGateVariable {
    <#
    .SYNOPSIS
        Returns the value of one process environment variable; the only environment boundary of the gate.
    .DESCRIPTION
        The default -ReadVariable seams call this function, so the tests replace it with a mock and never
        read the real NEEDS_JSON or GITHUB_STEP_SUMMARY values.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][string] $Name
    )

    return [Environment]::GetEnvironmentVariable($Name)
}

function Write-CiRequiredGateTarget {
    <#
    .SYNOPSIS
        Publishes the gate summary to the job summary or the log.
    .DESCRIPTION
        Summary appends to the file named by GITHUB_STEP_SUMMARY; when that variable is blank the text
        is shown on the information stream instead. Log writes the text to the information stream.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][ValidateSet('Summary', 'Log')][string] $Target,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string] $Text,
        [scriptblock] $ReadVariable = { param([string] $Name) Get-CiRequiredGateVariable -Name $Name }
    )

    if ($Target -ceq 'Summary') {
        $path = [string](& $ReadVariable 'GITHUB_STEP_SUMMARY')
        if ([string]::IsNullOrWhiteSpace($path)) {
            Write-Information -MessageData "[Summary] $Text" -InformationAction Continue
            return
        }
        Add-Content -LiteralPath $path -Value $Text
        return
    }
    Write-Information -MessageData $Text -InformationAction Continue
}

function Get-CiRequiredGateNeedsJson {
    <#
    .SYNOPSIS
        Returns the NEEDS_JSON value that the workflow step passes, as a string (blank when unset).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [scriptblock] $ReadVariable = { param([string] $Name) Get-CiRequiredGateVariable -Name $Name }
    )

    return [string](& $ReadVariable 'NEEDS_JSON')
}

function Invoke-CiRequiredGate {
    <#
    .SYNOPSIS
        Makes the gate decision, publishes its summary, and returns the decision object.
    .DESCRIPTION
        Never throws to its caller: any exception becomes a failed decision whose summary ends with
        'Verdict: FAIL (unexpected error: <message>)'. The summary is written to the Summary and Log
        targets through -OutputWriter.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string] $NeedsJson,
        [scriptblock] $OutputWriter = { param([string] $Target, [string] $Text) Write-CiRequiredGateTarget -Target $Target -Text $Text }
    )

    try {
        $decision = Get-CiRequiredGateDecision -NeedsJson $NeedsJson
    }
    catch {
        # Fail-closed envelope: an unexpected failure must never report a green gate.
        $summary = "CI Required Gate: scope=invalid code=(absent)`n`nVerdict: FAIL (unexpected error: $($_.Exception.Message))"
        $decision = [pscustomobject]@{ Passed = $false; Scope = 'invalid'; Code = $null; Rows = [object[]] @(); SummaryText = $summary }
    }
    & $OutputWriter 'Summary' $decision.SummaryText
    & $OutputWriter 'Log' $decision.SummaryText
    return $decision
}

function Get-CiRequiredGateExitCode {
    <#
    .SYNOPSIS
        Maps a decision to the process exit code: 0 only when Passed is $true, otherwise 1.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [AllowNull()][object] $Decision
    )

    if ($null -eq $Decision) { return 1 }
    $passedProperty = $Decision.PSObject.Properties['Passed']
    if ($null -ne $passedProperty -and $passedProperty.Value -is [bool] -and $passedProperty.Value) {
        return 0
    }
    return 1
}

function Invoke-CiRequiredGateEntry {
    <#
    .SYNOPSIS
        Runs the gate with the default seams and returns the exit code (0 or 1) for the entry point.
    .DESCRIPTION
        Reads NEEDS_JSON through the default -ReadVariable seam and publishes the summary through the
        default writer. Kept as a function so the only code outside the tests' reach is the guarded
        exit statements below.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param()

    $gateDecision = Invoke-CiRequiredGate -NeedsJson (Get-CiRequiredGateNeedsJson)
    return (Get-CiRequiredGateExitCode -Decision $gateDecision)
}

if ($MyInvocation.InvocationName -ne '.') {
    if ((Invoke-CiRequiredGateEntry) -eq 0) {
        exit 0
    }
    exit 1
}
