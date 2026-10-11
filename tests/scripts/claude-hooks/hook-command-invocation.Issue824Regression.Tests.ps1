#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Named regression rows for issue #824 and the bundled issues #742 and #733 (T-REG, plan section 5).

.DESCRIPTION
    Each row reproduces one reported false-positive deny or one reported pr-author defect
    against the hook that produced it, and asserts the corrected decision:

      REG-01        R-824-MAIN   promotion gate (Claude and Codex) allows a pwsh command whose
                                 prose contains the letters of 'gh', 'issue', and 'new'.
      REG-02..07    R-824-ADD1,  the three worktree-removal gates allow a command that removes
                    R-742-1      no worktree, and 'git --version' (a terminal git option).
      REG-08        R-742-1      the preimplementation gate (Claude and Codex) does not treat
                                 'git --version' as staging.
      REG-09..12    R-733-714,   the pr-author gate does not classify a commit-message heredoc
                    R-733-GREP   or a search pattern as 'gh pr create'.
      REG-13..17    R-733-715    the five body-file spellings reach receipt verification
                                 instead of PR_BODY_PATH_NONCANONICAL.
      REG-18..21    R-733-712    the pr-author command allowlist denies the chained receipt
                                 procedure and allows each command run alone.

    Scoping: no dot-source and no Mock at file scope. Each hook is dot-sourced only in the
    BeforeAll of the Describe that holds that hook's rows, and every Mock is declared inside
    that Describe. Every read seam a decision can reach is mocked, so no row reads the
    filesystem, starts a process, or depends on the machine's worktrees.
#>

BeforeDiscovery {
    $script:Runtimes = @(
        @{ Runtime = 'claude'; HookRoot = '.claude/hooks' }
        @{ Runtime = 'codex'; HookRoot = '.codex/hooks' }
    )
}

Describe 'Issue #824 regression: promotion gate (<Runtime>)' -ForEach $script:Runtimes {
    BeforeAll {
        $repoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $repoRoot "$HookRoot/enforce-promotion-mcp-only.ps1")
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-CleanupWorktreeManifestContent', 'Get-EpicScopeCheckpointText', 'Get-OrchestratorStateCheckpoint', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        if (Get-Command Get-EpicWorktreeGateCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicWorktreeGateCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-EpicWorktreeGateParallelCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicWorktreeGateParallelCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-ParallelWorktreeRemovalGateCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelWorktreeRemovalGateCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-ParallelWorktreeRemovalGateEpicCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelWorktreeRemovalGateEpicCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-PrAuthorCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-PrAuthorCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-PrAuthorReceiptContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-PrAuthorReceiptContent' -Surface 'Codex' }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    It 'REG-01 allows R-824-MAIN, whose prose only contains the letters of gh issue new' -Tag 'Issue824', 'R-824-MAIN' {
        $command = 'pwsh -NoProfile -Command ''$parts = New-Object System.Collections.Generic.List[string]; foreach ($t in @("a phrase that runs through the text", "The call is guarded (issue #1)")) { Write-Output $t }'''

        $reason = Get-PromotionBypassReason -CommandText $command

        $reason | Should -BeNullOrEmpty -Because 'no segment of R-824-MAIN invokes gh issue create or gh issue new'
    }
}

