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
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    Register-EpicStateBaselineMock -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot' -Surface 'Claude'

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

Describe 'epic-state baseline isolation (issue #1105)' {
    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot' }
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

    It 'blocks without a probe naming TARGET_WORKTREE_NOT_DERIVABLE in the plan block message when the prompt branch names no worktree' {
        # Arrange (D4: an unresolved present identity never probes the session root)
        Mock Get-PlanFileContent { throw 'the plan probe must not be called for an unresolved identity' }

        # Act
        $result = Get-ExecutorCase -Output "plan-path: $script:PlanRelative" -Prompt 'branch: bug/unknown-branch'

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message | Should -BeLike "*plan-path '$script:PlanRelative', which is rejected:*TARGET_WORKTREE_NOT_DERIVABLE*"
        Should -Invoke Get-PlanFileContent -Times 0 -Exactly
    }

    It 'blocks without a probe naming TARGET_WORKTREE_AMBIGUOUS in the plan block message when the prompt names two issue numbers' {
        # Arrange (D4: an unresolved present identity never probes the session root)
        Mock Get-PlanFileContent { throw 'the plan probe must not be called for an unresolved identity' }

        # Act
        $result = Get-ExecutorCase -Output "plan-path: $script:PlanRelative" -Prompt "Canonical issue number for this feature is 1105.`nCanonical issue number for this feature is 1106."

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message | Should -BeLike "*plan-path '$script:PlanRelative', which is rejected:*TARGET_WORKTREE_AMBIGUOUS*"
        Should -Invoke Get-PlanFileContent -Times 0 -Exactly
    }

    It 'keeps the session-root plan probe when the prompt carries no branch label and no canonical issue line' {
        # Arrange (D5: no identity keeps the session-root fallback)
        Mock Get-PlanFileContent { param([string] $Path) @{ Exists = ($Path -eq $script:PlanRelative); Lines = $script:CheckedPlan } }

        # Act
        $result = Get-ExecutorCase -Output "plan-path: $script:PlanRelative`n$script:CompleteOutput" -Prompt 'Execute the plan.'

        # Assert
        $result.Ok | Should -BeTrue
        Should -Invoke Get-PlanFileContent -Times 1 -Exactly -ParameterFilter { $Path -eq $script:PlanRelative }
    }

    It 'reads the transcript head once and still classifies the run from the delegation prompt' {
        # Arrange
        Mock Get-PlanFileContent { param([string] $Path) @{ Exists = ($Path -eq $script:PlanItem); Lines = $script:CheckedPlan } }
        $lines = [string[]]@((@{ type = 'user'; message = @{ role = 'user'; content = "DIRECTIVE: PREFLIGHT VALIDATION ONLY`n$script:Identity" } } | ConvertTo-Json -Compress -Depth 5))
        $readCalls = [System.Collections.Generic.List[string]]::new()
        $countingReader = { param([string] $Path) $readCalls.Add($Path); $lines }.GetNewClosure()

        # Act
        $result = Get-ExecutorOutputBlockDecision -AgentOutput "plan-path: $script:PlanRelative`n$script:CompleteOutput" -TranscriptPath 'transcripts/subagents/agent-1105.jsonl' -ReadTranscriptHead $countingReader -SessionRoot $script:SessionRoot -WorktreeListInvoker $script:ListInvoker

        # Assert
        $readCalls.Count | Should -Be 1 -Because 'one invocation reads the transcript head once'
        $result.Ok | Should -BeFalse
        $result.Message | Should -BeLike '*preflight output must include*' -Because 'the prompt directive classifies the run as preflight'
        Should -Invoke Get-PlanFileContent -Times 1 -Exactly -ParameterFilter { $Path -eq $script:PlanItem }
    }

    It 'invokes a throwing transcript reader once and treats the run as having no transcript' {
        # Arrange
        Mock Get-PlanFileContent { param([string] $Path) @{ Exists = ($Path -eq $script:PlanRelative); Lines = $script:CheckedPlan } }
        $readCalls = [System.Collections.Generic.List[string]]::new()
        $throwingReader = { param([string] $Path) $readCalls.Add($Path); throw "unreadable transcript $Path" }.GetNewClosure()

        # Act
        $result = Get-ExecutorOutputBlockDecision -AgentOutput "plan-path: $script:PlanRelative`n$script:CompleteOutput" -TranscriptPath 'transcripts/subagents/agent-1105.jsonl' -ReadTranscriptHead $throwingReader -SessionRoot $script:SessionRoot -WorktreeListInvoker $script:ListInvoker

        # Assert
        $readCalls.Count | Should -Be 1
        $result.Ok | Should -BeTrue -Because $result.Message
        Should -Invoke Get-PlanFileContent -Times 1 -Exactly -ParameterFilter { $Path -eq $script:PlanRelative }
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

    It 'blocks without probing the fix record or the plan and names TARGET_WORKTREE_NOT_DERIVABLE when the branch names no worktree' {
        # Arrange (D4: an unresolved present identity never probes the session root)
        Mock Get-PlanFileContent { throw 'the plan probe must not be called for an unresolved identity' }
        Mock Test-PreflightFixRecord { throw 'the fix-record probe must not be called for an unresolved identity' }

        # Act
        $result = Get-ExecutorCase -Output $script:PreflightOutput -Prompt "DIRECTIVE: PREFLIGHT VALIDATION ONLY`nbranch: bug/unknown-branch"

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message | Should -BeLike '*is rejected:*TARGET_WORKTREE_NOT_DERIVABLE*'
        Should -Invoke Test-PreflightFixRecord -Times 0 -Exactly
        Should -Invoke Get-PlanFileContent -Times 0 -Exactly
    }

    It 'blocks without probing the fix record or the plan and names TARGET_WORKTREE_AMBIGUOUS when the prompt names two issue numbers' {
        # Arrange (D4: an unresolved present identity never probes the session root)
        Mock Get-PlanFileContent { throw 'the plan probe must not be called for an unresolved identity' }
        Mock Test-PreflightFixRecord { throw 'the fix-record probe must not be called for an unresolved identity' }

        # Act
        $result = Get-ExecutorCase -Output $script:PreflightOutput -Prompt "DIRECTIVE: PREFLIGHT VALIDATION ONLY`nCanonical issue number for this feature is 1105.`nCanonical issue number for this feature is 1106."

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message | Should -BeLike '*is rejected:*TARGET_WORKTREE_AMBIGUOUS*'
        Should -Invoke Test-PreflightFixRecord -Times 0 -Exactly
        Should -Invoke Get-PlanFileContent -Times 0 -Exactly
    }

    It 'blocks repairably on a fix-record value with a parent segment beneath the item root without probing it' {
        # Arrange
        Mock Test-PreflightFixRecord { $true }
        $output = $script:PreflightOutput.Replace("preflight-fix-record: $script:RecordRelative", 'preflight-fix-record: docs/features/active/../../x/preflight-fixes.md')

        # Act
        $result = Get-ExecutorCase -Output $output -Prompt $script:PreflightPrompt

        # Assert
        $result.Ok | Should -BeFalse
        $result.Repairable | Should -BeTrue
        $result.Message | Should -BeLike "*preflight-fix-record 'docs/features/active/../../x/preflight-fixes.md'*'..' segment*"
        Should -Invoke Test-PreflightFixRecord -Times 0 -Exactly
    }
}

Describe 'validate-executor-output plan-path parent segment (issue #1105)' {
    It 'blocks repairably on a plan-path value with a parent segment beneath the item root without reading it' {
        # Arrange
        Mock Get-PlanFileContent { @{ Exists = $true; Lines = $script:CheckedPlan } }

        # Act
        $result = Get-ExecutorCase -Output "plan-path: docs/features/active/../../x/plan.md`n$script:CompleteOutput"

        # Assert
        $result.Ok | Should -BeFalse
        $result.Repairable | Should -BeTrue
        $result.Message | Should -BeLike "*plan-path 'docs/features/active/../../x/plan.md'*'..' segment*"
        Should -Invoke Get-PlanFileContent -Times 0 -Exactly
    }
}
