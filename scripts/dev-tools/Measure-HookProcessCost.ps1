<#
.SYNOPSIS
    Measures the PreToolUse hook process cost per tool call for Claude Code and Codex (issue #1159).

.DESCRIPTION
    Derives four representative scenarios per runtime (Bash, a write-class call, an Agent spawn
    call and an mcp__ call) with HookProcessCost.psm1, runs each scenario the requested number of
    times, and writes a Markdown report with the hook process count per call, the summed CPU
    seconds of those processes and the wall time from first start to last exit.

    -Source Registration runs every hook whose group matcher admits the tool name as its own
    'pwsh -NoProfile -File <hook>' process, all started concurrently as the runtimes start them.
    -Source Dispatcher runs the single dispatcher registration. Each process receives the scenario
    payload on stdin. CPU seconds come from TotalProcessorTime after WaitForExit, and wall time from
    a Stopwatch. Grandchild processes (git, gh) are not counted.

    The logic is in Invoke-MeasureHookProcessCost, whose process, clock, reader and writer effects
    are [scriptblock] seams; dot-sourcing this script defines the function and runs nothing.

.PARAMETER Source
    Registration (the per-hook registrations) or Dispatcher (the single dispatcher registration).

.PARAMETER Iterations
    Number of calls measured per scenario. Default 5.

.PARAMETER OutputPath
    File the report is written to. When omitted the report lines are written to the pipeline.

.EXAMPLE
    pwsh -NoProfile -File scripts/dev-tools/Measure-HookProcessCost.ps1 -Source Registration -OutputPath out.md
#>
[CmdletBinding()]
param(
    [Parameter()] [ValidateSet('Registration', 'Dispatcher')] [string] $Source = 'Registration',
    [Parameter()] [ValidateRange(1, 1000)] [int] $Iterations = 5,
    [Parameter()] [string] $OutputPath
)

$ErrorActionPreference = 'Stop'
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'HookProcessCost.psm1') -Force

function Start-HookCostProcessSet {
    <#
    .SYNOPSIS
        Starts every hook of one scenario concurrently and returns process count, CPU and wall ticks.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)] [pscustomobject] $Scenario,
        [Parameter(Mandatory)] [string] $RepositoryRoot
    )

    $payload = Resolve-HookCostPayload -PayloadTemplate $Scenario.PayloadTemplate -RepositoryRoot $RepositoryRoot
    $clock = [System.Diagnostics.Stopwatch]::StartNew()
    $running = [System.Collections.Generic.List[object]]::new()
    foreach ($hook in @($Scenario.Hooks)) {
        $info = [System.Diagnostics.ProcessStartInfo]::new('pwsh')
        foreach ($argument in @('-NoProfile', '-File', (Join-Path -Path $RepositoryRoot -ChildPath $hook))) { $info.ArgumentList.Add($argument) }
        $info.WorkingDirectory = $RepositoryRoot
        $info.UseShellExecute = $false
        $info.RedirectStandardInput = $true
        $info.RedirectStandardOutput = $true
        $info.RedirectStandardError = $true
        $process = [System.Diagnostics.Process]::Start($info)
        $running.Add([pscustomobject]@{ Process = $process; Stdout = $process.StandardOutput.ReadToEndAsync(); Stderr = $process.StandardError.ReadToEndAsync() })
        $process.StandardInput.Write($payload)
        $process.StandardInput.Close()
    }
    $cpu = 0.0; $exitCode = 0
    foreach ($item in $running) {
        $item.Process.WaitForExit()
        [void]$item.Stdout.Result; [void]$item.Stderr.Result
        $cpu += $item.Process.TotalProcessorTime.TotalSeconds
        if ($item.Process.ExitCode -gt $exitCode) { $exitCode = $item.Process.ExitCode }
        $item.Process.Dispose()
    }
    $clock.Stop()
    return [pscustomobject]@{ ProcessCount = $running.Count; CpuSeconds = $cpu; StartTicks = 0; EndTicks = $clock.Elapsed.Ticks; ExitCode = $exitCode }
}

function Invoke-MeasureHookProcessCost {
    <#
    .SYNOPSIS
        Derives the scenarios, samples each one, and writes or returns the Markdown report.
    .DESCRIPTION
        Returns the report lines. When OutputPath is set, the lines are also passed to the
        WriteReport seam with that path. EXIT_CODE in the report is 0 when every scenario was
        measured; hook exit codes are reported per scenario.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)] [ValidateSet('Registration', 'Dispatcher')] [string] $Source,
        [Parameter(Mandatory)] [ValidateRange(1, 1000)] [int] $Iterations,
        [Parameter(Mandatory)] [string] $RepositoryRoot,
        [AllowEmptyString()] [string] $OutputPath,
        [scriptblock] $ReadText = { param([string] $Path) $full = Join-Path -Path $RepositoryRoot -ChildPath $Path; if (Test-Path -LiteralPath $full -PathType Leaf) { Get-Content -LiteralPath $full -Raw } else { $null } },
        [scriptblock] $StartHookProcess = { param($Scenario) Start-HookCostProcessSet -Scenario $Scenario -RepositoryRoot $RepositoryRoot },
        [scriptblock] $GetTimestamp = { [DateTime]::UtcNow.ToString('yyyy-MM-ddTHH-mm') },
        [scriptblock] $WriteReport = { param([string] $Path, [string[]] $Lines) Set-Content -LiteralPath $Path -Value $Lines -Encoding utf8 }
    )

    $scenarios = @(Get-HookCostScenario -Source $Source -ReadText $ReadText)
    $samples = [System.Collections.Generic.List[object]]::new()
    foreach ($scenario in $scenarios) {
        foreach ($sample in @(Measure-HookCostSample -Scenario $scenario -Iterations $Iterations -StartHookProcess $StartHookProcess -GetTimestamp $GetTimestamp)) { $samples.Add($sample) }
    }
    $summary = @(Get-HookCostSummary -Samples $samples.ToArray())
    $command = "pwsh -NoProfile -File scripts/dev-tools/Measure-HookProcessCost.ps1 -Source $Source -Iterations $Iterations"
    $lines = [string[]]@(Format-HookCostReport -Source $Source -Summary $summary -Scenarios $scenarios -Timestamp ([string](& $GetTimestamp)) -Command $command -ExitCode 0 -Iterations $Iterations)
    if (-not [string]::IsNullOrEmpty($OutputPath)) { & $WriteReport $OutputPath $lines }
    return $lines
}

if ($MyInvocation.InvocationName -eq '.') {
    return
}

$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '../..')).ProviderPath
$report = Invoke-MeasureHookProcessCost -Source $Source -Iterations $Iterations -RepositoryRoot $repositoryRoot -OutputPath $OutputPath
if ([string]::IsNullOrEmpty($OutputPath)) { $report }
