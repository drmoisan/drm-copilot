#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Rows for the resolution sibling validate-orchestrator-output-resolution.ps1 (issue #787).

.DESCRIPTION
    Covers the -CheckpointPath leaf cross-check (canonical, separator variants, a
    non-canonical leaf, rooted and parent-escaping values), the argument values of every
    existing SubagentStop registration, the unsupported-type result, the runbook path
    helpers and their read seam, discovery of distinct run identities, and the guarded
    resolver import.

    Registration files are read as text and fixture-free rows run in memory. No row
    creates, writes, or deletes a file, uses a temporary path or the Pester temporary drive, reads a clock,
    starts a process, or touches the network. Synthetic roots use the
    /synthetic-worktrees/<name> form.
#>

BeforeAll {
    . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/validate-orchestrator-output.ps1").Path
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/orchestrator-state/OrchestratorState.psm1')).Path -ErrorAction Stop
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')).Path -ErrorAction Stop
    Mock Get-CheckpointFileContent { $null }
    Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
    Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
    Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    $libRoot = (Resolve-Path "$PSScriptRoot/../../../.claude/lib").Path
    Import-Module (Join-Path $libRoot 'worktree-resolution/WorktreeTargetResolution.psm1')
    Import-Module (Join-Path $libRoot 'worktree-resolution/WorktreeResolution.psm1')
    # The completion module re-imports OrchestratorState.psm1 internally, so the state
    # module is imported last to keep Get-OrchestratorStateCheckpoint mockable here.
    Import-Module (Join-Path $libRoot 'orchestrator-state/OrchestratorStateCompletion.psm1') -Force
    Import-Module (Join-Path $libRoot 'orchestrator-state/OrchestratorState.psm1') -Force
    Mock Get-OrchestratorStateCheckpoint -ModuleName OrchestratorState { $null }
    . (Join-Path $PSScriptRoot 'WorktreeResolutionFixture.Helpers.ps1')

    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
    $script:Session = (Get-Location).Path.Replace([string][char]92, '/')
    $script:EpicCanonical = '/synthetic-worktrees/w-reg/artifacts/orchestration/epic-orchestrator-state.json'

    function ConvertTo-ResolutionPayload {
        param([string] $Output)
        return (@{ output = $Output } | ConvertTo-Json -Compress)
    }

    # Model the live worktrees and their epic checkpoint texts in both mock scopes.
    function Set-ResolutionRunTopology {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param([string[]] $Live = @(), [hashtable] $Epic = @{})
        $liveSet = $Live
        $textMap = @{}
        foreach ($root in $Epic.Keys) { $textMap["$root/artifacts/orchestration/epic-orchestrator-state.json"] = $Epic[$root] }
        $liveMock = { return , [string[]] $liveSet }.GetNewClosure()
        $textMock = {
            param([string] $Path)
            if ($textMap.ContainsKey($Path)) { return $textMap[$Path] }
            return $null
        }.GetNewClosure()
        Mock -CommandName Get-WorktreeItemLiveRoot -ModuleName WorktreeRunResolution -MockWith $liveMock
        Mock -CommandName Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution -MockWith $textMock
        Mock -CommandName Get-WorktreeItemLiveRoot -MockWith $liveMock
        Mock -CommandName Get-WorktreeRunCheckpointText -MockWith $textMock
    }
}

