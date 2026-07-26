#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
    Unit coverage for the two Codex test-purity PreToolUse hooks
    .codex/hooks/check-python-test-purity.ps1 and
    .codex/hooks/check-powershell-test-purity.ps1 (issue #415 remediation cycle 1, R1).

    Every case dot-sources the ROOT hook in-process, so the policy functions and the
    guarded entrypoint are attributed to the on-disk source file. The pre-existing
    codex suites drive these hooks only by spawned process, which contributes no
    in-process coverage.

    No temporary file is created. Entrypoint cases redirect stdin with
    [System.Console]::SetIn([System.IO.StringReader]::new(...)) and restore the
    original readers in finally.

    Forbidden-pattern fixture text is assembled at run time from fragments so this
    file's own source never contains a literal pattern the purity hooks reject.
#>

Describe 'Codex test-purity PreToolUse hooks' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:HookRoot = Join-Path $script:RepoRoot '.codex/hooks'
        $script:PythonPurityHookPath = Join-Path $script:HookRoot 'check-python-test-purity.ps1'
        $script:PowerShellPurityHookPath = Join-Path $script:HookRoot 'check-powershell-test-purity.ps1'

        . $script:PythonPurityHookPath
        . $script:PowerShellPurityHookPath

        $script:PythonViolationText = 'import ' + 'subprocess' + [System.Environment]::NewLine + 'time.' + 'sleep(1)'
        $script:PowerShellViolationText = 'Start-' + 'Sleep 1'

        function ConvertTo-CodexPurityPayload {
            param(
                [Parameter(Mandatory)][string] $ToolName,
                [Parameter(Mandatory)][hashtable] $ToolInput
            )

            return [ordered]@{
                session_id      = 'purity-hook-coverage'
                hook_event_name = 'PreToolUse'
                tool_name       = $ToolName
                tool_input      = $ToolInput
            } | ConvertTo-Json -Compress -Depth 30
        }

        function Invoke-CodexPurityEntrypoint {
            <#
                Drives a hook's own entrypoint in-process with a StringReader on stdin.
            #>
            param(
                [Parameter(Mandatory)][string] $HookPath,
                [Parameter(Mandatory)][AllowEmptyString()][string] $PayloadRaw
            )

            $originalIn = [System.Console]::In
            $originalError = [System.Console]::Error
            $errorWriter = [System.IO.StringWriter]::new()
            try {
                [System.Console]::SetIn([System.IO.StringReader]::new($PayloadRaw))
                [System.Console]::SetError($errorWriter)
                $stdout = & $HookPath
                return [pscustomobject]@{
                    ExitCode = $LASTEXITCODE
                    Stdout   = ($stdout -join "`n")
                    Stderr   = $errorWriter.ToString()
                }
            } finally {
                [System.Console]::SetIn($originalIn)
                [System.Console]::SetError($originalError)
            }
        }
    }

    Context 'check-python-test-purity policy functions' {
        It 'recognises <Label> as a Python test path: <Expected>' -ForEach @(
            @{ Label = 'a tests tree module'; Path = 'tests/scripts/dev_tools/test_a.py'; Expected = $true }
            @{ Label = 'a bare test_ module'; Path = 'test_helper.py'; Expected = $true }
            @{ Label = 'a Windows-separated tests path'; Path = 'tests\scripts\test_b.py'; Expected = $true }
            @{ Label = 'a production module'; Path = 'scripts/dev_tools/tool.py'; Expected = $false }
            @{ Label = 'a PowerShell test'; Path = 'tests/scripts/a.Tests.ps1'; Expected = $false }
        ) {
            Test-PythonTestFilePath -FilePath $Path | Should -Be $Expected
        }

        It 'returns no decision when the mapped tool_input is empty' {
            Invoke-PythonTestPurityDecision -ToolInputRaw '' | Should -BeNullOrEmpty
        }

        It 'denies when the mapped tool_input is malformed JSON' {
            $decision = Invoke-PythonTestPurityDecision -ToolInputRaw 'not json'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'malformed JSON'
        }

        It 'returns no decision when the mapped tool_input carries no file_path' {
            Invoke-PythonTestPurityDecision -ToolInputRaw '{"content":"x"}' | Should -BeNullOrEmpty
        }

        It 'returns no decision for a path outside the Python test surface' {
            $raw = @{ file_path = 'scripts/dev_tools/tool.py'; content = $script:PythonViolationText } | ConvertTo-Json -Compress

            Invoke-PythonTestPurityDecision -ToolInputRaw $raw | Should -BeNullOrEmpty
        }

        It 'returns no decision when a Python test edit carries no content' {
            $raw = @{ file_path = 'tests/test_a.py' } | ConvertTo-Json -Compress

            Invoke-PythonTestPurityDecision -ToolInputRaw $raw | Should -BeNullOrEmpty
        }

        It 'returns no decision when the proposed Python test content is pure' {
            $raw = @{ file_path = 'tests/test_a.py'; content = 'def test_ok():' + "`n" + '    assert True' } | ConvertTo-Json -Compress

            Invoke-PythonTestPurityDecision -ToolInputRaw $raw | Should -BeNullOrEmpty
        }

        It 'denies a Write whose content introduces forbidden Python dependencies' {
            $raw = @{ file_path = 'tests/test_a.py'; content = $script:PythonViolationText } | ConvertTo-Json -Compress

            $decision = Invoke-PythonTestPurityDecision -ToolInputRaw $raw

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'subprocess execution forbidden'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match "tests/test_a.py"
        }

        It 'denies an Edit whose new_string introduces forbidden Python dependencies' {
            $raw = @{ file_path = 'tests/test_a.py'; new_string = $script:PythonViolationText } | ConvertTo-Json -Compress

            $decision = Invoke-PythonTestPurityDecision -ToolInputRaw $raw

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'reports each violated rule once' {
            $doubled = $script:PythonViolationText + "`n" + $script:PythonViolationText
            $raw = @{ file_path = 'tests/test_a.py'; content = $doubled } | ConvertTo-Json -Compress

            $decision = Invoke-PythonTestPurityDecision -ToolInputRaw $raw
            $occurrences = ([regex]::Matches($decision.hookSpecificOutput.permissionDecisionReason, 'subprocess execution forbidden')).Count

            $occurrences | Should -Be 1
        }
    }

    Context 'check-python-test-purity entrypoint (in-process)' {
        It 'denies a mapped Write that violates Python test purity' {
            $payload = ConvertTo-CodexPurityPayload -ToolName 'Write' -ToolInput @{
                file_path = 'tests/test_a.py'
                content   = $script:PythonViolationText
            }

            $result = Invoke-CodexPurityEntrypoint -HookPath $script:PythonPurityHookPath -PayloadRaw $payload

            $result.ExitCode | Should -Be 0
            $result.Stdout | Should -Match 'permissionDecision":"deny'
            $result.Stderr | Should -BeNullOrEmpty
        }

        It 'allows a mapped Write that is pure' {
            $payload = ConvertTo-CodexPurityPayload -ToolName 'Write' -ToolInput @{
                file_path = 'tests/test_a.py'
                content   = 'assert True'
            }

            $result = Invoke-CodexPurityEntrypoint -HookPath $script:PythonPurityHookPath -PayloadRaw $payload

            $result.ExitCode | Should -Be 0
            $result.Stdout | Should -BeNullOrEmpty
        }

        It 'allows a well-formed payload that maps to no file edit' {
            $payload = ConvertTo-CodexPurityPayload -ToolName 'Read' -ToolInput @{ file_path = 'tests/test_a.py' }

            $result = Invoke-CodexPurityEntrypoint -HookPath $script:PythonPurityHookPath -PayloadRaw $payload

            $result.ExitCode | Should -Be 0
            $result.Stdout | Should -BeNullOrEmpty
        }

        It 'fails closed with exit 2 on empty stdin' {
            $result = Invoke-CodexPurityEntrypoint -HookPath $script:PythonPurityHookPath -PayloadRaw ''

            $result.ExitCode | Should -Be 2
            $result.Stderr | Should -Match 'check-python-test-purity hook input is empty'
        }
    }

    Context 'check-powershell-test-purity policy functions' {
        It 'recognises <Label> as a PowerShell test path: <Expected>' -ForEach @(
            @{ Label = 'a tests tree script'; Path = 'tests/scripts/a.ps1'; Expected = $true }
            @{ Label = 'a Pester suffixed file'; Path = 'anywhere/b.Tests.ps1'; Expected = $true }
            @{ Label = 'a Windows-separated tests path'; Path = 'tests\scripts\c.ps1'; Expected = $true }
            @{ Label = 'a production script'; Path = 'scripts/dev-tools/tool.ps1'; Expected = $false }
            @{ Label = 'a Python test'; Path = 'tests/test_a.py'; Expected = $false }
        ) {
            Test-PowerShellTestFilePath -FilePath $Path | Should -Be $Expected
        }

        It 'returns no decision when the mapped tool_input is empty' {
            Invoke-PowerShellTestPurityDecision -ToolInputRaw '' | Should -BeNullOrEmpty
        }

        It 'returns no decision when the mapped tool_input is malformed JSON' {
            Invoke-PowerShellTestPurityDecision -ToolInputRaw 'not json' | Should -BeNullOrEmpty
        }

        It 'returns no decision when the mapped tool_input carries no file_path' {
            Invoke-PowerShellTestPurityDecision -ToolInputRaw '{"content":"x"}' | Should -BeNullOrEmpty
        }

        It 'returns no decision for a path outside the PowerShell test surface' {
            $raw = @{ file_path = 'scripts/dev-tools/tool.ps1'; content = $script:PowerShellViolationText } | ConvertTo-Json -Compress

            Invoke-PowerShellTestPurityDecision -ToolInputRaw $raw | Should -BeNullOrEmpty
        }

        It 'returns no decision when a PowerShell test edit carries no content' {
            $raw = @{ file_path = 'tests/scripts/a.Tests.ps1' } | ConvertTo-Json -Compress

            Invoke-PowerShellTestPurityDecision -ToolInputRaw $raw | Should -BeNullOrEmpty
        }

        It 'returns no decision when the proposed PowerShell test content is pure' {
            $raw = @{ file_path = 'tests/scripts/a.Tests.ps1'; content = 'Describe ''x'' { It ''y'' { $true | Should -BeTrue } }' } | ConvertTo-Json -Compress

            Invoke-PowerShellTestPurityDecision -ToolInputRaw $raw | Should -BeNullOrEmpty
        }

        It 'denies a Write whose content introduces a timing hack' {
            $raw = @{ file_path = 'tests/scripts/a.Tests.ps1'; content = $script:PowerShellViolationText } | ConvertTo-Json -Compress

            $decision = Invoke-PowerShellTestPurityDecision -ToolInputRaw $raw

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'avoid timing hacks'
        }

        It 'denies an Edit whose new_string introduces a timing hack' {
            $raw = @{ file_path = 'tests/scripts/a.Tests.ps1'; new_string = $script:PowerShellViolationText } | ConvertTo-Json -Compress

            $decision = Invoke-PowerShellTestPurityDecision -ToolInputRaw $raw

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'reports each violated rule once' {
            $doubled = $script:PowerShellViolationText + "`n" + $script:PowerShellViolationText
            $raw = @{ file_path = 'tests/scripts/a.Tests.ps1'; content = $doubled } | ConvertTo-Json -Compress

            $decision = Invoke-PowerShellTestPurityDecision -ToolInputRaw $raw
            $occurrences = ([regex]::Matches($decision.hookSpecificOutput.permissionDecisionReason, 'avoid timing hacks')).Count

            $occurrences | Should -Be 1
        }
    }

    Context 'check-powershell-test-purity entrypoint (in-process)' {
        It 'denies a mapped Write that violates PowerShell test purity' {
            $payload = ConvertTo-CodexPurityPayload -ToolName 'Write' -ToolInput @{
                file_path = 'tests/scripts/a.Tests.ps1'
                content   = $script:PowerShellViolationText
            }

            $result = Invoke-CodexPurityEntrypoint -HookPath $script:PowerShellPurityHookPath -PayloadRaw $payload

            $result.ExitCode | Should -Be 0
            $result.Stdout | Should -Match 'permissionDecision":"deny'
            $result.Stderr | Should -BeNullOrEmpty
        }

        It 'allows a mapped Write that is pure' {
            $payload = ConvertTo-CodexPurityPayload -ToolName 'Write' -ToolInput @{
                file_path = 'tests/scripts/a.Tests.ps1'
                content   = 'Describe ''x'' { }'
            }

            $result = Invoke-CodexPurityEntrypoint -HookPath $script:PowerShellPurityHookPath -PayloadRaw $payload

            $result.ExitCode | Should -Be 0
            $result.Stdout | Should -BeNullOrEmpty
        }

        It 'allows a well-formed payload that maps to no file edit' {
            $payload = ConvertTo-CodexPurityPayload -ToolName 'Read' -ToolInput @{ file_path = 'tests/scripts/a.Tests.ps1' }

            $result = Invoke-CodexPurityEntrypoint -HookPath $script:PowerShellPurityHookPath -PayloadRaw $payload

            $result.ExitCode | Should -Be 0
            $result.Stdout | Should -BeNullOrEmpty
        }

        It 'fails closed with exit 2 on empty stdin' {
            $result = Invoke-CodexPurityEntrypoint -HookPath $script:PowerShellPurityHookPath -PayloadRaw ''

            $result.ExitCode | Should -Be 2
            $result.Stderr | Should -Match 'check-powershell-test-purity hook input is empty'
        }
    }
}
