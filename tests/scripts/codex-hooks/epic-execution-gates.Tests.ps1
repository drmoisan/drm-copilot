#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'Codex epic preparation, wave, merge, and worktree gates' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:HookRoot = Join-Path $script:RepoRoot '.codex/hooks'
        . (Join-Path $script:HookRoot 'enforce-epic-planning-only.ps1')
        . (Join-Path $script:HookRoot 'enforce-epic-wave-barrier.ps1')
        . (Join-Path $script:HookRoot 'enforce-epic-merge-gate.ps1')
        . (Join-Path $script:HookRoot 'enforce-epic-worktree-removal-gate.ps1')
    }

    Context 'preparation route' {
        BeforeAll {
            $script:Preparation = '{"route_id":"preparation"}'
        }

        It 'allows feature planning document edits' {
            $patchText = [string]::Join([Environment]::NewLine, @(
                    '*** Begin Patch'
                    '*** Update File: docs/features/active/sample/spec.md'
                    '*** End Patch'
                ))
            $payload = @{
                tool_name  = 'apply_patch'
                tool_input = @{ command = $patchText }
            } | ConvertTo-Json -Compress

            Invoke-EpicPlanningOnlyDecision `
                -PayloadRaw $payload `
                -CheckpointRaw $script:Preparation `
                -StagedPaths @('docs/features/active/sample/spec.md') `
                -CurrentBranch 'feature/sample' |
                Should -BeNullOrEmpty
        }

        It 'denies production edits' {
            $patchText = [string]::Join([Environment]::NewLine, @(
                    '*** Begin Patch'
                    '*** Update File: src/service.py'
                    '*** End Patch'
                ))
            $payload = @{
                tool_name  = 'apply_patch'
                tool_input = @{ command = $patchText }
            } | ConvertTo-Json -Compress

            $decision = Invoke-EpicPlanningOnlyDecision -PayloadRaw $payload -CheckpointRaw $script:Preparation

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Match 'EPIC_PLANNING_ONLY_BLOCKED'
        }

        It 'denies PR creation and CI execution commands' -ForEach @(
            @{ Command = 'gh pr create --base main' }
            @{ Command = 'python -m pytest' }
            @{ Command = 'git status | Set-Content src/service.py' }
            @{ Command = 'git checkout -- src/service.py' }
            @{ Command = 'git push --force origin HEAD' }
            @{ Command = 'git add -A' }
        ) {
            $payload = @{
                tool_name  = 'Bash'
                tool_input = @{ command = $Command }
            } | ConvertTo-Json -Compress

            $decision = Invoke-EpicPlanningOnlyDecision -PayloadRaw $payload -CheckpointRaw $script:Preparation

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'allows explicit planning-artifact staging and an ordinary commit' -ForEach @(
            @{ Command = 'git add -- docs/features/active/sample/spec.md artifacts/research/sample.md' }
            @{ Command = 'git commit -m "docs: prepare sample feature"' }
            @{ Command = 'git push -u origin feature/sample' }
        ) {
            $payload = @{
                tool_name  = 'Bash'
                tool_input = @{ command = $Command }
            } | ConvertTo-Json -Compress

            Invoke-EpicPlanningOnlyDecision `
                -PayloadRaw $payload `
                -CheckpointRaw $script:Preparation `
                -StagedPaths @('docs/features/active/sample/spec.md') `
                -CurrentBranch 'feature/sample' |
                Should -BeNullOrEmpty
        }

        It 'denies deletion or route mutation of the canonical preparation checkpoint' -ForEach @(
            @{ Patch = "*** Begin Patch`n*** Delete File: artifacts/orchestration/orchestrator-state.json`n*** End Patch" }
            @{ Patch = "*** Begin Patch`n*** Update File: artifacts/orchestration/orchestrator-state.json`n@@`n-  `"route_id`": `"preparation`",`n+  `"route_id`": `"large`",`n*** End Patch" }
            @{ Patch = "*** Begin Patch`n*** Update File: artifacts/orchestration/orchestrator-state.json`n@@`n+  `"route_id`": `"standalone`",`n*** End Patch" }
            @{ Patch = "*** Begin Patch`n*** Update File: artifacts/orchestration/orchestrator-state.json`n@@`n+  `"x`": 1, `"route_id`": `"standalone`"`n*** End Patch" }
            @{ Patch = "*** Begin Patch`n*** Update File: artifacts/orchestration/orchestrator-state.json`n*** Move to: artifacts/research/archived-state.json`n@@`n {`n*** End Patch" }
        ) {
            $payload = @{
                tool_name  = 'apply_patch'
                tool_input = @{ command = $Patch }
            } | ConvertTo-Json -Compress

            $decision = Invoke-EpicPlanningOnlyDecision -PayloadRaw $payload -CheckpointRaw $script:Preparation

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Match 'EPIC_PLANNING_ONLY_BLOCKED'
        }

        It 'denies path traversal, move destinations, and security receipt writes' -ForEach @(
            @{ Patch = "*** Begin Patch`n*** Add File: docs/features/active/sample/../../../../src/service.py`n*** End Patch" }
            @{ Patch = "*** Begin Patch`n*** Update File: docs/features/active/sample/spec.md`n*** Move to: src/service.md`n*** End Patch" }
            @{ Patch = "*** Begin Patch`n*** Add File: artifacts/orchestration/codex-routing-attestation.fake.json`n*** End Patch" }
        ) {
            $payload = @{
                tool_name  = 'apply_patch'
                tool_input = @{ command = $Patch }
            } | ConvertTo-Json -Compress

            $decision = Invoke-EpicPlanningOnlyDecision `
                -PayloadRaw $payload `
                -CheckpointRaw $script:Preparation

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'fails closed for an attested preparation child before its checkpoint exists' {
            $payload = @{
                tool_name  = 'apply_patch'
                tool_input = @{ command = "*** Begin Patch`n*** Add File: src/service.py`n*** End Patch" }
            } | ConvertTo-Json -Compress

            $decision = Invoke-EpicPlanningOnlyDecision `
                -PayloadRaw $payload `
                -CheckpointRaw '' `
                -EpicExecutionContext 'epic_preparation_child'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'fails closed when an attested preparation child changes its checkpoint route' {
            $payload = @{
                tool_name = 'Bash'; tool_input = @{ command = 'git status' }
            } | ConvertTo-Json -Compress

            $decision = Invoke-EpicPlanningOnlyDecision `
                -PayloadRaw $payload `
                -CheckpointRaw '{"route_id":"large"}' `
                -EpicExecutionContext 'epic_preparation_child'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'requires explicit matching MCP workspace_root for an attested preparation child' {
            $payload = @{
                cwd        = $script:RepoRoot
                tool_name  = 'mcp__drm-copilot__new_active_feature_folder'
                tool_input = @{}
            } | ConvertTo-Json -Compress

            $decision = Invoke-EpicPlanningOnlyDecision `
                -PayloadRaw $payload `
                -CheckpointRaw $script:Preparation `
                -EpicExecutionContext 'epic_preparation_child'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Match 'workspace_root'
        }

        It 'denies a preparation commit when staged paths include production code' {
            $payload = @{
                tool_name  = 'Bash'
                tool_input = @{ command = 'git commit -m "docs: prepare sample"' }
            } | ConvertTo-Json -Compress

            $decision = Invoke-EpicPlanningOnlyDecision `
                -PayloadRaw $payload `
                -CheckpointRaw $script:Preparation `
                -StagedPaths @('docs/features/active/sample/spec.md', 'src/service.py')

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'allows only preparation lifecycle MCP operations' {
            $allowedPayload = @{
                tool_name  = 'mcp__drm-copilot__new_active_feature_folder'
                tool_input = @{}
            } | ConvertTo-Json -Compress
            $deniedPayload = @{
                tool_name  = 'mcp__drm-copilot__collect_pr_context'
                tool_input = @{}
            } | ConvertTo-Json -Compress

            Invoke-EpicPlanningOnlyDecision -PayloadRaw $allowedPayload -CheckpointRaw $script:Preparation |
                Should -BeNullOrEmpty
            (Invoke-EpicPlanningOnlyDecision -PayloadRaw $deniedPayload -CheckpointRaw $script:Preparation).
            hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'denies non-repository MCP tools during preparation' {
            $payload = @{
                tool_name  = 'mcp__codex_apps__github_create_pull_request'
                tool_input = @{}
            } | ConvertTo-Json -Compress

            (Invoke-EpicPlanningOnlyDecision -PayloadRaw $payload -CheckpointRaw $script:Preparation).
            hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'denies commit pathspecs and broad push modes' -ForEach @(
            @{ Command = 'git commit -m "docs: prepare" src/service.py' }
            @{ Command = 'git push --all' }
            @{ Command = 'git push --mirror' }
            @{ Command = 'git push origin --all' }
            @{ Command = 'git diff --output=src/service.py HEAD' }
            @{ Command = 'rg --pre Set-Content pattern .' }
        ) {
            Test-EpicPlanningBashAllowed -Command $Command `
                -StagedPaths @('docs/features/active/sample/spec.md') `
                -CurrentBranch 'feature/sample' | Should -BeFalse
        }
    }

    Context 'wave barrier' {
        BeforeAll {
            $script:MutationPayload = @{
                tool_name  = 'apply_patch'
                tool_input = @{ command = '*** Begin Patch' }
            } | ConvertTo-Json -Compress
            $script:LocalEpicChild = @{
                epic_mode      = $true
                feature_folder = 'child-b'
            } | ConvertTo-Json -Compress
        }

        It 'allows a child after every dependency is merged' {
            $epic = @{
                features = @(
                    @{ issue_num = 101; feature_folder = 'child-a'; depends_on = @(); merge_status = 'merged' }
                    @{ issue_num = 102; feature_folder = 'child-b'; depends_on = @(101); merge_status = 'not_started' }
                )
            } | ConvertTo-Json -Compress -Depth 5

            Invoke-CodexEpicWaveDecision -PayloadRaw $script:MutationPayload -LocalCheckpointRaw $script:LocalEpicChild -EpicCheckpointRaw $epic |
                Should -BeNullOrEmpty
        }

        It 'denies a child before an upstream merge' {
            $epic = @{
                features = @(
                    @{ issue_num = 101; feature_folder = 'child-a'; depends_on = @(); merge_status = 'pr_open' }
                    @{ issue_num = 102; feature_folder = 'child-b'; depends_on = @(101); merge_status = 'not_started' }
                )
            } | ConvertTo-Json -Compress -Depth 5

            $decision = Invoke-CodexEpicWaveDecision -PayloadRaw $script:MutationPayload -LocalCheckpointRaw $script:LocalEpicChild -EpicCheckpointRaw $epic

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Match 'EPIC_WAVE_BARRIER_BLOCKED'
        }

        It 'does not apply the execution barrier to preparation children' {
            $local = '{"route_id":"preparation","epic_mode":false}'

            Invoke-CodexEpicWaveDecision -PayloadRaw $script:MutationPayload -LocalCheckpointRaw $local -EpicCheckpointRaw '' |
                Should -BeNullOrEmpty
        }
    }

    Context 'merge gate' {
        BeforeAll {
            $script:MergePayload = @{
                tool_name  = 'Bash'
                tool_input = @{ command = 'gh pr merge 42 --merge' }
            } | ConvertTo-Json -Compress
        }

        It 'allows a verified epic child merge' {
            $child = '{"epic_mode":true,"step9_status":"verified"}'

            Invoke-CodexEpicMergeDecision -PayloadRaw $script:MergePayload -ChildCheckpointRaw $child -EpicCheckpointRaw '' |
                Should -BeNullOrEmpty
        }

        It 'allows the matching final epic PR after a successful CI gate' {
            $epic = '{"epic_merge_pr":{"pr_number":42,"ci_gate":{"conclusion":"success"}}}'

            Invoke-CodexEpicMergeDecision -PayloadRaw $script:MergePayload -ChildCheckpointRaw '' -EpicCheckpointRaw $epic |
                Should -BeNullOrEmpty
        }

        It 'denies a mismatched final PR number' {
            $epic = '{"epic_merge_pr":{"pr_number":41,"ci_gate":{"conclusion":"success"}}}'

            $decision = Invoke-CodexEpicMergeDecision -PayloadRaw $script:MergePayload -ChildCheckpointRaw '' -EpicCheckpointRaw $epic

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Match 'EPIC_MERGE_GATE_BLOCKED'
        }
    }

    Context 'worktree removal gate' {
        BeforeAll {
            $script:WorktreePath = Join-Path $script:RepoRoot 'worktrees/child-a'
            $script:WorktreePayload = @{
                cwd        = $script:RepoRoot
                tool_name  = 'Bash'
                tool_input = @{ command = 'git worktree remove "' + $script:WorktreePath + '"' }
            } | ConvertTo-Json -Compress
        }

        It 'allows removal after merge' {
            $checkpoint = @{
                features = @(
                    @{ worktree_path = $script:WorktreePath; merge_status = 'merged' }
                )
            } | ConvertTo-Json -Compress -Depth 4

            Invoke-CodexWorktreeRemovalDecision -PayloadRaw $script:WorktreePayload -EpicCheckpointRaw $checkpoint |
                Should -BeNullOrEmpty
        }

        It 'denies removal while the PR is open' {
            $checkpoint = @{
                features = @(
                    @{ worktree_path = $script:WorktreePath; merge_status = 'pr_open' }
                )
            } | ConvertTo-Json -Compress -Depth 4

            $decision = Invoke-CodexWorktreeRemovalDecision -PayloadRaw $script:WorktreePayload -EpicCheckpointRaw $checkpoint

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Match 'EPIC_WORKTREE_REMOVAL_BLOCKED'
        }
    }

    It 'fails closed on malformed Codex stdin JSON' {
        { Invoke-EpicPlanningOnlyDecision -PayloadRaw '{broken' -CheckpointRaw '{}' } |
            Should -Throw
        { Invoke-CodexEpicWaveDecision -PayloadRaw '{broken' -LocalCheckpointRaw '' -EpicCheckpointRaw '' } |
            Should -Throw
        { Invoke-CodexEpicMergeDecision -PayloadRaw '{broken' -ChildCheckpointRaw '' -EpicCheckpointRaw '' } |
            Should -Throw
        { Invoke-CodexWorktreeRemovalDecision -PayloadRaw '{broken' -EpicCheckpointRaw '' } |
            Should -Throw
    }
}
