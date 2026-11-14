#Requires -Version 7.0
<#
.SYNOPSIS
    Item-worktree resolution of research-path in .claude/hooks/validate-task-researcher-output.ps1
    (issue #1105).

.DESCRIPTION
    The delegation prompt comes from an in-memory ReadTranscriptHead seam and the registered
    worktrees from an in-memory WorktreeListInvoker seam. File existence and content go through
    Pester mocks of Test-ResearchFile and Get-ResearchFileContent, so no test reads or creates a
    file. Fixture roots are /-rooted forward-slash paths.
#>

BeforeAll {
    . (Join-Path $PSScriptRoot '../../../.claude/hooks/validate-task-researcher-output.ps1')
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    Register-EpicStateBaselineMock -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot' -Surface 'Claude'

    $script:SessionRoot = '/synthetic-worktrees/main'
    $script:ItemRoot = '/synthetic-worktrees/main/.claude/worktrees/bug-1105'
    $script:Relative = 'docs/features/active/sample/research/research.2026-11-07T13-55.md'
    $script:ItemPath = "$script:ItemRoot/$script:Relative"
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

    function Get-ResearcherEnvelopeText {
        # Builds a SubagentStop envelope whose assistant text advertises the given research-path.
        param([string] $ResearchPath)
        return ([ordered]@{
                session_id             = 'tw-1105'
                hook_event_name        = 'SubagentStop'
                agent_type             = 'task-researcher'
                stop_hook_active       = $false
                agent_transcript_path  = 'transcripts/subagents/agent-1105.jsonl'
                last_assistant_message = "Research complete.`nresearch-path: $ResearchPath"
            } | ConvertTo-Json -Compress)
    }

    function Invoke-ResearcherCase {
        # Runs the hook entry function with the synthetic session root and seams.
        param([string] $ResearchPath, [string] $Prompt = "Canonical issue number for this feature is 1105.`nbranch: bug/sample-1105")
        return Invoke-TaskResearcherOutputValidation -InputText (Get-ResearcherEnvelopeText -ResearchPath $ResearchPath) -SessionRoot $script:SessionRoot -ReadTranscriptHead (Get-TranscriptReader -Prompt $Prompt) -WorktreeListInvoker $script:ListInvoker
    }
}

Describe 'epic-state baseline isolation (issue #1105)' {
    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot' }
}

Describe 'validate-task-researcher-output research-path target worktree (issue #1105)' {
    BeforeEach {
        Mock Test-AutomationFeasibilitySection { @{ Ok = $true; Message = $null } }
        Mock Test-NumericDerivationEvidence { @{ Ok = $true; Message = $null } }
        Mock Test-PreMortemSection { @{ Ok = $true; Message = $null } }
    }

    It 'blocks repairably on a research-path value with a parent segment beneath the item root without probing it' {
        # Arrange
        Mock Test-ResearchFile { $true }

        # Act
        $result = Invoke-ResearcherCase -ResearchPath 'docs/research/../../x/2026-11-07T13-55-sample-research.md'

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message | Should -BeLike "task-researcher hook: research-path 'docs/research/../../x/2026-11-07T13-55-sample-research.md'*'..' segment*"
        $result.Message | Should -Not -BeLike '*not repairable*'
        Should -Invoke Test-ResearchFile -Times 0 -Exactly
    }

    It 'finds an item-only research file and runs the feasibility, numeric-evidence, and Pre-Mortem checks on item content' {
        # Arrange
        Mock Test-ResearchFile { param([string] $Path) $Path -eq $script:ItemPath }
        Mock Get-ResearchFileContent { 'item research body' } -ParameterFilter { $Path -eq $script:ItemPath }

        # Act
        $result = Invoke-ResearcherCase -ResearchPath $script:Relative

        # Assert
        $result.Ok | Should -BeTrue
        Should -Invoke Test-AutomationFeasibilitySection -Times 1 -Exactly -ParameterFilter { $ResearchFilePath -eq $script:ItemPath }
        Should -Invoke Test-NumericDerivationEvidence -Times 1 -Exactly -ParameterFilter { $Content -eq 'item research body' }
        Should -Invoke Test-PreMortemSection -Times 1 -Exactly -ParameterFilter { $Content -eq 'item research body' }
    }

    It 'blocks a main-only research file with the probed item location and resolver source without reading the main checkout' {
        # Arrange
        Mock Test-ResearchFile { param([string] $Path) $Path -eq $script:Relative }
        Mock Get-ResearchFileContent { 'main research body' }

        # Act
        $result = Invoke-ResearcherCase -ResearchPath $script:Relative

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message | Should -BeLike "*no file exists at that location. Probed location: '$script:ItemPath' (item worktree resolved by DelegationPrompt)*"
        Should -Invoke Test-ResearchFile -Times 0 -Exactly -ParameterFilter { $Path -eq $script:Relative }
        Should -Invoke Get-ResearchFileContent -Times 0 -Exactly
    }

    It 'reads only the item copy when both checkouts hold the research file' {
        # Arrange
        Mock Test-ResearchFile { $true }
        Mock Get-ResearchFileContent { param([string] $Path) if ($Path -eq $script:ItemPath) { 'item research body' } else { 'main research body' } }

        # Act
        $result = Invoke-ResearcherCase -ResearchPath $script:Relative

        # Assert
        $result.Ok | Should -BeTrue
        Should -Invoke Get-ResearchFileContent -Times 1 -Exactly -ParameterFilter { $Path -eq $script:ItemPath }
        Should -Invoke Get-ResearchFileContent -Times 0 -Exactly -ParameterFilter { $Path -ne $script:ItemPath }
    }

    It 'accepts an absolute research-path inside the item worktree after conversion' {
        # Arrange
        Mock Test-ResearchFile { param([string] $Path) $Path -eq $script:ItemPath }
        Mock Get-ResearchFileContent { 'item research body' }

        # Act
        $result = Invoke-ResearcherCase -ResearchPath $script:ItemPath -Prompt 'no identity'

        # Assert
        $result.Ok | Should -BeTrue
        Should -Invoke Test-PreMortemSection -Times 1 -Exactly
    }

    It 'rejects an absolute research-path outside every registered worktree through the unchanged root rule' {
        # Arrange
        Mock Test-ResearchFile { $true }

        # Act
        $result = Invoke-ResearcherCase -ResearchPath "/elsewhere/$script:Relative" -Prompt 'no identity'

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message | Should -BeLike '*is not under a tracked research root*'
        Should -Invoke Test-ResearchFile -Times 0 -Exactly
    }

    It 'blocks without a probe naming TARGET_WORKTREE_NOT_DERIVABLE when the prompt branch names no worktree' {
        # Arrange (D4: an unresolved present identity never probes the session root)
        Mock Test-ResearchFile { throw 'the research probe must not be called for an unresolved identity' }

        # Act
        $result = Invoke-ResearcherCase -ResearchPath $script:Relative -Prompt 'branch: bug/unknown-branch'

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message | Should -BeLike '*is rejected:*TARGET_WORKTREE_NOT_DERIVABLE*'
        Should -Invoke Test-ResearchFile -Times 0 -Exactly
    }

    It 'blocks without a probe naming TARGET_WORKTREE_AMBIGUOUS when the prompt names two issue numbers' {
        # Arrange (D4: an unresolved present identity never probes the session root)
        Mock Test-ResearchFile { throw 'the research probe must not be called for an unresolved identity' }

        # Act
        $result = Invoke-ResearcherCase -ResearchPath $script:Relative -Prompt "Canonical issue number for this feature is 1105.`nCanonical issue number for this feature is 1106."

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message | Should -BeLike '*is rejected:*TARGET_WORKTREE_AMBIGUOUS*'
        Should -Invoke Test-ResearchFile -Times 0 -Exactly
    }

    It 'keeps the session-root probe when the prompt carries no branch label and no canonical issue line' {
        # Arrange (D5: no identity keeps the session-root fallback)
        Mock Test-ResearchFile { param([string] $Path) $Path -eq $script:Relative }
        Mock Get-ResearchFileContent { 'main research body' }

        # Act
        $result = Invoke-ResearcherCase -ResearchPath $script:Relative -Prompt 'Research the topic.'

        # Assert
        $result.Ok | Should -BeTrue
        Should -Invoke Test-ResearchFile -Times 1 -Exactly -ParameterFilter { $Path -eq $script:Relative }
    }
}
