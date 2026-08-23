<#
.SYNOPSIS
    Pre-tool-use hook that enforces the Python per-batch change budget.

.DESCRIPTION
    This script is invoked by the Claude Code PreToolUse hook before any Write or Edit
    operation. When the target file is a Python file, it classifies the file as either
    production or test and checks the running count against the per-batch cap:
      - 3 production .py files per batch
      - 3 test .py files per batch

    A "batch" is scoped to the current Claude Code session. The running count is
    persisted under .claude/state/python-batch-budget.<session_id>.json. Only distinct
    file paths are counted; repeated edits to the same file consume one slot.

    Test files are those matching:
      - tests/**/*.py
      - test_*.py

    All other .py files are treated as production files. Non-Python paths pass through.

    The cap may be overridden per session by setting the environment variable
    CLAUDE_PYTHON_BUDGET_PROD or CLAUDE_PYTHON_BUDGET_TEST to a positive integer before
    the session starts, or by writing {"prodCap": N, "testCap": M} into the state file.

    When the cap would be exceeded by a new file, the script emits a PreToolUse JSON
    response with hookSpecificOutput.permissionDecision = 'deny' and exits 0. The session
    must explicitly reset the counter by deleting the state file before starting a new
    batch. Files already counted are always allowed through.

.NOTES
    Compatible with PowerShell 7+.
#>
[CmdletBinding()]
param()


Import-Module (Join-Path $PSScriptRoot '../lib/hook-payload/HookPayload.psm1') -Force
function Get-PythonBatchBudgetState {
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory)]
        [int] $ProdCap,

        [Parameter(Mandatory)]
        [int] $TestCap
    )

    [ordered]@{
        prodCap   = $ProdCap
        testCap   = $TestCap
        prodFiles = @()
        testFiles = @()
    }
}

function ConvertTo-PythonBatchBudgetState {
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory)]
        $InputObject,

        [Parameter(Mandatory)]
        [int] $ProdCap,

        [Parameter(Mandatory)]
        [int] $TestCap
    )

    $state = Get-PythonBatchBudgetState -ProdCap $ProdCap -TestCap $TestCap
    if ($null -ne $InputObject.prodCap) { $state.prodCap = [int]$InputObject.prodCap }
    if ($null -ne $InputObject.testCap) { $state.testCap = [int]$InputObject.testCap }
    if ($null -ne $InputObject.prodFiles) { $state.prodFiles = @($InputObject.prodFiles) }
    if ($null -ne $InputObject.testFiles) { $state.testFiles = @($InputObject.testFiles) }

    return $state
}

function Get-PythonBatchBudgetBlockDecision {
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory)]
        [string] $Reason,

        [System.Collections.IDictionary] $State
    )

    $decision = [ordered]@{
        hookSpecificOutput = [ordered]@{
            hookEventName            = 'PreToolUse'
            permissionDecision       = 'deny'
            permissionDecisionReason = $Reason
        }
    }
    if ($State) {
        $decision.state = $State
    }

    return $decision
}

function Invoke-PythonBatchBudgetDecision {
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory)]
        [string] $FilePath,

        [Parameter(Mandatory)]
        [System.Collections.IDictionary] $State,

        [Parameter(Mandatory)]
        [string] $StateFile
    )

    $normalized = $FilePath -replace '\\', '/'
    if ($normalized -notmatch '\.py$') {
        return [ordered]@{ hookSpecificOutput = [ordered]@{ hookEventName = 'PreToolUse'; permissionDecision = 'allow' }; state = $State; shouldWriteState = $false }
    }

    $isTestFile = ($normalized -match '(^|/)tests/.*\.py$') -or ($normalized -match '(^|/)test_[^/]+\.py$')
    $targetList = if ($isTestFile) { @($State.testFiles) } else { @($State.prodFiles) }
    $cap = if ($isTestFile) { [int]$State.testCap } else { [int]$State.prodCap }
    $kind = if ($isTestFile) { 'test' } else { 'production' }

    if ($targetList -contains $normalized) {
        return [ordered]@{ hookSpecificOutput = [ordered]@{ hookEventName = 'PreToolUse'; permissionDecision = 'allow' }; state = $State; shouldWriteState = $false }
    }

    if ($targetList.Count -ge $cap) {
        $currentFiles = ($targetList -join ', ')
        $kindUpper = $kind.ToUpperInvariant()
        $reason = "Python per-batch budget exceeded: $kind file cap is $cap and is already full ($currentFiles). Requested new file: $normalized. Split the work into a new batch, raise the cap via CLAUDE_PYTHON_BUDGET_$kindUpper environment variable with approved scope, or reset the batch by deleting $StateFile."
        return Get-PythonBatchBudgetBlockDecision -Reason $reason -State $State
    }

    if ($isTestFile) {
        $State.testFiles = @($State.testFiles) + @($normalized)
    } else {
        $State.prodFiles = @($State.prodFiles) + @($normalized)
    }

    return [ordered]@{ hookSpecificOutput = [ordered]@{ hookEventName = 'PreToolUse'; permissionDecision = 'allow' }; state = $State; shouldWriteState = $true }
}

