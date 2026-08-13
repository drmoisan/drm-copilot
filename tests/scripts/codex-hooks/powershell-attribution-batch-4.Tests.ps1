#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'PowerShell attribution batch 4' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:CoverageSettingsPath = Join-Path $script:RepoRoot `
            'scripts/powershell/PoshQC/settings/pester.runsettings.psd1'
        $script:RuntimePaths = @(
            '.codex/hooks/codex-authority-store.ps1'
            '.codex/hooks/enforce-codex-model-routing.ps1'
            '.codex/hooks/record-subagent-routing-attestation.ps1'
        )
        foreach ($runtimePath in $script:RuntimePaths) {
            . (Join-Path $script:RepoRoot $runtimePath)
        }
    }

    It 'registers <RuntimePath> for attributable coverage' -ForEach @(
        @{ RuntimePath = '.codex/hooks/codex-authority-store.ps1' }
        @{ RuntimePath = '.codex/hooks/enforce-codex-model-routing.ps1' }
        @{ RuntimePath = '.codex/hooks/record-subagent-routing-attestation.ps1' }
    ) {
        $settings = Get-Content -LiteralPath $script:CoverageSettingsPath -Raw

        $settings | Should -Match ([regex]::Escape("'$RuntimePath'"))
    }

    It 'normalizes authority path identities and rejects empty values' {
        ConvertTo-CodexAuthorityPathSegment -Value 'session/root:1' |
            Should -Be 'session_root_1'
        { ConvertTo-CodexAuthorityPathSegment -Value ' ' } | Should -Throw '*identity is empty*'
    }

    It 'derives the same transcript-bound key on model and start hooks' {
        $modelKey = Get-CodexModelGateAttestationKey -TranscriptPath 'C:/transcripts/one.jsonl'
        $startKey = Get-SubagentAttestationKey `
            -TranscriptPath 'C:/transcripts/one.jsonl' `
            -AgentId 'agent-1'

        $modelKey | Should -Match '^[0-9a-f]{64}$'
        $startKey | Should -BeExactly $modelKey
    }

    It 'classifies forced and generated model-gated personas' {
        Test-CodexModelGateAgentType -AgentType 'parallel-planner' | Should -BeTrue
        Test-CodexModelGateAgentType -AgentType 'python-typed-engineer-c3' | Should -BeTrue
        Test-CodexModelGateAgentType -AgentType 'default' | Should -BeFalse
    }
}
