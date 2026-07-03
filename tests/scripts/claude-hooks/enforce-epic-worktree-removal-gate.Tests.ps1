#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Pester tests for the enforce-epic-worktree-removal-gate.ps1 PreToolUse hook.
#>

Describe 'enforce-epic-worktree-removal-gate.ps1' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-worktree-removal-gate.ps1").Path
        . $script:UnderTest
    }

    Context 'commands outside scope' {
        It 'allows when CLAUDE_TOOL_INPUT is empty' {
            $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw ''
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows when the JSON payload has no command field' {
            $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw '{"other":"value"}'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows a non git-worktree-remove Bash command' {
            $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw '{"command":"git worktree list"}'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'throws on malformed JSON so the hook exits 1' {
            { Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw '{not-json' } | Should -Throw
        }
    }

    Context 'allow on merge_status merged' {
        It 'allows git worktree remove when the matching record has merge_status merged' {
            Mock -CommandName Get-EpicWorktreeGateCheckpointContent -MockWith {
                '{"features":[{"worktree_path":"/repo/worktrees/child-a","merge_status":"merged"}]}'
            }
            $json = '{"command":"git worktree remove /repo/worktrees/child-a"}'
            $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'allow on merge_status worktree_removed' {
        It 'allows git worktree remove when the matching record has merge_status worktree_removed' {
            Mock -CommandName Get-EpicWorktreeGateCheckpointContent -MockWith {
                '{"features":[{"worktree_path":"/repo/worktrees/child-a","merge_status":"worktree_removed"}]}'
            }
            $json = '{"command":"git worktree remove /repo/worktrees/child-a"}'
            $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'deny on unreadable checkpoint' {
        It 'denies EPIC_WORKTREE_REMOVAL_BLOCKED when the checkpoint file is absent' {
            Mock -CommandName Get-EpicWorktreeGateCheckpointContent -MockWith { $null }
            $json = '{"command":"git worktree remove /repo/worktrees/child-a"}'
            $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_WORKTREE_REMOVAL_BLOCKED'
        }

        It 'denies EPIC_WORKTREE_REMOVAL_BLOCKED when the checkpoint content is malformed JSON' {
            Mock -CommandName Get-EpicWorktreeGateCheckpointContent -MockWith { '{ broken json' }
            $json = '{"command":"git worktree remove /repo/worktrees/child-a"}'
            $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_WORKTREE_REMOVAL_BLOCKED'
        }
    }

    Context 'deny on no matching record' {
        It 'denies when no features[] record has a matching worktree_path' {
            Mock -CommandName Get-EpicWorktreeGateCheckpointContent -MockWith {
                '{"features":[{"worktree_path":"/repo/worktrees/child-b","merge_status":"merged"}]}'
            }
            $json = '{"command":"git worktree remove /repo/worktrees/child-a"}'
            $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_WORKTREE_REMOVAL_BLOCKED'
        }
    }

    Context 'deny on other merge_status' {
        It 'denies when the matching record has merge_status pr_open' {
            Mock -CommandName Get-EpicWorktreeGateCheckpointContent -MockWith {
                '{"features":[{"worktree_path":"/repo/worktrees/child-a","merge_status":"pr_open"}]}'
            }
            $json = '{"command":"git worktree remove /repo/worktrees/child-a"}'
            $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_WORKTREE_REMOVAL_BLOCKED'
        }
    }

    Context 'path normalization' {
        It 'matches worktree_path across backslash/forward-slash separator differences' {
            Mock -CommandName Get-EpicWorktreeGateCheckpointContent -MockWith {
                '{"features":[{"worktree_path":"C:\\repo\\worktrees\\child-a","merge_status":"merged"}]}'
            }
            $json = '{"command":"git worktree remove C:/repo/worktrees/child-a"}'
            $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'Get-EpicWorktreeRemovalCommandPath helper' {
        It 'extracts the target path from the command text' {
            Get-EpicWorktreeRemovalCommandPath -CommandText 'git worktree remove /repo/worktrees/child-a' |
                Should -Be '/repo/worktrees/child-a'
        }

        It 'returns $null when the command does not name a path' {
            Get-EpicWorktreeRemovalCommandPath -CommandText 'git status' | Should -BeNullOrEmpty
        }
    }

    Context 'Find-EpicWorktreeFeatureRecord helper' {
        It 'returns $null when Checkpoint is $null' {
            Find-EpicWorktreeFeatureRecord -Checkpoint $null -WorktreePath '/repo/a' | Should -BeNullOrEmpty
        }

        It 'returns $null when features key is absent' {
            $checkpoint = '{}' | ConvertFrom-Json
            Find-EpicWorktreeFeatureRecord -Checkpoint $checkpoint -WorktreePath '/repo/a' | Should -BeNullOrEmpty
        }

        It 'skips feature records with no worktree_path key' {
            $checkpoint = '{"features":[{"feature_folder":"a"}]}' | ConvertFrom-Json
            Find-EpicWorktreeFeatureRecord -Checkpoint $checkpoint -WorktreePath '/repo/a' | Should -BeNullOrEmpty
        }
    }

    Context 'Test-EpicWorktreeRemovalAllowed helper' {
        It 'returns $false when FeatureRecord is $null' {
            Test-EpicWorktreeRemovalAllowed -FeatureRecord $null | Should -BeFalse
        }

        It 'returns $false when merge_status key is absent' {
            $feature = '{"feature_folder":"a"}' | ConvertFrom-Json
            Test-EpicWorktreeRemovalAllowed -FeatureRecord $feature | Should -BeFalse
        }
    }

    Context 'real Test-Path read seam' {
        It 'Get-EpicWorktreeGateCheckpointContent returns $null when the checkpoint file does not exist' {
            Mock -CommandName Test-Path -MockWith { $false } -ParameterFilter { $LiteralPath -eq $script:EpicCheckpointPath }
            Get-EpicWorktreeGateCheckpointContent | Should -BeNullOrEmpty
        }

        It 'Get-EpicWorktreeGateCheckpointContent reads real content when the file exists' {
            Mock -CommandName Test-Path -MockWith { $true } -ParameterFilter { $LiteralPath -eq $script:EpicCheckpointPath }
            Mock -CommandName Get-Content -MockWith { '{"features":[]}' } -ParameterFilter { $LiteralPath -eq $script:EpicCheckpointPath }
            Get-EpicWorktreeGateCheckpointContent | Should -Be '{"features":[]}'
        }
    }

    Context 'script entrypoint (end-to-end)' {
        BeforeAll {
            $script:HookPath = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-worktree-removal-gate.ps1").Path
            $script:PwshExe = if ($PSVersionTable.PSVersion.Major -ge 7 -and $PSEdition -eq 'Core') {
                (Get-Process -Id $PID).Path
            } else {
                (Get-Command pwsh -CommandType Application -ErrorAction Stop).Source
            }
        }

        It 'allows when CLAUDE_TOOL_INPUT is empty (exit 0, allow)' {
            $prev = $env:CLAUDE_TOOL_INPUT
            try {
                $env:CLAUDE_TOOL_INPUT = ''
                $out = & $script:PwshExe -NoProfile -File $script:HookPath
                $LASTEXITCODE | Should -Be 0
                ($out | ConvertFrom-Json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
            } finally {
                $env:CLAUDE_TOOL_INPUT = $prev
            }
        }

        It 'exits 1 on malformed JSON' {
            $prev = $env:CLAUDE_TOOL_INPUT
            try {
                $env:CLAUDE_TOOL_INPUT = '{not-json'
                $null = & $script:PwshExe -NoProfile -File $script:HookPath 2>&1
                $LASTEXITCODE | Should -Be 1
            } finally {
                $env:CLAUDE_TOOL_INPUT = $prev
            }
        }
    }
}
