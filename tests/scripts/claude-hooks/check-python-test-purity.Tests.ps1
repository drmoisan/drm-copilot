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

            $toolInput = [ordered]@{ file_path = $FilePath }
            if ($PSBoundParameters.ContainsKey('Content')) {
                $toolInput.content = $Content
            }
            if ($PSBoundParameters.ContainsKey('NewString')) {
                $toolInput.new_string = $NewString
            }

            $envelope = [ordered]@{ tool_name = 'Write'; tool_input = $toolInput }
            return ($envelope | ConvertTo-Json -Compress -Depth 5)
        }
    }

    It 'denies an empty payload as an envelope anomaly (fail closed)' {
        $result = Invoke-PythonTestPurityDecision -ToolInputRaw ''

        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*empty payload*'
    }

    It 'denies the legacy flat root shape as a missing-tool_input anomaly' {
        $result = Invoke-PythonTestPurityDecision -ToolInputRaw '{"file_path":"tests/unit/test_x.py"}'

        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*no tool_input key*'
    }

    It 'allows (no decision) a well-formed tool_input carrying no file_path' {
        $missingPathResult = Invoke-PythonTestPurityDecision -ToolInputRaw '{"tool_name":"Bash","tool_input":{"command":"echo hi"}}'

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
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*not parseable JSON*'
    }

    It 'denies a nested envelope carrying forbidden test content (AC-7)' {
        $inputJson = Get-PythonPurityInput -FilePath 'tests/unit/test_bad.py' -Content 'import tempfile'

        $result = Invoke-PythonTestPurityDecision -ToolInputRaw $inputJson

        $result.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*tempfile usage forbidden in unit tests*'
    }

    It 'reads the payload through the shared reader' {
        $hookText = Get-Content -Path $script:ScriptPath -Raw

        $hookText | Should -BeLike '*HookPayload.psm1*'
        $hookText | Should -BeLike '*Read-ClaudeHookRawPayload*'
    }
}
