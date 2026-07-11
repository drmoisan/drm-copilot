#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'Codex epic-child worktree launcher and guard' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot '.codex/scripts/launch-epic-child-wave.ps1')
        . (Join-Path $script:RepoRoot '.codex/hooks/enforce-epic-child-worktree-binding.ps1')

        $script:Profile = [pscustomobject]@{
            name                   = 'orchestrator-c3-elevated'
            model                  = 'gpt-5.6-sol'
            model_reasoning_effort = 'high'
            default_permissions    = 'orchestrator-workspace'
            developer_instructions = "exact`ninstructions"
            skills_config          = '[{ name = "orchestrate", enabled = true }]'
            profile_path           = Join-Path $script:RepoRoot '.codex/agents/orchestrator-c3-elevated.toml'
            profile_sha256         = ('a' * 64)
            worktree_path          = $script:RepoRoot
        }
        $script:Entry = [pscustomobject]@{
            launch_id              = 'wave-1-child-a'
            delegation_id          = 'delegate-child-a'
            feature_folder         = 'docs/features/active/child-a'
            issue_num              = 101
            deployment_agent       = 'orchestrator-c3-elevated'
            model                  = 'gpt-5.6-sol'
            model_reasoning_effort = 'high'
            permissions            = 'orchestrator-workspace'
            execution_context      = 'epic_execution_child'
            worktree_path          = $script:RepoRoot
            branch_name            = 'feature/child-a'
            prompt                 = 'Epic mode: true. epic_feature_folder: sample-epic. integration_branch: epic/sample-integration. PR base branch MUST be epic/sample-integration, not main; pass --base epic/sample-integration to gh pr create.'
        }
        $script:ModelReceipt = [pscustomobject]@{
            delegation_id          = 'delegate-child-a'
            deployment_agent       = 'orchestrator-c3-elevated'
            model                  = 'gpt-5.6-sol'
            model_reasoning_effort = 'high'
            execution_context      = 'epic_execution_child'
        }
        $script:DelegationReceipt = [pscustomobject]@{
            delegation_id  = 'delegate-child-a'
            agent_name     = 'orchestrator-c3-elevated'
            feature_folder = 'docs/features/active/child-a'
            issue_num      = 101
        }
        $script:Feature = [pscustomobject]@{
            issue_num             = 101
            feature_folder        = 'docs/features/active/child-a'
            wave_number           = 1
            worktree_path         = $script:RepoRoot
            branch_name           = 'feature/child-a'
            model_routing_receipt = $script:ModelReceipt
            delegation_receipt    = $script:DelegationReceipt
        }
        $script:Checkpoint = [pscustomobject]@{
            integration_branch    = 'epic/sample-integration'
            epic_feature_folder   = 'sample-epic'
            max_parallel_features = 4
            features              = @($script:Feature)
        }
        $script:Spec = [pscustomobject]@{
            schema_version        = 1
            checkpoint_kind       = 'epic-orchestrator'
            wave_id               = 'sample-wave-1'
            wave_number           = 1
            max_parallel_features = 4
            integration_branch    = 'epic/sample-integration'
            checkpoint_path       = 'artifacts/orchestration/epic-orchestrator-state.json'
            launches              = @($script:Entry)
        }
        $profileKey = Get-CodexChildProfileKey -WorktreePath $script:RepoRoot `
            -AgentName 'orchestrator-c3-elevated' -RepositoryRoot $script:RepoRoot
        $script:Profiles = @{ $profileKey = $script:Profile }
        $script:Branches = @{ $script:RepoRoot = 'feature/child-a' }
    }

    Context 'immutable launch specification validation' {
        It 'accepts a feature, delegation, branch, worktree, model receipt, and profile that all match' {
            $errors = Test-CodexChildLaunchSpec -Spec $script:Spec -Checkpoint $script:Checkpoint `
                -RepositoryRoot $script:RepoRoot -ProfilesByKey $script:Profiles `
                -LiveBranchesByWorktree $script:Branches
            $errors | Should -BeNullOrEmpty
        }

        It 'rejects a missing exact delegation receipt' {
            $entry = $script:Entry.PSObject.Copy()
            $entry.delegation_id = 'different-delegation'
            $spec = $script:Spec.PSObject.Copy()
            $spec.launches = @($entry)
            $errors = Test-CodexChildLaunchSpec -Spec $spec -Checkpoint $script:Checkpoint `
                -RepositoryRoot $script:RepoRoot -ProfilesByKey $script:Profiles `
                -LiveBranchesByWorktree $script:Branches

            $errors | Should -Contain "launch 'wave-1-child-a' has no matching delegation receipt."
        }

        It 'rejects model, reasoning, permission, and worktree branch drift' {
            $agentProfile = $script:Profile.PSObject.Copy()
            $agentProfile.model_reasoning_effort = 'medium'
            $profiles = @{ $profileKey = $agentProfile }
            $branches = @{ $script:RepoRoot = 'feature/other' }
            $errors = Test-CodexChildLaunchSpec -Spec $script:Spec -Checkpoint $script:Checkpoint `
                -RepositoryRoot $script:RepoRoot -ProfilesByKey $profiles `
                -LiveBranchesByWorktree $branches

            $errors | Should -Contain "launch 'wave-1-child-a' worktree is not canonical or its live branch does not match."
            $errors | Should -Contain "launch 'wave-1-child-a' differs from its checked-in generated profile."
        }

        It 'requires bounded parallelism to match the checkpoint and remain at most eight' {
            $spec = $script:Spec.PSObject.Copy()
            $spec.max_parallel_features = 9
            $checkpoint = $script:Checkpoint.PSObject.Copy()
            $checkpoint.max_parallel_features = 9

            $errors = Test-CodexChildLaunchSpec -Spec $spec -Checkpoint $checkpoint `
                -RepositoryRoot $script:RepoRoot -ProfilesByKey $script:Profiles `
                -LiveBranchesByWorktree $script:Branches

            $errors | Should -Contain 'max_parallel_features must match the checkpoint and be between 1 and 8.'
            Get-CodexChildEffectiveMaximum -RequestedMaximum 3 -SpecMaximum 8 | Should -Be 3
        }

        It 'launches all planner preparations in one batch after final identity promotion' {
            $worktreeA = Join-Path $script:RepoRoot 'worktrees/preparation-a'
            $worktreeB = Join-Path $script:RepoRoot 'worktrees/preparation-b'
            $entryA = $script:Entry.PSObject.Copy()
            $entryA.launch_id = 'prepare-child-a'
            $entryA.delegation_id = 'prepare-delegation-a'
            $entryA.issue_num = 101
            $entryA.worktree_path = $worktreeA
            $entryA.execution_context = 'epic_preparation_child'
            $entryA.prompt = 'Preparation mode: true. Prepare child-a only.'
            $entryB = $entryA.PSObject.Copy()
            $entryB.launch_id = 'prepare-child-b'
            $entryB.delegation_id = 'prepare-delegation-b'
            $entryB.issue_num = 102
            $entryB.feature_folder = 'docs/features/active/child-b'
            $entryB.worktree_path = $worktreeB
            $entryB.branch_name = 'feature/child-b'
            $entryB.prompt = 'Preparation mode: true. Prepare child-b only.'
            $modelA = $script:ModelReceipt.PSObject.Copy()
            $modelA.delegation_id = 'prepare-delegation-a'
            $modelA.execution_context = 'epic_preparation_child'
            $modelB = $modelA.PSObject.Copy()
            $modelB.delegation_id = 'prepare-delegation-b'
            $delegationA = [pscustomobject]@{
                delegation_id = 'prepare-delegation-a'; agent_name = 'orchestrator-c3-elevated'
                feature_folder = 'docs/features/active/child-a'; issue_num = 101
            }
            $delegationB = [pscustomobject]@{
                delegation_id = 'prepare-delegation-b'; agent_name = 'orchestrator-c3-elevated'
                feature_folder = 'docs/features/active/child-b'; issue_num = 102
            }
            $featureA = [pscustomobject]@{
                issue_num = 101; feature_folder = 'docs/features/active/child-a'; wave = 0
                worktree_path = $worktreeA; branch_name = 'feature/child-a'
                model_routing_receipt = $modelA; delegation_receipt = $delegationA
            }
            $featureB = [pscustomobject]@{
                issue_num = 102; feature_folder = 'docs/features/active/child-b'; wave = 3
                worktree_path = $worktreeB; branch_name = 'feature/child-b'
                model_routing_receipt = $modelB; delegation_receipt = $delegationB
            }
            $checkpoint = [pscustomobject]@{
                integration_branch = 'epic/sample-integration'; max_parallel_features = 4
                epic_feature_folder = 'sample-epic'
                features            = @($featureA, $featureB)
            }
            $spec = [pscustomobject]@{
                schema_version = 1; checkpoint_kind = 'epic-planner'
                wave_id = 'preparation-batch'; wave_number = 0; max_parallel_features = 4
                integration_branch = 'epic/sample-integration'
                checkpoint_path    = 'artifacts/orchestration/epic-planner-state.json'
                launches           = @($entryA, $entryB)
            }
            $branches = @{ $worktreeA = 'feature/child-a'; $worktreeB = 'feature/child-b' }
            $profileA = $script:Profile.PSObject.Copy(); $profileA.worktree_path = $worktreeA
            $profileB = $script:Profile.PSObject.Copy(); $profileB.worktree_path = $worktreeB
            $keyA = Get-CodexChildProfileKey -WorktreePath $worktreeA `
                -AgentName 'orchestrator-c3-elevated' -RepositoryRoot $script:RepoRoot
            $keyB = Get-CodexChildProfileKey -WorktreePath $worktreeB `
                -AgentName 'orchestrator-c3-elevated' -RepositoryRoot $script:RepoRoot
            $profiles = @{ $keyA = $profileA; $keyB = $profileB }

            $errors = Test-CodexChildLaunchSpec -Spec $spec -Checkpoint $checkpoint `
                -RepositoryRoot $script:RepoRoot -ProfilesByKey $profiles `
                -LiveBranchesByWorktree $branches
            $codexRuntime = [pscustomobject]@{ CommandPath = 'codex.exe'; DeniedPaths = @('C:\codex.exe') }
            $receipt = Get-CodexChildLaunchReceipt -Spec $spec -Entry $entryA `
                -AgentProfile $profileA -CodexRuntime $codexRuntime `
                -SpecPath 'spec.json' -SpecSha256 ('a' * 64) `
                -CheckpointPath 'checkpoint.json' -CheckpointSha256 ('b' * 64) `
                -ReceiptPath 'receipt.json' -StatusPath 'status.json' -CodexHomePath 'C:\isolated' `
                -WaveLockPath 'C:\wave.lock'

            $errors | Should -BeNullOrEmpty
            $receipt.issue_num | Should -BeExactly 101
        }

        It 'rejects execution prompts missing required epic identity, branch, or PR-base markers' {
            $requiredMarkers = @(
                'Epic mode: true.',
                'epic_feature_folder: sample-epic',
                'integration_branch: epic/sample-integration',
                '--base epic/sample-integration'
            )
            foreach ($marker in $requiredMarkers) {
                $entry = $script:Entry.PSObject.Copy()
                $entry.prompt = $script:Entry.prompt.Replace($marker, '')
                $spec = $script:Spec.PSObject.Copy()
                $spec.launches = @($entry)

                $errors = Test-CodexChildLaunchSpec -Spec $spec -Checkpoint $script:Checkpoint `
                    -RepositoryRoot $script:RepoRoot -ProfilesByKey $script:Profiles `
                    -LiveBranchesByWorktree $script:Branches

                $errors | Should -Contain "launch 'wave-1-child-a' execution prompt is missing: $marker"
            }
        }

        It 'rejects a prepared execution prompt without its plan path and atomic-execution resume text' {
            $feature = $script:Feature.PSObject.Copy()
            $feature | Add-Member -NotePropertyName plan_path `
                -NotePropertyValue 'docs/features/active/child-a/plan.md'
            $checkpoint = $script:Checkpoint.PSObject.Copy()
            $checkpoint.features = @($feature)

            $errors = Test-CodexChildLaunchSpec -Spec $script:Spec -Checkpoint $checkpoint `
                -RepositoryRoot $script:RepoRoot -ProfilesByKey $script:Profiles `
                -LiveBranchesByWorktree $script:Branches

            $errors | Should -Contain "launch 'wave-1-child-a' prepared execution prompt must include plan_path and atomic-execution resume text."
        }

        It 'rejects a planner prompt without the literal preparation marker' {
            $entry = $script:Entry.PSObject.Copy()
            $entry.execution_context = 'epic_preparation_child'
            $entry.prompt = 'Prepare this child.'
            $modelReceipt = $script:ModelReceipt.PSObject.Copy()
            $modelReceipt.execution_context = 'epic_preparation_child'
            $feature = $script:Feature.PSObject.Copy()
            $feature.model_routing_receipt = $modelReceipt
            $checkpoint = [pscustomobject]@{
                integration_branch = 'epic/sample-integration'; epic_feature_folder = 'sample-epic'
                max_parallel_features = 4; features = @($feature)
            }
            $spec = $script:Spec.PSObject.Copy()
            $spec.checkpoint_kind = 'epic-planner'
            $spec.checkpoint_path = 'artifacts/orchestration/epic-planner-state.json'
            $spec.wave_number = 0
            $spec.launches = @($entry)

            $errors = Test-CodexChildLaunchSpec -Spec $spec -Checkpoint $checkpoint `
                -RepositoryRoot $script:RepoRoot -ProfilesByKey $script:Profiles `
                -LiveBranchesByWorktree $script:Branches

            $errors | Should -Contain "launch 'wave-1-child-a' planner prompt is missing 'Preparation mode: true'."
        }

        It 'extracts the exact executable agent profile values' {
            $raw = @'
name = "orchestrator-c3-elevated"
model = "gpt-5.6-sol"
model_reasoning_effort = "high"
default_permissions = "orchestrator-workspace"
developer_instructions = '''
exact instructions
'''

[skills]
config = [
    { name = "orchestrate", enabled = true },
]
'@
            $agentProfile = ConvertFrom-CodexAgentProfile -ProfileRaw $raw

            $agentProfile.name | Should -Be 'orchestrator-c3-elevated'
            $agentProfile.developer_instructions | Should -Match 'exact instructions'
            $agentProfile.skills_config | Should -Match 'name = "orchestrate"'
        }

        It 'builds codex exec with exact model, reasoning, instructions, skills, permissions, and worktree' {
            $receipt = [pscustomobject]@{
                launch_id              = 'wave-1-child-a'
                receipt_path           = 'C:\receipts\child.json'
                spec_path              = 'C:\receipts\spec.json'
                worktree_path          = $script:RepoRoot
                delegation_id          = 'delegate-child-a'
                deployment_agent       = 'orchestrator-c3-elevated'
                model                  = 'gpt-5.6-sol'
                model_reasoning_effort = 'high'
                execution_context      = 'epic_execution_child'
                profile_sha256         = ('a' * 64)
                profile_path           = Join-Path $script:RepoRoot '.codex/agents/orchestrator-c3-elevated.toml'
                codex_command_path     = 'codex.exe'
                codex_denied_paths     = @('C:\codex.exe')
                codex_home_path        = 'C:\isolated'
            }

            $info = Get-CodexChildProcessStartInfo -Entry $script:Entry -AgentProfile $script:Profile `
                -Receipt $receipt -LastMessagePath 'C:\status\last.txt'
            $arguments = [string[]]$info.ArgumentList

            $arguments | Should -Contain $script:RepoRoot
            $arguments | Should -Contain 'gpt-5.6-sol'
            $arguments | Should -Contain 'model_reasoning_effort=high'
            ($arguments -join "`n") | Should -Match 'developer_instructions='
            ($arguments -join "`n") | Should -Match 'skills\.config='
            ($arguments -join "`n") | Should -Match 'default_permissions='
            $arguments | Should -Contain 'approval_policy="never"'
            $arguments | Should -Contain '--ignore-user-config'
            $arguments | Should -Contain 'windows.sandbox="elevated"'
            ($arguments -join "`n") | Should -Match 'projects=\{'
            ($arguments -join "`n") | Should -Match 'permissions\.epic-child-workspace='
            $arguments | Should -Contain '--dangerously-bypass-hook-trust'
            $arguments | Should -Not -Contain '--dangerously-bypass-approvals-and-sandbox'
            $info.WorkingDirectory | Should -Be $script:RepoRoot
            $info.Environment['CODEX_EPIC_CHILD_DELEGATION_ID'] | Should -Be 'delegate-child-a'
            $info.Environment['CODEX_EPIC_CHILD_EXECUTION_CONTEXT'] | Should -Be 'epic_execution_child'
        }

        It 'requires clean child-worktree customizations before bypassing hook trust' {
            $runtime = Get-Content -Raw -LiteralPath (Join-Path $script:RepoRoot '.codex/scripts/epic-child-launch-runtime.ps1')
            $launcher = Get-Content -Raw -LiteralPath `
            (Join-Path $script:RepoRoot '.codex/scripts/launch-epic-child-wave.ps1')

            $runtime | Should -Match 'git-common-dir'
            $runtime | Should -Match "status', '--porcelain=v1', '--untracked-files=all'"
            $runtime | Should -Match 'trusted RepositoryRoot HEAD'
            $runtime | Should -Match 'RepositoryRoot must be completely clean at its committed integration tip'
            ([regex]::Matches($runtime, "status', '--porcelain=v1', '--untracked-files=all'")).Count |
                Should -BeGreaterThan 1
            $launcher | Should -Match '--dangerously-bypass-hook-trust'
            Test-CodexChildCustomizationClean -StatusLines @() | Should -BeTrue
            Test-CodexChildCustomizationClean -StatusLines @(' M .codex/config.toml') | Should -BeFalse
        }

        It 'extracts the exact Codex session id from JSONL for resume continuity' {
            $lines = @(
                '{"type":"turn.started"}',
                '{"type":"thread.started","thread_id":"019f-session-id"}'
            )

            Get-CodexChildSessionId -JsonLines $lines | Should -BeExactly '019f-session-id'
        }
    }

    Context 'PreToolUse worktree binding' {
        BeforeAll {
            $script:SpecPath = Join-Path $script:RepoRoot 'artifacts/orchestration/launch-spec.json'
            $script:ReceiptPath = Join-Path $script:RepoRoot 'artifacts/orchestration/launch-receipt.json'
            $script:SpecHash = ('b' * 64)
            $script:Receipt = [pscustomobject]@{
                schema_version          = 2
                state                   = 'active'
                codex_session_id        = '019f-session-id'
                session_bound_at        = '2026-07-10T12:00:00Z'
                expires_at              = '2999-07-10T12:00:00Z'
                launch_id               = 'wave-1-child-a'
                delegation_id           = 'delegate-child-a'
                feature_folder          = 'child-a'
                deployment_agent        = 'orchestrator-c3-elevated'
                model                   = 'gpt-5.6-sol'
                model_reasoning_effort  = 'high'
                execution_context       = 'epic_execution_child'
                worktree_path           = $script:RepoRoot
                branch_name             = 'feature/child-a'
                profile_sha256          = ('a' * 64)
                profile_path            = Join-Path $script:RepoRoot '.codex/agents/orchestrator-c3-elevated.toml'
                receipt_path            = $script:ReceiptPath
                status_path             = Join-Path $script:RepoRoot 'artifacts/orchestration/status.json'
                spec_path               = $script:SpecPath
                spec_sha256             = $script:SpecHash
                codex_home_path         = 'C:\isolated'
                checkpoint_kind         = 'epic-orchestrator'
                wave_lock_path          = Join-Path $script:RepoRoot 'artifacts/orchestration/epic-child-launches/.locks/wave.lock'
                trusted_repository_root = $script:RepoRoot
            }
            $script:ReceiptRaw = $script:Receipt | ConvertTo-Json -Compress
            $script:Attestation = [pscustomobject]@{
                launch_id         = 'wave-1-child-a'
                delegation_id     = 'delegate-child-a'
                execution_context = 'epic_execution_child'
                agent             = 'orchestrator-c3-elevated'
                model             = 'gpt-5.6-sol'
                reasoning_effort  = 'high'
                expected_worktree = $script:RepoRoot
                profile_sha256    = ('a' * 64)
                receipt_path      = $script:ReceiptPath
                spec_path         = $script:SpecPath
            }
            $script:Mutation = @{
                cwd        = $script:RepoRoot
                session_id = '019f-session-id'
                tool_name  = 'apply_patch'
                model      = 'gpt-5.6-sol'
                tool_input = @{ command = '*** Update File: src/service.py' }
            } | ConvertTo-Json -Compress
        }

        It 'allows a launch-authorized mutation in the exact worktree and branch' {
            Invoke-CodexEpicChildGuardDecision -PayloadRaw $script:Mutation `
                -ReceiptRaw $script:ReceiptRaw -Attestation $script:Attestation `
                -HookRepositoryRoot $script:RepoRoot -LiveBranch 'feature/child-a' `
                -ActualSpecSha256 $script:SpecHash -ActualProfileSha256 ('a' * 64) |
                Should -BeNullOrEmpty
        }

        It 'denies a mismatched working directory, branch, spec hash, or environment attestation' -ForEach @(
            @{ Name = 'cwd'; Cwd = 'C:\different'; Branch = 'feature/child-a'; Hash = ('b' * 64); Agent = 'orchestrator-c3-elevated' }
            @{ Name = 'branch'; Cwd = $script:RepoRoot; Branch = 'feature/other'; Hash = ('b' * 64); Agent = 'orchestrator-c3-elevated' }
            @{ Name = 'hash'; Cwd = $script:RepoRoot; Branch = 'feature/child-a'; Hash = ('c' * 64); Agent = 'orchestrator-c3-elevated' }
            @{ Name = 'agent'; Cwd = $script:RepoRoot; Branch = 'feature/child-a'; Hash = ('b' * 64); Agent = 'orchestrator-c3' }
        ) {
            $payloadObject = $script:Mutation | ConvertFrom-Json
            $payloadObject.cwd = $Cwd
            $attestation = $script:Attestation.PSObject.Copy()
            $attestation.agent = $Agent

            $decision = Invoke-CodexEpicChildGuardDecision `
                -PayloadRaw ($payloadObject | ConvertTo-Json -Compress) `
                -ReceiptRaw $script:ReceiptRaw -Attestation $attestation `
                -HookRepositoryRoot $script:RepoRoot -LiveBranch $Branch `
                -ActualSpecSha256 $Hash -ActualProfileSha256 ('a' * 64)

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Match 'EPIC_WORKTREE_BINDING_BLOCKED'
        }

        It 'requires explicit matching workspace_root on every drm-copilot MCP call' {
            $missing = @{
                cwd        = $script:RepoRoot
                session_id = '019f-session-id'
                tool_name  = 'mcp__drm-copilot__validate_orchestration_artifacts'
                tool_input = @{}
            } | ConvertTo-Json -Compress
            $matching = @{
                cwd        = $script:RepoRoot
                session_id = '019f-session-id'
                tool_name  = 'mcp__drm-copilot__validate_orchestration_artifacts'
                tool_input = @{ workspace_root = $script:RepoRoot }
            } | ConvertTo-Json -Compress

            (Invoke-CodexEpicChildGuardDecision -PayloadRaw $missing -ReceiptRaw $script:ReceiptRaw `
                -Attestation $script:Attestation -HookRepositoryRoot $script:RepoRoot `
                -LiveBranch 'feature/child-a' -ActualSpecSha256 $script:SpecHash `
                -ActualProfileSha256 ('a' * 64)).
            hookSpecificOutput.permissionDecision | Should -Be 'deny'
            Invoke-CodexEpicChildGuardDecision -PayloadRaw $matching -ReceiptRaw $script:ReceiptRaw `
                -Attestation $script:Attestation -HookRepositoryRoot $script:RepoRoot `
                -LiveBranch 'feature/child-a' -ActualSpecSha256 $script:SpecHash `
                -ActualProfileSha256 ('a' * 64) |
                Should -BeNullOrEmpty
        }

        It 'denies mutation of launch authorization and committed customizations' -ForEach @(
            @{ Kind = 'receipt' }
            @{ Kind = 'specification' }
            @{ Kind = 'configuration' }
        ) {
            $Path = switch ($Kind) {
                'receipt' { $script:ReceiptPath }
                'specification' { $script:SpecPath }
                default { Join-Path $script:RepoRoot '.codex/config.toml' }
            }
            $payload = @{
                cwd        = $script:RepoRoot
                session_id = '019f-session-id'
                tool_name  = 'apply_patch'
                tool_input = @{ command = "*** Update File: $Path" }
            } | ConvertTo-Json -Compress

            $decision = Invoke-CodexEpicChildGuardDecision -PayloadRaw $payload `
                -ReceiptRaw $script:ReceiptRaw -Attestation $script:Attestation `
                -HookRepositoryRoot $script:RepoRoot -LiveBranch 'feature/child-a' `
                -ActualSpecSha256 $script:SpecHash -ActualProfileSha256 ('a' * 64)

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'authorization|customizations'
        }

        It 'does not affect a session that was not started by the launcher' {
            $noAttestation = [pscustomobject]@{ launch_id = '' }

            Invoke-CodexEpicChildGuardDecision -PayloadRaw $script:Mutation -ReceiptRaw '' `
                -Attestation $noAttestation -HookRepositoryRoot $script:RepoRoot `
                -LiveBranch '' -ActualSpecSha256 '' -ActualProfileSha256 '' |
                Should -BeNullOrEmpty
        }
    }
}
