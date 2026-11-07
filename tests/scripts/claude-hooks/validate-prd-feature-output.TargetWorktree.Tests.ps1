#Requires -Version 7.0
<#
.SYNOPSIS
    Item-worktree resolution of spec-path and research-path in
    .claude/hooks/validate-prd-feature-output.ps1 (issue #1105).

.DESCRIPTION
    The delegation prompt comes from an in-memory ReadTranscriptHead seam and the registered
    worktrees from an in-memory WorktreeListInvoker seam. File existence and content go through
    Pester mocks of Test-PrdFeatureArtifactFile and Get-PrdFeatureArtifactContent, so no test reads
    or creates a file. Fixture roots are /-rooted forward-slash paths.
#>

BeforeAll {
    . (Join-Path $PSScriptRoot '../../../.claude/hooks/validate-prd-feature-output.ps1')

    $script:SessionRoot = '/synthetic-worktrees/main'
    $script:ItemRoot = '/synthetic-worktrees/main/.claude/worktrees/bug-1105'
    $script:SpecRelative = 'docs/features/active/sample/spec.md'
    $script:ResearchRelative = 'docs/features/active/sample/research/research.2026-11-07T13-55.md'
    $script:SpecItem = "$script:ItemRoot/$script:SpecRelative"
    $script:ResearchItem = "$script:ItemRoot/$script:ResearchRelative"
    $script:NumericSpec = "## Acceptance Criteria`n- [ ] All 12 agent files contain the marker."
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

    function Invoke-PrdFeatureCase {
        # Runs the hook entry function with an envelope advertising the given output text.
        param([string] $Output, [string] $Prompt = "Canonical issue number for this feature is 1105.`nbranch: bug/sample-1105")
        $raw = [ordered]@{
            session_id = 'tw-1105'; hook_event_name = 'SubagentStop'; agent_type = 'prd-feature'; stop_hook_active = $false
            agent_transcript_path = 'transcripts/subagents/agent-1105.jsonl'; last_assistant_message = $Output
        } | ConvertTo-Json -Compress
        return Invoke-PrdFeatureOutputValidation -InputText $raw -SessionRoot $script:SessionRoot -ReadTranscriptHead (Get-TranscriptReader -Prompt $Prompt) -WorktreeListInvoker $script:ListInvoker
    }
}

Describe 'validate-prd-feature-output spec-path and research-path target worktree (issue #1105)' {
    BeforeEach {
        Mock Test-NumericDerivationEvidence { @{ Ok = $true; Message = $null } }
    }

    It 'finds item-only spec and research files and runs the numeric-criterion check on item content' {
        # Arrange
        Mock Test-PrdFeatureArtifactFile { param([string] $Path) $Path -in @($script:SpecItem, $script:ResearchItem) }
        Mock Get-PrdFeatureArtifactContent { param([string] $Path) if ($Path -eq $script:SpecItem) { $script:NumericSpec } else { 'item research body' } }
        Mock Test-SpecNumericCriterion { $true }

        # Act
        $result = Invoke-PrdFeatureCase -Output "spec-path: $script:SpecRelative`nresearch-path: $script:ResearchRelative"

        # Assert
        $result.Ok | Should -BeTrue
        Should -Invoke Test-SpecNumericCriterion -Times 1 -Exactly -ParameterFilter { $SpecContent -eq $script:NumericSpec }
        Should -Invoke Test-NumericDerivationEvidence -Times 1 -Exactly -ParameterFilter { $Content -eq 'item research body' }
    }

    It 'blocks a main-only spec with the probed item location and resolver source without reading the main checkout' {
        # Arrange
        Mock Test-PrdFeatureArtifactFile { param([string] $Path) $Path -eq $script:SpecRelative }
        Mock Get-PrdFeatureArtifactContent { 'main spec' }

        # Act
        $result = Invoke-PrdFeatureCase -Output "spec-path: $script:SpecRelative"

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message | Should -BeLike "prd-feature hook: spec-path is required and must exist. Probed location: '$script:SpecItem' (item worktree resolved by DelegationPrompt)*"
        Should -Invoke Test-PrdFeatureArtifactFile -Times 0 -Exactly -ParameterFilter { $Path -eq $script:SpecRelative }
        Should -Invoke Get-PrdFeatureArtifactContent -Times 0 -Exactly
    }

    It 'blocks a main-only research file with the probed item location' {
        # Arrange
        Mock Test-PrdFeatureArtifactFile { param([string] $Path) $Path -in @($script:SpecItem, $script:ResearchRelative) }
        Mock Get-PrdFeatureArtifactContent { $script:NumericSpec }

        # Act
        $result = Invoke-PrdFeatureCase -Output "spec-path: $script:SpecRelative`nresearch-path: $script:ResearchRelative"

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message | Should -BeLike "prd-feature hook: numeric acceptance criterion requires an existing research-path. Probed location: '$script:ResearchItem'*"
        Should -Invoke Get-PrdFeatureArtifactContent -Times 0 -Exactly -ParameterFilter { $Path -eq $script:ResearchRelative }
    }

    It 'reads only the item copies when both checkouts hold the spec and research files' {
        # Arrange
        Mock Test-PrdFeatureArtifactFile { $true }
        Mock Get-PrdFeatureArtifactContent { param([string] $Path) if ($Path -eq $script:SpecItem) { $script:NumericSpec } else { 'research body' } }

        # Act
        $result = Invoke-PrdFeatureCase -Output "spec-path: $script:SpecRelative`nresearch-path: $script:ResearchRelative"

        # Assert
        $result.Ok | Should -BeTrue
        Should -Invoke Get-PrdFeatureArtifactContent -Times 2 -Exactly
        Should -Invoke Get-PrdFeatureArtifactContent -Times 0 -Exactly -ParameterFilter { $Path -notlike "$script:ItemRoot/*" }
    }

    It 'accepts an absolute spec-path inside the item worktree' {
        # Arrange
        Mock Test-PrdFeatureArtifactFile { param([string] $Path) $Path -eq $script:SpecItem }
        Mock Get-PrdFeatureArtifactContent { "## Acceptance Criteria`n- [ ] A textual criterion" }

        # Act
        $result = Invoke-PrdFeatureCase -Output "spec-path: $script:SpecItem" -Prompt 'no identity'

        # Assert
        $result.Ok | Should -BeTrue
        Should -Invoke Get-PrdFeatureArtifactContent -Times 1 -Exactly -ParameterFilter { $Path -eq $script:SpecItem }
    }

    It 'probes an absolute spec-path outside every registered worktree as given and blocks when it is absent' {
        # Arrange
        Mock Test-PrdFeatureArtifactFile { $false }

        # Act
        $result = Invoke-PrdFeatureCase -Output "spec-path: /elsewhere/$script:SpecRelative" -Prompt 'no identity'

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message | Should -Be 'prd-feature hook: spec-path is required and must exist.'
        Should -Invoke Test-PrdFeatureArtifactFile -Times 1 -Exactly -ParameterFilter { $Path -eq "/elsewhere/$script:SpecRelative" }
    }

    It 'falls back to the session root with TARGET_WORKTREE_NOT_DERIVABLE in the block message' {
        # Arrange
        Mock Test-PrdFeatureArtifactFile { $false }

        # Act
        $result = Invoke-PrdFeatureCase -Output "spec-path: $script:SpecRelative" -Prompt 'branch: bug/unknown-branch'

        # Assert
        $result.Message | Should -BeLike '*TARGET_WORKTREE_NOT_DERIVABLE*the session root was probed.'
        Should -Invoke Test-PrdFeatureArtifactFile -Times 1 -Exactly -ParameterFilter { $Path -eq $script:SpecRelative }
    }

    It 'falls back to the session root with TARGET_WORKTREE_AMBIGUOUS in the block message' {
        # Arrange
        Mock Test-PrdFeatureArtifactFile { $false }

        # Act
        $result = Invoke-PrdFeatureCase -Output "spec-path: $script:SpecRelative" -Prompt "Canonical issue number for this feature is 1105.`nCanonical issue number for this feature is 1106."

        # Assert
        $result.Message | Should -BeLike '*TARGET_WORKTREE_AMBIGUOUS*the session root was probed.'
        Should -Invoke Test-PrdFeatureArtifactFile -Times 1 -Exactly -ParameterFilter { $Path -eq $script:SpecRelative }
    }

    It 'routes the named file seams through the same cmdlet calls' {
        # Arrange
        Mock Test-Path { $true } -ParameterFilter { $LiteralPath -eq '/synthetic-worktrees/main/x.md' }
        Mock Get-Content { 'seam text' } -ParameterFilter { $LiteralPath -eq '/synthetic-worktrees/main/x.md' }

        # Act and Assert
        Test-PrdFeatureArtifactFile -Path '/synthetic-worktrees/main/x.md' | Should -BeTrue
        Get-PrdFeatureArtifactContent -Path '/synthetic-worktrees/main/x.md' | Should -Be 'seam text'
    }
}
