#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Docs-only branch of the Codex epic merge gate .codex/hooks/enforce-epic-merge-gate.ps1 (issue #927).

.DESCRIPTION
    Drives Invoke-CodexEpicMergeDecision with literal checkpoint texts and mocked docs-only
    seams. An allow is asserted as $null, the Codex allow representation. No row starts a
    process, runs git or gh, or writes a file. The BeforeAll seam mocks are registered only
    when the shared helper is loaded, so before it exists every docs-only row fails.
#>

Describe 'Codex enforce-epic-merge-gate docs-only branch (issue #927)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:CodexHook = Join-Path $script:RepoRoot '.codex/hooks/enforce-epic-merge-gate.ps1'
        . $script:CodexHook
        . (Join-Path $PSScriptRoot '../claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1')
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')).Path -ErrorAction Stop
        if (Get-Command Get-ChildOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Mock Get-ChildOrchestratorCheckpointContent { $null } }
        if (Get-Command Get-EpicOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Mock Get-EpicOrchestratorCheckpointContent { $null } }
        if (Get-Command Get-ParallelOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Mock Get-ParallelOrchestratorCheckpointContent { $null } }
        Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
        if (Get-Command Invoke-DocsOnlyGhExe -ErrorAction SilentlyContinue) { Mock Invoke-DocsOnlyGhExe { [pscustomobject]@{ ExitCode = 1; Output = '' } } }
        if (Get-Command Invoke-DocsOnlyGitExe -ErrorAction SilentlyContinue) { Mock Invoke-DocsOnlyGitExe { [pscustomobject]@{ ExitCode = 1; Output = '' } } }

        function ConvertTo-CodexDocsOnlyPayload {
            <#
            .SYNOPSIS
                Wrap a Bash command in the PreToolUse payload the Codex gate reads.
            #>
            [CmdletBinding()]
            [OutputType([string])]
            param([Parameter(Mandatory)][string] $Command)

            return (@{ session_id = 'session-927'; tool_name = 'Bash'; tool_input = @{ command = $Command } } | ConvertTo-Json -Depth 5 -Compress)
        }

        function Set-CodexGateDocsOnlySeam {
            <#
            .SYNOPSIS
                Mock both docs-only seams for one pull request and one diff listing.
            #>
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
            param([Parameter(Mandatory)][string] $DiffOutput)

            $listing = $DiffOutput
            Mock Invoke-DocsOnlyGhExe { [pscustomobject]@{ ExitCode = 0; Output = '{"baseRefName":"main","headRefOid":"0123456789abcdef0123456789abcdef01234567"}' } }
            Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'rev-parse' -and $GitArgs[-1] -ceq 'refs/remotes/origin/main^{commit}' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = 'fedcba9876543210fedcba9876543210fedcba98' } }
            Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'rev-parse' -and $GitArgs[-1] -ceq '0123456789abcdef0123456789abcdef01234567^{commit}' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = '0123456789abcdef0123456789abcdef01234567' } }
            Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'diff' } -MockWith ({ [pscustomobject]@{ ExitCode = 0; Output = $listing } }.GetNewClosure())
        }

        $script:CodexBareDenyText = 'EPIC_MERGE_GATE_BLOCKED: a pull-request merge or merge-queue enqueue (gh pr merge with any method, --auto, or --admin, or a gh api merge or enqueue mutation) requires a safe epic child checkpoint or a successful final epic CI gate with a matching PR number.'
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    It 'allows a docs-only merge when no checkpoint is present (codex, issue #927)' {
        # Arrange
        Set-CodexGateDocsOnlySeam -DiffOutput "docs/a.md`0"
        $payload = ConvertTo-CodexDocsOnlyPayload -Command 'gh pr merge 5 --merge'

        # Act
        $decision = Invoke-CodexEpicMergeDecision -PayloadRaw $payload -ChildCheckpointRaw '' -EpicCheckpointRaw '' -RepositoryRoot $PSScriptRoot

        # Assert
        $decision | Should -BeNullOrEmpty -Because "reason: $($decision.hookSpecificOutput.permissionDecisionReason)"
        Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -ParameterFilter { ($GhArgs -join ' ') -ceq 'pr view 5 --json baseRefName,headRefOid' -and $WorkingRoot -like '*codex-hooks' }
    }

    It 'appends the NON_DOCS_PATH docs-only reason to the standalone deny (codex, issue #927)' {
        # Arrange
        Set-CodexGateDocsOnlySeam -DiffOutput "docs/a.md`0src/a.ps1`0"
        $payload = ConvertTo-CodexDocsOnlyPayload -Command 'gh pr merge 5 --merge'

        # Act
        $decision = Invoke-CodexEpicMergeDecision -PayloadRaw $payload -ChildCheckpointRaw '' -EpicCheckpointRaw '' -RepositoryRoot $PSScriptRoot
        $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $reason | Should -BeLike 'EPIC_MERGE_GATE_BLOCKED: STANDALONE_MERGE_AUTHORIZATION_ABSENT: *'
        $reason.Contains(' (docs-only exemption not applied: DOCS_ONLY_EXEMPTION_NON_DOCS_PATH') | Should -BeTrue
    }

    It 'makes no docs-only call when the <Name> checkpoint is present (codex, issue #927)' -ForEach @(
        @{ Name = 'child'; Child = '{"note":"present"}'; Epic = '' }
        @{ Name = 'epic'; Child = ''; Epic = '{"note":"present"}' }
    ) {
        # Arrange
        $payload = ConvertTo-CodexDocsOnlyPayload -Command 'gh pr merge 5 --merge'

        # Act
        $decision = Invoke-CodexEpicMergeDecision -PayloadRaw $payload -ChildCheckpointRaw $Child -EpicCheckpointRaw $Epic -RepositoryRoot $PSScriptRoot
        $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $reason.Contains('docs-only exemption not applied') | Should -BeFalse
        Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
        Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly
    }

    It 'denies a blank repository root with PR_UNRESOLVED and no process call (codex, issue #927)' {
        # Arrange
        $payload = ConvertTo-CodexDocsOnlyPayload -Command 'gh pr merge 5 --merge'

        # Act
        $decision = Invoke-CodexEpicMergeDecision -PayloadRaw $payload -ChildCheckpointRaw '' -EpicCheckpointRaw '' -RepositoryRoot ''

        # Assert
        ([string]$decision.hookSpecificOutput.permissionDecisionReason).Contains('DOCS_ONLY_EXEMPTION_PR_UNRESOLVED') | Should -BeTrue
        Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
        Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly
    }

    It 'denies a -R override with PR_UNRESOLVED and no process call (codex, issue #927)' {
        # Arrange
        $payload = ConvertTo-CodexDocsOnlyPayload -Command 'gh pr merge 5 --merge -R o/r'

        # Act
        $decision = Invoke-CodexEpicMergeDecision -PayloadRaw $payload -ChildCheckpointRaw '' -EpicCheckpointRaw '' -RepositoryRoot $PSScriptRoot

        # Assert
        ([string]$decision.hookSpecificOutput.permissionDecisionReason).Contains('DOCS_ONLY_EXEMPTION_PR_UNRESOLVED') | Should -BeTrue
        Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
        Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly
    }

    It 'denies a pull-request URL selector with PR_UNRESOLVED and no process call (codex, issue #952)' {
        # Arrange: the URL resolves to 5 and the local pull request 5 is docs-only, so only
        # the M1 URL rule keeps the exemption from reading the local repository.
        Set-CodexGateDocsOnlySeam -DiffOutput "docs/a.md`0"
        $payload = ConvertTo-CodexDocsOnlyPayload -Command 'gh pr merge https://github.com/o/r/pull/5 --merge'

        # Act
        $decision = Invoke-CodexEpicMergeDecision -PayloadRaw $payload -ChildCheckpointRaw '' -EpicCheckpointRaw '' -RepositoryRoot $PSScriptRoot
        $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $reason.Contains(" (docs-only exemption not applied: DOCS_ONLY_EXEMPTION_PR_UNRESOLVED: the URL selector 'https://github.com/o/r/pull/5' is not accepted.)") | Should -BeTrue
        Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
        Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly
    }

    It 'denies a failed gh lookup with PR_UNRESOLVED (codex, issue #927)' {
        # Arrange: the BeforeAll seam mocks report a failed lookup.
        $payload = ConvertTo-CodexDocsOnlyPayload -Command 'gh pr merge 5 --merge'

        # Act
        $decision = Invoke-CodexEpicMergeDecision -PayloadRaw $payload -ChildCheckpointRaw '' -EpicCheckpointRaw '' -RepositoryRoot $PSScriptRoot

        # Assert
        ([string]$decision.hookSpecificOutput.permissionDecisionReason).Contains('DOCS_ONLY_EXEMPTION_PR_UNRESOLVED') | Should -BeTrue
        Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly
    }

    It 'keeps the bare-merge deny text unchanged (codex, issue #927)' {
        # Arrange
        $payload = ConvertTo-CodexDocsOnlyPayload -Command 'gh pr merge --merge'

        # Act
        $decision = Invoke-CodexEpicMergeDecision -PayloadRaw $payload -ChildCheckpointRaw '' -EpicCheckpointRaw '' -RepositoryRoot $PSScriptRoot

        # Assert
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:CodexBareDenyText
        Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
    }
}
