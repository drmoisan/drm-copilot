#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
    $script:HookRoot = Join-Path $script:RepoRoot '.codex/hooks'
    . (Join-Path $script:HookRoot 'record-subagent-routing-attestation.ps1')
    $script:Now = [datetimeoffset]'2026-07-10T15:00:00Z'
    $script:HeadSha = 'a' * 40
}

Describe 'Subagent attestation command with deterministic input boundaries' {
    BeforeEach {
        $script:PayloadRaw = '{"session_id":"one","turn_id":"turn","agent_id":"child","agent_type":"epic-planner","model":"gpt-6-astra"}'
        $script:Head = @{ sha = $script:HeadSha; exit_code = 0 }
        $script:Attestation = [ordered]@{ provenance_valid = $true; routing_valid = $true }
        $script:Inputs = $null
        $script:CheckpointText = @{}
        Mock Test-Path { $false }
        Mock Get-CodexAuthorityReceiptPath { 'memory-authority/root.json' }
        Mock Get-CodexSubagentAttestationFromAuthority {
            param($Payload, $ReceiptPath, $Checkpoints, $RepositoryRoot, $CurrentHeadSha, $Now)
            $script:Inputs = @{
                Payload = $Payload; ReceiptPath = $ReceiptPath; Checkpoints = $Checkpoints
                RepositoryRoot = $RepositoryRoot; CurrentHeadSha = $CurrentHeadSha; Now = $Now
            }
            $script:Attestation
        }
        Mock Write-CodexSubagentAttestation { 'memory-authority/attestation.json' }
        $script:CommandParameters = @{
            RepositoryRoot = $script:RepoRoot
            ReadInput      = { $script:PayloadRaw }
            ReadCheckpoint = { param($Path) $script:CheckpointText[[IO.Path]::GetFileName($Path)] }
            ReadHead       = { param($Root) $script:ReadHeadRoot = $Root; $script:Head }
            GetNow         = { $script:Now }
        }
    }

    It 'returns success without stdout or stderr and forwards exact authority inputs' {
        $result = Invoke-CodexSubagentAttestationCommand @script:CommandParameters
        $result.exit_code | Should -Be 0
        $result.stdout | Should -BeNullOrEmpty
        $result.stderr | Should -BeNullOrEmpty
        $script:Inputs.RepositoryRoot | Should -Be $script:RepoRoot
        $script:ReadHeadRoot | Should -Be $script:RepoRoot
        $script:Inputs.ReceiptPath | Should -Be 'memory-authority/root.json'
        $script:Inputs.CurrentHeadSha | Should -Be $script:HeadSha
        $script:Inputs.Now | Should -Be $script:Now
        $script:Inputs.Payload.agent_id | Should -Be 'child'
        @($script:Inputs.Checkpoints).Count | Should -Be 0
        Should -Invoke Write-CodexSubagentAttestation -Times 1 -Exactly -ParameterFilter {
            $RepositoryRoot -eq $script:RepoRoot -and $Attestation.provenance_valid
        }
    }

    It 'keeps valid checkpoints and ignores optional malformed checkpoint content' {
        Mock Test-Path { $true }
        $script:CheckpointText = @{
            'epic-planner-state.json'      = '{"marker":"planner"}'
            'epic-orchestrator-state.json' = '{'
            'orchestrator-state.json'      = '{"marker":"orchestrator"}'
        }
        $result = Invoke-CodexSubagentAttestationCommand @script:CommandParameters
        $result.exit_code | Should -Be 0
        @($script:Inputs.Checkpoints).Count | Should -Be 2
        $script:Inputs.Checkpoints.marker | Should -Be @('planner', 'orchestrator')
    }

    It 'retains the canonical repository derivation when its root argument is omitted' {
        $script:CommandParameters.Remove('RepositoryRoot')
        $result = Invoke-CodexSubagentAttestationCommand @script:CommandParameters
        $result.exit_code | Should -Be 0
        $hookDirectory = Split-Path (Get-Command Invoke-CodexSubagentAttestationCommand).ScriptBlock.File -Parent
        $script:Inputs.RepositoryRoot | Should -Be (Split-Path (Split-Path $hookDirectory -Parent) -Parent)
    }

    It 'returns the exact provenance rejection JSON with exit zero' {
        $script:Attestation.provenance_valid = $false
        $script:Attestation.routing_valid = $false
        $result = Invoke-CodexSubagentAttestationCommand @script:CommandParameters
        $expected = [ordered]@{
            systemMessage      = 'EPIC_INVOCATION_ORIGIN_BLOCKED: epic-planner requires a fresh root-session epic invocation receipt.'
            hookSpecificOutput = [ordered]@{
                hookEventName     = 'SubagentStart'
                additionalContext = 'Do not mutate state. Report EPIC_INVOCATION_ORIGIN_BLOCKED and stop.'
            }
        } | ConvertTo-Json -Compress -Depth 5
        $result.exit_code | Should -Be 0
        $result.stdout | Should -Be $expected
        $result.stderr | Should -BeNullOrEmpty
    }

    It 'returns the exact routing rejection JSON with exit zero' {
        $script:Attestation.routing_valid = $false
        $result = Invoke-CodexSubagentAttestationCommand @script:CommandParameters
        $expected = [ordered]@{
            systemMessage      = 'MODEL_ROUTING_ATTESTATION_BLOCKED: actual model/profile does not match the persisted routing receipt. Attestation: memory-authority/attestation.json'
            hookSpecificOutput = [ordered]@{
                hookEventName     = 'SubagentStart'
                additionalContext = 'Do not mutate state until the parent corrects the deployment profile and routing receipt.'
            }
        } | ConvertTo-Json -Compress -Depth 5
        $result.exit_code | Should -Be 0
        $result.stdout | Should -Be $expected
        $result.stderr | Should -BeNullOrEmpty
    }

    It 'rejects invalid HEAD <Case> with the existing stderr and exit two' -ForEach @(
        @{ Case = 'format'; Sha = 'invalid'; Code = 0 }
        @{ Case = 'exit status'; Sha = ('a' * 40); Code = 1 }
    ) {
        $script:Head = @{ sha = $Sha; exit_code = $Code }
        $result = Invoke-CodexSubagentAttestationCommand @script:CommandParameters
        $result.exit_code | Should -Be 2
        $result.stderr | Should -Be 'EPIC_INVOCATION_ORIGIN_BLOCKED: repository HEAD could not be resolved.'
        $result.stdout | Should -BeNullOrEmpty
        Should -Invoke Write-CodexSubagentAttestation -Times 0 -Exactly
    }

    It 'rejects required malformed input with stderr and exit two' {
        $script:PayloadRaw = '{'
        $result = Invoke-CodexSubagentAttestationCommand @script:CommandParameters
        $result.exit_code | Should -Be 2
        $result.stderr | Should -Match 'MODEL_ROUTING_ATTESTATION_BLOCKED: SubagentStart input is malformed JSON:'
        $result.stdout | Should -BeNullOrEmpty
        Should -Invoke Get-CodexSubagentAttestationFromAuthority -Times 0 -Exactly
    }

    It 'propagates persistence failure through stderr and exit two' {
        Mock Write-CodexSubagentAttestation { throw 'exclusive persistence rejected' }
        $result = Invoke-CodexSubagentAttestationCommand @script:CommandParameters
        $result.exit_code | Should -Be 2
        $result.stderr | Should -Be 'exclusive persistence rejected'
        $result.stdout | Should -BeNullOrEmpty
    }
}
