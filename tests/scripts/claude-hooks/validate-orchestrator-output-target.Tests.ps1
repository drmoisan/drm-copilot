#Requires -Version 7.0
<#
.SYNOPSIS
    Pure rows for .claude/hooks/validate-orchestrator-output-target.ps1 (issue #1145).

.DESCRIPTION
    The delegation prompt comes from an in-memory transcript reader and the registered worktrees from
    an in-memory porcelain list, so no row reads or creates a file or starts a process. The session
    fallback target, the resolver, and the writer are in-memory seams or Pester mocks.
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
    $script:Envelope = [pscustomobject]@{ agent_transcript_path = 'transcripts/subagents/agent-1145.jsonl'; last_assistant_message = 'Done.' }
    $porcelainText = @(
        'worktree /synthetic-worktrees/main', 'branch refs/heads/main', '',
        'worktree /synthetic-worktrees/main/.claude/worktrees/bug-1145', 'branch refs/heads/bug/sample-1145', ''
    ) -join "`n"
    $script:ListInvoker = { param($SessionRoot) $null = $SessionRoot; $porcelainText }.GetNewClosure()

    function Get-TranscriptReader {
        # Returns a ReadTranscriptHead seam that serves one user entry with the given prompt text.
        param([string] $Prompt)
        $lines = [string[]]@((@{ type = 'user'; message = @{ role = 'user'; content = $Prompt } } | ConvertTo-Json -Compress -Depth 5))
        return { param([string] $Path) $null = $Path; $lines }.GetNewClosure()
    }

    function Invoke-ItemTarget {
        # Resolves the item target for orchestrator-state with the given envelope and reader.
        param([AllowNull()] [object] $Envelope = $script:Envelope, [scriptblock] $Reader)
        return Resolve-OrchestratorOutputItemTarget -ArtifactType 'orchestrator-state' -Envelope $Envelope -AgentOutput 'Done.' -CheckpointPath $script:Leaf `
            -SessionRoot $script:SessionRoot -ReadTranscriptHead $Reader -WorktreeListInvoker $script:ListInvoker
    }
}

Describe 'epic-state baseline isolation (issue #1145, target sibling)' {
    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }
}

Describe 'Resolve-OrchestratorOutputItemTarget' {
    It 'returns Resolved with the item root for a branch-bearing prompt' {
        # Act
        $target = Invoke-ItemTarget -Reader (Get-TranscriptReader -Prompt 'branch: bug/sample-1145')

        # Assert
        $target.Status | Should -Be 'Resolved'
        $target.WorktreeRoot | Should -Be $script:ItemRoot
        $target.ReasonCode | Should -BeNullOrEmpty
        $target.FallbackApplied | Should -BeFalse
        $target.FallbackNote | Should -Be ''
    }

    It 'returns NoTarget for a branch checked out in no worktree' {
        # Act
        $target = Invoke-ItemTarget -Reader (Get-TranscriptReader -Prompt 'branch: bug/unknown-1145')

        # Assert
        $target.Status | Should -Be 'NoTarget'
        $target.ReasonCode | Should -Be 'TARGET_WORKTREE_NOT_DERIVABLE'
        $target.WorktreeRoot | Should -BeNullOrEmpty
        $target.Detail | Should -BeLike "*bug/unknown-1145*"
    }

    It 'returns Ambiguous for two distinct canonical issue lines' {
        # Act
        $target = Invoke-ItemTarget -Reader (Get-TranscriptReader -Prompt "Canonical issue number for this feature is 1145.`nCanonical issue number for this feature is 1146.")

        # Assert
        $target.Status | Should -Be 'Ambiguous'
        $target.ReasonCode | Should -Be 'TARGET_WORKTREE_AMBIGUOUS'
        $target.WorktreeRoot | Should -BeNullOrEmpty
    }

    It 'returns Fallback when <Label>' -ForEach @(
        @{ Label = 'the envelope names no transcript'; Case = 'NoPath' }
        @{ Label = 'the reader returns null'; Case = 'NullReader' }
        @{ Label = 'the reader throws'; Case = 'ThrowingReader' }
        @{ Label = 'the prompt carries no identity'; Case = 'NoIdentity' }
    ) {
        # Arrange
        $envelope = if ($Case -eq 'NoPath') { [pscustomobject]@{ last_assistant_message = 'Done.' } } else { $script:Envelope }
        $reader = switch ($Case) {
            'NullReader' { { param([string] $Path) $null = $Path; $null } }
            'ThrowingReader' { { param([string] $Path) $null = $Path; throw 'synthetic read failure' } }
            default { Get-TranscriptReader -Prompt 'Run the orchestration.' }
        }

        # Act
        $target = Invoke-ItemTarget -Envelope $envelope -Reader $reader

        # Assert
        $target.Status | Should -Be 'Fallback'
        $target.WorktreeRoot | Should -BeNullOrEmpty
        $target.FallbackNote | Should -Be ''
        $target.FallbackApplied | Should -BeFalse
    }

    It 'returns Fallback with the failure detail when the resolver throws' {
        # Arrange
        Mock Resolve-HookTargetWorktree { throw 'synthetic resolver failure' }

        # Act
        $target = Invoke-ItemTarget -Reader (Get-TranscriptReader -Prompt 'branch: bug/sample-1145')

        # Assert
        $target.Status | Should -Be 'Fallback'
        $target.FallbackNote | Should -BeLike 'target worktree resolution failed: synthetic resolver failure*'
    }

    It 'returns null without resolving for <Label>' -ForEach @(
        @{ Label = 'the epic kind'; ArtifactType = 'epic-orchestrator-state'; Output = 'Done.'; Leaf = 'artifacts/orchestration/epic-orchestrator-state.json' }
        @{ Label = 'the parallel kind'; ArtifactType = 'parallel-orchestrator-state'; Output = 'Done.'; Leaf = 'artifacts/orchestration/parallel-orchestrator-state.json' }
        @{ Label = 'an unsupported kind'; ArtifactType = 'other-state'; Output = 'Done.'; Leaf = 'artifacts/orchestration/orchestrator-state.json' }
        @{ Label = 'blank assistant text'; ArtifactType = 'orchestrator-state'; Output = '  '; Leaf = 'artifacts/orchestration/orchestrator-state.json' }
        @{ Label = 'a rooted leaf'; ArtifactType = 'orchestrator-state'; Output = 'Done.'; Leaf = '/synthetic-worktrees/main/artifacts/orchestration/orchestrator-state.json' }
        @{ Label = 'a parent-escaping leaf'; ArtifactType = 'orchestrator-state'; Output = 'Done.'; Leaf = '../artifacts/orchestration/orchestrator-state.json' }
    ) {
        # Arrange
        Mock Resolve-SubagentStopTargetWorktree { throw 'not reached' }

        # Act
        $target = Resolve-OrchestratorOutputItemTarget -ArtifactType $ArtifactType -Envelope $script:Envelope -AgentOutput $Output -CheckpointPath $Leaf -SessionRoot $script:SessionRoot

        # Assert
        $target | Should -BeNullOrEmpty
        Should -Invoke Resolve-SubagentStopTargetWorktree -Times 0 -Exactly
    }

    It 'forwards the reader and list seams only when they are supplied' {
        # Arrange
        $bound = [System.Collections.Generic.List[string]]::new()
        Mock Resolve-SubagentStopTargetWorktree {
            param($Envelope, $AdvertisedPath, $SessionRoot, $ReadTranscriptHead, $WorktreeListInvoker, $CheckpointIssueReader)
            $null = $Envelope, $AdvertisedPath, $SessionRoot, $CheckpointIssueReader
            $bound.Add(('{0},{1}' -f ($null -ne $ReadTranscriptHead), ($null -ne $WorktreeListInvoker)))
            [pscustomobject]@{ WorktreeRoot = '/synthetic-worktrees/main'; Source = 'SessionRoot'; ReasonCode = $null; Detail = 'x' }
        }.GetNewClosure()

        # Act
        $null = Resolve-OrchestratorOutputItemTarget -ArtifactType 'orchestrator-state' -Envelope $script:Envelope -AgentOutput 'Done.' -CheckpointPath $script:Leaf -SessionRoot $script:SessionRoot
        $null = Invoke-ItemTarget -Reader (Get-TranscriptReader -Prompt 'branch: main')

        # Assert
        $bound[0] | Should -Be 'False,False'
        $bound[1] | Should -Be 'True,True'
    }
}

