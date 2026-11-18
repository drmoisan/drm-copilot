<#
.SYNOPSIS
    Runs the npm audit gate with the advisory exception mechanism for one manifest (issue #1204).

.DESCRIPTION
    Runs in the .github/workflows/_npm-audit-gate.yml step 'Audit dependencies', with the matrix manifest
    as the working directory. It reads config/npm-audit-exceptions.json, runs the strict production-only
    audit (npm audit --omit=dev --audit-level=<level>) and then the full audit (npm audit --json, no
    --omit), and hands both results to Get-NpmAuditGateDecision in the pure module NpmAuditGate.psm1.
    This script holds the I/O: the file read, the UTC clock, the npm process, the environment read, the
    writes to GITHUB_STEP_SUMMARY and the log, and the process exit code. Each boundary goes through an
    injectable seam (-ReadFile, -GetUtcDate, Invoke-NpmAuditExe, -OutputWriter) so the tests run without
    files, clocks, or npm.

    The entry point runs only when the script is executed; when it is dot-sourced (tests), the guard at
    the end of the file skips it. The entry point ends with an explicit exit 0 for a passing decision and
    exit 1 otherwise (.claude/rules/ci-workflows.md).
#>
[CmdletBinding()]
param(
    [ValidateSet('info', 'low', 'moderate', 'high', 'critical')][string] $AuditLevel = 'moderate',
    [string] $ExceptionsPath = ''
)

Set-StrictMode -Version Latest
Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'NpmAuditGate.psm1') -Force

function Get-NpmAuditGateVariable {
    <#
    .SYNOPSIS
        Returns the value of one process environment variable; the only environment boundary of the gate.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][string] $Name
    )

    return [Environment]::GetEnvironmentVariable($Name)
}

function Get-NpmAuditGateFileText {
    <#
    .SYNOPSIS
        Returns the text of one file; the default -ReadFile seam.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][string] $Path
    )

    return [string] (Get-Content -Raw -LiteralPath $Path -ErrorAction Stop)
}

function Get-NpmAuditGateUtcDate {
    <#
    .SYNOPSIS
        Returns the current UTC date as yyyy-MM-dd; the default -GetUtcDate seam and the only clock read.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param()

    return [datetime]::UtcNow.ToString('yyyy-MM-dd', [cultureinfo]::InvariantCulture)
}

function Split-NpmAuditRecord {
    <#
    .SYNOPSIS
        Splits the merged records of a native npm call into standard output text and standard error lines.
    .DESCRIPTION
        An ErrorRecord is a line that npm wrote to standard error; every other record is standard output.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowNull()][object[]] $Record = @()
    )

    $stdOut = [System.Collections.Generic.List[string]]::new()
    $stdErr = [System.Collections.Generic.List[string]]::new()
    foreach ($item in @($Record)) {
        if ($item -is [System.Management.Automation.ErrorRecord]) {
            $stdErr.Add([string] $item.ToString())
        }
        else {
            $stdOut.Add([string] $item)
        }
    }
    return [pscustomobject]@{ StdOut = ($stdOut -join "`n"); StdErr = [string[]] $stdErr.ToArray() }
}

function ConvertTo-NpmAuditExeResult {
    <#
    .SYNOPSIS
        Turns the merged records and the exit code of one npm call into the wrapper result.
    .DESCRIPTION
        Standard error lines go to the log through the information stream and are never part of the
        returned standard output, so a warning cannot corrupt the audit JSON.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowNull()][object[]] $Record = @(),
        [Parameter(Mandatory = $true)][AllowNull()][object] $ExitCode
    )

    $streams = Split-NpmAuditRecord -Record $Record
    foreach ($line in $streams.StdErr) {
        Write-Information -MessageData "npm stderr: $line" -InformationAction Continue
    }
    # A missing exit code fails closed: it is reported as 1, never as success.
    $code = 1
    if ($null -ne $ExitCode) { $code = [int] $ExitCode }
    return [pscustomobject]@{ ExitCode = $code; StdOut = $streams.StdOut }
}

