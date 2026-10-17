#Requires -Version 7.0
<#
.SYNOPSIS
    Entry-point coverage for .claude/hooks/validate-prd-feature-output.ps1 (issues #786 and #905).

.DESCRIPTION
    Runs the hook through the & route with a SubagentStop envelope fed on stdin through
    [System.Console]::SetIn and stderr captured through [System.Console]::SetError, both restored
    in finally, so the envelope prologue, the spec and research reads, the block exit, and the
    allow exit execute in-process. Spec and research presence and reads are supplied by Test-Path
    and Get-Content mocks filtered on the exact literal path. No test creates, renames, moves, or
    deletes a file.
#>

Describe 'validate-prd-feature-output entry point (stdin envelope, issue #905)' {
    BeforeAll {
        $script:StdinHook = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../.claude/hooks/validate-prd-feature-output.ps1'))
        $script:PwshExe = if ($PSVersionTable.PSVersion.Major -ge 7 -and $PSEdition -eq 'Core') {
            (Get-Process -Id $PID).Path
        } else {
            (Get-Command pwsh -CommandType Application -ErrorAction Stop).Source
        }

        . (Join-Path $PSScriptRoot 'SubagentStopEnvelope.Helpers.ps1')

        function Invoke-PrdFeatureOutputStdinEntry {
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

    It 'exits 2 with a stderr reason when last_assistant_message lacks an existing spec-path' -Tag 'E3-Entry' {
        # Arrange
        $stdin = ConvertTo-SubagentStopEnvelopeJson -AgentType 'prd-feature' -AssistantMessage 'Wrote the specification.'
        # Act
        $result = Invoke-PrdFeatureOutputStdinEntry -Stdin $stdin
        # Assert
        $result.Thrown | Should -BeNullOrEmpty
        $result.ExitCode | Should -Be 2
        $result.Stderr | Should -Match 'spec-path is required and must exist'
    }

    It 'exits 0 when last_assistant_message carries an existing spec-path whose spec has no derived numeric criterion' -Tag 'E3-Entry' {
        # Arrange: the synthetic spec path is reported present and holds a textual criterion.
        Mock Test-Path { $true } -ParameterFilter { $LiteralPath -eq 'synthetic/spec.md' }
        Mock Get-Content { "## Acceptance Criteria`n- [ ] A textual criterion" } -ParameterFilter { $LiteralPath -eq 'synthetic/spec.md' }
        $stdin = ConvertTo-SubagentStopEnvelopeJson -AgentType 'prd-feature' -AssistantMessage 'spec-path: synthetic/spec.md'
        # Act
        $result = Invoke-PrdFeatureOutputStdinEntry -Stdin $stdin
        # Assert
        $result.Thrown | Should -BeNullOrEmpty
        $result.ExitCode | Should -Be 0
        $result.Stderr | Should -BeNullOrEmpty
    }

    It 'blocks when spec-path is supplied only in an output field or through CLAUDE_HOOK_INPUT' -Tag 'E3-Entry' {
        # Arrange: the spec path appears only in an output key and in the environment variable.
        Mock Test-Path { $true } -ParameterFilter { $LiteralPath -eq 'synthetic/spec.md' }
        Mock Get-Content { "## Acceptance Criteria`n- [ ] A textual criterion" } -ParameterFilter { $LiteralPath -eq 'synthetic/spec.md' }
        $stdin = ConvertTo-SubagentStopEnvelopeJson -AgentType 'prd-feature' -AssistantMessage 'Wrote the specification.' -OutputField 'spec-path: synthetic/spec.md'
        $priorInput = $env:CLAUDE_HOOK_INPUT
        try {
            $env:CLAUDE_HOOK_INPUT = '{"output":"spec-path: synthetic/spec.md"}'
            # Act
            $result = Invoke-PrdFeatureOutputStdinEntry -Stdin $stdin
        }
        finally { $env:CLAUDE_HOOK_INPUT = $priorInput }
        # Assert
        $result.Thrown | Should -BeNullOrEmpty
        $result.ExitCode | Should -Be 2
        $result.Stderr | Should -Match 'spec-path is required and must exist'
    }

    It 'exits 2 with the empty-message reason when last_assistant_message is an empty string' -Tag 'E3-Entry' {
        # Arrange
        $stdin = ConvertTo-SubagentStopEnvelopeJson -AgentType 'prd-feature' -AssistantMessage ''
        # Act
        $result = Invoke-PrdFeatureOutputStdinEntry -Stdin $stdin
        # Assert
        $result.Thrown | Should -BeNullOrEmpty
        $result.ExitCode | Should -Be 2
        $result.Stderr | Should -Match 'last assistant message is empty'
    }

    It 'exits 2 with a payload anomaly reason for empty stdin' -Tag 'E3-Entry' {
        # Arrange and act: no stdin content.
        $result = Invoke-PrdFeatureOutputStdinEntry -Stdin ''
        # Assert
        $result.Thrown | Should -BeNullOrEmpty
        $result.ExitCode | Should -Be 2
        $result.Stderr | Should -Match 'prd-feature hook:'
        $result.Stderr | Should -Match 'payload anomaly'
    }

    It 'exits 2 with a payload anomaly reason for malformed stdin' -Tag 'E3-Entry' {
        # Arrange and act: stdin that is not JSON.
        $result = Invoke-PrdFeatureOutputStdinEntry -Stdin '{not-json'
        # Assert
        $result.Thrown | Should -BeNullOrEmpty
        $result.ExitCode | Should -Be 2
        $result.Stderr | Should -Match 'prd-feature hook:'
        $result.Stderr | Should -Match 'payload anomaly'
    }

    It 'exits 2 with a payload anomaly reason when last_assistant_message is absent' -Tag 'E3-Entry' {
        # Arrange and act: an envelope without last_assistant_message.
        $result = Invoke-PrdFeatureOutputStdinEntry -Stdin (ConvertTo-SubagentStopEnvelopeJson -AgentType 'prd-feature' -OmitAssistantMessage)
        # Assert
        $result.Thrown | Should -BeNullOrEmpty
        $result.ExitCode | Should -Be 2
        $result.Stderr | Should -Match 'prd-feature hook:'
        $result.Stderr | Should -Match 'payload anomaly'
    }

    It 'keeps validating when stop_hook_active is true' -Tag 'E3-Entry' {
        # Arrange: a re-entry envelope that still carries no spec-path.
        $stdin = ConvertTo-SubagentStopEnvelopeJson -AgentType 'prd-feature' -AssistantMessage 'Wrote the specification.' -StopHookActive
        # Act
        $result = Invoke-PrdFeatureOutputStdinEntry -Stdin $stdin
        # Assert
        $result.Thrown | Should -BeNullOrEmpty
        $result.ExitCode | Should -Be 2
    }

    It 'exits 2 with a stderr reason when the spec-path file cannot be read' -Tag 'E3-Entry' {
        # Arrange: the spec path is present but its read fails.
        Mock Test-Path { $true } -ParameterFilter { $LiteralPath -eq 'synthetic/spec.md' }
        Mock Get-Content { throw 'simulated read failure' } -ParameterFilter { $LiteralPath -eq 'synthetic/spec.md' }
        $stdin = ConvertTo-SubagentStopEnvelopeJson -AgentType 'prd-feature' -AssistantMessage 'spec-path: synthetic/spec.md'
        # Act
        $result = Invoke-PrdFeatureOutputStdinEntry -Stdin $stdin
        # Assert
        $result.Thrown | Should -BeNullOrEmpty
        $result.ExitCode | Should -Be 2
        $result.Stderr | Should -Match 'failed to read spec-path'
    }

    It 'exits 2 in a separate process when the stdin envelope lacks a spec-path' -Tag 'E3-Entry' {
        # Arrange
        $stdinText = ConvertTo-SubagentStopEnvelopeJson -AgentType 'prd-feature' -AssistantMessage 'Wrote the specification.'
        # Act
        $global:LASTEXITCODE = 0
        $null = $stdinText | & $script:PwshExe -NoProfile -File $script:StdinHook 2>&1
        # Assert
        $LASTEXITCODE | Should -Be 2
    }

    It 'exits 0 without a research-path when the acceptance criteria contain only non-derived numerals' -Tag 'E3-Entry' {
        # Arrange: the criterion carries thresholds, exit codes, issue numbers, file:line and dates only.
        Mock Test-Path { $true } -ParameterFilter { $LiteralPath -eq 'synthetic/spec.md' }
        Mock Get-Content { "## Acceptance Criteria`n- [ ] AC-01: The hook exits 2 when line coverage is >= 85% (Refs #905, typescript.md:57, 2026-10-11)." } -ParameterFilter { $LiteralPath -eq 'synthetic/spec.md' }
        $stdin = ConvertTo-SubagentStopEnvelopeJson -AgentType 'prd-feature' -AssistantMessage 'spec-path: synthetic/spec.md'
        # Act
        $result = Invoke-PrdFeatureOutputStdinEntry -Stdin $stdin
        # Assert
        $result.Thrown | Should -BeNullOrEmpty
        $result.ExitCode | Should -Be 0
        $result.Stderr | Should -BeNullOrEmpty
    }

    It 'exits 2 with a stderr reason when the research-path file cannot be read' -Tag 'E3-Entry' {
        # Arrange: a derived-count criterion, a present research path, and a failing research read.
        Mock Test-Path { $true } -ParameterFilter { $LiteralPath -eq 'synthetic/spec.md' }
        Mock Get-Content { "## Acceptance Criteria`n- [ ] All 12 agent files contain the marker." } -ParameterFilter { $LiteralPath -eq 'synthetic/spec.md' }
        Mock Test-Path { $true } -ParameterFilter { $LiteralPath -eq 'synthetic/research.md' }
        Mock Get-Content { throw 'simulated read failure' } -ParameterFilter { $LiteralPath -eq 'synthetic/research.md' }
        $stdin = ConvertTo-SubagentStopEnvelopeJson -AgentType 'prd-feature' -AssistantMessage "spec-path: synthetic/spec.md`nresearch-path: synthetic/research.md"
        # Act
        $result = Invoke-PrdFeatureOutputStdinEntry -Stdin $stdin
        # Assert
        $result.Thrown | Should -BeNullOrEmpty
        $result.ExitCode | Should -Be 2
        $result.Stderr | Should -Match 'failed to read research-path'
    }
}
