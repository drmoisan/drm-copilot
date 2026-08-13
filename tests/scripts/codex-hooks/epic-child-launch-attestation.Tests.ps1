BeforeAll {
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
    . (Join-Path $script:RepoRoot '.codex/hooks/codex-epic-child-launch-attestation.ps1')
    $script:RecordHookPath = Join-Path $script:RepoRoot `
        '.codex/hooks/record-subagent-routing-attestation.ps1'
    . $script:RecordHookPath
    $script:Now = [datetimeoffset]'2026-07-10T22:00:00Z'
    $script:HeadSha = 'a' * 40

    function Get-TestLaunchReceipt {
        param(
            [ValidateSet('epic_preparation_child', 'epic_execution_child')]
            [string] $Context = 'epic_execution_child'
        )
        $waveRoot = Join-Path $script:RepoRoot 'artifacts/orchestration/epic-child-launches/wave-1'
        $checkpoint = if ($Context -eq 'epic_preparation_child') {
            'epic-planner-state.json'
        } else {
            'epic-orchestrator-state.json'
        }
        return [ordered]@{
            schema_version          = 2
            state                   = 'active'
            codex_session_id        = 'session-1'
            session_bound_at        = '2026-07-10T21:59:00Z'
            expires_at              = '2026-07-11T22:00:00Z'
            launch_id               = 'launch-1'
            delegation_id           = 'delegation-1'
            feature_folder          = 'docs/features/active/feature-one'
            deployment_agent        = 'orchestrator-c3-elevated'
            model                   = 'gpt-5.6-sol'
            model_reasoning_effort  = 'high'
            execution_context       = $Context
            worktree_path           = $script:RepoRoot
            branch_name             = 'feature/one'
            receipt_path            = Join-Path $waveRoot 'launch-1.receipt.json'
            status_path             = Join-Path $waveRoot 'wave.wave-1.status.json'
            spec_path               = Join-Path $waveRoot 'spec.json'
            profile_path            = Join-Path $script:RepoRoot '.codex/agents/orchestrator-c3-elevated.toml'
            profile_sha256          = 'profile-hash'
            codex_home_path         = Join-Path $HOME '.codex/authority/epic-child'
            checkpoint_kind         = $(if ($Context -eq 'epic_preparation_child') { 'epic-planner' } else { 'epic-orchestrator' })
            wave_lock_path          = Join-Path $waveRoot 'semantic-wave.lock'
            trusted_repository_root = $script:RepoRoot
            checkpoint_path         = Join-Path $script:RepoRoot "artifacts/orchestration/$checkpoint"
        }
    }

    function Get-TestLaunchEnvironment {
        param([Parameter(Mandatory)] $Receipt)
        return [pscustomobject]@{
            launch_id         = [string]$Receipt.launch_id
            receipt_path      = [string]$Receipt.receipt_path
            spec_path         = [string]$Receipt.spec_path
            worktree_path     = [string]$Receipt.worktree_path
            delegation_id     = [string]$Receipt.delegation_id
            execution_context = [string]$Receipt.execution_context
            deployment_agent  = [string]$Receipt.deployment_agent
            model             = [string]$Receipt.model
            reasoning_effort  = [string]$Receipt.model_reasoning_effort
            profile_sha256    = [string]$Receipt.profile_sha256
        }
    }

    function Test-LaunchAuthority {
        param(
            [Parameter(Mandatory)] $Receipt,
            [Parameter(Mandatory)] $Environment,
            [string] $SessionId = 'session-1'
        )
        $routing = [pscustomobject]@{ execution_context = [string]$Receipt.execution_context }
        $payload = [pscustomobject]@{ session_id = $SessionId }
        return Test-CodexEpicChildRoutingLaunchAuthority -RoutingReceipt $routing -Payload $payload -RepositoryRoot $script:RepoRoot -LaunchEnvironment $Environment -LaunchReceiptRaw ($Receipt | ConvertTo-Json -Depth 12) -Now $script:Now
    }

    function Get-TestEpicRootReceipt {
        param(
            [ValidateSet('epic-plan', 'epic-run', 'epic-orchestrate', 'direct')]
            [string] $EntryKind = 'epic-plan'
        )

        $persona = if ($EntryKind -eq 'epic-plan') { 'epic-planner' } else { 'epic-orchestrator' }
        return [pscustomobject][ordered]@{
            schema_version      = 1
            repository_root     = Get-CodexCanonicalAuthorityPath -Path $script:RepoRoot
            repository_sha256   = Get-CodexAuthorityRepositoryKey -RepositoryRoot $script:RepoRoot
            repository_head_sha = $script:HeadSha
            session_id          = 'session-epic'
            turn_id             = 'turn-epic'
            prompt_sha256       = 'b' * 64
            requested_persona   = $persona
            entry_kind          = $EntryKind
            epic_reference      = $(if ($EntryKind -eq 'direct') { '' } else { 'sample' })
            kickoff_path        = $(if ($EntryKind -eq 'epic-run') {
                    'docs/features/epics/sample/epic-kickoff.md'
                } else { '' })
            created_at          = $script:Now.AddMinutes(-1).ToString('o')
            expires_at          = $script:Now.AddMinutes(30).ToString('o')
            consumed            = $false
            consumed_by         = $null
            consumed_at         = $null
        }
    }

    function Invoke-TestRecordHook {
        param([Parameter(Mandatory)][string] $PayloadRaw)

        $originalIn = [Console]::In
        $originalError = [Console]::Error
        $errorWriter = [System.IO.StringWriter]::new()
        try {
            [Console]::SetIn([System.IO.StringReader]::new($PayloadRaw))
            [Console]::SetError($errorWriter)
            $stdout = & $script:RecordHookPath
            return [pscustomobject]@{
                ExitCode = $LASTEXITCODE
                Stdout   = (@($stdout) -join "`n")
                Stderr   = $errorWriter.ToString()
            }
        } finally {
            [Console]::SetIn($originalIn)
            [Console]::SetError($originalError)
        }
    }
}

