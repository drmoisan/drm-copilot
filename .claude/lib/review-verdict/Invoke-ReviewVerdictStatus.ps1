<#
.SYNOPSIS
    Post the review/verdict commit status on a pull-request head when a narrow rule allows it.

.DESCRIPTION
    Entry point of decision D16 (issue #1097). The orchestrator runs it after a review returns
    PASS and immediately before a merge:

        pwsh -NoProfile -File .claude/lib/review-verdict/Invoke-ReviewVerdictStatus.ps1 `
            -Mode Review -PrNumber <PR> -ReviewArtifact <feature-folder>/policy-audit.<timestamp>.md

    Mode Review reads the orchestrator checkpoint; modes MainSync, RecordsPr, and PromotionPr
    read only the pull request and git. The rules are the pure decisions of
    ReviewVerdictEligibility.psm1. This script gathers each fact a decision requests, one gh or
    git process at a time, and issues one gh api POST to repos/{owner}/{repo}/statuses/<head>
    only when the decision is eligible. It writes no file.

    Exit codes: 0 posted (stdout REVIEW_VERDICT_POSTED:); 3 not eligible (stderr
    REVIEW_VERDICT_NOT_ELIGIBLE: <code>: <detail>, no POST); 1 a read, git, or gh failure (stderr
    REVIEW_VERDICT_FAILED:); 2 a usage error (stderr REVIEW_VERDICT_USAGE:).

    The status records a passing review and does not prove one: anyone with write access,
    including any agent with gh, can post it.

.PARAMETER Mode
    Review, MainSync, RecordsPr, or PromotionPr.

.PARAMETER PrNumber
    The pull request number, a positive integer.

.PARAMETER CheckpointPath
    The orchestrator checkpoint read by mode Review; defaults to
    artifacts/orchestration/orchestrator-state.json.

.PARAMETER ReviewArtifact
    The committed policy audit of the PASS review; required by mode Review.
#>
[CmdletBinding(PositionalBinding = $false)]
param(
    [string] $Mode,
    [string] $PrNumber,
    [string] $CheckpointPath,
    [string] $ReviewArtifact
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'ReviewVerdictEligibility.psm1') -Force -ErrorAction Stop

$script:ReviewVerdictModes = @('Review', 'MainSync', 'RecordsPr', 'PromotionPr')
$script:ReviewVerdictDefaultCheckpoint = 'artifacts/orchestration/orchestrator-state.json'
$script:ReviewVerdictFactLimit = 16

function Invoke-ReviewVerdictNativeCommand {
    <#
    .SYNOPSIS
        Run one command with arguments and return ExitCode and the stdout lines joined as Output.
    .DESCRIPTION
        The only process start of the script. Error records on the merged stream are dropped, so
        Output holds stdout only.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([string] $Command, [string[]] $Arguments)

    $all = @(& $Command @Arguments 2>&1)
    return [pscustomobject]@{ ExitCode = [int](Get-Variable -Name 'LASTEXITCODE' -Scope Global -ValueOnly -ErrorAction Ignore); Output =(@($all | Where-Object { $_ -isnot [System.Management.Automation.ErrorRecord] }) -join "`n") }
}

function Invoke-ReviewVerdictGhExe {
    <#
    .SYNOPSIS
        Run gh with the given arguments; the script's gh seam. Returns ExitCode and stdout Output.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([string[]] $GhArgs)

    return Invoke-ReviewVerdictNativeCommand -Command 'gh' -Arguments $GhArgs
}

function Invoke-ReviewVerdictGitExe {
    <#
    .SYNOPSIS
        Run git with the given arguments; the script's git seam. Returns ExitCode and stdout Output.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([string[]] $GitArgs)

    return Invoke-ReviewVerdictNativeCommand -Command 'git' -Arguments $GitArgs
}

function Read-ReviewVerdictCheckpointText {
    <#
    .SYNOPSIS
        Read the checkpoint as UTF-8 text; the script's only file read and its test seam.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([string] $Path)

    $resolved = if ([System.IO.Path]::IsPathRooted($Path)) { $Path } else { Join-Path -Path (Get-Location).Path -ChildPath $Path }
    return [System.IO.File]::ReadAllText($resolved, [System.Text.Encoding]::UTF8)
}

function ConvertTo-ReviewVerdictOutcome {
    <#
    .SYNOPSIS
        Build the ExitCode, Stdout, and Stderr record the guard writes and exits with.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([int] $ExitCode, [string] $Stdout = '', [string] $Stderr = '')

    return [pscustomobject]@{ ExitCode = $ExitCode; Stdout = $Stdout; Stderr = $Stderr }
}

function Write-ReviewVerdictOutcome {
    <#
    .SYNOPSIS
        Write the outcome's Stdout and Stderr lines to the given writers and return its ExitCode.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param([pscustomobject] $Outcome, [System.IO.TextWriter] $Out = [Console]::Out, [System.IO.TextWriter] $ErrorWriter = [Console]::Error)

    if (-not [string]::IsNullOrEmpty($Outcome.Stdout)) { $Out.WriteLine($Outcome.Stdout) }
    if (-not [string]::IsNullOrEmpty($Outcome.Stderr)) { $ErrorWriter.WriteLine($Outcome.Stderr) }
    return [int]$Outcome.ExitCode
}

