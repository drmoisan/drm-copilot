#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Development-docs root cases for the Codex preimplementation gate (issue #1035).
.DESCRIPTION
    The Codex gate's feature-document, readiness, bookkeeping-tree, and
    epic-manifest matchers accept the active, epics, parallel, and potential areas
    of both known development-docs roots (docs/features and .dev), independent of
    the configured value. Each case calls the pure predicate with an in-memory
    value; no file is created and no process is started. Paths use forward
    slashes so the suite runs on the Linux hook-suite job.
#>

BeforeAll {
    . (Join-Path $PSScriptRoot '../../../.codex/hooks/enforce-orchestration-preimplementation-gate.ps1')
    . (Join-Path $PSScriptRoot '../claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1')
    Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
    Register-EpicStateBaselineMock -Seam 'Get-CheckpointContent', 'Get-EpicCheckpointContent', 'Get-ParallelCheckpointContent', 'Get-WorktreeResolutionGitFileText' -Surface 'Codex'
    Mock Get-EpicScopeCheckpointText { $null }
}

Describe 'Codex preimplementation gate development-docs root union' {
    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Codex' -Seam 'Get-EpicScopeCheckpointText' }

    It 'treats <Path> as a feature document path' -ForEach @(
        @{ Path = 'docs/features/active/2026-09-29-sample-509/evidence/other/x.json' }
        @{ Path = '.dev/active/2026-09-29-sample-509/evidence/other/x.json' }
        @{ Path = '/synthetic-checkout/.dev/active/2026-09-29-sample-509/spec.json' }
    ) {
        Test-FeatureDocumentationOrEvidencePath -NormalizedPath $Path | Should -BeTrue
    }

    It 'does not treat <Path> as a feature document path' -ForEach @(
        @{ Path = '.dev/research/x.json' }
        @{ Path = '.dev/activex/2026-09-29-sample-509/x.json' }
        @{ Path = '.devx/active/2026-09-29-sample-509/x.json' }
    ) {
        Test-FeatureDocumentationOrEvidencePath -NormalizedPath $Path | Should -BeFalse
    }

    It 'reports a ready checkpoint whose feature-folder is under <Root>' -ForEach @(
        @{ Root = 'docs/features/active' }
        @{ Root = '.dev/active' }
    ) {
        $payload = [pscustomobject]@{ 'issue-num' = '509'; 'feature-folder' = "$Root/2026-09-29-sample-509"; route_id = 'large'; lifecycle_ready = $true }
        Test-OrchestrationReady -Payload $payload | Should -BeTrue
    }

    It 'reports a checkpoint whose feature-folder is under .dev/research as not ready' {
        $payload = [pscustomobject]@{ 'issue-num' = '509'; 'feature-folder' = '.dev/research/2026-09-29-sample-509'; route_id = 'large'; lifecycle_ready = $true }
        Test-OrchestrationReady -Payload $payload | Should -BeFalse
    }

    It 'exempts the bookkeeping operand <Operand>' -ForEach @(
        @{ Operand = 'docs/features/epics/sample-epic/epic-status.md' }
        @{ Operand = '.dev/epics/sample-epic/epic-status.md' }
        @{ Operand = '.dev/parallel/sample-run/parallel.md' }
        @{ Operand = '.dev/active/2026-09-29-sample-509/plan.md' }
        @{ Operand = '.dev/potential/2026-09-29-sample.md' }
        @{ Operand = 'artifacts/orchestration/orchestrator-state.json' }
    ) {
        Test-ExemptOrchestrationOperand -Operand $Operand | Should -BeTrue
    }

    It 'does not exempt the operand <Operand>' -ForEach @(
        @{ Operand = '.dev/templates/feature/spec.md' }
        @{ Operand = '.dev/engineering/x.md' }
        @{ Operand = '.dev/active/../../scripts/x.ps1' }
    ) {
        Test-ExemptOrchestrationOperand -Operand $Operand | Should -BeFalse
    }

    It 'passes the mode epic_manifest_path conjunct for a manifest under <Root>' -ForEach @(
        @{ Root = 'docs/features/epics' }
        @{ Root = '.dev/epics' }
    ) {
        $checkpoint = [pscustomobject]@{ route_id = 'epic'; epic_feature_folder = 'sample-epic'; epic_manifest_path = "$Root/sample-epic/epic.md"; integration_branch = '' }
        Get-EpicOrchestrationReadinessFailure -Checkpoint $checkpoint | Should -Be 'integration_branch'
    }

    It 'passes the command-leg epic_manifest_path conjunct for a manifest under <Root>' -ForEach @(
        @{ Root = 'docs/features/epics' }
        @{ Root = '.dev/epics' }
    ) {
        $checkpoint = [pscustomobject]@{ route_id = 'epic'; epic_feature_folder = 'sample-epic'; epic_manifest_path = "$Root/sample-epic/epic.md"; integration_branch = '' }
        Get-EpicCommandLegReadinessFailure -Checkpoint $checkpoint -MergeInProgress $true | Should -Be 'integration_branch'
    }

    It 'fails both epic_manifest_path conjuncts for a manifest under .dev/active' {
        $checkpoint = [pscustomobject]@{ route_id = 'epic'; epic_feature_folder = 'sample-epic'; epic_manifest_path = '.dev/active/sample-epic/epic.md'; integration_branch = '' }
        Get-EpicOrchestrationReadinessFailure -Checkpoint $checkpoint | Should -Be 'epic_manifest_path'
        Get-EpicCommandLegReadinessFailure -Checkpoint $checkpoint -MergeInProgress $true | Should -Be 'epic_manifest_path'
    }
}
