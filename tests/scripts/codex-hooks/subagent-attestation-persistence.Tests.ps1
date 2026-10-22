#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
    $script:HookRoot = Join-Path $script:RepoRoot '.codex/hooks'
    . (Join-Path $script:HookRoot 'record-subagent-routing-attestation.ps1')
    . (Join-Path $script:HookRoot 'authorize-root-epic-invocation.ps1')
    $script:Now = [datetimeoffset]'2026-07-10T15:00:00Z'
    $script:HeadSha = 'a' * 40
}

Describe 'Subagent attestation required and optional JSON input' {
    It 'parses valid JSON without changing its fields' {
        $result = ConvertFrom-SubagentAttestationJson -Raw '{"session_id":"one"}' -Name 'payload'
        $result.session_id | Should -Be 'one'
    }

    It 'rejects required <Label> input with a specific diagnostic' -ForEach @(
        @{ Label = 'blank'; Raw = ''; Message = '*payload is empty*' }
        @{ Label = 'malformed'; Raw = '{'; Message = '*payload is malformed JSON*' }
    ) {
        { ConvertFrom-SubagentAttestationJson -Raw $Raw -Name 'payload' } | Should -Throw $Message
    }

    It 'ignores optional <Label> input' -ForEach @(
        @{ Label = 'blank'; Raw = '' }
        @{ Label = 'malformed'; Raw = '{' }
    ) {
        ConvertFrom-SubagentAttestationJson -Raw $Raw -Name 'checkpoint' -Optional | Should -BeNullOrEmpty
    }

    It 'uses the agent identity when the transcript path is absent' {
        $fallback = Get-SubagentAttestationKey -TranscriptPath '' -AgentId 'agent-one'
        $fallback | Should -Be (Get-SubagentAttestationKey -TranscriptPath 'agent-one' -AgentId 'other')
        $fallback | Should -Match '^[0-9a-f]{64}$'
        $fallback | Should -Not -Be (Get-SubagentAttestationKey -TranscriptPath 'transcript' -AgentId 'agent-one')
    }
}

Describe 'Subagent attestation input and root-receipt rejection' {
    BeforeEach {
        $script:Payload = [pscustomobject]@{
            session_id = 'one'; turn_id = 'turn'; agent_id = 'child'
            agent_type = 'epic-planner'; model = 'gpt-6-astra'
        }
        $script:Receipt = Get-RootEpicInvocationReceipt -Payload ([pscustomobject]@{
                session_id = 'one'; turn_id = 'turn'; prompt = '/epic-plan sample'
            }) -Now $script:Now -RepositoryRoot $script:RepoRoot -HeadSha $script:HeadSha |
            ConvertTo-Json | ConvertFrom-Json
    }

    It 'rejects a missing <Field> before profile or authority lookup' -ForEach @(
        @{ Field = 'agent_id' }; @{ Field = 'agent_type' }; @{ Field = 'model' }
    ) {
        $script:Payload.$Field = ''
        { Get-CodexSubagentAttestation -Payload $script:Payload -RootReceipt $null -Checkpoints @() -RepositoryRoot $script:RepoRoot -CurrentHeadSha $script:HeadSha -Now $script:Now } |
            Should -Throw '*requires agent_id, agent_type, and model*'
    }

    It 'rejects root <Case> metadata' -ForEach @(
        @{ Case = 'null'; Field = ''; Value = $null }
        @{ Case = 'consumption'; Field = 'consumed_by'; Value = 'prior' }
        @{ Case = 'entry'; Field = 'entry_kind'; Value = 'epic-run' }
        @{ Case = 'reference'; Field = 'epic_reference'; Value = '' }
        @{ Case = 'unexpected kickoff'; Field = 'kickoff_path'; Value = 'unexpected' }
        @{ Case = 'created time'; Field = 'created_at'; Value = 'invalid' }
    ) {
        if ($Field) { $script:Receipt.$Field = $Value } else { $script:Receipt = $null }
        Test-RootEpicReceipt -Receipt $script:Receipt -Payload $script:Payload -RepositoryRoot $script:RepoRoot -CurrentHeadSha $script:HeadSha -Now $script:Now |
            Should -BeFalse
    }

    It 'records profile lookup failure as rejected attestation' {
        Mock Get-CodexAgentProfileAttestation { throw 'profile missing' }
        $result = Get-CodexSubagentAttestation -Payload $script:Payload -RootReceipt $script:Receipt -Checkpoints @() -RepositoryRoot $script:RepoRoot -CurrentHeadSha $script:HeadSha -Now $script:Now
        $result.routing_valid | Should -BeFalse
        $result.profile_validation_error | Should -Match 'profile missing'
    }
}

