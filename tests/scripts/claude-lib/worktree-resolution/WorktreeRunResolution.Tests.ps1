#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Epic and parallel run-target resolution tests (issue #690).

.DESCRIPTION
    Covers Resolve-WorktreeEpicTarget (zero, one, and several matches, the branch
    tie-break reproducing the observed 2026-09-29T13-45 / 2026-09-29T14-15-epic-770 pair,
    slug agreement and disagreement, and every non-matching checkpoint shape) and
    Resolve-WorktreeParallelTarget.

    The topology is modelled by two mocks registered with -ModuleName
    'WorktreeRunResolution': Get-WorktreeItemLiveRoot (unfiltered and -Branch forms) and
    Get-WorktreeRunCheckpointText returning in-memory JSON keyed on the requested path.
    Synthetic roots use the /synthetic-worktrees/<name> form. No test creates or writes a
    file, reads a wall clock, starts a process, or touches the network. Both expected
    reason codes come only from the worktree-resolution accessors.
#>

BeforeAll {
    $script:LibRoot = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/worktree-resolution").Path
    Import-Module (Join-Path $script:LibRoot 'WorktreeRunResolution.psm1')
    Import-Module (Join-Path $script:LibRoot 'WorktreeResolution.psm1')

    $script:NoTargetCode = Get-WorktreeResolutionNoTargetReasonCode
    $script:AmbiguityCode = Get-WorktreeResolutionAmbiguityReasonCode
    $script:Session = '/synthetic-worktrees/session'
    $script:Branch = 'epic/repro-integration'

    # Return epic checkpoint JSON recording a route_id, integration branch, and slug.
    function New-EpicJson {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory JSON factory in a test file; it changes no system state.')]
        param([string] $Branch = 'epic/repro-integration', [string] $Slug = 'repro', [string] $RouteId = 'epic')
        return ('{{"route_id":"{0}","integration_branch":"{1}","epic_feature_folder":"{2}"}}' -f $RouteId, $Branch, $Slug)
    }

    # Return parallel checkpoint JSON recording a route_id and slug.
    function New-ParallelJson {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory JSON factory in a test file; it changes no system state.')]
        param([string] $Slug = 'wave-a', [string] $RouteId = 'parallel')
        return ('{{"route_id":"{0}","parallel_slug":"{1}"}}' -f $RouteId, $Slug)
    }

    # Register the module-scoped seam mocks. Epic and Parallel map a root to the text of
    # that root's epic or parallel checkpoint; an absent key models no checkpoint.
    function Set-RunTopology {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param(
            [string[]] $Live = @(),
            [string[]] $BranchRoot = @(),
            [hashtable] $Epic = @{},
            [hashtable] $Parallel = @{}
        )
        $liveSet = $Live
        $branchSet = $BranchRoot
        $textMap = @{}
        foreach ($root in $Epic.Keys) { $textMap["$root/artifacts/orchestration/epic-orchestrator-state.json"] = $Epic[$root] }
        foreach ($root in $Parallel.Keys) { $textMap["$root/artifacts/orchestration/parallel-orchestrator-state.json"] = $Parallel[$root] }
        Mock -CommandName Get-WorktreeItemLiveRoot -ModuleName WorktreeRunResolution -MockWith {
            param([string] $Branch)
            if (-not [string]::IsNullOrWhiteSpace($Branch)) { return , [string[]] $branchSet }
            return , [string[]] $liveSet
        }.GetNewClosure()
        Mock -CommandName Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution -MockWith {
            param([string] $Path)
            if ($textMap.ContainsKey($Path)) { return $textMap[$Path] }
            return $null
        }.GetNewClosure()
    }
}

