
<#
.SYNOPSIS
    Pre-tool-use hook for Codex that blocks forbidden patterns in PowerShell unit tests.

.DESCRIPTION
    This script is invoked by the Codex PreToolUse hook before any Write or Edit
    operation on a file path matching a Pester test file (*.Tests.ps1 or tests/**/*.ps1).
    It reads the tool input from the Codex tool_input environment variable (JSON with
    'file_path' and a content field: 'content' for Write, 'new_string' for Edit) and
    rejects the operation when the proposed content introduces forbidden runtime
    dependencies or violates the mocking rules.

    Forbidden patterns in Pester unit tests include:
      - direct external-executable mocking (Mock git, Mock gh, Mock actionlint, etc.)
        instead of mocking the wrapper function (Invoke-GitExe, Invoke-GhExe, etc.)
      - temporary filesystem usage (New-TemporaryFile, [System.IO.Path]::GetTempFileName,
        [System.IO.Path]::GetTempPath, $env:TEMP usage, $env:TMP usage)
      - network access (Invoke-WebRequest, Invoke-RestMethod, System.Net.Http.*,
        System.Net.WebRequest, System.Net.Sockets)
      - subprocess execution (Start-Process with raw executables)
      - time-based flakiness (Start-Sleep)

    If the content contains any forbidden pattern, the script writes a PreToolUse JSON
    response to stdout with hookSpecificOutput.permissionDecision = 'deny' and exits with
    code 0 to let Codex surface the reason.

.NOTES
    Compatible with PowerShell 7+.
    This script must not modify any state; it is a read-only validation gate.
    It only inspects tool inputs targeting Pester test paths; all other paths pass through.
#>
[CmdletBinding()]
param()

function Get-PowerShellTestPurityBlockDecision {
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory)]
        [string] $Reason
    )

    [ordered]@{
        hookSpecificOutput = [ordered]@{
            hookEventName            = 'PreToolUse'
            permissionDecision       = 'deny'
            permissionDecisionReason = $Reason
        }
    }
}

function Test-PowerShellTestFilePath {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [string] $FilePath
    )

    $normalized = $FilePath -replace '\\', '/'
    return (($normalized -match '(^|/)tests/.*\.ps1$') -or ($normalized -match '\.Tests\.ps1$'))
}

function Invoke-PowerShellTestPurityDecision {
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [string] $ToolInputRaw
    )

    if (-not $ToolInputRaw) {
        return $null
    }

    try {
        $toolInput = $ToolInputRaw | ConvertFrom-Json -ErrorAction Stop
    }
    catch {
        return $null
    }

    $filePath = $toolInput.file_path
    if (-not $filePath) {
        return $null
    }

    if (-not (Test-PowerShellTestFilePath -FilePath $filePath)) {
        return $null
    }

    $content = $null
    if ($null -ne $toolInput.content) {
        $content = [string]$toolInput.content
    }
    elseif ($null -ne $toolInput.new_string) {
        $content = [string]$toolInput.new_string
    }

    if (-not $content) {
        return $null
    }

    $forbiddenPatterns = @(
        @{ Pattern = '(?m)^\s*Mock\s+git\b'; Reason = 'direct Mock git forbidden in Pester tests; mock the Invoke-GitExe wrapper instead' },
        @{ Pattern = '(?m)^\s*Mock\s+gh\b'; Reason = 'direct Mock gh forbidden in Pester tests; mock the Invoke-GhExe wrapper instead' },
        @{ Pattern = '(?m)^\s*Mock\s+actionlint\b'; Reason = 'direct Mock actionlint forbidden in Pester tests; mock the Invoke-ActionlintExe wrapper instead' },
        @{ Pattern = "(?m)^\s*Mock\s+['""]git['""]"; Reason = 'direct Mock ''git'' forbidden in Pester tests; mock the Invoke-GitExe wrapper instead' },
        @{ Pattern = "(?m)^\s*Mock\s+['""]gh['""]"; Reason = 'direct Mock ''gh'' forbidden in Pester tests; mock the Invoke-GhExe wrapper instead' },
        @{ Pattern = '\bNew-TemporaryFile\b'; Reason = 'New-TemporaryFile forbidden in Pester unit tests' },
        @{ Pattern = '\[System\.IO\.Path\]::GetTempFileName'; Reason = 'temporary files forbidden in Pester unit tests' },
        @{ Pattern = '\[System\.IO\.Path\]::GetTempPath'; Reason = 'temp path usage forbidden in Pester unit tests' },
        @{ Pattern = '\$env:TEMP\b'; Reason = '$env:TEMP usage forbidden in Pester unit tests' },
        @{ Pattern = '\$env:TMP\b'; Reason = '$env:TMP usage forbidden in Pester unit tests' },
        @{ Pattern = '\bInvoke-WebRequest\b'; Reason = 'network access (Invoke-WebRequest) forbidden in Pester unit tests' },
        @{ Pattern = '\bInvoke-RestMethod\b'; Reason = 'network access (Invoke-RestMethod) forbidden in Pester unit tests' },
        @{ Pattern = '\[System\.Net\.Http\.'; Reason = 'System.Net.Http usage forbidden in Pester unit tests' },
        @{ Pattern = '\[System\.Net\.WebRequest\]'; Reason = 'System.Net.WebRequest usage forbidden in Pester unit tests' },
        @{ Pattern = '\[System\.Net\.Sockets\.'; Reason = 'raw socket access forbidden in Pester unit tests' },
        @{ Pattern = '\bStart-Process\b'; Reason = 'Start-Process forbidden in Pester unit tests; mock the wrapper seam instead' },
        @{ Pattern = '\bStart-Sleep\b'; Reason = 'Start-Sleep forbidden in Pester unit tests; avoid timing hacks' }
    )

    $violations = @()
    foreach ($entry in $forbiddenPatterns) {
        if ($content -match $entry.Pattern) {
            $violations += $entry.Reason
        }
    }

    if ($violations.Count -eq 0) {
        return $null
    }

    $uniqueViolations = $violations | Select-Object -Unique
    $reason = "PowerShell unit test purity violations in '$filePath': " + ($uniqueViolations -join '; ') + ". Replace with wrapper-seam mocks, in-memory fakes, or pure code paths per .agents/skills/powershell/SKILL.md."

    return Get-PowerShellTestPurityBlockDecision -Reason $reason
}

