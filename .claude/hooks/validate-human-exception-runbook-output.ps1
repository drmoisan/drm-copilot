<#
.SYNOPSIS
    SubagentStop hook for the human-exception-runbook subagent (issue #1128).

.DESCRIPTION
    Blocks termination of the human-exception-runbook subagent unless the agent's final output
    advertises a `runbook_path:` (or `runbook-path:`) value that names an existing
    `<FEATURE>/runbooks/<name>.runbook.md` file and every tool command in that runbook carries an
    honest `Version check:` marker against the lockfiles at the top level of the item worktree
    (RunbookCommandVersion.psm1). A block lists every finding so the agent can repair them in one pass.

.NOTES
    Reads the SubagentStop envelope JSON from stdin through the shared envelope helper
    (subagentstop-envelope.ps1). The item worktree is resolved through
    Resolve-SubagentStopTargetWorktree (issue #1105). Filesystem reads go through the -ReadFile,
    -TestFile and -ListRootFile seams so tests supply in-memory content. A hook dependency that
    fails to load blocks with exit 2 and the HUMAN_EXCEPTION_RUNBOOK_OUTPUT_MISSING: prefix. An
    unhandled error during validation blocks with exit 2 and a reason (issue #928).
#>

[CmdletBinding()]
param()
$script:HookDependencyGuardLoadFailed = $false; try { . (Join-Path $PSScriptRoot 'hook-dependency-guard.ps1') } catch { $script:HookDependencyGuardLoadFailed = $true }
try { . (Join-Path $PSScriptRoot 'subagentstop-envelope.ps1') } catch { Add-HookDependencyFailure -Name 'subagentstop-envelope.ps1' -ErrorRecord $_ }
try { . (Join-Path $PSScriptRoot 'subagentstop-target-worktree.ps1') } catch { Add-HookDependencyFailure -Name 'subagentstop-target-worktree.ps1' -ErrorRecord $_ }

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

try { Import-Module (Join-Path $PSScriptRoot '../lib/runbook/RunbookCommandVersion.psm1') -Force -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'RunbookCommandVersion.psm1' -ErrorRecord $_ }

$script:ReasonPrefix = 'HUMAN_EXCEPTION_RUNBOOK_OUTPUT_MISSING:'

function Get-RunbookPathFromOutput {
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [string] $AgentOutput)

    $match = [regex]::Match($AgentOutput, 'runbook[_-]path\s*[:=]\s*["'']?([^\s"''\)`]+)', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    if (-not $match.Success) { return $null }
    $value = $match.Groups[1].Value.Trim()
    if ([string]::IsNullOrWhiteSpace($value)) { return $null }
    return $value
}

function Test-IsRunbookPathShape {
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory = $true)] [string] $Path)

    $normalized = $Path -replace '\\', '/'
    return $normalized.EndsWith('.runbook.md', [System.StringComparison]::OrdinalIgnoreCase) -and
    $normalized.IndexOf('runbooks/', [System.StringComparison]::OrdinalIgnoreCase) -ge 0
}

