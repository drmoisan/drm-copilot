#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Behavior suite for the Codex SubagentStop validator .codex/hooks/validate-pr-author-output.ps1 (issue #1030).

.DESCRIPTION
    Runs every decision case of tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 and
    validate-pr-author-output.Coverage.Tests.ps1 on Codex SubagentStop payloads (hook_event_name,
    agent_type pr-author, last_assistant_message, stop_hook_active), pins the twin-rule functions against the
    Claude source, covers the Codex one-continuation decision, and drives the entrypoint in-process with
    stdin and stderr redirected through [System.Console] (both restored in finally) and in child processes.
    No test creates, renames, moves, or deletes a file.
#>

Describe 'Codex validate-pr-author-output.ps1' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:HookPath = Join-Path $script:RepoRoot '.codex/hooks/validate-pr-author-output.ps1'
        $script:PwshExe = (Get-Process -Id $PID).Path
        $script:NoPrMessage = 'I generated a PR body but did not open a pull request.'
        . $script:HookPath

        function ConvertTo-CodexStopPayload {
            # Returns a compressed Codex SubagentStop payload; last_assistant_message is omitted with -OmitAssistantMessage.
            param([AllowEmptyString()][string] $AssistantMessage = '', [switch] $OmitAssistantMessage, [string] $OutputField, [switch] $StopHookActive)
            $payload = [ordered]@{ session_id = 's-1030'; turn_id = 't-1030'; hook_event_name = 'SubagentStop'; agent_type = 'pr-author'; stop_hook_active = [bool]$StopHookActive }
            if (-not $OmitAssistantMessage) { $payload['last_assistant_message'] = $AssistantMessage }
            if ($PSBoundParameters.ContainsKey('OutputField')) { $payload['output'] = $OutputField }
            return ($payload | ConvertTo-Json -Compress)
        }

        function Invoke-CodexPrAuthorEntry {
            # Drives the hook through the & route with stdin and stderr redirected; both are restored in finally.
            param([AllowEmptyString()][string] $Stdin)
            $ErrorActionPreference = 'Continue'
            $priorIn = [System.Console]::In
            $priorError = [System.Console]::Error
            $errorWriter = [System.IO.StringWriter]::new()
            $thrown = $null
            $stdout = @()
            try {
                [System.Console]::SetIn([System.IO.StringReader]::new($Stdin))
                [System.Console]::SetError($errorWriter)
                $global:LASTEXITCODE = 0
                try { $stdout = @(& $script:HookPath) } catch { $thrown = $_ }
                $exitCode = $LASTEXITCODE
            }
            finally {
                [System.Console]::SetIn($priorIn)
                [System.Console]::SetError($priorError)
            }
            return [pscustomobject]@{ ExitCode = $exitCode; Stdout = ($stdout -join "`n"); Stderr = $errorWriter.ToString(); Thrown = $thrown }
        }

        function Invoke-CodexPrAuthorProcess {
            # Runs the hook in a child pwsh process with the payload on stdin.
            param([AllowEmptyString()][string] $Stdin)
            $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
            $startInfo.FileName = $script:PwshExe
            foreach ($argument in @('-NoProfile', '-File', $script:HookPath)) { $startInfo.ArgumentList.Add($argument) }
            $startInfo.RedirectStandardInput = $true
            $startInfo.RedirectStandardOutput = $true
            $startInfo.RedirectStandardError = $true
            $startInfo.UseShellExecute = $false
            $process = [System.Diagnostics.Process]::Start($startInfo)
            $process.StandardInput.Write($Stdin)
            $process.StandardInput.Close()
            $stdout = $process.StandardOutput.ReadToEnd()
            $stderr = $process.StandardError.ReadToEnd()
            $process.WaitForExit()
            return [pscustomobject]@{ ExitCode = $process.ExitCode; Stdout = $stdout.Trim(); Stderr = $stderr.Trim() }
        }
    }

    Context 'twin rule' {
        It 'keeps every twinned function text-identical to the Claude source' {
            $read = {
                param([string] $Path)
                $tokens = $null
                $errors = $null
                $ast = [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref]$tokens, [ref]$errors)
                $table = @{}
                foreach ($definition in @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false))) { $table[$definition.Name] = $definition.Extent.Text -replace "`r`n", "`n" }
                $table
            }
            $claude = & $read (Join-Path $script:RepoRoot '.claude/hooks/validate-pr-author-output.ps1')
            $codex = & $read $script:HookPath
            foreach ($name in @('Test-PrAuthorOutputReportsPr', 'Get-PrAuthorOutputDecision')) {
                $codex[$name] | Should -BeExactly $claude[$name] -Because "$name is a twin-rule function"
            }
        }
    }

    Context 'Get-PrAuthorOutputDecision - allow scenarios' {
        It 'allows when the Codex message contains <Name>' -ForEach @(
            @{ Name = 'a GitHub PR URL'; Message = 'Opened the PR at https://github.com/drmoisan/drm-copilot/pull/231 successfully.' }
            @{ Name = 'a PR #<n> reference'; Message = 'Created PR #231 for the feature branch.' }
            @{ Name = 'a gh pr create confirmation with a PR number'; Message = 'Ran gh pr create and the result was #231.' }
            @{ Name = 'a gh pr edit confirmation with a PR number'; Message = 'Ran gh pr edit on #231 to update the body.' }
        ) {
            (Get-PrAuthorOutputDecision -InputText (ConvertTo-CodexStopPayload -AssistantMessage $Message))['allowed'] | Should -BeTrue
        }
    }

    Context 'Get-PrAuthorOutputDecision - block scenarios' {
        It 'blocks with <Expected> when <Name>' -ForEach @(
            @{ Name = 'the assistant message is blank'; InputText = '{"hook_event_name":"SubagentStop","agent_type":"pr-author","stop_hook_active":false,"last_assistant_message":""}'; Expected = 'PR_AUTHOR_OUTPUT_EMPTY' }
            @{ Name = 'the message has no PR URL or number'; InputText = '{"hook_event_name":"SubagentStop","agent_type":"pr-author","stop_hook_active":false,"last_assistant_message":"I generated a PR body but did not open a pull request."}'; Expected = 'PR_AUTHOR_OUTPUT_NO_PR' }
            @{ Name = 'the payload is empty'; InputText = ''; Expected = 'PR_AUTHOR_OUTPUT_MALFORMED: payload anomaly' }
            @{ Name = 'the payload is malformed JSON'; InputText = '{not-json'; Expected = 'PR_AUTHOR_OUTPUT_MALFORMED: payload anomaly' }
            @{ Name = 'the message mentions gh pr create without a PR number'; InputText = '{"hook_event_name":"SubagentStop","agent_type":"pr-author","stop_hook_active":false,"last_assistant_message":"I intend to run gh pr create later."}'; Expected = 'PR_AUTHOR_OUTPUT_NO_PR' }
        ) {
            $decision = Get-PrAuthorOutputDecision -InputText $InputText
            $decision['allowed'] | Should -BeFalse
            $decision['reason'] | Should -Match ([regex]::Escape($Expected))
        }
    }

    Context 'Test-PrAuthorOutputReportsPr detection helper' {
        It 'returns false for null, empty and whitespace output' {
            Test-PrAuthorOutputReportsPr -OutputText $null | Should -BeFalse
            Test-PrAuthorOutputReportsPr -OutputText '' | Should -BeFalse
            Test-PrAuthorOutputReportsPr -OutputText '   ' | Should -BeFalse
        }

        It 'returns true for a PR URL' {
            Test-PrAuthorOutputReportsPr -OutputText 'see github.com/o/r/pull/42' | Should -BeTrue
        }

        It 'returns false for prose with no PR reference' {
            Test-PrAuthorOutputReportsPr -OutputText 'No pull request was opened.' | Should -BeFalse
        }
    }

    Context 'Get-CodexPrAuthorStopDecision' {
        It 'returns ExitCode 0 and no reason for an allowed stop' {
            $result = Get-CodexPrAuthorStopDecision -InputText (ConvertTo-CodexStopPayload -AssistantMessage 'Created PR #1030')
            $result.ExitCode | Should -Be 0
            $result.Reason | Should -BeExactly ''
        }

        It 'returns ExitCode 2 with the reason when stop_hook_active is unset' {
            $result = Get-CodexPrAuthorStopDecision -InputText (ConvertTo-CodexStopPayload -AssistantMessage $script:NoPrMessage)
            $result.ExitCode | Should -Be 2
            $result.Reason | Should -Match '^PR_AUTHOR_OUTPUT_NO_PR:'
        }

        It 'allows the one continuation when stop_hook_active is true' {
            $result = Get-CodexPrAuthorStopDecision -InputText (ConvertTo-CodexStopPayload -AssistantMessage $script:NoPrMessage -StopHookActive)
            $result.ExitCode | Should -Be 0
        }

        It 'fails closed for a malformed payload when stop_hook_active cannot be read' {
            (Get-CodexPrAuthorStopDecision -InputText '{not-json').ExitCode | Should -Be 2
        }

        It 'returns the dependency decision first when a dependency failed to load' {
            Mock Get-HookDependencyFailureDecision { [pscustomobject]@{ ExitCode = 2; Reason = 'PR_AUTHOR_OUTPUT_MISSING: subagentstop-envelope.ps1 failed to load' } }
            Mock Get-PrAuthorOutputDecision { [ordered]@{ allowed = $true } }
            $result = Get-CodexPrAuthorStopDecision -InputText (ConvertTo-CodexStopPayload -AssistantMessage 'Created PR #1030')
            $result.ExitCode | Should -Be 2
            $result.Reason | Should -Match 'subagentstop-envelope\.ps1'
            Should -Invoke Get-PrAuthorOutputDecision -Times 0 -Exactly
        }

        It 'returns the validator-error reason with ExitCode 2 when the decision throws' {
            Mock Get-PrAuthorOutputDecision { throw "simulated failure`nsecond line" }
            $result = Get-CodexPrAuthorStopDecision -InputText (ConvertTo-CodexStopPayload -AssistantMessage 'Created PR #1030')
            $result.ExitCode | Should -Be 2
            $result.Reason | Should -Match '^PR_AUTHOR_OUTPUT_MISSING: validator error: simulated failure; the gate fails closed\.'
            $result.Reason | Should -Not -Match 'second line'
        }
    }

    Context 'entrypoint through the & route' {
        It 'exits <ExitCode> for <Name>' -ForEach @(
            @{ Name = 'a message without a PR reference'; Message = 'I generated a PR body but did not open a pull request.'; Active = $false; ExitCode = 2; Pattern = 'PR_AUTHOR_OUTPUT_NO_PR' }
            @{ Name = 'a message with a pull request URL'; Message = 'Created https://github.com/owner/repo/pull/1030'; Active = $false; ExitCode = 0; Pattern = '' }
            @{ Name = 'an empty message'; Message = ''; Active = $false; ExitCode = 2; Pattern = 'PR_AUTHOR_OUTPUT_EMPTY' }
            @{ Name = 'a re-entered stop without a PR reference'; Message = 'I generated a PR body but did not open a pull request.'; Active = $true; ExitCode = 0; Pattern = '' }
        ) {
            $result = Invoke-CodexPrAuthorEntry -Stdin (ConvertTo-CodexStopPayload -AssistantMessage $Message -StopHookActive:$Active)
            $result.Thrown | Should -BeNullOrEmpty
            $result.ExitCode | Should -Be $ExitCode
            $result.Stdout | Should -BeNullOrEmpty
            if ($Pattern) { $result.Stderr | Should -Match $Pattern } else { $result.Stderr | Should -BeNullOrEmpty }
        }

        It 'exits 2 with a payload anomaly reason for <Name>' -ForEach @(
            @{ Name = 'empty stdin'; Stdin = '' }
            @{ Name = 'malformed stdin'; Stdin = '{not-json' }
            @{ Name = 'a payload without last_assistant_message'; Stdin = '{"hook_event_name":"SubagentStop","agent_type":"pr-author","stop_hook_active":false}' }
        ) {
            $result = Invoke-CodexPrAuthorEntry -Stdin $Stdin
            $result.ExitCode | Should -Be 2
            $result.Stderr | Should -Match 'PR_AUTHOR_OUTPUT_MALFORMED: payload anomaly'
        }

        It 'blocks when the PR reference is supplied only in an output field' {
            $result = Invoke-CodexPrAuthorEntry -Stdin (ConvertTo-CodexStopPayload -AssistantMessage $script:NoPrMessage -OutputField 'Created https://github.com/owner/repo/pull/1030')
            $result.ExitCode | Should -Be 2
            $result.Stderr | Should -Match 'PR_AUTHOR_OUTPUT_NO_PR'
        }
    }

    Context 'entrypoint in a child process' {
        It 'exits 2 with stderr and empty stdout for malformed stdin' {
            $result = Invoke-CodexPrAuthorProcess -Stdin '{not-json'
            $result.ExitCode | Should -Be 2
            $result.Stdout | Should -BeNullOrEmpty
            $result.Stderr | Should -Match 'PR_AUTHOR_OUTPUT_MALFORMED'
        }

        It 'exits 2 with PR_AUTHOR_OUTPUT_NO_PR when stop_hook_active is false' {
            $result = Invoke-CodexPrAuthorProcess -Stdin (ConvertTo-CodexStopPayload -AssistantMessage $script:NoPrMessage)
            $result.ExitCode | Should -Be 2
            $result.Stdout | Should -BeNullOrEmpty
            $result.Stderr | Should -Match 'PR_AUTHOR_OUTPUT_NO_PR:'
        }

        It 'exits 0 with empty stdout when stop_hook_active is true' {
            $result = Invoke-CodexPrAuthorProcess -Stdin (ConvertTo-CodexStopPayload -AssistantMessage $script:NoPrMessage -StopHookActive)
            $result.ExitCode | Should -Be 0
            $result.Stdout | Should -BeNullOrEmpty
        }

        It 'exits 0 for a payload with a PR URL' {
            $result = Invoke-CodexPrAuthorProcess -Stdin (ConvertTo-CodexStopPayload -AssistantMessage 'Created https://github.com/owner/repo/pull/1030')
            $result.ExitCode | Should -Be 0
            $result.Stdout | Should -BeNullOrEmpty
            $result.Stderr | Should -BeNullOrEmpty
        }
    }
}
