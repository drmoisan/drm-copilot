#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Decision-level rows for the release merge leg of .codex/hooks/enforce-epic-merge-gate.ps1 (issue #1234).

.DESCRIPTION
    Drives Invoke-CodexEpicMergeDecision with literal checkpoint texts and mocked gh and git seams.
    An allow is asserted as $null, the Codex allow representation. The unchanged-deny rows (AC-22)
    mock no allowance seam: the repository root is this folder, which holds no allowance file. The
    rows under 'an allowance file is present' mock the two allowance seams. No row starts a process,
    runs git or gh, or writes a file.
#>

Describe 'Codex enforce-epic-merge-gate release merge leg (#1234)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot '.codex/hooks/enforce-epic-merge-gate.ps1')
        . (Join-Path $PSScriptRoot '../claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1')
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')).Path -ErrorAction Stop
        if (Get-Command Get-ChildOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Mock Get-ChildOrchestratorCheckpointContent { $null } }
        if (Get-Command Get-EpicOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Mock Get-EpicOrchestratorCheckpointContent { $null } }
        if (Get-Command Get-ParallelOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Mock Get-ParallelOrchestratorCheckpointContent { $null } }
        Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }

        $script:CodexReleaseHead = '0123456789abcdef0123456789abcdef01234567'
        $script:CodexReleaseCommand = "gh pr merge 5 --merge --match-head-commit $($script:CodexReleaseHead)"
        $script:CodexReleaseUnchangedDeny = "EPIC_MERGE_GATE_BLOCKED: STANDALONE_MERGE_AUTHORIZATION_ABSENT: no orchestrator checkpoint carries an authorization record, but an authorized standalone merge path exists. To authorize a standalone merge, write a standalone_merge_authorizations record naming this pull request and the current session_id into an orchestrator checkpoint, as described in .claude/rules/orchestrator-state.md. (docs-only exemption not applied: DOCS_ONLY_EXEMPTION_NON_DOCS_PATH: 'package.json' is outside docs/.)"

        function ConvertTo-CodexReleasePayload {
            # Wrap a Bash command in the PreToolUse payload the Codex gate reads.
            param([Parameter(Mandatory)][string] $Command)
            return (@{ session_id = 'session-1234'; tool_name = 'Bash'; tool_input = @{ command = $Command } } | ConvertTo-Json -Depth 5 -Compress)
        }

        function Set-CodexReleaseDocsOnlySeam {
            # Mock the docs-only gh and git calls for one diff listing.
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
            param([Parameter(Mandatory)][string] $DiffOutput)
            $listing = $DiffOutput
            Mock Invoke-DocsOnlyGhExe -ParameterFilter { ($GhArgs -join ' ') -ceq 'pr view 5 --json baseRefName,headRefOid' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = '{"baseRefName":"main","headRefOid":"0123456789abcdef0123456789abcdef01234567"}' } }
            Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'rev-parse' -and $GitArgs[-1] -ceq 'refs/remotes/origin/main^{commit}' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = 'fedcba9876543210fedcba9876543210fedcba98' } }
            Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'rev-parse' -and $GitArgs[-1] -ceq '0123456789abcdef0123456789abcdef01234567^{commit}' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = '0123456789abcdef0123456789abcdef01234567' } }
            Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'diff' } -MockWith ({ [pscustomobject]@{ ExitCode = 0; Output = $listing } }.GetNewClosure())
        }

        function Invoke-CodexReleaseDecision {
            # Run the Codex gate decision for one command and checkpoint pair.
            param([string] $Command = $script:CodexReleaseCommand, [AllowEmptyString()][string] $Child = '', [AllowEmptyString()][string] $Epic = '')
            return Invoke-CodexEpicMergeDecision -PayloadRaw (ConvertTo-CodexReleasePayload -Command $Command) -ChildCheckpointRaw $Child -EpicCheckpointRaw $Epic -RepositoryRoot $PSScriptRoot
        }
    }

    BeforeEach {
        Mock Invoke-DocsOnlyGhExe { [pscustomobject]@{ ExitCode = 1; Output = '' } }
        Mock Invoke-DocsOnlyGitExe { [pscustomobject]@{ ExitCode = 1; Output = '' } }
    }

    AfterAll {
        foreach ($name in 'ConvertTo-CodexReleasePayload', 'Set-CodexReleaseDocsOnlySeam', 'Invoke-CodexReleaseDecision') {
            Remove-Item -LiteralPath "Function:\$name" -ErrorAction SilentlyContinue
        }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    Context 'no allowance file (AC-22)' {
        It 'keeps the checkpoint-free release-shaped deny text byte-identical (codex, #1234)' {
            # Arrange
            Set-CodexReleaseDocsOnlySeam -DiffOutput "package.json`0"

            # Act
            $decision = Invoke-CodexReleaseDecision
            $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            ($reason -ceq $script:CodexReleaseUnchangedDeny) | Should -BeTrue -Because "reason: $reason"
        }

        It 'starts only the docs-only gh and git calls (codex, #1234)' {
            # Arrange
            Set-CodexReleaseDocsOnlySeam -DiffOutput "package.json`0"

            # Act
            $null = Invoke-CodexReleaseDecision

            # Assert
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly
            Should -Invoke Invoke-DocsOnlyGitExe -Times 3 -Exactly
        }
    }

    Context 'an allowance file is present' {
        BeforeAll {
            $script:CodexReleaseFields = 'headRefName,baseRefName,headRefOid,state,isCrossRepository,changedFiles,files'

            function Set-CodexReleaseLegSeam {
                # Mock the leg's pr view and run list calls; the run list is green on the head.
                [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
                param()
                Mock Invoke-DocsOnlyGhExe -ParameterFilter { $GhArgs[-1] -ceq $script:CodexReleaseFields } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = '{"headRefName":"release/v1.2.3","baseRefName":"main","headRefOid":"0123456789abcdef0123456789abcdef01234567","state":"OPEN","isCrossRepository":false,"changedFiles":1,"files":[{"path":"package.json","changeType":"MODIFIED"}]}' } }
                Mock Invoke-DocsOnlyGhExe -ParameterFilter { $GhArgs[0] -ceq 'run' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = '[{"databaseId":11,"event":"pull_request","status":"completed","conclusion":"success","headSha":"0123456789abcdef0123456789abcdef01234567","workflowName":"CI","createdAt":"2026-11-20T10:00:00Z"}]' } }
            }
        }

        BeforeEach {
            Mock Get-OrchestrationGateReleaseAllowanceConfigText { '{"schema_version":1,"allowances":[{"id":"release","branch_patterns":["release/*"],"allowed_paths":["package.json"]}]}' }
            Mock Test-OrchestrationGateReleaseAllowancePathIsContainer { $false }
        }

        AfterAll {
            Remove-Item -LiteralPath 'Function:\Set-CodexReleaseLegSeam' -ErrorAction SilentlyContinue
        }

        It 'allows a checkpoint-free release merge without a review-guard process call (AC-02, AC-25) (codex, #1234)' {
            # Arrange
            Set-CodexReleaseDocsOnlySeam -DiffOutput "package.json`0"
            Set-CodexReleaseLegSeam

            # Act
            $decision = Invoke-CodexReleaseDecision

            # Assert
            $decision | Should -BeNullOrEmpty -Because "reason: $($decision.hookSpecificOutput.permissionDecisionReason)"
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -ParameterFilter { $GhArgs[-1] -ceq $script:CodexReleaseFields }
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -ParameterFilter { $GhArgs[0] -ceq 'run' }
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly -ParameterFilter { ($GhArgs -join ' ') -ceq 'pr view 5 --json headRefOid' }
            Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly -ParameterFilter { $GitArgs[0] -ceq 'merge-base' }
        }

        It 'reports RELEASE_MERGE_CHECKPOINT_PRESENT for a non-blank child checkpoint text (AC-05) (codex, #1234)' {
            # Arrange
            Set-CodexReleaseLegSeam

            # Act
            $decision = Invoke-CodexReleaseDecision -Child '{}'
            $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $reason | Should -Match ' \(release merge not applied: RELEASE_MERGE_CHECKPOINT_PRESENT: [^)]*\)$'
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly -ParameterFilter { $GhArgs[-1] -ceq $script:CodexReleaseFields }
        }

        It 'places the release suffix after the docs-only suffix (AC-23) (codex, #1234)' {
            # Arrange: the leg's pr view falls through to the failing default mock.
            Set-CodexReleaseDocsOnlySeam -DiffOutput "package.json`0"

            # Act
            $decision = Invoke-CodexReleaseDecision
            $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $reason | Should -Match "\(docs-only exemption not applied: DOCS_ONLY_EXEMPTION_NON_DOCS_PATH: [^)]*\) \(release merge not applied: RELEASE_MERGE_PR_UNRESOLVED: [^)]*\)$"
        }

        It 'lets the docs-only branch admit a docs-only diff before the leg runs (AC-24) (codex, #1234)' {
            # Arrange
            Set-CodexReleaseDocsOnlySeam -DiffOutput "docs/a.md`0"
            Set-CodexReleaseLegSeam

            # Act
            $decision = Invoke-CodexReleaseDecision

            # Assert
            $decision | Should -BeNullOrEmpty -Because "reason: $($decision.hookSpecificOutput.permissionDecisionReason)"
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly -ParameterFilter { $GhArgs[-1] -ceq $script:CodexReleaseFields }
        }

        It 'keeps an epic-child allow away from the leg (AC-24) (codex, #1234)' {
            # Arrange
            Mock Get-EpicMergeGateChildCiDecision { [ordered]@{ Verified = $true; Reason = '' } }

            # Act
            $decision = Invoke-CodexReleaseDecision -Child '{"epic_mode":true,"step9_status":"passed"}'

            # Assert
            $decision | Should -BeNullOrEmpty -Because "reason: $($decision.hookSpecificOutput.permissionDecisionReason)"
            Should -Invoke Get-OrchestrationGateReleaseAllowanceConfigText -Times 0 -Exactly
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly -ParameterFilter { $GhArgs[-1] -ceq $script:CodexReleaseFields }
        }
    }
}
