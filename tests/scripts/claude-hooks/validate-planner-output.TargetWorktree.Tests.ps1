#Requires -Version 7.0
<#
.SYNOPSIS
    Item-worktree resolution of plan-path in .claude/hooks/validate-planner-output.ps1 (issue #1105).

.DESCRIPTION
    The delegation prompt comes from an in-memory ReadTranscriptHead seam and the registered
    worktrees from an in-memory WorktreeListInvoker seam. Plan content goes through a Pester mock of
    Get-PlanFileContent, so no test reads or creates a file. Fixture roots are /-rooted
    forward-slash paths.
#>

BeforeAll {
    . (Join-Path $PSScriptRoot '../../../.claude/hooks/validate-planner-output.ps1')
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    Register-EpicStateBaselineMock -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot' -Surface 'Claude'

    $script:SessionRoot = '/synthetic-worktrees/main'
    $script:ItemRoot = '/synthetic-worktrees/main/.claude/worktrees/bug-1105'
    $script:Relative = 'docs/features/active/sample/plan.2026-11-07T08-48.md'
    $script:ItemPath = "$script:ItemRoot/$script:Relative"
    $script:Envelope = [pscustomobject]@{ agent_transcript_path = 'transcripts/subagents/agent-1105.jsonl' }
    $script:ItemLines = [string[]]@('### Phase 0 - Item plan', '- [ ] [P0-T1] Item task.')
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

    function Get-PlannerCase {
        # Runs the decision function for the given plan-path with the synthetic seams.
        param([string] $PlanPath, [string] $Prompt = "Canonical issue number for this feature is 1105.`nbranch: bug/sample-1105")
        return Get-PlannerOutputBlockDecision -AgentOutput "PREFLIGHT: ALL CLEAR`nplan-path: $PlanPath" -Envelope $script:Envelope -SessionRoot $script:SessionRoot -ReadTranscriptHead (Get-TranscriptReader -Prompt $Prompt) -WorktreeListInvoker $script:ListInvoker
    }
}

Describe 'epic-state baseline isolation (issue #1105)' {
    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot' }
}

Describe 'validate-planner-output plan-path target worktree (issue #1105)' {
    BeforeEach {
        Mock Get-PlanStructureValidationReport { [string[]]@() }
        Mock Test-PreMortemSection { @{ Ok = $true; Message = $null } }
        Mock Get-PlannerInternalReviewValidation { @{ Ok = $true; Message = $null } }
    }

    It 'reads an item-only plan and runs the plan-structure, Pre-Mortem, and planner-internal-review checks on item content' {
        # Arrange
        Mock Get-PlanFileContent { param([string] $Path) if ($Path -eq $script:ItemPath) { @{ Exists = $true; Lines = $script:ItemLines } } else { @{ Exists = $false; Lines = @() } } }

        # Act
        $result = Get-PlannerCase -PlanPath $script:Relative

        # Assert
        $result.Ok | Should -BeTrue
        Should -Invoke Get-PlanStructureValidationReport -Times 1 -Exactly -ParameterFilter { $Lines[0] -eq '### Phase 0 - Item plan' }
        Should -Invoke Test-PreMortemSection -Times 1 -Exactly -ParameterFilter { $Content -like '### Phase 0 - Item plan*' }
        Should -Invoke Get-PlannerInternalReviewValidation -Times 1 -Exactly
    }

    It 'blocks a main-only plan with the probed item location and resolver source without reading the main checkout' {
        # Arrange
        Mock Get-PlanFileContent { param([string] $Path) @{ Exists = ($Path -eq $script:Relative); Lines = @('main plan') } }

        # Act
        $result = Get-PlannerCase -PlanPath $script:Relative

        # Assert
        $result.Ok | Should -BeFalse
        $result.Repairable | Should -BeTrue
        $result.Message | Should -BeLike "*no file exists at that location. Probed location: '$script:ItemPath' (item worktree resolved by DelegationPrompt)."
        Should -Invoke Get-PlanFileContent -Times 0 -Exactly -ParameterFilter { $Path -eq $script:Relative }
        Should -Invoke Get-PlanStructureValidationReport -Times 0 -Exactly
    }

    It 'reads only the item copy when both checkouts hold the plan' {
        # Arrange
        Mock Get-PlanFileContent { param([string] $Path) if ($Path -eq $script:ItemPath) { @{ Exists = $true; Lines = $script:ItemLines } } else { @{ Exists = $true; Lines = @('main plan') } } }

        # Act
        $result = Get-PlannerCase -PlanPath $script:Relative

        # Assert
        $result.Ok | Should -BeTrue
        Should -Invoke Get-PlanFileContent -Times 1 -Exactly
        Should -Invoke Get-PlanFileContent -Times 1 -Exactly -ParameterFilter { $Path -eq $script:ItemPath }
    }

    It 'accepts an absolute plan-path inside the item worktree' {
        # Arrange
        Mock Get-PlanFileContent { param([string] $Path) @{ Exists = ($Path -eq $script:ItemPath); Lines = $script:ItemLines } }

        # Act
        $result = Get-PlannerCase -PlanPath $script:ItemPath -Prompt 'no identity'

        # Assert
        $result.Ok | Should -BeTrue
    }

    It 'probes an absolute plan-path outside every registered worktree as given and blocks without a probe note' {
        # Arrange
        Mock Get-PlanFileContent { @{ Exists = $false; Lines = @() } }

        # Act
        $result = Get-PlannerCase -PlanPath "/elsewhere/$script:Relative" -Prompt 'no identity'

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message | Should -Be "atomic-planner hook: planner advertised plan-path '/elsewhere/$script:Relative' but no file exists at that location."
        Should -Invoke Get-PlanFileContent -Times 1 -Exactly -ParameterFilter { $Path -eq "/elsewhere/$script:Relative" }
    }

    It 'falls back to the session root with TARGET_WORKTREE_NOT_DERIVABLE in the block message' {
        # Arrange
        Mock Get-PlanFileContent { @{ Exists = $false; Lines = @() } }

        # Act
        $result = Get-PlannerCase -PlanPath $script:Relative -Prompt 'branch: bug/unknown-branch'

        # Assert
        $result.Message | Should -BeLike '*TARGET_WORKTREE_NOT_DERIVABLE*the session root was probed.'
        Should -Invoke Get-PlanFileContent -Times 1 -Exactly -ParameterFilter { $Path -eq $script:Relative }
    }

    It 'falls back to the session root with TARGET_WORKTREE_AMBIGUOUS in the block message' {
        # Arrange
        Mock Get-PlanFileContent { @{ Exists = $false; Lines = @() } }

        # Act
        $result = Get-PlannerCase -PlanPath $script:Relative -Prompt "Canonical issue number for this feature is 1105.`nCanonical issue number for this feature is 1106."

        # Assert
        $result.Message | Should -BeLike '*TARGET_WORKTREE_AMBIGUOUS*the session root was probed.'
        Should -Invoke Get-PlanFileContent -Times 1 -Exactly -ParameterFilter { $Path -eq $script:Relative }
    }

    It 'blocks repairably on a plan-path value with a parent segment beneath the item root without reading it' {
        # Arrange
        Mock Get-PlanFileContent { @{ Exists = $true; Lines = $script:ItemLines } }

        # Act
        $result = Get-PlannerCase -PlanPath 'docs/features/active/../../x/plan.md'

        # Assert
        $result.Ok | Should -BeFalse
        $result.Repairable | Should -BeTrue
        $result.Message | Should -BeLike "*plan-path 'docs/features/active/../../x/plan.md'*'..' segment*"
        Should -Invoke Get-PlanFileContent -Times 0 -Exactly
    }

    It 'reads only the item copy when a later label names the base branch' {
        # Arrange
        Mock Get-PlanFileContent { param([string] $Path) if ($Path -eq $script:ItemPath) { @{ Exists = $true; Lines = $script:ItemLines } } else { @{ Exists = $true; Lines = @('main plan') } } }

        # Act
        $result = Get-PlannerCase -PlanPath $script:Relative -Prompt "branch: bug/sample-1105`nbase branch: main"

        # Assert
        $result.Ok | Should -BeTrue
        Should -Invoke Get-PlanFileContent -Times 1 -Exactly -ParameterFilter { $Path -eq $script:ItemPath }
        Should -Invoke Get-PlanFileContent -Times 0 -Exactly -ParameterFilter { $Path -eq $script:Relative }
    }
}
