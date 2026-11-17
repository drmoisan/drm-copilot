#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Development-docs root resolution in the enforce-parallel-drift-gate.ps1 allowance path (issue #1035).

.DESCRIPTION
    Drives Invoke-ParallelDriftGateDecision with a parallel-mode feature-review payload whose checkpoint,
    read through the mocked Get-ParallelDriftGateCheckpointContent seam, records one unresolved drift event
    for the cited item. The parallel target root, the item worktree_path, and the session location are
    three distinct synthetic absolute paths, so a case fails when the resolver receives the wrong root.
    The fail-closed cases run the real Resolve-DevelopmentDocsRoot with injected in-memory readers; no
    case reads the routing file or creates a file.
#>

Describe 'enforce-parallel-drift-gate.ps1 development-docs root (issue #1035)' {
    BeforeAll {
        $script:HookPath = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-parallel-drift-gate.ps1").Path
        . $script:HookPath
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        Register-EpicStateBaselineMock -Seam 'Get-ParallelDriftGateCheckpointContent' -Surface 'Codex'

        $script:TargetRoot = if ($IsWindows) { 'C:/synthetic-worktrees/parallel-target' } else { '/synthetic-worktrees/parallel-target' }
        $script:ItemWorktree = if ($IsWindows) { 'C:/synthetic-worktrees/item-alpha' } else { '/synthetic-worktrees/item-alpha' }
        $script:SessionLocation = if ($IsWindows) { 'C:/synthetic-worktrees/session' } else { '/synthetic-worktrees/session' }
        $script:Target = '2026-08-07-parallel-alpha-501'
        $script:Kickoff = 'Parallel mode: true. parallel_slug: demo.'
        $script:RealResolver = Get-Command -Name Resolve-DevelopmentDocsRoot -CommandType Function

        Mock Resolve-ParallelDriftGateTarget { [pscustomobject]@{ Status = 'Resolved'; WorktreeRoot = $script:TargetRoot; ReasonCode = $null; Detail = 'synthetic parallel target (issue #1035)' } }
        Mock Get-ParallelDriftGateCheckpointContent {
            '{"items":[' +
            '{"issue_num":501,"feature_folder":"' + $script:Target + '","state":"in_flight","worktree_path":"' + $script:ItemWorktree + '",' +
            '"blast_radius":{"paths":["scripts/declared/"],"modules":[],"shared_surfaces":[],"contracts":[],"source":"declared","computed_at":"2026-01-01T00-00"}}' +
            '],"drift_events":[{"item_key":501,"declared":["scripts/declared/"],"observed":["scripts/other/escape.py"],' +
            '"escaped_paths":["scripts/other/escape.py"],"at":"2026-01-02T00-00","action":"raised_blocking_finding"}]}'
        }

        function Invoke-DriftDecision {
            $payload = @{ tool_name = 'Agent'; tool_input = @{ subagent_type = 'feature-review'; prompt = "$script:Kickoff Review docs/features/active/$script:Target now" } } | ConvertTo-Json -Compress -Depth 5
            return (Invoke-ParallelDriftGateDecision -ToolInputRaw $payload).hookSpecificOutput
        }
    }

    BeforeEach {
        Mock Get-Location { [pscustomobject]@{ Path = $script:SessionLocation } }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    It 'DDR-DRIFT-FAILS-CLOSED-ON-MALFORMED-ROUTING-JSON' {
        # Arrange: the real resolver reads malformed routing JSON through an injected reader.
        Mock Resolve-DevelopmentDocsRoot {
            & $script:RealResolver -WorkspaceRoot $WorkspaceRoot -ReadText { param([string] $Path) $null = $Path; '{"development_docs_root":' } -TestDirectory { param([string] $Path) $null = $Path; $false }
        }
        Mock Test-ParallelDriftFindingPresent { $true }

        # Act
        $decision = Invoke-DriftDecision

        # Assert
        $decision.permissionDecision | Should -Be 'deny'
        $decision.permissionDecisionReason | Should -BeLike 'PARALLEL_DRIFT_GATE_BLOCKED: *'
        $decision.permissionDecisionReason | Should -BeLike '*config/orchestration-routing.json*'
        $decision.permissionDecisionReason | Should -BeLike '*development_docs_root*'
        Should -Invoke Test-ParallelDriftFindingPresent -Times 0 -Exactly
    }

    It 'DDR-DRIFT-FAILS-CLOSED-ON-OUT-OF-SET-VALUE' {
        # Arrange: the configured value is outside the known roots.
        Mock Resolve-DevelopmentDocsRoot {
            & $script:RealResolver -WorkspaceRoot $WorkspaceRoot -ReadText { param([string] $Path) $null = $Path; '{"development_docs_root":"docs"}' } -TestDirectory { param([string] $Path) $null = $Path; $false }
        }
        Mock Test-ParallelDriftFindingPresent { $true }

        # Act
        $decision = Invoke-DriftDecision

        # Assert
        $decision.permissionDecision | Should -Be 'deny'
        $decision.permissionDecisionReason | Should -BeLike 'PARALLEL_DRIFT_GATE_BLOCKED: *'
        $decision.permissionDecisionReason | Should -BeLike '*config/orchestration-routing.json*'
        $decision.permissionDecisionReason | Should -BeLike '*development_docs_root*'
        $decision.permissionDecisionReason | Should -BeLike '*"docs"*'
        Should -Invoke Test-ParallelDriftFindingPresent -Times 0 -Exactly
    }

    It 'DDR-DRIFT-PASSES-ITEM-WORKTREE-ROOT' {
        # Arrange
        Mock Resolve-DevelopmentDocsRoot { [pscustomobject]@{ Succeeded = $true; Root = 'docs/features'; Reason = $null } }
        Mock Test-ParallelDriftFindingPresent { $true }

        # Act
        $decision = Invoke-DriftDecision

        # Assert: the item worktree_path is the only root the resolver receives.
        $decision.permissionDecision | Should -Be 'allow'
        Should -Invoke Resolve-DevelopmentDocsRoot -Times 1 -Exactly -ParameterFilter { $WorkspaceRoot -ceq $script:ItemWorktree }
        Should -Invoke Resolve-DevelopmentDocsRoot -Times 0 -Exactly -ParameterFilter { $WorkspaceRoot -ceq $script:TargetRoot }
        Should -Invoke Resolve-DevelopmentDocsRoot -Times 0 -Exactly -ParameterFilter { $WorkspaceRoot -ceq $script:SessionLocation }
    }

    It 'DDR-DRIFT-PASSES-RESOLVED-ACTIVE-AREA' {
        # Arrange: the item worktree resolves the .dev root.
        Mock Resolve-DevelopmentDocsRoot { [pscustomobject]@{ Succeeded = $true; Root = '.dev'; Reason = $null } }
        Mock Test-ParallelDriftFindingPresent { $true }

        # Act
        $decision = Invoke-DriftDecision

        # Assert
        $decision.permissionDecision | Should -Be 'allow'
        Should -Invoke Test-ParallelDriftFindingPresent -Times 1 -Exactly -ParameterFilter {
            $ActiveFeatureRoot -ceq '.dev/active' -and $WorktreePath -ceq $script:ItemWorktree
        }
    }
}
