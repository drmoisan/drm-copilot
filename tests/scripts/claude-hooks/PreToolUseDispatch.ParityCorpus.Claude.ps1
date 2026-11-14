<#
.SYNOPSIS
    In-memory PreToolUse parity envelopes for the Claude dispatcher registry (issue #1159).

.DESCRIPTION
    Invoked (not dot-sourced) by PreToolUseDispatch.Parity.Tests.ps1, this script returns one
    hashtable and defines no function or variable in the caller's scope:

      Runtime     'claude'.
      Envelopes   one entry per envelope: Key, ToolName, ToolInput ($null omits the tool_input key),
                  Environment (variables set on both the per-hook processes and the dispatcher
                  process), Kind ('allow' or 'deny'), Deny (hook leaves the envelope must deny)
                  and Except (selected hook leaves an allow envelope does not count as allows).
      NoEnvelope  hook leaf -> the reason no allow or deny envelope is possible without a
                  filesystem mock, a file write or a gh call.

    The payload shapes are harvested from the existing hook suites: the missing-tool_input
    anomaly ('denies the legacy flat root shape as a missing-tool_input anomaly'), the
    validate-bash dangerous pattern, the poetry-venv VIRTUAL_ENV rule, and the evidence-location
    and file-size rules. Write envelopes target paths under tests/ or artifacts/, which the
    batch-budget hooks never record. No envelope makes a hook write a file or call gh: the
    discovery-sentinel tool, which writes a host observation, is not used. Text is LF only.
#>

@{
    Runtime    = 'claude'
    Envelopes  = @(
        @{
            Key = 'bash-allow'; ToolName = 'Bash'; Kind = 'allow'; Environment = @{}
            ToolInput = @{ command = 'git status --short' }
            Deny = @(); Except = @()
        }
        @{
            Key = 'bash-missing-tool-input'; ToolName = 'Bash'; Kind = 'deny'; Environment = @{}
            ToolInput = $null
            Deny      = @(
                'enforce-promotion-mcp-only.ps1', 'enforce-pr-author-skill.ps1', 'enforce-orchestration-preimplementation-gate.ps1',
                'enforce-epic-merge-gate.ps1', 'enforce-docs-complete-gate.ps1', 'enforce-epic-worktree-removal-gate.ps1',
                'enforce-parallel-worktree-removal-gate.ps1', 'enforce-parallel-abandon-gate.ps1', 'enforce-discovery-artifact-gate.ps1'
            )
            Except    = @()
        }
        @{
            Key = 'bash-dangerous-pattern'; ToolName = 'Bash'; Kind = 'deny'; Environment = @{}
            ToolInput = @{ command = 'rm -rf /tmp/parity-probe' }
            Deny = @('validate-bash.ps1'); Except = @()
        }
        @{
            Key = 'bash-direct-issue-create'; ToolName = 'Bash'; Kind = 'deny'; Environment = @{}
            ToolInput = @{ command = 'gh issue create --title parity --body probe' }
            Deny = @('enforce-promotion-mcp-only.ps1'); Except = @()
        }
        @{
            Key = 'bash-poetry-outside-venv'; ToolName = 'Bash'; Kind = 'deny'
            Environment = @{ VIRTUAL_ENV = '/parity-probe-outside/.venv' }
            ToolInput   = @{ command = 'poetry install' }
            Deny = @('enforce-worktree-poetry-venv.ps1'); Except = @()
        }
        @{
            Key = 'write-allow'; ToolName = 'Write'; Kind = 'allow'; Environment = @{}
            ToolInput = @{ file_path = 'tests/scripts/parity-probe/ParityProbe.Tests.ps1'; content = "Describe 'p' { It 'q' { 1 | Should -Be 1 } }`n" }
            Deny = @(); Except = @()
        }
        @{
            Key = 'write-missing-tool-input'; ToolName = 'Write'; Kind = 'deny'; Environment = @{}
            ToolInput = $null
            Deny      = @(
                'check-python-test-purity.ps1', 'enforce-python-batch-budget.ps1', 'check-powershell-test-purity.ps1',
                'enforce-powershell-batch-budget.ps1', 'enforce-evidence-locations.ps1', 'enforce-file-size-limit.ps1',
                'enforce-orchestration-preimplementation-gate.ps1', 'enforce-feature-folder-order.ps1', 'enforce-checkpoint-monotonic.ps1',
                'enforce-completion-consistency.ps1', 'enforce-mermaid-validation.ps1', 'enforce-discovery-artifact-gate.ps1'
            )
            Except    = @()
        }
        @{
            Key = 'write-non-canonical-evidence'; ToolName = 'Write'; Kind = 'deny'; Environment = @{}
            ToolInput = @{ file_path = 'artifacts/baselines/parity-probe.md'; content = "probe`n" }
            Deny = @('enforce-evidence-locations.ps1'); Except = @()
        }
        @{
            Key = 'write-oversize-test-file'; ToolName = 'Write'; Kind = 'deny'; Environment = @{}
            ToolInput = @{ file_path = 'tests/scripts/parity-probe/Oversize.Tests.ps1'; content = ((1..802 | ForEach-Object { "# line $_" }) -join "`n") + "`n" }
            Deny = @('enforce-file-size-limit.ps1'); Except = @()
        }
        @{
            Key = 'agent-allow'; ToolName = 'Agent'; Kind = 'allow'; Environment = @{}
            ToolInput = @{ subagent_type = 'task-researcher'; description = 'parity probe'; prompt = 'parity probe' }
            Deny = @(); Except = @('enforce-model-routing-receipt.ps1')
        }
        @{
            Key = 'agent-missing-tool-input'; ToolName = 'Agent'; Kind = 'deny'; Environment = @{}
            ToolInput = $null
            Deny      = @(
                'enforce-discovery-artifact-gate.ps1', 'enforce-prd-feature-before-planner.ps1', 'enforce-discovery-planning-gate.ps1',
                'enforce-orchestration-preimplementation-gate.ps1', 'enforce-epic-wave-barrier.ps1', 'enforce-model-routing-receipt.ps1',
                'enforce-epic-invocation-origin.ps1', 'enforce-parallel-cohort-barrier.ps1', 'enforce-parallel-drift-gate.ps1'
            )
            Except    = @()
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
        'enforce-docs-role-write-scope.ps1' = 'needs a filesystem mock: the deny path reads the documentation role from the subagent transcript named by transcript_path'
        'enforce-model-routing-receipt.ps1' = 'needs a filesystem mock: the allow path resolves the item worktree and its routing receipt from the checkpoint files on disk'
    }
}
