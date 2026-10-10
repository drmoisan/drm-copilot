#Requires -Version 7.0
<#
.SYNOPSIS
    Coverage tests for .codex/hooks/enforce-codex-model-routing.ps1 (issue #786).

.DESCRIPTION
    Exercises the payload parser, the attestation key, the profile-attestation rejections, the
    unrouted-agent allow, and the entry point (stdin redirected and restored in finally).
    Attestation reads go through Pester mocks of Test-Path, Get-ChildItem, and Get-Content; no
    test creates, renames, moves, or deletes a file.
#>

Describe 'Codex enforce-codex-model-routing coverage (issue #786)' {
    BeforeAll {
        $script:HookFile = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../.codex/hooks/enforce-codex-model-routing.ps1'))
        . $script:HookFile

        function Invoke-ModelRoutingEntry {
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

        function Get-SampleAttestation {
            # A schema-2 attestation with every required field; the named fields are overridden.
            param([hashtable] $Override = @{})
            $value = [ordered]@{
                schema_version = 2; routing_valid = $true; profile_validation_error = ''
                agent_type = 'atomic-executor'; actual_model = 'm'; expected_model = 'm'
                actual_reasoning_effort = 'high'; expected_reasoning_effort = 'high'
                profile_name = 'p'; profile_model = 'm'; profile_path = 'agents/p.toml'; profile_sha256 = ('a' * 64)
            }
            foreach ($key in $Override.Keys) { $value[$key] = $Override[$key] }
            return [pscustomobject]$value
        }
    }

    Context 'helpers and decision' {
        It 'throws on an empty or malformed payload' {
            { ConvertFrom-CodexModelGateJson -Raw ' ' -Name 'input' } | Should -Throw '*input is empty*'
            { ConvertFrom-CodexModelGateJson -Raw '{bad' -Name 'input' } | Should -Throw '*malformed JSON*'
        }

        It 'derives a 64-character lowercase attestation key' {
            Get-CodexModelGateAttestationKey -TranscriptPath 'C:\t.jsonl' | Should -Match '^[0-9a-f]{64}$'
        }

        It 'rejects an attestation missing <Case>' -ForEach @(
            @{ Case = 'a required field'; Override = @{ profile_name = '' } },
            @{ Case = 'a well-formed profile hash'; Override = @{ profile_sha256 = 'xyz' } }
        ) {
            Test-CodexModelGateProfileAttestation -Payload ([pscustomobject]@{ model = 'm' }) -Attestation (Get-SampleAttestation -Override $Override) -RepositoryRoot 'C:\repo' | Should -BeFalse
        }

        It 'rejects an attestation whose agent profile cannot be read' {
            Mock Get-CodexAgentProfileAttestation { throw 'simulated profile read failure' }
            Test-CodexModelGateProfileAttestation -Payload ([pscustomobject]@{ model = 'm' }) -Attestation (Get-SampleAttestation) -RepositoryRoot 'C:\repo' | Should -BeFalse
        }

        It 'rejects an attestation whose profile binding does not hold' {
            Mock Get-CodexAgentProfileAttestation { [pscustomobject]@{ profile_name = 'p'; profile_model = 'm'; profile_reasoning_effort = 'high' } }
            Mock Test-CodexAgentProfileBinding { $false }
            Test-CodexModelGateProfileAttestation -Payload ([pscustomobject]@{ model = 'm' }) -Attestation (Get-SampleAttestation) -RepositoryRoot 'C:\repo' | Should -BeFalse
        }

        It 'accepts an attestation whose profile and payload agree' {
            Mock Get-CodexAgentProfileAttestation { [pscustomobject]@{ profile_name = 'p'; profile_model = 'm'; profile_reasoning_effort = 'high' } }
            Mock Test-CodexAgentProfileBinding { $true }
            Test-CodexModelGateProfileAttestation -Payload ([pscustomobject]@{ model = 'm' }) -Attestation (Get-SampleAttestation) -RepositoryRoot 'C:\repo' | Should -BeTrue
        }

        It 'allows a valid attestation and denies a routed agent without one' {
            Mock Test-CodexModelGateProfileAttestation { $true }
            Invoke-CodexModelRoutingDecision -PayloadRaw '{"agent_type":"atomic-executor"}' -AttestationRaw '{"schema_version":2}' | Should -BeNullOrEmpty
            (Invoke-CodexModelRoutingDecision -PayloadRaw '{"agent_type":"atomic-executor"}' -AttestationRaw '').hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'allows an unrouted agent without an attestation' {
            Invoke-CodexModelRoutingDecision -PayloadRaw '{"agent_type":"general-purpose"}' -AttestationRaw '' | Should -BeNullOrEmpty
        }
    }

    Context 'entry point' {
        It 'exits 2 for <Case>' -ForEach @(
            @{ Case = 'whitespace stdin'; Stdin = '   ' },
            @{ Case = 'malformed stdin'; Stdin = '{bad' }
        ) {
            $result = Invoke-ModelRoutingEntry -Stdin $Stdin
            $result.ExitCode | Should -Be 2
            $result.Stderr | Should -Match 'MODEL_ROUTING_ATTESTATION_BLOCKED'
        }

        It 'reads the transcript-keyed attestation and denies profile drift' {
            Mock Test-Path { $true } -ParameterFilter { ([string]$LiteralPath) -like '*codex-routing-attestation.*' }
            Mock Get-Content { '{"schema_version":1,"agent_type":"atomic-executor"}' } -ParameterFilter { ([string]$LiteralPath) -like '*codex-routing-attestation.*' }
            $result = Invoke-ModelRoutingEntry -Stdin '{"session_id":"s-786","transcript_path":"C:\\t.jsonl","agent_type":"atomic-executor","model":"m"}'
            $result.ExitCode | Should -Be 0
            ($result.Stdout | ConvertFrom-Json).hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'falls back to the agent-id attestation scan' {
            Mock Get-ChildItem { @([pscustomobject]@{ FullName = 'C:\state\bad.json' }, [pscustomobject]@{ FullName = 'C:\state\good.json' }) }
            Mock Get-Content { param($LiteralPath) if (([string]$LiteralPath).EndsWith('bad.json')) { '{bad' } else { '{"agent_id":"a-786","schema_version":1}' } }
            $result = Invoke-ModelRoutingEntry -Stdin '{"session_id":"s-786","agent_id":"a-786","agent_type":"atomic-executor","model":"m"}'
            $result.ExitCode | Should -Be 0
            ($result.Stdout | ConvertFrom-Json).hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'allows an unrouted agent with no attestation' {
            $result = Invoke-ModelRoutingEntry -Stdin '{"agent_type":"general-purpose"}'
            $result.ExitCode | Should -Be 0
            $result.Stdout | Should -BeNullOrEmpty
        }
    }
}