Describe 'Issue #824 regression: Claude epic worktree-removal gate' {
    BeforeAll {
        $repoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $repoRoot '.claude/hooks/enforce-epic-worktree-removal-gate.ps1')
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-CleanupWorktreeManifestContent', 'Get-EpicScopeCheckpointText', 'Get-OrchestratorStateCheckpoint', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        if (Get-Command Get-EpicWorktreeGateCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicWorktreeGateCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-EpicWorktreeGateParallelCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicWorktreeGateParallelCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-ParallelWorktreeRemovalGateCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelWorktreeRemovalGateCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-ParallelWorktreeRemovalGateEpicCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelWorktreeRemovalGateEpicCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-PrAuthorCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-PrAuthorCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-PrAuthorReceiptContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-PrAuthorReceiptContent' -Surface 'Codex' }

        function ConvertTo-RegressionEnvelope {
            param([Parameter(Mandatory)][string] $Command)
            return (@{ tool_name = 'Bash'; tool_input = @{ command = $Command } } | ConvertTo-Json -Compress -Depth 5)
        }
    }

    BeforeEach {
        # No checkpoint and no manifest authorize anything, so an allow can only come from
        # the command being out of scope.
        Mock Resolve-EpicWorktreeGateRunTarget { [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = '/synthetic-worktrees/session'; ReasonCode = $null; Detail = 'synthetic session root' } }
        Mock Get-EpicWorktreeGateCheckpointContent { $null }
        Mock Get-EpicWorktreeGateParallelCheckpointContent { $null }
        Mock Test-CleanupWorktreeManifestAuthorizesRemoval { $false }
    }

    It 'REG-02 allows R-824-ADD1, which removes a file and no worktree' -Tag 'Issue824', 'R-824-ADD1' {
        $command = 'pwsh -NoProfile -Command ''Set-Location -LiteralPath "C:/repo/.claude/worktrees/agent-x"; if (Test-Path -LiteralPath "src/Old.cs") { Remove-Item -LiteralPath "src/Old.cs" -Force }; git status --porcelain -- "src/Old.cs"'''

        $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-RegressionEnvelope -Command $command)

        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because 'R-824-ADD1 invokes git status, not git worktree remove'
    }

    It 'REG-03 allows R-742-1, git --version' -Tag 'Issue824', 'R-742-1' {
        $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-RegressionEnvelope -Command 'git --version')

        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because '--version is a terminal git option, so no subcommand runs'
    }
}

Describe 'Issue #824 regression: Claude parallel worktree-removal gate' {
    BeforeAll {
        $repoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $repoRoot '.claude/hooks/enforce-parallel-worktree-removal-gate.ps1')
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-CleanupWorktreeManifestContent', 'Get-EpicScopeCheckpointText', 'Get-OrchestratorStateCheckpoint', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        if (Get-Command Get-EpicWorktreeGateCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicWorktreeGateCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-EpicWorktreeGateParallelCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicWorktreeGateParallelCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-ParallelWorktreeRemovalGateCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelWorktreeRemovalGateCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-ParallelWorktreeRemovalGateEpicCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelWorktreeRemovalGateEpicCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-PrAuthorCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-PrAuthorCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-PrAuthorReceiptContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-PrAuthorReceiptContent' -Surface 'Codex' }

        function ConvertTo-RegressionEnvelope {
            param([Parameter(Mandatory)][string] $Command)
            return (@{ tool_name = 'Bash'; tool_input = @{ command = $Command } } | ConvertTo-Json -Compress -Depth 5)
        }
    }

    BeforeEach {
        Mock Resolve-ParallelWorktreeGateRunTarget { [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = '/synthetic-worktrees/session'; ReasonCode = $null; Detail = 'synthetic session root' } }
        Mock Get-ParallelWorktreeRemovalGateCheckpointContent { $null }
        Mock Get-ParallelWorktreeRemovalGateEpicCheckpointContent { $null }
        Mock Test-CleanupWorktreeManifestAuthorizesRemoval { $false }
    }

    It 'REG-04 allows R-824-ADD1, which removes a file and no worktree' -Tag 'Issue824', 'R-824-ADD1' {
        $command = 'pwsh -NoProfile -Command ''Set-Location -LiteralPath "C:/repo/.claude/worktrees/agent-x"; if (Test-Path -LiteralPath "src/Old.cs") { Remove-Item -LiteralPath "src/Old.cs" -Force }; git status --porcelain -- "src/Old.cs"'''

        $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-RegressionEnvelope -Command $command)

        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because 'R-824-ADD1 invokes git status, not git worktree remove'
    }

    It 'REG-05 allows R-742-1, git --version' -Tag 'Issue824', 'R-742-1' {
        $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-RegressionEnvelope -Command 'git --version')

        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because '--version is a terminal git option, so no subcommand runs'
    }
}

