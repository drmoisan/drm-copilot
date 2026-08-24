#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

# Issue #516 facet suite: workspace-root normalization of the tool file_path before
# the gate's exemption classifier runs. Every case is a pure in-memory call. The
# workspace root is injected through -WorkspaceRoot and the checkpoint through
# -CheckpointRaw, so no filesystem read and no current-directory dependency exists.
Describe 'enforce-orchestration-preimplementation-gate.ps1 path normalization' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-orchestration-preimplementation-gate.ps1").Path
        . $script:UnderTest

        # Synthetic root for every case. Kept in step with the literal default of
        # Get-PathNormalizationDecision below; both spell the same root.
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

        function ConvertTo-ImplementationWriteToolInput {
            param(
                [Parameter(Mandatory)] [string] $FilePath,
                [string] $Content = 'implementation change'
            )

            return (@{
                    tool_name  = 'Write'
                    tool_input = @{ file_path = $FilePath; content = $Content }
                } | ConvertTo-Json -Compress -Depth 5)
        }

        function ConvertTo-NotReadyCheckpointRaw {
            # An explicitly not-ready checkpoint. Supplying it means Get-CheckpointContent
            # never runs, so the decision measures the exemption rather than whatever
            # checkpoint happens to exist on disk during the run.
            param()

            return @{
                'issue-num'      = '516'
                'feature-folder' = 'docs/features/active/2026-08-23-preimplementation-gate-rejects-absolute-checkpoint-path-516'
                route_id         = ''
                lifecycle_ready  = $false
            } | ConvertTo-Json -Compress
        }

        function Get-PathNormalizationDecision {
            param(
                [Parameter(Mandatory)] [string] $FilePath,
                [string] $WorkspaceRoot = 'C:\synthetic\root'
            )

            $json = ConvertTo-ImplementationWriteToolInput -FilePath $FilePath
            return Invoke-OrchestrationPreimplementationGateDecision `
                -ToolInputRaw $json `
                -CheckpointRaw (ConvertTo-NotReadyCheckpointRaw) `
                -WorkspaceRoot $WorkspaceRoot
        }
    }

    Context 'absolute checkpoint spellings resolve to the exempt literals' {
        It 'allows the absolute backslash checkpoint path' {
            # Spec decision-table row 3 - the defect reported in issue #516.
            $decision = Get-PathNormalizationDecision -FilePath 'C:\synthetic\root\artifacts\orchestration\orchestrator-state.json'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows absolute backslash twins of all seven checkpoint literals' {
            # Spec decision-table row 3, generalized over the literal list.
            foreach ($literal in $script:ExemptCheckpointLiterals) {
                $absolute = 'C:\synthetic\root\' + $literal.Replace('/', '\')

                $decision = Get-PathNormalizationDecision -FilePath $absolute

                $decision.hookSpecificOutput.permissionDecision |
                    Should -Be 'allow' -Because "$absolute resolves to the exempt literal $literal"
            }
        }

        It 'allows absolute forward-slash twins of all seven checkpoint literals' {
            # Spec decision-table row 4.
            foreach ($literal in $script:ExemptCheckpointLiterals) {
                $absolute = 'C:/synthetic/root/' + $literal

                $decision = Get-PathNormalizationDecision -FilePath $absolute

                $decision.hookSpecificOutput.permissionDecision |
                    Should -Be 'allow' -Because "$absolute resolves to the exempt literal $literal"
            }
        }

        It 'allows a lower-case drive letter checkpoint path' {
            # Spec decision-table row 5.
            $decision = Get-PathNormalizationDecision -FilePath 'c:\synthetic\root\artifacts\orchestration\orchestrator-state.json'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows an upper-cased root segment checkpoint path' {
            # Spec decision-table row 6.
            $decision = Get-PathNormalizationDecision -FilePath 'C:/SYNTHETIC/ROOT/artifacts/orchestration/orchestrator-state.json'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows a trailing-separator workspace root' {
            # Spec decision-table row 7. This is the one case that supplies a root other
            # than the shared synthetic root, so algorithm step 5 (trailing-slash trim)
            # is exercised.
            $decision = Get-PathNormalizationDecision `
                -FilePath 'C:\synthetic\root\artifacts\orchestration\orchestrator-state.json' `
                -WorkspaceRoot 'C:\synthetic\root\'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows duplicated separators in the checkpoint path' {
            # Spec decision-table row 9.
            $decision = Get-PathNormalizationDecision -FilePath 'C:/synthetic/root//artifacts//orchestration/orchestrator-state.json'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows an identity dot segment in the checkpoint path' {
            # Spec decision-table row 10.
            $decision = Get-PathNormalizationDecision -FilePath 'C:/synthetic/root/./artifacts/orchestration/orchestrator-state.json'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows a leading dot-slash checkpoint path' {
            # Spec decision-table row 15.
            $decision = Get-PathNormalizationDecision -FilePath './artifacts/orchestration/orchestrator-state.json'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows mixed separators in the checkpoint path' {
            # Spec decision-table row 21.
            $decision = Get-PathNormalizationDecision -FilePath 'C:\synthetic\root/artifacts\orchestration/orchestrator-state.json'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'absolute feature-tree paths reach the documentation exemption' {
        It 'allows an absolute gated-extension evidence path under the feature tree' {
            # Spec decision-table row 16 - a .json evidence artifact, which the extension
            # pattern would otherwise classify as an implementation write.
            $absolute = 'C:\synthetic\root\docs\features\active\2026-08-23-preimplementation-gate-rejects-absolute-checkpoint-path-516\evidence\qa-gates\summary.json'

            $decision = Get-PathNormalizationDecision -FilePath $absolute

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows the absolute twin of the feature spec path' {
            $absolute = 'C:\synthetic\root\docs\features\active\2026-06-26-orchestration-enforcement-hardening-253\spec.md'

            $decision = Get-PathNormalizationDecision -FilePath $absolute

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'the exemption surface is not widened' {
        It 'denies an absolute production source write under the root' {
            # Spec decision-table row 17 - the critical negative. An absolute
            # implementation write stays gated after the fix.
            $decision = Get-PathNormalizationDecision -FilePath 'C:\synthetic\root\scripts\dev_tools\x.py'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }

        It 'denies an absolute non-literal file under the orchestration artifacts folder' {
            # Spec decision-table row 18 - the literal set is not a directory prefix.
            $decision = Get-PathNormalizationDecision -FilePath 'C:\synthetic\root\artifacts\orchestration\some-other-file.json'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }

        It 'denies an absolute checkpoint basename outside its literal path' {
            # Spec decision-table row 19 - full-path equality, not basename matching.
            $decision = Get-PathNormalizationDecision -FilePath 'C:\synthetic\root\scripts\parallel-planner-state.json'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }

        It 'denies a checkpoint-shaped path under a different root' {
            # Spec decision-table row 14 - outside the workspace root, so no strip.
            $decision = Get-PathNormalizationDecision -FilePath 'C:\other\repo\artifacts\orchestration\orchestrator-state.json'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }

        It 'denies a segment-misaligned root prefix' {
            # Spec decision-table row 8 - 'C:/synthetic/rootX' carries the root as a
            # character prefix but not as a path segment.
            $decision = Get-PathNormalizationDecision -FilePath 'C:\synthetic\rootX\artifacts\orchestration\orchestrator-state.json'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }

        It 'denies a parent-directory segment path' {
            # Spec decision-table row 11 - the fail-closed guard; '..' is never resolved.
            $decision = Get-PathNormalizationDecision -FilePath 'C:\synthetic\root\x\..\artifacts\orchestration\orchestrator-state.json'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }

        It 'denies a UNC path under a non-UNC root' {
            # Spec decision-table row 12.
            $decision = Get-PathNormalizationDecision -FilePath '\\server\share\artifacts\orchestration\orchestrator-state.json'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }

        It 'denies a drive-relative path' {
            # Spec decision-table row 20 - 'C:artifacts/...' has no separator after the
            # drive designator, so it names no location the algorithm can resolve.
            $decision = Get-PathNormalizationDecision -FilePath 'C:artifacts\orchestration\orchestrator-state.json'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }

        It 'denies an upper-cased docs tail under the root' {
            # Spec decision-table row 23 - the prefix exemption keeps its case-sensitive
            # StartsWith, so the stripped tail behaves exactly as the relative form does.
            $decision = Get-PathNormalizationDecision -FilePath 'C:/synthetic/root/DOCS/features/active/x/file.json'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }
    }

    Context 'ConvertTo-WorkspaceRelativePath returned string' {
        It 'strips a lower-case drive letter root' {
            # Spec decision-table row 5.
            $result = ConvertTo-WorkspaceRelativePath `
                -FilePath 'c:\synthetic\root\artifacts\orchestration\orchestrator-state.json' `
                -WorkspaceRoot 'C:\synthetic\root'

            $result | Should -BeExactly 'artifacts/orchestration/orchestrator-state.json'
        }

        It 'collapses duplicated separators before stripping' {
            # Spec decision-table row 9.
            $result = ConvertTo-WorkspaceRelativePath `
                -FilePath 'C:/synthetic/root//artifacts//orchestration/orchestrator-state.json' `
                -WorkspaceRoot 'C:\synthetic\root'

            $result | Should -BeExactly 'artifacts/orchestration/orchestrator-state.json'
        }

        It 'removes identity dot segments before stripping' {
            # Spec decision-table row 10.
            $result = ConvertTo-WorkspaceRelativePath `
                -FilePath 'C:/synthetic/root/./artifacts/./orchestration/orchestrator-state.json' `
                -WorkspaceRoot 'C:\synthetic\root'

            $result | Should -BeExactly 'artifacts/orchestration/orchestrator-state.json'
        }

        It 'strips a UNC root from a UNC path' {
            # Spec decision-table row 13 - the leading '//' server prefix survives the
            # duplicate-separator collapse on both operands, so the prefix test aligns.
            $result = ConvertTo-WorkspaceRelativePath `
                -FilePath '\\server\share\repo\artifacts\orchestration\orchestrator-state.json' `
                -WorkspaceRoot '\\server\share\repo'

            $result | Should -BeExactly 'artifacts/orchestration/orchestrator-state.json'
        }

        It 'passes a drive-relative path through unchanged' {
            # Spec decision-table row 20.
            $result = ConvertTo-WorkspaceRelativePath `
                -FilePath 'C:artifacts\orchestration\orchestrator-state.json' `
                -WorkspaceRoot 'C:\synthetic\root'

            $result | Should -BeExactly 'C:artifacts/orchestration/orchestrator-state.json'
        }

        It 'preserves tail case after stripping' {
            # Spec decision-table row 22 - only the root-prefix comparison ignores case.
            $result = ConvertTo-WorkspaceRelativePath `
                -FilePath 'C:/synthetic/root/ARTIFACTS/orchestration/orchestrator-state.json' `
                -WorkspaceRoot 'C:\synthetic\root'

            $result | Should -BeExactly 'ARTIFACTS/orchestration/orchestrator-state.json'
        }

        It 'returns the input when the path equals the root' {
            # Spec decision-table row 24 - the degenerate empty-tail case.
            $result = ConvertTo-WorkspaceRelativePath `
                -FilePath 'C:\synthetic\root' `
                -WorkspaceRoot 'C:\synthetic\root'

            $result | Should -BeExactly 'C:/synthetic/root'
        }
    }
}
