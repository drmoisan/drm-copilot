
<#
.SYNOPSIS
    Pre-tool-use hook for Codex that blocks forbidden patterns in Python unit tests.

.DESCRIPTION
    This script is invoked by the Codex PreToolUse hook before any Write or Edit
    operation on a file path matching tests/**/*.py. It reads the tool input from the
    Codex tool_input environment variable (JSON with 'file_path' and a content field:
    'content' for Write, 'new_string' for Edit) and rejects the operation when the
    proposed content introduces forbidden runtime dependencies.

    Forbidden patterns in unit tests include:
      - temporary filesystem usage (tempfile, NamedTemporaryFile, TemporaryDirectory,
        mkstemp, mkdtemp, Path.touch)
      - network access (requests, httpx, urllib.request, socket, http.client)
      - subprocess execution (subprocess, os.system, os.popen)
      - time-based flakiness (time.sleep)
      - real database drivers (psycopg2, pymysql, sqlite3.connect on real files)

    If the content contains any forbidden pattern, the script writes a JSON response
    to stdout with 'decision': 'block' and exits with code 0 to let Codex surface
    the reason.

.NOTES
    Compatible with PowerShell 7+.
    This script must not modify any state; it is a read-only validation gate.
    It only inspects tool inputs targeting tests/ paths; all other paths pass through.
#>
[CmdletBinding()]
param()

function Get-PythonTestPurityBlockDecision {
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

function Test-PythonTestFilePath {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [string] $FilePath
    )

    $normalized = $FilePath -replace '\\', '/'
    return (($normalized -match '(^|/)tests/.*\.py$') -or ($normalized -match '(^|/)test_[^/]+\.py$'))
}

function Invoke-PythonTestPurityDecision {
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
    } catch {
        return Get-PythonTestPurityBlockDecision -Reason 'Python unit test purity hook received malformed JSON in Codex tool_input.'
    }

    $filePath = $toolInput.file_path
    if (-not $filePath) {
        return $null
    }

    if (-not (Test-PythonTestFilePath -FilePath $filePath)) {
        return $null
    }

    $content = $null
    if ($null -ne $toolInput.content) {
        $content = [string]$toolInput.content
    } elseif ($null -ne $toolInput.new_string) {
        $content = [string]$toolInput.new_string
    }

    if (-not $content) {
        return $null
    }

    $forbiddenPatterns = @(
        @{ Pattern = 'import\s+tempfile'; Reason = 'tempfile usage forbidden in unit tests' },
        @{ Pattern = 'from\s+tempfile\s+import'; Reason = 'tempfile usage forbidden in unit tests' },
        @{ Pattern = 'NamedTemporaryFile'; Reason = 'temporary files forbidden in unit tests' },
        @{ Pattern = 'TemporaryDirectory'; Reason = 'temporary directories forbidden in unit tests' },
        @{ Pattern = '\bmkstemp\s*\('; Reason = 'temporary files forbidden in unit tests' },
        @{ Pattern = '\bmkdtemp\s*\('; Reason = 'temporary directories forbidden in unit tests' },
        @{ Pattern = '\.touch\s*\('; Reason = 'Path.touch forbidden in unit tests' },
        @{ Pattern = 'import\s+requests\b'; Reason = 'network access forbidden in unit tests' },
        @{ Pattern = 'from\s+requests\b'; Reason = 'network access forbidden in unit tests' },
        @{ Pattern = 'import\s+httpx\b'; Reason = 'network access forbidden in unit tests' },
        @{ Pattern = 'from\s+httpx\b'; Reason = 'network access forbidden in unit tests' },
        @{ Pattern = 'urllib\.request'; Reason = 'network access forbidden in unit tests' },
        @{ Pattern = 'import\s+socket\b'; Reason = 'raw socket access forbidden in unit tests' },
        @{ Pattern = 'from\s+http\.client'; Reason = 'network access forbidden in unit tests' },
        @{ Pattern = 'import\s+subprocess\b'; Reason = 'subprocess execution forbidden in unit tests' },
        @{ Pattern = 'from\s+subprocess\s+import'; Reason = 'subprocess execution forbidden in unit tests' },
        @{ Pattern = 'os\.system\s*\('; Reason = 'os.system forbidden in unit tests' },
        @{ Pattern = 'os\.popen\s*\('; Reason = 'os.popen forbidden in unit tests' },
        @{ Pattern = 'time\.sleep\s*\('; Reason = 'time.sleep forbidden in unit tests; avoid timing hacks' },
        @{ Pattern = 'import\s+psycopg2\b'; Reason = 'real database drivers forbidden in unit tests' },
        @{ Pattern = 'import\s+pymysql\b'; Reason = 'real database drivers forbidden in unit tests' },
        @{ Pattern = 'sqlite3\.connect\s*\('; Reason = 'sqlite3.connect on real files forbidden in unit tests' }
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
    $reason = "Python unit test purity violations in '$filePath': " + ($uniqueViolations -join '; ') + ". Replace with pure code paths, dependency-injection seams, or in-memory fakes per .agents/skills/python/SKILL.md."

    return Get-PythonTestPurityBlockDecision -Reason $reason
}

function ConvertFrom-CodexPythonPurityPayload {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string] $PayloadRaw)

    if ([string]::IsNullOrWhiteSpace($PayloadRaw)) {
        throw 'check-python-test-purity hook input is empty.'
    }
    try {
        $payload = $PayloadRaw | ConvertFrom-Json -ErrorAction Stop
    } catch {
        throw "check-python-test-purity hook input is malformed JSON: $_"
    }
    if ($payload.PSObject.Properties.Name -notcontains 'tool_input' -or $null -eq $payload.tool_input) {
        throw 'check-python-test-purity hook input is missing tool_input.'
    }
    if ([string]$payload.hook_event_name -ne 'PreToolUse' -or [string]$payload.tool_name -ne 'apply_patch') {
        throw 'check-python-test-purity requires a PreToolUse apply_patch payload.'
    }
    return $payload
}

function ConvertTo-CodexPythonPurityInput {
    [CmdletBinding()]
    [OutputType([object[]])]
    param([Parameter(Mandatory)] $Payload)

    if ($Payload.tool_input.PSObject.Properties.Name -contains 'file_path') {
        return , $Payload.tool_input
    }

    $command = [string]$Payload.tool_input.command
    if ([string]::IsNullOrWhiteSpace($command)) {
        throw 'check-python-test-purity cannot map tool_input to a file edit.'
    }

    $fileMatches = [regex]::Matches(
        $command,
        '(?ms)^\*\*\* (?:Add|Update|Delete) File:\s*(?<path>.+?)\r?\n(?<body>.*?)(?=^\*\*\* (?:(?:Add|Update|Delete) File:|End Patch)\s*|\z)'
    )
    if ($fileMatches.Count -eq 0) {
        throw 'check-python-test-purity received an unrecognized apply_patch command.'
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
    $payload = ConvertFrom-CodexPythonPurityPayload -PayloadRaw ([Console]::In.ReadToEnd())
    foreach ($toolInput in @(ConvertTo-CodexPythonPurityInput -Payload $payload)) {
        $toolInputRaw = $toolInput | ConvertTo-Json -Compress -Depth 20
        $decision = Invoke-PythonTestPurityDecision -ToolInputRaw $toolInputRaw
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