Describe 'Resolve-WorktreeEpicTarget' {
    It 'E1 resolves NoTarget for a blank branch without enumerating live roots' {
        # Arrange
        Set-RunTopology -Live @('/synthetic-worktrees/w-epic') -Epic @{ '/synthetic-worktrees/w-epic' = (New-EpicJson) }

        # Act
        $target = Resolve-WorktreeEpicTarget -IntegrationBranch '' -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'NoTarget'
        $target.ReasonCode | Should -Be $script:NoTargetCode
        Should -Invoke Get-WorktreeItemLiveRoot -ModuleName WorktreeRunResolution -Times 0 -Exactly
    }

    It 'E2 resolves NoTarget when no live root records the branch' {
        # Arrange
        Set-RunTopology -Live @('/synthetic-worktrees/w-other') -Epic @{ '/synthetic-worktrees/w-other' = (New-EpicJson -Branch 'epic/other-integration') }

        # Act
        $target = Resolve-WorktreeEpicTarget -IntegrationBranch $script:Branch -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'NoTarget'
        $target.ReasonCode | Should -Be $script:NoTargetCode
    }

    It 'E3 resolves OtherWorktree for one match in another worktree' {
        # Arrange
        Set-RunTopology -Live @($script:Session, '/synthetic-worktrees/w-epic') -Epic @{ '/synthetic-worktrees/w-epic' = (New-EpicJson) }

        # Act
        $target = Resolve-WorktreeEpicTarget -IntegrationBranch $script:Branch -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'OtherWorktree'
        $target.WorktreeRoot | Should -Be '/synthetic-worktrees/w-epic'
    }

    It 'E4 resolves SessionRoot for one match at the session root' {
        # Arrange
        Set-RunTopology -Live @($script:Session) -Epic @{ $script:Session = (New-EpicJson) }

        # Act
        $target = Resolve-WorktreeEpicTarget -IntegrationBranch $script:Branch -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'SessionRoot'
        $target.WorktreeRoot | Should -Be $script:Session
    }

    It 'E5 resolves Ambiguous when the slug disagrees with the match' {
        # Arrange
        Set-RunTopology -Live @('/synthetic-worktrees/w-epic') -Epic @{ '/synthetic-worktrees/w-epic' = (New-EpicJson -Slug 'other') }

        # Act
        $target = Resolve-WorktreeEpicTarget -IntegrationBranch $script:Branch -EpicSlug 'repro' -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'Ambiguous'
        $target.ReasonCode | Should -Be $script:AmbiguityCode
    }

    It 'E6 resolves when the slug agrees with the match' {
        # Arrange
        Set-RunTopology -Live @('/synthetic-worktrees/w-epic') -Epic @{ '/synthetic-worktrees/w-epic' = (New-EpicJson) }

        # Act
        $target = Resolve-WorktreeEpicTarget -IntegrationBranch $script:Branch -EpicSlug 'repro' -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'OtherWorktree'
        $target.WorktreeRoot | Should -Be '/synthetic-worktrees/w-epic'
    }

    It 'E7 breaks the observed tie in favour of the worktree that has the branch checked out' {
        # Arrange: the session root 2026-09-29T13-45 holds a stale matching copy.
        $session = '/synthetic-worktrees/2026-09-29T13-45'
        $owner = '/synthetic-worktrees/2026-09-29T14-15-epic-770'
        Set-RunTopology -Live @($session, $owner) -BranchRoot @($owner) -Epic @{ $session = (New-EpicJson); $owner = (New-EpicJson) }

        # Act
        $target = Resolve-WorktreeEpicTarget -IntegrationBranch $script:Branch -SessionRoot $session

        # Assert
        $target.Status | Should -Be 'OtherWorktree'
        $target.WorktreeRoot | Should -Be $owner
    }

    It 'E8 resolves Ambiguous with the handoff remedy when no match has the branch checked out' {
        # Arrange
        Set-RunTopology -Live @('/synthetic-worktrees/a', '/synthetic-worktrees/b') -BranchRoot @('/synthetic-worktrees/c') `
            -Epic @{ '/synthetic-worktrees/a' = (New-EpicJson); '/synthetic-worktrees/b' = (New-EpicJson) }

        # Act
        $target = Resolve-WorktreeEpicTarget -IntegrationBranch $script:Branch -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'Ambiguous'
        $target.Detail | Should -Match ([regex]::Escape('artifacts/orchestration/handoff/'))
    }

    It 'E9 resolves Ambiguous with the handoff remedy when both matches have the branch checked out' {
        # Arrange
        Set-RunTopology -Live @('/synthetic-worktrees/a', '/synthetic-worktrees/b') -BranchRoot @('/synthetic-worktrees/a', '/synthetic-worktrees/b') `
            -Epic @{ '/synthetic-worktrees/a' = (New-EpicJson); '/synthetic-worktrees/b' = (New-EpicJson) }

        # Act
        $target = Resolve-WorktreeEpicTarget -IntegrationBranch $script:Branch -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'Ambiguous'
        $target.Detail | Should -Match ([regex]::Escape('artifacts/orchestration/handoff/'))
    }

    It 'E10-E15 never counts a live root whose epic checkpoint is <Label>' -ForEach @(
        @{ Label = 'absent'; Text = $null }
        @{ Label = 'empty'; Text = '' }
        @{ Label = 'unparseable'; Text = '{' }
        @{ Label = 'a JSON array'; Text = '[]' }
        @{ Label = 'a parallel route'; Text = '{"route_id":"parallel","integration_branch":"epic/repro-integration"}' }
        @{ Label = 'another integration branch'; Text = '{"route_id":"epic","integration_branch":"epic/other-integration"}' }
    ) {
        # Arrange
        Set-RunTopology -Live @('/synthetic-worktrees/w-epic') -Epic @{ '/synthetic-worktrees/w-epic' = $Text }

        # Act
        $target = Resolve-WorktreeEpicTarget -IntegrationBranch $script:Branch -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'NoTarget'
    }
}

