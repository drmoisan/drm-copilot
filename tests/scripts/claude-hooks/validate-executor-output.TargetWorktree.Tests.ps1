#Requires -Version 7.0
<#
.SYNOPSIS
    Item-worktree resolution of plan-path and preflight-fix-record in
    .claude/hooks/validate-executor-output.ps1 (issue #1105).

.DESCRIPTION
    The delegation prompt comes from an in-memory ReadTranscriptHead seam and the registered
    worktrees from an in-memory WorktreeListInvoker seam. Plan content and fix-record existence go
    through Pester mocks of Get-PlanFileContent and Test-PreflightFixRecord, so no test reads or
    creates a file. Fixture roots are /-rooted forward-slash paths.
#>

BeforeAll {
    . (Join-Path $PSScriptRoot '../../../.claude/hooks/validate-executor-output.ps1')

    $script:SessionRoot = '/synthetic-worktrees/main'
    $script:ItemRoot = '/synthetic-worktrees/main/.claude/worktrees/bug-1105'
    $script:PlanRelative = 'docs/features/active/sample/plan.2026-11-07T08-48.md'
    $script:PlanItem = "$script:ItemRoot/$script:PlanRelative"
    $script:RecordRelative = 'docs/features/active/sample/evidence/other/preflight-fixes.2026-11-07T14-27.md'
    $script:RecordItem = "$script:ItemRoot/$script:RecordRelative"
    $script:Identity = "Canonical issue number for this feature is 1105.`nbranch: bug/sample-1105"
    $script:CheckedPlan = [string[]]@('### Phase 0 - Item plan', '- [x] [P0-T1] Item task for `docs/features/active/sample/spec.md`.')
    $script:CompleteOutput = "Done. AC Status Summary: complete. Commands Run: git status. Markdown PASS."
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

    function Get-ExecutorCase {
        # Runs the decision function for the given output with the synthetic seams.
        param([string] $Output, [string] $Prompt = $script:Identity)
        return Get-ExecutorOutputBlockDecision -AgentOutput $Output -TranscriptPath 'transcripts/subagents/agent-1105.jsonl' -ReadTranscriptHead (Get-TranscriptReader -Prompt $Prompt) -SessionRoot $script:SessionRoot -WorktreeListInvoker $script:ListInvoker
    }
}

Describe 'validate-executor-output plan-path target worktree (issue #1105)' {
    It 'reads an item-only plan and completes against item content' {
        # Arrange
        Mock Get-PlanFileContent { param([string] $Path) @{ Exists = ($Path -eq $script:PlanItem); Lines = $script:CheckedPlan } }

        # Act
        $result = Get-ExecutorCase -Output "plan-path: $script:PlanRelative`n$script:CompleteOutput"

        # Assert
        $result.Ok | Should -BeTrue
        Should -Invoke Get-PlanFileContent -Times 1 -Exactly -ParameterFilter { $Path -eq $script:PlanItem }
    }

    It 'blocks a main-only plan with the probed item location and resolver source without reading the main checkout' {
        # Arrange
        Mock Get-PlanFileContent { param([string] $Path) @{ Exists = ($Path -eq $script:PlanRelative); Lines = $script:CheckedPlan } }

        # Act
        $result = Get-ExecutorCase -Output "plan-path: $script:PlanRelative`n$script:CompleteOutput"

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message | Should -BeLike "*no file exists at that location. Probed location: '$script:PlanItem' (item worktree resolved by DelegationPrompt)."
        Should -Invoke Get-PlanFileContent -Times 0 -Exactly -ParameterFilter { $Path -eq $script:PlanRelative }
    }

    It 'reads only the item plan when both checkouts hold it' {
        # Arrange
        Mock Get-PlanFileContent { param([string] $Path) if ($Path -eq $script:PlanItem) { @{ Exists = $true; Lines = $script:CheckedPlan } } else { @{ Exists = $true; Lines = [string[]]@('- [ ] [P0-T1] main task') } } }

        # Act
        $result = Get-ExecutorCase -Output "plan-path: $script:PlanRelative`n$script:CompleteOutput"

        # Assert
        $result.Ok | Should -BeTrue
        Should -Invoke Get-PlanFileContent -Times 1 -Exactly
    }

    It 'accepts an absolute plan-path inside the item worktree' {
        # Arrange
        Mock Get-PlanFileContent { param([string] $Path) @{ Exists = ($Path -eq $script:PlanItem); Lines = $script:CheckedPlan } }

        # Act
        $result = Get-ExecutorCase -Output "plan-path: $script:PlanItem`n$script:CompleteOutput" -Prompt 'no identity'

        # Assert
        $result.Ok | Should -BeTrue
    }

    It 'probes an absolute plan-path outside every registered worktree as given' {
        # Arrange
        Mock Get-PlanFileContent { @{ Exists = $false; Lines = @() } }

        # Act
        $result = Get-ExecutorCase -Output "plan-path: /elsewhere/$script:PlanRelative`n$script:CompleteOutput" -Prompt 'no identity'

        # Assert
        $result.Message | Should -Be "atomic-executor hook: executor advertised plan-path '/elsewhere/$script:PlanRelative' but no file exists at that location."
        Should -Invoke Get-PlanFileContent -Times 1 -Exactly -ParameterFilter { $Path -eq "/elsewhere/$script:PlanRelative" }
    }

    It 'falls back to the session root with TARGET_WORKTREE_NOT_DERIVABLE in the plan block message' {
        # Arrange
        Mock Get-PlanFileContent { @{ Exists = $false; Lines = @() } }

        # Act
        $result = Get-ExecutorCase -Output "plan-path: $script:PlanRelative" -Prompt 'branch: bug/unknown-branch'

        # Assert
        $result.Message | Should -BeLike '*TARGET_WORKTREE_NOT_DERIVABLE*the session root was probed.'
        Should -Invoke Get-PlanFileContent -Times 1 -Exactly -ParameterFilter { $Path -eq $script:PlanRelative }
    }

    It 'falls back to the session root with TARGET_WORKTREE_AMBIGUOUS in the plan block message' {
        # Arrange
        Mock Get-PlanFileContent { @{ Exists = $false; Lines = @() } }

        # Act
        $result = Get-ExecutorCase -Output "plan-path: $script:PlanRelative" -Prompt "branch: bug/sample-1105`nbranch: main"

        # Assert
        $result.Message | Should -BeLike '*TARGET_WORKTREE_AMBIGUOUS*the session root was probed.'
    }
}

Describe 'validate-executor-output preflight-fix-record target worktree (issue #1105)' {
    BeforeAll {
        $script:PreflightPrompt = "DIRECTIVE: PREFLIGHT VALIDATION ONLY`n$script:Identity"
        $script:PreflightOutput = "PREFLIGHT: ALL CLEAR`nCONVERGENCE: NO FURTHER ROUNDS EXPECTED`nPREFLIGHT-FIX: [P1-T1] | typo | fixed`npreflight-fix-record: $script:RecordRelative`nplan-path: $script:PlanRelative"
    }

    BeforeEach {
        Mock Get-PlanFileContent { @{ Exists = $true; Lines = [string[]]@('- [ ] [P0-T1] Task.') } }
    }

    It 'allows the preflight return when the fix record exists only beneath the item root (#1034)' {
        # Arrange
        Mock Test-PreflightFixRecord { param([string] $Path) $Path -eq $script:RecordItem }

        # Act
        $result = Get-ExecutorCase -Output $script:PreflightOutput -Prompt $script:PreflightPrompt

        # Assert
        $result.Ok | Should -BeTrue
        Should -Invoke Test-PreflightFixRecord -Times 1 -Exactly -ParameterFilter { $Path -eq $script:RecordItem }
    }

    It 'blocks a main-only fix record with the probed item location without probing the main checkout' {
        # Arrange
        Mock Test-PreflightFixRecord { param([string] $Path) $Path -eq $script:RecordRelative }

        # Act
        $result = Get-ExecutorCase -Output $script:PreflightOutput -Prompt $script:PreflightPrompt

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message | Should -BeLike "*naming an existing record under docs/features/. Probed location: '$script:RecordItem'*"
        Should -Invoke Test-PreflightFixRecord -Times 0 -Exactly -ParameterFilter { $Path -eq $script:RecordRelative }
    }

    It 'probes only the item fix record when both checkouts hold it' {
        # Arrange
        Mock Test-PreflightFixRecord { $true }

        # Act
        $result = Get-ExecutorCase -Output $script:PreflightOutput -Prompt $script:PreflightPrompt

        # Assert
        $result.Ok | Should -BeTrue
        Should -Invoke Test-PreflightFixRecord -Times 1 -Exactly -ParameterFilter { $Path -eq $script:RecordItem }
    }

    It 'accepts an absolute fix-record path inside the item worktree under the docs/features rule' {
        # Arrange
        Mock Test-PreflightFixRecord { param([string] $Path) $Path -eq $script:RecordItem }
        $output = $script:PreflightOutput.Replace("preflight-fix-record: $script:RecordRelative", "preflight-fix-record: $script:RecordItem")

        # Act
        $result = Get-ExecutorCase -Output $output -Prompt 'DIRECTIVE: PREFLIGHT VALIDATION ONLY'

        # Assert
        $result.Ok | Should -BeTrue
    }

    It 'rejects an absolute fix-record path outside every registered worktree through the docs/features rule' {
        # Arrange
        Mock Test-PreflightFixRecord { $true }
        $output = $script:PreflightOutput.Replace("preflight-fix-record: $script:RecordRelative", "preflight-fix-record: /elsewhere/$script:RecordRelative")

        # Act
        $result = Get-ExecutorCase -Output $output -Prompt 'DIRECTIVE: PREFLIGHT VALIDATION ONLY'

        # Assert
        $result.Ok | Should -BeFalse
        Should -Invoke Test-PreflightFixRecord -Times 0 -Exactly
    }

    It 'probes the session-root fix record and names TARGET_WORKTREE_NOT_DERIVABLE when the branch names no worktree' {
        # Arrange
        Mock Test-PreflightFixRecord { $false }

        # Act
        $result = Get-ExecutorCase -Output $script:PreflightOutput -Prompt "DIRECTIVE: PREFLIGHT VALIDATION ONLY`nbranch: bug/unknown-branch"

        # Assert
        $result.Message | Should -BeLike '*TARGET_WORKTREE_NOT_DERIVABLE*the session root was probed.'
        Should -Invoke Test-PreflightFixRecord -Times 1 -Exactly -ParameterFilter { $Path -eq $script:RecordRelative }
    }

    It 'probes the session-root fix record and names TARGET_WORKTREE_AMBIGUOUS when the prompt names two branches' {
        # Arrange
        Mock Test-PreflightFixRecord { $false }

        # Act
        $result = Get-ExecutorCase -Output $script:PreflightOutput -Prompt "DIRECTIVE: PREFLIGHT VALIDATION ONLY`nbranch: bug/sample-1105`nbranch: main"

        # Assert
        $result.Message | Should -BeLike '*TARGET_WORKTREE_AMBIGUOUS*the session root was probed.'
        Should -Invoke Test-PreflightFixRecord -Times 1 -Exactly -ParameterFilter { $Path -eq $script:RecordRelative }
    }
}
