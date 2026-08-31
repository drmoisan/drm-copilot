#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'Codex epic preparation, wave, merge, and worktree gates' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:HookRoot = Join-Path $script:RepoRoot '.codex/hooks'
        $script:PwshPath = (
            Get-Command pwsh -CommandType Application -ErrorAction Stop |
                Select-Object -First 1
        ).Source
        . (Join-Path $script:HookRoot 'enforce-epic-planning-only.ps1')
        . (Join-Path $script:HookRoot 'enforce-epic-wave-barrier.ps1')
        . (Join-Path $script:HookRoot 'enforce-epic-merge-gate.ps1')
        . (Join-Path $script:HookRoot 'enforce-epic-worktree-removal-gate.ps1')

        function Invoke-EpicPlanningDecisionProcess {
            [CmdletBinding()]
            param([Parameter(Mandatory)][string] $PayloadRaw)

            $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
            $startInfo.FileName = $script:PwshPath
            $startInfo.ArgumentList.Add('-NoProfile')
            $startInfo.ArgumentList.Add('-Command')
            $startInfo.ArgumentList.Add(@'
. $env:EPIC_PLANNING_HOOK_PATH
$decision = Invoke-EpicPlanningOnlyDecision `
    -PayloadRaw $env:EPIC_PLANNING_PAYLOAD `
    -CheckpointRaw '{"route_id":"preparation"}'
if ($null -ne $decision) {
    $decision | ConvertTo-Json -Compress -Depth 5 | Write-Output
}
exit 0
'@)
            $startInfo.WorkingDirectory = $script:RepoRoot
            $startInfo.RedirectStandardOutput = $true
            $startInfo.RedirectStandardError = $true
            $startInfo.UseShellExecute = $false
            $startInfo.Environment['EPIC_PLANNING_HOOK_PATH'] = Join-Path $script:HookRoot 'enforce-epic-planning-only.ps1'
            $startInfo.Environment['EPIC_PLANNING_PAYLOAD'] = $PayloadRaw

            $process = [System.Diagnostics.Process]::Start($startInfo)
            $stdout = $process.StandardOutput.ReadToEnd()
            $stderr = $process.StandardError.ReadToEnd()
            $process.WaitForExit()
            return [pscustomobject]@{
                ExitCode = $process.ExitCode
                Stdout   = $stdout.Trim()
                Stderr   = $stderr.Trim()
            }
        }
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

        It 'allows both registered MCP server spellings identically for <Operation>' -ForEach @(
            @{ Operation = 'validate_orchestration_artifacts' }
            @{ Operation = 'resolve_orchestration_topology' }
            @{ Operation = 'resolve_provider_routing' }
            @{ Operation = 'transition_prepared_orchestration' }
        ) {
            $hyphenPayload = @{
                tool_name = "mcp__drm-copilot__$Operation"; tool_input = @{}
            } | ConvertTo-Json -Compress
            $underscorePayload = @{
                tool_name = "mcp__drm_copilot__$Operation"; tool_input = @{}
            } | ConvertTo-Json -Compress

            $hyphen = Invoke-EpicPlanningDecisionProcess -PayloadRaw $hyphenPayload
            $underscore = Invoke-EpicPlanningDecisionProcess -PayloadRaw $underscorePayload

            $hyphen.ExitCode | Should -Be 0
            $hyphen.Stdout | Should -BeNullOrEmpty
            $hyphen.Stderr | Should -BeNullOrEmpty
            $underscore.ExitCode | Should -Be $hyphen.ExitCode
            $underscore.Stdout | Should -Be $hyphen.Stdout
            $underscore.Stderr | Should -Be $hyphen.Stderr
        }

        It 'denies <Label> exactly without changing checkpoint bytes' -ForEach @(
            @{ Label = 'malformed MCP id'; ToolName = 'mcp__drm_copilot_resolve_provider_routing'; ToolInput = @{}; Reason = "MCP tool 'mcp__drm_copilot_resolve_provider_routing' is outside the registered preparation lifecycle and semantic allowlist." }
            @{ Label = 'unrelated MCP server'; ToolName = 'mcp__other__resolve_provider_routing'; ToolInput = @{}; Reason = "MCP tool 'mcp__other__resolve_provider_routing' is outside the registered preparation lifecycle and semantic allowlist." }
            @{ Label = 'unregistered MCP operation'; ToolName = 'mcp__drm-copilot__collect_pr_context'; ToolInput = @{}; Reason = "MCP tool 'mcp__drm-copilot__collect_pr_context' is outside the registered preparation lifecycle and semantic allowlist." }
            @{ Label = 'approximate MCP operation'; ToolName = 'mcp__drm_copilot__resolve_provider_routing_approximate'; ToolInput = @{}; Reason = "MCP tool 'mcp__drm_copilot__resolve_provider_routing_approximate' is outside the registered preparation lifecycle and semantic allowlist." }
            @{ Label = 'shell edit'; ToolName = 'Bash'; ToolInput = @{ command = 'Set-Content src/service.ps1 unsafe' }; Reason = 'the Bash command is outside the preparation read, branch, commit, push, or validator allowlist.' }
            @{ Label = 'production patch'; ToolName = 'apply_patch'; ToolInput = @{ command = "*** Begin Patch`n*** Update File: src/service.py`n*** End Patch" }; Reason = "preparation may not edit 'src/service.py'; only feature planning documents and orchestration/research artifacts are writable." }
        ) {
            $checkpointPath = Join-Path $script:RepoRoot 'artifacts/orchestration/orchestrator-state.json'
            $before = [Convert]::ToBase64String([IO.File]::ReadAllBytes($checkpointPath))
            $payload = @{ tool_name = $ToolName; tool_input = $ToolInput } |
                ConvertTo-Json -Compress -Depth 10
            $expected = [ordered]@{
                hookSpecificOutput = [ordered]@{
                    hookEventName            = 'PreToolUse'
                    permissionDecision       = 'deny'
                    permissionDecisionReason = "EPIC_PLANNING_ONLY_BLOCKED: $Reason"
                }
            } | ConvertTo-Json -Compress -Depth 5

            $result = Invoke-EpicPlanningDecisionProcess -PayloadRaw $payload

            $result.ExitCode | Should -Be 0
            $result.Stdout | Should -Be $expected
            $result.Stderr | Should -BeNullOrEmpty
            [Convert]::ToBase64String([IO.File]::ReadAllBytes($checkpointPath)) |
                Should -Be $before
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