function Invoke-NpmAuditExe {
    <#
    .SYNOPSIS
        Runs npm with the given arguments and returns its exit code and standard output.
    .DESCRIPTION
        The wrapper seam for the npm executable. Standard error lines go to the log, never into the
        returned standard output, so a warning cannot corrupt the audit JSON.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][string[]] $NpmArgs
    )

    $records = @(& npm @NpmArgs 2>&1)
    return ConvertTo-NpmAuditExeResult -Record $records -ExitCode $LASTEXITCODE
}

function Write-NpmAuditGateTarget {
    <#
    .SYNOPSIS
        Publishes gate text to the job summary or the log.
    .DESCRIPTION
        Summary appends to the file named by GITHUB_STEP_SUMMARY; when that variable is blank the text is
        shown on the information stream instead. Log writes the text to the information stream.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][ValidateSet('Summary', 'Log')][string] $Target,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string] $Text,
        [scriptblock] $ReadVariable = { param([string] $Name) Get-NpmAuditGateVariable -Name $Name }
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

function Invoke-NpmAuditGate {
    <#
    .SYNOPSIS
        Runs both audits, makes the gate decision, publishes its summary, and returns the decision object.
    .DESCRIPTION
        Never throws to its caller: any exception becomes a failed decision whose summary reads
        'NPM Audit Gate: FAIL (unexpected error: <message>)'. The summary goes to the Summary and Log
        targets through -OutputWriter. The production call is npm audit --omit=dev with the audit level
        passed through unchanged; the full call is npm audit --json with no --omit.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [ValidateSet('info', 'low', 'moderate', 'high', 'critical')][string] $AuditLevel = 'moderate',
        [string] $ExceptionsPath = '',
        [scriptblock] $ReadFile = { param([string] $Path) Get-NpmAuditGateFileText -Path $Path },
        [scriptblock] $GetUtcDate = { Get-NpmAuditGateUtcDate },
        [scriptblock] $OutputWriter = { param([string] $Target, [string] $Text) Write-NpmAuditGateTarget -Target $Target -Text $Text }
    )

    try {
        $exceptionText = ''
        try {
            $exceptionText = [string](& $ReadFile $ExceptionsPath)
        }
        catch {
            & $OutputWriter 'Log' "Cannot read the exception file: $($_.Exception.Message)"
        }
        $utcDate = [string](& $GetUtcDate)
        $production = Invoke-NpmAuditExe -NpmArgs @('audit', '--omit=dev', "--audit-level=$AuditLevel")
        & $OutputWriter 'Log' "npm audit --omit=dev --audit-level=$AuditLevel exited $($production.ExitCode)`n$($production.StdOut)"
        $full = Invoke-NpmAuditExe -NpmArgs @('audit', '--json')
        & $OutputWriter 'Log' "npm audit --json exited $($full.ExitCode)"
        $decision = Get-NpmAuditGateDecision -ExceptionJson $exceptionText -UtcDate $utcDate -AuditLevel $AuditLevel -ProductionExitCode ([int] $production.ExitCode) -FullAuditJson ([string] $full.StdOut)
    }
    catch {
        # Fail-closed envelope: an unexpected failure must never report a green gate.
        $summary = "NPM Audit Gate: FAIL (unexpected error: $($_.Exception.Message))"
        $decision = [pscustomobject]@{ Passed = $false; Code = $null; Applied = [object[]] @(); Unused = [object[]] @(); SummaryText = $summary }
    }
    & $OutputWriter 'Summary' $decision.SummaryText
    & $OutputWriter 'Log' $decision.SummaryText
    return $decision
}

function Get-NpmAuditGateExitCode {
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

function Invoke-NpmAuditGateEntry {
    <#
    .SYNOPSIS
        Runs the gate with the default seams and returns the exit code (0 or 1) for the entry point.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [ValidateSet('info', 'low', 'moderate', 'high', 'critical')][string] $AuditLevel = 'moderate',
        [string] $ExceptionsPath = ''
    )

    $gateDecision = Invoke-NpmAuditGate -AuditLevel $AuditLevel -ExceptionsPath $ExceptionsPath
    return (Get-NpmAuditGateExitCode -Decision $gateDecision)
}

if ($MyInvocation.InvocationName -ne '.') {
    if ((Invoke-NpmAuditGateEntry -AuditLevel $AuditLevel -ExceptionsPath $ExceptionsPath) -eq 0) {
        exit 0
    }
    exit 1
}