function Get-ReviewVerdictModeDecision {
    <#
    .SYNOPSIS
        Call the pure decision of one mode with the facts gathered so far.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([string] $Mode, [int] $PrNumber, [AllowNull()][object] $Checkpoint, [string] $ReviewArtifact, [hashtable] $Fact)

    switch ($Mode) {
        'Review' { return Get-ReviewVerdictReviewDecision -Checkpoint $Checkpoint -PrNumber $PrNumber -ReviewArtifact $ReviewArtifact -Fact $Fact }
        'MainSync' { return Get-ReviewVerdictMainSyncDecision -PrNumber $PrNumber -Fact $Fact }
        'RecordsPr' { return Get-ReviewVerdictRecordsPrDecision -PrNumber $PrNumber -Fact $Fact }
        default { return Get-ReviewVerdictPromotionPrDecision -PrNumber $PrNumber -Fact $Fact }
    }
}

function Invoke-ReviewVerdictCli {
    <#
    .SYNOPSIS
        Validate usage, gather facts in rule order, and post the status only when eligible.
    .DESCRIPTION
        Usage errors exit 2 before any read or process. Each loop pass asks the mode's decision
        for its next fact and runs exactly that one process, so no later process runs once a rule
        refuses. A refusal exits 3 with no POST; a git or gh failure, an unreadable checkpoint, or
        a failed POST exits 1.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([string] $Mode, [string] $PrNumber, [string] $CheckpointPath, [string] $ReviewArtifact)

    $number = 0
    if ($script:ReviewVerdictModes -cnotcontains $Mode) {
        return ConvertTo-ReviewVerdictOutcome -ExitCode 2 -Stderr "REVIEW_VERDICT_USAGE: -Mode must be one of $($script:ReviewVerdictModes -join ', '); got '$Mode'."
    }
    if ($PrNumber -cnotmatch '^[1-9][0-9]{0,8}\z' -or -not [int]::TryParse($PrNumber, [ref] $number)) {
        return ConvertTo-ReviewVerdictOutcome -ExitCode 2 -Stderr "REVIEW_VERDICT_USAGE: -PrNumber must be a positive integer; got '$PrNumber'."
    }
    if ($Mode -ceq 'Review' -and [string]::IsNullOrWhiteSpace($ReviewArtifact)) {
        return ConvertTo-ReviewVerdictOutcome -ExitCode 2 -Stderr 'REVIEW_VERDICT_USAGE: -Mode Review requires -ReviewArtifact.'
    }
    if ([string]::IsNullOrEmpty($CheckpointPath)) { $CheckpointPath = $script:ReviewVerdictDefaultCheckpoint }

    $fact = @{}
    try {
        $checkpoint = $null
        if ($Mode -ceq 'Review') { $checkpoint = ConvertFrom-Json -InputObject (Read-ReviewVerdictCheckpointText -Path $CheckpointPath) -AsHashtable }
        $decision = Get-ReviewVerdictModeDecision -Mode $Mode -PrNumber $number -Checkpoint $checkpoint -ReviewArtifact $ReviewArtifact -Fact $fact
        for ($pass = 0; $null -ne $decision.Request -and $pass -lt $script:ReviewVerdictFactLimit; $pass++) {
            $request = $decision.Request
            $fact[$request.Name] = if ($request.Tool -ceq 'gh') { Invoke-ReviewVerdictGhExe -GhArgs $request.Arguments } else { Invoke-ReviewVerdictGitExe -GitArgs $request.Arguments }
            $decision = Get-ReviewVerdictModeDecision -Mode $Mode -PrNumber $number -Checkpoint $checkpoint -ReviewArtifact $ReviewArtifact -Fact $fact
        }
        if ($null -ne $decision.Request) { throw "the decision requested more than $($script:ReviewVerdictFactLimit) facts" }
        if ($decision.Code -ceq 'REVIEW_VERDICT_GIT_FAILED') { throw "$($decision.Code): $($decision.Detail)" }
        if (-not $decision.Eligible) {
            return ConvertTo-ReviewVerdictOutcome -ExitCode 3 -Stderr "REVIEW_VERDICT_NOT_ELIGIBLE: $($decision.Code): $($decision.Detail)"
        }
        $post = Invoke-ReviewVerdictGhExe -GhArgs (Get-ReviewVerdictStatusArgument -Head $decision.Detail -Description $decision.Description)
        if ([int]$post.ExitCode -ne 0) { throw "gh api POST of the status exited $($post.ExitCode)" }
    } catch {
        return ConvertTo-ReviewVerdictOutcome -ExitCode 1 -Stderr "REVIEW_VERDICT_FAILED: $($_.Exception.Message)"
    }
    return ConvertTo-ReviewVerdictOutcome -ExitCode 0 -Stdout "REVIEW_VERDICT_POSTED: review/verdict success on $($decision.Detail): $($decision.Description)"
}

# Dot-sourcing loads the functions for a test host; any other invocation runs the command.
if ($MyInvocation.InvocationName -ne '.') {
    exit (Write-ReviewVerdictOutcome -Outcome (Invoke-ReviewVerdictCli -Mode $Mode -PrNumber $PrNumber -CheckpointPath $CheckpointPath -ReviewArtifact $ReviewArtifact))
}
