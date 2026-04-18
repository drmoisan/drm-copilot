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

    When the cap would be exceeded by a new file, the script emits a JSON response with
    'decision': 'block' and exits 0. The session must explicitly reset the counter by
    deleting the state file before starting a new batch. Files already counted are
    always allowed through.

.NOTES
    Compatible with PowerShell 7+.
#>
[CmdletBinding()]
param()

$toolInputRaw = $env:CLAUDE_TOOL_INPUT
if (-not $toolInputRaw) {
    exit 0
}

try {
    $toolInput = $toolInputRaw | ConvertFrom-Json -ErrorAction Stop
}
catch {
    exit 0
}

$filePath = $toolInput.file_path
if (-not $filePath) {
    exit 0
}

$normalized = $filePath -replace '\\', '/'
if ($normalized -notmatch '\.py$') {
    exit 0
}

$isTestFile = ($normalized -match '(^|/)tests/.*\.py$') -or ($normalized -match '(^|/)test_[^/]+\.py$')

$sessionId = $env:CLAUDE_SESSION_ID
if (-not $sessionId) {
    $sessionId = 'default'
}

$stateDir = Join-Path -Path (Get-Location) -ChildPath '.claude/state'
if (-not (Test-Path -Path $stateDir)) {
    New-Item -ItemType Directory -Path $stateDir -Force | Out-Null
}

$stateFile = Join-Path -Path $stateDir -ChildPath ("python-batch-budget.$sessionId.json")

$prodCap = 3
$testCap = 3
if ($env:CLAUDE_PYTHON_BUDGET_PROD -match '^\d+$') {
    $prodCap = [int]$env:CLAUDE_PYTHON_BUDGET_PROD
}
if ($env:CLAUDE_PYTHON_BUDGET_TEST -match '^\d+$') {
    $testCap = [int]$env:CLAUDE_PYTHON_BUDGET_TEST
}

$state = [ordered]@{
    prodCap   = $prodCap
    testCap   = $testCap
    prodFiles = @()
    testFiles = @()
}

if (Test-Path -Path $stateFile) {
    try {
        $loaded = Get-Content -Path $stateFile -Raw | ConvertFrom-Json -ErrorAction Stop
        if ($null -ne $loaded.prodCap) { $state.prodCap = [int]$loaded.prodCap }
        if ($null -ne $loaded.testCap) { $state.testCap = [int]$loaded.testCap }
        if ($null -ne $loaded.prodFiles) { $state.prodFiles = @($loaded.prodFiles) }
        if ($null -ne $loaded.testFiles) { $state.testFiles = @($loaded.testFiles) }
    }
    catch {
        # Corrupt state file; start fresh.
    }
}

$targetList = if ($isTestFile) { $state.testFiles } else { $state.prodFiles }
$cap = if ($isTestFile) { $state.testCap } else { $state.prodCap }
$kind = if ($isTestFile) { 'test' } else { 'production' }

if ($targetList -contains $normalized) {
    exit 0
}

if ($targetList.Count -ge $cap) {
    $currentFiles = ($targetList -join ', ')
    $reason = "Python per-batch budget exceeded: $kind file cap is $cap and is already full ($currentFiles). Requested new file: $normalized. Split the work into a new batch, raise the cap via CLAUDE_PYTHON_BUDGET_$(($kind.ToUpper()))  environment variable with approved scope, or reset the batch by deleting $stateFile."
    $response = @{
        decision = 'block'
        reason   = $reason
    } | ConvertTo-Json -Compress
    Write-Output $response
    exit 0
}

if ($isTestFile) {
    $state.testFiles = @($state.testFiles) + @($normalized)
}
else {
    $state.prodFiles = @($state.prodFiles) + @($normalized)
}

try {
    $state | ConvertTo-Json -Depth 5 | Set-Content -Path $stateFile -Encoding UTF8
}
catch {
    # Never block on state write failure.
}

exit 0