Describe 'Resolve-OrchestratorOutputItemOperandTarget' {
    BeforeEach {
        Mock Resolve-WorktreeOperandTarget { [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = '/synthetic-worktrees/main'; ReasonCode = $null; Detail = 'synthetic session worktree' } }
    }

    It 'maps Resolved to the item root as OtherWorktree without the fallback' {
        # Arrange
        $item = [pscustomobject]@{ Status = 'Resolved'; WorktreeRoot = "$($script:ItemRoot)/"; ReasonCode = $null; Detail = ''; FallbackNote = ''; FallbackApplied = $false }

        # Act
        $target = Resolve-OrchestratorOutputItemOperandTarget -ItemTarget $item -SessionRoot $script:SessionRoot

        # Assert
        $target.Status | Should -Be 'OtherWorktree'
        $target.WorktreeRoot | Should -Be $script:ItemRoot
        $item.FallbackApplied | Should -BeFalse
        Should -Invoke Resolve-WorktreeOperandTarget -Times 0 -Exactly
    }

    It 'maps Resolved at the session root to SessionRoot' {
        # Arrange
        $item = [pscustomobject]@{ Status = 'Resolved'; WorktreeRoot = $script:SessionRoot; ReasonCode = $null; Detail = ''; FallbackNote = ''; FallbackApplied = $false }

        # Act
        $target = Resolve-OrchestratorOutputItemOperandTarget -ItemTarget $item -SessionRoot $script:SessionRoot

        # Assert
        $target.Status | Should -Be 'SessionRoot'
        $target.WorktreeRoot | Should -Be $script:SessionRoot
    }

    It 'maps <Status> to an unresolved target with the reason code and reads nothing' -ForEach @(
        @{ Status = 'NoTarget'; Code = 'TARGET_WORKTREE_NOT_DERIVABLE' }
        @{ Status = 'Ambiguous'; Code = 'TARGET_WORKTREE_AMBIGUOUS' }
    ) {
        # Arrange
        $item = [pscustomobject]@{ Status = $Status; WorktreeRoot = $null; ReasonCode = $Code; Detail = 'synthetic detail'; FallbackNote = ''; FallbackApplied = $false }

        # Act
        $target = Resolve-OrchestratorOutputItemOperandTarget -ItemTarget $item -SessionRoot $script:SessionRoot

        # Assert
        $target.Status | Should -Be $Status
        $target.ReasonCode | Should -Be $Code
        $target.WorktreeRoot | Should -BeNullOrEmpty
        $target.Detail | Should -BeLike '*synthetic detail'
        $item.FallbackApplied | Should -BeFalse
        Should -Invoke Resolve-WorktreeOperandTarget -Times 0 -Exactly
    }

    It 'maps Fallback to the session worktree and sets FallbackApplied' {
        # Arrange
        $item = [pscustomobject]@{ Status = 'Fallback'; WorktreeRoot = $null; ReasonCode = $null; Detail = 'x'; FallbackNote = ''; FallbackApplied = $false }

        # Act
        $target = Resolve-OrchestratorOutputItemOperandTarget -ItemTarget $item -SessionRoot $script:SessionRoot

        # Assert
        $target.WorktreeRoot | Should -Be '/synthetic-worktrees/main'
        $item.FallbackApplied | Should -BeTrue
        Should -Invoke Resolve-WorktreeOperandTarget -Times 1 -Exactly -ParameterFilter { $Path -eq '' -and $SessionRoot -eq '/synthetic-worktrees/main' }
    }
}

