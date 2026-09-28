#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Decision-surface coverage for the Codex epic worktree-removal gate
    (issue #545, [P12-T9]).

.DESCRIPTION
    tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1 and
    tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1
    between them drive the merged and unmerged checkpoint paths through
    Invoke-CodexWorktreeRemovalDecision with an absolute target path and an explicit cwd.
    The empty-source branches of ConvertFrom-CodexWorktreeJson, the --force operand
    fallback, the relative-path leg of the path normalizer, the two early returns of the
    feature finder, the non-Bash early return, the working-directory fallback, and the
    no-operand branch of the decision router carried no named case. The entry point had
    none. This file supplies them.

    Entry-point cases: the hook's stdin-to-exit-code block is exercised in process by
    redirecting [System.Console]::In and [System.Console]::Error to in-memory readers and
    writers, which is the harness already established by
    tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1. The original readers are
    restored in a finally block.

    The entry point reads artifacts/orchestration/epic-orchestrator-state.json from disk
    before it calls the decision seam. Every entry-point case below is written so that its
    asserted outcome is invariant to the content and to the presence of that file: the
    non-Bash case returns before the checkpoint is consulted, the malformed-stdin case
    throws before it is consulted, and the deny case names a synthetic absolute path that
    no real epic checkpoint records, so the target cannot match an authorizing feature
    whatever the file holds. No case writes to disk and no case creates a temporary file.

    Determinism: every other case drives a pure function with a literal fixture. No child
    process, no live executable, no ambient state in any assertion.
#>

Describe 'Codex enforce-epic-worktree-removal-gate decision surface (issue #545)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:UnderTest = Join-Path $script:RepoRoot '.codex/hooks/enforce-epic-worktree-removal-gate.ps1'
        . $script:UnderTest

        # A synthetic absolute path. No epic checkpoint records it, so a removal aimed at
        # it denies whatever the on-disk checkpoint holds.
        $script:SyntheticTarget = 'C:/nonexistent-545-fixture/worktree-9f2a1c'

        function ConvertTo-CodexWorktreeDecisionPayload {
            <# Builds the full Codex stdin payload the decision seam consumes. #>
            param(
                [Parameter(Mandatory)][AllowEmptyString()][string] $Command,
                [string] $ToolName = 'Bash',
                [AllowNull()][string] $WorkingDirectory
            )

            $payload = [ordered]@{
                hook_event_name = 'PreToolUse'
                tool_name       = $ToolName
                tool_input      = @{ command = $Command }
            }
            if ($PSBoundParameters.ContainsKey('WorkingDirectory')) {
                $payload['cwd'] = $WorkingDirectory
            }
            return ($payload | ConvertTo-Json -Compress -Depth 5)
        }

        function Invoke-CodexWorktreeGateEntryPoint {
            <#
                Runs the hook's entry point in process against an in-memory stdin reader
                and captures its stdout, stderr, and exit code. The console readers and
                writers are restored in finally, so no later case observes a redirected
                console.
            #>
            param(
                [Parameter(Mandatory)][string] $HookPath,
                [Parameter(Mandatory)][AllowEmptyString()][string] $PayloadRaw
            )

            $originalIn = [System.Console]::In
            $originalError = [System.Console]::Error
            $errorWriter = [System.IO.StringWriter]::new()
            try {
                [System.Console]::SetIn([System.IO.StringReader]::new($PayloadRaw))
                [System.Console]::SetError($errorWriter)
                $stdout = & $HookPath
                return [pscustomobject]@{
                    ExitCode = $LASTEXITCODE
                    Stdout   = ($stdout -join "`n")
                    Stderr   = $errorWriter.ToString()
                }
            } finally {
                [System.Console]::SetIn($originalIn)
                [System.Console]::SetError($originalError)
            }
        }
    }

    Context 'ConvertFrom-CodexWorktreeJson separates required from optional sources' {
        It 'returns null rather than throwing for an empty optional source' {
            ConvertFrom-CodexWorktreeJson -Raw '' -Name 'epic checkpoint' -Optional | Should -BeNullOrEmpty
        }

        It 'throws a named EPIC_WORKTREE_REMOVAL_BLOCKED error for an empty required source' {
            { ConvertFrom-CodexWorktreeJson -Raw '' -Name 'PreToolUse input' } |
                Should -Throw -ExpectedMessage 'EPIC_WORKTREE_REMOVAL_BLOCKED: PreToolUse input is empty.'
        }

        It 'returns null rather than throwing for a malformed optional source' {
            ConvertFrom-CodexWorktreeJson -Raw '{broken' -Name 'epic checkpoint' -Optional |
                Should -BeNullOrEmpty
        }

        It 'throws a named EPIC_WORKTREE_REMOVAL_BLOCKED error for a malformed required source' {
            { ConvertFrom-CodexWorktreeJson -Raw '{broken' -Name 'PreToolUse input' } |
                Should -Throw -ExpectedMessage 'EPIC_WORKTREE_REMOVAL_BLOCKED: PreToolUse input is malformed JSON:*'
        }
    }

    Context 'Get-CodexWorktreeRemovalPath resolves an operand or reports the flag' {
        It 'returns the --force marker when the flag is present and no operand follows' {
            Get-CodexWorktreeRemovalPath -Command 'git worktree remove --force' | Should -Be '--force'
        }

        It 'returns the empty string for a bare removal that names neither operand nor flag' {
            Get-CodexWorktreeRemovalPath -Command 'git worktree remove' | Should -Be ''
        }

        It 'returns the empty string for a subcommand that is not remove' {
            Get-CodexWorktreeRemovalPath -Command 'git worktree list --porcelain' | Should -Be ''
        }
    }

    Context 'Get-NormalizedCodexWorktreePath resolves both rooted and relative inputs' {
        It 'resolves a relative path against the supplied working directory' {
            Get-NormalizedCodexWorktreePath -Path 'worktrees/child-a' -WorkingDirectory 'C:/repo' |
                Should -Be 'C:/repo/worktrees/child-a'
        }

        It 'keeps a rooted path and trims a trailing separator' {
            Get-NormalizedCodexWorktreePath -Path 'C:/repo/worktrees/child-a/' -WorkingDirectory 'C:/elsewhere' |
                Should -Be 'C:/repo/worktrees/child-a'
        }
    }

    Context 'Find-CodexWorktreeFeature tolerates incomplete checkpoints' {
        It 'returns null for a null checkpoint' {
            Find-CodexWorktreeFeature -Checkpoint $null -TargetPath 'C:/repo/wt' -WorkingDirectory 'C:/repo' |
                Should -BeNullOrEmpty
        }

        It 'returns null for a checkpoint that carries no features array' {
            $checkpoint = '{"route_id":"epic"}' | ConvertFrom-Json

            Find-CodexWorktreeFeature -Checkpoint $checkpoint -TargetPath 'C:/repo/wt' -WorkingDirectory 'C:/repo' |
                Should -BeNullOrEmpty
        }

        It 'skips a feature record whose worktree_path is blank and reports no match' {
            $checkpoint = '{"features":[{"worktree_path":"","merge_status":"merged"}]}' | ConvertFrom-Json

            Find-CodexWorktreeFeature -Checkpoint $checkpoint -TargetPath 'C:/repo/wt' -WorkingDirectory 'C:/repo' |
                Should -BeNullOrEmpty
        }

        It 'returns the matching feature record when the normalized paths agree' {
            $checkpoint = '{"features":[{"worktree_path":"worktrees/child-a","merge_status":"merged"}]}' | ConvertFrom-Json

            $feature = Find-CodexWorktreeFeature `
                -Checkpoint $checkpoint `
                -TargetPath 'C:/repo/worktrees/child-a' `
                -WorkingDirectory 'C:/repo'

            $feature.merge_status | Should -Be 'merged'
        }
    }

    Context 'the decision router scope and operand branches' {
        It 'returns null for a non-Bash payload' {
            $payload = ConvertTo-CodexWorktreeDecisionPayload -Command 'ignored' -ToolName 'Write'

            Invoke-CodexWorktreeRemovalDecision -PayloadRaw $payload -EpicCheckpointRaw '' |
                Should -BeNullOrEmpty
        }

        It 'denies an in-scope removal that names no operand at all' {
            # The scope filter admits the bare invocation, the operand resolver returns the
            # empty string, and the feature lookup is skipped, so the gate denies.
            $payload = ConvertTo-CodexWorktreeDecisionPayload -Command 'git worktree remove' -WorkingDirectory 'C:/repo'

            $decision = Invoke-CodexWorktreeRemovalDecision -PayloadRaw $payload -EpicCheckpointRaw ''

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Match '^EPIC_WORKTREE_REMOVAL_BLOCKED'
        }

        It 'falls back to the current location when the payload carries no cwd' {
            # The target is absolute, so the working directory does not change the
            # normalized target and the deny holds wherever the suite runs from.
            $payload = ConvertTo-CodexWorktreeDecisionPayload -Command ('git worktree remove "' + $script:SyntheticTarget + '"')

            $decision = Invoke-CodexWorktreeRemovalDecision -PayloadRaw $payload -EpicCheckpointRaw ''

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'allows a removal whose feature record reports worktree_removed' {
            $checkpoint = '{"features":[{"worktree_path":"C:/repo/worktrees/child-a","merge_status":"worktree_removed"}]}'
            $payload = ConvertTo-CodexWorktreeDecisionPayload `
                -Command 'git worktree remove "C:/repo/worktrees/child-a"' `
                -WorkingDirectory 'C:/repo'

            Invoke-CodexWorktreeRemovalDecision -PayloadRaw $payload -EpicCheckpointRaw $checkpoint |
                Should -BeNullOrEmpty
        }
    }

    Context 'the hook entry point reads stdin and reports through the exit code' {
        It 'writes nothing and exits 0 for a non-Bash payload on stdin' {
            $payload = ConvertTo-CodexWorktreeDecisionPayload -Command 'ignored' -ToolName 'Write'

            $result = Invoke-CodexWorktreeGateEntryPoint -HookPath $script:UnderTest -PayloadRaw $payload

            $result.ExitCode | Should -Be 0
            $result.Stdout | Should -BeNullOrEmpty
            $result.Stderr | Should -BeNullOrEmpty
        }

        It 'writes the deny envelope and exits 0 for a removal no epic checkpoint authorizes' {
            $payload = ConvertTo-CodexWorktreeDecisionPayload `
                -Command ('git worktree remove "' + $script:SyntheticTarget + '"') `
                -WorkingDirectory 'C:/repo'

            $result = Invoke-CodexWorktreeGateEntryPoint -HookPath $script:UnderTest -PayloadRaw $payload

            $result.ExitCode | Should -Be 0
            $result.Stderr | Should -BeNullOrEmpty
            $decision = $result.Stdout | ConvertFrom-Json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Match '^EPIC_WORKTREE_REMOVAL_BLOCKED'
        }

        It 'writes the reason to stderr and exits 2 for malformed stdin' {
            $result = Invoke-CodexWorktreeGateEntryPoint -HookPath $script:UnderTest -PayloadRaw '{broken'

            $result.ExitCode | Should -Be 2
            $result.Stdout | Should -BeNullOrEmpty
            $result.Stderr | Should -Match 'EPIC_WORKTREE_REMOVAL_BLOCKED: PreToolUse input is malformed JSON'
        }
    }
}
