<#
.SYNOPSIS
    Pester tests for the check-powershell-test-purity.ps1 Claude Code hook.
#>

Set-StrictMode -Version Latest

Describe 'check-powershell-test-purity.ps1' {
    BeforeAll {
        $script:ScriptPath = Join-Path -Path $PSScriptRoot -ChildPath '..' -AdditionalChildPath '..', '..', '.claude', 'hooks', 'check-powershell-test-purity.ps1'
        $script:ScriptPath = (Resolve-Path $script:ScriptPath).Path
        . $script:ScriptPath

        function Get-PowerShellPurityInput {
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

    It 'returns no decision for safe Pester test content' {
        $inputJson = Get-PowerShellPurityInput -FilePath 'tests/scripts/example.Tests.ps1' -Content 'It "passes" { 1 | Should -Be 1 }'

        $result = Invoke-PowerShellTestPurityDecision -ToolInputRaw $inputJson

        $result | Should -BeNullOrEmpty
    }

    It 'returns no decision for empty content and empty new_string edits' {
        $contentResult = Invoke-PowerShellTestPurityDecision -ToolInputRaw (Get-PowerShellPurityInput -FilePath 'tests/scripts/example.Tests.ps1' -Content '')
        $newStringResult = Invoke-PowerShellTestPurityDecision -ToolInputRaw (Get-PowerShellPurityInput -FilePath 'tests/scripts/example.Tests.ps1' -NewString '')

        $contentResult | Should -BeNullOrEmpty
        $newStringResult | Should -BeNullOrEmpty
    }

    It 'ignores non-test and non-PowerShell file paths' {
        $sourceResult = Invoke-PowerShellTestPurityDecision -ToolInputRaw (Get-PowerShellPurityInput -FilePath 'scripts/tool.ps1' -Content 'Start-Sleep -Seconds 1')
        $markdownResult = Invoke-PowerShellTestPurityDecision -ToolInputRaw (Get-PowerShellPurityInput -FilePath 'tests/readme.md' -Content 'Start-Sleep -Seconds 1')

        $sourceResult | Should -BeNullOrEmpty
        $markdownResult | Should -BeNullOrEmpty
    }

    It 'returns no decision for absent or malformed tool input' {
        $absent = Invoke-PowerShellTestPurityDecision -ToolInputRaw ''
        $malformed = Invoke-PowerShellTestPurityDecision -ToolInputRaw '{not-json'

        $absent | Should -BeNullOrEmpty
        $malformed | Should -BeNullOrEmpty
    }

    It 'denies forbidden Pester runtime and mock patterns with the PreToolUse deny shape' {
        $blockedExamples = @(
            @{ Content = 'Mock git'; Reason = 'direct Mock git forbidden in Pester tests' },
            @{ Content = 'Mock gh'; Reason = 'direct Mock gh forbidden in Pester tests' },
            @{ Content = 'Mock actionlint'; Reason = 'direct Mock actionlint forbidden in Pester tests' },
            @{ Content = "Mock 'git'"; Reason = "direct Mock 'git' forbidden in Pester tests" },
            @{ Content = 'New-TemporaryFile'; Reason = 'New-TemporaryFile forbidden in Pester unit tests' },
            @{ Content = '[System.IO.Path]::GetTempFileName()'; Reason = 'temporary files forbidden in Pester unit tests' },
            @{ Content = '[System.IO.Path]::GetTempPath()'; Reason = 'temp path usage forbidden in Pester unit tests' },
            @{ Content = '$env:TEMP'; Reason = '$env:TEMP usage forbidden in Pester unit tests' },
            @{ Content = '$env:TMP'; Reason = '$env:TMP usage forbidden in Pester unit tests' },
            @{ Content = 'Invoke-WebRequest http://example.invalid'; Reason = 'network access (Invoke-WebRequest) forbidden in Pester unit tests' },
            @{ Content = 'Invoke-RestMethod http://example.invalid'; Reason = 'network access (Invoke-RestMethod) forbidden in Pester unit tests' },
            @{ Content = '[System.Net.Http.HttpClient]::new()'; Reason = 'System.Net.Http usage forbidden in Pester unit tests' },
            @{ Content = '[System.Net.WebRequest]::Create("http://example.invalid")'; Reason = 'System.Net.WebRequest usage forbidden in Pester unit tests' },
            @{ Content = '[System.Net.Sockets.TcpClient]::new()'; Reason = 'raw socket access forbidden in Pester unit tests' },
            @{ Content = 'Start-Process git'; Reason = 'Start-Process forbidden in Pester unit tests' },
            @{ Content = 'Start-Sleep -Seconds 1'; Reason = 'Start-Sleep forbidden in Pester unit tests' }
        )

        foreach ($example in $blockedExamples) {
            $inputJson = Get-PowerShellPurityInput -FilePath 'tests/scripts/example.Tests.ps1' -Content $example.Content

            $result = Invoke-PowerShellTestPurityDecision -ToolInputRaw $inputJson

            $result.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
            $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike "*$($example.Reason)*"
        }
    }

    It 'builds a deny decision that survives serialize-then-parse round-tripping' {
        $decision = Get-PowerShellTestPurityBlockDecision -Reason 'PowerShell unit test purity violations in test.Tests.ps1'
        $parsed = $decision | ConvertTo-Json -Depth 5 | ConvertFrom-Json

        $parsed.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
        $parsed.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $parsed.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*PowerShell unit test purity violations*'
    }

    It 'emits the compact deny JSON from the entrypoint on a forbidden pattern' {
        $env:CLAUDE_TOOL_INPUT = Get-PowerShellPurityInput -FilePath 'tests/scripts/example.Tests.ps1' -Content 'Start-Sleep -Seconds 1'

        $output = & $script:ScriptPath | ConvertFrom-Json

        $output.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
        $output.hookSpecificOutput.permissionDecision | Should -Be 'deny'
    }

    It 'emits nothing from the entrypoint for safe content' {
        $env:CLAUDE_TOOL_INPUT = Get-PowerShellPurityInput -FilePath 'tests/scripts/example.Tests.ps1' -Content 'It "passes" { 1 | Should -Be 1 }'

        $output = & $script:ScriptPath

        $output | Should -BeNullOrEmpty
    }
}
