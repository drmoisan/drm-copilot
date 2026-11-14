<#
.SYNOPSIS
    Pre-tool-use hook that keeps test suites on the test-execution launcher (issue #1158).

.DESCRIPTION
    Invoked by the Claude Code PreToolUse hook on the "Bash" matcher and on the
    mcp__drm-copilot__run_poshqc_test and mcp__drm-copilot__run_poshqc_suite matcher. For a Bash
    call, every command record of Read-CommandLineInvocationSegment is normalized by
    test-execution-command-form.ps1 (spec D25), and the hook denies a direct test runner, a hidden
    wrapper script that starts a suite, a launcher or runner call that selects an excluded local
    lane or a worker-reduction token, a launcher seam-variable override (D33), and every test
    command while config/test-execution-policy.json is invalid. The sanctioned launcher
    (run-test-suite.sh or Invoke-TestSuite.ps1 under .claude or .agents) is allowed, also while
    the machine test-suite lock is busy, because the launcher itself queues. For the two PoshQC
    MCP tools the hook denies while the lock is busy.

    Deny reasons start TEST_EXECUTION_POLICY_BLOCKED:, contain "test-execution policy", and name
    the launcher command. An allow writes nothing. A malformed payload fails open (policy-level
    guard, not a security control); a dependency load failure denies through the guard.

.NOTES
    Compatible with PowerShell 7+. Invokes no Python or test runner.
#>
[CmdletBinding()]
param()
$script:HookDependencyGuardLoadFailed = $false; try { . (Join-Path $PSScriptRoot 'hook-dependency-guard.ps1') } catch { $script:HookDependencyGuardLoadFailed = $true }

try { Import-Module (Join-Path $PSScriptRoot '../lib/hook-payload/HookPayload.psm1') -Force -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'HookPayload.psm1' -ErrorRecord $_ }
try { . (Join-Path $PSScriptRoot 'hook-command-scanner.ps1') } catch { Add-HookDependencyFailure -Name 'hook-command-scanner.ps1' -ErrorRecord $_ }
try { . (Join-Path $PSScriptRoot 'hook-command-invocation.ps1') } catch { Add-HookDependencyFailure -Name 'hook-command-invocation.ps1' -ErrorRecord $_ }
try { . (Join-Path $PSScriptRoot 'test-execution-policy.ps1') } catch { Add-HookDependencyFailure -Name 'test-execution-policy.ps1' -ErrorRecord $_ }
try { . (Join-Path $PSScriptRoot 'test-execution-lock-decision.ps1') } catch { Add-HookDependencyFailure -Name 'test-execution-lock-decision.ps1' -ErrorRecord $_ }
try { . (Join-Path $PSScriptRoot 'test-execution-lock.ps1') } catch { Add-HookDependencyFailure -Name 'test-execution-lock.ps1' -ErrorRecord $_ }
try { . (Join-Path $PSScriptRoot 'test-execution-command-form.ps1') } catch { Add-HookDependencyFailure -Name 'test-execution-command-form.ps1' -ErrorRecord $_ }

$script:TestExecutionHookRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$script:TestExecutionLauncherCommand = 'sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh'
$script:TestExecutionMcpToolName = @('mcp__drm-copilot__run_poshqc_test', 'mcp__drm-copilot__run_poshqc_suite')
$script:TestExecutionScriptReadLimit = 262144

function Get-TestExecutionLauncherHint {
    <#
    .SYNOPSIS
        Return the launcher command for a runner (D20): the first policy suite with that runner, or
        the launcher with the known suite names when none has it.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([AllowEmptyString()][string] $Runner, [AllowNull()][System.Collections.IDictionary] $Policy)

    $suite = ''
    if ($null -ne $Policy -and -not [string]::IsNullOrEmpty($Runner)) { $suite = Get-TestExecutionRunnerSuite -Runner $Runner -Policy $Policy }
    if (-not [string]::IsNullOrEmpty($suite)) { return "$script:TestExecutionLauncherCommand $suite" }
    $known = if ($null -ne $Policy) { @($Policy['suites'].Keys) -join ', ' } else { 'pytest, pester, jest, dotnet-test' }
    return "$script:TestExecutionLauncherCommand followed by one of the suites $known"
}

function Get-TestExecutionHolderClause {
    <#
    .SYNOPSIS
        Return '; the machine test-suite lock is held by ...' when the probe reports busy, else ''.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowNull()][System.Collections.IDictionary] $Policy,
        [Parameter(Mandatory)][scriptblock] $ProbeLock,
        [Parameter(Mandatory)][scriptblock] $ReadHolderText,
        [Parameter(Mandatory)][scriptblock] $GetProcessStartUtc
    )

    if ($null -ne $Policy -and -not [bool]$Policy['machineLock']['enabled']) { return '' }
    if ([string](& $ProbeLock) -ne 'Busy') { return '' }
    $holder = ConvertFrom-TestExecutionHolderText -Text ([string](& $ReadHolderText))
    $start = $null
    if ($holder.State -eq 'Parsed') { $start = & $GetProcessStartUtc ([int]$holder.Record['pid']) }
    $description = Get-TestExecutionLockHolderDescription -HolderRecord $holder -ProcessStartUtc $start -CurrentProcessId $PID
    return "; the machine test-suite lock is held by $description"
}