Describe 'Issue #824 regression: Codex epic worktree-removal gate' {
    BeforeAll {
        $repoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $repoRoot '.codex/hooks/enforce-epic-worktree-removal-gate.ps1')
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-CleanupWorktreeManifestContent', 'Get-EpicScopeCheckpointText', 'Get-OrchestratorStateCheckpoint', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        if (Get-Command Get-EpicWorktreeGateCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicWorktreeGateCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-EpicWorktreeGateParallelCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicWorktreeGateParallelCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-ParallelWorktreeRemovalGateCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelWorktreeRemovalGateCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-ParallelWorktreeRemovalGateEpicCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelWorktreeRemovalGateEpicCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-PrAuthorCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-PrAuthorCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-PrAuthorReceiptContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-PrAuthorReceiptContent' -Surface 'Codex' }
        $script:SyntheticRoot = if ($IsWindows) { 'C:/repo' } else { '/repo' }

        function ConvertTo-CodexRegressionPayload {
            param([Parameter(Mandatory)][string] $Command)
            return ([ordered]@{
                    hook_event_name = 'PreToolUse'
                    tool_name       = 'Bash'
                    tool_input      = @{ command = $Command }
                    cwd             = $script:SyntheticRoot
                } | ConvertTo-Json -Compress -Depth 5)
        }
    }

    It 'REG-06 returns no decision for R-824-ADD1, which removes a file and no worktree' -Tag 'Issue824', 'R-824-ADD1' {
        $command = 'pwsh -NoProfile -Command ''Set-Location -LiteralPath "C:/repo/.claude/worktrees/agent-x"; if (Test-Path -LiteralPath "src/Old.cs") { Remove-Item -LiteralPath "src/Old.cs" -Force }; git status --porcelain -- "src/Old.cs"'''

        $decision = Invoke-CodexWorktreeRemovalDecision -PayloadRaw (ConvertTo-CodexRegressionPayload -Command $command) -EpicCheckpointRaw ''

        $decision | Should -BeNullOrEmpty -Because 'R-824-ADD1 invokes git status, not git worktree remove'
    }

    It 'REG-07 returns no decision for R-742-1, git --version' -Tag 'Issue824', 'R-742-1' {
        $decision = Invoke-CodexWorktreeRemovalDecision -PayloadRaw (ConvertTo-CodexRegressionPayload -Command 'git --version') -EpicCheckpointRaw ''

        $decision | Should -BeNullOrEmpty -Because '--version is a terminal git option, so no subcommand runs'
    }
}

Describe 'Issue #824 regression: preimplementation gate (<Runtime>)' -ForEach $script:Runtimes {
    BeforeAll {
        $repoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $repoRoot "$HookRoot/enforce-orchestration-preimplementation-gate.ps1")
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-CleanupWorktreeManifestContent', 'Get-EpicScopeCheckpointText', 'Get-OrchestratorStateCheckpoint', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        if (Get-Command Get-EpicWorktreeGateCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicWorktreeGateCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-EpicWorktreeGateParallelCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicWorktreeGateParallelCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-ParallelWorktreeRemovalGateCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelWorktreeRemovalGateCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-ParallelWorktreeRemovalGateEpicCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelWorktreeRemovalGateEpicCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-PrAuthorCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-PrAuthorCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-PrAuthorReceiptContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-PrAuthorReceiptContent' -Surface 'Codex' }
        if ($Runtime -eq 'codex') {
            Mock Get-EpicScopeCheckpointText { $null }
        }
    }

    It 'REG-08 does not classify R-742-1, git --version, as an implementation command' -Tag 'Issue824', 'R-742-1' {
        $result = Test-ImplementationCommand -Command 'git --version'

        $result | Should -BeFalse -Because '--version is a terminal git option, so neither git add nor git commit runs'
    }
}