Describe 'Codex epic-child launch attestation' {
    It 'requires the launch-authority result in the routed SubagentStart attestation' {
        $recordHook = Get-Content -Raw -LiteralPath (
            Join-Path $script:RepoRoot '.codex/hooks/record-subagent-routing-attestation.ps1'
        )

        $recordHook | Should -Match 'Test-CodexEpicChildRoutingLaunchAuthority'
        $recordHook | Should -Match '\$routingValid\s*=\s*\$routingValid\s+-and\s+\$launchAuthorityValid'
    }

    It 'does not require external launch authority for standalone routing' {
        $result = Test-CodexEpicChildRoutingLaunchAuthority -RoutingReceipt ([pscustomobject]@{ execution_context = 'standalone' }) -Payload ([pscustomobject]@{ session_id = 'session-1' }) -RepositoryRoot $script:RepoRoot

        $result | Should -BeTrue
    }

    It 'accepts a session-bound launch receipt for <Context>' -ForEach @(
        @{ Context = 'epic_preparation_child' }
        @{ Context = 'epic_execution_child' }
    ) {
        $receipt = Get-TestLaunchReceipt -Context $Context

        Test-LaunchAuthority -Receipt $receipt -Environment (Get-TestLaunchEnvironment $receipt) |
            Should -BeTrue
    }

    It 'rejects epic-child routing without inherited launcher environment' {
        $receipt = Get-TestLaunchReceipt

        Test-LaunchAuthority -Receipt $receipt -Environment ([pscustomobject]@{}) |
            Should -BeFalse
    }

    It 'rejects a launch receipt bound to another Codex session' {
        $receipt = Get-TestLaunchReceipt

        Test-LaunchAuthority -Receipt $receipt -Environment (Get-TestLaunchEnvironment $receipt) -SessionId 'session-2' |
            Should -BeFalse
    }

    It 'rejects drift in an inherited launch field' {
        $receipt = Get-TestLaunchReceipt
        $environment = Get-TestLaunchEnvironment $receipt
        $environment.spec_path = Join-Path $script:RepoRoot 'other-spec.json'

        Test-LaunchAuthority -Receipt $receipt -Environment $environment | Should -BeFalse
    }

    It 'rejects a different inherited root delegation id' {
        $receipt = Get-TestLaunchReceipt
        $environment = Get-TestLaunchEnvironment $receipt
        $environment.delegation_id = 'other-delegation'

        Test-LaunchAuthority -Receipt $receipt -Environment $environment | Should -BeFalse
    }

    It 'rejects case drift in an inherited root model identity' {
        $receipt = Get-TestLaunchReceipt
        $environment = Get-TestLaunchEnvironment $receipt
        $environment.model = 'GPT-5.6-SOL'

        Test-LaunchAuthority -Receipt $receipt -Environment $environment | Should -BeFalse
    }

    It 'rejects an expired active receipt' {
        $receipt = Get-TestLaunchReceipt
        $receipt.expires_at = '2026-07-10T21:00:00Z'

        Test-LaunchAuthority -Receipt $receipt -Environment (Get-TestLaunchEnvironment $receipt) |
            Should -BeFalse
    }

    It 'rejects a checkpoint that does not match the epic child context' {
        $receipt = Get-TestLaunchReceipt -Context epic_execution_child
        $receipt.checkpoint_path = Join-Path $script:RepoRoot 'artifacts/orchestration/epic-planner-state.json'

        Test-LaunchAuthority -Receipt $receipt -Environment (Get-TestLaunchEnvironment $receipt) |
            Should -BeFalse
    }

    It 'rejects a receipt outside the trusted launch-artifact root' {
        $receipt = Get-TestLaunchReceipt
        $receipt.receipt_path = Join-Path $script:RepoRoot 'outside.receipt.json'

        Test-LaunchAuthority -Receipt $receipt -Environment (Get-TestLaunchEnvironment $receipt) |
            Should -BeFalse
    }

    It 'normalizes optional and required attestation JSON payloads' {
        ConvertFrom-SubagentAttestationJson -Raw '' -Name optional -Optional |
            Should -BeNullOrEmpty
        ConvertFrom-SubagentAttestationJson -Raw '{' -Name optional -Optional |
            Should -BeNullOrEmpty
        (ConvertFrom-SubagentAttestationJson -Raw '{"agent_id":"agent"}' -Name payload).
        agent_id | Should -Be 'agent'
        { ConvertFrom-SubagentAttestationJson -Raw '' -Name payload } |
            Should -Throw '*payload is empty*'
        { ConvertFrom-SubagentAttestationJson -Raw '{' -Name payload } |
            Should -Throw '*payload is malformed JSON*'
        Get-SubagentAttestationKey -TranscriptPath '' -AgentId agent |
            Should -Match '^[0-9a-f]{64}$'
    }

    It 'validates every supported epic root-entry receipt shape' {
        foreach ($entryKind in @('epic-plan', 'epic-run', 'epic-orchestrate', 'direct')) {
            $receipt = Get-TestEpicRootReceipt -EntryKind $entryKind
            $payload = [pscustomobject]@{
                session_id = 'session-epic'; turn_id = 'turn-epic'
                agent_type = [string]$receipt.requested_persona
            }
            Test-RootEpicReceipt `
                -Receipt $receipt -Payload $payload -RepositoryRoot $script:RepoRoot `
                -CurrentHeadSha $script:HeadSha -Now $script:Now |
                Should -BeTrue
        }
        Test-RootEpicReceipt `
            -Receipt $null -Payload ([pscustomobject]@{}) -RepositoryRoot $script:RepoRoot `
            -CurrentHeadSha $script:HeadSha -Now $script:Now |
            Should -BeFalse
    }

    It 'rejects malformed, drifted, consumed, and expired epic receipts' {
        $base = Get-TestEpicRootReceipt -EntryKind epic-run
        $payload = [pscustomobject]@{
            session_id = 'session-epic'; turn_id = 'turn-epic'
            agent_type = 'epic-orchestrator'
        }
        $cases = @(
            { param($r) $r.PSObject.Properties.Remove('entry_kind') }
            { param($r) Add-Member -InputObject $r -NotePropertyName unexpected -NotePropertyValue value }
            { param($r) $r.repository_head_sha = 'invalid' }
            { param($r) $r.requested_persona = 'unknown' }
            { param($r) $r.epic_reference = '' }
            { param($r) $r.kickoff_path = 'docs/features/epics/other/epic-kickoff.md' }
            { param($r) $r.consumed = $true }
            { param($r) $r.consumed_by = 'prior-agent' }
            { param($r) $r.created_at = 'invalid' }
            { param($r) $r.expires_at = $script:Now.AddMinutes(-1).ToString('o') }
        )
        foreach ($mutate in $cases) {
            $receipt = $base | ConvertTo-Json | ConvertFrom-Json
            & $mutate $receipt
            Test-RootEpicReceipt `
                -Receipt $receipt -Payload $payload -RepositoryRoot $script:RepoRoot `
                -CurrentHeadSha $script:HeadSha -Now $script:Now |
                Should -BeFalse
        }
    }

    It 'creates complete generic and routed attestations without filesystem writes' {
        $genericPayload = [pscustomobject]@{
            session_id = 'session'; turn_id = 'turn'; agent_id = 'agent-generic'
            agent_type = 'default'; model = 'gpt-5.6-terra'; transcript_path = ''
        }
        $generic = Get-CodexSubagentAttestation `
            -Payload $genericPayload -RootReceipt $null -Checkpoints @() `
            -RepositoryRoot $script:RepoRoot -CurrentHeadSha $script:HeadSha -Now $script:Now
        $generic.routing_valid | Should -BeTrue
        $generic.provenance_valid | Should -BeTrue
        $generic.surface | Should -Be 'epic'
        $generic.actual_reasoning_effort | Should -BeNullOrEmpty

        $routedPayload = [pscustomobject]@{
            session_id = 'session'; turn_id = 'turn'; agent_id = 'agent-routed'
            agent_type = 'atomic-executor-c3'; model = 'gpt-5.6-terra'
            transcript_path = 'routed.jsonl'
        }
        $routed = Get-CodexSubagentAttestation `
            -Payload $routedPayload -RootReceipt $null -Checkpoints @() `
            -RepositoryRoot $script:RepoRoot -CurrentHeadSha $script:HeadSha -Now $script:Now
        $routed.routing_valid | Should -BeFalse
        $routed.expected_model | Should -BeNullOrEmpty
        { Get-CodexSubagentAttestation `
                -Payload ([pscustomobject]@{}) -RootReceipt $null -Checkpoints @() `
                -RepositoryRoot $script:RepoRoot -CurrentHeadSha $script:HeadSha `
                -Now $script:Now } | Should -Throw '*requires agent_id, agent_type, and model*'
    }

    It 'serializes an attestation through the null-device persistence boundary' {
        Mock Get-CodexAuthorityStateRoot { $script:RepoRoot }
        Mock Get-CodexAuthorityAttestationPath { 'NUL' }
        $attestation = [ordered]@{
            session_id      = 'session'
            surface         = 'epic'
            attestation_key = 'key'
            routing_valid   = $true
        }

        Write-CodexSubagentAttestation `
            -RepositoryRoot $script:RepoRoot -Attestation $attestation |
            Should -Be 'NUL'
    }

    It 'executes malformed and incomplete native record-hook transport without writing state' {
        $malformed = Invoke-TestRecordHook -PayloadRaw '{'
        $malformed.ExitCode | Should -Be 2
        $malformed.Stderr | Should -Match 'malformed JSON'

        $incomplete = Invoke-TestRecordHook -PayloadRaw (
            '{"session_id":"session","turn_id":"turn","agent_type":"default","model":"gpt-5.6-terra"}'
        )
        $incomplete.ExitCode | Should -Be 2
        $incomplete.Stderr | Should -Match 'requires agent_id'
        $incomplete.Stdout | Should -BeNullOrEmpty
    }
}
