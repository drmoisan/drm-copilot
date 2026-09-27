#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Epic-scope resolution and command-leg readiness for the Codex preimplementation gate (issue #707).

.DESCRIPTION
    Covers the Codex-local resolution sibling
    .codex/hooks/enforce-orchestration-preimplementation-gate-epic-resolution.ps1 and the
    command-leg readiness predicate of the epic-scope sibling. The suite dot-sources
    .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1, which loads
    the resolution sibling, and imports no Claude module or hook.

    The Codex resolver has a fixed head-match contract (D3): it takes no command text and
    always matches the effective worktree HEAD against integration_branch, so the issue
    #663 reason no-branch-signal is unreachable and is not returned. No row asserts it.

    Resolver rows mock the four seams Find-WorktreeResolutionRoot,
    Get-EpicScopeCheckpointText, Get-EpicScopeWorktreeHeadBranch, and
    Test-EpicScopeMergeInProgress. Primitive rows mock only the existence probe
    Get-WorktreeResolutionGitEntryKind and the content read
    Get-WorktreeResolutionGitFileText. Every path lies under /synthetic-worktrees/ or
    /outside/, so no host path reaches an assertion, and no row creates a file or changes
    the working directory.
#>

Describe 'Codex epic-scope resolution sibling (issue #707)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot '.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1')

        $script:ReadyEpicJson = '{"route_id":"epic","epic_feature_folder":"sample-epic","epic_manifest_path":"docs/features/epics/sample-epic/epic.md","integration_branch":"epic/sample-epic-integration","epic_issue_num":900,"features":[{"feature_folder":"2026-09-25-child-a-901","merge_status":"merged"},{"feature_folder":"2026-09-25-child-b-902","merge_status":"worktree_removed"}],"model_routing_receipts":[{"agent":"pr-author"}]}'
        $script:SyntheticCheckpointPath = '/synthetic-worktrees/epic-coordinator/artifacts/orchestration/epic-orchestrator-state.json'

        function ConvertTo-EpicCheckpointVariant {
            # Return the parsed ready epic checkpoint with one property removed or replaced.
            param([string] $Property = '', [AllowNull()] [object] $Value, [switch] $Remove)
            $checkpoint = $script:ReadyEpicJson | ConvertFrom-Json
            if ($Remove) {
                $checkpoint.PSObject.Properties.Remove($Property)
            } elseif ($Property) {
                $checkpoint.$Property = $Value
            }
            return $checkpoint
        }

        function Get-ResolutionFixtureText {
            # Return the epic checkpoint text a resolver row reads, selected by fixture kind.
            param([Parameter(Mandatory)] [string] $Kind)
            switch ($Kind) {
                'ready' { return $script:ReadyEpicJson }
                'absent' { return $null }
                'unparseable' { return '{"route_id":' }
                'array' { return '[1,2]' }
                'route_id' { return (ConvertTo-EpicCheckpointVariant -Property 'route_id' -Value 'parallel' | ConvertTo-Json -Depth 6 -Compress) }
                'integration_branch' { return (ConvertTo-EpicCheckpointVariant -Property 'integration_branch' -Value '' | ConvertTo-Json -Depth 6 -Compress) }
            }
            throw "Unknown resolver fixture kind '$Kind'."
        }

        function Set-ResolverSeam {
            <#
                Mock the four resolver seams for one test. Value bodies close over local
                copies; the ascent body is plain so it sees the bound -Path argument.
            #>
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
            param(
                [AllowNull()] [object] $CheckpointText,
                [AllowNull()] [object] $HeadBranch = 'epic/sample-epic-integration',
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

    Context 'Resolve-EpicScopeCheckpoint' {
        It 'resolves reason <Reason> for <Label>' -ForEach @(
            @{ Reason = 'epic-scope'; Label = 'the session-root HEAD matching integration_branch'; Kind = 'ready'; Head = 'epic/sample-epic-integration'; SessionRoot = '/synthetic-worktrees/epic-coordinator'; Selector = '' }
            @{ Reason = 'epic-scope'; Label = 'a -C selector worktree whose HEAD matches integration_branch'; Kind = 'ready'; Head = 'epic/sample-epic-integration'; SessionRoot = '/synthetic-worktrees/epic-coordinator'; Selector = '/synthetic-worktrees/epic-integration' }
            @{ Reason = 'session-root-unresolved'; Label = 'a session root outside any worktree'; Kind = 'ready'; Head = 'epic/sample-epic-integration'; SessionRoot = '/outside/session'; Selector = '' }
            @{ Reason = 'epic-checkpoint-absent-or-unparseable'; Label = 'an absent epic checkpoint'; Kind = 'absent'; Head = 'epic/sample-epic-integration'; SessionRoot = '/synthetic-worktrees/epic-coordinator'; Selector = '' }
            @{ Reason = 'epic-checkpoint-absent-or-unparseable'; Label = 'an unparseable epic checkpoint'; Kind = 'unparseable'; Head = 'epic/sample-epic-integration'; SessionRoot = '/synthetic-worktrees/epic-coordinator'; Selector = '' }
            @{ Reason = 'epic-checkpoint-absent-or-unparseable'; Label = 'an array-shaped epic checkpoint'; Kind = 'array'; Head = 'epic/sample-epic-integration'; SessionRoot = '/synthetic-worktrees/epic-coordinator'; Selector = '' }
            @{ Reason = 'route_id'; Label = 'a route_id other than epic'; Kind = 'route_id'; Head = 'epic/sample-epic-integration'; SessionRoot = '/synthetic-worktrees/epic-coordinator'; Selector = '' }
            @{ Reason = 'integration_branch'; Label = 'an empty integration_branch'; Kind = 'integration_branch'; Head = 'epic/sample-epic-integration'; SessionRoot = '/synthetic-worktrees/epic-coordinator'; Selector = '' }
            @{ Reason = 'selector-unresolved'; Label = 'a -C selector outside any worktree'; Kind = 'ready'; Head = 'epic/sample-epic-integration'; SessionRoot = '/synthetic-worktrees/epic-coordinator'; Selector = '/outside/elsewhere' }
            @{ Reason = 'branch-mismatch'; Label = 'an effective HEAD that differs from integration_branch'; Kind = 'ready'; Head = 'feature/standalone-item'; SessionRoot = '/synthetic-worktrees/epic-coordinator'; Selector = '' }
            @{ Reason = 'branch-mismatch'; Label = 'a detached HEAD'; Kind = 'ready'; Head = $null; SessionRoot = '/synthetic-worktrees/epic-coordinator'; Selector = '' }
        ) {
            # Arrange
            Set-ResolverSeam -CheckpointText (Get-ResolutionFixtureText -Kind $Kind) -HeadBranch $Head -MergeInProgress $true
            $captured = @{}

            # Act
            { $captured.Result = Resolve-EpicScopeCheckpoint -SessionRoot $SessionRoot -WorktreeSelector $Selector } | Should -Not -Throw

            # Assert
            $captured.Result.Reason | Should -BeExactly $Reason
            $captured.Result.IsEpicScope | Should -Be ($Reason -eq 'epic-scope') -Because 'only the epic-scope reason marks the call as epic scope'
        }

        It 'reports MergeInProgress <Expected> when the MERGE_HEAD probe returns <Expected>' -ForEach @(
            @{ Expected = $true }
            @{ Expected = $false }
        ) {
            # Arrange
            Set-ResolverSeam -CheckpointText $script:ReadyEpicJson -MergeInProgress $Expected

            # Act
            $result = Resolve-EpicScopeCheckpoint -SessionRoot '/synthetic-worktrees/epic-coordinator'

            # Assert
            $result.IsEpicScope | Should -BeTrue
            $result.MergeInProgress | Should -Be $Expected
        }

        It 'composes an absolute checkpoint path from the resolved session root' {
            # Arrange
            Set-ResolverSeam -CheckpointText $script:ReadyEpicJson

            # Act
            $result = Resolve-EpicScopeCheckpoint -SessionRoot '/synthetic-worktrees/epic-coordinator'

            # Assert
            $result.CheckpointPath | Should -BeExactly $script:SyntheticCheckpointPath
            Should -Invoke Get-EpicScopeCheckpointText -Times 1 -Exactly -ParameterFilter { $Path -ceq '/synthetic-worktrees/epic-coordinator/artifacts/orchestration/epic-orchestrator-state.json' }
        }

        It 'consults the -C selector worktree HEAD and not the session-root HEAD when a selector is supplied' {
            # Arrange
            Set-ResolverSeam -CheckpointText $script:ReadyEpicJson

            # Act
            $result = Resolve-EpicScopeCheckpoint -SessionRoot '/synthetic-worktrees/epic-coordinator' -WorktreeSelector '/synthetic-worktrees/epic-integration'

            # Assert
            $result.WorktreeRoot | Should -BeExactly '/synthetic-worktrees/epic-integration'
            Should -Invoke Get-EpicScopeWorktreeHeadBranch -Times 1 -Exactly -ParameterFilter { $WorktreeRoot -ceq '/synthetic-worktrees/epic-integration' }
            Should -Invoke Get-EpicScopeWorktreeHeadBranch -Times 0 -Exactly -ParameterFilter { $WorktreeRoot -ceq '/synthetic-worktrees/epic-coordinator' }
            Should -Invoke Test-EpicScopeMergeInProgress -Times 1 -Exactly -ParameterFilter { $WorktreeRoot -ceq '/synthetic-worktrees/epic-integration' }
        }

        It 'declares the fixed head-match signature without Text or MatchWorktreeHead parameters' {
            # Arrange
            $command = Get-Command -Name Resolve-EpicScopeCheckpoint -CommandType Function

            # Act
            $names = @($command.Parameters.Keys)

            # Assert
            $names | Should -Not -Contain 'Text'
            $names | Should -Not -Contain 'MatchWorktreeHead'
            $names | Should -Contain 'SessionRoot'
            $names | Should -Contain 'WorktreeSelector'
        }
    }

    Context 'checkpoint, HEAD, and MERGE_HEAD seams' {
        It 'returns null checkpoint text when the checkpoint file is absent' {
            # Arrange
            Mock Get-WorktreeResolutionGitEntryKind { 'None' }
            Mock Get-WorktreeResolutionGitFileText { throw 'an absent checkpoint must not be read' }

            # Act
            $text = Get-EpicScopeCheckpointText -Path $script:SyntheticCheckpointPath

            # Assert
            $text | Should -BeNullOrEmpty
            Should -Invoke Get-WorktreeResolutionGitFileText -Times 0 -Exactly
        }

        It 'returns the checkpoint text when the checkpoint file exists' {
            # Arrange
            Mock Get-WorktreeResolutionGitEntryKind { 'File' }
            Mock Get-WorktreeResolutionGitFileText { '{"route_id":"epic"}' }

            # Act
            $text = Get-EpicScopeCheckpointText -Path $script:SyntheticCheckpointPath

            # Assert
            $text | Should -BeExactly '{"route_id":"epic"}'
            Should -Invoke Get-WorktreeResolutionGitFileText -Times 1 -Exactly -ParameterFilter { $Path -ceq '/synthetic-worktrees/epic-coordinator/artifacts/orchestration/epic-orchestrator-state.json' }
        }

        It 'reads the HEAD branch of a linked worktree through its gitdir file' {
            # Arrange
            Mock Get-WorktreeResolutionGitEntryKind { 'None' }
            Mock Get-WorktreeResolutionGitEntryKind { 'File' } -ParameterFilter { $Path -ceq '/synthetic-worktrees/epic-integration/.git' }
            Mock Get-WorktreeResolutionGitFileText { $null }
            Mock Get-WorktreeResolutionGitFileText { 'gitdir: /synthetic-worktrees/epic-coordinator/.git/worktrees/epic-integration' } -ParameterFilter { $Path -ceq '/synthetic-worktrees/epic-integration/.git' }
            Mock Get-WorktreeResolutionGitFileText { "ref: refs/heads/epic/sample-epic-integration`n" } -ParameterFilter { $Path -ceq '/synthetic-worktrees/epic-coordinator/.git/worktrees/epic-integration/HEAD' }

            # Act
            $branch = Get-EpicScopeWorktreeHeadBranch -WorktreeRoot '/synthetic-worktrees/epic-integration'

            # Assert
            $branch | Should -BeExactly 'epic/sample-epic-integration'
        }

        It 'reads the HEAD branch of a main checkout through its git directory' {
            # Arrange
            Mock Get-WorktreeResolutionGitEntryKind { 'None' }
            Mock Get-WorktreeResolutionGitEntryKind { 'Directory' } -ParameterFilter { $Path -ceq '/synthetic-worktrees/epic-coordinator/.git' }
            Mock Get-WorktreeResolutionGitFileText { $null }
            Mock Get-WorktreeResolutionGitFileText { "ref: refs/heads/main`n" } -ParameterFilter { $Path -ceq '/synthetic-worktrees/epic-coordinator/.git/HEAD' }

            # Act
            $branch = Get-EpicScopeWorktreeHeadBranch -WorktreeRoot '/synthetic-worktrees/epic-coordinator'

            # Assert
            $branch | Should -BeExactly 'main'
        }

        It 'resolves a relative gitdir target against the worktree root' {
            # Arrange
            Mock Get-WorktreeResolutionGitEntryKind { 'File' }
            Mock Get-WorktreeResolutionGitFileText { 'gitdir: admin/worktrees/epic-integration' }

            # Act
            $gitDirectory = Get-EpicScopeWorktreeGitDirectory -WorktreeRoot '/synthetic-worktrees/epic-integration'

            # Assert
            $gitDirectory | Should -BeExactly '/synthetic-worktrees/epic-integration/admin/worktrees/epic-integration'
        }

        It 'returns no HEAD branch for a detached HEAD' {
            # Arrange
            Mock Get-WorktreeResolutionGitEntryKind { 'Directory' }
            Mock Get-WorktreeResolutionGitFileText { "0123456789abcdef0123456789abcdef01234567`n" }

            # Act
            $branch = Get-EpicScopeWorktreeHeadBranch -WorktreeRoot '/synthetic-worktrees/epic-coordinator'

            # Assert
            $branch | Should -BeNullOrEmpty
        }

        It 'returns no git directory for <Label>' -ForEach @(
            @{ Label = 'a missing git entry'; Root = '/synthetic-worktrees/epic-coordinator'; Kind = 'None'; Text = $null; Probes = 1 }
            @{ Label = 'a gitdir file without a gitdir line'; Root = '/synthetic-worktrees/epic-coordinator'; Kind = 'File'; Text = 'not a worktree pointer'; Probes = 1 }
            @{ Label = 'a relative worktree root'; Root = 'synthetic-worktrees/epic-coordinator'; Kind = 'Directory'; Text = $null; Probes = 0 }
        ) {
            # Arrange
            $kind = $Kind
            $text = $Text
            Mock Get-WorktreeResolutionGitEntryKind -MockWith ({ $kind }.GetNewClosure())
            Mock Get-WorktreeResolutionGitFileText -MockWith ({ $text }.GetNewClosure())

            # Act
            $gitDirectory = Get-EpicScopeWorktreeGitDirectory -WorktreeRoot $Root

            # Assert
            $gitDirectory | Should -BeNullOrEmpty
            Should -Invoke Get-WorktreeResolutionGitEntryKind -Times $Probes -Exactly
        }

        It 'probes MERGE_HEAD in the worktree git directory and reports <Expected>' -ForEach @(
            @{ Expected = $true; Kind = 'File' }
            @{ Expected = $false; Kind = 'None' }
        ) {
            # Arrange
            $mergeKind = $Kind
            Mock Get-WorktreeResolutionGitEntryKind { 'None' }
            Mock Get-WorktreeResolutionGitEntryKind { 'Directory' } -ParameterFilter { $Path -ceq '/synthetic-worktrees/epic-integration/.git' }
            Mock Get-WorktreeResolutionGitEntryKind -MockWith ({ $mergeKind }.GetNewClosure()) -ParameterFilter { $Path -ceq '/synthetic-worktrees/epic-integration/.git/MERGE_HEAD' }

            # Act
            $inProgress = Test-EpicScopeMergeInProgress -WorktreeRoot '/synthetic-worktrees/epic-integration'

            # Assert
            $inProgress | Should -Be $Expected
            Should -Invoke Get-WorktreeResolutionGitEntryKind -Times 1 -Exactly -ParameterFilter { $Path -ceq '/synthetic-worktrees/epic-integration/.git/MERGE_HEAD' }
        }

        It 'reports no merge in progress when the worktree has no git directory' {
            # Arrange
            Mock Get-WorktreeResolutionGitEntryKind { 'None' }

            # Act
            $inProgress = Test-EpicScopeMergeInProgress -WorktreeRoot '/synthetic-worktrees/epic-integration'

            # Assert
            $inProgress | Should -BeFalse
            Should -Invoke Get-WorktreeResolutionGitEntryKind -Times 1 -Exactly
        }
    }

    Context 'worktree ascent and path primitives' {
        It 'finds the worktree root by ascending to the first level that carries a git directory' {
            # Arrange
            Mock Get-WorktreeResolutionGitEntryKind { 'None' }
            Mock Get-WorktreeResolutionGitEntryKind { 'Directory' } -ParameterFilter { $Path -ceq '/synthetic-worktrees/epic-coordinator/.git' }

            # Act
            $root = Find-WorktreeResolutionRoot -Path '/synthetic-worktrees/epic-coordinator/scripts/powershell'

            # Assert
            $root | Should -BeExactly '/synthetic-worktrees/epic-coordinator'
        }

        It 'finds a linked worktree root whose git entry is a gitdir file' {
            # Arrange
            Mock Get-WorktreeResolutionGitEntryKind { 'None' }
            Mock Get-WorktreeResolutionGitEntryKind { 'File' } -ParameterFilter { $Path -ceq '/synthetic-worktrees/epic-integration/.git' }
            Mock Get-WorktreeResolutionGitFileText { 'gitdir: /synthetic-worktrees/epic-coordinator/.git/worktrees/epic-integration' }

            # Act
            $root = Find-WorktreeResolutionRoot -Path '/synthetic-worktrees/epic-integration/docs'

            # Assert
            $root | Should -BeExactly '/synthetic-worktrees/epic-integration'
        }

        It 'returns no worktree root for <Label>' -ForEach @(
            @{ Label = 'a relative start path'; Path = 'synthetic-worktrees/epic-coordinator/docs'; Probes = 0 }
            @{ Label = 'an ascent that reaches the filesystem root without a git entry'; Path = '/outside/deep/path'; Probes = 4 }
        ) {
            # Arrange
            Mock Get-WorktreeResolutionGitEntryKind { 'None' }

            # Act
            $root = Find-WorktreeResolutionRoot -Path $Path

            # Assert
            $root | Should -BeNullOrEmpty
            Should -Invoke Get-WorktreeResolutionGitEntryKind -Times $Probes -Exactly
        }

        It 'normalises backslashes, repeated separators, a leading dot segment, and a trailing slash' {
            # Arrange
            $raw = '.\synthetic-worktrees\\epic-coordinator//docs/'

            # Act
            $normalized = ConvertTo-WorktreeResolutionNormalizedPath -Path $raw

            # Assert
            $normalized | Should -BeExactly 'synthetic-worktrees/epic-coordinator/docs'
        }

        It 'returns a null normalised path for blank input' {
            # Arrange
            $raw = '   '

            # Act
            $normalized = ConvertTo-WorktreeResolutionNormalizedPath -Path $raw

            # Assert
            $null -eq $normalized | Should -BeTrue -Because 'blank input has no normalised form'
        }

        It 'rejects a relative worktree root when composing a path' {
            # Arrange
            $compose = { Join-WorktreeResolutionPath -WorktreeRoot 'synthetic-worktrees/epic-coordinator' -RepoRelativePath 'docs' }

            # Act and Assert
            $compose | Should -Throw -ExpectedMessage 'WorktreeRoot must be an absolute path*'
        }

        It 'returns null from the checkpoint parser for <Label>' -ForEach @(
            @{ Label = 'null text'; Text = $null }
            @{ Label = 'whitespace text'; Text = '   ' }
            @{ Label = 'a JSON scalar'; Text = '42' }
        ) {
            # Arrange
            $raw = $Text

            # Act
            $parsed = ConvertFrom-EpicScopeCheckpointText -Text $raw

            # Assert
            $null -eq $parsed | Should -BeTrue -Because 'only a JSON object is a checkpoint'
        }
    }

    Context 'command-leg readiness predicate' {
        It 'command-leg readiness passes for a ready epic checkpoint while a merge is in progress' {
            # Arrange
            $checkpoint = ConvertTo-EpicCheckpointVariant

            # Act
            $failure = Get-EpicCommandLegReadinessFailure -Checkpoint $checkpoint -MergeInProgress $true

            # Assert
            $failure | Should -BeNullOrEmpty
        }

        It 'command-leg readiness names <Conjunct> for <Label>' -ForEach @(
            @{ Conjunct = 'checkpoint-absent'; Label = 'a null checkpoint'; Mutation = 'null'; Property = ''; Value = $null; Merge = $true }
            @{ Conjunct = 'route_id'; Label = 'a route_id other than epic'; Mutation = 'set'; Property = 'route_id'; Value = 'parallel'; Merge = $true }
            @{ Conjunct = 'epic_feature_folder'; Label = 'a missing epic_feature_folder'; Mutation = 'remove'; Property = 'epic_feature_folder'; Value = $null; Merge = $true }
            @{ Conjunct = 'epic_manifest_path'; Label = 'an epic_manifest_path outside docs/features/epics/'; Mutation = 'set'; Property = 'epic_manifest_path'; Value = 'docs/features/active/sample-epic/epic.md'; Merge = $true }
            @{ Conjunct = 'integration_branch'; Label = 'a missing integration_branch'; Mutation = 'remove'; Property = 'integration_branch'; Value = $null; Merge = $true }
            @{ Conjunct = 'features'; Label = 'an empty features array'; Mutation = 'set'; Property = 'features'; Value = @(); Merge = $true }
            @{ Conjunct = 'merge-in-progress'; Label = 'no merge in progress'; Mutation = 'none'; Property = ''; Value = $null; Merge = $false }
        ) {
            # Arrange
            $checkpoint = switch ($Mutation) {
                'null' { $null }
                'set' { ConvertTo-EpicCheckpointVariant -Property $Property -Value $Value }
                'remove' { ConvertTo-EpicCheckpointVariant -Property $Property -Remove }
                default { ConvertTo-EpicCheckpointVariant }
            }

            # Act
            $failure = Get-EpicCommandLegReadinessFailure -Checkpoint $checkpoint -MergeInProgress $Merge

            # Assert
            $failure | Should -BeExactly $Conjunct
        }

        It 'command-leg readiness reports the earliest failed conjunct when several fail' {
            # Arrange
            $checkpoint = ConvertTo-EpicCheckpointVariant -Property 'epic_feature_folder' -Remove
            $checkpoint.PSObject.Properties.Remove('features')

            # Act
            $failure = Get-EpicCommandLegReadinessFailure -Checkpoint $checkpoint -MergeInProgress $false

            # Assert
            $failure | Should -BeExactly 'epic_feature_folder'
        }

        It 'command-leg readiness accepts a backslash-separated epic_manifest_path under the epics tree' {
            # Arrange
            $checkpoint = ConvertTo-EpicCheckpointVariant -Property 'epic_manifest_path' -Value 'docs\features\epics\sample-epic\epic.md'

            # Act
            $failure = Get-EpicCommandLegReadinessFailure -Checkpoint $checkpoint -MergeInProgress $true

            # Assert
            $failure | Should -BeNullOrEmpty
        }
    }
}