Describe 'Subagent attestation persistence with memory streams' {
    BeforeEach {
        $script:Stream = [System.IO.MemoryStream]::new()
        $script:Opened = $null
        $script:Directory = $null
        $script:Flushed = $false
        Mock Get-CodexAuthorityStateRoot { 'memory-authority' }
        Mock Get-CodexAuthorityAttestationPath { 'memory-authority/record.json' }
        Mock Test-Path { $true }
        Mock Get-CodexSubagentAttestation { [ordered]@{ root_authorized = $true; routing_valid = $true } }
        $script:Payload = [pscustomobject]@{ session_id = 'one'; agent_id = 'child'; agent_type = 'epic-planner' }
        $script:Open = {
            param($Path, $Mode, $Access, $Share)
            $script:Opened = @($Path, $Mode, $Access, $Share)
            $script:Stream
        }
    }

    AfterEach {
        $script:Stream.Dispose()
    }

    It 'writes UTF8 without a BOM, preserves content and closes the exclusive new stream' {
        $attestation = [ordered]@{ session_id = 'one'; attestation_key = 'key'; actual_model = 'gpt-6-astra'; label = [string][char]0x00e9 }
        $result = Write-CodexSubagentAttestation -RepositoryRoot $script:RepoRoot -Attestation $attestation -OpenStream $script:Open -EnsureDirectory { param($Path) $script:Directory = $Path }
        $result | Should -Be 'memory-authority/record.json'
        $script:Directory | Should -Be 'memory-authority'
        $script:Opened | Should -Be @('memory-authority/record.json', [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::None)
        $bytes = $script:Stream.ToArray()
        [Text.Encoding]::UTF8.GetString($bytes) | Should -Be ($attestation | ConvertTo-Json -Depth 8)
        $bytes[0] | Should -Be 123
        $script:Stream.CanRead | Should -BeFalse
    }

    It 'propagates directory or stream construction failure' -ForEach @(
        @{ Boundary = 'directory' }; @{ Boundary = 'stream' }
    ) {
        $ensure = { param($Path) $script:Directory = $Path }
        $open = $script:Open
        if ($Boundary -eq 'directory') { $ensure = { param($Path) throw "directory rejected: $Path" } }
        else { $open = { param($Path, $Mode, $Access, $Share) throw "stream rejected: $Path/$Mode/$Access/$Share" } }
        { Write-CodexSubagentAttestation -RepositoryRoot $script:RepoRoot -Attestation @{ session_id = 'one'; attestation_key = 'key' } -OpenStream $open -EnsureDirectory $ensure } |
            Should -Throw "*$Boundary rejected*"
    }

    It 'returns without opening authority for <Case>' -ForEach @(
        @{ Case = 'non-epic'; Agent = 'atomic-executor-c3'; Exists = $true }
        @{ Case = 'discovery specialist'; Agent = 'legacy-parity-analyst-c3'; Exists = $true }
        @{ Case = 'absent receipt'; Agent = 'epic-planner'; Exists = $false }
    ) {
        $script:Payload.agent_type = $Agent
        $script:ReceiptExists = $Exists
        Mock Test-Path { $script:ReceiptExists }
        $result = Get-CodexSubagentAttestationFromAuthority -Payload $script:Payload -ReceiptPath 'memory.json' -Checkpoints @() -RepositoryRoot $script:RepoRoot -CurrentHeadSha $script:HeadSha -Now $script:Now -OpenStream { throw 'must not open' }
        $result.routing_valid | Should -BeTrue
        Should -Invoke Get-CodexSubagentAttestation -Times 1 -Exactly
    }

    It 'consumes only an authorized receipt and durably flushes before disposal' -ForEach @(
        @{ Authorized = $true }; @{ Authorized = $false }
    ) {
        $script:AuthorityAuthorized = $Authorized
        Mock Get-CodexSubagentAttestation { [ordered]@{ root_authorized = $script:AuthorityAuthorized } }
        $original = '{"consumed":false,"consumed_by":null,"consumed_at":null,"marker":"preserved"}'
        $bytes = [Text.Encoding]::UTF8.GetBytes($original)
        $script:Stream.Write($bytes, 0, $bytes.Length)
        $script:Stream.Position = 0
        $result = Get-CodexSubagentAttestationFromAuthority -Payload $script:Payload -ReceiptPath 'memory.json' -Checkpoints @() -RepositoryRoot $script:RepoRoot -CurrentHeadSha $script:HeadSha -Now $script:Now -OpenStream $script:Open -FlushStream { param($Stream) $script:Flushed = $true; $Stream.Flush() }
        $script:Opened | Should -Be @('memory.json', [IO.FileMode]::Open, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None)
        $serialized = [Text.Encoding]::UTF8.GetString($script:Stream.ToArray())
        if ($Authorized) {
            $receipt = $serialized | ConvertFrom-Json
            $receipt.consumed | Should -BeTrue
            $receipt.consumed_by | Should -Be 'child'
            $serialized | Should -Match ([regex]::Escape('"consumed_at": "' + $script:Now.ToUniversalTime().ToString('o') + '"'))
            $receipt.marker | Should -Be 'preserved'
        } else { $serialized | Should -Be $original }
        $result.root_authorized | Should -Be $Authorized
        $script:Flushed | Should -Be $Authorized
        $script:Stream.CanRead | Should -BeFalse
    }

    It 'propagates malformed authority JSON and disposes its stream' {
        $script:Stream.WriteByte(123)
        $script:Stream.Position = 0
        { Get-CodexSubagentAttestationFromAuthority -Payload $script:Payload -ReceiptPath 'memory.json' -Checkpoints @() -RepositoryRoot $script:RepoRoot -CurrentHeadSha $script:HeadSha -Now $script:Now -OpenStream $script:Open } |
            Should -Throw '*root receipt is malformed JSON*'
        $script:Stream.CanRead | Should -BeFalse
    }

    It 'propagates an exclusive authority-open failure' {
        { Get-CodexSubagentAttestationFromAuthority -Payload $script:Payload -ReceiptPath 'memory.json' -Checkpoints @() -RepositoryRoot $script:RepoRoot -CurrentHeadSha $script:HeadSha -Now $script:Now -OpenStream { param($Path, $Mode, $Access, $Share) throw "exclusive open rejected: $Path/$Mode/$Access/$Share" } } |
            Should -Throw '*exclusive open rejected*'
    }

    It 'disposes the authority stream when durable flush fails' {
        $bytes = [Text.Encoding]::UTF8.GetBytes('{"consumed":false,"consumed_by":null,"consumed_at":null}')
        $script:Stream.Write($bytes, 0, $bytes.Length)
        $script:Stream.Position = 0
        { Get-CodexSubagentAttestationFromAuthority -Payload $script:Payload -ReceiptPath 'memory.json' -Checkpoints @() -RepositoryRoot $script:RepoRoot -CurrentHeadSha $script:HeadSha -Now $script:Now -OpenStream $script:Open -FlushStream { param($Stream) throw "durable flush rejected: $($Stream.Position)" } } |
            Should -Throw '*durable flush rejected*'
        $script:Stream.CanRead | Should -BeFalse
    }
}

Describe 'Single-use authority consumption preserves real authorization' {
    It 'authorizes once and rejects the serialized consumed receipt on reuse' {
        Mock Test-Path { $true }
        Mock Get-CodexAgentProfileAttestation {
            [pscustomobject]@{
                profile_name = 'epic-planner'; profile_model = 'gpt-6-astra'
                profile_reasoning_effort = 'ultra'; profile_path = '.codex/agents/epic-planner.toml'
                profile_sha256 = ('f' * 64)
            }
        }
        $payload = [pscustomobject]@{
            session_id = 'one'; turn_id = 'turn'; agent_id = 'child'
            agent_type = 'epic-planner'; model = 'gpt-6-astra'
        }
        $receipt = Get-RootEpicInvocationReceipt -Payload ([pscustomobject]@{
                session_id = 'one'; turn_id = 'turn'; prompt = '/epic-plan sample'
            }) -Now $script:Now -RepositoryRoot $script:RepoRoot -HeadSha $script:HeadSha
        $script:SerializedAuthority = $receipt | ConvertTo-Json
        foreach ($attempt in 1..2) {
            $script:AuthorityStream = [IO.MemoryStream]::new()
            try {
                $bytes = [Text.Encoding]::UTF8.GetBytes($script:SerializedAuthority)
                $script:AuthorityStream.Write($bytes, 0, $bytes.Length)
                $script:AuthorityStream.Position = 0
                $result = Get-CodexSubagentAttestationFromAuthority -Payload $payload -ReceiptPath 'memory.json' -Checkpoints @() -RepositoryRoot $script:RepoRoot -CurrentHeadSha $script:HeadSha -Now $script:Now -OpenStream {
                    param($Path, $Mode, $Access, $Share)
                    $Path | Should -Be 'memory.json'
                    $Mode | Should -Be ([IO.FileMode]::Open)
                    $Access | Should -Be ([IO.FileAccess]::ReadWrite)
                    $Share | Should -Be ([IO.FileShare]::None)
                    $script:AuthorityStream
                } -FlushStream { param($Stream) $Stream.Flush() }
                $result.root_authorized | Should -Be ($attempt -eq 1)
                $result.provenance_valid | Should -Be ($attempt -eq 1)
                $result.routing_valid | Should -BeTrue
                $script:SerializedAuthority = [Text.Encoding]::UTF8.GetString($script:AuthorityStream.ToArray())
                $script:AuthorityStream.CanRead | Should -BeFalse
            } finally { $script:AuthorityStream.Dispose() }
        }
    }
}