function Get-TestExecutionClassifierReason {
    <#
    .SYNOPSIS
        Return the lane or worker-token deny reason for a runner's words, or $null.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][System.Collections.IDictionary] $Policy,
        [Parameter(Mandatory)][string] $Runner,
        [AllowEmptyCollection()][AllowEmptyString()][string[]] $Word = @(),
        [Parameter(Mandatory)][string] $Hint,
        [switch] $CheckWorker
    )

    $lane = Get-TestExecutionLaneSelection -Policy $Policy -Runner $Runner -ArgumentList $Word
    if ($lane) { return "TEST_EXECUTION_POLICY_BLOCKED: local $lane lane is CI-only evidence (test-execution policy); run $Hint without selecting it." }
    if ($CheckWorker) {
        $token = Get-TestExecutionWorkerReductionToken -Runner $Runner -ArgumentList $Word
        if ($token) { return "TEST_EXECUTION_POLICY_BLOCKED: worker-reduction token '$token' is not allowed (test-execution policy); the machine test-suite lock serializes suites, so run $Hint without it." }
    }
    return $null
}

function Get-TestExecutionWrapperReason {
    <#
    .SYNOPSIS
        Read a script-file operand through the seams and return the hidden-wrapper or seam-override
        deny reason, or $null. An unreadable or oversized file is allowed.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][pscustomobject] $Operand,
        [AllowEmptyString()][string] $Cwd = '',
        [AllowNull()][System.Collections.IDictionary] $Policy,
        [Parameter(Mandatory)][scriptblock] $GetScriptFileLength,
        [Parameter(Mandatory)][scriptblock] $ReadScriptText
    )

    $path = [string]$Operand.Path
    if (-not [System.IO.Path]::IsPathRooted($path) -and -not [string]::IsNullOrEmpty($Cwd)) { $path = Join-Path $Cwd $path }
    try {
        $length = & $GetScriptFileLength $path
        if ($null -eq $length -or [long]$length -gt $script:TestExecutionScriptReadLimit) { return $null }
        $text = [string](& $ReadScriptText $path)
    } catch {
        return $null
    }
    if (Get-TestExecutionSeamOverrideMatch -Text $text) {
        return "TEST_EXECUTION_POLICY_BLOCKED: launcher seam override in $($Operand.Path) (test-execution policy); run $script:TestExecutionLauncherCommand without TestSuiteLauncherSeams or PesterSuiteSeams."
    }
    $runner = Get-TestExecutionHiddenWrapperMatch -Language $Operand.Language -Text $text
    if (-not $runner) { return $null }
    return "TEST_EXECUTION_POLICY_BLOCKED: hidden wrapper suite launch in $($Operand.Path) (test-execution policy); run $(Get-TestExecutionLauncherHint -Runner $runner -Policy $Policy) instead."
}

