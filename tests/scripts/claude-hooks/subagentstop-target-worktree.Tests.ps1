#Requires -Version 7.0
<#
.SYNOPSIS
    Target-worktree resolution and artifact-path conversion of
    .claude/hooks/subagentstop-target-worktree.ps1 (issue #1105).

.DESCRIPTION
    Transcript lines come from an in-memory ReadTranscriptHead seam and registered worktrees from an
    in-memory WorktreeListInvoker seam, so no test reads a file, runs git, or creates a file. Fixture
    roots are /-rooted forward-slash paths, so the suite runs the same way on Linux and Windows.
#>

BeforeAll {
    . (Join-Path $PSScriptRoot '../../../.claude/hooks/subagentstop-target-worktree.ps1')

    $script:SessionRoot = '/synthetic-worktrees/main'
    $script:ItemRoot = '/synthetic-worktrees/main/.claude/worktrees/bug-1105'
    $script:Porcelain = @(
        'worktree /synthetic-worktrees/main', 'HEAD 1111111111111111111111111111111111111111', 'branch refs/heads/main', '',
        'worktree /synthetic-worktrees/main/.claude/worktrees/bug-1105', 'HEAD 2222222222222222222222222222222222222222', 'branch refs/heads/bug/sample-1105', ''
    ) -join "`n"
    $porcelainText = $script:Porcelain
    $script:ListInvoker = { param($SessionRoot) $null = $SessionRoot; $porcelainText }.GetNewClosure()
    $script:Envelope = [pscustomobject]@{ agent_transcript_path = 'transcripts/subagents/agent-1.jsonl' }

    function Get-TranscriptReader {
        # Returns a ReadTranscriptHead seam that serves one user entry with the given prompt text.
        param([string] $Prompt)
        $lines = [string[]]@(
            (@{ type = 'system'; content = 'session start' } | ConvertTo-Json -Compress -Depth 5),
            (@{ type = 'user'; message = @{ role = 'user'; content = @(@{ type = 'text'; text = $Prompt }) } } | ConvertTo-Json -Compress -Depth 5)
        )
        return { param([string] $Path) $null = $Path; $lines }.GetNewClosure()
    }
}

Describe 'Resolve-SubagentStopTargetWorktree (issue #1105)' {
    It 'reports source FilePath and the item root for an absolute advertised path' {
        # Arrange
        $path = "$script:ItemRoot/docs/features/active/sample/plan.md"

        # Act
        $result = Resolve-SubagentStopTargetWorktree -Envelope $null -AdvertisedPath @($path) -SessionRoot $script:SessionRoot -WorktreeListInvoker $script:ListInvoker

        # Assert
        $result.Source | Should -Be 'FilePath'
        $result.WorktreeRoot | Should -Be $script:ItemRoot
        $result.ReasonCode | Should -BeNullOrEmpty
    }

    It 'reports source DelegationPrompt for a relative path and a prompt carrying a branch label and the canonical issue line' {
        # Arrange
        $reader = Get-TranscriptReader -Prompt "Canonical issue number for this feature is 1105.`nbranch: bug/sample-1105`nExecute the plan."

        # Act
        $result = Resolve-SubagentStopTargetWorktree -Envelope $script:Envelope -AdvertisedPath @('docs/features/active/sample/plan.md') -SessionRoot $script:SessionRoot -ReadTranscriptHead $reader -WorktreeListInvoker $script:ListInvoker

        # Assert
        $result.Source | Should -Be 'DelegationPrompt'
        $result.WorktreeRoot | Should -Be $script:ItemRoot
        $result.ReasonCode | Should -BeNullOrEmpty
    }

    It 'reports source SessionRoot for a relative path when no transcript is named' {
        # Arrange
        $listCalls = [System.Collections.Generic.List[string]]::new()
        $countingInvoker = { param($SessionRoot) $listCalls.Add($SessionRoot); '' }.GetNewClosure()

        # Act
        $result = Resolve-SubagentStopTargetWorktree -Envelope $null -AdvertisedPath @('docs/features/active/sample/plan.md') -SessionRoot $script:SessionRoot -WorktreeListInvoker $countingInvoker

        # Assert
        $result.Source | Should -Be 'SessionRoot'
        $result.WorktreeRoot | Should -Be $script:SessionRoot
        $listCalls.Count | Should -Be 0 -Because 'the session-root case enumerates no worktree'
    }

    It 'reports source SessionRoot when the delegation prompt carries no branch label and no canonical issue line' {
        # Arrange
        $reader = Get-TranscriptReader -Prompt 'Execute the plan.'

        # Act
        $result = Resolve-SubagentStopTargetWorktree -Envelope $script:Envelope -AdvertisedPath @('docs/features/active/sample/plan.md') -SessionRoot $script:SessionRoot -ReadTranscriptHead $reader -WorktreeListInvoker $script:ListInvoker

        # Assert
        $result.Source | Should -Be 'SessionRoot'
        $result.ReasonCode | Should -BeNullOrEmpty
    }

    It 'returns TARGET_WORKTREE_NOT_DERIVABLE with a null root when the prompt branch names no worktree' {
        # Arrange
        $reader = Get-TranscriptReader -Prompt 'branch: bug/unknown-branch'

        # Act
        $result = Resolve-SubagentStopTargetWorktree -Envelope $script:Envelope -AdvertisedPath @('docs/features/active/sample/plan.md') -SessionRoot $script:SessionRoot -ReadTranscriptHead $reader -WorktreeListInvoker $script:ListInvoker

        # Assert
        $result.ReasonCode | Should -Be 'TARGET_WORKTREE_NOT_DERIVABLE'
        $result.Source | Should -Be 'DelegationPrompt'
        $result.WorktreeRoot | Should -BeNullOrEmpty
    }

    It 'returns TARGET_WORKTREE_AMBIGUOUS when the prompt names two different branches' {
        # Arrange
        $reader = Get-TranscriptReader -Prompt "branch: bug/sample-1105`nbranch: main"

        # Act
        $result = Resolve-SubagentStopTargetWorktree -Envelope $script:Envelope -AdvertisedPath @('docs/features/active/sample/plan.md') -SessionRoot $script:SessionRoot -ReadTranscriptHead $reader -WorktreeListInvoker $script:ListInvoker

        # Assert
        $result.ReasonCode | Should -Be 'TARGET_WORKTREE_AMBIGUOUS'
        $result.WorktreeRoot | Should -BeNullOrEmpty
        $result.Detail | Should -Match 'different branches'
    }

    It 'falls back to the session root when the transcript reader throws' {
        # Arrange
        $reader = { param([string] $Path) throw "unreadable transcript $Path" }

        # Act
        $result = Resolve-SubagentStopTargetWorktree -Envelope $script:Envelope -AdvertisedPath @('docs/features/active/sample/plan.md') -SessionRoot $script:SessionRoot -ReadTranscriptHead $reader -WorktreeListInvoker $script:ListInvoker

        # Assert
        $result.Source | Should -Be 'SessionRoot'
        $result.ReasonCode | Should -BeNullOrEmpty
    }

    It 'falls back to the session root when the transcript is missing' {
        # Arrange
        $reader = { param([string] $Path) $null = $Path; $null }

        # Act
        $result = Resolve-SubagentStopTargetWorktree -Envelope $script:Envelope -AdvertisedPath @('docs/features/active/sample/plan.md') -SessionRoot $script:SessionRoot -ReadTranscriptHead $reader -WorktreeListInvoker $script:ListInvoker

        # Assert
        $result.Source | Should -Be 'SessionRoot'
        $result.WorktreeRoot | Should -Be $script:SessionRoot
    }

    It 'reports the session root with a failure detail when resolution throws' {
        # Arrange
        Mock Resolve-HookTargetWorktree { throw 'resolver unavailable' }

        # Act
        $result = Resolve-SubagentStopTargetWorktree -Envelope $null -AdvertisedPath @("$script:ItemRoot/plan.md") -SessionRoot $script:SessionRoot -WorktreeListInvoker $script:ListInvoker

        # Assert
        $result.Source | Should -Be 'SessionRoot'
        $result.WorktreeRoot | Should -Be $script:SessionRoot
        $result.Detail | Should -Match 'resolver unavailable'
    }
}

Describe 'Resolve-SubagentStopArtifactPath (issue #1105)' {
    It 'returns the value unchanged for the session root' {
        Resolve-SubagentStopArtifactPath -Path 'docs/features/active/sample/plan.md' -WorktreeRoot $script:SessionRoot -SessionRoot $script:SessionRoot | Should -Be 'docs/features/active/sample/plan.md'
    }

    It 'returns the value unchanged for a null root' {
        Resolve-SubagentStopArtifactPath -Path 'docs/features/active/sample/plan.md' -WorktreeRoot $null -SessionRoot $script:SessionRoot | Should -Be 'docs/features/active/sample/plan.md'
    }

    It 'joins a relative value beneath an item root with forward slashes' {
        Resolve-SubagentStopArtifactPath -Path '.\docs\features\active\sample\plan.md' -WorktreeRoot $script:ItemRoot -SessionRoot $script:SessionRoot | Should -Be "$script:ItemRoot/docs/features/active/sample/plan.md"
    }

    It 'converts an absolute value inside the item root to repository-relative form' {
        Resolve-SubagentStopArtifactPath -Path "$script:ItemRoot/docs/features/active/sample/plan.md" -WorktreeRoot $script:ItemRoot -SessionRoot $script:SessionRoot | Should -Be 'docs/features/active/sample/plan.md'
    }

    It 'leaves an absolute value outside every worktree unchanged for the shape rules to reject' {
        Resolve-SubagentStopArtifactPath -Path '/elsewhere/docs/features/active/sample/plan.md' -WorktreeRoot $script:ItemRoot -SessionRoot $script:SessionRoot | Should -Be '/elsewhere/docs/features/active/sample/plan.md'
    }

    It 'leaves the item root itself unchanged' {
        Resolve-SubagentStopArtifactPath -Path $script:ItemRoot -WorktreeRoot $script:ItemRoot -SessionRoot $script:SessionRoot | Should -Be $script:ItemRoot
    }
}

Describe 'Resolve-SubagentStopArtifactLocation (issue #1105)' {
    It 'keeps a relative value for the shape rules and probes it beneath the item root' {
        $location = Resolve-SubagentStopArtifactLocation -Path 'docs/features/active/sample/plan.md' -WorktreeRoot $script:ItemRoot -SessionRoot $script:SessionRoot
        $location.RelativePath | Should -Be 'docs/features/active/sample/plan.md'
        $location.ProbePath | Should -Be "$script:ItemRoot/docs/features/active/sample/plan.md"
    }

    It 'converts an absolute value inside the item root and probes the joined path' {
        $location = Resolve-SubagentStopArtifactLocation -Path "$script:ItemRoot/docs/features/active/sample/plan.md" -WorktreeRoot $script:ItemRoot -SessionRoot $script:SessionRoot
        $location.RelativePath | Should -Be 'docs/features/active/sample/plan.md'
        $location.ProbePath | Should -Be "$script:ItemRoot/docs/features/active/sample/plan.md"
    }

    It 'keeps both values unchanged for the session root' {
        $location = Resolve-SubagentStopArtifactLocation -Path "$script:SessionRoot/docs/plan.md" -WorktreeRoot $script:SessionRoot -SessionRoot $script:SessionRoot
        $location.RelativePath | Should -Be "$script:SessionRoot/docs/plan.md"
        $location.ProbePath | Should -Be "$script:SessionRoot/docs/plan.md"
    }
}

Describe 'Get-SubagentStopTargetNote (issue #1105)' {
    It 'returns an empty note for a null target' {
        Get-SubagentStopTargetNote -Target $null -ProbePath 'plan.md' -SessionRoot $script:SessionRoot | Should -Be ''
    }

    It 'returns an empty note for the session root' {
        $target = [pscustomobject]@{ WorktreeRoot = $script:SessionRoot; Source = 'SessionRoot'; ReasonCode = $null; Detail = '' }
        Get-SubagentStopTargetNote -Target $target -ProbePath 'plan.md' -SessionRoot $script:SessionRoot | Should -Be ''
    }

    It 'names the probed location and source for an item root' {
        $target = [pscustomobject]@{ WorktreeRoot = $script:ItemRoot; Source = 'DelegationPrompt'; ReasonCode = $null; Detail = '' }
        $note = Get-SubagentStopTargetNote -Target $target -ProbePath "$script:ItemRoot/plan.md" -SessionRoot $script:SessionRoot
        $note | Should -BeLike "*Probed location: '$script:ItemRoot/plan.md'*"
        $note | Should -BeLike '*DelegationPrompt*'
    }

    It 'names the reason code for a not-derivable resolution' {
        $target = [pscustomobject]@{ WorktreeRoot = $null; Source = 'DelegationPrompt'; ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'; Detail = 'no match' }
        Get-SubagentStopTargetNote -Target $target -ProbePath 'plan.md' -SessionRoot $script:SessionRoot | Should -BeLike '*TARGET_WORKTREE_NOT_DERIVABLE*session root was probed*'
    }
}

Describe 'moved transcript readers (issue #1105)' {
    It 'expands a leading tilde in the envelope transcript path' {
        $path = Get-TranscriptPathFromEnvelope -Envelope ([pscustomobject]@{ agent_transcript_path = '~/t.jsonl' })
        $path | Should -Be ($HOME + '/t.jsonl')
    }

    It 'returns null for an envelope without a transcript path' {
        Get-TranscriptPathFromEnvelope -Envelope ([pscustomobject]@{ other = 1 }) | Should -BeNullOrEmpty
    }

    It 'reads string content from the first user entry and skips unparseable lines' {
        $lines = [string[]]@('not json', '', (@{ type = 'user'; content = 'plain prompt' } | ConvertTo-Json -Compress))
        Get-TranscriptFirstUserText -Lines $lines | Should -Be 'plain prompt'
    }

    It 'returns null when no user entry carries text' {
        $lines = [string[]]@((@{ type = 'user'; message = @{ content = @(@{ type = 'image' }) } } | ConvertTo-Json -Compress -Depth 5))
        Get-TranscriptFirstUserText -Lines $lines | Should -BeNullOrEmpty
    }

    It 'returns null from Read-TranscriptHead when no file exists at the path' {
        Mock Test-Path { $false }
        Read-TranscriptHead -Path '/synthetic-worktrees/main/missing.jsonl' | Should -BeNullOrEmpty
    }

    It 'returns the first lines from Read-TranscriptHead through the file read' {
        Mock Test-Path { $true }
        Mock Get-Content { @('line one', 'line two') }
        $head = Read-TranscriptHead -Path '/synthetic-worktrees/main/present.jsonl'
        $head.Count | Should -Be 2
        Should -Invoke Get-Content -Times 1 -Exactly -ParameterFilter { $TotalCount -eq 50 }
    }
}
