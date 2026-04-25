<#
.SYNOPSIS
    Pester tests for the check-powershell-test-purity.ps1 Claude Code hook.
#>

Set-StrictMode -Version Latest

Describe 'check-powershell-test-purity.ps1' {
    BeforeAll {
        $script:ScriptPath = Join-Path -Path $PSScriptRoot -ChildPath '..' -AdditionalChildPath '..', '..', '.claude', 'hooks', 'check-powershell-test-purity.ps1'
        $script:ScriptPath = (Resolve-Path $script:ScriptPath).Path

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

        function Invoke-PowerShellPurityHook {
            param([Parameter(Mandatory)][string] $ToolInputRaw)

            $env:CLAUDE_TOOL_INPUT = $ToolInputRaw
            $output = & $script:ScriptPath
            if ($output) {
                return ($output | ConvertFrom-Json)
            }

            return [pscustomobject]@{ decision = 'allow'; reason = $null }
        }
    }

    AfterEach {
        $env:CLAUDE_TOOL_INPUT = $null
    }

    It 'allows safe Pester test content' {
        $inputJson = Get-PowerShellPurityInput -FilePath 'tests/scripts/example.Tests.ps1' -Content 'It "passes" { 1 | Should -Be 1 }'

        $result = Invoke-PowerShellPurityHook -ToolInputRaw $inputJson

        $result.decision | Should -Be 'allow'
    }

    It 'allows empty content and empty new_string edits' {
        $contentResult = Invoke-PowerShellPurityHook -ToolInputRaw (Get-PowerShellPurityInput -FilePath 'tests/scripts/example.Tests.ps1' -Content '')
        $newStringResult = Invoke-PowerShellPurityHook -ToolInputRaw (Get-PowerShellPurityInput -FilePath 'tests/scripts/example.Tests.ps1' -NewString '')

        $contentResult.decision | Should -Be 'allow'
        $newStringResult.decision | Should -Be 'allow'
    }

    It 'ignores non-test and non-PowerShell file paths' {
        $sourceResult = Invoke-PowerShellPurityHook -ToolInputRaw (Get-PowerShellPurityInput -FilePath 'scripts/tool.ps1' -Content 'Start-Sleep -Seconds 1')
        $markdownResult = Invoke-PowerShellPurityHook -ToolInputRaw (Get-PowerShellPurityInput -FilePath 'tests/readme.md' -Content 'Start-Sleep -Seconds 1')

        $sourceResult.decision | Should -Be 'allow'
        $markdownResult.decision | Should -Be 'allow'
    }

    It 'blocks forbidden Pester runtime and mock patterns' {
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

            $result = Invoke-PowerShellPurityHook -ToolInputRaw $inputJson

            $result.decision | Should -Be 'block'
            $result.reason | Should -BeLike "*$($example.Reason)*"
        }
    }
}
