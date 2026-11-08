#Requires -Version 7.0
<#
.SYNOPSIS
    Item-worktree resolution of runbook_path in .claude/hooks/validate-human-exception-runbook-output.ps1
    (issue #1128).

.DESCRIPTION
    The delegation prompt comes from an in-memory ReadTranscriptHead seam and the registered
    worktrees from an in-memory WorktreeListInvoker seam. File existence, content, and the top-level
    listing go through in-memory ReadFile, TestFile, and ListRootFile seams that record every call, so
    no test reads or creates a file. Fixture roots are /-rooted forward-slash paths.
#>

BeforeAll {
    . (Join-Path $PSScriptRoot '../../../.claude/hooks/validate-human-exception-runbook-output.ps1')
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    Register-EpicStateBaselineMock -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot' -Surface 'Claude'

    $script:SessionRoot = '/synthetic-worktrees/main'
    $script:ItemRoot = '/synthetic-worktrees/main/.claude/worktrees/bug-1128'
    $script:Relative = 'docs/features/active/sample/runbooks/package.runbook.md'
    $script:ItemRunbook = "$script:ItemRoot/$script:Relative"
    $script:Prompt = "Canonical issue number for this feature is 1128.`nbranch: bug/sample-1128"
    $script:Fence = [string][char]96 * 3
    $script:Runbook = (@('# Runbook', '', "$($script:Fence)sh", 'python -m nuitka main.py', $script:Fence, '') -join "`n")
    $porcelainText = @(
        'worktree /synthetic-worktrees/main', 'branch refs/heads/main', '',
        'worktree /synthetic-worktrees/main/.claude/worktrees/bug-1128', 'branch refs/heads/bug/sample-1128', ''
    ) -join "`n"
    $script:ListInvoker = { param($SessionRoot) $null = $SessionRoot; $porcelainText }.GetNewClosure()

    function Get-TranscriptReader {
        # Returns a ReadTranscriptHead seam that serves one user entry with the given prompt text.
        param([string] $Prompt)
        $lines = [string[]]@((@{ type = 'user'; message = @{ role = 'user'; content = $Prompt } } | ConvertTo-Json -Compress -Depth 5))
        return { param([string] $Path) $null = $Path; $lines }.GetNewClosure()
    }

    function Invoke-Case {
        # Runs the decision function with in-memory files and returns the result plus the recorded seam calls.
        param([string] $RunbookPath, [hashtable] $File, [string] $Prompt = $script:Prompt)
        $read = [System.Collections.Generic.List[string]]::new()
        $listed = [System.Collections.Generic.List[string]]::new()
        $envelope = ([ordered]@{
                session_id             = 'tw-1128'
                hook_event_name        = 'SubagentStop'
                agent_type             = 'human-exception-runbook'
                stop_hook_active       = $false
                agent_transcript_path  = 'transcripts/subagents/agent-1128.jsonl'
                last_assistant_message = "Done.`nrunbook_path: $RunbookPath"
            } | ConvertTo-Json -Compress)
        $result = Get-HumanExceptionRunbookDecision -InputText $envelope -SessionRoot $script:SessionRoot -ReadTranscriptHead (Get-TranscriptReader -Prompt $Prompt) -WorktreeListInvoker $script:ListInvoker `
            -ReadFile { param($Path) $read.Add($Path); if ($File.ContainsKey($Path)) { $File[$Path] } else { $null } }.GetNewClosure() `
            -TestFile { param($Path) $File.ContainsKey($Path) }.GetNewClosure() `
            -ListRootFile { param($Root) $listed.Add($Root); @($File.Keys | Where-Object { $_.StartsWith("$Root/") -and -not $_.Substring($Root.Length + 1).Contains('/') } | ForEach-Object { $_.Substring($Root.Length + 1) }) }.GetNewClosure()
        return [pscustomobject]@{ Result = $result; Read = @($read); Listed = @($listed) }
    }
}

Describe 'epic-state baseline isolation (issue #1128)' {
    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot' }
}

Describe 'validate-human-exception-runbook-output runbook_path target worktree (issue #1128)' {
    It 'reads the runbook and the lockfile beneath the item root and lists only the item root' {
        # Arrange
        $file = @{ $script:ItemRunbook = $script:Runbook; "$script:ItemRoot/poetry.lock" = "[[package]]`nname = `"nuitka`"`nversion = `"4.3.4`"`n" }

        # Act
        $outcome = Invoke-Case -RunbookPath $script:Relative -File $file

        # Assert
        $outcome.Result.Ok | Should -BeFalse
        $outcome.Result.Message | Should -BeLike '*nuitka*4.3.4*'
        $outcome.Listed | Should -Be @($script:ItemRoot)
        $outcome.Read | Should -Contain $script:ItemRunbook
        $outcome.Read | Should -Contain "$script:ItemRoot/poetry.lock"
    }

    It 'does not read a main-checkout lockfile when only the item holds the runbook' {
        # Arrange
        $file = @{ $script:ItemRunbook = $script:Runbook; "$script:SessionRoot/poetry.lock" = "[[package]]`nname = `"nuitka`"`nversion = `"9.9.9`"`n" }

        # Act
        $outcome = Invoke-Case -RunbookPath $script:Relative -File $file

        # Assert
        $outcome.Result.Message | Should -Not -BeLike '*9.9.9*'
        $outcome.Read | Should -Not -Contain "$script:SessionRoot/poetry.lock"
    }

    It 'blocks a main-only runbook with the probed item location and resolver source' {
        # Arrange
        $file = @{ "$script:SessionRoot/$script:Relative" = $script:Runbook }

        # Act
        $outcome = Invoke-Case -RunbookPath $script:Relative -File $file

        # Assert
        $outcome.Result.Ok | Should -BeFalse
        $outcome.Result.Message | Should -BeLike "*no file exists at that location. Probed location: '$script:ItemRunbook' (item worktree resolved by DelegationPrompt)*"
    }

    It 'accepts an absolute runbook_path inside the item worktree after conversion' {
        # Arrange
        $file = @{ $script:ItemRunbook = (@('# Runbook', 'No commands.') -join "`n") }

        # Act
        $outcome = Invoke-Case -RunbookPath $script:ItemRunbook -File $file -Prompt 'no identity'

        # Assert
        $outcome.Result.Ok | Should -BeTrue
    }

    It 'blocks repairably on a runbook_path with a parent segment without probing it' {
        # Arrange
        $file = @{ $script:ItemRunbook = $script:Runbook }

        # Act
        $outcome = Invoke-Case -RunbookPath 'docs/runbooks/../../x.runbook.md' -File $file

        # Assert
        $outcome.Result.Ok | Should -BeFalse
        $outcome.Result.Message | Should -BeLike "*runbook path 'docs/runbooks/../../x.runbook.md' is rejected*'..' segment*"
        $outcome.Read.Count | Should -Be 0
    }

    It 'falls back to the session root with TARGET_WORKTREE_NOT_DERIVABLE in the block message' {
        # Arrange
        $file = @{}

        # Act
        $outcome = Invoke-Case -RunbookPath $script:Relative -File $file -Prompt 'branch: bug/unknown-branch'

        # Assert
        $outcome.Result.Ok | Should -BeFalse
        $outcome.Result.Message | Should -BeLike '*TARGET_WORKTREE_NOT_DERIVABLE*the session root was probed.'
    }

    It 'lists the session root and reads its lockfile when the target falls back to the session root' {
        # Arrange
        $file = @{ $script:Relative = $script:Runbook; "$script:SessionRoot/poetry.lock" = "[[package]]`nname = `"nuitka`"`nversion = `"4.3.4`"`n" }

        # Act
        $outcome = Invoke-Case -RunbookPath $script:Relative -File $file -Prompt 'branch: bug/unknown-branch'

        # Assert
        $outcome.Result.Message | Should -BeLike '*nuitka*4.3.4*'
        $outcome.Listed | Should -Be @($script:SessionRoot)
    }
}
