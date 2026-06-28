<#
.SYNOPSIS
    Pester tests for the check-python-test-purity.ps1 Claude Code hook.

.DESCRIPTION
    Verifies the PreToolUse deny schema: blocked content yields a decision whose
    hookSpecificOutput.permissionDecision is 'deny', and allow paths return no
    decision ($null), which is a valid allow at PreToolUse. No disk, network, or
    temporary-file use.
#>

Set-StrictMode -Version Latest

Describe 'check-python-test-purity.ps1' {
    BeforeAll {
        $script:ScriptPath = Join-Path -Path $PSScriptRoot -ChildPath '..' -AdditionalChildPath '..', '..', '.claude', 'hooks', 'check-python-test-purity.ps1'
        $script:ScriptPath = (Resolve-Path $script:ScriptPath).Path
        . $script:ScriptPath

        function Get-PythonPurityInput {
            param(
                [Parameter(Mandatory)]
                [string] $FilePath,

                [string] $Content,

                [string] $NewString
            )

            $payload = [ordered]@{ file_path = $FilePath }
            if ($PSBoundParameters.ContainsKey('Content')) {
                $payload.content = $Content
            }
            if ($PSBoundParameters.ContainsKey('NewString')) {
                $payload.new_string = $NewString
            }

            return ($payload | ConvertTo-Json -Compress)
        }
    }

    AfterEach {
        $env:CLAUDE_TOOL_INPUT = $null
    }

    It 'allows (no decision) missing tool input and missing file path' {
        $emptyResult = Invoke-PythonTestPurityDecision -ToolInputRaw ''
        $missingPathResult = Invoke-PythonTestPurityDecision -ToolInputRaw '{}'

        $emptyResult | Should -BeNullOrEmpty
        $missingPathResult | Should -BeNullOrEmpty
    }

    It 'allows (no decision) safe Python test content' {
        $inputJson = Get-PythonPurityInput -FilePath 'tests/unit/test_safe.py' -Content 'def test_value(): assert 1 == 1'

        $result = Invoke-PythonTestPurityDecision -ToolInputRaw $inputJson

        $result | Should -BeNullOrEmpty
    }

    It 'allows (no decision) empty content and empty new_string edits' {
        $contentResult = Invoke-PythonTestPurityDecision -ToolInputRaw (Get-PythonPurityInput -FilePath 'tests/unit/test_empty.py' -Content '')
        $newStringResult = Invoke-PythonTestPurityDecision -ToolInputRaw (Get-PythonPurityInput -FilePath 'tests/unit/test_empty.py' -NewString '')

        $contentResult | Should -BeNullOrEmpty
        $newStringResult | Should -BeNullOrEmpty
    }

    It 'ignores (no decision) non-test and non-Python file paths' {
        $sourceResult = Invoke-PythonTestPurityDecision -ToolInputRaw (Get-PythonPurityInput -FilePath 'src/module.py' -Content 'import tempfile')
        $markdownResult = Invoke-PythonTestPurityDecision -ToolInputRaw (Get-PythonPurityInput -FilePath 'tests/readme.md' -Content 'import tempfile')

        $sourceResult | Should -BeNullOrEmpty
        $markdownResult | Should -BeNullOrEmpty
    }

    It 'blocks forbidden Python unit-test runtime patterns with the deny schema' {
        $blockedExamples = @(
            @{ Content = 'import tempfile'; Reason = 'tempfile usage forbidden in unit tests' },
            @{ Content = 'from tempfile import TemporaryDirectory'; Reason = 'tempfile usage forbidden in unit tests' },
            @{ Content = 'NamedTemporaryFile()'; Reason = 'temporary files forbidden in unit tests' },
            @{ Content = 'TemporaryDirectory()'; Reason = 'temporary directories forbidden in unit tests' },
            @{ Content = 'mkstemp()'; Reason = 'temporary files forbidden in unit tests' },
            @{ Content = 'mkdtemp()'; Reason = 'temporary directories forbidden in unit tests' },
            @{ Content = 'Path("x").touch()'; Reason = 'Path.touch forbidden in unit tests' },
            @{ Content = 'import requests'; Reason = 'network access forbidden in unit tests' },
            @{ Content = 'import httpx'; Reason = 'network access forbidden in unit tests' },
            @{ Content = 'urllib.request.urlopen(url)'; Reason = 'network access forbidden in unit tests' },
            @{ Content = 'import socket'; Reason = 'raw socket access forbidden in unit tests' },
            @{ Content = 'from http.client import HTTPConnection'; Reason = 'network access forbidden in unit tests' },
            @{ Content = 'import subprocess'; Reason = 'subprocess execution forbidden in unit tests' },
            @{ Content = 'os.system("echo x")'; Reason = 'os.system forbidden in unit tests' },
            @{ Content = 'os.popen("echo x")'; Reason = 'os.popen forbidden in unit tests' },
            @{ Content = 'time.sleep(1)'; Reason = 'time.sleep forbidden in unit tests; avoid timing hacks' },
            @{ Content = 'import psycopg2'; Reason = 'real database drivers forbidden in unit tests' },
            @{ Content = 'import pymysql'; Reason = 'real database drivers forbidden in unit tests' },
            @{ Content = 'sqlite3.connect("db.sqlite")'; Reason = 'sqlite3.connect on real files forbidden in unit tests' }
        )

        foreach ($example in $blockedExamples) {
            $inputJson = Get-PythonPurityInput -FilePath 'tests/unit/test_bad.py' -Content $example.Content

            $result = Invoke-PythonTestPurityDecision -ToolInputRaw $inputJson

            $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike "*$($example.Reason)*"
        }
    }

    It 'Get-PythonTestPurityBlockDecision emits the PreToolUse deny schema after serialize-then-parse' {
        $decision = Get-PythonTestPurityBlockDecision -Reason 'tempfile usage forbidden in unit tests'
        $parsed = $decision | ConvertTo-Json -Depth 5 | ConvertFrom-Json

        $parsed.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
        $parsed.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $parsed.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*tempfile usage forbidden*'
    }

    It 'blocks malformed tool-input JSON with a diagnostic deny' {
        $result = Invoke-PythonTestPurityDecision -ToolInputRaw '{not-json'

        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*malformed JSON*'
    }

    It 'emits a deny response from the hook entrypoint' {
        $env:CLAUDE_TOOL_INPUT = Get-PythonPurityInput -FilePath 'tests/unit/test_bad.py' -Content 'import tempfile'

        $result = & $script:ScriptPath | ConvertFrom-Json

        $result.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*tempfile usage forbidden in unit tests*'
    }

    It 'emits no output (allow) from the hook entrypoint on safe content' {
        $env:CLAUDE_TOOL_INPUT = Get-PythonPurityInput -FilePath 'tests/unit/test_safe.py' -Content 'def test_value(): assert 1 == 1'

        $output = & $script:ScriptPath

        $output | Should -BeNullOrEmpty
    }
}
