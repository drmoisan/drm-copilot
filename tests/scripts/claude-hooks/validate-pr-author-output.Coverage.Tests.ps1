#Requires -Version 7.0
<#
.SYNOPSIS
    Entry-point coverage for .claude/hooks/validate-pr-author-output.ps1 (issues #786 and #905).

.DESCRIPTION
    Runs the hook through the & route with a SubagentStop envelope fed on stdin through
    [System.Console]::SetIn and stderr captured through [System.Console]::SetError, both restored
    in finally, so the envelope prologue, the block exit, and the allow exit execute in-process.
    No test creates, renames, moves, or deletes a file.
#>

Describe 'validate-pr-author-output entry point (stdin envelope, issue #905)' {
    BeforeAll {
        $script:StdinHook = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../.claude/hooks/validate-pr-author-output.ps1'))
        $script:NoPrMessage = 'I generated a PR body but did not open a pull request.'

        . (Join-Path $PSScriptRoot 'SubagentStopEnvelope.Helpers.ps1')

        function Invoke-PrAuthorOutputStdinEntry {
            # Drives the hook through the & route with stdin and stderr redirected; both are restored in finally.
            param([AllowEmptyString()] [string] $Stdin)
            $ErrorActionPreference = 'Continue'
            $priorIn = [System.Console]::In
            $priorError = [System.Console]::Error
            $errorWriter = [System.IO.StringWriter]::new()
            $thrown = $null
            $exitCode = $null
            try {
                [System.Console]::SetIn([System.IO.StringReader]::new($Stdin))
                [System.Console]::SetError($errorWriter)
                $global:LASTEXITCODE = 0
                try { $null = & $script:StdinHook 2>&1 } catch { $thrown = $_ }
                $exitCode = $LASTEXITCODE
            }
            finally {
                [System.Console]::SetIn($priorIn)
                [System.Console]::SetError($priorError)
            }
            return [pscustomobject]@{ ExitCode = $exitCode; Stderr = $errorWriter.ToString(); Thrown = $thrown }
        }
    }

    It 'exits 2 with PR_AUTHOR_OUTPUT_NO_PR on stderr when last_assistant_message lacks a PR reference' -Tag 'E3-Entry' {
        # Arrange
        $stdin = ConvertTo-SubagentStopEnvelopeJson -AgentType 'pr-author' -AssistantMessage $script:NoPrMessage
        # Act
        $result = Invoke-PrAuthorOutputStdinEntry -Stdin $stdin
        # Assert
        $result.Thrown | Should -BeNullOrEmpty
        $result.ExitCode | Should -Be 2
        $result.Stderr | Should -Match 'PR_AUTHOR_OUTPUT_NO_PR'
    }

    It 'exits 0 when last_assistant_message reports a pull request URL' -Tag 'E3-Entry' {
        # Arrange
        $stdin = ConvertTo-SubagentStopEnvelopeJson -AgentType 'pr-author' -AssistantMessage 'Created https://github.com/owner/repo/pull/905'
        # Act
        $result = Invoke-PrAuthorOutputStdinEntry -Stdin $stdin
        # Assert
        $result.Thrown | Should -BeNullOrEmpty
        $result.ExitCode | Should -Be 0
        $result.Stderr | Should -BeNullOrEmpty
    }

    It 'blocks when the PR reference is supplied only in an output field or through CLAUDE_HOOK_INPUT' -Tag 'E3-Entry' {
        # Arrange: the PR URL appears only in an output key and in the environment variable.
        $stdin = ConvertTo-SubagentStopEnvelopeJson -AgentType 'pr-author' -AssistantMessage $script:NoPrMessage -OutputField 'Created https://github.com/owner/repo/pull/905'
        $priorInput = $env:CLAUDE_HOOK_INPUT
        try {
            $env:CLAUDE_HOOK_INPUT = '{"output":"Created https://github.com/owner/repo/pull/905"}'
            # Act
            $result = Invoke-PrAuthorOutputStdinEntry -Stdin $stdin
        }
        finally { $env:CLAUDE_HOOK_INPUT = $priorInput }
        # Assert
        $result.Thrown | Should -BeNullOrEmpty
        $result.ExitCode | Should -Be 2
        $result.Stderr | Should -Match 'PR_AUTHOR_OUTPUT_NO_PR'
    }

    It 'exits 2 with PR_AUTHOR_OUTPUT_EMPTY when last_assistant_message is an empty string' -Tag 'E3-Entry' {
        # Arrange
        $stdin = ConvertTo-SubagentStopEnvelopeJson -AgentType 'pr-author' -AssistantMessage ''
        # Act
        $result = Invoke-PrAuthorOutputStdinEntry -Stdin $stdin
        # Assert
        $result.Thrown | Should -BeNullOrEmpty
        $result.ExitCode | Should -Be 2
        $result.Stderr | Should -Match 'PR_AUTHOR_OUTPUT_EMPTY'
    }

    It 'exits 2 with a payload anomaly reason for empty stdin' -Tag 'E3-Entry' {
        # Arrange and act: no stdin content.
        $result = Invoke-PrAuthorOutputStdinEntry -Stdin ''
        # Assert
        $result.Thrown | Should -BeNullOrEmpty
        $result.ExitCode | Should -Be 2
        $result.Stderr | Should -Match 'PR_AUTHOR_OUTPUT_MALFORMED:'
        $result.Stderr | Should -Match 'payload anomaly'
    }

    It 'exits 2 with a payload anomaly reason for malformed stdin' -Tag 'E3-Entry' {
        # Arrange and act: stdin that is not JSON.
        $result = Invoke-PrAuthorOutputStdinEntry -Stdin '{not-json'
        # Assert
        $result.Thrown | Should -BeNullOrEmpty
        $result.ExitCode | Should -Be 2
        $result.Stderr | Should -Match 'PR_AUTHOR_OUTPUT_MALFORMED:'
        $result.Stderr | Should -Match 'payload anomaly'
    }

    It 'exits 2 with a payload anomaly reason when last_assistant_message is absent' -Tag 'E3-Entry' {
        # Arrange and act: an envelope without last_assistant_message.
        $result = Invoke-PrAuthorOutputStdinEntry -Stdin (ConvertTo-SubagentStopEnvelopeJson -AgentType 'pr-author' -OmitAssistantMessage)
        # Assert
        $result.Thrown | Should -BeNullOrEmpty
        $result.ExitCode | Should -Be 2
        $result.Stderr | Should -Match 'PR_AUTHOR_OUTPUT_MALFORMED:'
        $result.Stderr | Should -Match 'payload anomaly'
    }

    It 'keeps validating when stop_hook_active is true' -Tag 'E3-Entry' {
        # Arrange: a re-entry envelope whose message still lacks a PR reference.
        $stdin = ConvertTo-SubagentStopEnvelopeJson -AgentType 'pr-author' -AssistantMessage $script:NoPrMessage -StopHookActive
        # Act
        $result = Invoke-PrAuthorOutputStdinEntry -Stdin $stdin
        # Assert
        $result.Thrown | Should -BeNullOrEmpty
        $result.ExitCode | Should -Be 2
    }
}