function Get-TestExecutionBashDenyReason {
    <#
    .SYNOPSIS
        Return the deny reason for a Bash command text, or $null to allow.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowEmptyString()][string] $CommandText,
        [AllowEmptyString()][string] $Cwd = '',
        [AllowNull()][System.Collections.IDictionary] $Policy,
        [AllowEmptyString()][string] $PolicyError = '',
        [Parameter(Mandatory)][scriptblock] $ProbeLock,
        [Parameter(Mandatory)][scriptblock] $ReadHolderText,
        [Parameter(Mandatory)][scriptblock] $GetProcessStartUtc,
        [Parameter(Mandatory)][scriptblock] $GetScriptFileLength,
        [Parameter(Mandatory)][scriptblock] $ReadScriptText
    )

    if ([string]::IsNullOrWhiteSpace($CommandText)) { return $null }
    $requireLauncher = $true
    if ($null -ne $Policy) { $requireLauncher = [bool]$Policy['requireLauncher'] }
    $configReason = "$PolicyError Fix the file, then run $script:TestExecutionLauncherCommand."
    $holderSeams = @{ Policy = $Policy; ProbeLock = $ProbeLock; ReadHolderText = $ReadHolderText; GetProcessStartUtc = $GetProcessStartUtc }

    foreach ($entry in @(Get-TestExecutionCommandRecord -CommandText $CommandText)) {
        $record = $entry.Record
        $form = $entry.Form
        $hostLed = $form.Words.Count -gt 0 -and @('pwsh', 'powershell') -contains (ConvertTo-TestExecutionLeafWord -Word $form.Words[0])
        if (($record.Dialect -eq 'PowerShell' -or $hostLed) -and (Get-TestExecutionSeamOverrideMatch -Text $record.RawText)) {
            return "TEST_EXECUTION_POLICY_BLOCKED: launcher seam override (test-execution policy); run $script:TestExecutionLauncherCommand without TestSuiteLauncherSeams or PesterSuiteSeams."
        }
        if ($record.Opaque -and $record.OpaqueReason -eq 'DecodeFailure') {
            $visibleRunner = @($script:TestExecutionRunnerWord.Keys | Where-Object { Test-CommandLineWordPresent -RawText $record.RawText -Word $_ } | Select-Object -First 1)
            if ($visibleRunner.Count -eq 0) { continue }
            if ($PolicyError) { return $configReason }
            if (-not $requireLauncher) { continue }
            $runner = $script:TestExecutionRunnerWord[$visibleRunner[0]]
            return "TEST_EXECUTION_POLICY_BLOCKED: test suites run only through the test-execution launcher (test-execution policy); run $(Get-TestExecutionLauncherHint -Runner $runner -Policy $Policy) instead$(Get-TestExecutionHolderClause @holderSeams)."
        }

        $launcher = Get-TestExecutionLauncherMatch -Form $form
        if ($null -ne $launcher) {
            if ($PolicyError) { return $configReason }
            if (-not $Policy['suites'].Contains($launcher.Suite)) { continue }
            $runner = [string]$Policy['suites'][$launcher.Suite]['runner']
            $reason = Get-TestExecutionClassifierReason -Policy $Policy -Runner $runner -Word $launcher.Extras -Hint "$script:TestExecutionLauncherCommand $($launcher.Suite)" -CheckWorker
            if ($reason) { return $reason }
            continue
        }

        $runner = Get-TestExecutionRunnerMatch -Form $form -CommandText $CommandText
        if ($runner) {
            if ($PolicyError) { return $configReason }
            $hint = Get-TestExecutionLauncherHint -Runner $runner -Policy $Policy
            $reason = Get-TestExecutionClassifierReason -Policy $Policy -Runner $runner -Word ([string[]]@($form.Words | Select-Object -Skip 1)) -Hint $hint
            if ($reason) { return $reason }
            if (-not $requireLauncher) { continue }
            return "TEST_EXECUTION_POLICY_BLOCKED: test suites run only through the test-execution launcher (test-execution policy); run $hint instead$(Get-TestExecutionHolderClause @holderSeams)."
        }

        if (-not $requireLauncher) { continue }
        $operand = Get-TestExecutionScriptOperand -Form $form
        if ($null -eq $operand) { continue }
        $reason = Get-TestExecutionWrapperReason -Operand $operand -Cwd $Cwd -Policy $Policy -GetScriptFileLength $GetScriptFileLength -ReadScriptText $ReadScriptText
        if ($reason) { return $reason }
    }
    return $null
}