Describe 'Resolve-WorktreeParallelTarget' {
    It 'R1 resolves NoTarget for a blank slug without enumerating live roots' {
        # Arrange
        Set-RunTopology -Live @('/synthetic-worktrees/w-par') -Parallel @{ '/synthetic-worktrees/w-par' = (New-ParallelJson) }

        # Act
        $target = Resolve-WorktreeParallelTarget -ParallelSlug '' -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'NoTarget'
        Should -Invoke Get-WorktreeItemLiveRoot -ModuleName WorktreeRunResolution -Times 0 -Exactly
    }

    It 'R2 resolves one matching live root' {
        # Arrange
        Set-RunTopology -Live @('/synthetic-worktrees/w-par') -Parallel @{ '/synthetic-worktrees/w-par' = (New-ParallelJson) }

        # Act
        $target = Resolve-WorktreeParallelTarget -ParallelSlug 'wave-a' -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'OtherWorktree'
        $target.WorktreeRoot | Should -Be '/synthetic-worktrees/w-par'
    }

    It 'R3 resolves Ambiguous for two matching live roots' {
        # Arrange
        Set-RunTopology -Live @('/synthetic-worktrees/a', '/synthetic-worktrees/b') `
            -Parallel @{ '/synthetic-worktrees/a' = (New-ParallelJson); '/synthetic-worktrees/b' = (New-ParallelJson) }

        # Act
        $target = Resolve-WorktreeParallelTarget -ParallelSlug 'wave-a' -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'Ambiguous'
        $target.ReasonCode | Should -Be $script:AmbiguityCode
        $target.Detail | Should -Match ([regex]::Escape('artifacts/orchestration/handoff/'))
    }

    It 'R4-R7 never counts a live root whose parallel checkpoint is <Label>' -ForEach @(
        @{ Label = 'unparseable'; Text = '{' }
        @{ Label = 'a JSON array'; Text = '[{"route_id":"parallel","parallel_slug":"wave-a"}]' }
        @{ Label = 'an epic route'; Text = '{"route_id":"epic","parallel_slug":"wave-a"}' }
        @{ Label = 'another slug'; Text = '{"route_id":"parallel","parallel_slug":"wave-b"}' }
    ) {
        # Arrange
        Set-RunTopology -Live @('/synthetic-worktrees/w-par') -Parallel @{ '/synthetic-worktrees/w-par' = $Text }

        # Act
        $target = Resolve-WorktreeParallelTarget -ParallelSlug 'wave-a' -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'NoTarget'
    }
}
