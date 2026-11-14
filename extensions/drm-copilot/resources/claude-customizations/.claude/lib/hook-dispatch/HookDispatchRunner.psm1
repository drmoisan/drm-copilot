<#
.SYNOPSIS
    Runs the PreToolUse hooks a dispatcher registry selects, in process or as child processes
    (issue #1159).

.DESCRIPTION
    Invoke-HookDispatchRunner selects the registry groups whose matcher admits the tool name, in
    registry order, and runs every selected hook; it never stops at the first deny (spec D5).

    With isolation 'in-process' each hook script runs in the dispatcher process in its own script
    scope: the payload is replayed on stdin through the stdin-replayer seam, the location is
    recorded, $LASTEXITCODE is set to a sentinel, [Console]::Error and [Console]::Out are redirected
    to per-hook writers, and the script is invoked with '&'. Its stdout is the per-hook Console.Out
    writer text followed by the success, warning and information stream text; its stderr is the
    error writer text followed by any error records. A sentinel left unchanged maps to exit code 0
    and a terminating error to a non-blocking error. stdin, the writers and the location are
    restored in 'finally'. With isolation 'per-process' (the default when the registry has no
    isolation field) each hook starts as 'pwsh -NoProfile -File <hook>' through the process-starter
    seam with the payload on stdin.

    The module imports its siblings with -ErrorAction Stop: it loads HookDispatch.psm1 at load time.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'HookDispatch.psm1') -ErrorAction Stop

$script:HookDispatchExitSentinel = -1073741511

function Invoke-HookDispatchChildProcess {
    <#
    .SYNOPSIS
        Default process-starter seam: runs one hook as 'pwsh -NoProfile -File <path>' with the payload on stdin.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)] [string] $Path,
        [Parameter(Mandatory)] [AllowEmptyString()] [string] $PayloadText
    )

    $info = [System.Diagnostics.ProcessStartInfo]::new('pwsh')
    foreach ($argument in @('-NoProfile', '-File', $Path)) { $info.ArgumentList.Add($argument) }
    $info.UseShellExecute = $false
    $info.RedirectStandardInput = $true
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    $process = [System.Diagnostics.Process]::Start($info)
    try {
        $stdout = $process.StandardOutput.ReadToEndAsync()
        $stderr = $process.StandardError.ReadToEndAsync()
        $process.StandardInput.Write($PayloadText)
        $process.StandardInput.Close()
        $process.WaitForExit()
        return [pscustomobject]@{ ExitCode = $process.ExitCode; Stdout = $stdout.Result; Stderr = $stderr.Result }
    } finally {
        $process.Dispose()
    }
}

function Get-HookDispatchModuleSnapshot {
    # Loaded module instances keyed by path; a re-import yields a new instance for the same path.
    $snapshot = @{}
    foreach ($module in @(Get-Module -All)) {
        if (-not [string]::IsNullOrEmpty($module.Path)) { $snapshot["$($module.Path)|$([System.Runtime.CompilerServices.RuntimeHelpers]::GetHashCode($module))"] = $module.Path }
    }
    return $snapshot
}

function ConvertTo-HookDispatchStreamText {
    # Splits captured stream records into stdout text (success, warning, information) and error text.
    param([AllowNull()] [object[]] $Record)
    $out = [System.Text.StringBuilder]::new()
    $err = [System.Text.StringBuilder]::new()
    foreach ($item in @($Record)) {
        if ($null -eq $item) { continue }
        if ($item -is [System.Management.Automation.ErrorRecord]) { [void]$err.AppendLine([string]$item); continue }
        if ($item -is [System.Management.Automation.VerboseRecord] -or $item -is [System.Management.Automation.DebugRecord]) { continue }
        if ($item -is [System.Management.Automation.WarningRecord]) { [void]$out.AppendLine($item.Message); continue }
        if ($item -is [System.Management.Automation.InformationRecord]) { [void]$out.AppendLine([string]$item.MessageData); continue }
        [void]$out.AppendLine([string]$item)
    }
    return [pscustomobject]@{ Stdout = $out.ToString(); Stderr = $err.ToString() }
}

