#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    PreToolUse deny-schema contract test for all 15 PreToolUse hooks.

.DESCRIPTION
    For each PreToolUse-registered hook this test dot-sources the hook (using its
    dot-sourcing guard so the entrypoint does not execute), obtains a
    representative DENY decision from the hook's pure decision/deny-builder
    function, serializes the decision with ConvertTo-Json -Depth 5, re-parses it
    with ConvertFrom-Json, and asserts that the round-tripped object carries:

        hookSpecificOutput.hookEventName       == 'PreToolUse'
        hookSpecificOutput.permissionDecision  == 'deny'

    This is the in-repo proving artifact for the root-cause invariant: Claude
    honors a PreToolUse deny only when the hook emits the hookSpecificOutput
    schema. The contract is enforced once per hook (15 assertion blocks).

    Each hook is dot-sourced inside its own It block so the imported functions
    are scoped to that test and do not collide across hooks (several hooks define
    same-named helpers such as ConvertFrom-CheckpointJson and Test-IsCheckpointPath).

    No disk, network, or temporary files are used. Filesystem seams are mocked or
    bypassed by constructing tool-input payloads directly.
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Injected seam stubs mirror the production scriptblock signatures for testing')]
param()

Describe 'PreToolUse deny-schema contract (all 15 hooks)' {
    BeforeAll {
        $script:HookRoot = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks").Path

        function Assert-PreToolUseDenyShape {
            param(
                [Parameter(Mandatory)]
                $Decision
            )
            $parsed = $Decision | ConvertTo-Json -Depth 5 | ConvertFrom-Json
            $parsed.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
            $parsed.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }
    }

    It 'validate-bash.ps1 emits a PreToolUse deny shape' {
        . (Join-Path $script:HookRoot 'validate-bash.ps1')
        $decision = Get-BashDenyDecision -Reason 'Blocked dangerous command pattern detected'
        Assert-PreToolUseDenyShape -Decision $decision
    }

    It 'enforce-promotion-mcp-only.ps1 emits a PreToolUse deny shape' {
        . (Join-Path $script:HookRoot 'enforce-promotion-mcp-only.ps1')
        $decision = Get-PromotionMcpOnlyBlockDecision
        Assert-PreToolUseDenyShape -Decision $decision
    }

    It 'enforce-pr-author-skill.ps1 emits a PreToolUse deny shape' {
        . (Join-Path $script:HookRoot 'enforce-pr-author-skill.ps1')
        $decision = Get-PrAuthorSkillBlockDecision -Reason 'PR author skill required'
        Assert-PreToolUseDenyShape -Decision $decision
    }

    It 'enforce-orchestration-preimplementation-gate.ps1 emits a PreToolUse deny shape' {
        . (Join-Path $script:HookRoot 'enforce-orchestration-preimplementation-gate.ps1')
        $decision = Get-OrchestrationPreimplementationGateBlockDecision -Reason 'Orchestration not ready'
        Assert-PreToolUseDenyShape -Decision $decision
    }

    It 'check-python-test-purity.ps1 emits a PreToolUse deny shape' {
        . (Join-Path $script:HookRoot 'check-python-test-purity.ps1')
        $decision = Get-PythonTestPurityBlockDecision -Reason 'Python test purity violation'
        Assert-PreToolUseDenyShape -Decision $decision
    }

    It 'enforce-python-batch-budget.ps1 emits a PreToolUse deny shape' {
        . (Join-Path $script:HookRoot 'enforce-python-batch-budget.ps1')
        $decision = Get-PythonBatchBudgetBlockDecision -Reason 'Python batch budget exceeded'
        Assert-PreToolUseDenyShape -Decision $decision
    }

    It 'check-powershell-test-purity.ps1 emits a PreToolUse deny shape' {
        . (Join-Path $script:HookRoot 'check-powershell-test-purity.ps1')
        $decision = Get-PowerShellTestPurityBlockDecision -Reason 'PowerShell test purity violation'
        Assert-PreToolUseDenyShape -Decision $decision
    }

    It 'enforce-powershell-batch-budget.ps1 emits a PreToolUse deny shape' {
        . (Join-Path $script:HookRoot 'enforce-powershell-batch-budget.ps1')
        $decision = Get-PowerShellBatchBudgetBlockDecision -Reason 'PowerShell batch budget exceeded'
        Assert-PreToolUseDenyShape -Decision $decision
    }

    It 'enforce-evidence-locations.ps1 emits a PreToolUse deny shape' {
        . (Join-Path $script:HookRoot 'enforce-evidence-locations.ps1')
        $decision = Get-EvidenceLocationBlockDecision -FilePath 'artifacts/baselines/example.md'
        Assert-PreToolUseDenyShape -Decision $decision
    }

    It 'enforce-feature-folder-order.ps1 emits a PreToolUse deny shape' {
        . (Join-Path $script:HookRoot 'enforce-feature-folder-order.ps1')
        # All required siblings reported missing -> deny path.
        Mock -CommandName Get-FeatureFolderFileExistence -MockWith { param([string]$Path) $false }
        $toolInput = @{
            tool_name  = 'Write'
            tool_input = @{ file_path = 'docs/features/active/2026-01-01-example-1/plan.md' }
        } | ConvertTo-Json -Compress -Depth 5
        $decision = Invoke-FeatureFolderOrderDecision -ToolInputRaw $toolInput
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'FEATURE_FOLDER_ORDER_BLOCKED'
        Assert-PreToolUseDenyShape -Decision $decision
    }

    It 'enforce-checkpoint-monotonic.ps1 emits a PreToolUse deny shape' {
        . (Join-Path $script:HookRoot 'enforce-checkpoint-monotonic.ps1')
        # Advanced step present without S3_promotion / S4_atomic_planning -> deny.
        $content = '{"completed_steps":["S5_atomic_execution"]}'
        $toolInput = (@{
                tool_name  = 'Write'
                tool_input = @{ file_path = 'artifacts/orchestration/orchestrator-state.json'; content = $content }
            } | ConvertTo-Json -Compress -Depth 5)
        $decision = Invoke-CheckpointMonotonicDecision -ToolInputRaw $toolInput
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'S4_atomic_planning'
        Assert-PreToolUseDenyShape -Decision $decision
    }

    It 'enforce-completion-consistency.ps1 emits a PreToolUse deny shape' {
        . (Join-Path $script:HookRoot 'enforce-completion-consistency.ps1')
        # Completion asserted without required evidence -> deny.
        $content = '{"next_step":"complete"}'
        $toolInput = (@{
                tool_name  = 'Write'
                tool_input = @{ file_path = 'artifacts/orchestration/orchestrator-state.json'; content = $content }
            } | ConvertTo-Json -Compress -Depth 5)
        $decision = Invoke-CompletionConsistencyDecision -ToolInputRaw $toolInput
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'COMPLETION_CONSISTENCY_BLOCKED'
        Assert-PreToolUseDenyShape -Decision $decision
    }

    It 'enforce-prd-feature-before-planner.ps1 emits a PreToolUse deny shape' {
        . (Join-Path $script:HookRoot 'enforce-prd-feature-before-planner.ps1')
        # atomic-planner delegation with no resolvable feature folder -> deny.
        Mock -CommandName Get-PrdFeatureCheckpointFolder -MockWith { $null }
        $toolInput = (@{
                tool_name  = 'Agent'
                tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'plan something generic' }
            } | ConvertTo-Json -Compress -Depth 5)
        $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $toolInput
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PRD_FEATURE_BLOCKED'
        Assert-PreToolUseDenyShape -Decision $decision
    }

    It 'enforce-epic-invocation-origin.ps1 emits a PreToolUse deny shape' {
        . (Join-Path $script:HookRoot 'enforce-epic-invocation-origin.ps1')
        $decision = Get-EpicInvocationOriginBlockDecision -Reason 'EPIC_INVOCATION_ORIGIN_BLOCKED: test reason'
        Assert-PreToolUseDenyShape -Decision $decision
    }

    It 'enforce-mermaid-validation.ps1 emits a PreToolUse deny shape' {
        . (Join-Path $script:HookRoot 'enforce-mermaid-validation.ps1')
        # A diagram file whose content carries an invalid arrow for its declared type.
        $content = "flowchart TD`n    A --> B`n    B ->> C`n"
        $toolInput = (@{
                tool_name  = 'Write'
                tool_input = @{ file_path = 'docs/diagrams/contract.mmd'; content = $content }
            } | ConvertTo-Json -Compress -Depth 5)
        $decision = Invoke-MermaidValidationDecision -ToolInputRaw $toolInput
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'MERMAID_VALIDATION_BLOCKED'
        Assert-PreToolUseDenyShape -Decision $decision
    }
}
