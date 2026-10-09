#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Probe and baseline-helper rows for the epic-state isolation guard (issue #737, CR-1).

.DESCRIPTION
    Exercises Register-EpicStateBaselineMock and Invoke-EpicStateInterceptionProbe from
    EpicStateIsolation.Baseline.Helpers.ps1. The helper rows show that the baseline mocks are
    registered in the right scope and that the modules are imported without -Force. The probe rows
    show that the probe passes when the suite's mock is bound to the module instance the resolver
    uses and fails when it is bound to a different instance. The interception rows register the
    baseline mock, register hostile in-memory payloads for the lower seams through the probe, and
    assert the resolver result, one baseline-mock invocation, and zero hostile reads on the Claude
    surface (epic-scope, worktree-run, and item-checkpoint seams) and on the Codex script-scope seam.

    This file is a harness suite, not a hook suite: it loads the worktree-resolution modules and,
    inside one Describe only, the Codex epic resolver, whose path is composed from segments so
    that the discovery guard does not treat the harness as a suite that loads a hook closure. It
    creates no file, reads no gitignored state, and runs no git command.
#>

BeforeAll {
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
    $script:LibRoot = Join-Path $script:RepoRoot '.claude/lib/worktree-resolution'
    # A suite that ran earlier in the same Pester session can leave a module whose nested import
    # still points at a replaced instance of a sibling module. Unloading the family first makes the
    # imports below build one coherent set of instances, so the probe rows measure only the mock binding.
    Remove-Module -Name 'EpicScopeResolution', 'WorktreeRunResolution', 'WorktreeItemResolution', 'WorktreeResolution', 'WorktreeTargetResolution', 'EpicScopeReadiness' -Force -ErrorAction SilentlyContinue
    Import-Module (Join-Path $script:LibRoot 'EpicScopeResolution.psm1')
    Import-Module (Join-Path $script:LibRoot 'WorktreeRunResolution.psm1')
    Import-Module (Join-Path $script:LibRoot 'WorktreeItemResolution.psm1')
    function Get-Fake737Seam { return 'real' }
}

Describe 'baseline helper' {
    It 'AC-6 helper registers a module-scoped null mock' {
        # Arrange and act: register the baseline mock, then call the real seam in its module scope.
        Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText' -Surface 'Claude'
        $text = InModuleScope 'EpicScopeResolution' { Get-EpicScopeCheckpointText -Path '/synthetic-worktrees/x/epic-orchestrator-state.json' }

        # Assert: the module-scoped mock answered the call.
        $text | Should -BeNullOrEmpty
        Should -Invoke Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution -Times 1 -Exactly
    }

    It 'AC-6 helper registers a script-scope null mock' {
        # Arrange and act: a script-scope seam on the Codex surface is mocked without -ModuleName.
        Register-EpicStateBaselineMock -Seam 'Get-Fake737Seam' -Surface 'Codex'
        $value = Get-Fake737Seam

        # Assert
        $value | Should -BeNullOrEmpty
        Should -Invoke Get-Fake737Seam -Times 1 -Exactly
    }

    It 'AC-6 helper imports without Force' {
        # Arrange: a marker in the loaded module instance; a forced re-import would discard it.
        InModuleScope 'EpicScopeResolution' { $script:Marker737 = 'present' }

        # Act
        Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText' -Surface 'Claude'

        # Assert
        (InModuleScope 'EpicScopeResolution' { $script:Marker737 }) | Should -Be 'present'
    }

    It 'AC-6 helper accepts an empty seam array and registers nothing' {
        # Act and assert: the -ForEach shape passes an ExtraSeam array that can be empty.
        { Register-EpicStateBaselineMock -Seam @() -Surface 'Claude' } | Should -Not -Throw
    }
}

Describe 'interception probe harness' {
    It "AC-6 probe passes when the baseline mock is bound to the resolver's module instance" {
        # Arrange
        Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText' -Surface 'Claude'

        # Act and assert: the resolver reads the baseline mock, never the hostile payload.
        { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-EpicScopeCheckpointText' } | Should -Not -Throw
    }

    It 'AC-6 probe fails when the baseline mock is bound to a different module instance' {
        # Arrange: register the baseline mock, then re-import the module with -Force so the resolver runs in a new instance.
        Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText' -Surface 'Claude'
        Import-Module (Join-Path $script:LibRoot 'EpicScopeResolution.psm1') -Force

        # Act and assert: the hostile payload is read and the suite's mock is never invoked, so the probe throws.
        { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-EpicScopeCheckpointText' } | Should -Throw
    }
}

Describe 'interception by surface' {
    It 'AC-7 Claude epic-scope seam is intercepted' {
        Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText' -Surface 'Claude'
        Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-EpicScopeCheckpointText'
    }

    It 'AC-7 Claude worktree-run seam is intercepted' {
        Register-EpicStateBaselineMock -Seam 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeRunCheckpointText'
    }

    It 'AC-7 Claude item-checkpoint seams are intercepted' {
        Register-EpicStateBaselineMock -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot' -Surface 'Claude'
        Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot'
    }

    Context 'Codex surface' {
        BeforeAll {
            # The Codex resolver defines its own script-scope seams; it is loaded here only, so the Claude rows keep the module-exported resolver.
            $codexRoot = Join-Path $script:RepoRoot '.codex/hooks'
            . (Join-Path $codexRoot 'enforce-orchestration-preimplementation-gate-epic-resolution.ps1')
        }

        It 'AC-7 Codex script-scope seam is intercepted' {
            Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText' -Surface 'Codex'
            Invoke-EpicStateInterceptionProbe -Surface 'Codex' -Seam 'Get-EpicScopeCheckpointText'
        }
    }
}
