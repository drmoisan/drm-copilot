#Requires -Version 7.0
<#
.SYNOPSIS
    Coverage tests for .codex/hooks/validate-codex-subagent-routing.ps1 (issue #786).

.DESCRIPTION
    Exercises the payload parser, the gated-agent rule, the continuation shapes, every
    decision branch, the attestation scan, and the entry point (stdin redirected and restored
    in finally). State reads go through Pester mocks of Test-Path, Get-ChildItem, and
    Get-Content; no test creates, renames, moves, or deletes a file.
#>

Describe 'Codex validate-codex-subagent-routing coverage (issue #786)' {
    BeforeAll {
        $script:HookFile = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../.codex/hooks/validate-codex-subagent-routing.ps1'))
        . $script:HookFile

        function Invoke-SubagentRoutingEntry {
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

    Context 'helpers' {
        It 'throws on a blank or malformed payload' {
            { ConvertFrom-CodexStopJson -Raw ' ' -Name 'input' } | Should -Throw '*input is empty*'
            { ConvertFrom-CodexStopJson -Raw '{bad' -Name 'input' } | Should -Throw '*malformed JSON*'
        }

        It 'gates a tiered agent name' {
            Test-CodexStopGatedAgent -AgentType 'reviewer-c3-elevated' | Should -BeTrue
        }

        It 'stops the loop when a continuation was already requested' {
            (Get-CodexStopContinuation -Reason 'r' -AlreadyContinued $true).continue | Should -BeFalse
            (Get-CodexStopContinuation -Reason 'r' -AlreadyContinued $false).decision | Should -Be 'block'
        }
    }

    Context 'Invoke-CodexSubagentStopDecision' {
        It 'allows an ungated agent' {
            Invoke-CodexSubagentStopDecision -PayloadRaw '{"agent_type":"general-purpose"}' -AttestationRaw '' | Should -BeNullOrEmpty
        }

        It 'reports <Case>' -ForEach @(
            @{ Case = 'a missing epic attestation'; Payload = '{"agent_type":"epic-planner"}'; Attestation = ''; Pattern = 'EPIC_INVOCATION_ORIGIN_BLOCKED: no SubagentStart' },
            @{ Case = 'a missing routed attestation'; Payload = '{"agent_type":"pr-author"}'; Attestation = ''; Pattern = 'MODEL_ROUTING_ATTESTATION_BLOCKED: no SubagentStart' },
            @{ Case = 'an identity mismatch'; Payload = '{"agent_type":"pr-author","agent_id":"a"}'; Attestation = '{"agent_type":"pr-author","agent_id":"b"}'; Pattern = 'identity does not match' },
            @{ Case = 'missing epic provenance'; Payload = '{"agent_type":"epic-planner","agent_id":"a"}'; Attestation = '{"agent_type":"epic-planner","agent_id":"a"}'; Pattern = 'lacks valid root provenance' },
            @{ Case = 'invalid routing'; Payload = '{"agent_type":"pr-author","agent_id":"a"}'; Attestation = '{"agent_type":"pr-author","agent_id":"a","routing_valid":false}'; Pattern = 'recorded deployment model' },
            @{ Case = 'a model change'; Payload = '{"agent_type":"pr-author","agent_id":"a","model":"m2"}'; Attestation = '{"agent_type":"pr-author","agent_id":"a","routing_valid":true,"actual_model":"m1"}'; Pattern = 'stop model differs' }
        ) {
            (Invoke-CodexSubagentStopDecision -PayloadRaw $Payload -AttestationRaw $Attestation).reason | Should -Match $Pattern
        }

        It 'allows a matching attestation' {
            Invoke-CodexSubagentStopDecision -PayloadRaw '{"agent_type":"pr-author","agent_id":"a","model":"m1"}' -AttestationRaw '{"agent_type":"pr-author","agent_id":"a","routing_valid":true,"actual_model":"m1"}' | Should -BeNullOrEmpty
        }
    }

    Context 'Find-CodexStopAttestationRaw' {
        It 'returns nothing when the state root is absent' {
            Mock Test-Path { $false }
            Find-CodexStopAttestationRaw -StateRoot 'C:\state' -AgentId 'a' | Should -Be ''
        }

        It 'returns the attestation whose agent id matches and skips unreadable files' {
            Mock Test-Path { $true }
            Mock Get-ChildItem { @([pscustomobject]@{ FullName = 'C:\state\bad.json' }, [pscustomobject]@{ FullName = 'C:\state\other.json' }, [pscustomobject]@{ FullName = 'C:\state\good.json' }) }
            Mock Get-Content { param($LiteralPath) switch -Wildcard ([string]$LiteralPath) { '*bad.json' { '{bad' } '*other.json' { '{"agent_id":"z"}' } default { '{"agent_id":"a"}' } } }
            Find-CodexStopAttestationRaw -StateRoot 'C:\state' -AgentId 'a' | Should -Be '{"agent_id":"a"}'
        }

        It 'returns nothing when no attestation matches' {
            Mock Test-Path { $true }
            Mock Get-ChildItem { @([pscustomobject]@{ FullName = 'C:\state\other.json' }) }
            Mock Get-Content { '{"agent_id":"z"}' }
            Find-CodexStopAttestationRaw -StateRoot 'C:\state' -AgentId 'a' | Should -Be ''
        }
    }

    Context 'entry point' {
        It 'exits 2 for <Case>' -ForEach @(
            @{ Case = 'blank stdin'; Stdin = '   '; Pattern = 'is empty' },
            @{ Case = 'a missing session id'; Stdin = '{"agent_type":"pr-author"}'; Pattern = 'session_id is empty' }
        ) {
            $result = Invoke-SubagentRoutingEntry -Stdin $Stdin
            $result.ExitCode | Should -Be 2
            $result.Stderr | Should -Match $Pattern
        }

        It 'requests a continuation for a routed agent without an attestation' {
            Mock Find-CodexStopAttestationRaw { '' }
            $result = Invoke-SubagentRoutingEntry -Stdin '{"session_id":"s-786","agent_type":"pr-author","agent_id":"a"}'
            $result.ExitCode | Should -Be 0
            ($result.Stdout | ConvertFrom-Json).decision | Should -Be 'block'
        }
    }
}
