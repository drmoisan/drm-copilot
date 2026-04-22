<#
.SYNOPSIS
    Pester tests for the check-python-test-purity.ps1 Claude Code hook.
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

    It 'allows missing tool input and missing file path' {
        $emptyResult = Invoke-PythonTestPurityDecision -ToolInputRaw ''
        $missingPathResult = Invoke-PythonTestPurityDecision -ToolInputRaw '{}'

        $emptyResult.decision | Should -Be 'allow'
        $missingPathResult.decision | Should -Be 'allow'
    }

    It 'allows safe Python test content' {
        $inputJson = Get-PythonPurityInput -FilePath 'tests/unit/test_safe.py' -Content 'def test_value(): assert 1 == 1'

        $result = Invoke-PythonTestPurityDecision -ToolInputRaw $inputJson

        $result.decision | Should -Be 'allow'
    }

    It 'allows empty content and empty new_string edits' {
        $contentResult = Invoke-PythonTestPurityDecision -ToolInputRaw (Get-PythonPurityInput -FilePath 'tests/unit/test_empty.py' -Content '')
        $newStringResult = Invoke-PythonTestPurityDecision -ToolInputRaw (Get-PythonPurityInput -FilePath 'tests/unit/test_empty.py' -NewString '')

        $contentResult.decision | Should -Be 'allow'
        $newStringResult.decision | Should -Be 'allow'
    }

    It 'ignores non-test and non-Python file paths' {
        $sourceResult = Invoke-PythonTestPurityDecision -ToolInputRaw (Get-PythonPurityInput -FilePath 'src/module.py' -Content 'import tempfile')
        $markdownResult = Invoke-PythonTestPurityDecision -ToolInputRaw (Get-PythonPurityInput -FilePath 'tests/readme.md' -Content 'import tempfile')

        $sourceResult.decision | Should -Be 'allow'
        $markdownResult.decision | Should -Be 'allow'
    }

    It 'blocks forbidden Python unit-test runtime patterns' {
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

            $result.decision | Should -Be 'block'
            $result.reason | Should -BeLike "*$($example.Reason)*"
        }
    }

    It 'blocks malformed tool-input JSON with a diagnostic' {
        $result = Invoke-PythonTestPurityDecision -ToolInputRaw '{not-json'

        $result.decision | Should -Be 'block'
        $result.reason | Should -BeLike '*malformed JSON*'
    }

    It 'emits a block response from the hook entrypoint' {
        $env:CLAUDE_TOOL_INPUT = Get-PythonPurityInput -FilePath 'tests/unit/test_bad.py' -Content 'import tempfile'

        $result = & $script:ScriptPath | ConvertFrom-Json

        $result.decision | Should -Be 'block'
        $result.reason | Should -BeLike '*tempfile usage forbidden in unit tests*'
    }
}