function Get-HumanExceptionRunbookDecision {
    <#
    .SYNOPSIS
        Reads the SubagentStop envelope and validates the advertised runbook.
    .DESCRIPTION
        Returns a hashtable with Ok and Message. SessionRoot, ReadTranscriptHead, WorktreeListInvoker,
        ReadFile (path -> text or $null), TestFile (path -> bool), and ListRootFile (root -> top-level
        file names) are test seams; SessionRoot defaults to the hook process directory.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [AllowNull()] [AllowEmptyString()] [string] $InputText,
        [AllowNull()] [AllowEmptyString()] [string] $SessionRoot,
        [scriptblock] $ReadTranscriptHead,
        [scriptblock] $WorktreeListInvoker,
        [scriptblock] $ReadFile = { param($Path) if (Test-Path -LiteralPath $Path -PathType Leaf) { Get-Content -LiteralPath $Path -Raw -ErrorAction Stop } else { $null } },
        [scriptblock] $TestFile = { param($Path) [bool](Test-Path -LiteralPath $Path -PathType Leaf) },
        [scriptblock] $ListRootFile = { param($Root) @(Get-ChildItem -LiteralPath $Root -File -ErrorAction SilentlyContinue | ForEach-Object { $_.Name }) }
    )

    $dependencyDecision = Get-HookDependencyFailureDecision -HookEvent SubagentStop -ReasonPrefix $script:ReasonPrefix
    if ($null -ne $dependencyDecision) { return $dependencyDecision }
    $envelope = if ($PSBoundParameters.ContainsKey('InputText')) { Read-SubagentStopEnvelope -InputText $InputText } else { Read-SubagentStopEnvelope }
    if (-not $envelope.IsValid) { return @{ Ok = $false; Message = "$script:ReasonPrefix payload anomaly - $(Get-SubagentStopEnvelopeAnomalyReason -Anomaly $envelope.Anomaly)" } }
    $assistantMessage = [string]$envelope.AssistantText
    $runbookPath = if ([string]::IsNullOrWhiteSpace($assistantMessage)) { $null } else { Get-RunbookPathFromOutput -AgentOutput $assistantMessage }
    if ($null -eq $runbookPath) {
        return @{ Ok = $false; Message = "$script:ReasonPrefix agent output does not advertise a runbook path. Report ``runbook_path: <FEATURE>/runbooks/<name>.runbook.md`` before termination." }
    }

    $root = if ([string]::IsNullOrWhiteSpace($SessionRoot)) { (Get-Location).Path } else { $SessionRoot }
    $targetArguments = @{ Envelope = $envelope.Envelope; AdvertisedPath = @($runbookPath); SessionRoot = $root }
    if ($null -ne $ReadTranscriptHead) { $targetArguments['ReadTranscriptHead'] = $ReadTranscriptHead }
    if ($null -ne $WorktreeListInvoker) { $targetArguments['WorktreeListInvoker'] = $WorktreeListInvoker }
    $target = Resolve-SubagentStopTargetWorktree @targetArguments
    $location = Resolve-SubagentStopArtifactLocation -Path $runbookPath -WorktreeRoot $target.WorktreeRoot -SessionRoot $root
    if ($location.Rejected) {
        return @{ Ok = $false; Message = "$script:ReasonPrefix runbook path '$runbookPath' is rejected: $($location.RejectionDetail)." }
    }
    if (-not (Test-IsRunbookPathShape -Path $location.RelativePath)) {
        return @{ Ok = $false; Message = "$script:ReasonPrefix runbook path '$runbookPath' must name <FEATURE>/runbooks/<name>.runbook.md." }
    }
    if (-not [bool](& $TestFile $location.ProbePath)) {
        return @{ Ok = $false; Message = "$script:ReasonPrefix runbook path '$runbookPath' was advertised but no file exists at that location.$(Get-SubagentStopTargetNote -Target $target -ProbePath $location.ProbePath -SessionRoot $root)" }
    }
    try { $runbookText = [string](& $ReadFile $location.ProbePath) } catch { return @{ Ok = $false; Message = "$script:ReasonPrefix failed to read runbook path '$runbookPath': $($_.Exception.Message)" } }

    $pinned = @{}
    foreach ($name in @(& $ListRootFile $target.WorktreeRoot)) {
        $lockText = & $ReadFile (Resolve-SubagentStopArtifactPath -Path ([string]$name) -WorktreeRoot $target.WorktreeRoot -SessionRoot $root)
        if ($null -eq $lockText) { continue }
        foreach ($entry in (Get-RunbookPinnedToolVersion -LockfileName ([string]$name) -Content ([string]$lockText)).GetEnumerator()) {
            $pinned[$entry.Key] = $entry.Value
        }
    }

    $finding = @(Get-RunbookCommandVersionFinding -RunbookText $runbookText -PinnedVersion $pinned)
    if ($finding.Count -gt 0) {
        $list = ($finding | ForEach-Object { "- $_" }) -join "`n"
        return @{ Ok = $false; Message = "$script:ReasonPrefix runbook '$runbookPath' has $($finding.Count) tool command version finding(s); repair every one and report the path again.`n$list" }
    }
    return @{ Ok = $true; Message = $null }
}

if ($MyInvocation.InvocationName -eq '.') {
    return
}
if ($script:HookDependencyGuardLoadFailed) { [Console]::Error.WriteLine('HUMAN_EXCEPTION_RUNBOOK_OUTPUT_MISSING: hook-dependency-guard.ps1 failed to load; the gate fails closed.'); exit 2 }
$dependencyDecision = Get-HookDependencyFailureDecision -HookEvent SubagentStop -ReasonPrefix 'HUMAN_EXCEPTION_RUNBOOK_OUTPUT_MISSING:'
if ($null -ne $dependencyDecision) { [Console]::Error.WriteLine($dependencyDecision.Reason); exit $dependencyDecision.ExitCode }
try { $result = Get-HumanExceptionRunbookDecision }
catch { Exit-SubagentStopBlock -Message ('HUMAN_EXCEPTION_RUNBOOK_OUTPUT_MISSING: validator error: ' + ([string]$_.Exception.Message -split "`r?`n")[0] + '; the gate fails closed.' + "`n" + 'This condition is not repairable by the subagent. Report it to the operator and halt.') }
if (-not $result.Ok) { Exit-SubagentStopBlock -Message $result.Message }
exit 0
