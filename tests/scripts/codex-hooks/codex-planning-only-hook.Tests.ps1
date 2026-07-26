#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Coverage-closure unit tests for .codex/hooks/enforce-epic-planning-only.ps1.

.DESCRIPTION
    Issue #415 remediation cycle 2 added this hook to CodeCoverage.Path (R-COV), which
    exposed uncovered decision branches above the dot-source guard. These tests target
    exactly the exercisable missed lines catalogued in
    FEATURE/evidence/qa-gates/per-file-coverage.2026-07-26T15-17.md.

    All cases dot-source the hook and exercise its functions directly. No temporary file
    is created and no live executable is invoked; the git wrapper seam is never reached
    because no case drives the entrypoint.
#>

Describe 'enforce-epic-planning-only.ps1 planning-boundary functions' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:PlanningHookPath = Join-Path $script:RepoRoot '.codex/hooks/enforce-epic-planning-only.ps1'

        . $script:PlanningHookPath

        $script:PreparationCheckpoint = '{"route_id":"preparation"}'

        function Get-PlanningPayloadFixture {
            <# Builds a compact JSON payload string for the decision function. #>
            param(
                [Parameter(Mandatory)][string] $ToolName,
                [hashtable] $ToolInput = @{}
            )

            return [ordered]@{
                session_id      = 'issue-415-planning'
                hook_event_name = 'PreToolUse'
                tool_name       = $ToolName
                tool_input      = $ToolInput
                cwd             = $script:RepoRoot
            } | ConvertTo-Json -Compress -Depth 10
        }

        function Invoke-PlanningPreparationDecision {
            <# Runs the decision function with the preparation route selected. #>
            param([Parameter(Mandatory)][string] $PayloadRaw)

            return Invoke-EpicPlanningOnlyDecision -PayloadRaw $PayloadRaw `
                -CheckpointRaw $script:PreparationCheckpoint -EpicExecutionContext '' `
                -StagedPaths $null -CurrentBranch 'feature/planning'
        }
    }

    Context 'ConvertFrom-EpicPlanningJson' {
        It 'returns null for empty input when the caller marks the document optional' {
            # Arrange / Act
            $result = ConvertFrom-EpicPlanningJson -Raw '   ' -Name 'orchestrator checkpoint' -Optional

            # Assert
            $result | Should -BeNullOrEmpty
        }

        It 'throws a blocked message for empty input when the document is required' {
            # Arrange / Act / Assert
            { ConvertFrom-EpicPlanningJson -Raw '' -Name 'PreToolUse input' } |
                Should -Throw -ExpectedMessage '*PreToolUse input is empty.*'
        }
    }

    Context 'Test-EpicPlanningBashAllowed' {
        It 'allows a read-only inspection command from the allowlist' -ForEach @(
            @{ Command = 'git status' }
            @{ Command = 'git log --oneline -5' }
            @{ Command = 'gh issue view 415' }
        ) {
            # Arrange / Act / Assert
            Test-EpicPlanningBashAllowed -Command $Command -StagedPaths $null -CurrentBranch 'feature/planning' |
                Should -BeTrue
        }

        It 'rejects a git add whose path list resolves to no tokens' {
            # Arrange: trailing whitespace produces a whitespace-only path capture.
            # Act / Assert
            Test-EpicPlanningBashAllowed -Command 'git add    ' -StagedPaths $null -CurrentBranch 'feature/planning' |
                Should -BeFalse
        }

        It 'rejects a git commit when the staged set is empty' {
            # Arrange / Act / Assert
            Test-EpicPlanningBashAllowed -Command 'git commit -m "docs: plan"' -StagedPaths @() -CurrentBranch 'feature/planning' |
                Should -BeFalse
        }
    }

    Context 'Invoke-EpicPlanningOnlyDecision apply_patch branches' {
        It 'denies a patch that advances an execution-through-CI step status' {
            # Arrange: preparation may not mark execution steps as anything but not-applicable.
            $patch = @(
                '*** Update File: artifacts/orchestration/orchestrator-state.json',
                '+  "step5_status": "complete"'
            ) -join "`n"
            $payloadRaw = Get-PlanningPayloadFixture -ToolName 'apply_patch' -ToolInput @{ command = $patch }

            # Act
            $decision = Invoke-PlanningPreparationDecision -PayloadRaw $payloadRaw

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Match 'execution-through-CI statuses must remain not-applicable during preparation'
        }

        It 'denies a patch that identifies no artifact path at all' {
            # Arrange: a patch body with no *** File: header yields an empty path list.
            $payloadRaw = Get-PlanningPayloadFixture -ToolName 'apply_patch' -ToolInput @{
                command = "@@ -1 +1 @@`n-old line`n+new line"
            }

            # Act
            $decision = Invoke-PlanningPreparationDecision -PayloadRaw $payloadRaw

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Match 'preparation apply_patch input must identify planning artifact paths'
        }
    }

    Context 'Invoke-EpicPlanningOnlyDecision unclassified tools' {
        It 'denies a tool that preparation mode does not classify' {
            # Arrange: neither apply_patch, nor Bash, nor an MCP tool.
            $payloadRaw = Get-PlanningPayloadFixture -ToolName 'Write' -ToolInput @{ file_path = 'src/service.py' }

            # Act
            $decision = Invoke-PlanningPreparationDecision -PayloadRaw $payloadRaw

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Match "tool 'Write' is not classified for preparation mode"
        }
    }
}