function ConvertFrom-CodexPowerShellPurityPayload {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string] $PayloadRaw)

    if ([string]::IsNullOrWhiteSpace($PayloadRaw)) {
        throw 'check-powershell-test-purity hook input is empty.'
    }
    try {
        $payload = $PayloadRaw | ConvertFrom-Json -ErrorAction Stop
    } catch {
        throw "check-powershell-test-purity hook input is malformed JSON: $_"
    }
    if ($payload.PSObject.Properties.Name -notcontains 'tool_input' -or $null -eq $payload.tool_input) {
        throw 'check-powershell-test-purity hook input is missing tool_input.'
    }
    if ([string]$payload.hook_event_name -ne 'PreToolUse' -or [string]$payload.tool_name -ne 'apply_patch') {
        throw 'check-powershell-test-purity requires a PreToolUse apply_patch payload.'
    }
    return $payload
}

function ConvertTo-CodexPowerShellPurityInput {
    [CmdletBinding()]
    [OutputType([object[]])]
    param([Parameter(Mandatory)] $Payload)

    if ($Payload.tool_input.PSObject.Properties.Name -contains 'file_path') {
        return , $Payload.tool_input
    }

    $command = [string]$Payload.tool_input.command
    if ([string]::IsNullOrWhiteSpace($command)) {
        throw 'check-powershell-test-purity cannot map tool_input to a file edit.'
    }

    $fileMatches = [regex]::Matches(
        $command,
        '(?ms)^\*\*\* (?:Add|Update|Delete) File:\s*(?<path>.+?)\r?\n(?<body>.*?)(?=^\*\*\* (?:(?:Add|Update|Delete) File:|End Patch)\s*|\z)'
    )
    if ($fileMatches.Count -eq 0) {
        throw 'check-powershell-test-purity received an unrecognized apply_patch command.'
    }

    $inputs = [System.Collections.Generic.List[object]]::new()
    foreach ($match in $fileMatches) {
        $filePath = ([string]$match.Groups['path'].Value).Trim()
        $moveMatch = [regex]::Match([string]$match.Groups['body'].Value, '(?m)^\*\*\* Move to:\s*(?<path>.+?)\s*$')
        if ($moveMatch.Success) {
            $filePath = ([string]$moveMatch.Groups['path'].Value).Trim()
        }
        $addedLines = foreach ($line in ([string]$match.Groups['body'].Value -split '\r?\n')) {
            if ($line.StartsWith('+') -and -not $line.StartsWith('+++')) {
                $line.Substring(1)
            }
        }
        $inputs.Add([pscustomobject]@{
                file_path = $filePath
                content   = $addedLines -join [Environment]::NewLine
            })
    }
    return $inputs.ToArray()
}

if ($MyInvocation.InvocationName -eq '.') {
    return
}

try {
    $payload = ConvertFrom-CodexPowerShellPurityPayload -PayloadRaw ([Console]::In.ReadToEnd())
    foreach ($toolInput in @(ConvertTo-CodexPowerShellPurityInput -Payload $payload)) {
        $toolInputRaw = $toolInput | ConvertTo-Json -Compress -Depth 20
        $decision = Invoke-PowerShellTestPurityDecision -ToolInputRaw $toolInputRaw
        if ($null -ne $decision -and $decision.hookSpecificOutput.permissionDecision -eq 'deny') {
            $decision | ConvertTo-Json -Compress -Depth 5 | Write-Output
            exit 0
        }
    }
    exit 0
} catch {
    [Console]::Error.WriteLine([string]$_)
    exit 2
}