Describe 'validate-orchestrator-output resolution sibling' {

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    BeforeEach {
        Mock Get-CheckpointFileContent { @{ Exists = $false; Content = $null } }
    }

    It 'S2-1 accepts the canonical epic leaf and returns the canonical path' {
        # Arrange / Act
        $leaf = Test-OrchestratorOutputCheckpointLeaf -CheckpointPath 'artifacts/orchestration/epic-orchestrator-state.json' -Kind 'epic' -WorktreeRoot '/synthetic-worktrees/w-reg'

        # Assert
        $leaf.Ok | Should -BeTrue -Because $leaf.Detail
        $leaf.CanonicalPath | Should -BeExactly $script:EpicCanonical
    }

    It 'S2-2 accepts a dot-prefixed backslash spelling of the epic leaf' {
        # Arrange / Act
        $leaf = Test-OrchestratorOutputCheckpointLeaf -CheckpointPath '.\artifacts\orchestration\epic-orchestrator-state.json' -Kind 'epic' -WorktreeRoot '/synthetic-worktrees/w-reg'

        # Assert
        $leaf.Ok | Should -BeTrue -Because $leaf.Detail
        $leaf.CanonicalPath | Should -BeExactly $script:EpicCanonical
    }

    It 'S2-3 rejects the item leaf for the epic kind and names the canonical epic path' {
        # Arrange / Act
        $leaf = Test-OrchestratorOutputCheckpointLeaf -CheckpointPath 'artifacts/orchestration/orchestrator-state.json' -Kind 'epic' -WorktreeRoot '/synthetic-worktrees/w-reg'

        # Assert
        $leaf.Ok | Should -BeFalse
        $leaf.Detail.Contains($script:EpicCanonical) | Should -BeTrue -Because $leaf.Detail
    }

    It 'S2-4 rejects a rooted -CheckpointPath before any resolver call or read' {
        # Arrange
        Set-ResolutionRunTopology -Live @($script:Session)

        # Act
        $result = Invoke-OrchestratorOutputValidation -RawPayload (ConvertTo-ResolutionPayload -Output 'Final summary.') `
            -CheckpointPath '/abs/artifacts/orchestration/epic-orchestrator-state.json' -ArtifactType 'epic-orchestrator-state' -SessionRoot $script:Session

        # Assert
        $result.Message.Contains('Rejected (CHECKPOINT_PATH_MISMATCH)') | Should -BeTrue -Because $result.Message
        Should -Invoke Get-WorktreeItemLiveRoot -Times 0 -Exactly
        Should -Invoke Get-WorktreeItemLiveRoot -ModuleName WorktreeRunResolution -Times 0 -Exactly
        Should -Invoke Get-CheckpointFileContent -Times 0 -Exactly
    }

    It 'S2-5 rejects a parent-escaping -CheckpointPath before any resolver call or read' {
        # Arrange
        Set-ResolutionRunTopology -Live @($script:Session)

        # Act
        $result = Invoke-OrchestratorOutputValidation -RawPayload (ConvertTo-ResolutionPayload -Output 'Final summary.') `
            -CheckpointPath 'artifacts/../artifacts/orchestration/epic-orchestrator-state.json' -ArtifactType 'epic-orchestrator-state' -SessionRoot $script:Session

        # Assert
        $result.Message.Contains('Rejected (CHECKPOINT_PATH_MISMATCH)') | Should -BeTrue -Because $result.Message
        Should -Invoke Get-WorktreeItemLiveRoot -Times 0 -Exactly
        Should -Invoke Get-WorktreeItemLiveRoot -ModuleName WorktreeRunResolution -Times 0 -Exactly
        Should -Invoke Get-CheckpointFileContent -Times 0 -Exactly
    }

    It 'S2-6 passes the cross-check for every existing SubagentStop registration unchanged' {
        # Arrange: read the four registration files as text (read-only).
        $files = @('.claude/settings.json', '.claude/agents/orchestrator.md', '.claude/agents/epic-orchestrator.md', '.claude/agents/parallel-orchestrator.md')
        $registrations = foreach ($file in $files) {
            $text = [System.IO.File]::ReadAllText((Join-Path $script:RepoRoot $file))
            foreach ($match in [regex]::Matches($text, '-File \.claude/hooks/validate-orchestrator-output\.ps1(?<args>[^"\r\n]*)')) { $match.Groups['args'].Value }
        }
        $failures = [System.Collections.Generic.List[string]]::new()

        # Act: derive each registration's arguments, applying the hook's defaults, and cross-check them.
        foreach ($arguments in $registrations) {
            $checkpointPath = if ($arguments -match '-CheckpointPath\s+(?<value>\S+)') { $Matches['value'] } else { 'artifacts/orchestration/orchestrator-state.json' }
            $artifactType = if ($arguments -match '-ArtifactType\s+(?<value>\S+)') { $Matches['value'] } else { 'orchestrator-state' }
            $leaf = Test-OrchestratorOutputCheckpointLeaf -CheckpointPath $checkpointPath -Kind $script:OrchestratorOutputRunKind[$artifactType] -WorktreeRoot '/synthetic-worktrees/w-reg'
            if (-not $leaf.Ok) { $failures.Add("$artifactType ${checkpointPath}: $($leaf.Detail)") }
        }

        # Assert
        @($registrations).Count | Should -Be 6
        $failures | Should -BeNullOrEmpty -Because ($failures -join '; ')
    }

    It 'S2-7 reports an unsupported artifact type as NoTarget with the shared reason code' {
        # Arrange / Act
        $result = Resolve-OrchestratorOutputCheckpointPath -ArtifactType 'not-a-type' -CheckpointPath 'artifacts/orchestration/orchestrator-state.json' -AgentOutput '' -SessionRoot $script:Session

        # Assert
        $result.Resolved | Should -BeFalse
        $result.Status | Should -BeExactly 'NoTarget'
        $result.ReasonCode | Should -BeExactly (Get-WorktreeResolutionNoTargetReasonCode)
        $result.Detail.Contains("unsupported artifact type 'not-a-type'") | Should -BeTrue -Because $result.Detail
    }

    It 'S2-8 joins a dot-prefixed runbook path beneath the resolved root' {
        # Arrange / Act
        $path = Resolve-OrchestratorOutputRunbookPath -WorktreeRoot '/synthetic-worktrees/w-epic' -RunbookPath './docs/runbooks/x.md'

        # Assert
        $path | Should -BeExactly '/synthetic-worktrees/w-epic/docs/runbooks/x.md'
    }

    It 'S2-9 returns a rooted runbook path unchanged' {
        # Arrange / Act
        $path = Resolve-OrchestratorOutputRunbookPath -WorktreeRoot '/synthetic-worktrees/w-epic' -RunbookPath '/srv/runbooks/x.md'

        # Assert
        $path | Should -BeExactly '/srv/runbooks/x.md'
    }

    It 'S2-10 collects only distinct epic-route branch values in discovery order' {
        # Arrange: a case-variant route, unparseable text, a JSON array, a blank branch, and two
        # branches that differ only in case.
        $roots = @('/synthetic-worktrees/r-upper', '/synthetic-worktrees/r-broken', '/synthetic-worktrees/r-array', '/synthetic-worktrees/r-blank', '/synthetic-worktrees/r-lower-a', '/synthetic-worktrees/r-upper-a')
        Set-ResolutionRunTopology -Live $roots -Epic @{
            '/synthetic-worktrees/r-upper'   = '{"route_id":"Epic","integration_branch":"epic/x"}'
            '/synthetic-worktrees/r-broken'  = '{ broken'
            '/synthetic-worktrees/r-array'   = '[{"route_id":"epic","integration_branch":"epic/y"}]'
            '/synthetic-worktrees/r-blank'   = '{"route_id":"epic","integration_branch":""}'
            '/synthetic-worktrees/r-lower-a' = '{"route_id":"epic","integration_branch":"epic/a"}'
            '/synthetic-worktrees/r-upper-a' = '{"route_id":"epic","integration_branch":"epic/A"}'
        }

        # Act
        $values = Find-OrchestratorOutputRunSignalValue -Kind 'epic' -SessionRoot $script:Session

        # Assert
        ($values -join ',') | Should -BeExactly 'epic/a,epic/A'
    }

    It 'S2-11 reports the runbook seam result from the filesystem' {
        # Arrange
        $missing = Join-Path $PSScriptRoot 'no-such-runbook-for-787.md'

        # Act / Assert
        Test-OrchestratorOutputRunbookFile -Path $missing | Should -BeFalse
        Test-OrchestratorOutputRunbookFile -Path $PSCommandPath | Should -BeTrue
    }

    It 'S2-12 blocks naming WorktreeRunResolution.psm1 when the resolver import failed, before any read' {
        # Arrange: reload the hook with the WorktreeRunResolution.psm1 import throwing, so its
        # own import guard records the failure; every other import is a no-op.
        Mock Import-Module { }
        Mock Import-Module { throw 'simulated import failure (issue #787)' } -ParameterFilter { $Name -like '*WorktreeRunResolution.psm1' }
        . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/validate-orchestrator-output.ps1").Path
        Mock Get-CheckpointFileContent { @{ Exists = $false; Content = $null } }
        try {
            # Act
            $result = Invoke-OrchestratorOutputValidation -RawPayload (ConvertTo-ResolutionPayload -Output 'Final summary.') `
                -CheckpointPath 'artifacts/orchestration/epic-orchestrator-state.json' -ArtifactType 'epic-orchestrator-state' -SessionRoot $script:Session
        }
        finally {
            $script:OrchestratorOutputResolverImportFailure = $null
        }

        # Assert
        $result.Message.Contains('ORCHESTRATOR_CHECKPOINT_UNRESOLVED:') | Should -BeTrue -Because $result.Message
        $result.Message.Contains('RESOLVER_IMPORT_FAILED') | Should -BeTrue -Because $result.Message
        $result.Message.Contains('WorktreeRunResolution.psm1') | Should -BeTrue -Because $result.Message
        Should -Invoke Get-CheckpointFileContent -Times 0 -Exactly
    }
}
