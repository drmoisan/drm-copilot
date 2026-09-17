#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'enforce-prd-feature-before-planner.ps1 target resolution' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-prd-feature-before-planner.ps1").Path
        $script:Helpers = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1").Path
        . $script:UnderTest
        . $script:Helpers
    }

    Context 'cross-file mock resolution smoke' {
        It 'observes a test-scope mock across the dot-source boundary' {
            Mock -CommandName Get-PrdFeatureCheckpointFolder -MockWith { 'docs/features/active/2026-01-01-checkpoint-only-000' }

            $prompt = 'Plan the work in docs/features/active/2026-09-13-smoke-1 now.'
            Find-PrdFeatureFolderFromPrompt -Prompt $prompt |
                Should -Be 'docs/features/active/2026-09-13-smoke-1'

            Should -Invoke -CommandName Get-PrdFeatureCheckpointFolder -Times 0 -Exactly
        }
    }
}
