#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Seams and leg entry of enforce-orchestration-preimplementation-gate-release.ps1 (issue #1201),
    both surface copies.

.DESCRIPTION
    Each surface's preimplementation gate is dot-sourced first and then that root's release
    sibling. The config seam and the container seam run against mocked Test-Path and Get-Content
    with synthetic paths (spec AC-3); the leg entry runs with injected readers or mocked seams for
    every decline path (AC-5), every seam failure path, the catch path (AC-20), and the reader call
    counts of the performance constraints. No row reads a real file, starts a process, or reads the
    environment.
#>

Describe 'enforce-orchestration-preimplementation-gate-release.ps1 (<Surface>)' -ForEach @(
    @{ Surface = 'Claude'; GateRelativePath = '.claude/hooks/enforce-orchestration-preimplementation-gate.ps1'; ReleaseRelativePath = '.claude/hooks/enforce-orchestration-preimplementation-gate-release.ps1'; Seam = @('Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText', 'Get-EpicScopeCheckpointText'); ExtraSeam = @('Get-CheckpointContent', 'Get-EpicCheckpointContent', 'Get-ParallelCheckpointContent') }
    @{ Surface = 'Codex'; GateRelativePath = '.codex/hooks/enforce-orchestration-preimplementation-gate.ps1'; ReleaseRelativePath = '.codex/hooks/enforce-orchestration-preimplementation-gate-release.ps1'; Seam = @('Get-EpicScopeCheckpointText'); ExtraSeam = @('Get-CheckpointContent', 'Get-EpicCheckpointContent', 'Get-ParallelCheckpointContent', 'Get-WorktreeResolutionGitFileText') }
) {
    BeforeAll {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
        . (Join-Path $repoRoot $GateRelativePath)
        . (Join-Path $repoRoot $ReleaseRelativePath)
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam $Seam -Surface $Surface
        Register-EpicStateBaselineMock -Seam $ExtraSeam -Surface $Surface
        $script:ReleaseRoot = '/synthetic-worktrees/release'
        $script:ReleaseCheckpointPath = '/synthetic-worktrees/release/artifacts/orchestration/orchestrator-state.json'
        $script:ReleaseValidConfig = '{"schema_version": 1, "allowances": [{"id": "release-version-bump", "branch_patterns": ["release/v*"], "allowed_paths": ["package.json", "CHANGELOG.md"]}]}'
        $script:ReleaseSuffixPrefix = ' Release allowance not applied: '
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface $Surface -Seam $Seam }

    Context 'config seam Get-OrchestrationGateReleaseAllowanceConfigText (spec AC-3)' {
        It 'returns $null without a read when no item exists' {
            # Arrange
            Mock Test-Path { $false }
            Mock Get-Content { 'unexpected' }

            # Act
            $text = Get-OrchestrationGateReleaseAllowanceConfigText -WorktreeRoot $script:ReleaseRoot

            # Assert
            $text | Should -BeNullOrEmpty
            Should -Invoke Test-Path -Times 1 -Exactly -ParameterFilter { ($LiteralPath -replace '\\', '/') -ceq '/synthetic-worktrees/release/.claude/release-commit-allowance.json' }
            Should -Invoke Get-Content -Times 0 -Exactly
        }

        It 'returns the raw text of a file' {
            # Arrange
            Mock Test-Path { $true }
            Mock Get-Content { '{"schema_version": 1}' }

            # Act
            $text = Get-OrchestrationGateReleaseAllowanceConfigText -WorktreeRoot $script:ReleaseRoot

            # Assert
            $text | Should -BeExactly '{"schema_version": 1}'
            Should -Invoke Get-Content -Times 1 -Exactly -ParameterFilter { $Raw -and ($LiteralPath -replace '\\', '/') -ceq '/synthetic-worktrees/release/.claude/release-commit-allowance.json' }
        }

        It 'throws when the item is not a file' {
            # Arrange
            Mock Test-Path { $true }
            Mock Test-Path -ParameterFilter { $PathType -eq 'Leaf' } { $false }
            Mock Get-Content { 'unexpected' }

            # Act and Assert
            { Get-OrchestrationGateReleaseAllowanceConfigText -WorktreeRoot $script:ReleaseRoot } | Should -Throw '*not a file*'
            Should -Invoke Get-Content -Times 0 -Exactly
        }

        It 'throws when the read fails' {
            # Arrange
            Mock Test-Path { $true }
            Mock Get-Content { throw 'synthetic read failure' }

            # Act and Assert
            { Get-OrchestrationGateReleaseAllowanceConfigText -WorktreeRoot $script:ReleaseRoot } | Should -Throw '*synthetic read failure*'
        }
    }

    Context 'container seam Test-OrchestrationGateReleaseAllowancePathIsContainer (spec AC-3)' {
        It 'returns <Expected> when Test-Path -PathType Container reports <Expected>' -ForEach @(
            @{ Expected = $true }
            @{ Expected = $false }
        ) {
            # Arrange
            $answer = $Expected
            Mock Test-Path { $answer }.GetNewClosure()

            # Act
            $result = Test-OrchestrationGateReleaseAllowancePathIsContainer -WorktreeRoot $script:ReleaseRoot -RelativePath 'package.json'

            # Assert
            $result | Should -Be $Expected
            Should -Invoke Test-Path -Times 1 -Exactly -ParameterFilter { $PathType -eq 'Container' -and ($LiteralPath -replace '\\', '/') -ceq '/synthetic-worktrees/release/package.json' }
        }
    }

    Context 'leg entry Get-OrchestrationReleaseAllowanceResult' {
        BeforeEach {
            Mock Get-OrchestrationGateReleaseAllowanceConfigText { $script:ReleaseValidConfig }
            Mock Test-OrchestrationGateReleaseAllowancePathIsContainer { $false }
            Mock Get-EpicScopeWorktreeHeadBranch { 'release/v1.2.3' }
            Mock Get-OrchestrationGateStagedIndex { [pscustomobject]@{ ExitCode = 0; Output = "package.json`0" } }
        }

        It 'declines <Label> with no suffix and no config read (spec AC-5, AC-6)' -ForEach @(
            @{ Label = 'a blank command'; Command = '   '; CheckpointPath = '/synthetic-worktrees/release/artifacts/orchestration/orchestrator-state.json' }
            @{ Label = 'apply_patch text'; Command = "*** Begin Patch`n*** Update File: package.json`n@@`n-a`n+b`n*** End Patch"; CheckpointPath = '/synthetic-worktrees/release/artifacts/orchestration/orchestrator-state.json' }
            @{ Label = 'an injected checkpoint (empty checkpoint path)'; Command = 'git add package.json'; CheckpointPath = '' }
            @{ Label = 'a checkpoint path without the item suffix'; Command = 'git add package.json'; CheckpointPath = '/synthetic-worktrees/release/state.json' }
            @{ Label = 'a line without git add or git commit'; Command = 'pytest'; CheckpointPath = '/synthetic-worktrees/release/artifacts/orchestration/orchestrator-state.json' }
        ) {
            # Act
            $result = Get-OrchestrationReleaseAllowanceResult -Command $Command -CheckpointPath $CheckpointPath

            # Assert
            $result.Allowed | Should -BeFalse
            $result.DenySuffix | Should -BeExactly ''
            Should -Invoke Get-OrchestrationGateReleaseAllowanceConfigText -Times 0 -Exactly
        }

        It 'declines an absent allowance file with no branch, staged-index, or container read' {
            # Arrange
            Mock Get-OrchestrationGateReleaseAllowanceConfigText { $null }

            # Act
            $result = Get-OrchestrationReleaseAllowanceResult -Command 'git commit -m x' -CheckpointPath $script:ReleaseCheckpointPath

            # Assert
            $result.Allowed | Should -BeFalse
            $result.DenySuffix | Should -BeExactly ''
            Should -Invoke Get-OrchestrationGateReleaseAllowanceConfigText -Times 1 -Exactly -ParameterFilter { $WorktreeRoot -ceq '/synthetic-worktrees/release' }
            Should -Invoke Test-OrchestrationGateReleaseAllowancePathIsContainer -Times 0 -Exactly
            Should -Invoke Get-EpicScopeWorktreeHeadBranch -Times 0 -Exactly
            Should -Invoke Get-OrchestrationGateStagedIndex -Times 0 -Exactly
        }

        It 'reports a throwing config reader as an unreadable file' {
            # Act
            $result = Get-OrchestrationReleaseAllowanceResult -Command 'git add package.json' -CheckpointPath $script:ReleaseCheckpointPath -ConfigReader { throw 'synthetic read failure' }

            # Assert
            $result.Allowed | Should -BeFalse
            $result.DenySuffix | Should -BeExactly ($script:ReleaseSuffixPrefix + 'RELEASE_ALLOWANCE_CONFIG_INVALID: the file could not be read')
        }

        It 'reports a throwing container probe as an unchecked entry' {
            # Act
            $result = Get-OrchestrationReleaseAllowanceResult -Command 'git add package.json' -CheckpointPath $script:ReleaseCheckpointPath -ContainerProbe { throw 'synthetic probe failure' }

            # Assert
            $result.DenySuffix | Should -BeExactly ($script:ReleaseSuffixPrefix + "RELEASE_ALLOWANCE_CONFIG_INVALID: allowed_paths entry 'package.json' could not be checked")
        }

        It 'reports a directory entry' {
            # Act
            $result = Get-OrchestrationReleaseAllowanceResult -Command 'git add package.json' -CheckpointPath $script:ReleaseCheckpointPath -ContainerProbe { $args[1] -ceq 'CHANGELOG.md' }

            # Assert
            $result.DenySuffix | Should -BeExactly ($script:ReleaseSuffixPrefix + "RELEASE_ALLOWANCE_CONFIG_INVALID: allowed_paths entry 'CHANGELOG.md' is a directory")
        }

        It 'reports an invalid document' {
            # Act
            $result = Get-OrchestrationReleaseAllowanceResult -Command 'git add package.json' -CheckpointPath $script:ReleaseCheckpointPath -ConfigReader { '{"schema_version": 1}' }

            # Assert
            $result.DenySuffix | Should -BeExactly ($script:ReleaseSuffixPrefix + "RELEASE_ALLOWANCE_CONFIG_INVALID: missing top-level key 'allowances'")
        }

        It 'declines with PREIMPL_RELEASE_LEG_ERROR when the <Reader> throws (spec AC-20)' -ForEach @(
            @{ Reader = 'branch reader'; Command = 'git add package.json'; Parameter = 'BranchReader' }
            @{ Reader = 'staged-index reader'; Command = 'git commit -m x'; Parameter = 'StagedIndexReader' }
        ) {
            # Arrange
            $arguments = @{ Command = $Command; CheckpointPath = $script:ReleaseCheckpointPath; $Parameter = { throw 'synthetic unexpected failure' } }

            # Act
            $output = @(Get-OrchestrationReleaseAllowanceResult @arguments -Debug 5>&1)

            # Assert
            $result = @($output | Where-Object { $_ -isnot [System.Management.Automation.DebugRecord] })
            $debug = @($output | Where-Object { $_ -is [System.Management.Automation.DebugRecord] })
            $result.Count | Should -Be 1
            $result[0].Allowed | Should -BeFalse
            $result[0].DenySuffix | Should -BeExactly ''
            @($debug | Where-Object { $_.Message -like 'PREIMPL_RELEASE_LEG_ERROR:*synthetic unexpected failure*' }).Count | Should -Be 1
        }

        It 'reads each container once, the branch once, and no staged index for a git add (performance constraints)' {
            # Act
            $result = Get-OrchestrationReleaseAllowanceResult -Command 'git add package.json' -CheckpointPath $script:ReleaseCheckpointPath

            # Assert
            $result.Allowed | Should -BeTrue
            $result.DenySuffix | Should -BeExactly ''
            Should -Invoke Test-OrchestrationGateReleaseAllowancePathIsContainer -Times 2 -Exactly
            Should -Invoke Get-EpicScopeWorktreeHeadBranch -Times 1 -Exactly -ParameterFilter { $WorktreeRoot -ceq '/synthetic-worktrees/release' }
            Should -Invoke Get-OrchestrationGateStagedIndex -Times 0 -Exactly
        }

        It 'reads the staged index once for a git commit' {
            # Act
            $result = Get-OrchestrationReleaseAllowanceResult -Command 'git commit -m x' -CheckpointPath $script:ReleaseCheckpointPath

            # Assert
            $result.Allowed | Should -BeTrue
            Should -Invoke Get-OrchestrationGateStagedIndex -Times 1 -Exactly -ParameterFilter { $WorktreeRoot -ceq '/synthetic-worktrees/release' }
        }

        It 'reports the decision code and detail for a denied line' {
            # Act
            $result = Get-OrchestrationReleaseAllowanceResult -Command 'git add other.txt' -CheckpointPath $script:ReleaseCheckpointPath

            # Assert
            $result.Allowed | Should -BeFalse
            $result.DenySuffix | Should -BeExactly ($script:ReleaseSuffixPrefix + "RELEASE_ALLOWANCE_PATH_NOT_ALLOWED: operand 'other.txt' is not an allowed path")
        }
    }
}
