#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Release exemption of the PR-author gate (issue #1231, Leg 1).

.DESCRIPTION
    Unit rows call Get-PrAuthorReleaseExemption directly. The artifact root is the synthetic
    release worktree /synthetic-worktrees/release, no checkpoint file exists, the allowance file
    text and the container probe are mocked, refs/remotes/origin/<head> equals HEAD, origin/main
    resolves, and the branch diff lists package.json and package-lock.json. Each row overrides one
    seam or the command.

    Decision rows enter through Invoke-PrAuthorSkillDecision with the target resolution, the
    context summary, the failing orchestrator-state preflight, and the receipt seams mocked as in
    enforce-pr-author-skill.Cleanup.Tests.ps1. No row creates, writes, or deletes a file, starts a
    process, or runs the git executable.
#>

Describe 'enforce-pr-author-skill.ps1 release exemption (#1231)' {
    BeforeAll {
        $script:HookRoot = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks").Path
        . (Join-Path $script:HookRoot 'enforce-pr-author-skill.ps1')
        . (Join-Path $script:HookRoot 'enforce-pr-author-skill.release.ps1')
        $script:RealPublishedHead = ${function:Get-PrAuthorReleasePublishedHead}
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText', 'Get-OrchestratorStateCheckpoint', 'Get-CleanupWorktreeManifestContent' -Surface 'Claude'
        Mock Get-PrAuthorCheckpointContent { $null }
        Mock Get-PrAuthorReceiptContent { $null }

        $script:Root = '/synthetic-worktrees/release'
        $script:Checkpoint = "$($script:Root)/artifacts/orchestration/orchestrator-state.json"
        $script:Body = "$($script:Root)/artifacts/pr_body_7.md"
        $script:Create = "gh pr create --head release/v1.2.3 --base main --title Release --body-file $($script:Body)"
        $script:Commit = 'a' * 40
        $script:Nul = [string][char]0
        $script:ValidConfig = '{"schema_version":1,"allowances":[{"id":"npm","branch_patterns":["release/*"],"allowed_paths":["package.json","package-lock.json"]}]}'
        $script:Receipt = '{"skill":"pr-author","pr_body_path":"artifacts/pr_body_7.md","number":7,"sha256":"559aead08264d5795d3909718cdd05abd49572e84fe55590eef31a88a08fdffd","context_summary_path":"artifacts/pr_context.summary.txt","created_at":"2026-11-03T11:30:00Z"}'

        function Set-ReleasePrFixture {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
            param(
                [AllowNull()][object] $Config = $script:ValidConfig,
                [string] $Diff = "package.json$($script:Nul)package-lock.json$($script:Nul)",
                [string] $Root = $script:Root
            )
            $configText = $Config
            $diffResult = [pscustomobject]@{ ExitCode = 0; Output = $Diff }
            $commit = $script:Commit
            $target = [pscustomobject]@{ Status = 'OtherWorktree'; WorktreeRoot = $Root; ReasonCode = $null; Detail = 'synthetic release root' }
            $receipt = $script:Receipt
            Mock Get-OrchestrationGateReleaseAllowanceConfigText { $configText }.GetNewClosure()
            Mock Test-OrchestrationGateReleaseAllowancePathIsContainer { $false }
            Mock Test-PrAuthorDocsOnlyCheckpointPresence { $false }
            Mock Get-PrAuthorReleasePublishedHead { [pscustomobject]@{ Remote = ('b' * 40); Head = ('b' * 40) } }
            Mock Invoke-PrAuthorDocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'rev-parse' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = $commit } }.GetNewClosure()
            Mock Invoke-PrAuthorDocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'diff' } -MockWith { $diffResult }.GetNewClosure()
            Mock Resolve-PrAuthorWorktreeTarget { $target }.GetNewClosure()
            Mock Get-PrContextArtifactExistence { $true }
            Mock Invoke-OrchestratorStatePreflight { @{ HasErrors = $true; ErrorText = '' } }
            Mock Get-PrBodyFileBytes { , [byte[]] @(0x41) }
            Mock Get-PrAuthorReceiptContent { $receipt }.GetNewClosure()
            Mock Get-PrContextSummaryLastWriteUtc { [datetime]::new(2026, 11, 3, 11, 0, 0, [System.DateTimeKind]::Utc) }
        }

        function Get-ReleaseExemptionResult {
            param([string] $Command = $script:Create)
            return (Get-PrAuthorReleaseExemption -CommandText $Command -WorktreeRoot $script:Root -CheckpointPath $script:Checkpoint)
        }

        function ConvertTo-ReleasePrPayload {
            param([Parameter(Mandatory)] [string] $Command)
            return (@{ tool_input = @{ command = $Command } } | ConvertTo-Json -Depth 5 -Compress)
        }

        function Get-ReleasePrReason {
            param([Parameter(Mandatory)] [string] $Command)
            return ([string](Invoke-PrAuthorSkillDecision -ToolInputRaw (ConvertTo-ReleasePrPayload -Command $Command)).hookSpecificOutput.permissionDecisionReason)
        }
    }

    BeforeEach {
        Set-ReleasePrFixture
    }

    It 'baseline mock interception probe (#1231)' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    Context 'unit rows' {
        It 'exempts a release create whose diff is listed by the matching allowance (#1231)' {
            # Act
            $result = Get-ReleaseExemptionResult

            # Assert
            $result.Exempt | Should -BeTrue
            $result.Reason | Should -BeNullOrEmpty
            Should -Invoke Invoke-PrAuthorDocsOnlyGitExe -Times 1 -Exactly -ParameterFilter { ($GitArgs -join ' ') -ceq 'rev-parse --verify --quiet refs/remotes/origin/main^{commit}' }
            Should -Invoke Invoke-PrAuthorDocsOnlyGitExe -Times 1 -Exactly -ParameterFilter { $WorktreeRoot -ceq '/synthetic-worktrees/release' -and ($GitArgs -join ' ') -ceq "diff --name-only -z --no-renames --no-color --no-ext-diff --no-relative $($script:Commit)...HEAD" }
            Should -Invoke Get-PrAuthorReleasePublishedHead -Times 1 -Exactly -ParameterFilter { $Branch -ceq 'release/v1.2.3' }
        }

        It 'returns a null reason with no git call when the allowance file is absent (#1231)' {
            # Arrange
            Set-ReleasePrFixture -Config $null

            # Act
            $result = Get-ReleaseExemptionResult
            $blank = Get-PrAuthorReleaseExemption -CommandText $script:Create -WorktreeRoot '' -CheckpointPath $script:Checkpoint

            # Assert
            foreach ($entry in @($result, $blank)) {
                $entry.Exempt | Should -BeFalse
                $entry.Reason | Should -BeNullOrEmpty
            }
            Should -Invoke Invoke-PrAuthorDocsOnlyGitExe -Times 0 -Exactly
            Should -Invoke Get-PrAuthorReleasePublishedHead -Times 0 -Exactly
        }

        It 'reports RELEASE_EXEMPTION_CONFIG_INVALID for an invalid file, a read failure, or a directory entry (#1231)' {
            # Act
            Set-ReleasePrFixture -Config '{"schema_version":1}'
            $invalid = Get-ReleaseExemptionResult
            Mock Get-OrchestrationGateReleaseAllowanceConfigText { throw 'synthetic read failure' }
            $thrown = Get-ReleaseExemptionResult
            Set-ReleasePrFixture
            Mock Test-OrchestrationGateReleaseAllowancePathIsContainer { $true }
            $directory = Get-ReleaseExemptionResult

            # Assert
            $invalid.Reason | Should -BeExactly "RELEASE_EXEMPTION_CONFIG_INVALID: missing top-level key 'allowances'"
            $thrown.Reason | Should -BeExactly 'RELEASE_EXEMPTION_CONFIG_INVALID: the file could not be read'
            $directory.Reason | Should -BeExactly "RELEASE_EXEMPTION_CONFIG_INVALID: allowed_paths entry 'package.json' is a directory"
        }

        It 'reports RELEASE_EXEMPTION_NOT_CREATE for gh pr edit (#1231)' {
            # Act
            $result = Get-ReleaseExemptionResult -Command "gh pr edit release/v1.2.3 --body-file $($script:Body)"

            # Assert
            $result.Exempt | Should -BeFalse
            $result.Reason | Should -BeLike 'RELEASE_EXEMPTION_NOT_CREATE: *'
        }

        It 'reports RELEASE_EXEMPTION_CHECKPOINT_PRESENT with no git call (#1231)' {
            # Arrange
            Mock Test-PrAuthorDocsOnlyCheckpointPresence { $true }

            # Act
            $result = Get-ReleaseExemptionResult

            # Assert
            $result.Reason | Should -BeLike 'RELEASE_EXEMPTION_CHECKPOINT_PRESENT: *'
            Should -Invoke Invoke-PrAuthorDocsOnlyGitExe -Times 0 -Exactly
            Should -Invoke Get-PrAuthorReleasePublishedHead -Times 0 -Exactly
        }

        It 'reports RELEASE_EXEMPTION_HEAD_UNRESOLVED for <Label> (#1231)' -ForEach @(
            @{ Label = 'a repeated --head'; Command = 'gh pr create --head release/v1 --head release/v1 --base main --body-file artifacts/pr_body_7.md' }
            @{ Label = 'a --head= token'; Command = 'gh pr create --head=release/v1 --base main --body-file artifacts/pr_body_7.md' }
            @{ Label = 'an owner-qualified --head'; Command = 'gh pr create --head drmoisan:release/v1 --base main --body-file artifacts/pr_body_7.md' }
            @{ Label = 'a single-dash token containing H'; Command = 'gh pr create -H release/v1 --base main --body-file artifacts/pr_body_7.md' }
            @{ Label = 'a --head with no value'; Command = 'gh pr create --base main --body-file artifacts/pr_body_7.md --head' }
            @{ Label = 'a value containing ..'; Command = 'gh pr create --head release/v1..x --base main --body-file artifacts/pr_body_7.md' }
            @{ Label = 'no --head'; Command = 'gh pr create --base main --body-file artifacts/pr_body_7.md' }
        ) {
            # Act
            $result = Get-ReleaseExemptionResult -Command $Command

            # Assert
            $result.Exempt | Should -BeFalse
            $result.Reason | Should -BeLike 'RELEASE_EXEMPTION_HEAD_UNRESOLVED: *'
            Should -Invoke Invoke-PrAuthorDocsOnlyGitExe -Times 0 -Exactly
        }

        It 'reports RELEASE_EXEMPTION_BASE_UNRESOLVED for <Label> (#1231)' -ForEach @(
            @{ Label = 'a missing --base'; Command = 'gh pr create --head release/v1 --body-file artifacts/pr_body_7.md' }
            @{ Label = 'a --repo override'; Command = 'gh pr create --head release/v1 --base main --repo o/r --body-file artifacts/pr_body_7.md' }
            @{ Label = 'a -R override'; Command = 'gh pr create --head release/v1 --base main -R o/r --body-file artifacts/pr_body_7.md' }
        ) {
            # Act
            $result = Get-ReleaseExemptionResult -Command $Command

            # Assert
            $result.Reason | Should -BeLike 'RELEASE_EXEMPTION_BASE_UNRESOLVED: *'
        }

        It 'reports RELEASE_EXEMPTION_BRANCH_NOT_MATCHED with no git call (#1231)' {
            # Act
            $result = Get-ReleaseExemptionResult -Command 'gh pr create --head feature/x --base main --body-file artifacts/pr_body_7.md'

            # Assert
            $result.Reason | Should -BeExactly "RELEASE_EXEMPTION_BRANCH_NOT_MATCHED: branch 'feature/x' matches no allowance."
            Should -Invoke Invoke-PrAuthorDocsOnlyGitExe -Times 0 -Exactly
            Should -Invoke Get-PrAuthorReleasePublishedHead -Times 0 -Exactly
        }

        It 'reports RELEASE_EXEMPTION_REMOTE_HEAD_MISMATCH for a missing or different remote head (#1231)' {
            # Act
            Mock Get-PrAuthorReleasePublishedHead { [pscustomobject]@{ Remote = ''; Head = ('b' * 40) } }
            $missing = Get-ReleaseExemptionResult
            Mock Get-PrAuthorReleasePublishedHead { [pscustomobject]@{ Remote = ('c' * 40); Head = ('b' * 40) } }
            $different = Get-ReleaseExemptionResult
            Mock Get-PrAuthorReleasePublishedHead { [pscustomobject]@{ Remote = ('b' * 40); Head = '' } }
            $noHead = Get-ReleaseExemptionResult

            # Assert
            foreach ($entry in @($missing, $different, $noHead)) { $entry.Reason | Should -BeLike 'RELEASE_EXEMPTION_REMOTE_HEAD_MISMATCH: refs/remotes/origin/release/v1.2.3 *' }
            Should -Invoke Invoke-PrAuthorDocsOnlyGitExe -Times 0 -Exactly
        }

        It 'reports RELEASE_EXEMPTION_DIFF_FAILED for an unresolved base, a failed diff, or unterminated output (#1231)' {
            # Act
            Mock Invoke-PrAuthorDocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'diff' } -MockWith { [pscustomobject]@{ ExitCode = 1; Output = '' } }
            $failed = Get-ReleaseExemptionResult
            Set-ReleasePrFixture -Diff 'package.json'
            $unterminated = Get-ReleaseExemptionResult
            Set-ReleasePrFixture
            Mock Invoke-PrAuthorDocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'rev-parse' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = 'not-a-commit' } }
            $unresolved = Get-ReleaseExemptionResult

            # Assert
            foreach ($entry in @($failed, $unterminated, $unresolved)) { $entry.Reason | Should -BeLike 'RELEASE_EXEMPTION_DIFF_FAILED: *' }
        }

        It 'reports RELEASE_EXEMPTION_EMPTY_DIFF for an empty diff (#1231)' {
            # Arrange
            Set-ReleasePrFixture -Diff ''

            # Act / Assert
            (Get-ReleaseExemptionResult).Reason | Should -BeLike 'RELEASE_EXEMPTION_EMPTY_DIFF: *'
        }

        It 'reports RELEASE_EXEMPTION_PATH_NOT_ALLOWED for an unlisted path (#1231)' {
            # Arrange
            Set-ReleasePrFixture -Diff "package.json$($script:Nul)src/app.ps1$($script:Nul)"

            # Act
            $result = Get-ReleaseExemptionResult

            # Assert
            $result.Reason | Should -BeExactly "RELEASE_EXEMPTION_PATH_NOT_ALLOWED: 'src/app.ps1' is not listed in allowed_paths of allowance 'npm'."
        }

        It 'declines with a null reason and a Write-Debug record when a seam throws (#1231)' {
            # Arrange
            Mock Write-Debug { }
            Mock Get-PrAuthorReleasePublishedHead { throw 'synthetic published-head failure' }

            # Act
            $result = Get-ReleaseExemptionResult

            # Assert
            $result.Exempt | Should -BeFalse
            $result.Reason | Should -BeNullOrEmpty
            Should -Invoke Write-Debug -Times 1 -ParameterFilter { $Message -like 'PR_AUTHOR_RELEASE_LEG_ERROR:*' }
        }
    }

    Context 'published-head seam body' {
        It 'resolves refs/remotes/origin/<branch> and HEAD through the docs-only git seam (#1231)' {
            # Arrange
            $remote = '1' * 40
            $head = '2' * 64
            Mock Invoke-PrAuthorDocsOnlyGitExe -ParameterFilter { $GitArgs[3] -ceq 'refs/remotes/origin/release/v1^{commit}' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = "$remote`n" } }.GetNewClosure()
            Mock Invoke-PrAuthorDocsOnlyGitExe -ParameterFilter { $GitArgs[3] -ceq 'HEAD^{commit}' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = $head } }.GetNewClosure()

            # Act
            $resolved = & $script:RealPublishedHead -WorktreeRoot $script:Root -Branch 'release/v1'
            Mock Invoke-PrAuthorDocsOnlyGitExe -ParameterFilter { $GitArgs[3] -ceq 'refs/remotes/origin/release/v1^{commit}' } -MockWith { [pscustomobject]@{ ExitCode = 1; Output = '' } }
            Mock Invoke-PrAuthorDocsOnlyGitExe -ParameterFilter { $GitArgs[3] -ceq 'HEAD^{commit}' } -MockWith { throw 'synthetic rev-parse failure' }
            $failed = & $script:RealPublishedHead -WorktreeRoot $script:Root -Branch 'release/v1'
            Mock Invoke-PrAuthorDocsOnlyGitExe -ParameterFilter { $GitArgs[3] -ceq 'refs/remotes/origin/release/v1^{commit}' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = 'not-a-commit' } }
            Mock Invoke-PrAuthorDocsOnlyGitExe -ParameterFilter { $GitArgs[3] -ceq 'HEAD^{commit}' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = ('A' * 40) } }
            $nonCommit = & $script:RealPublishedHead -WorktreeRoot $script:Root -Branch 'release/v1'

            # Assert
            $resolved.Remote | Should -BeExactly $remote
            $resolved.Head | Should -BeExactly $head
            foreach ($result in @($failed, $nonCommit)) {
                $result.Remote | Should -BeExactly ''
                $result.Head | Should -BeExactly ''
            }
            Should -Invoke Invoke-PrAuthorDocsOnlyGitExe -Times 3 -Exactly -ParameterFilter { ($GitArgs -join ' ') -ceq 'rev-parse --verify --quiet refs/remotes/origin/release/v1^{commit}' }
        }
    }

    Context 'decision rows through Invoke-PrAuthorSkillDecision' {
        It 'allows a checkpoint-free release create, and the receipt checks still deny a missing or mismatched receipt (AC-01) (#1231)' {
            # Act
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw (ConvertTo-ReleasePrPayload -Command $script:Create)
            Mock Get-PrAuthorReceiptContent { $null }
            $missing = Get-ReleasePrReason -Command $script:Create
            Set-ReleasePrFixture
            Mock Get-PrBodyFileBytes { , [byte[]] @(0x42) }
            $mismatched = Get-ReleasePrReason -Command $script:Create

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "reason: $($decision.hookSpecificOutput.permissionDecisionReason)"
            $missing | Should -BeLike 'PR_AUTHOR_RECEIPT_MISSING*'
            $mismatched | Should -BeLike 'PR_AUTHOR_RECEIPT_HASH_MISMATCH*'
        }

        It 'appends the release reason after the docs-only and cleanup reasons inside the parentheses (AC-03) (#1231)' {
            # Arrange: a consolidation create with no manifest fails cleanup, and its head matches no release pattern.
            Mock Get-CleanupWorktreeManifestContent { $null }
            $command = "gh pr create --head documentationandmemories --base main --title Consolidate --body-file $($script:Body)"

            # Act
            $reason = Get-ReleasePrReason -Command $command

            # Assert
            $reason | Should -Match '^ORCHESTRATOR_STATE_PREFLIGHT_FAILED: .*\(docs-only exemption not applied: DOCS_ONLY_EXEMPTION_[A-Z_]+: .*; cleanup exemption not applied: CLEANUP_EXEMPTION_MANIFEST_INVALID: .*; release exemption not applied: RELEASE_EXEMPTION_BRANCH_NOT_MATCHED: branch ''documentationandmemories'' matches no allowance\.\)$'
        }

        It 'appends the release reason directly after the docs-only reason when no cleanup branch is named (#1231)' {
            # Arrange
            Set-ReleasePrFixture -Diff "package.json$($script:Nul)src/app.ps1$($script:Nul)"

            # Act
            $reason = Get-ReleasePrReason -Command $script:Create

            # Assert
            $reason | Should -Match '\(docs-only exemption not applied: DOCS_ONLY_EXEMPTION_NON_DOCS_PATH: .*; release exemption not applied: RELEASE_EXEMPTION_PATH_NOT_ALLOWED: .*\)$'
            $reason | Should -Not -Match 'cleanup exemption not applied'
        }

        It 'does not evaluate the release leg under epic scope (AC-04) (#1231)' {
            # Arrange
            $root = $script:Root
            $epic = [pscustomobject]@{ Checkpoint = $null; Branch = 'release/v1.2.3'; CheckpointPath = "$root/artifacts/orchestration/epic-orchestrator-state.json"; WorktreeRoot = $root }
            Mock Resolve-PrAuthorArtifactRoot { [ordered]@{ Reason = $null; ArtifactRoot = $root; CheckpointPath = $epic.CheckpointPath; EpicScope = $epic; Status = 'Epic'; RelativeBodyAllowed = $false } }.GetNewClosure()
            Mock Get-EpicPrCreationReadinessFailure { 'epic_mode' }
            Mock Get-PrAuthorReleaseExemption { [ordered]@{ Exempt = $true; Reason = $null } }

            # Act
            $reason = Get-ReleasePrReason -Command $script:Create

            # Assert
            $reason | Should -BeLike 'ORCHESTRATOR_STATE_PREFLIGHT_FAILED: this epic-scope pull request*'
            Should -Invoke Get-PrAuthorReleaseExemption -Times 0 -Exactly
            Should -Invoke Get-OrchestrationGateReleaseAllowanceConfigText -Times 0 -Exactly
        }

        It 'exempts a docs-only diff through #901 before the release leg is evaluated (AC-04) (#1231)' {
            # Arrange
            Set-ReleasePrFixture -Diff "docs/release-notes.md$($script:Nul)"

            # Act
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw (ConvertTo-ReleasePrPayload -Command $script:Create)

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            Should -Invoke Get-OrchestrationGateReleaseAllowanceConfigText -Times 0 -Exactly
        }

        It 'keeps the exact pre-change deny text and makes no release-leg git call when the allowance file is absent (AC-10) (#1231)' {
            # Arrange
            Set-ReleasePrFixture -Config $null
            $checkpoint = Get-WorktreeItemCheckpointPath -WorktreeRoot $script:Root
            $docsReason = Get-DocsOnlyDiffTextViolation -DiffText "package.json$($script:Nul)package-lock.json$($script:Nul)" -BaseName 'main'

            # Act
            $reason = Get-ReleasePrReason -Command $script:Create

            # Assert
            $reason | Should -BeExactly "ORCHESTRATOR_STATE_PREFLIGHT_FAILED: checkpoint missing at $checkpoint (docs-only exemption not applied: $docsReason)"
            Should -Invoke Get-PrAuthorReleasePublishedHead -Times 0 -Exactly
            Should -Invoke Invoke-PrAuthorDocsOnlyGitExe -Times 2 -Exactly
            Should -Invoke Invoke-PrAuthorDocsOnlyGitExe -Times 1 -Exactly -ParameterFilter { $GitArgs[0] -eq 'rev-parse' }
            Should -Invoke Invoke-PrAuthorDocsOnlyGitExe -Times 1 -Exactly -ParameterFilter { $GitArgs[0] -eq 'diff' }
        }

        It 'reports each code through the gate after the docs-only reason (AC-02) (#1231)' {
            # Arrange
            $rows = @(
                @{ Command = "gh pr edit release/v1.2.3 --body-file $($script:Body)"; Code = 'RELEASE_EXEMPTION_NOT_CREATE' }
                @{ Command = "gh pr create --head release/v1.2.3 --head release/v1.2.3 --base main --body-file $($script:Body)"; Code = 'RELEASE_EXEMPTION_HEAD_UNRESOLVED' }
                @{ Command = "gh pr create --head release/v1.2.3 --body-file $($script:Body)"; Code = 'RELEASE_EXEMPTION_BASE_UNRESOLVED' }
            )

            # Act / Assert
            foreach ($row in $rows) {
                $reason = Get-ReleasePrReason -Command $row.Command
                $reason | Should -BeLike 'ORCHESTRATOR_STATE_PREFLIGHT_FAILED:*' -Because $row.Code
                $reason | Should -Match ([regex]::Escape("; release exemption not applied: $($row.Code): ")) -Because $row.Code
            }
        }
    }
}
