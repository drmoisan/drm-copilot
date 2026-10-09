#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Epic-state isolation guard for the gate-1, gate-3, and gate-4 hook suites (issues #709, #690).

.DESCRIPTION
    Hook suites reach Resolve-EpicScopeCheckpoint in
    .claude/lib/worktree-resolution/EpicScopeResolution.psm1 through the hooks they load, and
    that resolver now locates the epic checkpoint through WorktreeRunResolution.psm1. Unmocked,
    either module reads a gitignored run checkpoint, so leftover local state could change their
    results on a developer machine.

    The predicate lives in EpicStateIsolation.Helpers.ps1. The per-suite structural check now
    lives in enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1, which discovers the
    suites on both hook surfaces by directory enumeration. This file keeps the
    predicate-discrimination rows and the seam-sufficiency proof.

.NOTES
    This file loads no hook, creates no file, reads no gitignored state, and runs no git
    command. It reads only committed suite files located from $PSScriptRoot and builds
    every other input in memory; synthetic roots use the /synthetic-worktrees/ form.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Helpers.ps1')
}

Describe 'gate suites isolate the epic checkpoint read (structural guard)' {
    Context 'guard predicate discrimination' {
        # Each row parses an in-memory fixture, so the guard is shown to reject every
        # non-compliant shape rather than passing vacuously. Every fixture carries both
        # pairs except where the row targets one, so it fails only for its own reason.
        It 'accepts the compliant <Name> form with zero findings' -ForEach @(
            @{
                Name   = 'positional'
                Source = @'
Describe 'fixture' {
    BeforeAll {
        . $script:UnderTest
        Import-Module ./EpicScopeResolution.psm1
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
        Import-Module ./WorktreeRunResolution.psm1
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    }
}
'@
            }
            @{
                Name   = '-CommandName and -MockWith'
                Source = @'
Describe 'fixture' {
    BeforeAll {
        . $script:UnderTest
        Import-Module ./EpicScopeResolution.psm1
        Mock -CommandName Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution -MockWith { $null }
        Import-Module ./WorktreeRunResolution.psm1
        Mock -CommandName Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution -MockWith { $null }
    }
}
'@
            }
        ) {
            # Arrange
            $tokens = $null
            $errors = $null
            $ast = [System.Management.Automation.Language.Parser]::ParseInput($Source, [ref] $tokens, [ref] $errors)

            # Act
            $findings = @(Get-EpicStateIsolationFinding -Ast $ast)

            # Assert
            @($findings).Count | Should -Be 0 -Because ($findings -join '; ')
        }

        It 'rejects <Name> with a finding containing "<Expected>"' -ForEach @(
            @{
                Name     = 'a Mock that targets another command'
                Expected = 'missing from outermost BeforeAll'
                Source   = @'
Describe 'fixture' {
    BeforeAll {
        . $script:UnderTest
        Import-Module ./EpicScopeResolution.psm1
        Mock Get-EpicScopeWorktreeHeadBranch -ModuleName EpicScopeResolution { $null }
        Import-Module ./WorktreeRunResolution.psm1
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    }
}
'@
            }
            @{
                Name     = 'a Mock without -ModuleName'
                Expected = 'lacks -ModuleName'
                Source   = @'
Describe 'fixture' {
    BeforeAll {
        . $script:UnderTest
        Import-Module ./EpicScopeResolution.psm1
        Mock Get-EpicScopeCheckpointText { $null }
        Import-Module ./WorktreeRunResolution.psm1
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    }
}
'@
            }
            @{
                Name     = 'a Mock body other than $null'
                Expected = 'not exactly'
                Source   = @'
Describe 'fixture' {
    BeforeAll {
        . $script:UnderTest
        Import-Module ./EpicScopeResolution.psm1
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { '' }
        Import-Module ./WorktreeRunResolution.psm1
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    }
}
'@
            }
            @{
                Name     = 'a Mock declared only in a nested Context BeforeAll'
                Expected = 'missing from outermost BeforeAll'
                Source   = @'
Describe 'fixture' {
    BeforeAll {
        . $script:UnderTest
        Import-Module ./EpicScopeResolution.psm1
        Import-Module ./WorktreeRunResolution.psm1
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    }
    Context 'nested' {
        BeforeAll {
            Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
        }
    }
}
'@
            }
            @{
                Name     = 'an Import-Module with -Force'
                Expected = 'uses -Force'
                Source   = @'
Describe 'fixture' {
    BeforeAll {
        . $script:UnderTest
        Import-Module ./EpicScopeResolution.psm1 -Force
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
        Import-Module ./WorktreeRunResolution.psm1
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    }
}
'@
            }
            @{
                Name     = 'an import and Mock placed before the hook dot-source'
                Expected = 'order violated'
                Source   = @'
Describe 'fixture' {
    BeforeAll {
        Import-Module ./EpicScopeResolution.psm1
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
        . $script:UnderTest
        Import-Module ./WorktreeRunResolution.psm1
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    }
}
'@
            }
            @{
                Name     = 'a missing Get-WorktreeRunCheckpointText Mock'
                Expected = 'Mock of Get-WorktreeRunCheckpointText missing from outermost BeforeAll'
                Source   = @'
Describe 'fixture' {
    BeforeAll {
        . $script:UnderTest
        Import-Module ./EpicScopeResolution.psm1
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
        Import-Module ./WorktreeRunResolution.psm1
    }
}
'@
            }
            @{
                Name     = 'a Get-WorktreeRunCheckpointText Mock without -ModuleName'
                Expected = 'Mock lacks -ModuleName WorktreeRunResolution'
                Source   = @'
Describe 'fixture' {
    BeforeAll {
        . $script:UnderTest
        Import-Module ./EpicScopeResolution.psm1
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
        Import-Module ./WorktreeRunResolution.psm1
        Mock Get-WorktreeRunCheckpointText { $null }
    }
}
'@
            }
            @{
                Name     = 'a missing WorktreeRunResolution import'
                Expected = 'Import-Module of WorktreeRunResolution.psm1 missing from outermost BeforeAll'
                Source   = @'
Describe 'fixture' {
    BeforeAll {
        . $script:UnderTest
        Import-Module ./EpicScopeResolution.psm1
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    }
}
'@
            }
            @{
                Name     = 'a WorktreeRunResolution import with -Force'
                Expected = 'Import-Module of WorktreeRunResolution.psm1 uses -Force'
                Source   = @'
Describe 'fixture' {
    BeforeAll {
        . $script:UnderTest
        Import-Module ./EpicScopeResolution.psm1
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
        Import-Module ./WorktreeRunResolution.psm1 -Force
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    }
}
'@
            }
        ) {
            # Arrange
            $tokens = $null
            $errors = $null
            $ast = [System.Management.Automation.Language.Parser]::ParseInput($Source, [ref] $tokens, [ref] $errors)

            # Act
            $findings = @(Get-EpicStateIsolationFinding -Ast $ast)

            # Assert
            ($findings -join '; ') | Should -BeLike "*$Expected*"
        }

        It 'reports a listed suite path that does not exist and names the path' {
            # Arrange
            $missingPath = '/synthetic-worktrees/missing/enforce-missing.Tests.ps1'

            # Act
            $findings = @(Get-EpicStateIsolationSuiteFinding -RepoRoot $script:RepoRoot -RelativePath $missingPath)

            # Assert
            @($findings).Count | Should -Be 1
            $findings[0] | Should -BeLike '*suite file not found*'
            $findings[0] | Should -BeLike "*$missingPath*"
        }
    }
}

