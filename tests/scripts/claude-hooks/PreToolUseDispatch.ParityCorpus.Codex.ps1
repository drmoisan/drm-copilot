<#
.SYNOPSIS
    In-memory PreToolUse parity envelopes for the Codex dispatcher registry (issue #1159).

.DESCRIPTION
    Invoked (not dot-sourced) by PreToolUseDispatch.Parity.Tests.ps1, this script returns one
    hashtable in the shape PreToolUseDispatch.ParityCorpus.Claude.ps1 documents: Runtime,
    Envelopes (Key, ToolName, ToolInput, Environment, Kind, Deny, Except) and NoEnvelope.

    The shapes are harvested from the Codex hook suites: the missing-tool_input anomaly, the
    apply_patch Add File envelope of codex-pretooluse-integration.Tests.ps1, the validate-bash
    dangerous pattern, the standalone merge and epic worktree-removal commands, the poetry-venv
    VIRTUAL_ENV rule, the evidence-location rule, and the wave-barrier launcher context
    ('allows a preparation child and denies an unknown launcher context'). Patch envelopes add
    files under tests/ or artifacts/, which the batch-budget hooks never record. No envelope
    makes a hook write a file or call gh. Text is LF only.
#>

@{
    Runtime    = 'codex'
    Envelopes  = @(
        @{
            Key = 'bash-allow'; ToolName = 'Bash'; Kind = 'allow'; Environment = @{}
            ToolInput = @{ command = 'git status --short' }
            Deny = @(); Except = @()
        }
        @{
            Key = 'bash-missing-tool-input'; ToolName = 'Bash'; Kind = 'deny'; Environment = @{}
            ToolInput = $null
            Deny      = @('validate-bash.ps1', 'enforce-promotion-mcp-only.ps1', 'enforce-orchestration-preimplementation-gate.ps1', 'enforce-discovery-artifact-gate.ps1')
            Except    = @()
        }
        @{
            Key = 'bash-standalone-merge'; ToolName = 'Bash'; Kind = 'deny'; Environment = @{}
            ToolInput = @{ command = 'gh pr merge 999999 --squash' }
            Deny = @('enforce-epic-merge-gate.ps1'); Except = @()
        }
        @{
            Key = 'bash-worktree-removal'; ToolName = 'Bash'; Kind = 'deny'; Environment = @{}
            ToolInput = @{ command = 'git worktree remove .claude/worktrees/parity-probe' }
            Deny = @('enforce-epic-worktree-removal-gate.ps1'); Except = @()
        }
        @{
            Key = 'bash-poetry-outside-venv'; ToolName = 'Bash'; Kind = 'deny'
            Environment = @{ VIRTUAL_ENV = '/parity-probe-outside/.venv' }
            ToolInput   = @{ command = 'poetry install' }
            Deny = @('enforce-worktree-poetry-venv.ps1'); Except = @()
        }
        @{
            Key = 'bash-direct-test-runner'; ToolName = 'Bash'; Kind = 'deny'; Environment = @{}
            ToolInput = @{ command = 'pytest -q tests/parity-probe' }
            Deny = @('enforce-test-execution-policy.ps1'); Except = @()
        }
        @{
            Key = 'bash-unknown-launcher-context'; ToolName = 'Bash'; Kind = 'deny'
            Environment = @{ CODEX_EPIC_CHILD_LAUNCH_ID = 'parity-probe'; CODEX_EPIC_CHILD_EXECUTION_CONTEXT = 'other' }
            ToolInput   = @{ command = 'git status --short' }
            Deny = @('enforce-epic-wave-barrier.ps1', 'enforce-epic-child-worktree-binding.ps1'); Except = @()
        }
        @{
            Key = 'patch-allow'; ToolName = 'apply_patch'; Kind = 'allow'; Environment = @{}
            ToolInput = @{ command = "*** Begin Patch`n*** Add File: tests/scripts/parity-probe/ParityProbe.Tests.ps1`n+Describe 'p' { It 'q' { 1 | Should -Be 1 } }`n*** End Patch`n" }
            Deny = @(); Except = @()
        }
        @{
            Key = 'patch-missing-tool-input'; ToolName = 'apply_patch'; Kind = 'deny'; Environment = @{}
            ToolInput = $null
            Deny      = @(
                'enforce-discovery-artifact-gate.ps1', 'check-python-test-purity.ps1', 'enforce-python-batch-budget.ps1',
                'check-powershell-test-purity.ps1', 'enforce-powershell-batch-budget.ps1', 'enforce-evidence-locations.ps1',
                'enforce-file-size-limit.ps1', 'enforce-orchestration-preimplementation-gate.ps1', 'enforce-checkpoint-monotonic.ps1',
                'enforce-completion-consistency.ps1'
            )
            Except    = @()
        }
        @{
            Key = 'patch-non-canonical-evidence'; ToolName = 'apply_patch'; Kind = 'deny'; Environment = @{}
            ToolInput = @{ command = "*** Begin Patch`n*** Add File: artifacts/baselines/parity-probe.md`n+probe`n*** End Patch`n" }
            Deny = @('enforce-evidence-locations.ps1'); Except = @()
        }
        @{
            Key = 'agent-allow'; ToolName = 'spawn_agent'; Kind = 'allow'; Environment = @{}
            ToolInput = @{ agent_type = 'task-researcher'; message = 'parity probe' }
            Deny = @(); Except = @()
        }
        @{
            Key = 'agent-missing-tool-input'; ToolName = 'spawn_agent'; Kind = 'deny'; Environment = @{}
            ToolInput = $null
            Deny = @('enforce-discovery-artifact-gate.ps1', 'enforce-discovery-planning-gate.ps1'); Except = @()
        }
        @{
            Key = 'mcp-allow'; ToolName = 'mcp__drm-copilot__run_poshqc_format'; Kind = 'allow'; Environment = @{}
            ToolInput = @{ workspace_root = '.' }
            Deny = @(); Except = @()
        }
        @{
            Key = 'mcp-missing-tool-input'; ToolName = 'mcp__drm-copilot__run_poshqc_format'; Kind = 'deny'; Environment = @{}
            ToolInput = $null
            Deny = @('enforce-discovery-artifact-gate.ps1'); Except = @()
        }
    )
    NoEnvelope = @{
        'enforce-epic-root-invocation.ps1' = 'needs a filesystem mock: the deny path reads the SubagentStart attestation file keyed by the transcript path'
        'enforce-codex-model-routing.ps1'  = 'needs a filesystem mock: the deny path reads the routing attestation recorded for the agent transcript'
        'enforce-epic-planning-only.ps1'   = 'needs a filesystem mock: the deny path reads the epic planning checkpoint under artifacts/orchestration'
    }
}
