#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Pester tests for the enforce-parallel-worktree-removal-gate.ps1 PreToolUse hook.

.DESCRIPTION
    Every checkpoint fixture is injected through the mocked read seam
    Get-ParallelWorktreeRemovalGateCheckpointContent. No test reads the real
    artifacts/orchestration/parallel-orchestrator-state.json and no test writes a temporary
    file, so the suite is deterministic regardless of live orchestration state.

    Deny assertions use -BeLike with a trailing wildcard so the required
    PARALLEL_WORKTREE_REMOVAL_BLOCKED token is verified as a prefix rather than as a
    substring appearing anywhere in the reason.
#>

Describe 'enforce-parallel-worktree-removal-gate.ps1' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-parallel-worktree-removal-gate.ps1").Path
        . $script:UnderTest
    }

    Context 'commands outside scope are allowed unconditionally' {
        It 'denies an empty payload as an envelope anomaly (fail closed)' {
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw ''
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PARALLEL_WORKTREE_REMOVAL_BLOCKED'
        }

        It 'allows when the JSON payload has no command field' {
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw '{"tool_input":{"other":"value"}}'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows git worktree list' {
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw '{"tool_input":{"command":"git worktree list"}}'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows git worktree add' {
            $json = '{"tool_input":{"command":"git worktree add /repo/worktrees/item-a origin/main"}}'
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows an unrelated Bash command' {
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw '{"tool_input":{"command":"git status --short"}}'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'denies unparseable JSON instead of throwing (exit 1 is non-blocking)' {
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw '{not-json'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'not parseable JSON'
        }
    }

    Context 'allow when the matched item merge_status is terminal' {
        It 'allows git worktree remove when the matching record has merge_status merged' {
            Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -MockWith {
                '{"items":[{"issue_num":101,"worktree_path":"/repo/worktrees/item-a-101","merge_status":"merged"}]}'
            }
            $json = '{"tool_input":{"command":"git worktree remove /repo/worktrees/item-a-101"}}'
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows git worktree remove when the matching record has merge_status worktree_removed' {
            Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -MockWith {
                '{"items":[{"issue_num":101,"worktree_path":"/repo/worktrees/item-a-101","merge_status":"worktree_removed"}]}'
            }
            $json = '{"tool_input":{"command":"git worktree remove /repo/worktrees/item-a-101"}}'
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows git worktree remove --force when the matching record has merge_status merged' {
            Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -MockWith {
                '{"items":[{"issue_num":101,"worktree_path":"/repo/worktrees/item-a-101","merge_status":"merged"}]}'
            }
            $json = '{"tool_input":{"command":"git worktree remove /repo/worktrees/item-a-101 --force"}}'
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'deny PARALLEL_WORKTREE_REMOVAL_BLOCKED for every non-terminal merge_status' {
        It 'denies when the matching record has merge_status not_started' {
            Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -MockWith {
                '{"items":[{"issue_num":101,"worktree_path":"/repo/worktrees/item-a-101","merge_status":"not_started"}]}'
            }
            $json = '{"tool_input":{"command":"git worktree remove /repo/worktrees/item-a-101"}}'
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PARALLEL_WORKTREE_REMOVAL_BLOCKED:*'
        }

        It 'denies when the matching record has merge_status worktree_created' {
            Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -MockWith {
                '{"items":[{"issue_num":101,"worktree_path":"/repo/worktrees/item-a-101","merge_status":"worktree_created"}]}'
            }
            $json = '{"tool_input":{"command":"git worktree remove /repo/worktrees/item-a-101"}}'
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PARALLEL_WORKTREE_REMOVAL_BLOCKED:*'
        }

        It 'denies when the matching record has merge_status pr_open' {
            Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -MockWith {
                '{"items":[{"issue_num":101,"worktree_path":"/repo/worktrees/item-a-101","merge_status":"pr_open"}]}'
            }
            $json = '{"tool_input":{"command":"git worktree remove /repo/worktrees/item-a-101"}}'
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PARALLEL_WORKTREE_REMOVAL_BLOCKED:*'
        }

        It 'denies when the matching record has merge_status ci_green' {
            Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -MockWith {
                '{"items":[{"issue_num":101,"worktree_path":"/repo/worktrees/item-a-101","merge_status":"ci_green"}]}'
            }
            $json = '{"tool_input":{"command":"git worktree remove /repo/worktrees/item-a-101"}}'
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PARALLEL_WORKTREE_REMOVAL_BLOCKED:*'
        }

        It 'denies when the matching record has merge_status blocked_drift' {
            Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -MockWith {
                '{"items":[{"issue_num":101,"worktree_path":"/repo/worktrees/item-a-101","merge_status":"blocked_drift"}]}'
            }
            $json = '{"tool_input":{"command":"git worktree remove /repo/worktrees/item-a-101"}}'
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PARALLEL_WORKTREE_REMOVAL_BLOCKED:*'
        }

        It 'denies when the matching record has merge_status blocked_ci_loop_limit' {
            Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -MockWith {
                '{"items":[{"issue_num":101,"worktree_path":"/repo/worktrees/item-a-101","merge_status":"blocked_ci_loop_limit"}]}'
            }
            $json = '{"tool_input":{"command":"git worktree remove /repo/worktrees/item-a-101"}}'
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PARALLEL_WORKTREE_REMOVAL_BLOCKED:*'
        }

        It 'denies when the matching record carries no merge_status key' {
            Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -MockWith {
                '{"items":[{"issue_num":101,"worktree_path":"/repo/worktrees/item-a-101"}]}'
            }
            $json = '{"tool_input":{"command":"git worktree remove /repo/worktrees/item-a-101"}}'
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PARALLEL_WORKTREE_REMOVAL_BLOCKED:*'
        }
    }

    Context 'deny fail-closed on an unusable checkpoint or an unmatched path' {
        It 'denies when the parallel checkpoint file is absent' {
            Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -MockWith { $null }
            $json = '{"tool_input":{"command":"git worktree remove /repo/worktrees/item-a-101"}}'
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PARALLEL_WORKTREE_REMOVAL_BLOCKED:*'
        }

        It 'denies when the parallel checkpoint content is malformed JSON' {
            Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -MockWith { '{ broken json' }
            $json = '{"tool_input":{"command":"git worktree remove /repo/worktrees/item-a-101"}}'
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PARALLEL_WORKTREE_REMOVAL_BLOCKED:*'
        }

        It 'denies when no items[] record has a matching worktree_path' {
            Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -MockWith {
                '{"items":[{"issue_num":102,"worktree_path":"/repo/worktrees/item-b-102","merge_status":"merged"}]}'
            }
            $json = '{"tool_input":{"command":"git worktree remove /repo/worktrees/item-a-101"}}'
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PARALLEL_WORKTREE_REMOVAL_BLOCKED:*'
        }

        It 'denies when the checkpoint carries no items key' {
            Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -MockWith { '{"features":[]}' }
            $json = '{"tool_input":{"command":"git worktree remove /repo/worktrees/item-a-101"}}'
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PARALLEL_WORKTREE_REMOVAL_BLOCKED:*'
        }
    }

    Context 'read seam binding (the mocked seam value determines the decision)' {
        It 'calls the read seam exactly once and allows when the seam reports merged' {
            Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -MockWith {
                '{"items":[{"issue_num":101,"worktree_path":"/repo/worktrees/item-a-101","merge_status":"merged"}]}'
            }
            $json = '{"tool_input":{"command":"git worktree remove /repo/worktrees/item-a-101"}}'
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            Should -Invoke -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -Times 1 -Exactly
        }

        It 'calls the read seam exactly once and denies for the identical command when the seam reports ci_green' {
            Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -MockWith {
                '{"items":[{"issue_num":101,"worktree_path":"/repo/worktrees/item-a-101","merge_status":"ci_green"}]}'
            }
            $json = '{"tool_input":{"command":"git worktree remove /repo/worktrees/item-a-101"}}'
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            Should -Invoke -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -Times 1 -Exactly
        }

        It 'does not call the read seam for a command that is not git worktree remove' {
            Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -MockWith { $null }
            $null = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw '{"tool_input":{"command":"git worktree list"}}'
            Should -Invoke -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -Times 0 -Exactly
        }
    }

    Context 'path normalization' {
        It 'matches worktree_path across backslash/forward-slash separator differences' {
            Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -MockWith {
                '{"items":[{"issue_num":101,"worktree_path":"C:\\repo\\worktrees\\item-a-101","merge_status":"merged"}]}'
            }
            $json = '{"tool_input":{"command":"git worktree remove C:/repo/worktrees/item-a-101"}}'
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'matches worktree_path when the recorded value carries a trailing slash' {
            Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -MockWith {
                '{"items":[{"issue_num":101,"worktree_path":"/repo/worktrees/item-a-101/","merge_status":"merged"}]}'
            }
            $json = '{"tool_input":{"command":"git worktree remove /repo/worktrees/item-a-101"}}'
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'matches worktree_path when the command quotes the target path' {
            Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -MockWith {
                '{"items":[{"issue_num":101,"worktree_path":"/repo/worktrees/item-a-101","merge_status":"merged"}]}'
            }
            $json = '{"tool_input":{"command":"git worktree remove \"/repo/worktrees/item-a-101\""}}'
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'Get-ParallelWorktreeRemovalCommandPath helper' {
        It 'extracts the target path from the command text' {
            Get-ParallelWorktreeRemovalCommandPath -CommandText 'git worktree remove /repo/worktrees/item-a-101' |
                Should -Be '/repo/worktrees/item-a-101'
        }

        It 'returns $null when the command does not name a path' {
            Get-ParallelWorktreeRemovalCommandPath -CommandText 'git status' | Should -BeNullOrEmpty
        }
    }

    Context 'Find-ParallelWorktreeItemRecord helper' {
        It 'returns $null when Checkpoint is $null' {
            Find-ParallelWorktreeItemRecord -Checkpoint $null -WorktreePath '/repo/a' | Should -BeNullOrEmpty
        }

        It 'returns $null when the items key is absent' {
            $checkpoint = '{}' | ConvertFrom-Json
            Find-ParallelWorktreeItemRecord -Checkpoint $checkpoint -WorktreePath '/repo/a' | Should -BeNullOrEmpty
        }

        It 'returns $null when WorktreePath is empty' {
            $checkpoint = '{"items":[{"worktree_path":"/repo/a"}]}' | ConvertFrom-Json
            Find-ParallelWorktreeItemRecord -Checkpoint $checkpoint -WorktreePath '' | Should -BeNullOrEmpty
        }

        It 'skips item records with no worktree_path key' {
            $checkpoint = '{"items":[{"issue_num":101}]}' | ConvertFrom-Json
            Find-ParallelWorktreeItemRecord -Checkpoint $checkpoint -WorktreePath '/repo/a' | Should -BeNullOrEmpty
        }

        It 'returns the matching item record' {
            $checkpoint = '{"items":[{"issue_num":101,"worktree_path":"/repo/a"}]}' | ConvertFrom-Json
            $record = Find-ParallelWorktreeItemRecord -Checkpoint $checkpoint -WorktreePath '/repo/a'
            $record.issue_num | Should -Be 101
        }
    }

    Context 'Test-ParallelWorktreeRemovalAllowed helper' {
        It 'returns $false when ItemRecord is $null' {
            Test-ParallelWorktreeRemovalAllowed -ItemRecord $null | Should -BeFalse
        }

        It 'returns $false when the merge_status key is absent' {
            $item = '{"issue_num":101}' | ConvertFrom-Json
            Test-ParallelWorktreeRemovalAllowed -ItemRecord $item | Should -BeFalse
        }

        It 'returns $true for merge_status merged' {
            $item = '{"issue_num":101,"merge_status":"merged"}' | ConvertFrom-Json
            Test-ParallelWorktreeRemovalAllowed -ItemRecord $item | Should -BeTrue
        }
    }

    Context 'real Test-Path read seam' {
        It 'Get-ParallelWorktreeRemovalGateCheckpointContent returns $null when the checkpoint file does not exist' {
            Mock -CommandName Test-Path -MockWith { $false } -ParameterFilter { $LiteralPath -eq $script:ParallelCheckpointPath }
            Get-ParallelWorktreeRemovalGateCheckpointContent | Should -BeNullOrEmpty
        }

        It 'Get-ParallelWorktreeRemovalGateCheckpointContent reads real content when the file exists' {
            Mock -CommandName Test-Path -MockWith { $true } -ParameterFilter { $LiteralPath -eq $script:ParallelCheckpointPath }
            Mock -CommandName Get-Content -MockWith { '{"items":[]}' } -ParameterFilter { $LiteralPath -eq $script:ParallelCheckpointPath }
            Get-ParallelWorktreeRemovalGateCheckpointContent | Should -Be '{"items":[]}'
        }
    }

    Context 'entry-point exit code and emitted decision (AC-4, no child process)' {
        BeforeEach {
            Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -MockWith { $null }
        }


        It 'returns exit code 0 and emits a deny when every transport is empty' {
            $emptyReader = {
                Read-ClaudeHookRawPayload `
                    -ReadStandardInput { '' } `
                    -TestStandardInputRedirected { $true } `
                    -HookInputFallback '' `
                    -ToolInputFallback ''
            }
            $emitted = Invoke-ParallelWorktreeRemovalGateEntryPoint -ReadPayload $emptyReader
            $emitted[-1] | Should -Be 0
            $emitted[-1] | Should -Not -Be 1
            $parsed = $emitted[0] | ConvertFrom-Json
            $parsed.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $parsed.hookSpecificOutput.permissionDecisionReason | Should -Match 'PARALLEL_WORKTREE_REMOVAL_BLOCKED'
        }

        It 'returns exit code 0 and emits a deny for unparseable JSON' {
            $emitted = Invoke-ParallelWorktreeRemovalGateEntryPoint -ToolInputRaw '{not-json'
            $emitted[-1] | Should -Be 0
            $emitted[-1] | Should -Not -Be 1
            ($emitted[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecisionReason |
                Should -Match 'not parseable JSON'
        }

        It 'returns exit code 0 and emits a deny for JSON with no tool_input key' {
            $emitted = Invoke-ParallelWorktreeRemovalGateEntryPoint -ToolInputRaw '{"session_id":"s1","tool_name":"Bash"}'
            $emitted[-1] | Should -Be 0
            $emitted[-1] | Should -Not -Be 1
            ($emitted[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecisionReason |
                Should -Match 'no tool_input key'
        }

        It 'returns exit code 0 and emits a deny for a null tool_input' {
            $emitted = Invoke-ParallelWorktreeRemovalGateEntryPoint -ToolInputRaw '{"tool_name":"Bash","tool_input":null}'
            $emitted[-1] | Should -Be 0
            ($emitted[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecisionReason |
                Should -Match 'tool_input is null'
        }

        It 'returns exit code 0 and emits a deny for a non-object tool_input' {
            $emitted = Invoke-ParallelWorktreeRemovalGateEntryPoint -ToolInputRaw '{"tool_name":"Bash","tool_input":"text"}'
            $emitted[-1] | Should -Be 0
            ($emitted[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecisionReason |
                Should -Match 'not an object'
        }

        It 'denies the nested envelope end-to-end when no checkpoint record authorizes removal' {
            $nested = '{"tool_name":"Bash","tool_input":{"command":"git worktree remove /repo/worktrees/item-a-101"}}'
            $emitted = Invoke-ParallelWorktreeRemovalGateEntryPoint -ToolInputRaw $nested
            $emitted[-1] | Should -Be 0
            $parsed = $emitted[0] | ConvertFrom-Json
            $parsed.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
            $parsed.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $parsed.hookSpecificOutput.permissionDecisionReason | Should -Match 'PARALLEL_WORKTREE_REMOVAL_BLOCKED'
        }

        It 'allows the nested envelope when the checkpoint records the item as merged' {
            Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -MockWith {
                '{"items":[{"worktree_path":"/repo/worktrees/item-a-101","merge_status":"merged"}]}'
            }
            $nested = '{"tool_name":"Bash","tool_input":{"command":"git worktree remove /repo/worktrees/item-a-101"}}'
            $emitted = Invoke-ParallelWorktreeRemovalGateEntryPoint -ToolInputRaw $nested
            $emitted[-1] | Should -Be 0
            ($emitted[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }
}
