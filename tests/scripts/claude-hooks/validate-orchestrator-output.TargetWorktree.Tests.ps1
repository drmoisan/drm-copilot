#Requires -Version 7.0
<#
.SYNOPSIS
    Item-worktree resolution of the orchestrator-state checkpoint in
    .claude/hooks/validate-orchestrator-output.ps1 (issue #1145).

.DESCRIPTION
    The delegation prompt comes from an in-memory ReadTranscriptHead seam and the registered
    worktrees from an in-memory WorktreeListInvoker seam. Checkpoint reads go through a path-keyed
    Get-CheckpointFileContent mock that records every path, and the routing and feature-folder
    probes are recording invokers, so no row reads or creates a file, starts a process, or reads a
    clock. Fixture roots are /-rooted forward-slash paths and -SessionRoot is passed explicitly.
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification = 'Fixture values are consumed inside It blocks after definition in BeforeAll')]
param()

BeforeAll {
    . (Join-Path $PSScriptRoot '../../../.claude/hooks/validate-orchestrator-output.ps1')
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    Register-EpicStateBaselineMock -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText', 'Get-OrchestratorStateCheckpoint', 'Get-CheckpointFileContent' -Surface 'Claude'

    $script:SessionRoot = '/synthetic-worktrees/main'
    $script:ItemRoot = '/synthetic-worktrees/main/.claude/worktrees/bug-1145'
    $script:Leaf = 'artifacts/orchestration/orchestrator-state.json'
    $script:SessionPath = "$script:SessionRoot/$script:Leaf"
    $script:ItemPath = "$script:ItemRoot/$script:Leaf"
    $script:Prompt = "Canonical issue number for this feature is 1145.`nbranch: bug/sample-1145"
    $script:Valid = '{"objective":"run","completed_steps":["S1"],"next_step":"complete","last_updated":"2026-11-08T00:00:00Z"}'
    $script:Invalid = '{"objective":"run","completed_steps":["S1"],"last_updated":"2026-11-08T00:00:00Z"}'
    $script:Token = 'ORCHESTRATOR_CHECKPOINT_FALLBACK:'
    $script:Porcelain = @(
        'worktree /synthetic-worktrees/main', 'branch refs/heads/main', '',
        'worktree /synthetic-worktrees/main/.claude/worktrees/bug-1145', 'branch refs/heads/bug/sample-1145', ''
    ) -join "`n"

    function Invoke-Case {
        # Runs Invoke-OrchestratorOutputValidation with in-memory seams and returns the result plus the recorded calls.
        param(
            [AllowNull()] [string] $Prompt = $script:Prompt,
            [hashtable] $Map = @{},
            [string] $Porcelain = $script:Porcelain,
            [switch] $NoTranscript,
            [bool] $StopHookActive = $false,
            [string] $ArtifactType = 'orchestrator-state',
            [string] $CheckpointPath = $script:Leaf
        )
        $fileMap = $Map
        $read = [System.Collections.Generic.List[string]]::new()
        $routed = [System.Collections.Generic.List[string]]::new()
        $readerCalls = [System.Collections.Generic.List[string]]::new()
        $git = [System.Collections.Generic.List[object]]::new()
        Mock Get-CheckpointFileContent {
            param([string] $Path)
            $read.Add($Path)
            if ($fileMap.ContainsKey($Path)) { return @{ Exists = $true; Content = $fileMap[$Path] } }
            return @{ Exists = $false; Content = $null }
        }.GetNewClosure()
        $lines = [string[]]@((@{ type = 'user'; message = @{ role = 'user'; content = $Prompt } } | ConvertTo-Json -Compress -Depth 5))
        $reader = { param([string] $Path) $readerCalls.Add($Path); $lines }.GetNewClosure()
        $listText = $Porcelain
        $envelope = [ordered]@{ session_id = 'tw-1145'; hook_event_name = 'SubagentStop'; agent_type = 'orchestrator'; stop_hook_active = $StopHookActive; last_assistant_message = 'Done.' }
        if (-not $NoTranscript) { $envelope['agent_transcript_path'] = 'transcripts/subagents/agent-1145.jsonl' }
        $result = Invoke-OrchestratorOutputValidation -InputText ($envelope | ConvertTo-Json -Compress) -SessionRoot $script:SessionRoot `
            -ArtifactType $ArtifactType -CheckpointPath $CheckpointPath -ReadTranscriptHead $reader -WorktreeListInvoker { param($SessionRoot) $null = $SessionRoot; $listText }.GetNewClosure() `
            -RoutingInvoker { param($Path, $Type) $null = $Type; $routed.Add($Path); [pscustomobject]@{ ExitCode = 0; Output = '' } }.GetNewClosure() `
            -FeatureFolderGitInvoker { $git.Add([string[]]@($args)); $global:LASTEXITCODE = 0; 'tree' }.GetNewClosure()
        return [pscustomobject]@{ Result = $result; Read = @($read); Routed = @($routed); ReaderCalls = $readerCalls.Count; Git = @($git) }
    }
}

Describe 'epic-state baseline isolation (issue #1145)' {
    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }
}

Describe 'validate-orchestrator-output orchestrator-state target worktree (issue #1145)' {
    BeforeEach {
        # The session-worktree fallback resolves without probing the file system.
        $session = $script:SessionRoot
        Mock Resolve-WorktreeOperandTarget { [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = $session; ReasonCode = $null; Detail = 'synthetic session worktree' } }.GetNewClosure()
    }
    AfterEach { $global:LASTEXITCODE = 0 }

    It 'H1 allows a valid item checkpoint while the session checkpoint is invalid, reading only the item path' {
        # Act
        $outcome = Invoke-Case -Map @{ $script:SessionPath = $script:Invalid; $script:ItemPath = $script:Valid }

        # Assert
        $outcome.Result.Ok | Should -BeTrue -Because $outcome.Result.Message
        $outcome.Read | Should -Be @($script:ItemPath)
        $outcome.Routed | Should -Be @($script:ItemPath)
    }

    It 'H2 blocks on an invalid item checkpoint naming the item path and never reads the session path' {
        # Act
        $outcome = Invoke-Case -Map @{ $script:SessionPath = $script:Valid; $script:ItemPath = $script:Invalid }

        # Assert
        $outcome.Result.Ok | Should -BeFalse
        $outcome.Result.Message | Should -BeLike "*'$($script:ItemPath)' is missing required field(s): next_step*"
        $outcome.Read | Should -Not -Contain $script:SessionPath
    }

    It 'H3 validates the session worktree with the fallback note when the envelope names no transcript' {
        # Act
        $blocked = Invoke-Case -NoTranscript -Map @{ $script:SessionPath = $script:Invalid }
        $allowed = Invoke-Case -NoTranscript -Map @{ $script:SessionPath = $script:Valid }

        # Assert
        $blocked.ReaderCalls | Should -Be 0
        $blocked.Result.Ok | Should -BeFalse
        $blocked.Result.Message | Should -BeLike "*$($script:Token)*"
        $allowed.Result.Ok | Should -BeTrue
        $allowed.Result.Message | Should -BeNullOrEmpty
        $allowed.Result.Note | Should -BeLike "$($script:Token)*"
        $allowed.Read | Should -Be @($script:SessionPath)
    }

    It 'H4 reads the transcript once and falls back with the note when the prompt carries no identity' {
        # Act
        $outcome = Invoke-Case -Prompt 'Run the orchestration.' -Map @{ $script:SessionPath = $script:Valid }

        # Assert
        $outcome.ReaderCalls | Should -Be 1
        $outcome.Result.Ok | Should -BeTrue
        $outcome.Result.Note | Should -BeLike "$($script:Token)*no branch: label or canonical issue line*"
    }

    It 'H5 blocks as NoTarget without any read when the identity places the run nowhere (<Label>)' -ForEach @(
        @{ Label = 'branch in no worktree'; Prompt = 'branch: bug/unknown-1145' }
        @{ Label = 'issue recorded by no worktree'; Prompt = 'Canonical issue number for this feature is 9145.' }
    ) {
        # Act
        $outcome = Invoke-Case -Prompt $Prompt -Map @{ $script:SessionPath = $script:Valid; $script:ItemPath = $script:Valid }

        # Assert
        $outcome.Result.Ok | Should -BeFalse
        $outcome.Result.Message | Should -BeLike 'ORCHESTRATOR_CHECKPOINT_UNRESOLVED: orchestrator-state: NoTarget (TARGET_WORKTREE_NOT_DERIVABLE)*'
        $outcome.Read.Count | Should -Be 0
        $outcome.Routed.Count | Should -Be 0
    }

    It 'H6 blocks as Ambiguous without any read (<Label>)' -ForEach @(
        @{ Label = 'two distinct issue lines'; Prompt = "branch: bug/sample-1145`nCanonical issue number for this feature is 1145.`nCanonical issue number for this feature is 1146."; Porcelain = '' }
        @{ Label = 'branch in two worktrees'; Prompt = 'branch: bug/sample-1145'; Porcelain = "worktree /synthetic-worktrees/a`nbranch refs/heads/bug/sample-1145`n`nworktree /synthetic-worktrees/b`nbranch refs/heads/bug/sample-1145`n" }
    ) {
        # Arrange
        $list = if ($Porcelain) { $Porcelain } else { $script:Porcelain }

        # Act
        $outcome = Invoke-Case -Prompt $Prompt -Porcelain $list -Map @{ $script:SessionPath = $script:Valid; $script:ItemPath = $script:Valid }

        # Assert
        $outcome.Result.Ok | Should -BeFalse
        $outcome.Result.Message | Should -BeLike 'ORCHESTRATOR_CHECKPOINT_UNRESOLVED: orchestrator-state: Ambiguous (TARGET_WORKTREE_AMBIGUOUS)*'
        $outcome.Read.Count | Should -Be 0
    }

    It 'H7 places an issue-line-only prompt through the item checkpoint issue and reads the item path' {
        # Arrange
        $itemPath = $script:ItemPath
        Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { param([string] $Path) if ($Path -eq $itemPath) { '{"issue-num":"1145"}' } else { $null } }.GetNewClosure()

        # Act
        $outcome = Invoke-Case -Prompt 'Canonical issue number for this feature is 1145.' -Map @{ $script:ItemPath = $script:Valid }

        # Assert
        $outcome.Result.Ok | Should -BeTrue -Because $outcome.Result.Message
        $outcome.Read | Should -Be @($script:ItemPath)
    }

    It 'H8 validates the session worktree with the failure detail when the resolver throws' {
        # Arrange
        # Issue #1163: the helper resolves through Resolve-AgentTargetWorktree, so the failing collaborator is mocked there; the asserted fallback is unchanged.
        Mock Resolve-AgentTargetWorktree { throw 'synthetic resolver failure' }

        # Act
        $outcome = Invoke-Case -Map @{ $script:SessionPath = $script:Valid; $script:ItemPath = $script:Invalid }

        # Assert
        $outcome.Result.Ok | Should -BeTrue
        $outcome.Read | Should -Be @($script:SessionPath)
        $outcome.Result.Note | Should -BeLike '*target worktree resolution failed*'
    }

    It 'H9 allows the re-entered stop after an Ambiguous block' {
        # Arrange
        $prompt = "branch: bug/sample-1145`nCanonical issue number for this feature is 1145.`nCanonical issue number for this feature is 1146."

        # Act
        $first = Invoke-Case -Prompt $prompt
        $second = Invoke-Case -Prompt $prompt -StopHookActive $true

        # Assert
        $first.Result.Ok | Should -BeFalse
        $first.Result.Message | Should -BeLike '*Report it to the operator and halt.'
        $second.Result.Ok | Should -BeTrue
    }

    It 'H10 does not read the transcript for <ArtifactType>' -ForEach @(
        @{ ArtifactType = 'epic-orchestrator-state'; Leaf = 'artifacts/orchestration/epic-orchestrator-state.json' }
        @{ ArtifactType = 'parallel-orchestrator-state'; Leaf = 'artifacts/orchestration/parallel-orchestrator-state.json' }
    ) {
        # Arrange
        Mock Resolve-OrchestratorOutputCheckpointPath { [pscustomobject]@{ Resolved = $false; CheckpointPath = $null; WorktreeRoot = $null; Status = 'NoTarget'; ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'; Detail = 'synthetic' } }

        # Act
        $outcome = Invoke-Case -ArtifactType $ArtifactType -CheckpointPath $Leaf

        # Assert
        $outcome.ReaderCalls | Should -Be 0
        Should -Invoke Resolve-OrchestratorOutputCheckpointPath -Times 1 -Exactly -ParameterFilter { $null -eq $ItemTarget }
    }

    It 'H11 validates the session checkpoint without a fallback note when the prompt names the session branch' {
        # Act
        $outcome = Invoke-Case -Prompt 'branch: main' -Map @{ $script:SessionPath = $script:Valid; $script:ItemPath = $script:Invalid }

        # Assert
        $outcome.Result.Ok | Should -BeTrue
        $outcome.Read | Should -Be @($script:SessionPath)
        $outcome.Result.Note | Should -BeNullOrEmpty
    }

    It 'H12 runs the feature-folder probe and the runbook check beneath the item root' {
        # Arrange
        $folder = 'docs/features/active/2026-11-08-sample-1145'
        $adoption = '"issue_adoption":{"waived_tools":["potential_to_issue","new_active_feature_folder"]}'
        $interaction = '"human_interaction":{"requirements":[{"response":"exception","runbook_path":"docs/runbooks/item.runbook.md"}]}'
        $text = '{"objective":"run","completed_steps":["S1"],"next_step":"complete","last_updated":"2026-11-08T00:00:00Z","feature-folder":"' + $folder + '",' + $adoption + ',' + $interaction + '}'
        $probed = [System.Collections.Generic.List[string]]::new()
        Mock Test-OrchestratorOutputRunbookFile { param([string] $Path) $probed.Add($Path); $true }.GetNewClosure()

        # Act
        $outcome = Invoke-Case -Map @{ $script:ItemPath = $text }

        # Assert
        $outcome.Result.Ok | Should -BeTrue -Because $outcome.Result.Message
        ($outcome.Git[0] -join '|') | Should -BeExactly ('-C|' + $script:ItemRoot + '|cat-file|-t|HEAD:' + $folder)
        $probed | Should -Be @("$($script:ItemRoot)/docs/runbooks/item.runbook.md")
    }
}

Describe 'validate-orchestrator-output entry tail fallback note (issue #1145)' {
    AfterAll { Reset-EpicStateProbeModuleBinding }

    It 'H13 exits 0 and writes the fallback note to stderr when stdin names no transcript' {
        # Arrange
        $hook = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../.claude/hooks/validate-orchestrator-output.ps1'))
        $valid = $script:Valid
        Mock Import-Module { }
        Mock Resolve-WorktreeOperandTarget { [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = '/synthetic-worktrees/e13'; ReasonCode = $null; Detail = 'synthetic' } }
        Mock Get-CheckpointFileContent { @{ Exists = $true; Content = $valid } }.GetNewClosure()
        Mock Invoke-RoutingContractValidation { @{ HasErrors = $false; ErrorText = '' } }
        $priorIn = [System.Console]::In
        $priorError = [System.Console]::Error
        $errorWriter = [System.IO.StringWriter]::new()
        $thrown = $null

        # Act
        try {
            [System.Console]::SetIn([System.IO.StringReader]::new('{"last_assistant_message":"Final summary."}'))
            [System.Console]::SetError($errorWriter)
            $global:LASTEXITCODE = 0
            try { $null = & $hook } catch { $thrown = $_ }
            $exitCode = $LASTEXITCODE
        }
        finally {
            [System.Console]::SetIn($priorIn)
            [System.Console]::SetError($priorError)
            $global:LASTEXITCODE = 0
            $script:HookDependencyFailures = [System.Collections.Generic.List[object]]::new()
            $script:HookDependencyGuardLoadFailed = $false
        }

        # Assert
        $thrown | Should -BeNullOrEmpty -Because "the hook must not throw ($thrown)"
        $exitCode | Should -Be 0
        $errorWriter.ToString() | Should -BeLike "*$($script:Token)*"
    }
}
