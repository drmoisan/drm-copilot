#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

# Issue #516 Codex facet suite: workspace-root normalization of the tool file_path,
# of apply-patch hunk paths, and of mapped Edit/Write paths before the gate's
# exemption classifier runs. Every case injects both the workspace root and the
# checkpoint, so no case reads the filesystem, invokes the entry point, or depends
# on the current directory.
Describe 'Codex enforce-orchestration-preimplementation-gate.ps1 path normalization' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:HookRoot = Join-Path $script:RepoRoot '.codex/hooks'
        . (Join-Path $script:HookRoot 'enforce-orchestration-preimplementation-gate.ps1')
        . (Join-Path $script:HookRoot 'codex-pretooluse-file-mapping.ps1')

        # Synthetic root for every case. Kept in step with the literal default of
        # Get-CodexPathNormalizationDecision below; both spell the same root.
        $script:SyntheticRoot = 'C:\synthetic\root'

        $script:ExemptCheckpointLiterals = @(
            'artifacts/orchestration/orchestrator-state.json'
            'artifacts/orchestration/parallel-planner-state.json'
            'artifacts/orchestration/parallel-orchestrator-state.json'
            'artifacts/orchestration/epic-planner-state.json'
            'artifacts/orchestration/epic-orchestrator-state.json'
            'artifacts/orchestration/powershell-orchestrator-state.json'
            'artifacts/orchestration/csharp-orchestrator-state.json'
        )

        function ConvertTo-NotReadyCheckpointRaw {
            # An explicitly not-ready checkpoint, so the decision measures the exemption
            # rather than whatever checkpoint happens to exist on disk during the run.
            param()

            return @{
                'issue-num'      = '516'
                'feature-folder' = 'docs/features/active/2026-08-23-preimplementation-gate-rejects-absolute-checkpoint-path-516'
                route_id         = ''
                lifecycle_ready  = $false
            } | ConvertTo-Json -Compress
        }

        function ConvertTo-CodexPreToolPayload {
            param(
                [Parameter(Mandatory)][string] $ToolName,
                [Parameter(Mandatory)][hashtable] $ToolInput
            )

            return [ordered]@{
                session_id      = 'path-normalization-516'
                transcript_path = $null
                cwd             = $script:RepoRoot
                hook_event_name = 'PreToolUse'
                model           = 'gpt-5.6-terra'
                permission_mode = 'default'
                turn_id         = 'turn-516'
                tool_name       = $ToolName
                tool_use_id     = 'tool-516'
                tool_input      = $ToolInput
            } | ConvertTo-Json -Compress -Depth 30
        }

        function Get-CodexPathNormalizationDecision {
            # The Codex decision function consumes a flat mapped tool_input, not the
            # nested Claude envelope.
            param(
                [Parameter(Mandatory)][hashtable] $ToolInput,
                [string] $WorkspaceRoot = 'C:\synthetic\root'
            )

            $raw = $ToolInput | ConvertTo-Json -Compress -Depth 20
            return Invoke-OrchestrationPreimplementationGateDecision `
                -ToolInputRaw $raw `
                -CheckpointRaw (ConvertTo-NotReadyCheckpointRaw) `
                -WorkspaceRoot $WorkspaceRoot
        }
    }

    Context 'absolute file paths resolve against the injected workspace root' {
        It 'allows the absolute checkpoint path' {
            $decision = Get-CodexPathNormalizationDecision -ToolInput @{
                file_path = 'C:\synthetic\root\artifacts\orchestration\orchestrator-state.json'
            }

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows absolute twins of all seven checkpoint literals' {
            foreach ($literal in $script:ExemptCheckpointLiterals) {
                $absolute = 'C:\synthetic\root\' + $literal.Replace('/', '\')

                $decision = Get-CodexPathNormalizationDecision -ToolInput @{ file_path = $absolute }

                $decision.hookSpecificOutput.permissionDecision |
                    Should -Be 'allow' -Because "$absolute resolves to the exempt literal $literal"
            }
        }

        It 'allows an absolute gated-extension evidence path under the feature tree' {
            $absolute = 'C:\synthetic\root\docs\features\active\2026-08-23-preimplementation-gate-rejects-absolute-checkpoint-path-516\evidence\qa-gates\summary.json'

            $decision = Get-CodexPathNormalizationDecision -ToolInput @{ file_path = $absolute }

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'the exemption surface is not widened' {
        It 'denies an absolute production source write under the root' {
            $decision = Get-CodexPathNormalizationDecision -ToolInput @{
                file_path = 'C:\synthetic\root\scripts\dev_tools\x.py'
            }

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }

        It 'denies a checkpoint-shaped path under a different root' {
            $decision = Get-CodexPathNormalizationDecision -ToolInput @{
                file_path = 'C:\other\repo\artifacts\orchestration\orchestrator-state.json'
            }

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }

        It 'denies a parent-directory segment path' {
            $decision = Get-CodexPathNormalizationDecision -ToolInput @{
                file_path = 'C:\synthetic\root\x\..\artifacts\orchestration\orchestrator-state.json'
            }

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }

        It 'denies a UNC path under a non-UNC root' {
            $decision = Get-CodexPathNormalizationDecision -ToolInput @{
                file_path = '\\server\share\artifacts\orchestration\orchestrator-state.json'
            }

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }

        It 'denies a drive-relative path' {
            $decision = Get-CodexPathNormalizationDecision -ToolInput @{
                file_path = 'C:artifacts\orchestration\orchestrator-state.json'
            }

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }
    }

    Context 'the two Codex-only routes into the classifier normalize identically' {
        It 'normalizes absolute apply-patch hunk paths' {
            # The Codex command classifier harvests hunk paths from an apply_patch
            # command and hands each to the same exemption classifier, so it is the
            # second route the defect reaches.
            $patch = "*** Begin Patch`n" +
            "*** Add File: C:\synthetic\root\artifacts\orchestration\orchestrator-state.json`n" +
            "+{}`n" +
            '*** End Patch'

            $decision = Get-CodexPathNormalizationDecision -ToolInput @{ command = $patch }

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'normalizes absolute mapped edit paths' {
            # Mirrors the direct-mapping pattern of
            # tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1:233-252:
            # the payload is mapped in-process, then the mapped record is evaluated by
            # the decision function. No entry point and no filesystem access.
            $absolute = 'C:\synthetic\root\artifacts\orchestration\orchestrator-state.json'
            $payload = (ConvertTo-CodexPreToolPayload -ToolName 'Write' -ToolInput @{
                    file_path = $absolute
                    content   = '{}'
                }) | ConvertFrom-Json

            $mapped = @(ConvertTo-CodexFileEditInput -Payload $payload)
            $mapped.Count | Should -BeGreaterThan 0 -Because 'a Write payload must map to one record'

            $decision = Get-CodexPathNormalizationDecision -ToolInput @{
                file_path = [string]$mapped[0].file_path
            }

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'ConvertTo-WorkspaceRelativePath returned string' {
        It 'strips the workspace root from an absolute path' {
            $result = ConvertTo-WorkspaceRelativePath `
                -FilePath 'C:\synthetic\root\artifacts\orchestration\orchestrator-state.json' `
                -WorkspaceRoot 'C:\synthetic\root'

            $result | Should -BeExactly 'artifacts/orchestration/orchestrator-state.json'
        }

        It 'passes an outside-root path through unchanged' {
            $result = ConvertTo-WorkspaceRelativePath `
                -FilePath 'C:\other\repo\artifacts\orchestration\orchestrator-state.json' `
                -WorkspaceRoot 'C:\synthetic\root'

            $result | Should -BeExactly 'C:/other/repo/artifacts/orchestration/orchestrator-state.json'
        }
    }
}