Describe 'Issue #824 regression: Claude pr-author skill gate' {
    BeforeAll {
        $repoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $repoRoot '.claude/hooks/enforce-pr-author-skill.ps1')
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-CleanupWorktreeManifestContent', 'Get-EpicScopeCheckpointText', 'Get-OrchestratorStateCheckpoint', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        if (Get-Command Get-EpicWorktreeGateCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicWorktreeGateCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-EpicWorktreeGateParallelCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicWorktreeGateParallelCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-ParallelWorktreeRemovalGateCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelWorktreeRemovalGateCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-ParallelWorktreeRemovalGateEpicCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelWorktreeRemovalGateEpicCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-PrAuthorCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-PrAuthorCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-PrAuthorReceiptContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-PrAuthorReceiptContent' -Surface 'Codex' }
    }

    Context 'commands that mention gh pr create without invoking it (R-733-714, R-733-GREP)' {
        It 'REG-09 allows R-733-714, a commit whose heredoc body contains the letters of gh pr create' -Tag 'Issue824', 'R-733-714' {
            $command = @(
                'git commit -m "$(cat <<''EOF'''
                'fix(hooks): route the matcher through the process that created the payload'
                'The change runs through every segment.'
                'EOF'
                ')"'
            ) -join "`n"

            $reason = Get-PrAuthorBypassReason -CommandText $command

            $reason | Should -BeNullOrEmpty -Because 'the heredoc body is data passed to git commit, not a gh pr create invocation'
        }

        It 'REG-10 allows R-733-GREP G1, a Select-String search for a phrase' -Tag 'Issue824', 'R-733-GREP' {
            $command = 'pwsh -NoProfile -Command ''Select-String -Path x.md -Pattern "high priority" | ForEach-Object { "create" }'''

            $reason = Get-PrAuthorBypassReason -CommandText $command

            $reason | Should -BeNullOrEmpty -Because 'no segment of G1 invokes gh'
        }

        It 'REG-11 allows R-733-GREP G2, a grep inside a command substitution' -Tag 'Issue824', 'R-733-GREP' {
            $command = 'echo "$(sed -n ''1,20p'' notes.md | grep -n ''through the process that created it'')"'

            $reason = Get-PrAuthorBypassReason -CommandText $command

            $reason | Should -BeNullOrEmpty -Because 'no segment of G2 invokes gh'
        }

        It 'REG-12 allows R-733-GREP G3, a grep whose pattern is the literal gh pr create' -Tag 'Issue824', 'R-733-GREP' {
            $command = 'echo "$(grep -n ''gh pr create'' notes.md)"'

            $reason = Get-PrAuthorBypassReason -CommandText $command

            $reason | Should -BeNullOrEmpty -Because 'gh pr create is a quoted grep pattern inside a sink, not an invocation'
        }
    }

    Context 'body-file spellings reach receipt verification (R-733-715)' {
        BeforeEach {
            Mock Get-PrAuthorReceiptContent { $null }
        }

        It 'REG-13 accepts S1, a double-quoted body-file path' -Tag 'Issue824', 'R-733-715' {
            $reason = Test-PrAuthorReceiptVerification -CommandText 'gh pr create --head bug/x-5 --body-file "artifacts/pr_body_5.md"' -CheckpointPath '/synthetic/checkpoint.json' -ArtifactRoot '/session' -RelativeBodyAllowed $true

            $reason | Should -BeLike 'PR_AUTHOR_RECEIPT_MISSING:*' -Because 'the quoted canonical path must pass check 1 and stop at the absent receipt'
        }

        It 'REG-14 accepts S2, the --body-file=<path> form' -Tag 'Issue824', 'R-733-715' {
            $reason = Test-PrAuthorReceiptVerification -CommandText 'gh pr create --head bug/x-5 --body-file=artifacts/pr_body_5.md' -CheckpointPath '/synthetic/checkpoint.json' -ArtifactRoot '/session' -RelativeBodyAllowed $true

            $reason | Should -BeLike 'PR_AUTHOR_RECEIPT_MISSING:*' -Because 'the equals form carries the same canonical path'
        }

        It 'REG-15 accepts S3, an absolute path under the session root' -Tag 'Issue824', 'R-733-715' {
            $reason = Test-PrAuthorReceiptVerification -CommandText 'gh pr create --head bug/x-5 --body-file /session/artifacts/pr_body_5.md' -CheckpointPath '/synthetic/checkpoint.json' -ArtifactRoot '/session' -RelativeBodyAllowed $true

            $reason | Should -BeLike 'PR_AUTHOR_RECEIPT_MISSING:*' -Because 'the absolute path equals the canonical path beneath the artifact root'
        }

        It 'REG-16 accepts S4, a ./-prefixed relative path' -Tag 'Issue824', 'R-733-715' {
            $reason = Test-PrAuthorReceiptVerification -CommandText 'gh pr create --head bug/x-5 --body-file ./artifacts/pr_body_5.md' -CheckpointPath '/synthetic/checkpoint.json' -ArtifactRoot '/session' -RelativeBodyAllowed $true

            $reason | Should -BeLike 'PR_AUTHOR_RECEIPT_MISSING:*' -Because 'one leading ./ is stripped before the canonical match'
        }

        It 'REG-17 accepts S5, a backslash-separated path' -Tag 'Issue824', 'R-733-715' {
            $reason = Test-PrAuthorReceiptVerification -CommandText 'gh pr create --head bug/x-5 --body-file artifacts\pr_body_5.md' -CheckpointPath '/synthetic/checkpoint.json' -ArtifactRoot '/session' -RelativeBodyAllowed $true

            $reason | Should -BeLike 'PR_AUTHOR_RECEIPT_MISSING:*' -Because 'backslash separators normalize to forward slashes before the canonical match'
        }
    }
}