BeforeDiscovery {
    # One call shape per gate that reaches Resolve-EpicScopeCheckpoint.
    $script:HostileShapes = @(
        @{ Gate = 'gate 1'; Text = 'gh pr create --head epic/hostile-integration --body-file artifacts/pr_body_1.md'; MatchWorktreeHead = $false; WorktreeSelector = '' }
        @{ Gate = 'gate 3'; Text = "Run the model-routing review for this item.`nbranch: epic/hostile-integration"; MatchWorktreeHead = $false; WorktreeSelector = '' }
        @{ Gate = 'gate 4'; Text = 'git add scripts/powershell/Sample.ps1'; MatchWorktreeHead = $true; WorktreeSelector = '' }
        @{ Gate = 'gate 4 selector'; Text = 'git -C /synthetic-worktrees/selected-item add scripts/powershell/Sample.ps1'; MatchWorktreeHead = $true; WorktreeSelector = '/synthetic-worktrees/selected-item' }
    )
}

Describe 'the run-checkpoint mocks block the epic-state read (seam sufficiency)' {
    BeforeAll {
        # This file loads no hook, so there is no module instance to bind to; -Force loads a
        # fresh ESR, and the WRR import binds the instance ESR loaded.
        Import-Module (Join-Path $script:RepoRoot '.claude/lib/worktree-resolution/EpicScopeResolution.psm1') -Force
        Import-Module (Join-Path $script:RepoRoot '.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')
        $script:HostileEpicJson = '{"route_id":"epic","integration_branch":"epic/hostile-integration","epic_feature_folder":"hostile-epic","features":[]}'
        $script:SessionRoot = '/synthetic-worktrees/local-checkout'

        function Set-HostileEpicSeam {
            <#
                Mock the lower seams inside EpicScopeResolution and WorktreeRunResolution so
                that, without the run-checkpoint mocks, the resolver locates and reads a
                hostile ready epic checkpoint whose integration_branch matches every call shape.
            #>
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
            param()
            $hostileText = $script:HostileEpicJson
            Mock Find-WorktreeResolutionRoot -ModuleName EpicScopeResolution {
                if ($Path -like '/synthetic-worktrees/*') { return $Path }
                return '/synthetic-worktrees/local-checkout'
            }
            Mock Get-WorktreeResolutionGitEntryKind -ModuleName EpicScopeResolution { 'File' }
            Mock Get-WorktreeResolutionGitFileText -ModuleName EpicScopeResolution { $hostileText }.GetNewClosure()
            Mock Get-EpicScopeWorktreeHeadBranch -ModuleName EpicScopeResolution { 'epic/hostile-integration' }
            Mock Test-EpicScopeMergeInProgress -ModuleName EpicScopeResolution { $false }
            Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeRunResolution { , [string[]] @('/synthetic-worktrees/local-checkout') }
            Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $hostileText }.GetNewClosure()
        }

        function Invoke-HostileEpicResolution {
            # Resolve one call shape from the synthetic session root.
            param([Parameter(Mandatory)] [string] $Text, [bool] $MatchWorktreeHead, [string] $WorktreeSelector)
            $arguments = @{ Text = $Text; SessionRoot = $script:SessionRoot; MatchWorktreeHead = $MatchWorktreeHead }
            if (-not [string]::IsNullOrEmpty($WorktreeSelector)) { $arguments['WorktreeSelector'] = $WorktreeSelector }
            return (Resolve-EpicScopeCheckpoint @arguments)
        }
    }

    It '<Gate> control: the hostile payload is epic scope without the mocks' -ForEach $script:HostileShapes {
        # Arrange: only the hostile lower seams.
        Set-HostileEpicSeam

        # Act
        $result = Invoke-HostileEpicResolution -Text $Text -MatchWorktreeHead $MatchWorktreeHead -WorktreeSelector $WorktreeSelector

        # Assert: the payload is read and decides the call, so the treatment rows are not vacuous.
        $result.IsEpicScope | Should -BeTrue -Because "the hostile checkpoint is read for $Gate (reason: $($result.Reason))"
        Should -Invoke Get-WorktreeResolutionGitFileText -ModuleName EpicScopeResolution -Times 1 -Exactly -ParameterFilter { $Path -like '*epic-orchestrator-state.json' }
    }

    It '<Gate> treatment A: both $null mocks block the target lookup and the epic-state read' -ForEach $script:HostileShapes {
        # Arrange: the hostile lower seams plus the two mocks the guarded suites declare.
        Set-HostileEpicSeam
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }

        # Act
        $result = Invoke-HostileEpicResolution -Text $Text -MatchWorktreeHead $MatchWorktreeHead -WorktreeSelector $WorktreeSelector

        # Assert
        $result.IsEpicScope | Should -BeFalse
        $result.Reason | Should -Be 'epic-checkpoint-absent-or-unparseable'
        Should -Invoke Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution -Times 0 -Exactly
        Should -Invoke Get-EpicScopeWorktreeHeadBranch -ModuleName EpicScopeResolution -Times ([int]$MatchWorktreeHead) -Exactly
        Should -Invoke Test-EpicScopeMergeInProgress -ModuleName EpicScopeResolution -Times 0 -Exactly
    }

    It '<Gate> treatment B: the Get-EpicScopeCheckpointText mock alone blocks the epic-state read' -ForEach $script:HostileShapes {
        # Arrange: the hostile lower seams plus only the epic-scope text mock.
        Set-HostileEpicSeam
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }

        # Act
        $result = Invoke-HostileEpicResolution -Text $Text -MatchWorktreeHead $MatchWorktreeHead -WorktreeSelector $WorktreeSelector

        # Assert
        $result.IsEpicScope | Should -BeFalse
        Should -Invoke Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution -Times 1 -Exactly
        Should -Invoke Get-WorktreeResolutionGitFileText -ModuleName EpicScopeResolution -Times 0 -Exactly -ParameterFilter { $Path -like '*epic-orchestrator-state.json' }
    }
}