function Invoke-TestExecutionPolicyDecision {
    <#
    .SYNOPSIS
        Parse the PreToolUse payload and return a deny decision, or $null to allow.
    .PARAMETER ToolInputRaw
        The raw PreToolUse JSON envelope.
    .PARAMETER ReadConfigText
        Seam returning the text of config/test-execution-policy.json, or $null when it is absent.
    .PARAMETER ProbeLock
        Seam returning Free or Busy for the machine test-suite lock.
    .PARAMETER ReadHolderText
        Seam returning the holder record text, or $null.
    .PARAMETER GetProcessStartUtc
        Seam returning the UTC start time of a process id, or $null.
    .PARAMETER GetScriptFileLength
        Seam returning the byte length of a script file, or $null when it does not exist.
    .PARAMETER ReadScriptText
        Seam returning the text of a script file; called only for a file of at most 262144 bytes.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [AllowNull()][AllowEmptyString()][string] $ToolInputRaw,
        [scriptblock] $ReadConfigText = {
            $path = Join-Path $script:TestExecutionHookRoot 'config/test-execution-policy.json'
            if (Test-Path -LiteralPath $path -PathType Leaf) { Get-Content -LiteralPath $path -Raw } else { $null }
        },
        [scriptblock] $ProbeLock = {
            $opened = Open-TestExecutionLock -Directory (Get-TestExecutionCurrentLockDirectory)
            if ($null -ne $opened.Stream) { $opened.Stream.Dispose() }
            $opened.Result
        },
        [scriptblock] $ReadHolderText = { Read-TestExecutionHolderText -Directory (Get-TestExecutionCurrentLockDirectory) },
        [scriptblock] $GetProcessStartUtc = { param([int] $Id) Get-TestExecutionProcessStartTime -ProcessId $Id },
        [scriptblock] $GetScriptFileLength = { param([string] $Path) if (Test-Path -LiteralPath $Path -PathType Leaf) { (Get-Item -LiteralPath $Path).Length } else { $null } },
        [scriptblock] $ReadScriptText = { param([string] $Path) Get-Content -LiteralPath $Path -Raw }
    )

    $dependencyDecision = Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix 'TEST_EXECUTION_POLICY_BLOCKED:'
    if ($null -ne $dependencyDecision) { return $dependencyDecision }
    if ([string]::IsNullOrWhiteSpace($ToolInputRaw)) { return $null }
    try { $payload = $ToolInputRaw | ConvertFrom-Json -ErrorAction Stop } catch { return $null }
    $toolName = [string](Get-ClaudeHookEnvelopeValue -Envelope $payload -Name 'tool_name')
    $toolInput = Get-ClaudeHookEnvelopeValue -Envelope $payload -Name 'tool_input'
    $commandText = ''
    if ($null -ne $toolInput) { $commandText = [string](Get-ClaudeHookEnvelopeValue -Envelope $toolInput -Name 'command') }
    $cwd = [string](Get-ClaudeHookEnvelopeValue -Envelope $payload -Name 'cwd')
    $reason = Get-TestExecutionPolicyDenyReason -ToolName $toolName -CommandText $commandText -Cwd $cwd -ReadConfigText $ReadConfigText -ProbeLock $ProbeLock -ReadHolderText $ReadHolderText -GetProcessStartUtc $GetProcessStartUtc -GetScriptFileLength $GetScriptFileLength -ReadScriptText $ReadScriptText
    if ($null -eq $reason) { return $null }
    return [ordered]@{
        hookSpecificOutput = [ordered]@{
            hookEventName            = 'PreToolUse'
            permissionDecision       = 'deny'
            permissionDecisionReason = $reason
        }
    }
}

