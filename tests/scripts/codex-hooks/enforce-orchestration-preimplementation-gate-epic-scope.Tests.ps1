#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Codex preimplementation gate 4 epic-scope rows for the command, apply_patch, and path legs (issue #707).

.DESCRIPTION
    Drives Invoke-OrchestrationPreimplementationGateDecision of
    .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 with the mapped Codex
    tool_input JSON the decision consumes. When the effective worktree HEAD equals the
    integration_branch of the epic checkpoint, the call is epic scope and is decided by the
    epic command-leg readiness predicate; under issue #663 decision D2 a production path may
    be staged or edited only while a merge is in progress. Any other call takes the
    unchanged single-feature path.

    The four resolver seams Find-WorktreeResolutionRoot, Get-EpicScopeCheckpointText,
    Get-EpicScopeWorktreeHeadBranch, and Test-EpicScopeMergeInProgress are mocked by name.
    The ascent maps the session root to /synthetic-worktrees/epic-coordinator and returns any
    /synthetic-worktrees/ path unchanged, so no host path reaches an assertion. Every gate
    call passes -CheckpointRaw, so the single-feature fallback never reads the per-feature
    checkpoint from disk. No row creates a file or changes the working directory.

    The structural rows pin the 500-line cap, bundle parity, and the absence of any
    interpreter invocation (issue #707, decisions D15 and D16).
#>

Describe 'Codex preimplementation gate epic scope (issue #707)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot '.codex/hooks/enforce-orchestration-preimplementation-gate.ps1')
        . (Join-Path $script:RepoRoot 'tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Helpers.ps1')

        $script:BundleHookRoot = Join-Path $script:RepoRoot 'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks'
        $script:ReadyEpicJson = '{"route_id":"epic","epic_feature_folder":"sample-epic","epic_manifest_path":"docs/features/epics/sample-epic/epic.md","integration_branch":"epic/sample-epic-integration","epic_issue_num":900,"features":[{"feature_folder":"2026-09-25-child-a-901","merge_status":"merged"},{"feature_folder":"2026-09-25-child-b-902","merge_status":"worktree_removed"}],"model_routing_receipts":[{"agent":"pr-author"}]}'
        $script:NotReadySingleFeature = '{"issue-num":"707","route_id":"large","lifecycle_ready":false}'
        $script:ReadySingleFeature = '{"issue-num":"707","feature-folder":"docs/features/active/sample","route_id":"full-bug","lifecycle_ready":true}'
        $script:SingleFeatureReason = 'PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require artifacts/orchestration/orchestrator-state.json to contain issue number, feature folder, route metadata, lifecycle readiness, and checkpoint state before implementation begins.'
        $script:ProductionPath = 'scripts/powershell/Sample.ps1'
        $script:StageCommand = 'git add scripts/powershell/Sample.ps1'
        $script:ApplyPatchCommand = "*** Begin Patch`n*** Update File: scripts/powershell/Sample.ps1`n@@`n-old`n+new`n*** End Patch"
        $script:SyntheticEpicCheckpointPath = '/synthetic-worktrees/epic-coordinator/artifacts/orchestration/epic-orchestrator-state.json'

        function ConvertTo-LegToolInput {
            # Return the mapped Codex tool_input JSON for one leg carrying a production operand.
            param([Parameter(Mandatory)] [string] $Leg)
            switch ($Leg) {
                'command' { return (@{ command = $script:StageCommand } | ConvertTo-Json -Compress) }
                'apply_patch' { return (@{ command = $script:ApplyPatchCommand } | ConvertTo-Json -Compress) }
                'path' { return (@{ file_path = $script:ProductionPath } | ConvertTo-Json -Compress) }
            }
            throw "Unknown gate leg '$Leg'."
        }

        function ConvertTo-EpicJsonWithout {
            # Return the ready epic checkpoint JSON with one property removed.
            param([Parameter(Mandatory)] [string] $Property)
            $checkpoint = $script:ReadyEpicJson | ConvertFrom-Json
            $checkpoint.PSObject.Properties.Remove($Property)
            return ($checkpoint | ConvertTo-Json -Depth 6 -Compress)
        }

        function ConvertTo-EpicCheckpointVariant {
            # Return the parsed ready epic checkpoint with one property removed or replaced.
            param([Parameter(Mandatory)] [string] $Property, [AllowNull()] [object] $Value, [switch] $Remove)
            $checkpoint = $script:ReadyEpicJson | ConvertFrom-Json
            if ($Remove) {
                $checkpoint.PSObject.Properties.Remove($Property)
            } else {
                $checkpoint.$Property = $Value
            }
            return $checkpoint
        }

        function Get-EpicFixtureText {
            # Return the epic checkpoint text a single-feature row reads, selected by fixture kind.
            param([Parameter(Mandatory)] [string] $Kind)
            switch ($Kind) {
                'absent' { return $null }
                'ready' { return $script:ReadyEpicJson }
                'without-route_id' { return (ConvertTo-EpicJsonWithout -Property 'route_id') }
                'empty-integration_branch' { return (ConvertTo-EpicCheckpointVariant -Property 'integration_branch' -Value '' | ConvertTo-Json -Depth 6 -Compress) }
            }
            throw "Unknown epic fixture kind '$Kind'."
        }

        function Set-EpicScopeSeam {
            <#
                Mock the four resolver seams for one test. Value bodies close over local
                copies; the ascent body is plain so it sees the bound -Path argument.
            #>
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
            param(
                [AllowNull()] [object] $CheckpointText,
                [string] $HeadBranch = 'epic/sample-epic-integration',
                [bool] $MergeInProgress = $true
            )
            $text = $CheckpointText
            $head = $HeadBranch
            $merge = $MergeInProgress
            Mock Find-WorktreeResolutionRoot {
                if ($Path -like '/synthetic-worktrees/*') { return $Path }
                if ($Path -like '/outside/*') { return $null }
                return '/synthetic-worktrees/epic-coordinator'
            }
            Mock Get-EpicScopeCheckpointText -MockWith ({ $text }.GetNewClosure())
            Mock Get-EpicScopeWorktreeHeadBranch -MockWith ({ $head }.GetNewClosure())
            Mock Test-EpicScopeMergeInProgress -MockWith ({ $merge }.GetNewClosure())
        }
    }

    Context 'epic-scope decisions through the gate' {
        It 'epic scope allows the <Leg> leg of a production path while a merge is in progress' -ForEach @(
            @{ Leg = 'command' }
            @{ Leg = 'apply_patch' }
            @{ Leg = 'path' }
        ) {
            # Arrange
            Set-EpicScopeSeam -CheckpointText $script:ReadyEpicJson -MergeInProgress $true

            # Act
            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-LegToolInput -Leg $Leg) -CheckpointRaw $script:NotReadySingleFeature

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because 'a ready epic checkpoint with a merge in progress admits a production operand (D2)'
        }

        It 'epic scope denies the <Leg> leg of a production path when no merge is in progress and names the epic checkpoint' -ForEach @(
            @{ Leg = 'command' }
            @{ Leg = 'apply_patch' }
            @{ Leg = 'path' }
        ) {
            # Arrange
            Set-EpicScopeSeam -CheckpointText $script:ReadyEpicJson -MergeInProgress $false

            # Act
            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-LegToolInput -Leg $Leg) -CheckpointRaw $script:NotReadySingleFeature

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $reason = $decision.hookSpecificOutput.permissionDecisionReason
            $reason | Should -BeLike 'PREIMPLEMENTATION_GATE_BLOCKED*'
            $reason.Contains('epic-orchestrator-state.json') | Should -BeTrue -Because 'the denial names the epic checkpoint'
            $reason.Contains("'merge-in-progress'") | Should -BeTrue -Because 'the denial names the failed conjunct'
        }

        It 'epic scope denies the command leg when <Conjunct> is missing and names it and the epic checkpoint' -ForEach @(
            @{ Conjunct = 'epic_feature_folder' }
            @{ Conjunct = 'epic_manifest_path' }
            @{ Conjunct = 'features' }
        ) {
            # Arrange
            Set-EpicScopeSeam -CheckpointText (ConvertTo-EpicJsonWithout -Property $Conjunct) -MergeInProgress $true

            # Act
            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-LegToolInput -Leg 'command') -CheckpointRaw $script:NotReadySingleFeature

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $reason = $decision.hookSpecificOutput.permissionDecisionReason
            $reason | Should -BeLike 'PREIMPLEMENTATION_GATE_BLOCKED*'
            $reason.Contains('epic-orchestrator-state.json') | Should -BeTrue -Because 'the denial names the epic checkpoint'
            $reason.Contains("'$Conjunct'") | Should -BeTrue -Because 'the denial names the failed conjunct'
        }

        It 'the epic-scope decision names <Conjunct> and the epic checkpoint when the resolved scope carries an invalid <Conjunct>' -ForEach @(
            @{ Conjunct = 'route_id'; Value = 'parallel'; Remove = $false }
            @{ Conjunct = 'epic_feature_folder'; Value = $null; Remove = $true }
            @{ Conjunct = 'epic_manifest_path'; Value = 'docs/features/active/sample-epic/epic.md'; Remove = $false }
            @{ Conjunct = 'integration_branch'; Value = ''; Remove = $false }
            @{ Conjunct = 'features'; Value = @(); Remove = $false }
        ) {
            # Arrange: route_id and integration_branch are scope-defining in the resolver, so
            # the resolved scope is mocked to reach the predicate with each invalid conjunct (RS-1).
            $checkpoint = ConvertTo-EpicCheckpointVariant -Property $Conjunct -Value $Value -Remove:$Remove
            $scope = [pscustomobject]@{
                IsEpicScope     = $true
                CheckpointPath  = $script:SyntheticEpicCheckpointPath
                Checkpoint      = $checkpoint
                WorktreeRoot    = '/synthetic-worktrees/epic-coordinator'
                Branch          = 'epic/sample-epic-integration'
                MergeInProgress = $true
                Reason          = 'epic-scope'
            }
            Mock Resolve-EpicScopeCheckpoint -MockWith ({ $scope }.GetNewClosure())

            # Act
            $decision = Get-OrchestrationEpicScopeDecision -Command 'git add scripts/powershell/Sample.ps1' -FilePath ''

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $reason = $decision.hookSpecificOutput.permissionDecisionReason
            $reason | Should -BeLike 'PREIMPLEMENTATION_GATE_BLOCKED*'
            $reason.Contains("'$Conjunct'") | Should -BeTrue -Because 'the denial names the failed conjunct'
            $reason.Contains('epic-orchestrator-state.json') | Should -BeTrue -Because 'the denial names the epic checkpoint'
        }

        It 'epic scope decides a -C selector command by the selector worktree HEAD and allows it' {
            # Arrange
            Set-EpicScopeSeam -CheckpointText $script:ReadyEpicJson -MergeInProgress $true
            $toolInput = @{ command = 'git -C /synthetic-worktrees/epic-integration add scripts/powershell/Sample.ps1' } | ConvertTo-Json -Compress

            # Act
            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $toolInput -CheckpointRaw $script:NotReadySingleFeature

            # Assert: the HEAD read targets the selector worktree, not the session root.
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            Should -Invoke Get-EpicScopeWorktreeHeadBranch -Times 1 -Exactly -ParameterFilter {
                $WorktreeRoot -eq '/synthetic-worktrees/epic-integration'
            }
        }

        It 'a -C selector command whose selector HEAD differs is denied as target-mixed when the session-root HEAD matches (issue #738)' {
            # Arrange: only the session root has the integration branch checked out.
            Set-EpicScopeSeam -CheckpointText $script:ReadyEpicJson -MergeInProgress $true
            Mock Get-EpicScopeWorktreeHeadBranch {
                if ($WorktreeRoot -eq '/synthetic-worktrees/epic-other') { return 'feature/standalone-item' }
                return 'epic/sample-epic-integration'
            }
            $toolInput = @{ command = 'git -C /synthetic-worktrees/epic-other add scripts/powershell/Sample.ps1' } | ConvertTo-Json -Compress

            # Act
            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $toolInput -CheckpointRaw $script:NotReadySingleFeature

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason.Contains('target-mixed') | Should -BeTrue -Because 'the session root is epic scope and the selector HEAD differs (D3)'
        }

        It 'with <Label> the <Leg> leg returns the unchanged single-feature decision and reason' -ForEach @(
            @{ Label = 'no epic checkpoint'; Kind = 'absent'; Head = 'epic/sample-epic-integration'; Leg = 'command' }
            @{ Label = 'no epic checkpoint'; Kind = 'absent'; Head = 'epic/sample-epic-integration'; Leg = 'apply_patch' }
            @{ Label = 'no epic checkpoint'; Kind = 'absent'; Head = 'epic/sample-epic-integration'; Leg = 'path' }
            @{ Label = 'an integration_branch that differs from HEAD'; Kind = 'ready'; Head = 'feature/standalone-item'; Leg = 'command' }
            @{ Label = 'an integration_branch that differs from HEAD'; Kind = 'ready'; Head = 'feature/standalone-item'; Leg = 'apply_patch' }
            @{ Label = 'an integration_branch that differs from HEAD'; Kind = 'ready'; Head = 'feature/standalone-item'; Leg = 'path' }
            @{ Label = 'a missing route_id'; Kind = 'without-route_id'; Head = 'epic/sample-epic-integration'; Leg = 'command' }
            @{ Label = 'a missing route_id'; Kind = 'without-route_id'; Head = 'epic/sample-epic-integration'; Leg = 'apply_patch' }
            @{ Label = 'a missing route_id'; Kind = 'without-route_id'; Head = 'epic/sample-epic-integration'; Leg = 'path' }
            @{ Label = 'an empty integration_branch'; Kind = 'empty-integration_branch'; Head = 'epic/sample-epic-integration'; Leg = 'command' }
            @{ Label = 'an empty integration_branch'; Kind = 'empty-integration_branch'; Head = 'epic/sample-epic-integration'; Leg = 'apply_patch' }
            @{ Label = 'an empty integration_branch'; Kind = 'empty-integration_branch'; Head = 'epic/sample-epic-integration'; Leg = 'path' }
        ) {
            # Arrange
            Set-EpicScopeSeam -CheckpointText (Get-EpicFixtureText -Kind $Kind) -HeadBranch $Head -MergeInProgress $true

            # Act
            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-LegToolInput -Leg $Leg) -CheckpointRaw $script:NotReadySingleFeature

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:SingleFeatureReason
        }

        It 'without an epic checkpoint the <Leg> leg is allowed by a ready single-feature checkpoint' -ForEach @(
            @{ Leg = 'command' }
            @{ Leg = 'apply_patch' }
            @{ Leg = 'path' }
        ) {
            # Arrange
            Set-EpicScopeSeam -CheckpointText $null

            # Act
            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-LegToolInput -Leg $Leg) -CheckpointRaw $script:ReadySingleFeature

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because 'a call outside epic scope keeps the single-feature readiness decision'
        }

        It 'a bookkeeping <Leg> operand stays exempt without reading the epic checkpoint' -ForEach @(
            @{ Leg = 'path'; ToolInput = '{"file_path":"docs/features/active/sample/spec.md"}' }
            @{ Leg = 'command'; ToolInput = '{"command":"git add artifacts/orchestration/epic-orchestrator-state.json"}' }
        ) {
            # Arrange
            Set-EpicScopeSeam -CheckpointText $script:ReadyEpicJson -MergeInProgress $false

            # Act
            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $ToolInput -CheckpointRaw $script:NotReadySingleFeature

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            Should -Invoke Get-EpicScopeCheckpointText -Times 0 -Exactly
        }
    }

    Context 'relocated read seams and the no-leg guard' {
        # The two per-mode read seams moved into the epic-scope sibling keep their
        # behaviour: the path comes from the fixed mode table, an absent file yields an
        # empty string, and a present file yields its raw text. Test-Path and the content
        # read are mocked, so no file is read or created.
        BeforeEach {
            $script:EpicSeamPath = '/synthetic-worktrees/epic-coordinator/artifacts/orchestration/epic-orchestrator-state.json'
            $script:ParallelSeamPath = '/synthetic-worktrees/epic-coordinator/artifacts/orchestration/parallel-orchestrator-state.json'
            # A plain body (no closure) so the -Mode argument Pester binds is visible to it.
            Mock Get-OrchestrationDelegationCheckpointPath {
                if ($Mode -eq 'epic') { return $script:EpicSeamPath }
                return $script:ParallelSeamPath
            }
        }

        It 'the relocated epic read seam returns an empty string when the epic checkpoint file is absent' {
            # Arrange
            Mock Test-Path { $false }
            Mock Get-Content { throw 'an absent checkpoint must not be read' }

            # Act
            $text = Get-EpicCheckpointContent

            # Assert
            $text | Should -BeExactly ''
            Should -Invoke Test-Path -Times 1 -Exactly -ParameterFilter { $LiteralPath -eq $script:EpicSeamPath }
            Should -Invoke Get-Content -Times 0 -Exactly
        }

        It 'the relocated epic read seam returns the raw epic checkpoint text when the file exists' {
            # Arrange
            $raw = $script:ReadyEpicJson
            Mock Test-Path { $true }
            Mock Get-Content -MockWith ({ $raw }.GetNewClosure())

            # Act
            $text = Get-EpicCheckpointContent

            # Assert
            $text | Should -BeExactly $script:ReadyEpicJson
            Should -Invoke Get-Content -Times 1 -Exactly -ParameterFilter { $LiteralPath -eq $script:EpicSeamPath -and $Raw }
        }

        It 'the relocated parallel read seam returns an empty string when the parallel checkpoint file is absent' {
            # Arrange
            Mock Test-Path { $false }
            Mock Get-Content { throw 'an absent checkpoint must not be read' }

            # Act
            $text = Get-ParallelCheckpointContent

            # Assert
            $text | Should -BeExactly ''
            Should -Invoke Test-Path -Times 1 -Exactly -ParameterFilter { $LiteralPath -eq $script:ParallelSeamPath }
            Should -Invoke Get-Content -Times 0 -Exactly
        }

        It 'the relocated parallel read seam returns the raw parallel checkpoint text when the file exists' {
            # Arrange
            Mock Test-Path { $true }
            Mock Get-Content { '{"route_id":"parallel"}' }

            # Act
            $text = Get-ParallelCheckpointContent

            # Assert
            $text | Should -BeExactly '{"route_id":"parallel"}'
            Should -Invoke Get-Content -Times 1 -Exactly -ParameterFilter { $LiteralPath -eq $script:ParallelSeamPath -and $Raw }
        }

        It 'the epic-scope decision returns null without resolving when the call carries neither a command nor a path' {
            # Arrange
            Mock Resolve-EpicScopeCheckpoint { throw 'a call with no leg must not be resolved' }

            # Act
            $decision = Get-OrchestrationEpicScopeDecision -Command '' -FilePath ''

            # Assert
            $decision | Should -BeNullOrEmpty
            Should -Invoke Resolve-EpicScopeCheckpoint -Times 0 -Exactly
        }
    }

    Context 'epic-scope selector' {
        It 'the epic-scope selector returns <Display> for <Label>' -ForEach @(
            @{ Display = 'the selector path'; Label = 'a leading git -C selector'; Command = 'git -C /synthetic-worktrees/epic-integration add scripts/powershell/Sample.ps1'; Expected = '/synthetic-worktrees/epic-integration' }
            @{ Display = 'no selector'; Label = 'a command without a selector'; Command = 'git add scripts/powershell/Sample.ps1'; Expected = $null }
            @{ Display = 'no selector'; Label = 'an unbalanced command line'; Command = 'git -C "/synthetic-worktrees/epic-integration add scripts/powershell/Sample.ps1'; Expected = $null }
        ) {
            # Act
            $selector = Get-OrchestrationEpicScopeSelector -Command $Command

            # Assert
            if ($null -eq $Expected) {
                $selector | Should -BeNullOrEmpty
            } else {
                $selector | Should -BeExactly $Expected
            }
        }
    }

    Context 'structure, parity, and interpreter absence' {
        It 'resolves every Codex epic-scope seam name as a function after dot-sourcing the gate' {
            # Arrange
            $names = @(
                'Get-EpicScopeCheckpointText'
                'ConvertFrom-EpicScopeCheckpointText'
                'Get-EpicScopeWorktreeGitDirectory'
                'Get-EpicScopeWorktreeHeadBranch'
                'Test-EpicScopeMergeInProgress'
                'Resolve-EpicScopeCheckpoint'
                'Get-EpicCommandLegReadinessFailure'
                'Get-OrchestrationEpicScopeSelector'
                'Get-OrchestrationEpicScopeDecision'
                'Get-EpicCheckpointContent'
                'Get-ParallelCheckpointContent'
            )

            # Act
            $missing = @($names | Where-Object { -not (Get-Command -Name $_ -CommandType Function -ErrorAction SilentlyContinue) })

            # Assert
            $missing | Should -BeNullOrEmpty -Because 'every D2 seam and both relocated read seams load with the gate'
        }

        It 'keeps <File> at or under 500 lines in the repository and the bundle' -ForEach @(
            @{ File = 'enforce-orchestration-preimplementation-gate.ps1' }
            @{ File = 'enforce-orchestration-preimplementation-gate-epic-scope.ps1' }
            @{ File = 'enforce-orchestration-preimplementation-gate-epic-resolution.ps1' }
        ) {
            # Arrange
            $repositoryPath = Join-Path $script:RepoRoot ".codex/hooks/$File"
            $bundlePath = Join-Path $script:BundleHookRoot $File

            # Act
            $repositoryCount = @(Get-Content -LiteralPath $repositoryPath).Count
            $bundleCount = @(Get-Content -LiteralPath $bundlePath).Count

            # Assert
            $repositoryCount | Should -BeLessOrEqual 500 -Because 'the repository copy stays inside the 500-line cap'
            $bundleCount | Should -BeLessOrEqual 500 -Because 'the bundle copy stays inside the 500-line cap'
        }

        It 'keeps <File> byte-identical to its bundle copy' -ForEach @(
            @{ File = 'enforce-orchestration-preimplementation-gate.ps1' }
            @{ File = 'enforce-orchestration-preimplementation-gate-epic-scope.ps1' }
            @{ File = 'enforce-orchestration-preimplementation-gate-epic-resolution.ps1' }
        ) {
            # Arrange
            $repositoryPath = Join-Path $script:RepoRoot ".codex/hooks/$File"
            $bundlePath = Join-Path $script:BundleHookRoot $File

            # Act
            $repositoryHash = (Get-FileHash -LiteralPath $repositoryPath -Algorithm SHA256).Hash
            $bundleHash = (Get-FileHash -LiteralPath $bundlePath -Algorithm SHA256).Hash

            # Assert
            $bundleHash | Should -BeExactly $repositoryHash -Because 'the bundle copy is a byte copy of the repository file'
        }

        It 'reports no interpreter invocation in <File> or its bundle copy' -ForEach @(
            @{ File = 'enforce-orchestration-preimplementation-gate.ps1' }
            @{ File = 'enforce-orchestration-preimplementation-gate-epic-scope.ps1' }
            @{ File = 'enforce-orchestration-preimplementation-gate-epic-resolution.ps1' }
        ) {
            # Arrange
            $repositoryText = Get-Content -Raw -LiteralPath (Join-Path $script:RepoRoot ".codex/hooks/$File")
            $bundleText = Get-Content -Raw -LiteralPath (Join-Path $script:BundleHookRoot $File)

            # Act: the helper returns its findings as one array (unary comma), so the result
            # is assigned directly rather than wrapped in a second array.
            $repositoryFindings = Get-PythonInvocationFinding -ScriptText $repositoryText -SourceLabel ".codex/hooks/$File"
            $bundleFindings = Get-PythonInvocationFinding -ScriptText $bundleText -SourceLabel "bundle/.codex/hooks/$File"

            # Assert
            $repositoryFindings.Count | Should -Be 0 -Because 'the repository hook starts no interpreter process (D16)'
            $bundleFindings.Count | Should -Be 0 -Because 'the bundle hook starts no interpreter process (D16)'
        }

        It 'keeps <File> free of interpreter-name tokens and declares the predicate PowerShell-authoritative' -ForEach @(
            @{ File = 'enforce-orchestration-preimplementation-gate-epic-scope.ps1' }
            @{ File = 'enforce-orchestration-preimplementation-gate-epic-resolution.ps1' }
        ) {
            # Arrange
            $text = Get-Content -Raw -LiteralPath (Join-Path $script:RepoRoot ".codex/hooks/$File")

            # Act
            $interpreterTokenMatches = [regex]::Matches($text, 'python|poetry', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase).Count

            # Assert
            $interpreterTokenMatches | Should -Be 0 -Because 'a sibling this change authors names no interpreter (D16)'
            $text.Contains('PowerShell-authoritative') | Should -BeTrue -Because 'the sibling header declares PowerShell authority (D15)'
        }
    }
}
