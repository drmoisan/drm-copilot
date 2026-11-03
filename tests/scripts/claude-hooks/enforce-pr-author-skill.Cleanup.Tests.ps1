#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Cleanup exemption of the PR-author gate for consolidation pull requests (issue #1026).

.DESCRIPTION
    Every decision row enters through Invoke-PrAuthorSkillDecision. The target resolves to the
    synthetic consolidation worktree /synthetic-worktrees/documentationandmemories, the context
    summary exists, the orchestrator-state preflight fails, no checkpoint file exists,
    origin/main resolves, the branch diff lists docs/ and .claude/agent-memory/ paths, the
    session-root manifest is fresh and valid, and the receipt seams describe a valid receipt for
    pr_body_7.md. Each row overrides one seam or the command.

    The manifest and clock seams are mocked at script scope, because the cleanup sibling calls
    Get-CleanupWorktreeManifestContent and Get-CleanupWorktreeManifestUtcNow directly; the
    module-scope baseline mock of the manifest read is registered as well. No row creates,
    writes, or deletes a file, starts a process, or runs the git executable.
#>

Describe 'enforce-pr-author-skill.ps1 cleanup exemption (issue #1026)' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-pr-author-skill.ps1").Path
        . $script:UnderTest
        $script:RealPublishedHead = ${function:Get-PrAuthorCleanupPublishedHead}
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText', 'Get-OrchestratorStateCheckpoint', 'Get-CleanupWorktreeManifestContent' -Surface 'Claude'
        Mock Get-PrAuthorCheckpointContent { $null }
        Mock Get-PrAuthorReceiptContent { $null }

        $script:Root = '/synthetic-worktrees/documentationandmemories'
        $script:Feature = '/synthetic-worktrees/bug-example'
        $script:Body = "$($script:Root)/artifacts/pr_body_7.md"
        $script:Create = "gh pr create --head documentationandmemories --base main --title Consolidate --body-file $($script:Body)"
        $script:Manifest = '{"tool":"cleanup-merged-worktrees","schema_version":1,"generated_at":"2026-11-03T11:00:00Z","run_id":"run-1026","removals":[]}'
        $script:Now = [datetime]::new(2026, 11, 3, 12, 0, 0, [System.DateTimeKind]::Utc)
        $script:Nul = [string][char]0
        $script:Receipt = '{"skill":"pr-author","pr_body_path":"artifacts/pr_body_7.md","number":7,"sha256":"559aead08264d5795d3909718cdd05abd49572e84fe55590eef31a88a08fdffd","context_summary_path":"artifacts/pr_context.summary.txt","created_at":"2026-11-03T11:30:00Z"}'

        function ConvertTo-CleanupPrPayload {
            param([Parameter(Mandatory)] [string] $Command)
            return (@{ tool_input = @{ command = $Command } } | ConvertTo-Json -Depth 5 -Compress)
        }

        function Set-CleanupPrFixture {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
            param([string] $Root = $script:Root, [string] $Status = 'OtherWorktree', [string] $Diff = "docs/research/y.md$($script:Nul).claude/agent-memory/x/y.md$($script:Nul)", [AllowNull()][string] $Manifest = $script:Manifest)
            $target = [pscustomobject]@{ Status = $Status; WorktreeRoot = $Root; ReasonCode = $null; Detail = 'synthetic cleanup root' }
            $diffResult = [pscustomobject]@{ ExitCode = 0; Output = $Diff }
            $manifestText = $Manifest
            $now = $script:Now
            $receipt = $script:Receipt
            Mock Resolve-PrAuthorWorktreeTarget { $target }.GetNewClosure()
            Mock Get-PrContextArtifactExistence { $true }
            Mock Invoke-OrchestratorStatePreflight { @{ HasErrors = $true; ErrorText = '' } }
            Mock Invoke-PrAuthorDocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'rev-parse' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = ('a' * 40) } }
            Mock Invoke-PrAuthorDocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'diff' } -MockWith { $diffResult }.GetNewClosure()
            Mock Get-PrBodyFileBytes { , [byte[]] @(0x41) }
            Mock Get-PrAuthorReceiptContent { $receipt }.GetNewClosure()
            Mock Get-PrContextSummaryLastWriteUtc { [datetime]::new(2026, 11, 3, 11, 0, 0, [System.DateTimeKind]::Utc) }
            Mock Get-CleanupWorktreeManifestContent { $manifestText }.GetNewClosure()
            Mock Get-CleanupWorktreeManifestUtcNow { $now }.GetNewClosure()
            Mock Get-PrAuthorCleanupPublishedHead { [pscustomobject]@{ Remote = ('b' * 40); Head = ('b' * 40) } }
        }

        function Get-CleanupPrReason {
            param([Parameter(Mandatory)] [string] $Command)
            return ([string](Invoke-PrAuthorSkillDecision -ToolInputRaw (ConvertTo-CleanupPrPayload -Command $Command)).hookSpecificOutput.permissionDecisionReason)
        }

        function Assert-CleanupPrSubCode {
            param([Parameter(Mandatory)] [string] $Reason, [Parameter(Mandatory)] [string] $SubCode)
            $Reason | Should -BeLike 'ORCHESTRATOR_STATE_PREFLIGHT_FAILED:*'
            $Reason | Should -Match "; cleanup exemption not applied: $SubCode"
        }
    }

    BeforeEach {
        Set-CleanupPrFixture
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    Context 'allow' {
        It 'allows gh pr create --head documentationandmemories --base main with no checkpoint, a fresh valid manifest, and an allowlisted diff' {
            # Act
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw (ConvertTo-CleanupPrPayload -Command $script:Create)

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            Should -Invoke Get-CleanupWorktreeManifestContent -Times 1 -Exactly
        }
    }

    Context 'K1 to K6 failures' {
        It 'denies gh pr edit of the consolidation branch with CLEANUP_EXEMPTION_NOT_CREATE' {
            # Act
            $reason = Get-CleanupPrReason -Command "gh pr edit documentationandmemories --body-file $($script:Body)"

            # Assert
            Assert-CleanupPrSubCode -Reason $reason -SubCode 'CLEANUP_EXEMPTION_NOT_CREATE'
            $reason | Should -Match 'DOCS_ONLY_EXEMPTION_NOT_CREATE'
        }

        It 'denies a consolidation create when a checkpoint is present with CLEANUP_EXEMPTION_CHECKPOINT_PRESENT' {
            # Arrange
            Mock Test-PrAuthorDocsOnlyCheckpointPresence { $true }

            # Act / Assert
            Assert-CleanupPrSubCode -Reason (Get-CleanupPrReason -Command $script:Create) -SubCode 'CLEANUP_EXEMPTION_CHECKPOINT_PRESENT'
        }

        It 'denies an absent, different, short-form, owner-qualified, or repeated --head with CLEANUP_EXEMPTION_HEAD_UNRESOLVED' {
            # Arrange
            $tail = "--base main --body-file $($script:Body)"
            $commands = @(
                "gh pr create -H documentationandmemories $tail"
                "gh pr create --head drmoisan:documentationandmemories $tail"
                "gh pr create --head documentationandmemories --head documentationandmemories $tail"
                "gh pr create --head=documentationandmemories $tail"
                "gh pr create --head bug/other --title documentationandmemories $tail"
                "gh pr create --title documentationandmemories $tail"
            )

            # Act / Assert
            foreach ($command in $commands) {
                Assert-CleanupPrSubCode -Reason (Get-CleanupPrReason -Command $command) -SubCode 'CLEANUP_EXEMPTION_HEAD_UNRESOLVED'
            }
        }

        It 'denies a repeated or non-main --base with CLEANUP_EXEMPTION_BASE_UNRESOLVED' {
            # Arrange
            $commands = @(
                "gh pr create --head documentationandmemories --base main --base main --body-file $($script:Body)"
                "gh pr create --head documentationandmemories --base development --body-file $($script:Body)"
                "gh pr create --head documentationandmemories --body-file $($script:Body)"
                "gh pr create --head documentationandmemories --base main -R o/r --body-file $($script:Body)"
            )

            # Act / Assert
            foreach ($command in $commands) {
                Assert-CleanupPrSubCode -Reason (Get-CleanupPrReason -Command $command) -SubCode 'CLEANUP_EXEMPTION_BASE_UNRESOLVED'
            }
        }

        It 'denies a missing, stale, future, or invalid manifest or an empty run_id with CLEANUP_EXEMPTION_MANIFEST_INVALID' {
            # Arrange
            $manifests = @(
                $null
                '{"tool":"cleanup-merged-worktrees","schema_version":1,"generated_at":"2026-11-02T11:00:00Z","run_id":"r"}'
                '{"tool":"cleanup-merged-worktrees","schema_version":1,"generated_at":"2026-11-03T13:00:00Z","run_id":"r"}'
                '{"tool":"other","schema_version":1,"generated_at":"2026-11-03T11:00:00Z","run_id":"r"}'
                '{"tool":"cleanup-merged-worktrees","schema_version":1,"generated_at":"2026-11-03T11:00:00Z","run_id":""}'
            )

            # Act / Assert
            foreach ($manifest in $manifests) {
                Set-CleanupPrFixture -Manifest $manifest
                Assert-CleanupPrSubCode -Reason (Get-CleanupPrReason -Command $script:Create) -SubCode 'CLEANUP_EXEMPTION_MANIFEST_INVALID'
            }
            Mock Get-CleanupWorktreeManifestContent { throw 'simulated manifest read failure (issue #1026)' }
            Assert-CleanupPrSubCode -Reason (Get-CleanupPrReason -Command $script:Create) -SubCode 'CLEANUP_EXEMPTION_MANIFEST_INVALID'
        }

        It 'denies an empty or non-allowlisted diff with CLEANUP_EXEMPTION_EMPTY_DIFF or CLEANUP_EXEMPTION_NON_ALLOWLISTED_PATH' {
            # Act
            Set-CleanupPrFixture -Diff ''
            $empty = Get-CleanupPrReason -Command $script:Create
            Set-CleanupPrFixture -Diff "docs/research/y.md$($script:Nul).claude/rules/x.md$($script:Nul)"
            $outside = Get-CleanupPrReason -Command $script:Create

            # Assert
            Assert-CleanupPrSubCode -Reason $empty -SubCode 'CLEANUP_EXEMPTION_EMPTY_DIFF'
            Assert-CleanupPrSubCode -Reason $outside -SubCode 'CLEANUP_EXEMPTION_NON_ALLOWLISTED_PATH'
        }

        It 'denies a failed, unterminated, or throwing git read with CLEANUP_EXEMPTION_DIFF_FAILED' {
            # Arrange / Act
            Mock Invoke-PrAuthorDocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'diff' } -MockWith { [pscustomobject]@{ ExitCode = 1; Output = '' } }
            $failed = Get-CleanupPrReason -Command $script:Create
            Set-CleanupPrFixture -Diff 'docs/research/y.md'
            $unterminated = Get-CleanupPrReason -Command $script:Create
            Mock Invoke-PrAuthorDocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'diff' } -MockWith { throw 'simulated git failure (issue #1026)' }
            $thrown = Get-CleanupPrReason -Command $script:Create
            Mock Invoke-PrAuthorDocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'rev-parse' } -MockWith { [pscustomobject]@{ ExitCode = 1; Output = '' } }
            $unresolved = Get-CleanupPrReason -Command $script:Create
            Mock Invoke-PrAuthorDocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'rev-parse' } -MockWith { throw 'simulated rev-parse failure (issue #1026)' }
            $revParseThrown = Get-CleanupPrReason -Command $script:Create

            # Assert
            foreach ($reason in @($failed, $unterminated, $thrown, $unresolved, $revParseThrown)) {
                Assert-CleanupPrSubCode -Reason $reason -SubCode 'CLEANUP_EXEMPTION_DIFF_FAILED'
            }
        }

        It 'denies a consolidation create when origin/documentationandmemories is missing with CLEANUP_EXEMPTION_REMOTE_HEAD_MISMATCH' {
            # Arrange
            Mock Get-PrAuthorCleanupPublishedHead { [pscustomobject]@{ Remote = ''; Head = ('b' * 40) } }

            # Act
            $reason = Get-CleanupPrReason -Command $script:Create
            Mock Get-PrAuthorCleanupPublishedHead { throw 'simulated published-head failure (issue #1026)' }
            $thrown = Get-CleanupPrReason -Command $script:Create

            # Assert
            foreach ($result in @($reason, $thrown)) {
                Assert-CleanupPrSubCode -Reason $result -SubCode 'CLEANUP_EXEMPTION_REMOTE_HEAD_MISMATCH'
                $result | Should -Match ([regex]::Escape('refs/remotes/origin/documentationandmemories does not resolve to a commit'))
            }
        }

        It 'denies a consolidation create when origin/documentationandmemories differs from HEAD with CLEANUP_EXEMPTION_REMOTE_HEAD_MISMATCH' {
            # Arrange
            Mock Get-PrAuthorCleanupPublishedHead { [pscustomobject]@{ Remote = ('c' * 40); Head = ('b' * 40) } }

            # Act
            $reason = Get-CleanupPrReason -Command $script:Create

            # Assert
            Assert-CleanupPrSubCode -Reason $reason -SubCode 'CLEANUP_EXEMPTION_REMOTE_HEAD_MISMATCH'
            $reason | Should -Match ([regex]::Escape('differs from the consolidation worktree HEAD'))
        }
    }

    Context 'published-head seam body' {
        It 'resolves the published consolidation branch and HEAD through the bounded docs-only git seam' {
            # Arrange
            $remoteRef = 'refs/remotes/origin/documentationandmemories^{commit}'
            $remote = '1' * 40
            $head = '2' * 64
            Mock Invoke-PrAuthorDocsOnlyGitExe -ParameterFilter { $GitArgs[3] -ceq 'refs/remotes/origin/documentationandmemories^{commit}' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = "$remote`n" } }.GetNewClosure()
            Mock Invoke-PrAuthorDocsOnlyGitExe -ParameterFilter { $GitArgs[3] -ceq 'HEAD^{commit}' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = $head } }.GetNewClosure()

            # Act
            $resolved = & $script:RealPublishedHead -WorktreeRoot $script:Root
            Mock Invoke-PrAuthorDocsOnlyGitExe -ParameterFilter { $GitArgs[3] -ceq 'refs/remotes/origin/documentationandmemories^{commit}' } -MockWith { [pscustomobject]@{ ExitCode = 1; Output = '' } }
            Mock Invoke-PrAuthorDocsOnlyGitExe -ParameterFilter { $GitArgs[3] -ceq 'HEAD^{commit}' } -MockWith { throw 'simulated rev-parse failure (issue #1026)' }
            $failed = & $script:RealPublishedHead -WorktreeRoot $script:Root
            Mock Invoke-PrAuthorDocsOnlyGitExe -ParameterFilter { $GitArgs[3] -ceq 'refs/remotes/origin/documentationandmemories^{commit}' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = 'not-a-commit' } }
            Mock Invoke-PrAuthorDocsOnlyGitExe -ParameterFilter { $GitArgs[3] -ceq 'HEAD^{commit}' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = ('A' * 40) } }
            $nonCommit = & $script:RealPublishedHead -WorktreeRoot $script:Root

            # Assert
            $resolved.Remote | Should -BeExactly $remote
            $resolved.Head | Should -BeExactly $head
            foreach ($result in @($failed, $nonCommit)) {
                $result.Remote | Should -BeExactly ''
                $result.Head | Should -BeExactly ''
            }
            Should -Invoke Invoke-PrAuthorDocsOnlyGitExe -Times 3 -Exactly -ParameterFilter {
                $WorktreeRoot -eq $script:Root -and ($GitArgs -join ' ') -ceq "rev-parse --verify --quiet $remoteRef"
            }
            Should -Invoke Invoke-PrAuthorDocsOnlyGitExe -Times 3 -Exactly -ParameterFilter { ($GitArgs -join ' ') -ceq 'rev-parse --verify --quiet HEAD^{commit}' }
        }
    }

    Context 'ordering and unchanged behavior' {
        It 'still requires the orchestrator preflight for a non-consolidation PR with no checkpoint' {
            # Arrange
            Set-CleanupPrFixture -Root $script:Feature
            $command = "gh pr create --head bug/example --base main --body-file $($script:Feature)/artifacts/pr_body_7.md"
            $checkpoint = Get-WorktreeItemCheckpointPath -WorktreeRoot $script:Feature
            $docsOnly = Get-PrAuthorDocsOnlyExemption -CommandText $command -WorktreeRoot $script:Feature -CheckpointPath $checkpoint

            # Act
            $reason = Get-CleanupPrReason -Command $command

            # Assert
            $reason | Should -BeExactly "ORCHESTRATOR_STATE_PREFLIGHT_FAILED: checkpoint missing at $checkpoint (docs-only exemption not applied: $($docsOnly.Reason))"
            Should -Invoke Get-CleanupWorktreeManifestContent -Times 0 -Exactly
        }

        It 'evaluates the docs-only exemption before the cleanup exemption with unchanged results' {
            # Arrange: a docs/-only diff is exempt as docs-only, so the cleanup checks never run.
            Set-CleanupPrFixture -Diff "docs/research/y.md$($script:Nul)"
            $checkpoint = Get-WorktreeItemCheckpointPath -WorktreeRoot $script:Root
            $plain = 'gh pr create --base main --body-file artifacts/pr_body_7.md'

            # Act
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw (ConvertTo-CleanupPrPayload -Command $script:Create)
            $wrapped = Get-PrAuthorPreflightExemption -CommandText $plain -WorktreeRoot $script:Root -CheckpointPath $checkpoint
            $direct = Get-PrAuthorDocsOnlyExemption -CommandText $plain -WorktreeRoot $script:Root -CheckpointPath $checkpoint
            Set-CleanupPrFixture
            $wrappedDeny = Get-PrAuthorPreflightExemption -CommandText $plain -WorktreeRoot $script:Root -CheckpointPath $checkpoint
            $directDeny = Get-PrAuthorDocsOnlyExemption -CommandText $plain -WorktreeRoot $script:Root -CheckpointPath $checkpoint

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            Should -Invoke Get-CleanupWorktreeManifestContent -Times 0 -Exactly
            ($wrapped | ConvertTo-Json -Compress) | Should -BeExactly ($direct | ConvertTo-Json -Compress)
            ($wrappedDeny | ConvertTo-Json -Compress) | Should -BeExactly ($directDeny | ConvertTo-Json -Compress)
            $wrappedDeny.Exempt | Should -BeFalse
        }

        It 'runs the receipt checks unchanged after the cleanup exemption' {
            # Arrange: the body bytes no longer match the receipt hash.
            Mock Get-PrBodyFileBytes { , [byte[]] @(0x42) }

            # Act
            $reason = Get-CleanupPrReason -Command $script:Create

            # Assert
            $reason | Should -BeLike 'PR_AUTHOR_RECEIPT_HASH_MISMATCH*'
        }
    }

    Context 'paired denials' {
        It 'denies the consolidation create against a non-consolidation worktree' {
            # Arrange
            Set-CleanupPrFixture -Root $script:Feature
            $command = "gh pr create --head bug/example --base main --title Consolidate --body-file $($script:Feature)/artifacts/pr_body_7.md"
            $checkpoint = Get-WorktreeItemCheckpointPath -WorktreeRoot $script:Feature
            $docsOnly = Get-PrAuthorDocsOnlyExemption -CommandText $command -WorktreeRoot $script:Feature -CheckpointPath $checkpoint

            # Act / Assert
            Get-CleanupPrReason -Command $command | Should -BeExactly "ORCHESTRATOR_STATE_PREFLIGHT_FAILED: checkpoint missing at $checkpoint (docs-only exemption not applied: $($docsOnly.Reason))"
        }

        It 'denies the consolidation create against the session root' {
            # Arrange: the session root resolves for a create that names no branch.
            $session = (Get-Location).Path -replace '\\', '/'
            Set-CleanupPrFixture -Root $session -Status 'SessionRoot'
            $command = 'gh pr create --base main --title Consolidate --body-file artifacts/pr_body_7.md'
            $checkpoint = Get-WorktreeItemCheckpointPath -WorktreeRoot $session
            Mock Test-PrAuthorDocsOnlyCheckpointPresence { $false }
            $docsOnly = Get-PrAuthorDocsOnlyExemption -CommandText $command -WorktreeRoot $session -CheckpointPath $checkpoint

            # Act / Assert
            Get-CleanupPrReason -Command $command | Should -BeExactly "ORCHESTRATOR_STATE_PREFLIGHT_FAILED: checkpoint missing at $checkpoint (docs-only exemption not applied: $($docsOnly.Reason))"
        }
    }
}
