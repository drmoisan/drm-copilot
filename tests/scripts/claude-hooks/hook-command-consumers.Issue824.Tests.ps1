#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Consumer behavior of the issue #824 structural matcher (T-CONS, rows CN-01 to CN-10).

.DESCRIPTION
    The shared matcher is consumed by validate-bash, the orchestration pre-implementation
    gate, the epic merge gate, and the pr-author epic base-branch check. These rows pin that
    each consumer still classifies a direct and a wrapper-led invocation, and does not
    classify a token-bounded mention, after the raw-containment helper was removed.

    Each hook is dot-sourced only in the BeforeAll of the Describe that holds its rows, and
    every mock is declared inside that Describe. Rows CN-01 to CN-09 run against the Claude
    and the Codex copy; CN-10 is Claude-only.

    Determinism: pure string decisions; checkpoint content arrives only through mocked read
    seams. No temporary file, no child process, and no live executable.
#>

BeforeDiscovery {
    $script:Runtimes = @(
        @{ Runtime = 'claude'; HookRoot = '.claude/hooks' }
        @{ Runtime = 'codex'; HookRoot = '.codex/hooks' }
    )
    $script:BlockedRows = @(
        @{ Id = 'CN-01'; Command = 'git push --force origin main' }
        @{ Id = 'CN-02'; Command = 'bash -c "git push --force origin main"' }
        @{ Id = 'CN-03'; Command = 'git reset --hard HEAD' }
        @{ Id = 'CN-04'; Command = 'pwsh -Command ''git reset --hard HEAD''' }
    )
    $script:StagingRows = @(
        @{ Id = 'CN-06'; Command = 'git add src/feature.ps1' }
        @{ Id = 'CN-07'; Command = 'bash -c "git add src/feature.ps1"' }
    )
    $script:MergeRows = @(
        @{ Command = 'gh pr merge --merge 688' }
        @{ Command = 'bash -c "gh pr merge --merge 688"' }
    )
}

Describe 'validate-bash consumer rows, <Runtime> copy (issue #824)' -ForEach $script:Runtimes {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot "$HookRoot/validate-bash.ps1")
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText', 'Get-OrchestratorStateCheckpoint', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        if (Get-Command Get-PrAuthorCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-PrAuthorCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-PrAuthorReceiptContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-PrAuthorReceiptContent' -Surface 'Codex' }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    It '<Id> blocks <Command>' -Tag 'Issue824' -ForEach $script:BlockedRows {
        Get-BashBlockReason -Command $Command | Should -Not -BeNullOrEmpty
    }

    It 'CN-05 does not block a script-file invocation whose name mentions push' -Tag 'Issue824' {
        Get-BashBlockReason -Command 'pwsh -NoProfile -f ./scripts/legit-push.ps1' | Should -BeNullOrEmpty
    }
}

Describe 'pre-implementation gate consumer rows, <Runtime> copy (issue #824)' -ForEach $script:Runtimes {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot "$HookRoot/enforce-orchestration-preimplementation-gate.ps1")
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText', 'Get-OrchestratorStateCheckpoint', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        if (Get-Command Get-PrAuthorCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-PrAuthorCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-PrAuthorReceiptContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-PrAuthorReceiptContent' -Surface 'Codex' }
        if ($Runtime -eq 'claude') {
            Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
        } else {
            Mock Get-EpicScopeCheckpointText { $null }
        }
    }

    It '<Id> classifies <Command> as an implementation command' -Tag 'Issue824' -ForEach $script:StagingRows {
        Test-ImplementationCommand -Command $Command | Should -BeTrue
    }

    It 'CN-08 does not classify a quoted token-bounded mention' -Tag 'Issue824' {
        Test-ImplementationCommand -Command 'pwsh -NoProfile -Command ''Write-Output "digit address"''' | Should -BeFalse
    }
}

Describe 'epic merge gate consumer rows, <Runtime> copy (issue #824)' -ForEach $script:Runtimes {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot "$HookRoot/enforce-epic-merge-gate.ps1")
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText', 'Get-OrchestratorStateCheckpoint', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        if (Get-Command Get-PrAuthorCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-PrAuthorCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-PrAuthorReceiptContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-PrAuthorReceiptContent' -Surface 'Codex' }
        $script:CurrentRuntime = $Runtime
    }

    It 'CN-09 reads pull request 688 from <Command>' -Tag 'Issue824' -ForEach $script:MergeRows {
        $number = if ($script:CurrentRuntime -eq 'claude') {
            Get-EpicMergeGateCommandPrNumber -CommandText $Command
        } else {
            Get-CodexMergeCommandPrNumber -Command $Command
        }
        $number | Should -Be 688
    }
}

Describe 'pr-author epic base-branch consumer row, claude copy (issue #824)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot '.claude/hooks/enforce-pr-author-skill.ps1')
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText', 'Get-OrchestratorStateCheckpoint', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        if (Get-Command Get-PrAuthorCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-PrAuthorCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-PrAuthorReceiptContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-PrAuthorReceiptContent' -Surface 'Codex' }
        Mock -CommandName Get-PrAuthorCheckpointContent -MockWith {
            '{"epic_mode":true,"epic_context":{"integration_branch":"epic/foo-integration"}}'
        }
    }

    It 'CN-10 reports EPIC_BASE_BRANCH_MISMATCH for <_>' -Tag 'Issue824' -ForEach @(
        'gh pr create --base epic/x --body-file artifacts/pr_body_545.md'
        'bash -c "gh pr create --base epic/x --body-file artifacts/pr_body_545.md"'
    ) {
        $result = Test-EpicBaseBranchOverride -CommandText $_ -CheckpointPath (Join-Path $PSScriptRoot 'no-such-checkpoint.json')
        $result | Should -Match 'EPIC_BASE_BRANCH_MISMATCH'
    }
}