Describe 'Issue #824 regression: pr-author command allowlist' {
    BeforeAll {
        $repoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $repoRoot '.claude/hooks/enforce-pr-author-command-allowlist.ps1')
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-CleanupWorktreeManifestContent', 'Get-EpicScopeCheckpointText', 'Get-OrchestratorStateCheckpoint', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        if (Get-Command Get-EpicWorktreeGateCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicWorktreeGateCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-EpicWorktreeGateParallelCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicWorktreeGateParallelCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-ParallelWorktreeRemovalGateCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelWorktreeRemovalGateCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-ParallelWorktreeRemovalGateEpicCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelWorktreeRemovalGateEpicCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-PrAuthorCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-PrAuthorCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-PrAuthorReceiptContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-PrAuthorReceiptContent' -Surface 'Codex' }
    }

    It 'REG-18 denies the R-733-712 chained receipt procedure' -Tag 'Issue824', 'R-733-712' {
        $command = 'git log -1 --format=%H && sha256sum artifacts/pr_body_5.md && date -u +%Y-%m-%dT%H:%M:%SZ'

        $decision = Invoke-PrAuthorCommandAllowlistDecision -CommandText $command

        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PR_AUTHOR_COMMAND_NOT_ALLOWED:*'
    }

    It 'REG-19 allows git log -1 --format=%H run alone' -Tag 'Issue824', 'R-733-712' {
        $decision = Invoke-PrAuthorCommandAllowlistDecision -CommandText 'git log -1 --format=%H'

        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'REG-20 allows sha256sum artifacts/pr_body_5.md run alone' -Tag 'Issue824', 'R-733-712' {
        $decision = Invoke-PrAuthorCommandAllowlistDecision -CommandText 'sha256sum artifacts/pr_body_5.md'

        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'REG-21 allows date -u +%Y-%m-%dT%H:%M:%SZ run alone' -Tag 'Issue824', 'R-733-712' {
        $decision = Invoke-PrAuthorCommandAllowlistDecision -CommandText 'date -u +%Y-%m-%dT%H:%M:%SZ'

        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }
}
