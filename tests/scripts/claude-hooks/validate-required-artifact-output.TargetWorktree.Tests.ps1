#Requires -Version 7.0
<#
.SYNOPSIS
    Item-worktree resolution of the prd-feature spec-path registration in
    .claude/hooks/validate-required-artifact-output.ps1 (issue #1105).

.DESCRIPTION
    The delegation prompt comes from an in-memory ReadTranscriptHead seam and the registered
    worktrees from an in-memory WorktreeListInvoker seam. File existence goes through a Pester mock
    of Test-ArtifactFile, so no test reads or creates a file. Fixture roots are /-rooted
    forward-slash paths. The spec string is the prd-feature registration, unchanged.
#>

BeforeAll {
    . (Join-Path $PSScriptRoot '../../../.claude/hooks/validate-required-artifact-output.ps1')
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    Register-EpicStateBaselineMock -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot' -Surface 'Claude'

    $script:SessionRoot = '/synthetic-worktrees/main'
    $script:ItemRoot = '/synthetic-worktrees/main/.claude/worktrees/bug-1105'
    $script:Relative = 'docs/features/active/sample/spec.md'
    $script:ItemPath = "$script:ItemRoot/$script:Relative"
    $script:SpecString = 'spec-path|^docs/features/active/.+/spec\.md$|feature spec artifact'
    $script:Envelope = [pscustomobject]@{ agent_transcript_path = 'transcripts/subagents/agent-1105.jsonl' }
    $porcelainText = @(
        'worktree /synthetic-worktrees/main', 'branch refs/heads/main', '',
        'worktree /synthetic-worktrees/main/.claude/worktrees/bug-1105', 'branch refs/heads/bug/sample-1105', ''
    ) -join "`n"
    $script:ListInvoker = { param($SessionRoot) $null = $SessionRoot; $porcelainText }.GetNewClosure()

    function Get-TranscriptReader {
        # Returns a ReadTranscriptHead seam that serves one user entry with the given prompt text.
        param([string] $Prompt)
        $lines = [string[]]@((@{ type = 'user'; message = @{ role = 'user'; content = $Prompt } } | ConvertTo-Json -Compress -Depth 5))
        return { param([string] $Path) $null = $Path; $lines }.GetNewClosure()
    }

    function Get-RequiredArtifactCase {
        # Runs the decision function for the prd-feature registration with the synthetic seams.
        param([string] $SpecPath, [string] $Prompt = "Canonical issue number for this feature is 1105.`nbranch: bug/sample-1105")
        return Get-RequiredArtifactOutputBlockDecision -AgentOutput "Spec ready.`nspec-path: $SpecPath" -AgentName 'prd-feature' -RequiredArtifact @($script:SpecString) -Envelope $script:Envelope -SessionRoot $script:SessionRoot -ReadTranscriptHead (Get-TranscriptReader -Prompt $Prompt) -WorktreeListInvoker $script:ListInvoker
    }
}

Describe 'epic-state baseline isolation (issue #1105)' {
    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot' }
}

Describe 'validate-required-artifact-output prd-feature spec-path target worktree (issue #1105)' {
    It 'blocks repairably on a spec-path value with a parent segment beneath the item root without probing it' {
        # Arrange
        Mock Test-ArtifactFile { $true }

        # Act
        $result = Get-RequiredArtifactCase -SpecPath 'docs/features/active/../../x/spec.md'

        # Assert
        $result.Ok | Should -BeFalse
        $result.Repairable | Should -BeTrue
        $result.Message | Should -BeLike "prd-feature hook:*spec-path 'docs/features/active/../../x/spec.md' is rejected*'..' segment*"
        Should -Invoke Test-ArtifactFile -Times 0 -Exactly
    }

    It 'finds an item-only spec file through the item root' {
        # Arrange
        Mock Test-ArtifactFile { param([string] $Path) $Path -eq $script:ItemPath }

        # Act
        $result = Get-RequiredArtifactCase -SpecPath $script:Relative

        # Assert
        $result.Ok | Should -BeTrue
        Should -Invoke Test-ArtifactFile -Times 1 -Exactly -ParameterFilter { $Path -eq $script:ItemPath }
    }

    It 'blocks a main-only spec file with the probed item location and resolver source without probing the main checkout' {
        # Arrange
        Mock Test-ArtifactFile { param([string] $Path) $Path -eq $script:Relative }

        # Act
        $result = Get-RequiredArtifactCase -SpecPath $script:Relative

        # Assert
        $result.Ok | Should -BeFalse
        $result.Repairable | Should -BeTrue
        $result.Message | Should -BeLike "*no file exists at that location; Probed location: '$script:ItemPath' (item worktree resolved by DelegationPrompt)"
        Should -Invoke Test-ArtifactFile -Times 0 -Exactly -ParameterFilter { $Path -eq $script:Relative }
    }

    It 'probes only the item copy when both checkouts hold the spec file' {
        # Arrange
        Mock Test-ArtifactFile { $true }

        # Act
        $result = Get-RequiredArtifactCase -SpecPath $script:Relative

        # Assert
        $result.Ok | Should -BeTrue
        Should -Invoke Test-ArtifactFile -Times 1 -Exactly
        Should -Invoke Test-ArtifactFile -Times 1 -Exactly -ParameterFilter { $Path -eq $script:ItemPath }
    }

    It 'passes an absolute spec-path inside the item worktree through the unchanged spec rule after conversion' {
        # Arrange
        Mock Test-ArtifactFile { param([string] $Path) $Path -eq $script:ItemPath }

        # Act
        $result = Get-RequiredArtifactCase -SpecPath $script:ItemPath -Prompt 'no identity'

        # Assert
        $result.Ok | Should -BeTrue
    }

    It 'rejects an absolute spec-path outside every registered worktree through the unchanged spec rule' {
        # Arrange
        Mock Test-ArtifactFile { $true }

        # Act
        $result = Get-RequiredArtifactCase -SpecPath "/elsewhere/$script:Relative" -Prompt 'no identity'

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message | Should -BeLike '*does not match the required location for the feature spec artifact*'
        Should -Invoke Test-ArtifactFile -Times 0 -Exactly
    }

    It 'falls back to the session root with TARGET_WORKTREE_NOT_DERIVABLE in the block message' {
        # Arrange
        Mock Test-ArtifactFile { $false }

        # Act
        $result = Get-RequiredArtifactCase -SpecPath $script:Relative -Prompt 'branch: bug/unknown-branch'

        # Assert
        $result.Message | Should -BeLike '*TARGET_WORKTREE_NOT_DERIVABLE*the session root was probed'
        Should -Invoke Test-ArtifactFile -Times 1 -Exactly -ParameterFilter { $Path -eq $script:Relative }
    }

    It 'falls back to the session root with TARGET_WORKTREE_AMBIGUOUS in the block message' {
        # Arrange
        Mock Test-ArtifactFile { $false }

        # Act
        $result = Get-RequiredArtifactCase -SpecPath $script:Relative -Prompt "Canonical issue number for this feature is 1105.`nCanonical issue number for this feature is 1106."

        # Assert
        $result.Message | Should -BeLike '*TARGET_WORKTREE_AMBIGUOUS*the session root was probed'
        Should -Invoke Test-ArtifactFile -Times 1 -Exactly -ParameterFilter { $Path -eq $script:Relative }
    }

    It 'keeps the session-root message unchanged when no envelope is supplied' {
        # Arrange
        Mock Test-ArtifactFile { $false }

        # Act
        $result = Get-RequiredArtifactOutputBlockDecision -AgentOutput "spec-path: $script:Relative" -AgentName 'prd-feature' -RequiredArtifact @($script:SpecString)

        # Assert
        $result.Message | Should -BeLike "*spec-path '$script:Relative' was advertised for the feature spec artifact but no file exists at that location"
    }
}