function Invoke-HookDispatchRunner {
    <#
    .SYNOPSIS
        Runs every registry hook selected for the payload's tool name and returns one result per hook.
    .PARAMETER Registry
        A valid registry object from Read-HookDispatchRegistry.
    .PARAMETER InvokeScript
        Script-invoker seam (in-process): receives the resolved script path. When omitted the runner
        invokes the path directly with '&'.
    .PARAMETER ReplayInput
        Stdin-replayer seam (in-process): receives the payload text and installs it as [Console]::In.
    .PARAMETER StartProcess
        Process-starter seam (per-process): receives -Path and -PayloadText and returns ExitCode,
        Stdout and Stderr.
    .OUTPUTS
        Objects with Hook (script leaf), Command, Isolation, ExitCode, Stdout, Stderr, Decision,
        Reason, AdditionalContext, Error and ModulesLoaded.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)] [AllowEmptyString()] [string] $PayloadText,
        [Parameter(Mandatory)] [pscustomobject] $Registry,
        [Parameter(Mandatory)] [AllowEmptyString()] [string] $ToolName,
        [scriptblock] $InvokeScript,
        [scriptblock] $ReplayInput = { param([string] $Text) [Console]::SetIn([System.IO.StringReader]::new($Text)) },
        [scriptblock] $StartProcess = { param([string] $Path, [string] $PayloadText) Invoke-HookDispatchChildProcess -Path $Path -PayloadText $PayloadText }
    )

    $selected = @(Select-HookDispatchHook -Registry $Registry -ToolName $ToolName)
    foreach ($hook in $selected) {
        $hookScriptPath = Resolve-HookDispatchScriptPath -Hook $hook
        $exitCode = 0; $stdout = ''; $stderr = ''; $terminating = $false; $loaded = @()

        if ($Registry.Isolation -ne 'in-process') {
            $child = & $StartProcess -Path $hookScriptPath -PayloadText $PayloadText
            $exitCode = [int]$child.ExitCode; $stdout = [string]$child.Stdout; $stderr = [string]$child.Stderr
        } else {
            $location = Get-Location
            $originalIn = [Console]::In; $originalOut = [Console]::Out; $originalError = [Console]::Error
            $outWriter = [System.IO.StringWriter]::new(); $errorWriter = [System.IO.StringWriter]::new()
            $before = Get-HookDispatchModuleSnapshot
            $captured = @()
            try {
                & $ReplayInput $PayloadText
                [Console]::SetOut($outWriter)
                [Console]::SetError($errorWriter)
                Set-Variable -Name LASTEXITCODE -Scope Global -Value $script:HookDispatchExitSentinel
                # A hook script expects the defaults of a fresh pwsh process, not this module's settings.
                Set-StrictMode -Off
                $ErrorActionPreference = 'Continue'
                if ($null -ne $InvokeScript) {
                    $captured = @(& $InvokeScript $hookScriptPath *>&1)
                } else {
                    $captured = @(& $hookScriptPath *>&1)
                }
                $lastExit = Get-Variable -Name LASTEXITCODE -Scope Global -ValueOnly -ErrorAction SilentlyContinue
                $exitCode = if ($null -eq $lastExit -or $lastExit -eq $script:HookDispatchExitSentinel) { 0 } else { [int]$lastExit }
            } catch {
                $terminating = $true
                $exitCode = 1
                $captured += $_
            } finally {
                [Console]::SetIn($originalIn)
                [Console]::SetOut($originalOut)
                [Console]::SetError($originalError)
                Set-Location -LiteralPath $location.ProviderPath
                $ErrorActionPreference = 'Stop'
                Set-StrictMode -Version Latest
            }
            $after = Get-HookDispatchModuleSnapshot
            $loaded = @($after.Keys | Where-Object { -not $before.ContainsKey($_) } | ForEach-Object { $after[$_] } | Sort-Object -Unique)
            $streams = ConvertTo-HookDispatchStreamText -Record $captured
            $stdout = $outWriter.ToString() + $streams.Stdout
            $stderr = $errorWriter.ToString() + $streams.Stderr
        }

        $normalized = ConvertTo-HookDispatchResult -ExitCode $exitCode -Stdout $stdout -Stderr $stderr -TerminatingError:$terminating
        [pscustomobject]@{
            Hook              = $hook.Leaf
            Command           = $hook.Command
            Isolation         = $Registry.Isolation
            ExitCode          = $exitCode
            Stdout            = $stdout
            Stderr            = $stderr
            Decision          = $normalized.Decision
            Reason            = $normalized.Reason
            AdditionalContext = $normalized.AdditionalContext
            Error             = $normalized.Error
            ModulesLoaded     = [string[]]$loaded
        }
    }
}

Export-ModuleMember -Function Invoke-HookDispatchRunner, Invoke-HookDispatchChildProcess
