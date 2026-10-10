#Requires -Version 7.0
<#
.SYNOPSIS
    Coverage tests for .codex/hooks/enforce-epic-root-invocation.ps1 (issue #786).

.DESCRIPTION
    Exercises the payload parser, the attestation key, the decision branches, and the entry point
    (stdin redirected and restored in finally). Attestation reads go through Pester mocks of
    Test-Path, Get-ChildItem, and Get-Content; no test creates, renames, moves, or deletes a file.
#>

Describe 'Codex enforce-epic-root-invocation coverage (issue #786)' {
    BeforeAll {
        $script:HookFile = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../.codex/hooks/enforce-epic-root-invocation.ps1'))
        . $script:HookFile

        function Invoke-RootInvocationEntry {
            # Drives the entry point with the given stdin; stdin and stderr are restored in finally.
            param([AllowEmptyString()] [string] $Stdin)
            $priorIn = [System.Console]::In
            $priorError = [System.Console]::Error
            $errorWriter = [System.IO.StringWriter]::new()
            try {
                [System.Console]::SetIn([System.IO.StringReader]::new($Stdin))
                [System.Console]::SetError($errorWriter)
                $global:LASTEXITCODE = 0
                $stdout = @(& $script:HookFile)
                return [pscustomobject]@{ ExitCode = $LASTEXITCODE; Stdout = (($stdout | ForEach-Object { [string]$_ }) -join "`n"); Stderr = $errorWriter.ToString() }
            }
            finally {
                [System.Console]::SetIn($priorIn)
                [System.Console]::SetError($priorError)
            }
        }
    }

    Context 'helpers and decision' {
        It 'throws on an empty or malformed payload' {
            { ConvertFrom-EpicRootGatePayload -Raw ' ' -Name 'input' } | Should -Throw '*input is empty*'
            { ConvertFrom-EpicRootGatePayload -Raw '{bad' -Name 'input' } | Should -Throw '*malformed JSON*'
        }

        It 'derives a 64-character lowercase attestation key' {
            Get-EpicRootGateAttestationKey -TranscriptPath 'C:\t.jsonl' | Should -Match '^[0-9a-f]{64}$'
        }

        It 'allows a non-epic agent without an attestation' {
            Invoke-EpicRootInvocationDecision -PayloadRaw '{"agent_type":"atomic-executor"}' -AttestationRaw '' | Should -BeNullOrEmpty
        }

        It 'denies an epic agent without an attestation' {
            (Invoke-EpicRootInvocationDecision -PayloadRaw '{"agent_type":"epic-orchestrator"}' -AttestationRaw '').hookSpecificOutput.permissionDecisionReason | Should -Match 'no matching'
        }

        It 'allows an attestation for a non-epic agent' {
            Invoke-EpicRootInvocationDecision -PayloadRaw '{"agent_type":"epic-planner"}' -AttestationRaw '{"agent_type":"atomic-executor"}' | Should -BeNullOrEmpty
        }

        It 'allows an epic agent with valid provenance' {
            Invoke-EpicRootInvocationDecision -PayloadRaw '{"agent_type":"epic-planner"}' -AttestationRaw '{"agent_type":"epic-planner","provenance_valid":true}' | Should -BeNullOrEmpty
        }

        It 'denies an epic agent whose provenance is not valid' {
            (Invoke-EpicRootInvocationDecision -PayloadRaw '{"agent_type":"epic-planner"}' -AttestationRaw '{"agent_type":"epic-planner","provenance_valid":false}').hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }
    }

    Context 'entry point' {
        It 'exits 2 for <Case>' -ForEach @(
            @{ Case = 'whitespace stdin'; Stdin = '   ' },
            @{ Case = 'malformed stdin'; Stdin = '{bad' }
        ) {
            $result = Invoke-RootInvocationEntry -Stdin $Stdin
            $result.ExitCode | Should -Be 2
            $result.Stderr | Should -Match 'EPIC_INVOCATION_ORIGIN_BLOCKED'
        }

        It 'reads the transcript-keyed attestation and allows valid provenance' {
            Mock Test-Path { $true } -ParameterFilter { ([string]$LiteralPath) -like '*codex-routing-attestation.*' }
            Mock Get-Content { '{"agent_type":"epic-planner","provenance_valid":true}' } -ParameterFilter { ([string]$LiteralPath) -like '*codex-routing-attestation.*' }
            $result = Invoke-RootInvocationEntry -Stdin '{"session_id":"s-786","transcript_path":"C:\\t.jsonl","agent_type":"epic-planner"}'
            $result.ExitCode | Should -Be 0
            $result.Stdout | Should -BeNullOrEmpty
        }

        It 'falls back to the agent-id attestation scan and denies missing provenance' {
            Mock Get-ChildItem { @([pscustomobject]@{ FullName = 'C:\state\bad.json' }, [pscustomobject]@{ FullName = 'C:\state\good.json' }) }
            Mock Get-Content { param($LiteralPath) if (([string]$LiteralPath).EndsWith('bad.json')) { '{bad' } else { '{"agent_id":"a-786","agent_type":"epic-orchestrator"}' } }
            $result = Invoke-RootInvocationEntry -Stdin '{"session_id":"s-786","agent_id":"a-786","agent_type":"epic-orchestrator"}'
            $result.ExitCode | Should -Be 0
            ($result.Stdout | ConvertFrom-Json).hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }
    }
}