Describe 'Get-OrchestratorOutputFallbackNote' {
    It 'returns an empty string for <Label>' -ForEach @(
        @{ Label = 'a null target'; Applied = $null }
        @{ Label = 'a target without the fallback'; Applied = $false }
    ) {
        # Arrange
        $item = if ($null -eq $Applied) { $null } else { [pscustomobject]@{ FallbackNote = 'detail'; FallbackApplied = $Applied } }

        # Act / Assert
        Get-OrchestratorOutputFallbackNote -ItemTarget $item | Should -Be ''
    }

    It 'returns the token without detail when no failure was recorded' {
        # Act
        $note = Get-OrchestratorOutputFallbackNote -ItemTarget ([pscustomobject]@{ FallbackNote = ''; FallbackApplied = $true })

        # Assert
        $note | Should -BeLike 'ORCHESTRATOR_CHECKPOINT_FALLBACK: *the checkpoint of the session worktree is validated.'
        $note | Should -Not -BeLike '*Detail:*'
    }

    It 'appends the resolver-failure detail when one was recorded' {
        # Act
        $note = Get-OrchestratorOutputFallbackNote -ItemTarget ([pscustomobject]@{ FallbackNote = 'target worktree resolution failed: boom; the session root applies'; FallbackApplied = $true })

        # Assert
        $note | Should -BeLike 'ORCHESTRATOR_CHECKPOINT_FALLBACK: *Detail: target worktree resolution failed: boom; the session root applies.'
    }
}

Describe 'Write-OrchestratorOutputAllowNote' {
    It 'writes a non-empty Note once' {
        # Arrange
        $writer = [System.IO.StringWriter]::new()

        # Act
        Write-OrchestratorOutputAllowNote -Result @{ Ok = $true; Message = $null; Note = 'ORCHESTRATOR_CHECKPOINT_FALLBACK: x' } -Writer $writer

        # Assert
        $writer.ToString() | Should -Be ('ORCHESTRATOR_CHECKPOINT_FALLBACK: x' + [System.Environment]::NewLine)
    }

    It 'writes nothing for <Label>' -ForEach @(
        @{ Label = 'an empty Note'; Result = @{ Ok = $true; Message = $null; Note = '' } }
        @{ Label = 'a result without Note'; Result = @{ Ok = $true; Message = $null } }
        @{ Label = 'a null result'; Result = $null }
    ) {
        # Arrange
        $writer = [System.IO.StringWriter]::new()

        # Act
        Write-OrchestratorOutputAllowNote -Result $Result -Writer $writer

        # Assert
        $writer.ToString() | Should -Be ''
    }
}