function Invoke-PythonBatchBudgetHook {
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [string] $ToolInputRaw,
        [string] $SessionId = 'default',
        [string] $Root = (Get-Location).Path,
        [int] $ProdCap = 3,
        [int] $TestCap = 3,
        [scriptblock] $TestPathExists = { param([string] $Path) Test-Path -Path $Path },
        [scriptblock] $EnsureDirectory = { param([string] $Path) New-Item -ItemType Directory -Path $Path -Force | Out-Null },
        [scriptblock] $ReadState = { param([string] $Path) Get-Content -Path $Path -Raw },
        [scriptblock] $WriteState = {
            param([string] $Path, [System.Collections.IDictionary] $State)
            $State | ConvertTo-Json -Depth 5 | Set-Content -Path $Path -Encoding UTF8
        }
    )

    $payload = Resolve-ClaudeHookToolInput -Raw $ToolInputRaw
    if (-not $payload.IsValid) {
        return Get-PythonBatchBudgetBlockDecision -Reason (
            'Python batch-budget hook received an unreadable PreToolUse envelope: ' +
            (Get-ClaudeHookPayloadAnomalyReason -Anomaly $payload.Anomaly) +
            '. The gate fails closed on an envelope it cannot read.')
    }

    $filePath = Get-ClaudeHookToolInputString -ToolInput $payload.Value -Name 'file_path'
    if (-not $filePath) {
        return [ordered]@{ hookSpecificOutput = [ordered]@{ hookEventName = 'PreToolUse'; permissionDecision = 'allow' } }
    }

    $normalized = $filePath -replace '\\', '/'
    if ($normalized -notmatch '\.py$') {
        return [ordered]@{ hookSpecificOutput = [ordered]@{ hookEventName = 'PreToolUse'; permissionDecision = 'allow' } }
    }

    $stateDir = Join-Path -Path $Root -ChildPath '.claude/state'
    if (-not (& $TestPathExists $stateDir)) {
        & $EnsureDirectory $stateDir
    }

    $stateFile = Join-Path -Path $stateDir -ChildPath ("python-batch-budget.$SessionId.json")
    $state = Get-PythonBatchBudgetState -ProdCap $ProdCap -TestCap $TestCap

    if (& $TestPathExists $stateFile) {
        try {
            $loaded = & $ReadState $stateFile | ConvertFrom-Json -ErrorAction Stop
            $state = ConvertTo-PythonBatchBudgetState -InputObject $loaded -ProdCap $ProdCap -TestCap $TestCap
        } catch {
            Write-Verbose "Ignoring unreadable Python batch-budget state file '$stateFile': $($_.Exception.Message)"
        }
    }

    $decision = Invoke-PythonBatchBudgetDecision -FilePath $filePath -State $state -StateFile $stateFile
    if ($decision.shouldWriteState) {
        try {
            & $WriteState $stateFile $decision.state
        } catch {
            Write-Verbose "Unable to write Python batch-budget state file '$stateFile': $($_.Exception.Message)"
        }
    }

    return $decision
}

function Invoke-PythonBatchBudgetEntryPoint {
    <#
    .SYNOPSIS
        Runs the Python batch-budget decision and returns the process exit code.
    .DESCRIPTION
        Wraps the dispatch logic that the hook entry point performs so it can be
        exercised by unit tests. It acquires the payload through the shared reader
        unless the caller supplies one, writes the compact JSON decision to the output
        stream only when the decision is a deny (this hook is deny-only: an allow
        decision emits nothing), and returns 0. This function does not call exit; the
        thin entry-point wiring converts the returned code into a process exit.
    .PARAMETER ToolInputRaw
        Optional pre-acquired payload text. When omitted the ReadPayload seam runs.
    .PARAMETER ReadPayload
        Seam for payload acquisition, so tests can drive the empty-on-all-transports
        case without touching a console.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        [string] $ToolInputRaw,

        [scriptblock] $ReadPayload = { Read-ClaudeHookRawPayload }
    )

    if (-not $PSBoundParameters.ContainsKey('ToolInputRaw')) {
        $ToolInputRaw = [string](& $ReadPayload)
    }

    $sessionId = $env:CLAUDE_SESSION_ID
    if (-not $sessionId) {
        $sessionId = 'default'
    }

    $prodCap = 3
    $testCap = 3
    if ($env:CLAUDE_PYTHON_BUDGET_PROD -match '^\d+$') {
        $prodCap = [int]$env:CLAUDE_PYTHON_BUDGET_PROD
    }
    if ($env:CLAUDE_PYTHON_BUDGET_TEST -match '^\d+$') {
        $testCap = [int]$env:CLAUDE_PYTHON_BUDGET_TEST
    }

    $decision = Invoke-PythonBatchBudgetHook -ToolInputRaw $ToolInputRaw -SessionId $sessionId -ProdCap $prodCap -TestCap $testCap
    if ($decision.hookSpecificOutput.permissionDecision -eq 'deny') {
        $decision.Remove('state')
        $decision | ConvertTo-Json -Compress -Depth 5 | Write-Output
    }

    return 0
}

# Guard allows dot-sourcing in tests without executing the entrypoint.
if ($MyInvocation.InvocationName -eq '.') {
    return
}

# The entry point returns its [int] exit code as the last pipeline element and the
# decision JSON before it. `exit (<call>)` would capture BOTH into the exit
# expression and emit nothing, so the decision is written explicitly here first.
$entryPointResult = @(Invoke-PythonBatchBudgetEntryPoint)
if ($entryPointResult.Count -gt 1) {
    $entryPointResult[0..($entryPointResult.Count - 2)] | Write-Output
}

exit ([int]$entryPointResult[-1])