function Get-TestExecutionPolicyDenyReason {
    <#
    .SYNOPSIS
        Return the deny reason for one tool call (Bash command or PoshQC MCP tool), or $null.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowEmptyString()][string] $ToolName = '',
        [AllowEmptyString()][string] $CommandText = '',
        [AllowEmptyString()][string] $Cwd = '',
        [Parameter(Mandatory)][scriptblock] $ReadConfigText,
        [Parameter(Mandatory)][scriptblock] $ProbeLock,
        [Parameter(Mandatory)][scriptblock] $ReadHolderText,
        [Parameter(Mandatory)][scriptblock] $GetProcessStartUtc,
        [Parameter(Mandatory)][scriptblock] $GetScriptFileLength,
        [Parameter(Mandatory)][scriptblock] $ReadScriptText
    )

    $isMcp = $script:TestExecutionMcpToolName -contains $ToolName
    if (-not $isMcp -and $ToolName -like 'mcp__*') { return $null }
    if (-not $isMcp -and [string]::IsNullOrWhiteSpace($CommandText)) { return $null }
    $policy = $null
    $policyError = ''
    try {
        $configText = & $ReadConfigText
        $policy = Get-TestExecutionPolicy -ReadText { $configText }
    } catch {
        $policyError = $_.Exception.Message
    }
    $holderSeams = @{ Policy = $policy; ProbeLock = $ProbeLock; ReadHolderText = $ReadHolderText; GetProcessStartUtc = $GetProcessStartUtc }
    if ($isMcp) {
        if ($policyError) { return "$policyError Fix the file, then run $script:TestExecutionLauncherCommand pester." }
        $clause = Get-TestExecutionHolderClause @holderSeams
        if (-not $clause) { return $null }
        return "TEST_EXECUTION_POLICY_BLOCKED: $ToolName does not run while another suite holds the lock (test-execution policy)$clause; retry later, or run $script:TestExecutionLauncherCommand pester, which waits for the lock."
    }
    return (Get-TestExecutionBashDenyReason -CommandText $CommandText -Cwd $Cwd -Policy $policy -PolicyError $policyError @holderSeams -GetScriptFileLength $GetScriptFileLength -ReadScriptText $ReadScriptText)
}

function Invoke-TestExecutionPolicyEntryPoint {
    <#
    .SYNOPSIS
        Read the payload and return the deny JSON text, or $null to allow.
    .PARAMETER ReadPayload
        Seam for the payload read. Default is Read-ClaudeHookRawPayload (stdin first).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([scriptblock] $ReadPayload = { Read-ClaudeHookRawPayload })

    $decision = Invoke-TestExecutionPolicyDecision -ToolInputRaw ([string](& $ReadPayload))
    if ($null -eq $decision) { return $null }
    return ($decision | ConvertTo-Json -Compress -Depth 5)
}

# Allow dot-sourcing in tests without executing the entry point.
if ($MyInvocation.InvocationName -eq '.') {
    return
}
if ($script:HookDependencyGuardLoadFailed) { [Console]::Error.WriteLine('TEST_EXECUTION_POLICY_BLOCKED: hook-dependency-guard.ps1 failed to load; the gate fails closed.'); exit 2 }
$dependencyDecision = Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix 'TEST_EXECUTION_POLICY_BLOCKED:'
if ($null -ne $dependencyDecision) { $dependencyDecision | ConvertTo-Json -Compress -Depth 5 | Write-Output; exit 0 }

$denyJson = Invoke-TestExecutionPolicyEntryPoint
if ($null -ne $denyJson) { $denyJson | Write-Output }
exit 0
